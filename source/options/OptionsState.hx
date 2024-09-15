package options;

import states.MainMenuState;
import states.FreeplayState;
import states.FreeplayStatePsych;

import mobile.substates.MobileControlSelectSubState;
import mobile.substates.MobileExtraControl;

import backend.ClientPrefs;
import language.Language;

import backend.StageData;

class OptionsState extends MusicBeatState
{
	public static var instance:OptionsState;

	var filePath:String = 'menuExtend/OptionsState/';

	private static var position:Float = 0;
	private static var lerpPosition:Float = 0;
	private static var maxPos:Float = 0;

	var optionName:Array<String> = [];

	var cataArray:Array<OptionCata> = [];
	var bgArray:Array<OptionBG> = [];

	public static var stateType:Int = 0;
    
	override function create()
	{
			optionName = [
				Language.getStr('General'), 
				Language.getStr('Gameplay'), 
				Language.getStr('Backend'), 
				Language.getStr('Game UI'), 
				Language.getStr('Skin'), 
				Language.getStr('Input'), 
				Language.getStr('User Interface'), 
				Language.getStr('Watermark')];

		persistentUpdate = persistentDraw = true;

		FlxG.mouse.visible = true;

		Main.fpsVar.visible = false;
		if(Main.watermark != null) Main.watermark.visible = false;

		instance = this;
		
		var bg = new Rect(0,0, FlxG.width, FlxG.height, 0, 0, 0x302E3A);
		add(bg);

		var bg = new FlxSprite().loadGraphic(Paths.image(filePath + 'bg'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(600, 600);
		bg.updateHitbox();
		bg.y = FlxG.height / 2 - bg.height / 2;
		bg.x = 250 + (FlxG.width - 250) / 2 - bg.width / 2;
		bg.color = 0x444444;
		bg.alpha = 0.4;
		add(bg);

		var bg = new Rect(0,0, 250, FlxG.height, 0, 0, 0x24232C);
		add(bg);

		for (i in 0...optionName.length)
		{
			var option = new OptionCata(0, 80.625 * i, optionName[i]);
			add(option);
			cataArray.push(option);
		}

		var back = new BackButton(0,0, 250, 75, 'back', 0x53b7ff, backMenu);
		back.y = FlxG.height - 75;
		add(back);

		maxPos = 0;

		for (i in 0...cataArray.length)
		{
			var bg:OptionBG = new OptionBG(250, 0);
			add(bg);
			bgArray.push(bg);
			switch (i)
			{
				case 0:
					GeneralGroup.add(bg);
				case 1:
					GameplayGroup.add(bg);
				case 2:
					BackendGroup.add(bg);
				case 3:
					UIGroup.add(bg);
				case 4:
					SkinGroup.add(bg);
				case 5:
					InputGroup.add(bg);
				case 6:
					InterfaceGroup.add(bg);
				case 7:
					WatermarkGroup.add(bg);
			}

			if (i != 0) bg.y = bgArray[bgArray.length - 1].y + bgArray[bgArray.length - 1].saveHeight;
			if (i != cataArray.length - 1) maxPos += bg.saveHeight;
			else maxPos += bg.saveHeight - FlxG.height;
		}

		mouseMove();

		var checked:Bool = false;
		for (i in 0...optionName.length)
		{
			if (checked) continue;
			if (position <= cataArray[i].y)
			{
				//checked = true;
				//cataArray[i].forceUpdate();
			}
		}

		
		super.create();
	}

	public var ignoreCheck:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		for (i in 0...cataArray.length)
		{
			if (FlxG.mouse.overlaps(cataArray[i]) && FlxG.mouse.justReleased)
			{
				var data:Int = 0;
				for (num in 0...i) 
					data += bgArray[num].saveHeight;
				position = data;
			} else {
				cataArray[i].focused = false;
				cataArray[i].forceUpdate();
			}
		}

		mouseMove();

		if (FlxG.mouse.x >= 250 && FlxG.mouse.x <= FlxG.width && !ignoreCheck)
		{
			position -= FlxG.mouse.wheel * 120;
			if (FlxG.mouse.pressed) 
			{
				position -= moveData;
				lerpPosition = position;
			}
			if (FlxG.mouse.justReleased)
			{
				position -= avgSpeed * 1.5 * (0.0166 / elapsed) * Math.pow(1.1, Math.abs(avgSpeed * 0.8));
			}
		}

		if (position > maxPos) position = maxPos;
		if (position < 0) position = 0;
		if (lerpPosition > maxPos) lerpPosition = maxPos;
		if (lerpPosition < 0) lerpPosition = 0;

		if (Math.abs(lerpPosition - position) < 0.1) lerpPosition = position;
		else lerpPosition = FlxMath.lerp(position, lerpPosition, Math.exp(-elapsed * 15));

		for (num in 0...bgArray.length)
		{
			if (num == 0) bgArray[num].y = -lerpPosition;
			else bgArray[num].y = bgArray[num - 1].y + bgArray[num - 1].saveHeight;
		}
	}

	override function closeSubState()
	{				
		super.closeSubState();
		
		persistentUpdate = true;
		FlxG.mouse.visible = true;
	}

	var saveMouseY:Int = 0;
	var moveData:Int = 0;
	public var avgSpeed:Float = 0;
	function mouseMove()
	{
		if (FlxG.mouse.justPressed) saveMouseY = FlxG.mouse.y;
		moveData = FlxG.mouse.y - saveMouseY;
		saveMouseY = FlxG.mouse.y;
		avgSpeed = avgSpeed * 0.75 + moveData * 0.25;
	}

	public function moveState(type:Int) {
		switch(type)
		{
			case 1: //NoteOffsetState
				LoadingState.loadAndSwitchState(new NoteOffsetState());
			case 2: //NotesSubState
				persistentUpdate = false;
				openSubState(new NotesSubState());
			case 3: //ControlsSubState
				persistentUpdate = false;
				openSubState(new ControlsSubState());
			case 4: //MobileControlSelectSubState
				persistentUpdate = false;
				openSubState(new MobileControlSelectSubState());
			case 5: //MobileExtraControl
				persistentUpdate = false;
				openSubState(new MobileExtraControl());
		}
	}

	var pressCheck:Bool = false;

	function backMenu() {
		if (!pressCheck){
			pressCheck = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			ClientPrefs.saveSettings();
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
			Main.fpsVar.scaleX = Main.fpsVar.scaleY = ClientPrefs.data.FPSScale;
			Main.fpsVar.change();
			if(Main.watermark != null) {
				Main.watermark.scaleX = Main.watermark.scaleY = ClientPrefs.data.WatermarkScale;
				Main.watermark.y += (1 - ClientPrefs.data.WatermarkScale) * Main.watermark.bitmapData.height;
				Main.watermark.visible = ClientPrefs.data.showWatermark;
			}			
			switch (stateType)
			{
				case 0:
					MusicBeatState.switchState(new MainMenuState());
				case 1:
					if (!ClientPrefs.data.freeplayOld) MusicBeatState.switchState(new FreeplayState());
					else  MusicBeatState.switchState(new FreeplayStatePsych());
				case 2:
					MusicBeatState.switchState(new PlayState());
			}
			stateType = 0;
		}
	}
}