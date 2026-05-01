package options.objects.navi;

//左边的导航摁键

class NaviGroup extends FlxSpriteGroup
{
    var filePath:String = 'menuExtend/OptionsState/icons/';

    public var optionSort:Int;
    public var isModsAdd:Bool = false;

    public var background:Rect;
    public var icon:FlxSprite;
    public var textDis:FlxText;
    var specRect:Rect;

    public var mainWidth:Float;
    public var mainHeight:Float;

    public var mainX:Float;
    public var mainY:Float;
    public var offsetY:Float;
    public var offsetWaitY:Float;

    var name:String;

    public var parent:Array<NaviMember> = [];

    ///////////////////////////////////////////////////////////////////////////////

    public function new(X:Float, Y:Float, width:Float, height:Float, naviData:NaviData, sort:Int, modsAdd:Bool = false) {
        super(X, Y);
        optionSort = sort;

        mainWidth = width;
        mainHeight = height;

        isModsAdd = modsAdd;

        this.name = naviData.name;

        background = new Rect(0, 0, width, height, height / 5, height / 5, EngineSet.mainColor, 0.0000001);
        add(background);

        specRect = new Rect(0, 0, 5, height * 0.5, 5, 5, EngineSet.mainColor);
		specRect.x += height * 0.25;
		specRect.y += height * 0.25;
		specRect.alpha = 0;
		specRect.scale.y = 0;
		specRect.antialiasing = ClientPrefs.data.antialiasing;
		add(specRect);

        icon = new FlxSprite().loadGraphic(Paths.image(filePath + name));
        icon.setGraphicSize(Std.int(height * 0.8));
        icon.updateHitbox();
        icon.antialiasing = ClientPrefs.data.antialiasing;
        icon.color = EngineSet.mainColor;
        icon.x += height * 0.15;
        icon.y += height * 0.1;
        add(icon);

        textDis = new FlxText(0, 0, 0, Language.get(name, 'op'), Std.int(height * 0.15));
		textDis.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(height * 0.25), EngineSet.mainColor, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        textDis.borderStyle = NONE;
		textDis.antialiasing = ClientPrefs.data.antialiasing;
        textDis.x += height * (0.8 + 0.15 + 0.25);
        textDis.y += height * 0.5 - textDis.height * 0.5;
		add(textDis);

        for (num in 0...naviData.group.length){
            var member:NaviMember = new NaviMember(this, naviData.group[num], num);
            add(member);
            member.y += 15 + (num + 1) * 50;
            member.x -= member.background.width;
            parent.push(member);
        }
    }

    public var onFocus:Bool = false;
    public var cataChoose:Bool = false;
    var focusTime:Float = 0;

    override function update(elapsed:Float)
	{
		super.update(elapsed);
        mainX = this.x;
        mainY = this.y;

        var mouse = OptionsState.instance.mouseEvent;

		onFocus = mouse.overlaps(this.background);

        if (cataChoose) {
            if (focusTime > 0.2) {
                if (specRect.alpha < 1)  specRect.alpha += EngineSet.FPSfix(0.12);
                if (specRect.scale.y < 1) specRect.scale.y += EngineSet.FPSfix(0.12);
            } else {
                focusTime += elapsed;
            }
        } else {
            focusTime = 0;
            if (specRect.alpha > 0)  specRect.alpha -= EngineSet.FPSfix(0.2);
		    if (specRect.scale.y > 0) specRect.scale.y -= EngineSet.FPSfix(0.2);
        }

		if (onFocus) {
            if (background.alpha < 0.2) background.alpha += EngineSet.FPSfix(0.015);

            if (mouse.justReleased) {
                moveParent();
            }
        } else {
            if (background.alpha > 0) background.alpha -= EngineSet.FPSfix(0.015);
        }
	}

    public function changeLanguage() {
        textDis.text = Language.get(name, 'op');
        textDis.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(mainHeight * 0.25), EngineSet.mainColor, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        textDis.borderStyle = NONE;
    }

    public var isOpened:Bool = false;
    var moveTweens:Array<FlxTween> = [];
    public function moveParent(changeTimer:Float = 0.45) {
        for (tween in moveTweens) {
			if (tween != null) tween.cancel();
		}

        for (mem in 0...parent.length) {
            var tween = FlxTween.tween(parent[mem], {x: isOpened ? -parent[mem].background.width : FlxG.width * 0.005}, changeTimer + mem * 0.025 * (isOpened ? -1 : 1), {ease: FlxEase.expoInOut});
            moveTweens.push(tween);
        }

        OptionsState.instance.changeNavi(this, isOpened, changeTimer);
        isOpened = !isOpened;
    }
}