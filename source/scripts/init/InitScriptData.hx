package scripts.init;

import crowplexus.iris.Iris;

import scripts.lua.*;

//hxcodec
import vlc.MP4Handler; //2.5.0-2.5.1
import VideoHandler; //2.6.0-2.6.1
import hxcodec.flixel.FlxVideo; //3.0.0-3.0.1

class InitScriptData {
    public static function init() {
        
        //psychlua
        Iris.proxyImports.set("psychlua.CallbackHandler", CallbackHandler);
        Iris.proxyImports.set("psychlua.CustomSubstate", CustomSubstate);
        Iris.proxyImports.set("psychlua.DebugLuaText", DebugLuaText);
        Iris.proxyImports.set("psychlua.DeprecatedFunctions", DeprecatedFunctions);
        Iris.proxyImports.set("psychlua.ExtraFunctions", ExtraFunctions);
        Iris.proxyImports.set("psychlua.FlxAnimateFunctions", FlxAnimateFunctions);
        Iris.proxyImports.set("psychlua.FunkinLua", FunkinLua);
        Iris.proxyImports.set("psychlua.LuaUtils", LuaUtils);
        Iris.proxyImports.set("psychlua.ModchartAnimateSprite", ModchartAnimateSprite);
        Iris.proxyImports.set("psychlua.ModchartSprite", ModchartSprite);
        Iris.proxyImports.set("psychlua.ReflectionFunctions", ReflectionFunctions);
        Iris.proxyImports.set("psychlua.ShaderFunctions", ShaderFunctions);

        //hxcodec
        Iris.proxyImports.set("vlc.MP4Handler", MP4Handler);
        Iris.proxyImports.set("VideoHandler", VideoHandler);
        Iris.proxyImports.set("hxcodec.VideoHandler", VideoHandler);
        Iris.proxyImports.set("hxcodec.flixel.FlxVideo", FlxVideo);
    }
}