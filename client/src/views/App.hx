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

		// and check our login
		Authenticate.check();
	}

	override public function componentWillUnmount() {
		Authenticate.changed.unlisten(update);
		Translation.changed.unlisten(update);
	}

	override public function render() {
		return
			React.createElement("div", null,
				React.createElement("header", null,
					React.createElement("h1", null,
						React.createElement("a", {href:"/"}, Translation.get("home/title"))
					),
					React.createElement("p", null, Translation.get("home/tagline"))
				),
				state.authenticated ? React.createElement("p", null, "Make your changes below. When you're done, click the 'Regenerate' button to publish your changes.") : null,
				state.authenticated ? React.createElement("article", null, React.createElement(MovieList, null)) : null,
				React.createElement("footer", null,
					React.createElement("p", null, "This product uses the TMDb API but is not endorsed or certified by TMDb."),
					React.createElement(AuthGreeting, null),
					React.createElement("p", null,
						React.createElement(AuthButton, null)
					)
				),
				React.createElement(ActorNameDataList, {})
			);
	}
}