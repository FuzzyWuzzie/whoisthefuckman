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
	public function new(props:Dynamic) {
		super(props);
		state = {
			actors: Actors.actors
		};
	}

	private function update() {
		setState({
			actors: Actors.actors
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