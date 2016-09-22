package macros;

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
}