package general.backend.mouse;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.math.FlxPoint;

class MouseEvent extends FlxBasic
{
    public var justPressed:Bool = false;
    public var pressed:Bool = false;
    public var justReleased:Bool = false;

    public var targetCamera:FlxCamera = null;

    public function new() {
        super(); //对的什么都没有
    }

    var worldPos:FlxPoint = null;
    var tmpWorldPos:FlxPoint = null;
    var calcPosX:Float = 0;
    var calcPosY:Float = 0;
    var lastMouseY:Float = 0;
    var lastMouseX:Float = 0;
    override function update(elapsed:Float) {

        var mouse = FlxG.mouse;

        if (worldPos == null) worldPos = new FlxPoint();
        if (targetCamera != null) mouse.getWorldPosition(targetCamera, worldPos);
        else worldPos.set(mouse.x, mouse.y);

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

        if (mouse.justReleased && calcPosX < FlxG.width * 0.1 && calcPosY < FlxG.height * 0.1) justReleased = true;
        else justReleased = false;
    
        super.update(elapsed);
    }

    public function overlaps(tar:FlxBasic, ?camera:FlxCamera):Bool {
        var cam = camera != null ? camera : targetCamera;
        var obj:FlxObject = cast tar;
        if (obj != null) {
            var mx:Float;
            var my:Float;
            if (cam == null || cam == targetCamera) {
                mx = worldPos.x;
                my = worldPos.y;
            } else {
                if (tmpWorldPos == null) tmpWorldPos = new FlxPoint();
                FlxG.mouse.getWorldPosition(cam, tmpWorldPos);
                mx = tmpWorldPos.x;
                my = tmpWorldPos.y;
            }
            return mx >= obj.x && mx <= obj.x + obj.width && my >= obj.y && my <= obj.y + obj.height;
        }
        return FlxG.mouse.overlaps(tar, cam);
    }
}
