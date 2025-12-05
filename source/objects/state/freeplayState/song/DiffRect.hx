package objects.state.freeplayState.song;

class DiffRect extends FlxSpriteGroup {
    static public var fixHeight:Int = #if mobile 40 #else 30 #end;

    var background:Rect;
    var overlay:Rect;
    var triangles:FlxSpriteGroup;

    var diffName:FlxText;
    var charterName:FlxText;

    var follow:SongRect;

    public var member:Int;

    public var posX:Float = -50;
    public var lerpPosX:Float = 0;
    public var posY:Float = 0;
    public var lerpPosY:Float = 0;
    public var onFocus(default, set):Bool = true;

    var tween:FlxTween;

    public function new(name:String, color:FlxColor, charter:String, point:SongRect) {
        super();

        var w:Float = point.light.width;
        var h:Float = fixHeight;
        var r:Float = h / 4;

        background = new Rect(0, 0, w, h, r, r, color, 1, 1, color);
        add(background);

        overlay = new Rect(0, 0.5, w, h - 1, r, r, FlxColor.fromRGB(90, 100, 110), 1, 0, FlxColor.TRANSPARENT);
        add(overlay);

        triangles = new FlxSpriteGroup();
        add(triangles);

        for (i in 0...10) {
            var size:Float = FlxG.random.float(8, 20);
            var tri:Triangle = new Triangle(FlxG.random.float(20, w - 20), FlxG.random.float(h * 0.2, h - size), size, 0.0);
            tri.color = color;
            tri.alpha = FlxG.random.float(0.3, 0.8);
            tri.angle = FlxG.random.float(0, 60);
            tri.velocity.y = -FlxG.random.float(15, 60);
            triangles.add(tri);
        }

        diffName = new FlxText(15, 5, 0, name, 20);
        diffName.borderSize = 0;
        diffName.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, 0xA1393939);
        diffName.antialiasing = ClientPrefs.data.antialiasing;
        add(diffName);

        charterName = new FlxText(15, 30, 0, 'Charter: ' + charter, 12);
        charterName.borderSize = 0;
        charterName.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), 12, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, 0xA1393939);
        charterName.antialiasing = ClientPrefs.data.antialiasing;
        add(charterName);

        follow = point;

        y = follow.y + lerpPosY;
        x = 660 + Math.abs(y + height / 2 - FlxG.height / 2) / FlxG.height / 2 * 250 + lerpPosX;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        //if (FreeplayState.instance.ignoreCheck) return;

        if (follow.onFocus) {
            if (Math.abs(lerpPosY - posY) < 0.1) lerpPosY = posY; else lerpPosY = FlxMath.lerp(posY, lerpPosY, Math.exp(-elapsed * 15));
        } else {
            onFocus = false;
            if (tween != null) tween.cancel();
            tween = FlxTween.tween(this, {alpha: 0}, 0.1);
            if (Math.abs(lerpPosY - 0) < 0.1) lerpPosY = 0; else lerpPosY = FlxMath.lerp(0, lerpPosY, Math.exp(-elapsed * 15));
        }

        if (onFocus) {
            if (Math.abs(lerpPosX - posX) < 0.1) lerpPosX = posX; else lerpPosX = FlxMath.lerp(posX, lerpPosX, Math.exp(-elapsed * 15));
        } else {
            if (Math.abs(lerpPosX - 0) < 0.1) lerpPosX = 0; else lerpPosX = FlxMath.lerp(0, lerpPosX, Math.exp(-elapsed * 15));
        }

        y = follow.y + lerpPosY;
        x = 660 + Math.abs(y + height / 2 - FlxG.height / 2) / FlxG.height / 2 * 250 + lerpPosX;

        for (tri in triangles.members) {
            if (tri == null) continue;
            tri.y += tri.velocity.y * elapsed;
            if (tri.y + tri.height < 0) {
                var w = background.width;
                var h = background.height;
                var s = FlxG.random.float(8, 20);
                tri.x = FlxG.random.float(20, w - 20);
                tri.y = h + FlxG.random.float(0, h * 0.5);
                tri.velocity.y = -FlxG.random.float(15, 60);
                tri.angle = FlxG.random.float(0, 60);
                tri.alpha = FlxG.random.float(0.3, 0.8);
                tri.scale.set(1, 1);
            }
        }
    }

    private function set_onFocus(value:Bool):Bool {
        if (onFocus == value) return onFocus;
        onFocus = value;
        if (onFocus) {
            if (tween != null) tween.cancel();
            tween = FlxTween.tween(this, {alpha: 1}, 0.2);
        } else {
            if (tween != null) tween.cancel();
            tween = FlxTween.tween(this, {alpha: 0.5}, 0.2);
        }
        return value;
    }
}
