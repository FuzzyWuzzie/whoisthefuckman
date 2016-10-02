package tmdb;

import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;
import promhx.Promise;
import promhx.Deferred;
import tmdb.MovieSearchResult;
import tmdb.PersonSearchResult;

using StringTools;

class TMDB {
    private static var key:String = "";

    public static function init() {
        var xhr:XMLHttpRequest = new XMLHttpRequest();
        xhr.open("GET", Main.apiRoot + '//config/tmdb', true);
        xhr.setRequestHeader("Authorization", "Bearer " + stores.Authenticate.token);
        xhr.responseType = XMLHttpRequestResponseType.JSON;
        xhr.onload = function() {
            if(xhr.status >= 200 && xhr.status < 300) {
                // parse it
                key = xhr.response.key;
            }
            else {
                Main.console.error("Failed to get TMDB key", {
                    status: xhr.status,
                    response: xhr.response
                });
            }
        };
        xhr.onabort = function() Main.console.warn("aborted TMDB key request");
        xhr.onerror = function() Main.console.error('failed to get TMDB key');
        xhr.ontimeout = function() Main.console.error('get TMDB key request timed out!');
        xhr.send();
    }

    public static function searchMovies(query:String):Promise<Array<MovieSearchResult>> {
        var d:Deferred<Array<MovieSearchResult>> = new Deferred<Array<MovieSearchResult>>();

        var xhr:XMLHttpRequest = new XMLHttpRequest();
        var params:String = [
            "api_key=" + key.urlEncode(),
            "query=" + query.urlEncode(),
            "include_adult=true"
        ].join("&");
        var url:String = "https://api.themoviedb.org/3/search/movie?" + params;
        xhr.open("GET", url, true);
        xhr.responseType = XMLHttpRequestResponseType.JSON;
        xhr.onload = function() {
            if(xhr.status >= 200 && xhr.status < 300) {
                // parse it
                var responses:Array<MovieSearchResult> = cast xhr.response.results;
                d.resolve(responses);
            }
            else {
                Main.console.error("failed to search for TMDB movie", {
                    status: xhr.status,
                    response: xhr.response
                });
                d.throwError(xhr.response);
            }
        };
        xhr.onabort = function() d.throwError("aborted TMDB movie search request");
        xhr.onerror = function() d.throwError('failed to search for TMDB movie');
        xhr.ontimeout = function() d.throwError('search for TMDB movie request timed out!');
        xhr.send();

        return d.promise();
    }

    public static function searchPeople(query:String):Promise<Array<PersonSearchResult>> {
        var d:Deferred<Array<PersonSearchResult>> = new Deferred<Array<PersonSearchResult>>();

        var xhr:XMLHttpRequest = new XMLHttpRequest();
        var params:String = [
            "api_key=" + key.urlEncode(),
            "query=" + query.urlEncode(),
            "include_adult=true"
        ].join("&");
        var url:String = "https://api.themoviedb.org/3/search/person?" + params;
        xhr.open("GET", url, true);
        xhr.responseType = XMLHttpRequestResponseType.JSON;
        xhr.onload = function() {
            if(xhr.status >= 200 && xhr.status < 300) {
                // parse it
                var responses:Array<PersonSearchResult> = cast xhr.response.results;
                d.resolve(responses);
            }
            else {
                Main.console.error("failed to search for TMDB person", {
                    status: xhr.status,
                    response: xhr.response
                });
                d.throwError(xhr.response);
            }
        };
        xhr.onabort = function() d.throwError("aborted TMDB person search request");
        xhr.onerror = function() d.throwError('failed to search for TMDB person');
        xhr.ontimeout = function() d.throwError('search for TMDB person request timed out!');
        xhr.send();

        return d.promise();
    }
}