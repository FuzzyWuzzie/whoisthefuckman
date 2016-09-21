module.exports = function(router, model, log) {
    var controllers = {};

    controllers.listAll = function(req, res, next) {
        log.trace("listing all movies");
        model.findAll()
            .then(function(movies) {
                res.json(movies);
            });
    };
    // TODO: this is a debug function
    // disable it for production
    router.get('/', controllers.listAll);

    controllers.add = function(req, res, next) {
        // TODO: validate the request
        model.create({
            title: req.body.title,
            imdb: req.body.imdb,
            year: req.body.year
        }).then(function(movie) {
                res.json({
                    success: true,
                    movie: movie
                });
            });
    };
    router.post('/', controllers.add);

    controllers.getActors = function(req, res, next) {
        var MovieNotFound = {};
        var movie;
        model.findById(req.params.movie_id)
            .then(function(mov) {
                if(mov == null)
                    throw MovieNotFound;
                movie = mov;
                return movie.getActors();
            })
            .then(function(actors) {
                movie.actors = actors;
                res.json({
                    success: true,
                    movie: movie
                });
            })
            .catch(function(error) {
                if(error === MovieNotFound) {
                    res.status(404).json({
                        success: false,
                        message: "movie not found"
                    });
                }
                else
                   next(error);
            });
    };
    router.get('/:movie_id/actors', controllers.getActors);

    return controllers;
}
