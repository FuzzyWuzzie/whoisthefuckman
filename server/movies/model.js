var Sequelize = require('sequelize');

exports.define = function(db, log) {
    return db.define('Movie', {
        title: { type: Sequelize.STRING, allowNull: false },
        imdb: { type: Sequelize.STRING, allowNull: true },
        year: { type: Sequelize.INTEGER, allowNull: false }
    });
}

exports.sanitize = function(movie) {
	return {
		id: movie.id,
		title: movie.title,
		imdb: movie.imdb ? movie.imdb : null,
		year: movie.year
	};
}
