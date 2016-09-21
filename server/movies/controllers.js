module.exports = function(router, db, models, log) {
    var controllers = {};

    controllers.listAll = function(req, res, next) {
        log.trace("listing all movies");
        models.movie.findAll()
            .then(function(movies) {
                res.json(movies);
            });
    };
    // TODO: this is a debug function
    // disable it for production
    router.get('/', controllers.listAll);

    controllers.getActors = function(req, res, next) {
        var MovieNotFound = {};
        var movie;
        models.movie.findById(req.params.movie_id)
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

    controllers.add = function(req, res, next) {
        db.transaction(function(t) {
            var result = {};
            return models.movie.create({
                title: req.body.title,
                imdb: req.body.imdb,
                year: req.body.year
            }, {transaction: t})
            .then(function(movie) {
                result.movie = movie;
                log.trace("made movie", { movie: movie });
                return models.actor.findAll({
                    where: {
                        id: {
                            $in: JSON.parse(req.body.actors)
                        }
                    }
                }, {transaction: t});
            })
            .then(function(actors) {
                result.actors = actors;
                log.trace("queried actors", { actors: actors });
                return result.movie.addActors(actors, {transaction: t});
            })
            .then(function() {
                log.trace("after add actors", { result: result });
                return result;
            });
        })
        .then(function(result) {
            log.debug("add movie result", { result: result });
            res.json(result);
        })
        .catch(function(error) {
            next(error);
        });
    };
    router.post('/', controllers.add);

    return controllers;
}
