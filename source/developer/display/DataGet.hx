package developer.display;

class DataGet
{
	static public var currentFPS:Float = 0;
	static public var displayedFrameTime:Float;

	static public var memory:Float = 0; //处理成mb
	static public var memoryDis:Float = 0; //真实显示的数据，可能会转换为MB
	static public var memType:String = "MB";

	static public var wait:Float = 0;
	static public var number:Float = 0;

	static public function update()
	{
		wait += FlxG.elapsed * 1000;
		number++;
		if (wait < 100)
			return;

		/////////////////// →更新
		if (Math.abs(Math.floor(1000 / displayedFrameTime + 0.5) - Math.floor(1000 / (wait / number) + 0.5)) > (ClientPrefs.data.framerate / 5)) 
			displayedFrameTime = wait / number;
		else
			displayedFrameTime = displayedFrameTime * 0.9 + wait / number * 0.1;

		currentFPS = Math.floor(1000 / displayedFrameTime + 0.5);
		if (currentFPS > ClientPrefs.data.framerate)
			currentFPS = ClientPrefs.data.framerate;

		/////////////////// →fps计算

		// Flixel keeps reseting this to 60 on focus gained
		if (FlxG.stage.window.frameRate != ClientPrefs.data.framerate && FlxG.stage.window.frameRate != FlxG.game.focusLostFramerate) {
			FlxG.stage.window.frameRate = ClientPrefs.data.framerate;
		}

		memory = getMem();
		if (Math.abs(memory) < 1000)
		{
			memoryDis = Math.abs(memory);
			memType = "MB";
		}
		else
		{
			memoryDis = Math.ceil(Math.abs(memory / 1024) * 100) / 100;
			memType = "GB";
		}

		/////////////////// →memory计算

		wait -= 100; 
		number = 0;
	}

	static public function getMem():Float
	{
		return FlxMath.roundDecimal(Gc.memInfo64(4) / 1024 / 1024, 2); //转化为MB
	}
}

class Display
{
	static public function fix(data:Float, isMemory:Bool = false):String
	{
		var returnString:String = '';

		if (data % 1 == 0)
			if (isMemory && DataGet.memType == 'GB')
				returnString = Std.string(data) + '.00';
			else
				returnString = Std.string(data) + '.0';
		else if ((data * 10) % 1 == 0 && isMemory && DataGet.memType == 'GB')
			returnString = Std.string(data) + '0';
		else
			returnString = Std.string(data);

		return returnString;
	}
}

class ColorReturn
{
	static public function transfer(data:Float, maxData:Float):FlxColor
	{
		var red = 0;
		var green = 0;
		var blue = 126;

		if (data < maxData / 2)
		{
			red = 255;
			green = Std.int(255 * data / maxData * 2);
		}
		else
		{
			red = Std.int(255 * (maxData - data) / maxData * 2);
			green = 255;
		}

		return FlxColor.fromRGB(red, green, blue, 255);
	}
}
