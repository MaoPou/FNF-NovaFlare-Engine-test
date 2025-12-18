package objects.state.freeplayState.detail;

class DetailRect extends FlxSpriteGroup{
    public var bg1:SkewRoundRect;
    public var bg2:SkewRoundRect;
    public var bg3:SkewRoundRect;

    public function new(x, y){
        super(x, y);
        bg1 = new SkewRoundRect(-100, 0, 670, 270, 10, 10, -10, 0, FlxColor.BLACK, 0.4);
		bg1.antialiasing = ClientPrefs.data.antialiasing;
		add(bg1);

        bg2 = new SkewRoundRect(-147, 0, bg1.width, 120, 10, 10, -10, 0, FlxColor.BLACK, 0.4);
        bg2.y += bg1.height - bg2.height;
		bg2.antialiasing = ClientPrefs.data.antialiasing;
		add(bg2);

        bg3 = new SkewRoundRect(-147, 0, bg1.width, 70, 10, 10, -10, 0, FlxColor.BLACK, 0.4);
        bg3.y += bg1.height - bg3.height;
		bg3.antialiasing = ClientPrefs.data.antialiasing;
		add(bg3);
    }
}