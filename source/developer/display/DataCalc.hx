package developer.display;

using StringTools;

class DataCalc
{
	static public var updateFPS:Float = 0;
	static public var updateFrameTime:Float = 0;

	static public var appMem:Float = 0;
	static public var gcMem:Float = 0;

	static public var drawFPS:Float = 0;
	static public var drawFrameTime:Float = 0;

	/////////////////////////////////////////

	static public var updateTimeSave:Float = 0;
	static public var updateMember:Float = 0;

	static public function update()
	{
		updateMember++;
		if (Lib.getTimer() - updateTimeSave < 100)
			return;

		var updateWait:Float = Lib.getTimer() - updateTimeSave;

		/////////////////// →更新
		if (Math.abs(Math.floor(1000 / updateFrameTime + 0.5) - Math.floor(1000 / (updateWait / updateMember) + 0.5)) > (ClientPrefs.data.framerate / 5)) 
			updateFrameTime = updateWait / updateMember;
		else
			updateFrameTime = updateFrameTime * 0.9 + updateWait / updateMember * 0.1;

		updateFPS = Math.floor(1000 / updateFrameTime + 0.5);
		if (updateFPS > ClientPrefs.data.framerate)
			updateFPS = ClientPrefs.data.framerate;

		/////////////////// →fps计算

		// Flixel keeps reseting this to 60 on focus gained
		//if (FlxG.stage.window.frameRate != ClientPrefs.data.framerate && FlxG.stage.window.frameRate != FlxG.game.focusLostFramerate) {
		//	FlxG.stage.window.frameRate = ClientPrefs.data.framerate;
		//}

		appMem = getAppMem();
		gcMem = getGcMem();

		/////////////////// →memory计算

		updateTimeSave = Lib.getTimer();
		updateMember = 0;

		////////////////// 数据初始化
	}

	static public var drawTimeSave:Float = 0;
	static public var drawCount:Float = 0;

	static public function draw()
	{
		drawCount++;
		
		if (Lib.getTimer() - drawTimeSave < 100)
			return;
		
		var drawWait:Float = Lib.getTimer() - drawTimeSave;

		/////////////////// →更新
		if (Math.abs(Math.floor(1000 / drawFrameTime + 0.5) - Math.floor(1000 / (drawWait / drawCount) + 0.5)) > (ClientPrefs.data.splitUpdate ? (ClientPrefs.data.drawFramerate / 5) : (ClientPrefs.data.framerate / 5))) 
			drawFrameTime = drawWait / drawCount;
		else
			drawFrameTime = drawFrameTime * 0.9 + drawWait / drawCount * 0.1;

		drawFPS = Math.floor(1000 / drawFrameTime + 0.5);
		if (ClientPrefs.data.splitUpdate) {
			if (drawFPS > ClientPrefs.data.drawFramerate) {
				drawFPS = ClientPrefs.data.drawFramerate;
			}
		} else {
			if (drawFPS > ClientPrefs.data.framerate) {
				drawFPS = ClientPrefs.data.framerate;
			}
		}

		////////////////////////////// 数据初始化

		drawTimeSave = Lib.getTimer();
		drawCount = 0;
	}

	static public function getAppMem():Float
	{
		return FlxMath.roundDecimal(Gc.memInfo64(4) / 1024 / 1024, 2); //转化为MB
	}

	static public function getGcMem():Float
	{
		return FlxMath.roundDecimal(GCManager.gcGarbageEstimate() / 1024 / 1024, 2); //转化为MB
	}
}

class Display
{
	static public function fix(data:Float, decimal:Int):String
	{
		var returnString:String = '';
		var zeros:String= '';

		for (i in 0...decimal)
			zeros += '0';

		if (data % 1 == 0)
			returnString = Std.string(data) + '.' + zeros;
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
