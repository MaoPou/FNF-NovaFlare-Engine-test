package objects.state.optionState.navi;

class NaviMember extends FlxSpriteGroup
{
    public var optionSort:Int;
    public var isModsAdd:Bool = false;

    public var background:Rect;
    public var textDis:FlxText;
    var specRect:Rect;

    public var offsetX:Float;
    public var offsetY:Float;
    public var mainWidth:Float;
    public var mainHeight:Float;

    var name:String;

    var follow:NaviGroup;

    ///////////////////////////////////////////////////////////////////////////////

    public function new(follow:NaviGroup, name:String, sort:Int, modsAdd:Bool = false) {
        super(0, 0);
        this.follow = follow;
        optionSort = sort;

        mainWidth = follow.mainWidth;
        mainHeight = follow.mainHeight * 0.75;

        this.name = name;

        background = new Rect(0, 0, mainWidth, mainHeight, mainHeight / 5, mainHeight / 5, EngineSet.mainColor, 0.0000001);
        add(background);

        specRect = new Rect(0, 0, 4, mainHeight * 0.6, 4, 4, EngineSet.mainColor);
        specRect.x += mainHeight * 0.34;
        specRect.y += mainHeight * 0.2;
		specRect.alpha = 1;
		specRect.scale.y = 1;
		specRect.antialiasing = ClientPrefs.data.antialiasing;
		add(specRect);

        textDis = new FlxText(0, 0, 0, Language.get(name, 'op'), Std.int(mainHeight * 0.15));
		textDis.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(mainHeight * 0.35), EngineSet.mainColor, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        textDis.borderStyle = NONE;
		textDis.antialiasing = ClientPrefs.data.antialiasing;
        textDis.x += mainHeight * 0.6;
        textDis.y += mainHeight * 0.5 - textDis.height * 0.5;
		add(textDis);
    }

    public var onFocus:Bool = false;
    public var cataChoose:Bool = false;
    public var allowChoose:Bool = false;
    var focusTime:Float = 0;
    override function update(elapsed:Float)
	{
		super.update(elapsed);

        var mouse = OptionsState.instance.mouseEvent;

		onFocus = mouse.overlaps(this);

        if (cataChoose) {
            if (focusTime > 0.2) {
                if (specRect.alpha < 1)  specRect.alpha += EngineSet.FPSfix(0.12);
                if (specRect.scale.y < 1) specRect.scale.y += EngineSet.FPSfix(0.12);
            } else {
                focusTime += elapsed;
            }
        } else {
            if (focusTime > 0) focusTime -= elapsed * 2;
            if (focusTime < 0) focusTime = 0;
            if (specRect.alpha > 0)  specRect.alpha -= EngineSet.FPSfix(0.12);
		    if (specRect.scale.y > 0) specRect.scale.y -= EngineSet.FPSfix(0.12);
        }

		if (onFocus) {
            if (background.alpha < 0.2) background.alpha += EngineSet.FPSfix(0.015);

            if (mouse.justPressed) {
                
            }

            if (mouse.justReleased) {
                OptionsState.instance.changeCata(follow.optionSort, optionSort);
            }
        } else {
            if (background.alpha > 0) background.alpha -= EngineSet.FPSfix(0.015);
        }
	}

    public function changeLanguage() {
        textDis.text = Language.get(name, 'op');
        textDis.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(mainHeight * 0.35), EngineSet.mainColor, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        textDis.borderStyle = NONE;
    }
}