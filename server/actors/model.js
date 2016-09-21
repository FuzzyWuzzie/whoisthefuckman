var Sequelize = require('sequelize');

exports.define = function(db, log) {
	return db.define('Actor', {
        name: { type: Sequelize.STRING, allowNull: false },
        imdb: { type: Sequelize.STRING, allowNull: true },
    });
}

exports.sanitize = function(actor) {
	return {
		id: actor.id,
		name: actor.name,
		imdb: actor.imdb ? actor.imdb : null
	};
}