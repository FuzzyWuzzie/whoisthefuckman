package tmdb;

typedef MovieSearchResult = {
    var id:Int;
    var title:String;
    @:optional var poster_path:String;
    @:optional var overview:String;
    @:optional var release_date:String;
}