package;

import api.react.ReactMacro.jsx;
import api.react.ReactDOM;
import js.Browser;
import js.html.Console;

import views.App;

class Main {
	public static var console:Console = Browser.console;

	public static function main() {
		ReactDOM.render(jsx('<$App />'), Browser.document.body);
	}
}