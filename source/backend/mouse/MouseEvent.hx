package backend.mouse;

import flixel.FlxBasic;

class MouseEvent extends FlxBasic
{
    public var justPressed:Bool = false;
    public var pressed:Bool = false;
    public var justReleased:Bool = false;

    public function new() {
        super(); //对的什么都没有
    }

    var calcPosX:Float = 0;
    var calcPosY:Float = 0;
    var lastMouseY:Float = 0;
    var lastMouseX:Float = 0;
    override function update(elapsed:Float) {

        var mouse = FlxG.mouse;

        if (mouse.justPressed) { 
            justPressed = true; 
            lastMouseY = mouse.y;
            lastMouseX = mouse.x;
            calcPosX = 0;
            calcPosY = 0;
        }
        else justPressed = false;

        if (mouse.pressed) {
            pressed = true;
            calcPosX += Math.abs(mouse.x - lastMouseX);
            calcPosY += Math.abs(mouse.y - lastMouseY);
        }
        else pressed = false;

        if (mouse.justReleased && calcPosX < 20 && calcPosY < 20) justReleased = true;
        else justReleased = false;
    
        super.update(elapsed);
    }

    public function overlaps(tar:FlxBasic):Bool {
        return FlxG.mouse.overlaps(tar);
    }
}