module.exports = function(context, router) {
    var controllers = {};

    controllers.tmdb = function(req, res, next) {
        res.json(context.config.tmdb)
    };
    router.get('/tmdb', context.auth, controllers.tmdb);

    return controllers;
}
