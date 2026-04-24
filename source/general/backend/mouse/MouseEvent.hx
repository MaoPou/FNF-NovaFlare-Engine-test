package general.backend.mouse;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import general.backend.CoolUtil;
import openfl.display.BitmapData;

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

    public function overlaps(tar:FlxBasic):Bool {
        return FlxG.mouse.overlaps(tar);
    }

    public function overlapsPixel(tar:FlxBasic, camera:FlxCamera = null):Bool {
        if (tar == null) return false;

        camera = camera ?? targetCamera;
        if (tmpWorldPos == null) tmpWorldPos = new FlxPoint();
        FlxG.mouse.getScreenPosition(camera, tmpWorldPos);

        if (Std.isOfType(tar, FlxSprite)) {
            return spritePixelOverlap(cast tar, tmpWorldPos, camera);
        }

        return CoolUtil.mouseOverlaps(tar, camera);
    }

    inline function spritePixelOverlap(sprite:FlxSprite, screenPoint:FlxPoint, camera:FlxCamera):Bool {
        if (!sprite.exists || !sprite.visible) return false;
        if (!sprite.overlapsPoint(screenPoint, true, camera)) return false;

        var framePixels:BitmapData = null;
        if (Reflect.hasField(sprite, "framePixels")) {
            framePixels = cast Reflect.field(sprite, "framePixels");
        }
        if (framePixels == null) framePixels = sprite.pixels;
        if (framePixels == null) return true;

        var spriteScreenPos = sprite.getScreenPosition(FlxPoint.weak(), camera);
        var scaleX = sprite.scale.x;
        var scaleY = sprite.scale.y;
        if (scaleX == 0 || scaleY == 0) return false;

        var localX = (screenPoint.x - spriteScreenPos.x) / scaleX;
        var localY = (screenPoint.y - spriteScreenPos.y) / scaleY;
        var px = Std.int(localX);
        var py = Std.int(localY);

        if (px < 0 || py < 0 || px >= framePixels.width || py >= framePixels.height) return false;

        var argb = framePixels.getPixel32(px, py);
        return ((argb >>> 24) & 0xFF) > 0;
    }
}
