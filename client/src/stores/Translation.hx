package stores;

import promhx.haxe.Http;
import jsoni18n.I18n;
import promhx.Deferred;
import promhx.Promise;

class Translation {
	private function new() {}
	public static var changed(default, null):Event = new Event();
	public static var locale(default, null):String = {
		I18n.loadFromString('
			{
				"home": {
					"title": "Who is the Fuck Man?",
					"tagline": "A list of actors who get to say \'fuck\' in PG-13 movies."
				},
				"footer": {
					"madeincanada": "Made in Canada"
				}
			}
		');
		"en";
	}

	public static function setLocale(newLocale:String) {
		var h = new Http("i18n/" + newLocale + ".json");
		Main.console.log("Switching locale to " + "i18n/" + newLocale + ".json");
		h.async = true;
		h.request();
		h.then(function(contents:String) {
			I18n.loadFromString(contents);
			Main.console.log('Switched to "${newLocale}" locale!');
			locale = newLocale;
			changed.trigger();
		})
		.catchError(function(error:Dynamic) {
			Main.console.warn('Couldn\'t load locale file "${newLocale}"!');
			// try again with the base?
			if(newLocale.indexOf('-') != -1) {
				var baseLocale:String = newLocale.split('-')[0];
				Main.console.log('Couldn\'t load i18n locale "${newLocale}", trying with base locale "${baseLocale}"...');
				var h2 = new Http("i18n/" + baseLocale + ".json");
				h2.async = true;
				h2.request();
				h2.then(function(contents:String) {
					I18n.loadFromString(contents);
					Main.console.log('Switched to "${baseLocale}" locale!');
					locale = baseLocale;
					changed.trigger();
				})
				.catchError(function(error:Dynamic) {
					Main.console.warn("Couldn't load base locale file!");
				});
			}
		});
	}

	public static function get(id:String, ?vars:Map<String, String>):String {
		return I18n.tr(id, vars);
	}
}