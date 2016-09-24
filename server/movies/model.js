var Sequelize = require('sequelize');

exports.define = function(db, log) {
    return db.define('Movie', {
        id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: false },
        title: { type: Sequelize.STRING, allowNull: false },
        release_date: { type: Sequelize.DATE, allowNull: true },
        overview: { type: Sequelize.STRING, allowNull: true },
        image_path: { type: Sequelize.STRING, allowNull: true }
    });
}

exports.sanitize = function(movie) {
	return {
		id: movie.id,
		title: movie.title,
        release_date: movie.release_date ? movie.release_date : null,
        overview: movie.overview ? movie.overview : null,
        image_path: movie.image_path ? movie.image_path : null
	};
}
