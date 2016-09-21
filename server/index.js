// imports
var bunyan = require('bunyan');
var express = require('express');
var bodyParser = require('body-parser');
var sequelize = require('sequelize');
var passport = require('passport');

// initialize logging
var log = bunyan.createLogger({
    name: "whoisthefuckman",
    level: "debug"
});

// load configuration
require('toml-require').install();
var config = require('./config.toml');
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
var movies = require('./movies')(app, db, log);
var actors = require('./actors')(app, db, log, movies);

// define relationships
// TODO: locate this somewhere more obvious!
actors.model.belongsToMany(movies.model, { through: 'ActorMovie' });

// deal with unhandled routes gracefully
app.use(function(req, res, next) {
    res.status(404).json({
        success: false
    });
});

// deal with errors gracefully
app.use(function(err, req, res, next) {
    log.error("error", { error: err });
    res.status(500).json({
        success: false
    });
});

// initialize databases and start!
db.sync().then(function() {
    var server = app.listen(port);
    log.info("server started", {address: server.address()});
});
