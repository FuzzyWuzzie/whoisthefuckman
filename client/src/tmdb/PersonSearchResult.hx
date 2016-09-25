package tmdb;

typedef PersonSearchResult = {
    @:optional var profile_path:String;
    @:optional var adult:Bool;
    var id:Int;
    @:optional var known_for:Array<Dynamic>;
    var name:String;
    @:optional var popularity:Float;
}