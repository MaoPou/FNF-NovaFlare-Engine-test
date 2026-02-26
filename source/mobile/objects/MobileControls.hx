package mobile.objects;

import haxe.ds.Map;
import haxe.extern.EitherType;

import mobile.flixel.input.FlxMobileInputManager;
import mobile.flixel.FlxButton;

class MobileControls extends FlxTypedSpriteGroup<FlxMobileInputManager>
{
	public var virtualPad:FlxVirtualPad = new FlxVirtualPad(NONE, NONE);
	public var hitbox:FlxHitbox = new FlxHitbox();
	// YOU CAN'T CHANGE PROPERTIES USING THIS EXCEPT WHEN IN RUNTIME!!
	public var current:CurrentManager;

	public static var mode(get, set):Int;
	public static var forcedControl:Null<Int>;

	public function new(?forceType:Int, ?extra:Bool = true)
	{
		super();

		if (forceType != null)
			forcedControl = forceType;
		else
			forcedControl = get_mode();

		switch (forcedControl)
		{
			case 0: // RIGHT_FULL
				initControler(0);
			case 1: // LEFT_FULL
				initControler(1);
			case 2: // CUSTOM
				initControler(2);
			case 3: // BOTH
				initControler(3);
			case 4: // HITBOX
				initControler(4);
			case 5: // KEYBOARD
		}
		current = new CurrentManager(this);
		// Options related stuff
		// alpha = ClientPrefs.data.controlsAlpha;
		updateButtonsColors();
	}

	private function initControler(virtualPadMode:Int = 0):Void
	{
		switch (virtualPadMode)
		{
			case 0:
				virtualPad = new FlxVirtualPad(RIGHT_FULL_GAME, controlExtend);
				add(virtualPad);
				virtualPad = getExtraCustomMode(virtualPad);
			case 1:
				virtualPad = new FlxVirtualPad(LEFT_FULL_GAME, controlExtend);
				add(virtualPad);
				virtualPad = getExtraCustomMode(virtualPad);
			case 2:
				virtualPad = new FlxVirtualPad(RIGHT_FULL_GAME, controlExtend);
				virtualPad = getCustomMode(virtualPad);
				virtualPad = getExtraCustomMode(virtualPad);
				add(virtualPad);
			case 3:
				virtualPad = new FlxVirtualPad(BOTH_GAME, controlExtend);
				add(virtualPad);
				virtualPad = getExtraCustomMode(virtualPad);
			case 4:
				hitbox = new FlxHitbox();
				add(hitbox);
		}
	}

	public static function setCustomMode(virtualPad:FlxVirtualPad):Void
	{
		if (FlxG.save.data.buttons == null)
		{
			FlxG.save.data.buttons = new Array();
			for (buttons in virtualPad)
				FlxG.save.data.buttons.push(FlxPoint.get(buttons.x, buttons.y));
		}
		else
		{
			var tempCount:Int = 0;
			for (buttons in virtualPad)
			{
				FlxG.save.data.buttons[tempCount] = FlxPoint.get(buttons.x, buttons.y);
				tempCount++;
			}
		}

		FlxG.save.flush();
	}

	public static function getCustomMode(virtualPad:FlxVirtualPad):FlxVirtualPad
	{
		var tempCount:Int = 0;

		if (FlxG.save.data.buttons == null)
			return virtualPad;

		for (buttons in virtualPad)
		{
			if (FlxG.save.data.buttons[tempCount] != null)
			{
				buttons.x = FlxG.save.data.buttons[tempCount].x;
				buttons.y = FlxG.save.data.buttons[tempCount].y;
			}
			tempCount++;
		}

		return virtualPad;
	}

	public static function setExtraCustomMode(virtualPad:FlxVirtualPad):Void
	{
		FlxG.save.flush();
	}

	public static function getExtraCustomMode(virtualPad:FlxVirtualPad):FlxVirtualPad
	{
		return virtualPad;
	}

	override public function destroy():Void
	{
		super.destroy();

		if (virtualPad != null)
		{
			virtualPad = FlxDestroyUtil.destroy(virtualPad);
			virtualPad = null;
		}

		if (hitbox != null)
		{
			hitbox = FlxDestroyUtil.destroy(hitbox);
			hitbox = null;
		}
	}

	public static function set_mode(mode:Int = 0)
	{
		FlxG.save.data.mobileControlsMode = mode;
		FlxG.save.flush();
		return mode;
	}

	public static function get_mode():Int
	{
		if (FlxG.save.data.mobileControlsMode == null)
		{
			FlxG.save.data.mobileControlsMode = 0;
			FlxG.save.flush();
		}

		return FlxG.save.data.mobileControlsMode;
	}

	public function updateButtonsColors()
	{
		// Dynamic Controls Color
		var buttonsColors:Array<FlxColor> = [];
		var data:Dynamic;
		if (ClientPrefs.data.dynamicColors)
			data = ClientPrefs.data;
		else
			data = ClientPrefs.defaultData;

		buttonsColors.push(data.arrowRGB[0][0]);
		buttonsColors.push(data.arrowRGB[1][0]);
		buttonsColors.push(data.arrowRGB[2][0]);
		buttonsColors.push(data.arrowRGB[3][0]);
		if (mode == 3)
		{
			virtualPad.buttonLeft2.color = buttonsColors[0];
			virtualPad.buttonDown2.color = buttonsColors[1];
			virtualPad.buttonUp2.color = buttonsColors[2];
			virtualPad.buttonRight2.color = buttonsColors[3];
		}
		current.buttonLeft.color = buttonsColors[0];
		current.buttonDown.color = buttonsColors[1];
		current.buttonUp.color = buttonsColors[2];
		current.buttonRight.color = buttonsColors[3];
	}
}

class CurrentManager
{
	public var buttonLeft:FlxButton;
	public var buttonDown:FlxButton;
	public var buttonUp:FlxButton;
	public var buttonRight:FlxButton;
	public var target:FlxMobileInputManager;

	public function new(control:MobileControls)
	{
		if (MobileControls.mode == 4)
		{
			target = control.hitbox;
			// Use buttonNotes array instead of individual button fields
			buttonLeft = control.hitbox.buttonNotes[0];
			buttonDown = control.hitbox.buttonNotes[1];
			buttonUp = control.hitbox.buttonNotes[2];
			buttonRight = control.hitbox.buttonNotes[3];
		}
		else
		{
			target = control.virtualPad;
			buttonLeft = control.virtualPad.buttonLeft;
			buttonDown = control.virtualPad.buttonDown;
			buttonUp = control.virtualPad.buttonUp;
			buttonRight = control.virtualPad.buttonRight;
		}
	}
}
