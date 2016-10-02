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
			movies: null,
			actors: null
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
		setState({
			movies: null,
			actors: null
		});
		Movies.queryAll();
		Actors.queryAll();
	}

	override public function componentWillUnmount() {
		Movies.changed.unlisten(update);
		Actors.changed.unlisten(update);
	}

	override public function render() {
		if(state.movies == null)
			return React.createElement(Loader, {});
		else
			return React.createElement("div", {},
				React.createElement("ul", null, renderMovieList()),
				React.createElement(AddMovie)
			);
	}

	private function renderMovieList():Array<ReactComponent> {
		var components:Array<ReactComponent> = new Array<ReactComponent>();

		var movieArray:Array<TMovie> = new Array<TMovie>();
		for(movie in state.movies.iterator())
			movieArray.push(movie);
		movieArray.sort(function(a:TMovie, b:TMovie):Int {
			var A:String = a.title.toUpperCase();
			var B:String = b.title.toUpperCase();
			if(A < B) return -1;
			else if(A > B) return 1;
			return 0;
		});
		for(movie in movieArray)
			components.push(React.createElement(Movie, { movie: movie }));

		return components;
	}
}