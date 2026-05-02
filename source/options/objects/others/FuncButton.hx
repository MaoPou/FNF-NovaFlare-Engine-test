package options.objects.others;
//右下角的特殊功能摁键

class FuncButton extends FlxSpriteGroup
{
    var filePath:String = 'menuExtend/OptionsState/icons/';

    public var optionSort:Int;
    public var isModsAdd:Bool = false;

    public var background:RoundRect;
    public var icon:FlxSprite;
    public var textDis:FlxText;

    var mainWidth:Float;
    var mainHeight:Float;

    ///////////////////////////////////////////////////////////////////////////////

    public var event:Void->Void = null;

    public function new(X:Float, Y:Float, width:Float, height:Float, onClick:Void->Void = null) {
        super(X, Y);

        this.event = onClick;

        mainWidth = width;
        mainHeight = height;

        background = new RoundRect(0, 0, width, height, height / 5, LEFT_UP, EngineSet.mainColor);
        background.alpha = 0.35;
        background.mainX = X;
        background.mainY = Y;
        add(background);

        icon = new FlxSprite().loadGraphic(Paths.image(filePath + 'specIcon'));
        icon.setGraphicSize(Std.int(height * 0.8));
        icon.updateHitbox();
        icon.antialiasing = ClientPrefs.data.antialiasing;
        icon.color = EngineSet.mainColor;
        icon.x += height * 0.1;
        icon.y += height * 0.1;
        add(icon);

        textDis = new FlxText(0, 0, 0, 'Special Function', Std.int(height * 0.15));
		textDis.setFormat(Paths.font(Language.get('fontName', 'main') + '.ttf'), Std.int(height * 0.25), EngineSet.mainColor, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        textDis.borderStyle = NONE;
		textDis.antialiasing = ClientPrefs.data.antialiasing;
        textDis.x += height * 0.1 + icon.width + (width - height * 0.1 - icon.width) / 2 - textDis.width / 2 ;
        textDis.y += height * 0.5 - textDis.height * 0.5;
		add(textDis);
    }

    public var onFocus:Bool = false;
    public var onPress:Bool = false;
    override function update(elapsed:Float)
	{
		super.update(elapsed);

        var mouse = OptionsState.instance.mouseEvent;

		onFocus = mouse.overlaps(this);

		if (onFocus) {
            if (background.alpha < 0.1) background.alpha += EngineSet.FPSfix(0.015);
        } else {
            if (background.alpha > 0) background.alpha -= EngineSet.FPSfix(0.015);
        }
        
        if (onFocus) {
            if (mouse.justPressed) {
                
            }

            if (mouse.pressed) {

            }

            if (mouse.justReleased) {
                event();
            }
        }
	}
}