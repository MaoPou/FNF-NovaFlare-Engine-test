package general.objects.state;

import flash.geom.Point;
import flash.geom.Matrix;

import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;
import openfl.geom.Rectangle;
import openfl.display.Shape;

import flixel.util.FlxSpriteUtil;

import general.objects.CheckboxThingie;

import substates.ResultsScreen;

class PressButton extends FlxSpriteGroup
{
	public var background:FlxSprite;

	var bgAlpha:Float = 0;

	public var text:FlxText;

	public var onClick:Void->Void = null;

	var saveColor:FlxColor = 0xffffff;
	var saveColor2:FlxColor = 0x000000;

	public function new(X:Float, Y:Float, width:Float = 0, height:Float = 0, texts:String = '', bgAlpha:Float = 0.5, onClick:Void->Void = null)
	{
		super(X, Y);

		background = new FlxSprite().makeGraphic(Std.int(width), Std.int(height));
		background.alpha = bgAlpha;
		background.color = saveColor2;
		add(background);

		text = new FlxText(0, 0, 0, texts, 25);
		text.font = Paths.font(Language.get('fontName', 'ma') + '.ttf');
		text.antialiasing = ClientPrefs.data.antialiasing;
		add(text);

		text.x += background.width / 2 - text.width / 2;
		text.y += background.height / 2 - text.height / 2;

		this.onClick = onClick;
		this.bgAlpha = bgAlpha;
	}

	public var onFocus:Bool = false;

	var focused:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		onFocus = (FlxG.mouse.getScreenPosition(ResultsScreen.camOther).x > this.x)
			&& (FlxG.mouse.getScreenPosition(ResultsScreen.camOther).x < (this.x + this.background.width))
			&& (FlxG.mouse.getScreenPosition(ResultsScreen.camOther).y > this.y)
			&& (FlxG.mouse.getScreenPosition(ResultsScreen.camOther).y < (this.y + this.background.height));

		if (onFocus && onClick != null && FlxG.mouse.justReleased)
			onClick();

		if (onFocus)
		{
			if (!focused)
			{
				focused = true;
				background.color = saveColor;
				text.color = saveColor2;
			}
		}
		else
		{
			if (focused)
			{
				focused = false;
				background.color = saveColor2;
				text.color = saveColor;
			}
		}

		if (background.alpha > bgAlpha)
			background.alpha = bgAlpha;
	}
}
