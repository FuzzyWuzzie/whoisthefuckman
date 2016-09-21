const express = require('express');
const Model = require('./model.js');
const Controllers = require('./controllers.js');

exports.defineModel = function(db, log) {
    return Model.define(db, log);
};

exports.setupRouter = function(app) {
    var router = express.Router();
    app.use('/actors', router);
    return router;
};

exports.engageControllers = function(context, router) {
    return Controllers(context, router);
}

