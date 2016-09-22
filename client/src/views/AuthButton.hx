package views;

import api.react.React;
import api.react.ReactComponent;
import api.react.ReactMacro.jsx;
import stores.Authenticate;
import stores.Translation;

typedef AuthButtonState = {
	var authenticated:Bool;
	var locale:String;
}

class AuthButton extends ReactComponentOfState<AuthButtonState> {
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
		if(Authenticate.authenticated)
			return React.createElement("a", { href: "#", onClick: logout }, "Log Out");
		else
			return React.createElement("a", { href: "#", onClick: login }, "Log In");
	}

	private function login() {
		Authenticate.startLogin();
	}

	private function logout() {
		Authenticate.logout();
	}
}