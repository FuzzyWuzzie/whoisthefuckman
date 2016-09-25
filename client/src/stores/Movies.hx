package stores;

import haxe.ds.IntMap;
import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;
import promhx.haxe.Http;
import jsoni18n.I18n;
import promhx.Deferred;
import promhx.Promise;
import types.TActor;
import types.TMovie;

class Movies {
	private function new() {}
	public static var changed(default, null):Event = new Event();
	public static var movies(default, null):IntMap<TMovie> = new IntMap<TMovie>();

	private static function queryActorIDs(movieID:Int) {
		var xhr:XMLHttpRequest = new XMLHttpRequest();
		xhr.open("GET", 'http://localhost:8000/api/v1/movie/${movieID}', true);
		xhr.responseType = XMLHttpRequestResponseType.JSON;
		xhr.onload = function() {
			if(xhr.status >= 200 && xhr.status < 300) {
				// parse it
				var actorList:Array<TActor> = cast xhr.response.actors;
				for(actor in actorList) {
					movies.get(movieID).actorIDs.push(actor.id);
				}
				changed.trigger();
			}
			else {
				Main.console.error('Failed to load movie ${movieID}\'s actors!', {
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

	public static function queryAll() {
		var xhr:XMLHttpRequest = new XMLHttpRequest();
		xhr.open("GET", "http://localhost:8000/api/v1/movie", true);
		xhr.responseType = XMLHttpRequestResponseType.JSON;
		xhr.onload = function() {
			if(xhr.status >= 200 && xhr.status < 300) {
				// parse it
				var movieList:Array<TMovie> = cast xhr.response;

				// convert it into our dictionary
				movies = new IntMap<TMovie>();
				for(movie in movieList) {
					movie.actorIDs = new Array<Int>();
					movies.set(movie.id, movie);
					queryActorIDs(movie.id);
				}

				Main.console.log('got ${movieList.length} movies from the server!');
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

	// TODO: promisify
	public static function addActor(movie:TMovie, actor:TActor) {
		// TODO: sync with server
		movies.get(movie.id).actorIDs.push(actor.id);
		changed.trigger();
	}
}