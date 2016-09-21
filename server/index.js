// imports
var bunyan = require('bunyan');
var express = require('express');
var bodyParser = require('body-parser');
var sequelize = require('sequelize');
var passport = require('passport');

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
log.info("loaded configuration", config);

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

// throw in some middleware
app.use(bodyParser.urlencoded({
    extended: true
}));

// load our components
var movies = require('./movies');
var actors = require('./actors');

// setup our models
movies.model = movies.defineModel(db, log);
actors.model = actors.defineModel(db, log);

// define relationships
// TODO: locate this somewhere more obvious!
actors.model.belongsToMany(movies.model, { through: 'ActorMovie' });

// store all our models in one place
var models = {
    movie: movies.model,
    actor: actors.model
};
log.trace({ models: Object.keys(models) });

// setup the routes
movies.router = movies.setupRouter(app);
actors.router = actors.setupRouter(app);

// and start our controllers
movies.engageControllers(movies.router, db, models, log);
actors.engageControllers(actors.router, db, models, log);

// deal with unhandled routes gracefully
app.use(function(req, res, next) {
    res.status(404).json({
        success: false
    });
});

// deal with errors gracefully
app.use(function(err, req, res, next) {
    log.error({ error: err });
    res.status(500).json({
        success: false
    });
});

// initialize databases and start!
db.sync().then(function() {
    var server = app.listen(port);
    log.info("server started", {address: server.address()});
});
