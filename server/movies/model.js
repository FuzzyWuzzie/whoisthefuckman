var Sequelize = require('sequelize');

exports.define = function(db, log) {
    return db.define('Movie', {
        title: Sequelize.STRING,
        imdb: Sequelize.STRING,
        year: Sequelize.INTEGER
    });
}
