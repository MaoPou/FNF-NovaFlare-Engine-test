package objects;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.utils.Assets;

import flixel.graphics.FlxGraphic;

import flixel.util.FlxSave;
import states.PlayState;
import backend.InputFormatter;
import options.OptionsHelpers;
import backend.Song;

class KeyboardViewer extends FlxSpriteGroup
{
	public var noteArrays:Array<Array<TimeDis>> = []; // 存储所有键位的数组
	public var keyAlphas:Array<KeyButtonAlpha> = []; // 存储键位透明度对象
	public var keyTexts:Array<FlxText> = []; // 存储键位文本对象

	public var _x:Float;
	public var _y:Float;
	public var _width:Float;
	public var _height:Float;
	public var kpsText:FlxText;
	public var totalText:FlxText;

	public var keys:Int = 4; // 默认键位数

	var total:Int = 0;

	public static var instance:KeyboardViewer;

	public function new(X:Float, Y:Float)
	{
		super();
		instance = this;

		_x = X;
		_y = Y;

		var mania:Int = 3;
		if(PlayState.SONG != null) mania = PlayState.SONG.mania;
		keys = mania + 1;

		for(i in 0...keys) noteArrays.push([]);

		_width = (KeyButton.size + 4) * keys;
		_height = (KeyButton.size + 4) * 2;

		if (mania == 3)
		{
			for (i in 0...4)
			{
				var obj:KeyButton = new KeyButton(X + (KeyButton.size + 4) * i, Y, KeyButton.size, KeyButton.size);
				add(obj);
			}
			for (i in 0...4)
			{
				var obj:KeyButtonAlpha = new KeyButtonAlpha(X + (KeyButton.size + 4) * i, Y);
				keyAlphas.push(obj);
				add(obj);
			}
			var textArray:Array<String> = createArray();
			for (i in 0...4)
			{
				var obj:FlxText = new FlxText(X + (KeyButton.size + 4) * i + keyAlphas[i].width / 2, Y + keyAlphas[i].height / 2, 50, textArray[i], 10, false);
				obj.setFormat(Assets.getFont("assets/fonts/montserrat.ttf").fontName, 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, 0x00);
				obj.x -= obj.width / 2;
				obj.y -= obj.height / 2;
				obj.color = OptionsHelpers.colorArray(ClientPrefs.data.keyboardTextColor);
				obj.alpha = ClientPrefs.data.keyboardAlpha;
				keyTexts.push(obj);
				add(obj);
			}
			for (i in 0...2)
			{
				var obj:KeyButton = new KeyButton(X + (KeyButton.size + 4) * i * 2, Y + KeyButton.size + 4, KeyButton.size * 2 + 4, KeyButton.size);
				add(obj);
			}
			var textArray:Array<String> = ['KPS', 'total'];
			for (i in 0...2)
			{
				var obj:FlxText = new FlxText(members[12 + i].x + members[12 + i].width / 2, members[12 + i].y + members[12 + i].height / 4,
					KeyButton.size * 2 + 4, textArray[i], 20, false);
				obj.setFormat(Assets.getFont("assets/fonts/montserrat.ttf").fontName, 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, 0x00);
				obj.x -= obj.width / 2;
				obj.y -= obj.height / 2;
				obj.color = OptionsHelpers.colorArray(ClientPrefs.data.keyboardTextColor);
				obj.alpha = ClientPrefs.data.keyboardAlpha;
				obj.antialiasing = ClientPrefs.data.antialiasing;
				add(obj);
			}
			kpsText = new FlxText(members[12].x + members[12].width / 2, members[12].y + members[12].height / 5 * 3.5, KeyButton.size * 2 + 4, '0', 15, false);
			kpsText.setFormat(Assets.getFont("assets/fonts/montserrat.ttf").fontName, 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, 0x00);
			kpsText.x -= kpsText.width / 2;
			kpsText.y -= kpsText.height / 2;
			kpsText.color = OptionsHelpers.colorArray(ClientPrefs.data.keyboardTextColor);
			kpsText.alpha = ClientPrefs.data.keyboardAlpha;

			if (FlxG.save.data.keyboardtotal != null)
				total = FlxG.save.data.keyboardtotal;
			totalText = new FlxText(members[13].x + members[13].width / 2, members[13].y + members[13].height / 5 * 3.5, KeyButton.size * 2 + 4,
				Std.string(total), 15, false);
			totalText.setFormat(Assets.getFont("assets/fonts/montserrat.ttf").fontName, 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, 0x00);
			totalText.x -= totalText.width / 2;
			totalText.y -= totalText.height / 2;
			totalText.color = OptionsHelpers.colorArray(ClientPrefs.data.keyboardTextColor);
			totalText.alpha = ClientPrefs.data.keyboardAlpha;
			add(kpsText);
			add(totalText);
		}
		else // 多键模式
		{
			for (i in 0...keys)
			{
				var obj:KeyButton = new KeyButton(X + (KeyButton.size + 4) * i, Y, KeyButton.size, KeyButton.size);
				add(obj);
			}

			for (i in 0...keys)
			{
				var obj:KeyButtonAlpha = new KeyButtonAlpha(X + (KeyButton.size + 4) * i, Y);
				keyAlphas.push(obj);
				add(obj);
			}

			var textArray:Array<String> = createArray();
			for (i in 0...keys)
			{
				var obj:FlxText = new FlxText(X + (KeyButton.size + 4) * i + keyAlphas[i].width / 2, Y + keyAlphas[i].height / 2, 50, textArray[i], 10, false);
				obj.setFormat(Assets.getFont("assets/fonts/montserrat.ttf").fontName, 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, 0x00);
				obj.x -= obj.width / 2;
				obj.y -= obj.height / 2;
				obj.color = OptionsHelpers.colorArray(ClientPrefs.data.keyboardTextColor);
				obj.alpha = ClientPrefs.data.keyboardAlpha;
				keyTexts.push(obj);
				add(obj);
			}

			var bigButtonWidth:Int = Std.int((KeyButton.size * 2 + 4) * (keys / 4));
			var startX = X + (_width - bigButtonWidth * 2 - 4) / 2;

			for (i in 0...2)
			{
				var obj:KeyButton = new KeyButton(startX + (bigButtonWidth + 4) * i, Y + KeyButton.size + 4, bigButtonWidth, KeyButton.size);
				add(obj);
			}
			var textArray:Array<String> = ['KPS', 'total'];
			for (i in 0...2)
			{
				var obj:FlxText = new FlxText(startX + (bigButtonWidth + 4) * i + bigButtonWidth / 2, Y + KeyButton.size + 4 + KeyButton.size / 4,
					bigButtonWidth, textArray[i], 20, false);
				obj.setFormat(Assets.getFont("assets/fonts/montserrat.ttf").fontName, 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, 0x00);
				obj.x -= obj.width / 2;
				obj.y -= obj.height / 2;
				obj.color = OptionsHelpers.colorArray(ClientPrefs.data.keyboardTextColor);
				obj.alpha = ClientPrefs.data.keyboardAlpha;
				obj.antialiasing = ClientPrefs.data.antialiasing;
				add(obj);
			}

			kpsText = new FlxText(startX + bigButtonWidth / 2, Y + KeyButton.size + 4 + KeyButton.size / 5 * 3.5, bigButtonWidth, '0', 15, false);
			kpsText.setFormat(Assets.getFont("assets/fonts/montserrat.ttf").fontName, 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, 0x00);
			kpsText.x -= kpsText.width / 2;
			kpsText.y -= kpsText.height / 2;
			kpsText.color = OptionsHelpers.colorArray(ClientPrefs.data.keyboardTextColor);
			kpsText.alpha = ClientPrefs.data.keyboardAlpha;

			if (FlxG.save.data.keyboardtotal != null)
				total = FlxG.save.data.keyboardtotal;
			totalText = new FlxText(startX + bigButtonWidth + 4 + bigButtonWidth / 2, Y + KeyButton.size + 4 + KeyButton.size / 5 * 3.5, bigButtonWidth,
				Std.string(total), 15, false);
			totalText.setFormat(Assets.getFont("assets/fonts/montserrat.ttf").fontName, 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, 0x00);
			totalText.x -= totalText.width / 2;
			totalText.y -= totalText.height / 2;
			totalText.color = OptionsHelpers.colorArray(ClientPrefs.data.keyboardTextColor);
			totalText.alpha = ClientPrefs.data.keyboardAlpha;
			add(kpsText);
			add(totalText);
		}

		DisBitmap.addCache();

	}

	public function pressed(key:Int)
	{
		if(key < keyAlphas.length) {
			keyAlphas[key].alpha = 1 * ClientPrefs.data.keyboardAlpha;
			keyTexts[key].color = FlxColor.BLACK;
		}

		if (!PlayState.replayMode)
			total++;
		totalText.text = Std.string(total);
		hitArray.unshift(Date.now());

		if (!ClientPrefs.data.keyboardTimeDisplay)
			return;

		var obj:TimeDis = new TimeDis(key, Conductor.songPosition, _x, _y);
		add(obj);

		if(key < noteArrays.length) {
			var arr = noteArrays[key];
			if(arr.length > 0 && arr[arr.length - 1].endTime == -999999)
				arr[arr.length - 1].endTime = Conductor.songPosition;
			arr.push(obj);
		}
	}

	public function released(key:Int)
	{
		if(key < keyAlphas.length) {
			keyAlphas[key].alpha = 0;
			keyTexts[key].color = OptionsHelpers.colorArray(ClientPrefs.data.keyboardTextColor);
		}

		if(key < noteArrays.length) {
			var arr = noteArrays[key];
			if(arr.length > 0 && arr[arr.length - 1].endTime == -999999)
				arr[arr.length - 1].endTime = Conductor.songPosition;
		}
	}

	public function save()
	{
		FlxG.save.data.keyboardtotal = total;
		FlxG.save.flush();
	}

	public function createArray():Array<String>
	{
		var array:Array<String> = [];
		var mania:Int = (PlayState.SONG != null) ? PlayState.SONG.mania : 3;
		var keys:Int = mania + 1;

		if (mania == 3)
		{
			array.push(InputFormatter.getKeyName(Controls.instance.keyboardBinds['note_left'][0]));
			array.push(InputFormatter.getKeyName(Controls.instance.keyboardBinds['note_down'][0]));
			array.push(InputFormatter.getKeyName(Controls.instance.keyboardBinds['note_up'][0]));
			array.push(InputFormatter.getKeyName(Controls.instance.keyboardBinds['note_right'][0]));
			return array;
		}

		var keybindID = '${mania}_key';

		for (i in 0...keys)
		{
			// Get the keybind name using the format used in ClientPrefs
			var bindName = '${keybindID}_${i}';
			var keysArray = Controls.instance.keyboardBinds.get(bindName);

			if(keysArray != null && keysArray.length > 0)
				array.push(InputFormatter.getKeyName(keysArray[0]));
			else
				array.push('?');
		}
		return array;
	}

	public function removeObj(obj:TimeDis)
	{
		if(obj.line < noteArrays.length) {
			noteArrays[obj.line].remove(obj);
		}
		remove(obj, true);
		obj.destroy();
	}

	public var kps:Int = 0;
	public var kpsCheck:Int = 0;
	public var hitArray:Array<Date> = [];

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var i = hitArray.length - 1;
		while (i >= 0)
		{
			var time:Date = hitArray[i];
			if (time != null && time.getTime() + 1000 < Date.now().getTime())
				hitArray.remove(time);
			else
				i = -1; // 跳出循环
			i--;
		}
		kps = hitArray.length;

		if (kpsCheck != kps)
		{
			kpsCheck = kps;
			kpsText.text = Std.string(kps);
		}
	}
}

class KeyButton extends FlxSprite
{
	var bgAlpha = 0.3 * ClientPrefs.data.keyboardAlpha;
	var lineAlpha = 0.8 * ClientPrefs.data.keyboardAlpha;

	public static var size = 50;

	public function new(X:Float, Y:Float, Width:Int, Height:Int)
	{
		super(X, Y);

		var shape:Shape = new Shape();
		shape.graphics.lineStyle(2, FlxColor.WHITE, lineAlpha);
		shape.graphics.drawRoundRect(0, 0, Width, Height, Std.int(size / 3), Std.int(size / 3));
		shape.graphics.lineStyle();
		shape.graphics.beginFill(FlxColor.WHITE, bgAlpha);
		shape.graphics.drawRoundRect(0, 0, Width, Height, Std.int(size / 3), Std.int(size / 3));
		shape.graphics.endFill();

		var BitmapData:BitmapData = new BitmapData(Width, Height, 0x00FFFFFF);
		BitmapData.draw(shape);

		loadGraphic(BitmapData);
		antialiasing = ClientPrefs.data.antialiasing;
		color = OptionsHelpers.colorArray(ClientPrefs.data.keyboardBGColor);
	}
}

class KeyButtonAlpha extends FlxSprite
{
	var size = KeyButton.size;

	public var tween = FlxTween;

	public function new(X:Float, Y:Float)
	{
		super(X, Y);

		var shape:Shape = new Shape();
		shape.graphics.beginFill(FlxColor.WHITE, 1);
		shape.graphics.drawRoundRect(0, 0, size, size, Std.int(size / 3), Std.int(size / 3));
		shape.graphics.endFill();

		var BitmapData:BitmapData = new BitmapData(size, size, 0x00FFFFFF);
		BitmapData.draw(shape);

		loadGraphic(BitmapData);
		antialiasing = ClientPrefs.data.antialiasing;
		alpha = 0;
	}
}

class TimeDis extends FlxSprite
{
	public var startTime:Float;
	public var endTime:Float = -999999;
	public var line:Int;

	var durationTime:Float = ClientPrefs.data.keyboardTime;

	public function new(Line:Int, Time:Float, X:Float, Y:Float)
	{
		this.line = Line;
		super(X + Line * (KeyButton.size + 4), Y - 4 - DisBitmap.Height);
		this.startTime = Time;
		frames = Cache.getFrame('keyboardViewer');
		_frame.frame.height = 1;
		color = OptionsHelpers.colorArray(ClientPrefs.data.keyboardBGColor);
		alpha = ClientPrefs.data.keyboardAlpha;
	}

	var saveTime:Float;

	override function update(elapsed:Float)
	{
		if (endTime == -999999)
		{
			_frame.frame.y = (1 - ((Conductor.songPosition - startTime) / durationTime)) * DisBitmap.Height;
			_frame.frame.height = ((Conductor.songPosition - startTime) / durationTime) * DisBitmap.Height;
			offset.y = -(1 - ((Conductor.songPosition - startTime) / durationTime)) * DisBitmap.Height;
			if (_frame.frame.y < 0)
				_frame.frame.y = 0;
			if (Conductor.songPosition - startTime > durationTime)
				offset.y = 0;
			saveTime = Conductor.songPosition;
		}
		else
		{
			if (endTime - startTime < durationTime)
				_frame.frame.y = (1 - ((Conductor.songPosition - startTime) / durationTime)) * DisBitmap.Height;
			else
				_frame.frame.y = (1 - ((Conductor.songPosition - (endTime - durationTime)) / durationTime)) * DisBitmap.Height;
			offset.y -= -((Conductor.songPosition - saveTime) / durationTime) * DisBitmap.Height;
			saveTime = Conductor.songPosition;
		}
		if (_frame.frame.height > DisBitmap.Height)
			_frame.frame.height = DisBitmap.Height;
		if (_frame.frame.height <= 0)
			_frame.frame.height = 1; // fix bug

		if (endTime != -999999 && Conductor.songPosition - endTime > durationTime)
			KeyboardViewer.instance.removeObj(this);
	}
}

class DisBitmap extends Bitmap
{
	static public var Width:Int = KeyButton.size;
	static public var Height:Int = Std.int(KeyButton.size * 3);

	static public var colorArray:Array<FlxColor> = [];

	static public function addCache() {
		var BitmapData:BitmapData = new BitmapData(Width, Height, true, 0);
		var shape:Shape = new Shape();

		for (i in 0...Std.int(Height / 10))
		{
			shape.graphics.beginFill(FlxColor.WHITE, i / Std.int(Height / 10));
			shape.graphics.drawRect(0, i, Width, 1);
			shape.graphics.endFill();
		}
		shape.graphics.beginFill(FlxColor.WHITE);
		shape.graphics.drawRect(0, Std.int(Height / 10), Width, Height - Std.int(Height / 10));
		shape.graphics.endFill();
		BitmapData.draw(shape);

		var spr:FlxSprite = new FlxSprite();
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData);
		spr.loadGraphic(newGraphic);

		Cache.currentTrackedFrames.set('keyboardViewer', spr.frames);
	}
}