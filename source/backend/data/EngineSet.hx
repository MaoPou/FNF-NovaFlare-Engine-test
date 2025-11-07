package backend.data;

import developer.display.DataCalc;

class EngineSet
{
    static public var mainColor:FlxColor = 0x96B5FF;
    static public var minorColor:FlxColor = 0xFF90DC;

    static public function FPSfix(data:Float, filp:Bool = false):Float {
        if (!filp) return data * 60 / DataCalc.updateFPS;
        else return data * DataCalc.updateFPS / 60;
        return data * 60 / DataCalc.updateFPS;
    }
}

