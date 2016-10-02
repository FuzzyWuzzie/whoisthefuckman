package views;

import api.react.React;
import api.react.ReactComponent;
import api.react.ReactMacro.jsx;
import stores.Movies;
import stores.Actors;
import types.TActor;
import types.TMovie;
import haxe.ds.IntMap;

typedef MovieState = {
	var expanded:Bool;
	var movies:IntMap<TMovie>;
	var actors:IntMap<TActor>;
	var removingMovie:Bool;
	var removingActor:Bool;
}

typedef MovieProps = {
	var movie:TMovie;
};

class Movie extends ReactComponentOfPropsAndState<MovieProps, MovieState> {
	public function new(props:MovieProps) {
		super(props);
		state = {
			expanded: false,
			movies: Movies.movies,
			actors: Actors.actors,
			removingMovie: false,
			removingActor: false
		};
	}

	private function update() {
		setState({
			expanded: state.expanded,
			movies: Movies.movies,
			actors: Actors.actors,
			removingMovie: state.removingMovie,
			removingActor: state.removingActor
		});
	}

	override public function componentDidMount() {
		Movies.changed.listen(update);
		Actors.changed.listen(update);
	}

	override public function componentWillUnmount() {
		Movies.changed.unlisten(update);
		Actors.changed.unlisten(update);
	}

	override public function render() {
		var description:String = props.movie.title;
		if(props.movie.release_date != null)
			description += ' (${Date.fromString(props.movie.release_date.split('T')[0]).getFullYear()})';

		var components:Array<ReactComponent> = new Array<ReactComponent>();

		if(state.removingMovie) {
			components.push(React.createElement(Loader));
		}
		else if(state.expanded) {
			components.push(
				React.createElement("dl", {},
					React.createElement("dt", {}, "Overview"),
					React.createElement("dd", {}, props.movie.overview),
					React.createElement("dt", {}, "Fuck Men"),
					React.createElement("dd", {},
						renderActors(),
						React.createElement(AddActor, { movie:props.movie })
					)
				)
			);
		}

		return
			React.createElement("li", { className: state.expanded ? "expanded" : "unexpanded" },
				React.createElement("a", { href: "#", onClick: toggleExpanded }, description),
				React.createElement("a", { href: "#", onClick: function() { removeMovie(); } },
					React.createElement("i", { className: "fa fa-trash" })
				),
				React.createElement("div", {},
					components
				)
			);
	}

	private function toggleExpanded() {
		setState({
			expanded: !state.expanded,
			movies: Movies.movies,
			actors: Actors.actors,
			removingMovie: state.removingMovie,
			removingActor: state.removingActor
		});
	}

	private function renderActors():ReactComponent {
		if(state.removingActor)
			return React.createElement(Loader);

		var a:Array<ReactComponent> = new Array<ReactComponent>();

		for(actorID in props.movie.actorIDs) {
			if(!Actors.actors.exists(actorID)) continue;
			var actor:TActor = Actors.actors.get(actorID);
			a.push(
				React.createElement("li", {}, actor.name,
					React.createElement("a", { href: "#", onClick: function() { removeActor(actor); } },
						React.createElement("i", { className: "fa fa-trash" })
					)
				)
			);
		}

		return React.createElement("ul", {}, a);
	}

	private function removeMovie() {
		setState({
			expanded: state.expanded,
			movies: Movies.movies,
			actors: Actors.actors,
			removingMovie: true,
			removingActor: state.removingActor
		});

		Movies.delete(props.movie)
			.then(function(movie:TMovie) {
				Main.console.log('Removed movie ${props.movie.title}');
				setState({
					expanded: state.expanded,
					movies: Movies.movies,
					actors: Actors.actors,
					removingMovie: false,
					removingActor: state.removingActor
				});
			})
			.catchError(function(error:Dynamic) {
				Main.console.error(error);
				setState({
					expanded: state.expanded,
					movies: Movies.movies,
					actors: Actors.actors,
					removingMovie: false,
					removingActor: state.removingActor
				});
			});
	}

	private function removeActor(actor:TActor) {
		setState({
			expanded: state.expanded,
			movies: Movies.movies,
			actors: Actors.actors,
			removingMovie: state.removingMovie,
			removingActor: true
		});

		Movies.deleteActor(props.movie, actor)
			.then(function(movie:TMovie) {
				Main.console.log('Removed actor ${actor.name} from movie ${props.movie.title}');
				setState({
					expanded: state.expanded,
					movies: Movies.movies,
					actors: Actors.actors,
					removingMovie: state.removingMovie,
					removingActor: false
				});
			})
			.catchError(function(error:Dynamic) {
				Main.console.error(error);
				setState({
					expanded: state.expanded,
					movies: Movies.movies,
					actors: Actors.actors,
					removingMovie: state.removingMovie,
					removingActor: false
				});
			});
	}
}