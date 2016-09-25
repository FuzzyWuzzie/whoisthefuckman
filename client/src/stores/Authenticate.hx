package stores;

import auth0.Lock;
import macros.Defines;

using StringTools;

class Authenticate {
	private function new(){}
	private static var lock:Lock = {
		var l:Lock = new Lock(Defines.getDefine("AUTH0_CLIENT_ID"), Defines.getDefine("AUTH0_DOMAIN"), {
			theme: {
				logo: "/logo.png",
				primaryColor: "#bf0a30"
			},
			languageDictionary: {
				title: "Who is the Fuck Man?"
			}
		});
		l.on("authenticated", onAuthenticated);
		l;
	};

	public static var changed(default, null):Event = new Event();

	public static var authenticated(default, set):Bool = false;
	private static function set_authenticated(a:Bool):Bool {
		var didChange:Bool = authenticated != a;
		authenticated = a;
		if(didChange) changed.trigger();
		return authenticated;
	}

	public static var token(default, null):String = null;
	public static var profile(default, null):Dynamic = null;

	private static function onAuthenticated(authResult:Dynamic) {
		js.Browser.getLocalStorage().setItem('idToken', authResult.idToken);
		check();
	}

	public static function check() {
		var idToken:String = js.Browser.getLocalStorage().getItem('idToken');
		if(idToken == null || idToken.trim() == "") {
			token = null;
			authenticated = false;
			return;
		}

		// make sure we haven't expired
		var payloadEncoded:String = idToken.split(".")[1];
		var payload:Dynamic = haxe.Json.parse(haxe.crypto.Base64.decode(payloadEncoded).toString());
		var ts:Float = Date.now().getTime() / 1000;
		if(ts >= payload.exp) {
			Main.console.warn("Authentication failed: token expired", {
				expiry: payload.exp,
				now: ts
			});
			token = null;
			authenticated = false;
			return;
		}

		lock.getProfile(idToken, function(error, userProfile) {
			if(error != null) {
				token = null;
				authenticated = false;
				Main.console.error("Unable to get user profile: " + error.message);
				return;
			}
			js.Browser.getLocalStorage().setItem("profile", haxe.Json.stringify(userProfile));
			token = idToken;
			profile = userProfile;
			authenticated = true;
			tmdb.TMDB.init();
		});
	}

	public static function startLogin() {
		if(!authenticated) lock.show();
	}

	public static function logout() {
		js.Browser.getLocalStorage().removeItem("idToken");
		js.Browser.getLocalStorage().removeItem("profile");
		check();
	}

	public static function getProfile():Dynamic {
		if(!authenticated) return null;
		return js.Browser.getLocalStorage().getItem('profile');
	}
}