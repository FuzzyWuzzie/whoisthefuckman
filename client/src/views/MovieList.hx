package views;

import api.react.React;
import api.react.ReactComponent;
import api.react.ReactMacro.jsx;
import stores.Movies;
import types.TMovie;

typedef MovieListState = {
	var movies:Array<TMovie>;
}

class MovieList extends ReactComponentOfState<MovieListState> {
	public function new(props:Dynamic) {
		super(props);
		state = {
			movies: Movies.movies
		};
	}

	private function update() {
		setState({
			movies: Movies.movies
		});
	}

	override public function componentDidMount() {
		Movies.changed.listen(update);
		Movies.queryAll();
	}

	override public function componentWillUnmount() {
		Movies.changed.unlisten(update);
	}

	override public function render() {
		return React.createElement("dl", null, renderMovieList());
	}

	private function renderMovieList():Array<ReactComponent> {
		var components:Array<ReactComponent> = new Array<ReactComponent>();

		for(movie in state.movies) {
			components.push(React.createElement(Movie, { movie: movie }));
			components.push(React.createElement("dd", null, "TODO: actor list"));
		}

		return components;
	}
}