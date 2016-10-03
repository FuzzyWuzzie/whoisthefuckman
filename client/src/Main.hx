package;

import api.react.ReactMacro.jsx;
import api.react.ReactDOM;
import js.Browser;
import js.html.Console;

import views.App;

class Main {
    public static var serverRoot:String = "http://138.197.132.156:8080";
    public static var apiRoot:String = serverRoot + "/api/v1";

	public static var console:Console = Browser.console;

	public static function main() {
		ReactDOM.render(jsx('<$App />'), Browser.document.body);
	}
}
