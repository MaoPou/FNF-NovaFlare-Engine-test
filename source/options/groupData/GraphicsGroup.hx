package options.groupData;

class GraphicsGroup extends OptionCata
{
	public function new(X:Float, Y:Float, width:Float, height:Float)
	{
		super(X, Y, width, height);

		var option:Option = new Option(this, 'Graphics', TITLE);
		addOption(option);
		
		/////--FPScounter--\\\\\

		var option:Option = new Option(this, 'FPScounter', TEXT);
		addOption(option);

		var option:Option = new Option(this, 'showFPS', BOOL);
		option.onChange = () -> changeWatermark();
		addOption(option);

		var option:Option = new Option(this, 'rainbowFPS', BOOL);
		addOption(option, true);

		var option:Option = new Option(this, 'FPSScale', FLOAT, [0, 5, 1]);
		option.onChange = () -> changeWatermark();
		addOption(option);
		
		/////--Watermark--\\\\\

		var option:Option = new Option(this, 'Watermark', TEXT);
		addOption(option);

		var option:Option = new Option(this, 'showWatermark', BOOL);
		option.onChange = () -> changeWatermark();
		addOption(option);

		var option:Option = new Option(this, 'WatermarkScale', FLOAT, [0, 5, 1]);
		option.onChange = () -> changeWatermark();
		addOption(option);

		changeHeight(0); //初始化真正的height
	}

	function changeWatermark() {
		Main.fpsVar.visible = ClientPrefs.data.showFPS;
		Main.fpsVar.scaleX = Main.fpsVar.scaleY = ClientPrefs.data.FPSScale;
		//Main.fpsVar.change();
		if (Main.watermark != null)
		{
			Main.watermark.scaleX = Main.watermark.scaleY = ClientPrefs.data.WatermarkScale;
			Main.watermark.y += (1 - ClientPrefs.data.WatermarkScale) * Main.watermark.bitmapData.height;
			Main.watermark.visible = ClientPrefs.data.showWatermark;
		}
	}
}
