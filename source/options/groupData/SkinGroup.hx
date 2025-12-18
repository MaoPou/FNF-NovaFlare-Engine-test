package options.groupData;

class SkinGroup extends OptionCata
{
	public function new(X:Float, Y:Float, width:Float, height:Float)
	{
		super(X, Y, width, height);

		var option:Option = new Option(this, 'Skin', TITLE);
		addOption(option);

		var option:Option = new Option(this, 'Note', TEXT);
		addOption(option);

		var noteSkins:Array<String> = addNoteSkins();

		if (noteSkins.length > 0)
		{
			noteSkins.insert(0, ClientPrefs.defaultData.noteSkin);

			var option:Option = new Option(this, 'noteSkin', STRING, noteSkins);
			addOption(option);
		}

		var option:Option = new Option(this, 'noteRGB', BOOL);
		if (noteSkins.length > 0)
		{
			addOption(option, true);
		} else {
			addOption(option, true);
		}


		var option:Option = new Option(this, 'NotesSubState', STATE);
		option.onChange = function() { changeState(2); };
		addOption(option);
		
		var option:Option = new Option(this, 'noteColorSwap', BOOL);
		if (noteSkins.length > 0)
		{
			addOption(option, true);
		} else {
			addOption(option, true);
		}

		var option:Option = new Option(this, 'NotesSubStateLegacy', STATE);
		option.onChange = function() { changeState(7); };
		addOption(option);
		
		/////--Splash--\\\\\

		var option:Option = new Option(this, 'Splash', TEXT);
		addOption(option);

		var option:Option = new Option(this, 'showSplash', BOOL);
		addOption(option);

		var noteSplashes:Array<String> = addNoteSplashes();
		if (noteSplashes.length > 0)
		{
			noteSplashes.insert(0, ClientPrefs.defaultData.splashSkin);

			var option:Option = new Option(this, 'splashSkin', STRING, noteSplashes);
			addOption(option, true);
		}

		var option:Option = new Option(this, 'splashRGB', BOOL);
		if (noteSplashes.length > 0)
		{
			addOption(option);
		} else {
			addOption(option, true);
		}

		var option:Option = new Option(this, 'splashAlpha', FLOAT, [0, 1, 1]);
		addOption(option);

		changeHeight(0); //初始化真正的height
	}

	function addNoteSkins():Array<String> {
		var output:Array<String> = [];
		if (Mods.mergeAllTextsNamed('images/noteSkins/list.txt', 'shared').length > 0)
			output = Mods.mergeAllTextsNamed('images/noteSkins/list.txt', 'shared');
		else
			output = CoolUtil.coolTextFile(Paths.getSharedPath('images/noteSkins/list.txt'));
		return output;
	}

	function addNoteSplashes():Array<String> {
		var output:Array<String> = [];
		if (Mods.mergeAllTextsNamed('images/noteSplashes/list.txt', 'shared').length > 0)
			output = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt', 'shared');
		else
			output = CoolUtil.coolTextFile(Paths.getSharedPath('images/noteSplashes/list.txt'));
		return output;
	}
	
	function changeState(type:Int) {
		OptionsState.instance.moveState(type);
	}
}
