module.exports = function(context, router) {
    var controllers = {};

    controllers.listAll = function(req, res, next) {
        context.models.actor.findAll()
            .then(function(actors) {
                res.json(actors.map(context.sanitize.actor));
            });
    };
    router.get('/', controllers.listAll);

    controllers.getActor = function(req, res, next) {
        var ActorNotFound = {};
        context.models.actor.find({
            where: {
                id: req.params.actor_id
            }
        })
        .then(function(actor) {
            if(actor == null)
                throw ActorNotFound;
            res.json(context.sanitize.actor(actor));
        })
        .catch(function(error) {
            if(error === ActorNotFound) {
                res.status(404).json({
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
        context.models.actor.actor.findById(req.params.actor_id)
            .then(function(actor) {
                if(actor == null)
                    throw ActorNotFound;
                return actor.getMovies();
            })
            .then(function(movies) {
                res.json(movies.map(context.sanitize.movie));
            })
            .catch(function(error) {
                if(error === ActorNotFound) {
                    res.status(404).json({
                        message: "actor not found"
                    });
                }
                else
                   next(error);
            });
    };
    router.get('/:actor_id/movies', controllers.getMovies);

    controllers.add = function(req, res, next) {
        context.models.actor.create({
            name: req.body.name,
            imdb: req.body.imdb
        })
        .then(function(actor) {
            res.json(context.sanitize.actor(actor));
        })
        .catch(function(error) {
            next(error);
        });
    };
    router.post('/', context.auth, controllers.add);

    return controllers;
}
