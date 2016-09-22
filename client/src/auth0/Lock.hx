package auth0;

@:native('Auth0Lock')
extern class Lock {
	public function new(clientID:String, domain:String, ?options:Dynamic);
	public function getProfile(idToken:String, callback:Dynamic->Dynamic->Void):Void;
	public function show(?options:Dynamic):Void;
	public function hide():Void;
	public function on(event:String, callback:Dynamic->Void):Void;
}