package options.groupData;

import lime.graphics.opengl.GL;
import general.shaders.ColorblindFilter;
import lime.system.Display;

class GeneralGroup extends OptionCata
{
	public function new(X:Float, Y:Float, width:Float, height:Float)
	{
		super(X, Y, width, height);

		var option:Option = new Option(this, 'General', TITLE);
		addOption(option);

		var option:Option = new Option(this, 'framerate', INT, [24, #if mobile 1000 #else 2000 #end, 'TPS']);
		addOption(option);
		option.onChange = onChangeFramerate;

		var option:Option = new Option(this, 'drawFramerate', INT, [24, #if mobile 240 #else 1000 #end, 'FPS']);
		addOption(option);
		option.onChange = onChangeDrawFramerate;

		var option:Option = new Option(this, 'lockRender', BOOL);
		addOption(option);
		option.onChange = onChangelockRender;

		var option:Option = new Option(this, 'renderThread', BOOL);
		addOption(option);
		option.onChange = onChangerenderThread;

		var option:Option = new Option(this, 'lowQuality', BOOL);
		addOption(option);

		var resolutionArray:Array<Array<String>> = resoData();
		var option:Option = new Option(this, 'resolution', STRING, resolutionArray);
		addOption(option);
		option.onChange = onChangeResolution;

		var option:Option = new Option(this, 'gameQuality', INT, [0, 3]);
		addOption(option);

		var langArray:Array<String> = languageArray();
		var option:Option = new Option(this, 'language', STRING, langArray);
		addOption(option);
		option.onChange = onChangeLanguage;

		var option:Option = new Option(this, 'antialiasing', BOOL);
		addOption(option);

		var option:Option = new Option(this, 'flashing', BOOL);
		addOption(option);

		var option:Option = new Option(this, 'shaders', BOOL);
		addOption(option);

		var option:Option = new Option(this, 'cacheOnGPU', BOOL);
		addOption(option);

		var option:Option = new Option(this, 'autoPause', BOOL);
		addOption(option);
		option.onChange = onChangePause;

		var colorblindFilterArray:Array<String> = [
			'None',
			'Protanopia',
			'Protanomaly',
			'Deuteranopia',
			'Deuteranomaly',
			'Tritanopia',
			'Tritanomaly',
			'Achromatopsia',
			'Achromatomaly'
		];
		var colorblindDisplayArray:Array<String> = [
			'None',
			'Protanopia',
			'Protanomaly',
			'Deuteranopia',
			'Deuteranomaly',
			'Tritanopia',
			'Tritanomaly',
			'Achromatopsia',
			'Achromatomaly'
		];

		var option:Option = new Option(this, 'colorblindMode', STRING, [colorblindFilterArray, colorblindDisplayArray]);
		addOption(option);
		option.onChange = onChangeFilter;

		changeHeight(0); //初始化真正的height
	}

	///////////////////////////////////////////////////////////////////////////

	function resoData():Array<Array<String>> {
		var display:Display = lime.system.System.getDisplay(0);
		var maxReso:Float = display.bounds.width * display.bounds.height;
		var displayOutput:Array<String> = [];

		var data:Array<Float> = [640 * 360, 854 * 480, 960 * 540, 1280 * 720, 1366 * 768, 1600 * 900, 1920 * 1080, 2560 * 1440, 2560 * 1600, 3200 * 1800, 3840 * 2160];
		var displayData:Array<String> = ["360P", "480P", "540P", "720P", "768P", "900P", "1080P", "1440P (2K)", "1600P", "1800P", "2160P (4K)"];
		
		for (i in 0...data.length)
		{
			if (maxReso > Math.floor(data[i]))
			{
				displayOutput.push(displayData[i]);
			} else {
				displayOutput.push("Native: " + display.bounds.width + "x" + display.bounds.height);
				break;
			}
		}

		return [displayOutput, displayOutput];
	}

	function languageArray():Array<String> 
	{
		var output:Array<String> = [];
		var contents:Array<String> = FileSystem.readDirectory(Paths.getPath('language'));
		for (item in contents)
		{
			if (item == "JustSay")
				continue; // JustSay不能被读取为语言文件
			var itemPath = Paths.getPath('language') + '/' + item;
			if (FileSystem.isDirectory(itemPath))
			{
				output.push(item);
			}
		}
		Language.check();
		return output;
	}

	///////////////////////////////////////////////////////////////

	function onChangeFramerate()
	{
		if (ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
	}

	function onChangeDrawFramerate()
	{
		FlxG.stage.application.window.drawFrameRate = ClientPrefs.data.drawFramerate;
	}

	function onChangelockRender()
	{
		FlxG.stage.application.window.lockRender = ClientPrefs.data.lockRender;
	}

	function onChangerenderThread()
	{
		GL.setMultiThreaded(ClientPrefs.data.renderThread);
	}

	function onChangeResolution()
	{
		var output:Array<Float> = [];
		switch(ClientPrefs.data.resolution) {
			case '360P':
				output = [640, 360];
			case '480P':
				output = [854, 480];
			case '540P':
				output = [960, 540];
			case '720P':
				output = [1280, 720];
			case '768P':
				output = [1366, 768];
			case '900P':
				output = [1600, 900];
			case '1080P':
				output = [1920, 1080];
			case '1440P (2K)':
				output = [2560, 1440];
			case '1600P':
				output = [2560, 1600];
			case '1800P':
				output = [3200, 1800];
			case '2160P (4K)':
				output = [3840, 2160];
			default:
				var display:Display = lime.system.System.getDisplay(0);
				output = [display.bounds.width, display.bounds.height];
		}
		openfl.Lib.current.stage.setLogicalSize(Std.int(output[0]), Std.int(output[1]));
	}

	function onChangeFilter()
	{
		ColorblindFilter.UpdateColors();
	}

	function onChangePause()
	{
		FlxG.autoPause = ClientPrefs.data.autoPause;
	}

	function onChangeLanguage()
	{
		Language.resetData();
		OptionsState.instance.changeLanguage();
	}
}
