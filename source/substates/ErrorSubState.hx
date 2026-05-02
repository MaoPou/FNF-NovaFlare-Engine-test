package substates;

import flixel.FlxSubState;

import states.freeplayState.FreeplayState;
import states.MainMenuState;

class ErrorSubState extends MusicBeatSubstate
{
	var errorText:FlxText;
	var tips:FlxText;
	var error:String = "Oh Shit!";
	var bg:FlxSprite;
	var subcameras:FlxCamera;

	var saveMouseY:Int = 0;
	var moveData:Int = 0;
	var avgSpeed:Float = 0;

	var pressas:Int = 0;

	public function new(stack:String)
	{
		super();
		error = stack + "\n\nError message saved";
		FlxG.mouse.visible = true;
	}

	override function create()
	{
		super.create();
		FlxG.state.persistentUpdate = false; // 停止更新state

		subcameras = new FlxCamera();

		bg = new FlxSprite().loadGraphic(Paths.image('egg'));
		bg.width = FlxG.width;
		bg.height = FlxG.height;
		bg.alpha = 0;
		add(bg);

		errorText = new FlxText(0, 0, FlxG.width, error, 50);
		errorText.font = Paths.font('Lang-ZH.ttf');
		add(errorText);

		tips = new FlxText(0, 0, FlxG.width, 'Wait 10 second or press back / ENTER\nstate will close', 25);
		tips.font = Paths.font('Lang-ZH.ttf');
		tips.x = FlxG.width - tips.width;
		tips.alignment = FlxTextAlign.RIGHT;
		add(tips);

		bg.cameras = [subcameras];
		errorText.cameras = [subcameras];
		tips.cameras = [subcameras];

		FlxG.cameras.add(subcameras, false);
		subcameras.bgColor.alpha = 0;

		new FlxTimer().start(10, function(tmr:FlxTimer)
		{
			close();
		});
	}

	override function update(elapsed:Float)
	{
		bg.alpha += elapsed * 1.5;
		if (bg.alpha > 0.6)
			bg.alpha = 0.6;
		if (FlxG.keys.justPressed.ENTER #if android || FlxG.android.justReleased.BACK #end)
		{
			pressas++;
		}

		if (pressas >= 1)
		{
			FlxG.state.persistentUpdate = true; // 恢复更新
			if (Type.getClass(FlxG.state) == PlayState)
				MusicBeatState.switchState(new FreeplayState());
			else
				MusicBeatState.switchState(new MainMenuState());

			close();
		}

		if (FlxG.mouse.pressed)
		{
			if (errorText.height > FlxG.height)
			{
				if (FlxG.mouse.justPressed)
					saveMouseY = FlxG.mouse.y;
				moveData = FlxG.mouse.y - saveMouseY;
				saveMouseY = FlxG.mouse.y;

				errorText.y += moveData;
			}
			if (errorText.y < (FlxG.height - errorText.height))
				errorText.y = FlxG.height - errorText.height;
			if (errorText.y > 0)
				errorText.y = 0;
			// 限制错误信息可以滑动的范围
		}
		super.update(elapsed);
	}

	override function destroy()
	{
		bg = FlxDestroyUtil.destroy(bg);
		errorText = FlxDestroyUtil.destroy(errorText);
		#if mobile
		FlxG.mouse.visible = false;
		#end
		super.destroy();
	}
}
