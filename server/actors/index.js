const express = require('express');
const Model = require('./model.js');
const Controllers = require('./controllers.js');

module.exports = function(app, db, log) {
    var model = Model.define(db, log);
    var router = express.Router();
    var controllers = Controllers(router, model, log);

    app.use('/actors', router);

    return {
        model: model,
        router: router,
        controllers: controllers
    };
}
