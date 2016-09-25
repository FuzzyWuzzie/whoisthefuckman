package views;

import api.react.React;
import api.react.ReactComponent;

class Loader extends ReactComponent {
    override public function render() {
        return React.createElement("div", { className: "loader" });
        //return React.createElement("p", {}, "loading...");
    }
}