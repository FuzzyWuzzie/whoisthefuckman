const express = require('express');
const Model = require('./model.js');
const Controllers = require('./controllers.js');

exports.defineModel = function(db, log) {
    return Model.define(db, log);
};

exports.getSanitizer = function() {
	return Model.sanitize;
}

exports.setupRouter = function(app) {
    var router = express.Router();
    app.use('/movie', router);
    return router;
};

exports.engageControllers = function(context, router) {
    return Controllers(context, router);
}

