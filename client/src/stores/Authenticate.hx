package stores;

class Authenticate {
	private function new(){}
	public static var changed:Event = new Event();

	public static var authenticated(get, null):Bool;
	private static function get_authenticated():Bool {
		return false;
	}
}