// imports
var bunyan = require('bunyan');
var express = require('express');
var bodyParser = require('body-parser');
var sequelize = require('sequelize');
var jwt = require('express-jwt');

// load configuration
require('toml-require').install();
var config = require('./config.toml');

// initialize logging
var log = bunyan.createLogger({
    name: "whoisthefuckman",
    level: (config.log == null || config.log.level == null)
            ? "info"
            : config.log.level
});

// connect to the db
var db = new sequelize('data', '', '', {
    host: 'localhost',
    dialect: 'sqlite',
    pool: {
        max: 5,
        min: 0,
        idle: 10000
    },
    storage: 'whoisthefuckman.db',
    logging: function(query) {
        log.debug("db query", { query: query });
    }
});

// initialize the server
var app = express();
var port = config.server.port;

//  parse bodies as JSON data
app.use(bodyParser.urlencoded({ extended: true }));

// create a global context for our controllers
context = {
    app: app,
    config: config,
    db: db,
    log: log,
    auth: jwt({
        secret: new Buffer(config.auth.secret, 'base64'),
        issuer: config.auth.issuer
    })
};

// load our components
var movies = require('./movies');
var actors = require('./actors');

// setup our models
movies.model = movies.defineModel(db, log);
actors.model = actors.defineModel(db, log);

// define relationships
// TODO: locate this somewhere more obvious!
actors.model.belongsToMany(movies.model, { through: 'ActorMovie' });
movies.model.belongsToMany(actors.model, { through: 'ActorMovie' });

// store all our models in one place
context.models = {
    movie: movies.model,
    actor: actors.model
};

// setup the routes
movies.router = movies.setupRouter(app);
actors.router = actors.setupRouter(app);

// and start our controllers
movies.engageControllers(context, movies.router);
actors.engageControllers(context, actors.router);

// deal with unhandled routes gracefully
app.use(function(req, res, next) {
    res.status(404).json({
        message: "endpoint not found"
    });
});

// handle unauthorized errors
app.use(function(err, req, res, next) {
    if(err.name === 'UnauthorizedError')
        res.status(401).json({
            message: "unauthorized"
        });
    else
        next(err);
});

// deal with errors gracefully
app.use(function(err, req, res, next) {
    log.error("error", err);
    res.status(500).json({
        message: "internal server error"
    });
});

// initialize databases and start!
db.sync().then(function() {
    var server = app.listen(port);
    log.info("server started", {address: server.address()});
});
