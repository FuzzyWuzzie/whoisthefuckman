package views;

import api.react.React;
import api.react.ReactComponent;
import api.react.ReactMacro.jsx;
import types.TMovie;

typedef MovieProps = {
	var movie:TMovie;
};

class Movie extends ReactComponentOfProps<MovieProps> {
	public function new(props:MovieProps) {
		super(props);
	}

	override public function render() {
		var description:String = props.movie.title;
		if(props.movie.year != null)
			description += ' (${props.movie.year})';
		return React.createElement("dt", null, description);
	}
}