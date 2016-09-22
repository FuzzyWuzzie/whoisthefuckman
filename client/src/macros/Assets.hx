package macros;

import haxe.Http;
import haxe.macro.Context;
import haxe.macro.Expr;
import Sys;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;

using StringTools;

class Assets {
    private static function copy(sourceDir:String, targetDir:String):Int {
        var numCopied:Int = 0;

        if(!FileSystem.exists(targetDir))
            FileSystem.createDirectory(targetDir);

        for(entry in FileSystem.readDirectory(sourceDir)) {
            var srcFile:String = Path.join([sourceDir, entry]);
            var dstFile:String = Path.join([targetDir, entry]);

            if(FileSystem.isDirectory(srcFile))
                numCopied += copy(srcFile, dstFile);
            else {
                File.copy(srcFile, dstFile);
                numCopied++;
            }
        }
        return numCopied;
    }

    public static function copyProjectAssets() {
        var cwd:String = Sys.getCwd();
        var assetSrcFolder = Path.join([cwd, "assets"]);
        var assetsDstFolder = Path.join([cwd, "public"]);

        // make sure the destination folder exists
        if(!FileSystem.exists(assetsDstFolder))
            FileSystem.createDirectory(assetsDstFolder);

        // copy it!
        var numCopied = copy(assetSrcFolder, assetsDstFolder);
        Sys.println('copied ${numCopied} project assets to bin!');
    }

    public static function minify(path:String) {
        Sys.println('minifying ${path} using closure-compiler...');
        var src:String = File.getContent(path);

        // prepare the HTML request
        var h:Http = new Http("http://closure-compiler.appspot.com/compile");
        h.addHeader("Content-type", "application/x-www-form-urlencoded");
        h.addParameter("js_code", src);
        h.addParameter("compilation_level", "SIMPLE_OPTIMIZATIONS");
        h.addParameter("output_info", "compiled_code");
        h.addParameter("output_format", "text");

        // receive functions
        h.onData = function(data:String) {
            var destination = Path.withoutExtension(path) + ".min.js";
            File.saveContent(destination, data);
            Sys.println('minified source saved to ${destination}!');
            Sys.println('compressed ${Math.fround(src.length/1024.0)}KB to ${Math.fround(data.length/1024.0)}KB, ${Math.fround(100.0*data.length/src.length)}% compression!');
        }
        h.onError = function(error:String) {
            Sys.println('error: ${error}');
        }
        h.onStatus = function(status:Int) {}

        h.request(true);
    }
}