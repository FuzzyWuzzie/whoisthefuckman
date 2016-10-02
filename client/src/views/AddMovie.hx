package views;

import api.react.React;
import api.react.ReactComponent;
import js.html.InputElement;
import stores.Movies;
import tmdb.MovieSearchResult;
import types.TMovie;

using StringTools;

typedef AddMovieState = {
    var searchResults:Array<MovieSearchResult>;
    var searching:Bool;
    var adding:Bool;
}

typedef AddMovieRefs = {
    var searchText:InputElement;
}

class AddMovie extends ReactComponentOf<Dynamic, AddMovieState, AddMovieRefs> {
    public function new(props:Dynamic) {
        super(props);
        state = {
            searchResults: null,
            searching: false,
            adding: false
        };
    }

    override public function render() {
        var components:Array<ReactComponent> = new Array<ReactComponent>();

        if(state.adding)
            components.push(React.createElement(Loader));
        else {
            components.push(
                React.createElement("label", { className: "search" },
                    React.createElement("a", { href: "#", onClick: performSearch },
                        React.createElement("i", {className: "fa fa-search"})
                    ),
                    React.createElement("input", {
                        type: "text",
                        placeholder: "Movie title",
                        ref: "searchText",
                        onKeyDown: function(event:js.html.KeyboardEvent) { if(event.key == "Enter") performSearch(); }
                    })
                )
            );
            components.push(renderSearchResults());
        }

        return
            React.createElement("dl", {},
                React.createElement("dt", {}, "Add Movie"),
                React.createElement("dd", {}, components)
            );
    }

    private function performSearch() {
        setState({
            searchResults: null,
            searching: true,
            adding: false
        });

        // search!
        Movies.findMovies(refs.searchText.value)
            .then(function(movies:Array<MovieSearchResult>) {
                setState({
                    searchResults: movies,
                    searching: false,
                    adding: false
                });
            })
            .catchError(function(error:Dynamic) {
                // TODO: show error to user
                Main.console.error("error searching for movie '" + refs.searchText.value + "':");
                Main.console.error(error);
            });
    }

    private function renderSearchResults():ReactComponent {
        if(state.searchResults == null)
            return null;

        var movieItems:Array<ReactComponent> = new Array<ReactComponent>();
        for(movie in state.searchResults) {
            var title:String = movie.title;
            if(movie.release_date != null && StringTools.trim(movie.release_date) != "")
                title += ' (${Date.fromString(movie.release_date.split('T')[0]).getFullYear()})';

            movieItems.push(
                React.createElement("dt", {},
                    React.createElement("a", {href:"#", onClick: function() {addMovie(movie);} },
                        React.createElement("i", {className:"fa fa-plus-circle"}),
                        title
                    )
                )
            );
            movieItems.push(React.createElement("dd", {}, movie.overview));
        }

        var results:ReactComponent =
            if(state.searching) React.createElement(Loader);
            else if(state.searchResults.length > 0)
                React.createElement("dl", {}, movieItems);
            else React.createElement("p", {}, 'No movies by the name of "${refs.searchText.value}" were found!');

        return
            React.createElement("dl", {},
                React.createElement("dt", {}, "Results:"),
                React.createElement("dd", {}, results)
            );
    }

    private function addMovie(movie:MovieSearchResult) {
        //clear our search results
        refs.searchText.value = "";
        setState({
            searchResults: null,
            searching: false,
            adding: true
        });

        // add the movie!
        Movies.add(movie)
            .then(function(movie:TMovie) {
                Main.console.log('Added movie ${movie.title}');
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