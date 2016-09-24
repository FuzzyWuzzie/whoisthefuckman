package views;

import api.react.React;
import api.react.ReactComponent;
import api.react.ReactMacro.jsx;
import types.TMovie;

typedef MovieState = {
	var expanded:Bool;
}

typedef MovieProps = {
	var movie:TMovie;
};

class Movie extends ReactComponentOfPropsAndState<MovieProps, MovieState> {
	public function new(props:MovieProps) {
		super(props);
		state = {
			expanded: false
		};
	}

	override public function render() {
		var description:String = props.movie.title;
		if(props.movie.release_date != null)
			description += ' (${Date.fromString(props.movie.release_date.split('T')[0]).getFullYear()})';

		var components:Array<ReactComponent> = new Array<ReactComponent>();

		if(state.expanded) {
			components.push(
				React.createElement("dl", {},
					React.createElement("dt", {}, "Overview"),
					React.createElement("dd", {}, props.movie.overview)
				)
			);
		}

		return
			React.createElement("li", { className: state.expanded ? "expanded" : "unexpanded" },
				React.createElement("a", { href: "#", onClick: toggleExpanded }, description),
				React.createElement("div", {},
					components
				)
			);
	}

	private function toggleExpanded() {
		setState({
			expanded: !state.expanded
		});
	}
}