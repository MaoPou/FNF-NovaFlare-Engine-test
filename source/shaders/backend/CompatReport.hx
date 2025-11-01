package shaders.backend;

typedef CheckItem = {
    var field:String;
    var ok:Bool;
    var message:String;
}

typedef ShaderCompatResult = {
    var ok:Bool;
    var stage:String; // "vertex" | "fragment" | "both"
    var needsFragOut:Bool;
    var messages:Array<String>;
    var convertedVertex:String;
    var convertedFragment:String;
}