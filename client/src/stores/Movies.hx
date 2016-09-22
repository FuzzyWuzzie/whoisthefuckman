package stores;

import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;
import promhx.haxe.Http;
import jsoni18n.I18n;
import promhx.Deferred;
import promhx.Promise;
import types.TMovie;

class Movies {
	private function new() {}
	public static var changed(default, null):Event = new Event();
	public static var movies(default, null):Array<TMovie> = new Array<TMovie>();

	public static function queryAll() {
		var xhr:XMLHttpRequest = new XMLHttpRequest();
		xhr.open("GET", "http://localhost:8000/movies", true);
		xhr.responseType = XMLHttpRequestResponseType.JSON;
		xhr.onload = function() {
			if(xhr.status >= 200 && xhr.status < 300) {
				// parse it
				movies = cast xhr.response;
				Main.console.log('got ${movies.length} movies from the server!');
				changed.trigger();
			}
			else {
				Main.console.error("Failed to load movie list", {
					status: xhr.status,
					response: xhr.response
				});
			}
		};
		xhr.onabort = function() Main.console.warn("aborted movie list request");
		xhr.onerror = function() Main.console.error('failed to get movie list');
		xhr.ontimeout = function() Main.console.error('get movie list request timed out!');
		xhr.send();
	}
}