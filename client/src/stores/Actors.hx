package stores;

import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;
import promhx.haxe.Http;
import jsoni18n.I18n;
import promhx.Deferred;
import promhx.Promise;
import types.TActor;

class Actors {
	private function new() {}
	public static var changed(default, null):Event = new Event();
	public static var actors(default, null):Array<TActor> = new Array<TActor>();

	public static function queryAll() {
		var xhr:XMLHttpRequest = new XMLHttpRequest();
		xhr.open("GET", "http://localhost:8000/actors", true);
		xhr.responseType = XMLHttpRequestResponseType.JSON;
		xhr.onload = function() {
			if(xhr.status >= 200 && xhr.status < 300) {
				// parse it
				actors = cast xhr.response;
				Main.console.log('got ${actors.length} actors from the server!');
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
}