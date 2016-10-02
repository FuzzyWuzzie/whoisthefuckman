package stores;

import haxe.ds.IntMap;
import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;
import promhx.haxe.Http;
import jsoni18n.I18n;
import promhx.Deferred;
import promhx.Promise;
import tmdb.PersonSearchResult;
import types.TActor;
import tmdb.TMDB;

class Actors {
	private function new() {}
	public static var changed(default, null):Event = new Event();
	public static var actors(default, null):IntMap<TActor> = new IntMap<TActor>();

    public static function add(actor:TActor):Promise<TActor> {
        var d:Deferred<TActor> = new Deferred<TActor>();
        var isNew:Bool = !actors.exists(actor.id);

        if(!isNew) {
            d.throwError('Actor ${actor.name} already exists!');
            return d.promise();
        }

        var xhr:XMLHttpRequest = new XMLHttpRequest();
        xhr.open("POST", Main.apiRoot + '/actor', true);
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.setRequestHeader("Authorization", "Bearer " + Authenticate.token);
        xhr.responseType = XMLHttpRequestResponseType.JSON;
        xhr.onload = function() {
            if(xhr.status >= 200 && xhr.status < 300) {
                // parse it
                var act:TActor = cast xhr.response;

                // store it
                actors.set(act.id, act);

                // notify
                changed.trigger();
                d.resolve(act);
            }
            else {
                d.throwError(xhr.response);
            }
        };
        xhr.onabort = function() { d.throwError('aborted add actor request'); }
        xhr.onerror = function() { d.throwError('failed to get add actor'); }
        xhr.ontimeout = function() { d.throwError('get add actor request timed out!'); }
        xhr.send('id=${actor.id}');

        return d.promise();
    }

	public static function queryAll() {
		var xhr:XMLHttpRequest = new XMLHttpRequest();
		xhr.open("GET", Main.apiRoot + '//actor', true);
		xhr.responseType = XMLHttpRequestResponseType.JSON;
		xhr.onload = function() {
			if(xhr.status >= 200 && xhr.status < 300) {
				// parse it
				var actorList:Array<TActor> = cast xhr.response;
				for(actor in actorList) {
					actors.set(actor.id, actor);
				}
				Main.console.log('got ${actorList.length} actors from the server!');
				changed.trigger();
			}
			else {
				Main.console.error("Failed to load actor list", {
					status: xhr.status,
					response: xhr.response
				});
			}
		};
		xhr.onabort = function() Main.console.warn("aborted actor list request");
		xhr.onerror = function() Main.console.error('failed to get actor list');
		xhr.ontimeout = function() Main.console.error('get actor list request timed out!');
		xhr.send();
	}

	public static function findActors(name:String):Promise<Array<TActor>> {
		var d:Deferred<Array<TActor>> = new Deferred<Array<TActor>>();
		var p:Promise<Array<TActor>> = d.promise();

		var ret:Array<TActor> = new Array<TActor>();

		// search internally
		var regex:EReg = new EReg(".*" + name + ".*", "gi");
		for(actor in actors) {
			if(regex.match(actor.name))
				ret.push(actor);
		}

		// now query TMDB
		TMDB.searchPeople(name)
			.then(function(results:Array<PersonSearchResult>) {
				for(result in results) {
					// make sure we don't have already have them in the results
					var skip:Bool = false;
					for(existing in ret) {
						if(existing.id == result.id) {
							skip = true;
							break;
						}
					}
					if(skip) continue;

					var actor:TActor = {
						id: result.id,
						name: result.name
					};
					if(result.known_for != null) {
						var knownList:Array<String> = new Array<String>();
						for(known_for in result.known_for) {
							if(known_for.title != null)
								knownList.push(known_for.title);
							else if(known_for.name != null)
								knownList.push(known_for.name);
						}
						if(knownList.length > 0)
							actor.biography = "Known for: " + knownList.join(", ");
					}

					ret.push(actor);
				}

				// finally resolve!
				d.resolve(ret);
			})
			.catchError(function(error) {
				d.throwError(error);
			});

		return p;
	}
}