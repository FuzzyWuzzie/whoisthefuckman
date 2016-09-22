package views;

import api.react.React;
import api.react.ReactComponent;
import api.react.ReactMacro.jsx;
import stores.Authenticate;
import stores.Translation;

typedef AppState = {
	var authenticated:Bool;
	var locale:String;
}

class App extends ReactComponentOfState<AppState> {
	public function new(props:Dynamic) {
		super(props);
		state = {
			authenticated: Authenticate.authenticated,
			locale: Translation.locale
		};
	}

	private function update() {
		setState({
			authenticated: Authenticate.authenticated,
			locale: Translation.locale
		});
	}

	override public function componentDidMount() {
		Authenticate.changed.listen(update);
		Translation.changed.listen(update);

		// switch locales based on what the browser reports as default
		if(js.Browser.navigator.languages.length > 0)
			Translation.setLocale(js.Browser.navigator.languages[0]);
		else
			Translation.setLocale(js.Browser.navigator.language);
	}

	override public function componentWillUnmount() {
		Authenticate.changed.unlisten(update);
		Translation.changed.unlisten(update);
	}

	override public function render() {
		return
			React.createElement("div", null,
				React.createElement("header", null,
					React.createElement("h1", null, Translation.get("home/title")),
					React.createElement("p", null, Translation.get("home/tagline"))),
				React.createElement("article", null));
	}
}