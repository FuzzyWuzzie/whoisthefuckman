package stores;

import promhx.Deferred;
import promhx.Promise;
import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;

class Generator {
    public static function regenerate():Promise<String> {
        var d:Deferred<String> = new Deferred<String>();

        var xhr:XMLHttpRequest = new XMLHttpRequest();
        xhr.open("POST", Main.apiRoot + '/generate', true);
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.setRequestHeader("Authorization", "Bearer " + Authenticate.token);
        xhr.responseType = XMLHttpRequestResponseType.JSON;
        xhr.onload = function() {
            if(xhr.status >= 200 && xhr.status < 300) {
                d.resolve('Regenerated in ' + xhr.response.time);
            }
            else {
                d.throwError(xhr.response);
            }
        };
        xhr.onabort = function() { d.throwError('aborted regenerate request'); }
        xhr.onerror = function() { d.throwError('failed to get regenerate'); }
        xhr.ontimeout = function() { d.throwError('get regenerate request timed out!'); }
        xhr.send();

        return d.promise();
    }
}