package views;

import api.react.React;
import api.react.ReactComponent;
import api.react.ReactMacro.jsx;
import stores.Authenticate;
import stores.Translation;

typedef AuthGreetingState = {
	var authenticated:Bool;
	var locale:String;
}

class AuthGreeting extends ReactComponentOfState<AuthGreetingState> {
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
	}

	override public function componentWillUnmount() {
		Authenticate.changed.unlisten(update);
		Translation.changed.unlisten(update);
	}

	override public function render() {
		if(Authenticate.unauthorized)
			return React.createElement("p", {className:"error"}, 'Access Denied.');
		else if(Authenticate.authenticated)
			return React.createElement("p", null,
				React.createElement("span", null, 'Howdy, ${Authenticate.getName()}!')
			);
		else
			return null;
	}

	private function login() {
		Authenticate.startLogin();
	}

	private function logout() {
		Authenticate.logout();
	}
}