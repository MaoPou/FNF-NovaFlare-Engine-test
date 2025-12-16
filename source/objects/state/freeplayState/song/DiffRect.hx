package objects.state.freeplayState.song;

class DiffRect extends FlxSpriteGroup {
    static public final fixHeight:Int = #if mobile 40 #else 40 #end;

    var background:Rect;
    var overlay:Rect;
    var triangles:FlxSpriteGroup;

    var diffName:FlxText;
    var charterName:FlxText;

    var follow:SongRect;

    public var member:Int;

    public var onFocus(default, set):Bool = true;

    public function new(follow:SongRect, name:String, color:FlxColor, charter:String) {
        super();

        var w:Float = follow.light.width;
        var h:Float = fixHeight;
        var r:Float = h / 4;

        background = new Rect(0, 0, w, h, r, r, color, 1, 1, color);
        add(background);

        overlay = new Rect(0, 0.5, w, h - 1, r, r, FlxColor.fromRGB(90, 100, 110), 1, 0, FlxColor.TRANSPARENT);
        //add(overlay);

        triangles = new FlxSpriteGroup();
        add(triangles);

        for (i in 0...10) {
            var size:Float = FlxG.random.float(8, 20);
            var tri:Triangle = new Triangle(FlxG.random.float(20, w - 20), FlxG.random.float(h * 0.2, h - size), size, 0.0);
            tri.alpha = FlxG.random.float(0.3, 0.8);
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

        this.follow = follow;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

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
                //tri.angle = FlxG.random.float(0, 60);
                tri.alpha = FlxG.random.float(0.3, 0.8);
                tri.scale.set(1, 1);
            }
        }
    }

    private function set_onFocus(value:Bool):Bool {
        if (onFocus == value) return onFocus;
        onFocus = value;
        
        return value;
    }

    //////////////////////////////////////////

    
    public var startX:Float = 0;
    public var chooseX:Float = 0;

    public function calcX() {
        startX = Math.pow(Math.abs(this.y + this.background.height / 2 - FlxG.height / 2) / (FlxG.height / 2) * 10, 1.8);

        var chooseTar = onFocus ? -50 : 0;
        if (Math.abs(chooseX - chooseTar) > 0.5) chooseX = FlxMath.lerp(chooseTar, chooseX, Math.exp(-FreeplayState.instance.songsMove.saveElapsed * FreeplayState.instance.songsMove.lerpSmooth));
        else chooseX = chooseTar;
        
        x = startX + chooseX;
    }

    public var startTarY:Float = 0;
    public var startY:Float = 0;
    public function calcY() {
        startY = FlxMath.lerp(startTarY, startY, Math.exp(-FreeplayState.instance.songsMove.saveElapsed * FreeplayState.instance.songsMove.lerpSmooth));
        y = follow.light.y + startY;
    }
}
