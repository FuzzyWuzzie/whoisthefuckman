var Sequelize = require('sequelize');

exports.define = function(db, log) {
    return db.define('Actor', {
        name: Sequelize.STRING,
        imdb: Sequelize.STRING
    });
}
