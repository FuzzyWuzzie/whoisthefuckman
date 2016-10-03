// imports
var bunyan = require('bunyan');
var express = require('express');
var cors = require('cors');
var bodyParser = require('body-parser');
var sequelize = require('sequelize');
var jwt = require('express-jwt');
var compression = require('compression');

// load configuration
require('toml-require').install();
var config = require('/data/config.toml');

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
    storage: '/data/whoisthefuckman.db',
    logging: function(query) {
        log.trace("db query", { query: query });
    }
});

// initialize the server
var app = express();
var port = config.server.port;

// enable CORS
app.use(cors());

//  parse bodies as JSON data
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// enable gzip compression
app.use(compression());

// enable a static folder
if(config.server.static)
    app.use(express.static('public'));

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
var generator = require('./generator');
var configuration = require('./configuration');

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

movies.sanitize = movies.getSanitizer();
actors.sanitize = actors.getSanitizer();
context.sanitize = {
    movie: movies.sanitize,
    actor: actors.sanitize
}

// setup the routes
var apiRouter = express.Router();
app.use('/api/v1', apiRouter);
movies.router = movies.setupRouter(apiRouter);
actors.router = actors.setupRouter(apiRouter);
generator.router = generator.setupRouter(apiRouter);
configuration.router = configuration.setupRouter(apiRouter);

// and start our controllers
movies.engageControllers(context, movies.router);
actors.engageControllers(context, actors.router);
generator.engageControllers(context, generator.router);
configuration.engageControllers(context, configuration.router);

// deal with unhandled routes gracefully
app.use(function(req, res, next) {
    res.status(404).json({
        message: "endpoint not found",
	urls: {
		original: req.originalUrl,
		base: req.baseUrl,
		path: req.path
	}
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
