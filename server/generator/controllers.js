var Mustache = require('./mustache');
var Promise = require('bluebird');
var fs = require('fs-extra');
var minify = require('html-minifier').minify;
var CleanCSS = require('clean-css');
var slug = require('slug');
var extend = require('util')._extend;

fs.readFileAsync = Promise.promisify(fs.readFile);
fs.writeFileAsync = Promise.promisify(fs.writeFile);
fs.copyAsync = Promise.promisify(fs.copy);

module.exports = function(context, router) {
    var controllers = {};

    controllers.build = function(req, res, next) {
        // timing!
        var startTime = new Date();

        // save these for future calls
        var partials = {};
        var homeTemplate = "";
        var actorTemplate = "";
        var rootView = {
            site: {
                title: "Who is the Fuck Man?",
                tag: "A list of actors who get to say 'fuck' in PG-13 movies.",
                root: "whoisthefuckman.com",
                twitter: "@KentonHam"
            },
            slugify: function() {
                return function(text, render) {
                    return slug(render(text));
                }
            }
        };
        var homeView = extend(rootView, {});
        var builtPaths = [];

        // do a clean run
        fs.emptyDirSync("public");
        // make sure our output folders exist
        fs.ensureDirSync("public/assets");
        fs.ensureDirSync("public/actor");

        var compileAndSave = function(template, view, path) {
            var output = Mustache.render(template, view, partials);
            output = minify(output, {
                removeComments: true,
                removeCommentsFromCDATA: true,
                collapseWhitespace: true
            });
            builtPaths.push(path);
            return fs.writeFileAsync(path, output);
        }

        var buildMovie = function(movie) {
            return new Promise(function(resolve, reject) {
                movie.getActors()
                    .then(function(actors) {
                        movie.actors = actors;
                        movie.actors[movie.actors.length - 1].last = true;
                        resolve(movie);
                    })
                    .catch(reject);
            });
        }

        var buildActor = function(actor) {
            return new Promise(function(resolve, reject) {
                actor.getMovies()
                    .then(function(movies) {
                        actor.movies = movies;
                        actor.movies[actor.movies.length - 1].last = true;
                        resolve(actor);
                    })
                    .catch(reject);
            });
        }

        // load our partials
        var partialPromises = [
            fs.readFileAsync("templates/header.mustache", 'utf8'),
            fs.readFileAsync("templates/style.css", 'utf8'),
            fs.readFileAsync("templates/footer.mustache", 'utf8'),
            fs.readFileAsync("templates/analytics.mustache", 'utf8')
        ];
        Promise.all(partialPromises)
            .then(function(pa) {
                partials.header = pa[0];
                partials.style = new CleanCSS().minify(pa[1]).styles;
                partials.footer = pa[2];
                partials.analytics = pa[3];

                // now load our home template
                return fs.readFileAsync("templates/home.mustache", 'utf8')
            })
            .then(function(contents) {
                homeTemplate = contents;
                return context.models.movie.findAll();
            })
            .then(function(movies) {
                var moviePromises = movies.map(buildMovie);
                return Promise.all(moviePromises);
            })
            .then(function(movies) {
                homeView.movies = movies;
                return compileAndSave(homeTemplate, homeView, "public/index.html");
            })
            .then(function() {
                // read the actor template
                return fs.readFileAsync("templates/actor.mustache", 'utf8')
            })
            .then(function(contents) {
                actorTemplate = contents;
                return context.models.actor.findAll();
            })
            .then(function(actors) {
                var actorPromises = actors.map(buildActor);
                return Promise.all(actorPromises);
            })
            .then(function(actors) {
                var actorCompilePromises = actors.map(function(actor) {
                    var view = extend(rootView, {
                        actor: actor
                    });
                    return compileAndSave(actorTemplate, view, "public/actor/" + slug(actor.name) + ".html")
                });
                return Promise.all(actorCompilePromises);
            })
            /*.then(function(arr) {

            })*/
            .then(function() {
                // copy the asset files
                builtPaths.push("public/assets/");
                return fs.copyAsync("assets", "public/assets");
            })
            .then(function() {
                res.json({
                    paths: builtPaths.map(function(path) { return path.substr(6); }),
                    time: (new Date() - startTime) + "ms"
                });
            })
            .catch(function(error) {
                context.log.error("failed to load templates", error);
                res.status(500).json({
                    message: "error loading templates"
                });
            });
    };
    router.post('/', context.auth, controllers.build);
    //router.post('/', controllers.build); // for testing only

    return controllers;
}
