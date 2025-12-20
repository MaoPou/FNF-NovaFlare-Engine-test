package objects.state.freeplayState.detail;

class DataDis extends FlxSpriteGroup{
    var lineBG:Rect;
    public var lineDis:Rect;
    var text:FlxText;
    public var data:FlxText;

    public function new(x:Float, y:Float, width:Float, height:Float, dataName:String){
        super(x, y);

        lineBG = new Rect(0, 0, width, height, height, height, 0xffffff);
		lineBG.antialiasing = ClientPrefs.data.antialiasing;
		add(lineBG);

        lineDis = new Rect(0, 0, width, height, height, height, 0xffffff);
		lineDis.antialiasing = ClientPrefs.data.antialiasing;
		add(lineDis);

        text = new FlxText(0, 0, 0, dataName, 20);
		text.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), 14, 0xffffff, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        text.borderStyle = NONE;
		text.antialiasing = ClientPrefs.data.antialiasing;
        text.y += height * 1.5;
		add(text);

        data = new FlxText(0, 0, 0, dataName, 20);
		data.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), 14, 0xffffff, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        data.borderStyle = NONE;
		data.antialiasing = ClientPrefs.data.antialiasing;
        data.y += lineDis.height + text.textField.height;
		add(data);
    }

    public function chanegData(data:Float) {

    }

}