package options.groupData;

class InterfaceGroup extends OptionCata
{
	public function new(X:Float, Y:Float, width:Float, height:Float)
	{
		super(X, Y, width, height);

		var option:Option = new Option(this, 'User Interface', TITLE);
		addOption(option);

		var CustomFadeArray:Array<String> = ['Move', 'Alpha'];
		var option:Option = new Option(this, 'CustomFade', STRING, CustomFadeArray);
		addOption(option);

		var option:Option = new Option(this, 'CustomFadeText', BOOL);
		addOption(option);

		var option:Option = new Option(this, 'CustomFadeSound', FLOAT, [0, 1, 1]);
		addOption(option);
		

		var option:Option = new Option(this, 'audioDisplayQuality', INT, [1, 4]);
		addOption(option);

		var option:Option = new Option(this, 'audioDisplayUpdate', INT, [0, 200, 'MS']);
		addOption(option);

		var option:Option = new Option(this, 'skipTitleVideo', BOOL);
		addOption(option);

		var option:Option = new Option(this, 'resultsScreen', BOOL);
		addOption(option);

		var option:Option = new Option(this, 'loadingScreen', BOOL);
		addOption(option);

		var maxthread:Int = Std.int(Math.max(1, CoolUtil.getCPUThreadsCount() - #if DISCORD_ALLOWED 2 #else 1 #end));
		var option:Option = new Option(this, 'loadThreads', INT, [1, maxthread, ' Thread']);
		addOption(option);

		changeHeight(0); //初始化真正的height
	}
}
