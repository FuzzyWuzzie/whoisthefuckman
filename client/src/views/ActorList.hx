package views;

import api.react.React;
import api.react.ReactComponent;
import api.react.ReactMacro.jsx;
import stores.Actors;
import types.TActor;

typedef ActorListState = {
	var actors:Array<TActor>;
}

class ActorList extends ReactComponentOfState<ActorListState> {
	private function orderActors():Array<TActor> {
		var actors:Array<TActor> = new Array<TActor>();

		for(actor in Actors.actors.iterator()) {
			actors.push(actor);
		}
		actors.sort(function(a:TActor, b:TActor):Int {
			var A:String = a.name.toUpperCase();
			var B:String = b.name.toUpperCase();
			if(A < B) return -1;
			else if(A > B) return 1;
			return 0;
		});

		return actors;
	}

	public function new(props:Dynamic) {
		super(props);
		state = {
			actors: orderActors()
		};
	}

	private function update() {
		setState({
			actors: orderActors()
		});
	}

	override public function componentDidMount() {
		Actors.changed.listen(update);
		Actors.queryAll();
	}

	override public function componentWillUnmount() {
		Actors.changed.unlisten(update);
	}

	override public function render() {
		return React.createElement("dl", null, renderActorList());
	}

	private function renderActorList():Array<ReactComponent> {
		var components:Array<ReactComponent> = new Array<ReactComponent>();

		for(actor in state.actors) {
			components.push(React.createElement(Actor, { actor: actor }));
			components.push(React.createElement("dd", null, "TODO: movie list"));
		}

		return components;
	}
}