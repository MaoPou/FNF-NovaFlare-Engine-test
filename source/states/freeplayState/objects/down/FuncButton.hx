package states.freeplayState.objects.down;

class FuncButton extends FlxSpriteGroup {

    static public var filePath:String = 'function/';

    public var id:Int;

    var rect:SkewRoundRect;
    var light:SkewSegmentGradientRoundRect;
    var downRect:Rect;

    var text:FlxText;
    var icon:FlxSprite;
    
    public var event:() -> Void = null;

    var normalColor:FlxColor = 0x312f3b;
    var hoverColor:FlxColor;
    
    public function new(x:Float, y:Float, name:String, color:FlxColor = 0xffffff) {
        super(x, y);

        rect = new SkewRoundRect(0, 0, 140, 80, 20, 20, -10, 0, normalColor);
        rect.antialiasing = ClientPrefs.data.antialiasing;
        add(rect);

        hoverColor = CoolUtil.brightenColor(normalColor, 1.5);
        
        light = new SkewSegmentGradientRoundRect(0, 0, 140, 80, 20, 20, -10, 0, FlxColor.WHITE,  [[0.5, 1, 0.5], [0.5, 0.2, 0]]);
        light.color = color;
        light.alpha = 0.8;
        light.blend = ADD;
        light.antialiasing = ClientPrefs.data.antialiasing;
        add(light);

        downRect = new Rect(0, 62, 95, 10, 10, 10, color);
        downRect.x += rect.width / 2 - downRect.width / 2 - 5;
        add(downRect);

        icon = new FlxSprite().loadGraphic(Paths.image(FreeplayState.filePath + filePath + name));
        icon.antialiasing = ClientPrefs.data.antialiasing;
        icon.color = color;
        icon.setGraphicSize(25);
        icon.updateHitbox();
        icon.x += rect.width / 2 - icon.width / 2;
        icon.y += rect.height / 4 - icon.height / 2 - 2;
        add(icon);

        text = new FlxText(0, 0, 0, name, Std.int(rect.height * 0.25));
		text.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(rect.height * 0.25), 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        text.borderStyle = NONE;
		text.antialiasing = ClientPrefs.data.antialiasing;
		text.x = rect.width / 2 - text.width / 2;
		text.y = rect.height / 3 * 2 - text.height / 2 - 7;
		add(text);
    }

    override function update(elapsed:Float)
	{
        var mouse = FreeplayState.instance.mouseEvent;

        var overlaps = mouse.overlapsPixel(this.rect, rect.camera);
        if (overlaps || id == FreeplayState.instance.curFunc)
        {
            rect.color = hoverColor;
        }
        else
        {
            rect.color = normalColor;
        }

        if (overlaps) {
            if (mouse.justReleased) {
                if (event != null) event();
            }
        }

        super.update(elapsed);
    }
}