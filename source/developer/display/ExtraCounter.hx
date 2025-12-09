package developer.display;

class ExtraCounter extends Sprite
{
	public var typeName:TextField;
	public var typeData:TextField;

	public var bgSprite:FPSBG;

	public function new(x:Float = 10, y:Float = 10)
	{
		super();

		this.x = x;
		this.y = y;

		bgSprite = new FPSBG(320, 75);
		addChild(bgSprite);

		this.typeName = new TextField();
		this.typeData = new TextField();
		
		for (label in [this.typeData, this.typeName])
		{
			label.x = 0;
			label.y = 0;
			label.defaultTextFormat = new TextFormat(Assets.getFont("assets/fonts/FPS.ttf").fontName, 18, 0xFFFFFFFF, false, null, null, RIGHT, 0, 0);
			label.wordWrap = false;
			label.selectable = false;
			label.mouseEnabled = false;
			addChild(label);
		}

		typeName.x -= 10;
		typeData.x += 100;
	}

	public function update():Void
	{
		for (label in [this.typeData, this.typeName])
		{
			if (ClientPrefs.data.rainbowFPS)
			{
				label.textColor = ColorReturn.transfer(DataCalc.drawFPS, ClientPrefs.data.drawFramerate);
			}
			else
			{
				label.textColor = 0xFFFFFFFF;
			}

			if (!ClientPrefs.data.rainbowFPS && DataCalc.drawFPS <= ClientPrefs.data.drawFramerate / 2)
			{
				label.textColor = 0xFFFF0000;
			}
		}

		this.typeName.text = "Update \nDraw \nMemery \n";

		var outputText:String = '';
		var showTime:Float = Math.floor((DataCalc.updateFrameTime) * 10) / 10;
		outputText += DataCalc.updateFPS + " / " + ClientPrefs.data.framerate + "fps (" + Display.fix(showTime, 1) + " ms) \n";
		showTime = Math.floor((DataCalc.drawFrameTime) * 10) / 10;
		outputText += DataCalc.drawFPS + " / " + (ClientPrefs.data.splitUpdate ? ClientPrefs.data.drawFramerate : ClientPrefs.data.framerate) + "fps (" + Display.fix(showTime, 1) + " ms) \n";
		outputText += "APP:" + Display.fix(DataCalc.appMem, 2) + " GC:" + Display.fix(DataCalc.gcMem, 2) + " MB \n";
		this.typeData.text = outputText;
		typeData.width = typeData.textWidth;
		typeData.x = bgSprite.x + bgSprite.width - typeData.width - 10;
	}
}
