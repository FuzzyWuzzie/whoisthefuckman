module.exports = function(router, db, models, log) {
    var controllers = {};

    controllers.listAll = function(req, res, next) {
        log.trace("listing all actors");
        models.actor.findAll()
            .then(function(actors) {
                res.json(actors);
            });
    };
    // TODO: this is a debug function
    // disable it for production
    router.get('/', controllers.listAll);

    controllers.getActor = function(req, res, next) {
        var ActorNotFound = {};
        var actor;
        models.actor.find({
            where: {
                id: req.params.actor_id
            }
        })
        .then(function(act) {
            if(act == null)
                throw ActorNotFound;
            actor = act;
            res.json({
                success: true,
                actor: actor
            });
        })
        .catch(function(error) {
            if(error === ActorNotFound) {
                res.status(404).json({
                    success: false,
                    message: "actor not found"
                });
            }
            else
                next(error);
        });
    };
    router.get('/:actor_id', controllers.getActor);

    controllers.getMovies = function(req, res, next) {
        var ActorNotFound = {};
        var actor;
        models.actor.actor.findById(req.params.actor_id)
            .then(function(act) {
                if(act == null)
                    throw ActorNotFound;
                actor = act;
                return actor.getMovies();
            })
            .then(function(movies) {
                actor.movies = movies;
                res.json({
                    success: true,
                    actor: actor,
                });
            })
            .catch(function(error) {
                if(error === ActorNotFound) {
                    res.status(404).json({
                        success: false,
                        message: "actor not found"
                    });
                }
                else
                   next(error);
            });
    };
    router.get('/:actor_id/movies', controllers.getMovies);

    controllers.add = function(req, res, next) {
        models.actor.create({
            name: req.body.name,
            imdb: req.body.imdb
        })
        .then(function(actor) {
            res.json({
                success: true,
                actor: actor
            });
        })
        .catch(function(error) {
            next(error);
        });
    };
    router.post('/', controllers.add);

    return controllers;
}
