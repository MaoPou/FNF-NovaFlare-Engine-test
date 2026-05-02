package options.objects.others;

class ResetButton extends FlxSpriteGroup
{
	var rect:Rect;
	var text:FlxText;

	public function new(x:Float, y:Float, width:Float, height:Float)
	{
		super(x, y);

		rect = new Rect(0, 0, width, height, height / 5, height / 5, OptionsState.instance.mainColor, 1);
		add(rect);

		text = new FlxText(0, 0, 0, Language.get('Reset'), 25);
		text.font = Paths.font(Language.get('fontName', 'main') + '.ttf');
		text.antialiasing = ClientPrefs.data.antialiasing;
		text.y += rect.height / 2 - text.height / 2;
		text.x += rect.width / 2 - text.width / 2;
		add(text);

	}

	public var onFocus:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var mouse = OptionsState.instance.mouseEvent;

		onFocus = mouse.overlaps(this);

		if (onFocus)
		{
			rect.color = EngineSet.mainColor;
			if (mouse.justReleased)
				OptionsState.instance.resetData();
		}
		else
		{
			rect.color = OptionsState.instance.mainColor;
		}
	}

	public function changeLanguage() {
		text.text = Language.get('Reset', 'options');
		text.font = Paths.font(Language.get('fontName', 'main') + '.ttf');
	}
}