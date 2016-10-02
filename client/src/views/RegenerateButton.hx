package views;

import api.react.React;
import api.react.ReactComponent;
import api.react.ReactMacro.jsx;
import stores.Authenticate;
import stores.Generator;
import stores.Translation;

typedef RegenerateButtonState = {
    var loading:Bool;
    var message:String;
}

class RegenerateButton extends ReactComponentOfState<RegenerateButtonState> {
    public function new(props:Dynamic) {
        super(props);
        state = {
            loading: false,
            message: null
        };
    }

    override public function render() {
        var button:ReactComponent = state.loading
            ? React.createElement(Loader)
            : React.createElement("button", {onClick:regenerate}, "Regenerate");
        var message:ReactComponent = state.message != null
            ? React.createElement("p", {}, state.message + ": ",
                React.createElement("a", {href: "http://localhost:8000"}, "Results")
            )
            : null;

        return React.createElement("div", {className: "regen"}, button, message);
    }

    private function regenerate() {
        setState({
            loading: true,
            message: null
        });

        Generator.regenerate()
            .then(function(message:String) {
                setState({
                    loading: false,
                    message: message
                });
            })
            .catchError(function(error:Dynamic) {
                Main.console.error(error);
                setState({
                    loading: false,
                    message: "Error! Check the console!"
                });
            });
    }
}