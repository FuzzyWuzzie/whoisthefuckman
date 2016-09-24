package views;

import api.react.React;
import api.react.ReactComponent;
import api.react.ReactMacro.jsx;
import haxe.ds.IntMap;
import stores.Movies;
import stores.Actors;
import types.TMovie;
import types.TActor;

typedef MovieListState = {
	var movies:IntMap<TMovie>;
	var actors:IntMap<TActor>;
}

class MovieList extends ReactComponentOfState<MovieListState> {
	public function new(props:Dynamic) {
		super(props);
		state = {
			movies: Movies.movies,
			actors: Actors.actors
		};
	}

	private function update() {
		setState({
			movies: Movies.movies,
			actors: Actors.actors
		});
	}

	override public function componentDidMount() {
		Movies.changed.listen(update);
		Actors.changed.listen(update);
		Movies.queryAll();
		Actors.queryAll();
	}

	override public function componentWillUnmount() {
		Movies.changed.unlisten(update);
		Actors.changed.unlisten(update);
	}

	override public function render() {
		return React.createElement("ul", null, renderMovieList());
	}

	private function renderMovieList():Array<ReactComponent> {
		var components:Array<ReactComponent> = new Array<ReactComponent>();

		for(movie in state.movies.iterator()) {
			components.push(React.createElement(Movie, { movie: movie }));
		}

		return components;
	}
}