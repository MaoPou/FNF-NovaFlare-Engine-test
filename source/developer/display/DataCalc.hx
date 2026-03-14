package developer.display;

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

		var time = Lib.getTimer();
		if (time - updateTimeSave < 100)
			return;

		var updateWait:Float = time - updateTimeSave;
		var currentMember:Float = updateMember;
		var targetFramerate:Int = ClientPrefs.data.framerate;

		updateTimeSave = time;
		updateMember = 0;

		//BackendThread.run(() -> {
			/////////////////// →更新
			var newFrameTime:Float = 0;

			if (Math.abs(Math.floor(1000 / updateFrameTime + 0.5) - Math.floor(1000 / (updateWait / currentMember) + 0.5)) > (targetFramerate / 5)) 
				newFrameTime = updateWait / currentMember;
			else
				newFrameTime = updateFrameTime * 0.9 + updateWait / currentMember * 0.1;
			
			updateFrameTime = newFrameTime;

			var newFPS = Math.floor(1000 / updateFrameTime + 0.5);
			if (newFPS > targetFramerate)
				newFPS = targetFramerate;
			
			updateFPS = newFPS;

			/////////////////// →fps计算

			// Flixel keeps reseting this to 60 on focus gained
			//if (FlxG.stage.window.frameRate != ClientPrefs.data.framerate && FlxG.stage.window.frameRate != FlxG.game.focusLostFramerate) {
			//	FlxG.stage.window.frameRate = ClientPrefs.data.framerate;
			//}

			appMem = getAppMem();
			gcMem = getGcMem();
		//});

		/////////////////// →memory计算

		////////////////// 数据初始化
	}

	static public var drawTimeSave:Float = 0;
	static public var drawCount:Float = 0;

	static public function draw()
	{
		drawCount++;
		
		var time = Lib.getTimer();
		if (time - drawTimeSave < 100)
			return;
		
		var drawWait:Float = time - drawTimeSave;
		var currentCount:Float = drawCount;
		var lockRender:Bool = ClientPrefs.data.lockRender;
		var drawFramerate:Int = ClientPrefs.data.drawFramerate;
		var framerate:Int = ClientPrefs.data.framerate;

		drawTimeSave = time;
		drawCount = 0;

		//BackendThread.run(() -> {
			/////////////////// →更新
			var newFrameTime:Float = 0;

			if (Math.abs(Math.floor(1000 / drawFrameTime + 0.5) - Math.floor(1000 / (drawWait / currentCount) + 0.5)) > (lockRender ? (drawFramerate / 5) : (framerate / 5))) 
				newFrameTime = drawWait / currentCount;
			else
				newFrameTime = drawFrameTime * 0.9 + drawWait / currentCount * 0.1;
			
			drawFrameTime = newFrameTime;

			var newFPS = Math.floor(1000 / drawFrameTime + 0.5);
			if (lockRender) {
				if (newFPS > drawFramerate) {
					newFPS = drawFramerate;
				}
			} else {
				if (newFPS > framerate) {
					newFPS = framerate;
				}
			}
			drawFPS = newFPS;
		//});

		////////////////////////////// 数据初始化
	}

	static public function getAppMem():Float
	{
		return FlxMath.roundDecimal(Gc.memInfo64(4) / 1024 / 1024, 2); //转化为MB
	}

	static public function getGcMem():Float
	{
		return 0;
		//FlxMath.roundDecimal(GCManager.gcGarbageEstimate() / 1024 / 1024, 2); //转化为MB
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
