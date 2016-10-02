var Promise = require('bluebird');
var MovieDB = require('moviedb');

module.exports = function(context, router) {
    var controllers = {};
    var mdb = Promise.promisifyAll(MovieDB(context.config.tmdb.key));

    controllers.listAll = function(req, res, next) {
        context.models.movie.findAll()
            .then(function(movies) {
                res.json(movies.map(context.sanitize.movie));
            });
    };
    router.get('/', controllers.listAll);

    controllers.getMovie = function(req, res, next) {
        var MovieNotFound = {};
        var result = {};
        context.models.movie.findById(req.params.movie_id)
            .then(function(movie) {
                if(movie == null)
                    throw MovieNotFound;
                result.movie = movie;
                return movie.getActors()
            })
            .then(function(actors) {
                res.json({
                    movie: context.sanitize.movie(result.movie),
                    actors: actors.map(context.sanitize.actor)
                });
            })
            .catch(function(error) {
                if(error === MovieNotFound) {
                    res.status(404).json({
                        message: "movie not found"
                    });
                }
                else
                    next(error);
            });
    };
    router.get('/:movie_id', controllers.getMovie);

    controllers.getActors = function(req, res, next) {
        var MovieNotFound = {};
        context.models.movie.findById(req.params.movie_id)
            .then(function(movie) {
                if(movie == null)
                    throw MovieNotFound;
                return movie.getActors();
            })
            .then(function(actors) {
                res.json(actors.map(context.sanitize.actor));
            })
            .catch(function(error) {
                if(error === MovieNotFound) {
                    res.status(404).json({
                        message: "movie not found"
                    });
                }
                else
                   next(error);
            });
    };
    router.get('/:movie_id/actors', controllers.getActors);

    controllers.upsert = function(req, res, next) {
        if(!req.body.id) {
            res.status(400).json({
                message: "you need an `id` parameter!"
            });
            return;
        }

        mdb.movieInfoAsync({id: req.body.id})
            .then(function(movie) {
                return context.models.movie.upsert({
                    id: movie.id,
                    title: movie.title,
                    release_date: movie.release_date,
                    overview: movie.overview,
                    image_path: movie.poster_path
                });
            })
            .then(function(created) {
                return context.models.movie.findById(req.body.id);
            })
            .then(function(movie) {
                res.json(context.sanitize.movie(movie));
            })
            .catch(function(error) {
                if(error.status && error.status === 404) {
                    res.status(404).json({
                        message: "movie wasn't found!"
                    });
                }
                else
                    next(error);
            });
    };
    router.post('/', context.auth, controllers.upsert);

    controllers.addActor = function(req, res, next) {
        if(!req.body.id) {
            res.status(400).json({
                message: "you need an `id` parameter!"
            });
            return;
        }

        /*context.db.transaction(function(t) {
            var result = {};
            return context.models.movie.findById(req.params.movie_id)
                .then(function(movie) {
                    result.movie = movie;
                    return context.models.actor.findById(parseInt(req.body.id))
                })
                .then(function(actor) {
                    return result.movie.addActor(actor, {transaction: t});
                })
                .then(function() {
                    return result;
                })
        })*/
        var result = {};
        context.models.movie.findById(req.params.movie_id)
            .then(function(movie) {
                result.movie = movie;
                return context.models.actor.findById(parseInt(req.body.id));
            })
            .then(function(actor) {
                return result.movie.addActor(actor);
            })
            .then(function() {
                return result.movie.getActors();
            })
            .then(function(actors) {
                res.json({
                    movie: context.sanitize.movie(result.movie),
                    actors: actors.map(context.sanitize.actor)
                });
            })
            .catch(function(error) {
                next(error);
            });
    };
    router.post('/:movie_id/actor', context.auth, controllers.addActor);

    controllers.deleteActor = function(req, res, next) {
        var MovieNotFound = {};
        var result = {};
        context.models.movie.findById(req.params.movie_id)
            .then(function(movie) {
                if(movie == null)
                    throw MovieNotFound;
                result.movie = movie;
                return movie.removeActor(parseInt(req.params.actor_id));
            })
            .then(function() {
                return result.movie.getActors();
            })
            .then(function(actors) {
                res.json({
                    movie: context.sanitize.movie(result.movie),
                    actors: actors.map(context.sanitize.actor)
                });
            })
            .catch(function(error) {
                if(error === MovieNotFound) {
                    res.status(404).json({
                        message: "movie not found"
                    });
                }
                else
                    next(error);
            });
    }
    router.delete('/:movie_id/actor/:actor_id', context.auth, controllers.deleteActor);

    return controllers;
}
