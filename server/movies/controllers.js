module.exports = function(context, router) {
    var controllers = {};

    controllers.listAll = function(req, res, next) {
        context.models.movie.findAll()
            .then(function(movies) {
                res.json(movies);
            });
    };
    router.get('/', controllers.listAll);

    controllers.getMovie = function(req, res, next) {
        var MovieNotFound = {};
        context.models.movie.find({
            where: {
                id: req.params.movie_id
            }
        })
        .then(function(movie) {
            if(movie == null)
                throw MovieNotFound;
            res.json(movie);
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
                res.json(actors);
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

    controllers.add = function(req, res, next) {
        context.db.transaction(function(t) {
            var result = {};
            return context.models.movie.create({
                title: req.body.title,
                imdb: req.body.imdb,
                year: req.body.year
            }, {transaction: t})
            .then(function(movie) {
                result.movie = movie;
                return context.models.actor.findAll({
                    where: {
                        id: {
                            $in: JSON.parse(req.body.actors)
                        }
                    }
                });
            })
            .then(function(actors) {
                result.actors = actors;
                return result.movie.addActors(actors, {transaction: t});
            })
            .then(function() {
                return result;
            });
        })
        .then(function(result) {
            res.json(result.movie);
        })
        .catch(function(error) {
            next(error);
        });
    };
    router.post('/', controllers.add);

    return controllers;
}
