package developer.display;

/*
	author: beihu235
	bilibili: https://b23.tv/SnqG443
	github: https://github.com/beihu235
	youtube: https://youtube.com/@beihu235?si=NHnWxcUWPS46EqUt
	discord: @beihu235

	thanks Chiny help me adjust data
	github: https://github.com/dmmchh
 */
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import openfl.events.Event;

class FPSViewer extends Sprite
{
	public function new(x:Float = 10, y:Float = 10)
	{
		super();

		this.x = x;
		this.y = y;

		create();

		scaleX = scaleY = ClientPrefs.data.FPSScale;
		visible = ClientPrefs.data.showFPS;
	}

	public static var fpsShow:FPSCounter;
	public static var extraShow:ExtraCounter;

	public var isHiding = true;

	function create()
	{
		fpsShow = new FPSCounter(10, 10);
		addChild(fpsShow);
		fpsShow.update();

		extraShow = new ExtraCounter(10, 10);
		addChild(extraShow);
		extraShow.update();

		extraShow.alpha = 0;

		addEventListener(Event.ENTER_UPDATE, update);
		addEventListener(Event.ENTER_FRAME, draw);
	}
	
	private function update(e:Event):Void
	{
		DataCalc.update();
		
		if (isPointInFPSCounter() && FlxG.mouse.justPressed)
		{
			isHiding = !isHiding;
			hide();
		}

		if (DataCalc.updateMember != 0)
			return;

		fpsShow.update();
		extraShow.update();

		#if TRACY_ALLOWED
			cpp.vm.tracy.TracyProfiler.frameMark();
		#end

		this.x = 10 - FlxG.game.x;
		this.y = 10 - FlxG.game.y;
	}

	private function draw(e:Event)
	{
		DataCalc.draw();
	}

	function hide():Void
	{
		if (isHiding)
		{
			extraShow.alpha = 0;
			fpsShow.alpha = 1;
		}
		else
		{
			extraShow.alpha = 1;
			fpsShow.alpha = 0;
		}
	}

	private function isPointInFPSCounter():Bool
	{
		var target = isHiding ? fpsShow.bgSprite : extraShow.bgSprite;

		var global = target.localToGlobal(new openfl.geom.Point(0, 0));
		var fpsX = global.x;
		var fpsY = global.y;
		var fpsWidth = target.width;
		var fpsHeight = target.height;

		var mx = Lib.current.stage.mouseX;
		var my = Lib.current.stage.mouseY;

		return mx >= fpsX && mx <= fpsX + fpsWidth && my >= fpsY && my <= fpsY + fpsHeight;
	}
}
