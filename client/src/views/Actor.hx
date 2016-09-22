package views;

import api.react.React;
import api.react.ReactComponent;
import api.react.ReactMacro.jsx;
import types.TActor;

typedef ActorProps = {
	var actor:TActor;
};

class Actor extends ReactComponentOfProps<ActorProps> {
	public function new(props:ActorProps) {
		super(props);
	}

	override public function render() {
		var description:String = props.actor.title;
		return React.createElement("dt", null, description);
	}
}