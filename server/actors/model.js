var Sequelize = require('sequelize');

exports.define = function(db, log) {
	return db.define('Actor', {
        id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: false },
        name: { type: Sequelize.STRING, allowNull: false },
        biography: { type: Sequelize.STRING, allowNull: true },
        image_path: { type: Sequelize.STRING, allowNull: true }
    });
}

exports.sanitize = function(actor) {
	return {
		id: actor.id,
		name: actor.name,
        biography: actor.biography ? actor.biography : null,
        image_path: actor.image_path ? actor.image_path : null
	};
}