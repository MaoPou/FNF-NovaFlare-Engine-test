package objects.state.freeplayState.detail;

class StarRect extends FlxSpriteGroup{
    public var bg:Rect;
    private var star:Star;
    public var text:FlxText;

    public function new(x:Float, y:Float, width:Float, height:Float){
        super(x, y);

        bg = new Rect(0, 0, width, height, height, height, 0x9bff7a);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

        star = new Star(0, 0, height * 0.5, 0, 0x242A2E);
        star.antialiasing = ClientPrefs.data.antialiasing;
        var offsetMove = (bg.height - star.height) / 2;
        star.x += offsetMove * 1.25;
        star.y += offsetMove * 0.85;
        add(star);

        text = new FlxText(0, 0, 0, '0.99', Std.int(height * 0.25));
		text.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(height * 0.6), 0x242A2E, CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        text.borderStyle = NONE;
		text.antialiasing = ClientPrefs.data.antialiasing;
		text.x = star.x + star.width * 0.9;
		text.y = (bg.height - text.height) / 2;
		add(text);
    }
}