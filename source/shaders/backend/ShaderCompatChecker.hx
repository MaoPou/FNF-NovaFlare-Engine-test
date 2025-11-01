package shaders.backend;

import shaders.backend.CompatReport;
import haxe.ds.ArraySort;

class ShaderCompatChecker {
    public static function toES3(vertex:String, fragment:String, isES:Bool):ShaderCompatResult {
        var messages:Array<String> = [];

        function upgradeCommon(source:String):String {
            var s = source;
            s = s.replace("flixel_texture2D", "texture");
            s = s.replace("texture2DProj", "textureProj");
            s = s.replace("texture2DLod", "textureLod");
            s = s.replace("textureCubeLod", "textureLod");
            s = s.replace("texture3D", "texture");
            s = s.replace("textureCube", "texture");
            s = s.replace("texture2D", "texture");
            s = s.replace("#extension GL_OES_standard_derivatives : enable", "");
            return s;
        }

        function upgradeVertex(source:String):String {
            var s = source;
            s = s.replace("attribute", "in");
            s = s.replace("varying", "out");
            s = upgradeCommon(s);
            return s;
        }

        function upgradeFragment(source:String):String {
            var s = source;
            s = s.replace("attribute", "in");
            s = s.replace("varying", "in");
            s = upgradeCommon(s);
            s = s.replace("gl_FragData[0]", "output_FragColor");
            s = s.replace("gl_FragColor", "output_FragColor");

            // Move non-const global initializations that reference dynamic builtins into main()
            var initAssignments:Array<String> = [];
            var beforeMain:Bool = true;
            var lines = s.split("\n");
            for (i in 0...lines.length) {
                var line = StringTools.trim(lines[i]);
                if (line.indexOf("void main") != -1) {
                    beforeMain = false;
                }
                if (beforeMain && (line.indexOf("openfl_TextureCoordv") != -1 || line.indexOf("openfl_TextureSize") != -1)) {
                    var eqPos = line.indexOf("=");
                    var semiPos = line.lastIndexOf(";");
                    if (eqPos > 0 && semiPos > eqPos) {
                        var left = StringTools.trim(line.substr(0, eqPos));
                        var right = StringTools.trim(line.substr(eqPos + 1, semiPos - eqPos - 1));
                        var lastSpace = left.lastIndexOf(" ");
                        if (lastSpace > 0) {
                            var varName = StringTools.trim(left.substr(lastSpace + 1));
                            initAssignments.push(varName + " = " + right + ";");
                            lines[i] = left + ";";
                            messages.push('Moved global init of ' + varName + ' into main() for ES compatibility');
                        }
                    }
                }
            }
            if (initAssignments.length > 0) {
                var rebuilt = lines.join("\n");
                var mPos = rebuilt.indexOf("void main");
                if (mPos >= 0) {
                    var bracePos = rebuilt.indexOf("{", mPos);
                    if (bracePos >= 0) {
                        var insertPos = bracePos + 1;
                        var inject = "\n" + initAssignments.join("\n") + "\n";
                        rebuilt = rebuilt.substr(0, insertPos) + inject + rebuilt.substr(insertPos);
                        s = rebuilt;
                    }
                }
            }
            return s;
        }

        var needsFragOut:Bool = (fragment.indexOf("gl_FragColor") >= 0) || (fragment.indexOf("gl_FragData") >= 0);
        var v2 = upgradeVertex(vertex);
        var f2 = upgradeFragment(fragment);

        return {
            ok: true,
            stage: "both",
            needsFragOut: needsFragOut,
            messages: messages,
            convertedVertex: v2,
            convertedFragment: f2
        };
    }
}