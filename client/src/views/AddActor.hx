package views;

import api.react.React;
import api.react.ReactComponent;
import js.html.InputElement;
import stores.Actors;
import stores.Movies;
import types.TActor;
import types.TMovie;

using StringTools;

typedef AddActorState = {
    var searchResults:Array<TActor>;
    var searching:Bool;
    var adding:Bool;
}

typedef AddActorProps = {
    var movie:TMovie;
};

typedef AddActorRefs = {
    var searchText:InputElement;
}

class AddActor extends ReactComponentOf<AddActorProps, AddActorState, AddActorRefs> {
    public function new(props:AddActorProps) {
        super(props);
        state = {
            searchResults: null,
            searching: false,
            adding: false
        };
    }

    override public function render() {
        if(state.adding)
            return
                React.createElement("div", {},
                    React.createElement(Loader)
                );
        else
            return
                React.createElement("div", {},
                    React.createElement("label", { className: "search" },
                        React.createElement("i", {className: "fa fa-search"}),
                        React.createElement("input", {
                            type: "text",
                            placeholder: "Actor name",
                            list: "actorNameDataList",
                            ref: "searchText",
                            onKeyDown: function(event:js.html.KeyboardEvent) { if(event.key == "Enter") performSearch(); }
                        })
                    ),
                    renderSearchResults()
                );
    }

    private function performSearch() {
        if(refs.searchText.value.trim() == "")
            return;

        setState({
            searchResults: null,
            searching: true,
            adding: false
        });

        // search!
        Actors.findActors(refs.searchText.value)
            .then(function(actors:Array<TActor>) {
                setState({
                    searchResults: actors,
                    searching: false,
                    adding: false
                });
            })
            .catchError(function(error:Dynamic) {
                // TODO: show error to user
                Main.console.error("error searching for actor '" + refs.searchText.value + "':");
                Main.console.error(error);
            });
    }

    private function renderSearchResults():ReactComponent {
        if(state.searchResults == null)
            return null;

        var actorItems:Array<ReactComponent> = new Array<ReactComponent>();
        for(actor in state.searchResults) {
            actorItems.push(
                React.createElement("dt", {},
                    React.createElement("a", {href:"#", onClick: function() {addActor(actor);} },
                        React.createElement("i", {className:"fa fa-plus-circle"}),
                        actor.name
                    )
                )
            );
            actorItems.push(React.createElement("dd", {}, actor.biography));
        }

        var results:ReactComponent =
            if(state.searching) React.createElement(Loader);
            else if(state.searchResults.length > 0)
                React.createElement("dl", {}, actorItems);
            else React.createElement("p", {}, 'No actors by the name of "${refs.searchText.value}" were found!');

        return
            React.createElement("dl", {},
                React.createElement("dt", {}, "Results:"),
                React.createElement("dd", {}, results)
            );
    }

    private function addActor(actor:TActor) {
        //clear our search results
        refs.searchText.value = "";
        setState({
            searchResults: null,
            searching: false,
            adding: true
        });

        // add the actor!
        Movies.addActor(props.movie, actor)
            .then(function(movie:TMovie) {
                Main.console.log('Added actor ${actor.name} to movie ${movie.title}');
                setState({
                    searchResults: null,
                    searching: false,
                    adding: false
                });
            })
            .catchError(function(error:Dynamic) {
                Main.console.error(error);
                setState({
                    searchResults: null,
                    searching: false,
                    adding: false
                });
            });
    }
}