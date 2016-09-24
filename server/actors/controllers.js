var Promise = require('bluebird');
var MovieDB = require('moviedb');

module.exports = function(context, router) {
    var controllers = {};
    var mdb = Promise.promisifyAll(MovieDB(context.config.tmdb.key));

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

    controllers.upsert = function(req, res, next) {
        if(!req.body.id) {
            res.status(400).json({
                message: "you need an `id` parameter!"
            });
            return;
        }

        mdb.personInfoAsync({id: req.body.id})
            .then(function(person) {
                return context.models.actor.upsert({
                    id: person.id,
                    name: person.name,
                    biography: person.biography,
                    image_path: person.profile_path
                });
            })
            .then(function(created) {
                return context.models.actor.findById(req.body.id);
            })
            .then(function(actor) {
                res.json(context.sanitize.actor(actor));
            })
            .catch(function(error) {
                if(error.status && error.status === 404) {
                    res.status(404).json({
                        message: "actor wasn't found!"
                    });
                }
                else
                    next(error);
            });
    };
    router.post('/', context.auth, controllers.upsert);
    
    return controllers;
}
