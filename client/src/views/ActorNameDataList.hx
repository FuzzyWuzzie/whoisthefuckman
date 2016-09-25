package views;

import api.react.React;
import api.react.ReactComponent;
import api.react.ReactMacro.jsx;
import haxe.ds.IntMap;
import stores.Actors;
import stores.Authenticate;
import stores.Translation;
import types.TActor;

typedef ActorNameDataListState = {
    var actors:IntMap<TActor>;
}

class ActorNameDataList extends ReactComponentOfState<ActorNameDataListState> {
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
    }

    override public function componentWillUnmount() {
        Actors.changed.unlisten(update);
    }

    override public function render() {
        return React.createElement("datalist", {id:"actorNameDataList"}, listActors());
    }

    private function listActors():Array<ReactComponent> {
        var cs:Array<ReactComponent> = new Array<ReactComponent>();

        for(actor in state.actors) {
            cs.push(React.createElement("option", {value:actor.name}));
        }

        return cs;
    }
}