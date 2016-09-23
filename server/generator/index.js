const express = require('express');
const Controllers = require('./controllers.js');

exports.setupRouter = function(app) {
    var router = express.Router();
    app.use('/generator', router);
    return router;
};

exports.engageControllers = function(context, router) {
    return Controllers(context, router);
}

