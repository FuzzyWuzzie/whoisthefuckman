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

	private static function addActorServer(movie:TMovie, actor:TActor):Promise<TMovie> {
		var d:Deferred<TMovie> = new Deferred<TMovie>();
		var xhr:XMLHttpRequest = new XMLHttpRequest();
		xhr.open("POST", 'http://localhost:8000/api/v1/movie/${movie.id}/actor', true);
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		xhr.setRequestHeader("Authorization", "Bearer " + Authenticate.token);
		xhr.responseType = XMLHttpRequestResponseType.JSON;
		xhr.onload = function() {
			if(xhr.status >= 200 && xhr.status < 300) {
				// parse it
				var mov:TMovie = cast xhr.response.movie;
				var actors:Array<TActor> = cast xhr.response.actors;

				// specify our linkage
				mov.actorIDs = new Array<Int>();
				for(act in actors) {
					mov.actorIDs.push(act.id);
				}

				// store it
				movies.set(mov.id, mov);

				// notify
				changed.trigger();
				d.resolve(mov);
			}
			else {
				d.throwError(xhr.response);
			}
		};
		xhr.onabort = function() { var err:String = 'aborted add actor request'; Main.console.warn(err); d.throwError(err); }
		xhr.onerror = function() { var err:String = 'failed to get add actor'; Main.console.error(err); d.throwError(err); }
		xhr.ontimeout = function() { var err:String = 'get add actor request timed out!'; Main.console.error(err); d.throwError(err); }
		xhr.send('id=${actor.id}');
		return d.promise();
	}

	private static function deleteActorServer(movie:TMovie, actor:TActor):Promise<TMovie> {
		var d:Deferred<TMovie> = new Deferred<TMovie>();
		var xhr:XMLHttpRequest = new XMLHttpRequest();
		xhr.open("DELETE", 'http://localhost:8000/api/v1/movie/${movie.id}/actor/${actor.id}', true);
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		xhr.setRequestHeader("Authorization", "Bearer " + Authenticate.token);
		xhr.responseType = XMLHttpRequestResponseType.JSON;
		xhr.onload = function() {
			if(xhr.status >= 200 && xhr.status < 300) {
				// parse it
				var mov:TMovie = cast xhr.response.movie;
				var actors:Array<TActor> = cast xhr.response.actors;

				// specify our linkage
				mov.actorIDs = new Array<Int>();
				for(act in actors) {
					mov.actorIDs.push(act.id);
				}

				// store it
				movies.set(mov.id, mov);

				// notify
				changed.trigger();
				d.resolve(mov);
			}
			else {
				d.throwError(xhr.response);
			}
		};
		xhr.onabort = function() { var err:String = 'aborted delete actor request'; Main.console.warn(err); d.throwError(err); }
		xhr.onerror = function() { var err:String = 'failed to get delete actor'; Main.console.error(err); d.throwError(err); }
		xhr.ontimeout = function() { var err:String = 'get delete actor request timed out!'; Main.console.error(err); d.throwError(err); }
		xhr.send();
		return d.promise();
	}

	public static function addActor(movie:TMovie, actor:TActor):Promise<TMovie> {
		var d:Deferred<TMovie> = new Deferred<TMovie>();
		var isNew:Bool = !Actors.actors.exists(actor.id);

		if(isNew) {
			d.throwError("Can't handle new actors yet!");
		}
		else {
			return addActorServer(movie, actor);
		}

		return d.promise();
	}

	public static function deleteActor(movie:TMovie, actor:TActor):Promise<TMovie> {
		var d:Deferred<TMovie> = new Deferred<TMovie>();

		if(!Actors.actors.exists(actor.id)) {
			d.throwError("That actor doesn't even exist!");
		}
		else {
			return deleteActorServer(movie, actor);
		}

		return d.promise();
	}
}