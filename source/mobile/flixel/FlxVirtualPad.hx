package mobile.flixel;

import flixel.graphics.frames.FlxTileFrames;
import flixel.input.keyboard.FlxKey;

import mobile.flixel.input.FlxMobileInputManager;
import mobile.flixel.FlxButton;

import general.backend.InputFormatter;

import openfl.display.Shape;
import openfl.display.BitmapData;

/**
 * A gamepad.
 * It's easy to customize the layout.
 *
 * @original author Ka Wing Chin & Mihai Alexandru
 * @modification's author: Karim Akra & Lily (mcagabe19)
 */
class FlxVirtualPad extends FlxMobileInputManager
{
	public var buttonLeft:FlxButton;
	public var buttonUp:FlxButton;
	public var buttonRight:FlxButton;
	public var buttonDown:FlxButton;	

	public var buttonLeft2:FlxButton;
	public var buttonUp2:FlxButton;
	public var buttonRight2:FlxButton;
	public var buttonDown2:FlxButton;

	public var buttonA:FlxButton;
	public var buttonB:FlxButton;
	public var buttonC:FlxButton;
	public var buttonD:FlxButton;
	public var buttonE:FlxButton;
	public var buttonF:FlxButton;
	public var buttonG:FlxButton;
	public var buttonS:FlxButton;
	public var buttonV:FlxButton;
	public var buttonX:FlxButton;
	public var buttonY:FlxButton;
	public var buttonZ:FlxButton;
	public var buttonP:FlxButton;

	public var extraKeys:Array<FlxButton> = [];

	/**
	 * Create a gamepad.
	 *
	 * @param   DPadMode     The D-Pad mode. `LEFT_FULL` for example.
	 * @param   ActionMode   The action buttons mode. `A_B_C` for example.
	 */
	public function new(DPad:FlxDPadMode, Action:FlxActionMode)
	{
		super();

		var BTN:Int = 130;
		var ratio:Float = 1.01;
		function ux(v:Int):Float return BTN * v * ratio;
		function uy(v:Int):Float return BTN * v * ratio;
		function rx(v:Int):Float return FlxG.width - ux(v);
		function by(v:Int):Float return FlxG.height - uy(v);

		switch (DPad)
		{
			case UP_DOWN:
				add(buttonUp = createButton(0, by(2), BTN, BTN, 'up', keybindSet('ui_up'), 0xFF12FA05));
				add(buttonDown = createButton(0, by(1), BTN, BTN, 'down', keybindSet('ui_down'), 0xFF00FFFF));
			case LEFT_RIGHT:
				add(buttonLeft = createButton(0, by(1), BTN, BTN, 'left', keybindSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(ux(1), by(1), BTN, BTN, 'right', keybindSet('ui_right'), 0xFFF9393F));
			case UP_LEFT_RIGHT:
				add(buttonUp = createButton(ux(1), by(2), BTN, BTN, 'up', keybindSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, by(1), BTN, BTN, 'left', keybindSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(ux(2), by(1), BTN, BTN, 'right', keybindSet('ui_right'), 0xFFF9393F));
			case LEFT_FULL:
				add(buttonUp = createButton(ux(1), by(3), BTN, BTN, 'up', keybindSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, by(2), BTN, BTN, 'left', keybindSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(ux(2), by(2), BTN, BTN, 'right', keybindSet('ui_right'), 0xFFF9393F));
				add(buttonDown = createButton(ux(1), by(1), BTN, BTN, 'down', keybindSet('ui_down'), 0xFF00FFFF));
			case LEFT_FULL_GAME:
				add(buttonUp = createButton(ux(1), by(3), BTN, BTN, 'up', keybindSet('note_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, by(2), BTN, BTN, 'left', keybindSet('note_left'), 0xFFC24B99));
				add(buttonRight = createButton(ux(2), by(2), BTN, BTN, 'right', keybindSet('note_right'), 0xFFF9393F));
				add(buttonDown = createButton(ux(1), by(1), BTN, BTN, 'down', keybindSet('note_down'), 0xFF00FFFF));
			case RIGHT_FULL:
				add(buttonUp = createButton(rx(2), by(3), BTN, BTN, 'up', keybindSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(rx(3), by(2), BTN, BTN, 'left', keybindSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(rx(1), by(2), BTN, BTN, 'right', keybindSet('ui_right'), 0xFFF9393F));
				add(buttonDown = createButton(rx(2), by(1), BTN, BTN, 'down', keybindSet('ui_down'), 0xFF00FFFF));
			case RIGHT_FULL_GAME:
				add(buttonUp = createButton(rx(2), by(3), BTN, BTN, 'up', keybindSet('note_up'), 0xFF12FA05));
				add(buttonLeft = createButton(rx(3), by(2), BTN, BTN, 'left', keybindSet('note_left'), 0xFFC24B99));
				add(buttonRight = createButton(rx(1), by(2), BTN, BTN, 'right', keybindSet('note_right'), 0xFFF9393F));
				add(buttonDown = createButton(rx(2), by(1), BTN, BTN, 'down', keybindSet('note_down'), 0xFF00FFFF));
			case BOTH:
				add(buttonUp = createButton(ux(1), by(3), BTN, BTN, 'up', keybindSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, by(2), BTN, BTN, 'left', keybindSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(ux(2), by(2), BTN, BTN, 'right', keybindSet('ui_right'), 0xFFF9393F));
				add(buttonDown = createButton(ux(1), by(1), BTN, BTN, 'down', keybindSet('ui_down'), 0xFF00FFFF));
				add(buttonUp2 = createButton(rx(2), by(3), BTN, BTN, 'up', keybindSet('ui_up'), 0xFF12FA05));
				add(buttonLeft2 = createButton(rx(3), by(2), BTN, BTN, 'left', keybindSet('ui_left'), 0xFFC24B99));
				add(buttonRight2 = createButton(rx(1), by(2), BTN, BTN, 'right', keybindSet('ui_right'), 0xFFF9393F));
				add(buttonDown2 = createButton(rx(2), by(1), BTN, BTN, 'down', keybindSet('ui_down'), 0xFF00FFFF));
			case BOTH_GAME:
				add(buttonUp = createButton(ux(1), by(3), BTN, BTN, 'up', keybindSet('note_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, by(2), BTN, BTN, 'left', keybindSet('note_left'), 0xFFC24B99));
				add(buttonRight = createButton(ux(2), by(2), BTN, BTN, 'right', keybindSet('note_right'), 0xFFF9393F));
				add(buttonDown = createButton(ux(1), by(1), BTN, BTN, 'down', keybindSet('note_down'), 0xFF00FFFF));
				add(buttonUp2 = createButton(rx(2), by(3), BTN, BTN, 'up', keybindSet('note_up', 1), 0xFF12FA05));
				add(buttonLeft2 = createButton(rx(3), by(2), BTN, BTN, 'left', keybindSet('note_left', 1), 0xFFC24B99));
				add(buttonRight2 = createButton(rx(1), by(2), BTN, BTN, 'right', keybindSet('note_right', 1), 0xFFF9393F));
				add(buttonDown2 = createButton(rx(2), by(1), BTN, BTN, 'down', keybindSet('note_down', 1), 0xFF00FFFF));
			case PauseSubstateC:
				add(buttonUp = createButton(0, by(2), BTN, BTN, "up", keybindSet('ui_up'), 0x00FF00));
				add(buttonDown = createButton(0, by(1), BTN, BTN, "down", keybindSet('ui_down'), 0x00FFFF));
				add(buttonLeft = createButton(ux(1), by(1), BTN, BTN, "left", keybindSet('ui_left'), 0xFF00FF));
				add(buttonRight = createButton(ux(2), by(1), BTN, BTN, "right", keybindSet('ui_right'), 0xFF0000));
			case OptionStateC:
				add(buttonUp = createButton(0, by(2), BTN, BTN, "up", keybindSet('ui_up'), 0x00FF00));
				add(buttonDown = createButton(0, by(1), BTN, BTN, "down", keybindSet('ui_down'), 0x00FFFF));
			case MamainmenuStateC:
				add(buttonUp = createButton(rx(1), by(4), BTN, BTN, 'up', keybindSet('ui_up'), 0xFF12FA05));
				add(buttonDown = createButton(rx(1), by(3), BTN, BTN, 'down', keybindSet('ui_down'), 0xFF00FFFF));
			case ChartingStateC:
				add(buttonUp = createButton(0, by(2), BTN, BTN, 'up', keybindSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(ux(1), by(2), BTN, BTN, 'left', keybindSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(ux(1), by(1), BTN, BTN, 'right', keybindSet('ui_right'), 0xFFF9393F));
				add(buttonDown = createButton(0, by(1), BTN, BTN, 'down', keybindSet('ui_down'), 0xFF00FFFF));
			case DIALOGUE_PORTRAIT:
				add(buttonUp = createButton(ux(1), by(3), BTN, BTN, 'up', keybindSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, by(2), BTN, BTN, 'left', keybindSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(ux(2), by(2), BTN, BTN, 'right', keybindSet('ui_right'), 0xFFF9393F));
				add(buttonDown = createButton(ux(1), by(1), BTN, BTN, 'down', keybindSet('ui_down'), 0xFF00FFFF));
				add(buttonUp2 = createButton(ux(1), uy(0), BTN, BTN, 'up', keybindSet('ui_up'), 0xFF12FA05));
				add(buttonLeft2 = createButton(0, uy(1), BTN, BTN, 'left', keybindSet('ui_left'), 0xFFC24B99));
				add(buttonRight2 = createButton(ux(2), uy(1), BTN, BTN, 'right', keybindSet('ui_right'), 0xFFF9393F));
				add(buttonDown2 = createButton(ux(1), uy(2), BTN, BTN, 'down', keybindSet('ui_down'), 0xFF00FFFF));
			case MENU_CHARACTER:
				add(buttonUp = createButton(ux(1), uy(0), BTN, BTN, 'up', keybindSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, uy(1), BTN, BTN, 'left', keybindSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(ux(2), uy(1), BTN, BTN, 'right', keybindSet('ui_right'), 0xFFF9393F));
				add(buttonDown = createButton(ux(1), uy(2), BTN, BTN, 'down', keybindSet('ui_down'), 0xFF00FFFF));
			case NOTE_SPLASH_DEBUG:
				add(buttonUp = createButton(0, uy(1), BTN, BTN, 'up', keybindSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, 0, BTN, BTN, 'left', keybindSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(ux(1), 0, BTN, BTN, 'right', keybindSet('ui_right'), 0xFFF9393F));
				add(buttonDown = createButton(ux(1), uy(1), BTN, BTN, 'down', keybindSet('ui_down'), 0xFF00FFFF));
				add(buttonUp2 = createButton(ux(1), uy(3), BTN, BTN, 'up', keybindSet('ui_up', 1), 0xFF12FA05));
				add(buttonLeft2 = createButton(0, uy(3), BTN, BTN, 'left', keybindSet('ui_left', 1), 0xFFC24B99));
				add(buttonRight2 = createButton(rx(1), uy(3), BTN, BTN, 'right', keybindSet('ui_right', 1), 0xFFF9393F));
				add(buttonDown2 = createButton(rx(2), uy(3), BTN, BTN, 'down', keybindSet('ui_down', 1), 0xFF00FFFF));
			case NONE: // do nothing
		}

		switch (Action)
		{
			case A:
				add(buttonA = createButton(rx(1), by(1), BTN, BTN, 'a', keybindSet('accept'), 0xFF0000));
			case B:
				add(buttonB = createButton(rx(1), by(1), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
			case B_X:
				add(buttonB = createButton(rx(2), by(1), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
				add(buttonX = createButton(rx(1), by(1), BTN, BTN, 'x', null, 0x99062D));
			case A_B:
				add(buttonB = createButton(rx(2), by(1), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
				add(buttonA = createButton(rx(1), by(1), BTN, BTN, 'a', keybindSet('accept'), 0xFF0000));
			case A_B_C:
				add(buttonC = createButton(rx(3), by(1), BTN, BTN, 'c', null, 0x44FF00));
				add(buttonB = createButton(rx(2), by(1), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
				add(buttonA = createButton(rx(1), by(1), BTN, BTN, 'a', keybindSet('accept'), 0xFF0000));
			case A_B_E:
				add(buttonE = createButton(rx(3), by(1), BTN, BTN, 'e', null, 0xFF7D00));
				add(buttonB = createButton(rx(2), by(1), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
				add(buttonA = createButton(rx(1), by(1), BTN, BTN, 'a', keybindSet('accept'), 0xFF0000));
			case A_B_X_Y:
				add(buttonX = createButton(rx(4), by(1), BTN, BTN, 'x', null, 0x99062D));
				add(buttonB = createButton(rx(2), by(1), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
				add(buttonY = createButton(rx(3), by(1), BTN, BTN, 'y', null, 0x4A35B9));
				add(buttonA = createButton(rx(1), by(1), BTN, BTN, 'a', keybindSet('accept'), 0xFF0000));
			case A_B_C_X_Y:
				add(buttonC = createButton(rx(3), by(1), BTN, BTN, 'c', null, 0x44FF00));
				add(buttonX = createButton(rx(2), by(2), BTN, BTN, 'x', null, 0x99062D));
				add(buttonB = createButton(rx(2), by(1), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
				add(buttonY = createButton(rx(1), by(2), BTN, BTN, 'y', null, 0x4A35B9));
				add(buttonA = createButton(rx(1), by(1), BTN, BTN, 'a', keybindSet('accept'), 0xFF0000));
			case A_B_C_X_Y_Z:
				add(buttonX = createButton(rx(3), by(2), BTN, BTN, 'x', null, 0x99062D));
				add(buttonC = createButton(rx(3), by(1), BTN, BTN, 'c', null, 0x44FF00));
				add(buttonY = createButton(rx(2), by(2), BTN, BTN, 'y', null, 0x4A35B9));
				add(buttonB = createButton(rx(2), by(1), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
				add(buttonZ = createButton(rx(1), by(2), BTN, BTN, 'z', null, 0xCCB98E));
				add(buttonA = createButton(rx(1), by(1), BTN, BTN, 'a', keybindSet('accept'), 0xFF0000));
			case A_B_C_D_V_X_Y_Z:
				add(buttonV = createButton(rx(4), by(2), BTN, BTN, 'v', null, 0x49A9B2));
				add(buttonD = createButton(rx(4), by(1), BTN, BTN, 'd', null, 0x0078FF));
				add(buttonX = createButton(rx(3), by(2), BTN, BTN, 'x', null, 0x99062D));
				add(buttonC = createButton(rx(3), by(1), BTN, BTN, 'c', null, 0x44FF00));
				add(buttonY = createButton(rx(2), by(2), BTN, BTN, 'y', null, 0x4A35B9));
				add(buttonB = createButton(rx(2), by(1), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
				add(buttonZ = createButton(rx(1), by(2), BTN, BTN, 'z', null, 0xCCB98E));
				add(buttonA = createButton(rx(1), by(1), BTN, BTN, 'a', keybindSet('accept'), 0xFF0000));
			case controlExtend:
				var keyNames:Array<String> = [
					ClientPrefs.data.extraKeyReturn1,
					ClientPrefs.data.extraKeyReturn2,
					ClientPrefs.data.extraKeyReturn3,
					ClientPrefs.data.extraKeyReturn4
				];
				for (i in 0...ClientPrefs.data.extraKey)
				{
					var btn = createButton(rx(1 + i), by(4), BTN, BTN, keyNames[i], keyboardSet(keyNames[i]), 0xFFAA66CC);
					extraKeys.push(btn);
					add(btn);
				}
			case OptionStateC:
				add(buttonLeft = createButton(rx(2), by(2), BTN, BTN, "left", keybindSet('ui_left'), 0xFF00FF));
				add(buttonRight = createButton(rx(1), by(2), BTN, BTN, "right", keybindSet('ui_right'), 0xFF0000));
				add(buttonC = createButton(rx(3), by(1), BTN, BTN, 'c', null, 0x44FF00));
				add(buttonB = createButton(rx(2), by(1), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
				add(buttonA = createButton(rx(1), by(1), BTN, BTN, 'a', keybindSet('accept'), 0xFF0000));
			case ChartingStateC:
				add(buttonS = createButton(rx(1), by(3), BTN, BTN, 's', null, 0x49A9B2));
				add(buttonG = createButton(rx(2), uy(0), BTN, BTN, 'g', null, 0x49A9B2));
				add(buttonP = createButton(rx(5), by(2), BTN, BTN, 'up', null, 0x49A9B2));
				add(buttonE = createButton(rx(5), by(1), BTN, BTN, 'down', null, 0x49A9B2));
				add(buttonV = createButton(rx(4), by(2), BTN, BTN, 'v', null, 0x49A9B2));
				add(buttonD = createButton(rx(4), by(1), BTN, BTN, 'd', null, 0x0078FF));
				add(buttonX = createButton(rx(3), by(2), BTN, BTN, 'x', null, 0x99062D));
				add(buttonC = createButton(rx(3), by(1), BTN, BTN, 'c', null, 0x44FF00));
				add(buttonY = createButton(rx(2), by(2), BTN, BTN, 'y', null, 0x4A35B9));
				add(buttonB = createButton(rx(2), by(1), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
				add(buttonZ = createButton(rx(1), by(2), BTN, BTN, 'z', null, 0xCCB98E));
				add(buttonA = createButton(rx(1), by(1), BTN, BTN, 'a', keybindSet('accept'), 0xFF0000));
			case CHARACTER_EDITOR:
				add(buttonV = createButton(rx(4), by(2), BTN, BTN, 'v', null, 0x49A9B2));
				add(buttonD = createButton(rx(4), by(1), BTN, BTN, 'd', null, 0x0078FF));
				add(buttonX = createButton(rx(3), by(2), BTN, BTN, 'x', null, 0x99062D));
				add(buttonC = createButton(rx(3), by(1), BTN, BTN, 'c', null, 0x44FF00));
				add(buttonS = createButton(rx(5), by(1), BTN, BTN, 's', null, 0xEA00FF));
				add(buttonG = createButton(rx(5), by(2), BTN, BTN, 'g', null, 0xEA00FF));
				add(buttonF = createButton(rx(3), uy(0), BTN, BTN, 'f', null, 0xFF009D));
				add(buttonY = createButton(rx(2), by(2), BTN, BTN, 'y', null, 0x4A35B9));
				add(buttonB = createButton(rx(2), by(1), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
				add(buttonZ = createButton(rx(1), by(2), BTN, BTN, 'z', null, 0xCCB98E));
				add(buttonA = createButton(rx(1), by(1), BTN, BTN, 'a', keybindSet('accept'), 0xFF0000));
			case DIALOGUE_PORTRAIT:
				add(buttonX = createButton(rx(3), uy(0), BTN, BTN, 'x', null, 0x99062D));
				add(buttonC = createButton(rx(3), uy(1), BTN, BTN, 'c', null, 0x44FF00));
				add(buttonY = createButton(rx(2), uy(0), BTN, BTN, 'y', null, 0x4A35B9));
				add(buttonB = createButton(rx(2), uy(1), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
				add(buttonZ = createButton(rx(1), uy(0), BTN, BTN, 'z', null, 0xCCB98E));
				add(buttonA = createButton(rx(1), uy(1), BTN, BTN, 'a', keybindSet('accept'), 0xFF0000));
			case MENU_CHARACTER:
				add(buttonC = createButton(rx(3), uy(0), BTN, BTN, 'c', null, 0x44FF00));
				add(buttonB = createButton(rx(2), uy(0), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
				add(buttonA = createButton(rx(1), uy(0), BTN, BTN, 'a', keybindSet('accept'), 0xFF0000));
			case NOTE_SPLASH_DEBUG:
				add(buttonB = createButton(rx(2), by(1), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
				add(buttonE = createButton(rx(1), uy(0), BTN, BTN, 'e', null, 0xFF7D00));
				add(buttonX = createButton(rx(2), uy(0), BTN, BTN, 'x', null, 0x99062D));
				add(buttonY = createButton(rx(1), uy(2), BTN, BTN, 'y', null, 0x4A35B9));
				add(buttonZ = createButton(rx(2), uy(2), BTN, BTN, 'z', null, 0xCCB98E));
				add(buttonA = createButton(rx(1), by(1), BTN, BTN, 'a', keybindSet('accept'), 0xFF0000));
				add(buttonC = createButton(rx(1), uy(1), BTN, BTN, 'c', null, 0x44FF00));
				add(buttonV = createButton(rx(2), uy(1), BTN, BTN, 'v', null, 0x49A9B2));
			case P:
				add(buttonP = createButton(rx(1), uy(0), BTN, BTN, 'x', null, 0x99062D));
			case B_C:
				add(buttonC = createButton(rx(1), by(1), BTN, BTN, 'c', null, 0x44FF00));
				add(buttonB = createButton(rx(2), by(1), BTN, BTN, 'b', keybindSet('back'), 0xFFCB00));
			case NONE: // do nothing
		}

		scrollFactor.set();
		updateTrackedButtons();
	}

	private function createButton(X:Float, Y:Float, Width:Int, Height:Int, Graphic:String,  ?IDs:Array<FlxKey> = null, ?Color:Int = 0xFFFFFF):FlxButton
	{
		var button = new FlxButton(X, Y, IDs, Graphic);
		button.loadGraphic(createHintGraphic(Width, Height));
		button.saveColor = Color;
		button.solid = false;
		button.immovable = true;
		button.moves = false;
		button.scrollFactor.set();
		button.color = Color;
		button.antialiasing = ClientPrefs.data.antialiasing;
		button.tag = Graphic.toUpperCase();
		#if FLX_DEBUG
		button.ignoreDrawDebug = true;
		#end

		button.updateLabelSize(Width, Height);

		button.onDown.callback = function()
		{
			button.color = 0xFFFFFF;
		}
		button.onUp.callback = function()
		{
			button.color = button.saveColor;
		}
		button.onOut.callback = function()
		{
			button.color = button.saveColor;
		}

		return button;
	}

	function createHintGraphic(Width:Int, Height:Int):BitmapData
	{
		var guh = ClientPrefs.data.controlsAlpha;
		return drawRect(Width, Height, Width / 3, Height / 3, 3, 0xFFFFFF);
	}

	var shape:Shape = new Shape();
	function drawRect(width:Float, height:Float, roundWidth:Float, roundHeight:Float, lineStyle:Int, lineColor:FlxColor):BitmapData
	{
		shape = new Shape();

		shape.graphics.beginFill(0xFFFFFF, 0.5);
		shape.graphics.drawRoundRect(0, 0, Std.int(width), Std.int(height), roundWidth, roundHeight);
		shape.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(Std.int(width), Std.int(height), true, 0);
		bitmap.draw(shape);
		if (lineStyle > 0) drawLine(bitmap, lineStyle, roundWidth, roundHeight, lineColor);
		return bitmap;
	}

	var lineShape:Shape = null;
    function drawLine(bitmap:BitmapData, lineStyle:Int, roundWidth:Float, roundHeight:Float, lineColor:FlxColor)
	{
		lineShape = new Shape();
		var lineSize:Int = lineStyle;
		lineShape.graphics.beginFill(lineColor);
		lineShape.graphics.lineStyle(1, lineColor, 1);
		lineShape.graphics.drawRoundRect(0, 0, bitmap.width, bitmap.height, roundWidth, roundHeight);
		lineShape.graphics.lineStyle(0, 0, 0);
		lineShape.graphics.drawRoundRect(lineSize, lineSize, bitmap.width - lineSize * 2, bitmap.height - lineSize * 2, roundWidth - lineSize * 2, roundHeight - lineSize * 2);
		lineShape.graphics.endFill();

		bitmap.draw(lineShape);
	}

	private function keybindSet(keyName:String, defaultKey:Int = 0):Array<FlxKey>
	{
		if (ClientPrefs.keyBinds.exists(keyName))
			return ClientPrefs.keyBinds.get(keyName);

		return [];
	}

	private function keyboardSet(keyName:String):Array<FlxKey>
	{
		return [InputFormatter.getFlxKey(keyName)];
	}

	override public function destroy():Void
	{
		super.destroy();

		buttonLeft = FlxDestroyUtil.destroy(buttonLeft);
		buttonUp = FlxDestroyUtil.destroy(buttonUp);
		buttonDown = FlxDestroyUtil.destroy(buttonDown);
		buttonRight = FlxDestroyUtil.destroy(buttonRight);
		buttonLeft2 = FlxDestroyUtil.destroy(buttonLeft2);
		buttonUp2 = FlxDestroyUtil.destroy(buttonUp2);
		buttonDown2 = FlxDestroyUtil.destroy(buttonDown2);
		buttonRight2 = FlxDestroyUtil.destroy(buttonRight2);
		buttonA = FlxDestroyUtil.destroy(buttonA);
		buttonB = FlxDestroyUtil.destroy(buttonB);
		buttonC = FlxDestroyUtil.destroy(buttonC);
		buttonD = FlxDestroyUtil.destroy(buttonD);
		buttonE = FlxDestroyUtil.destroy(buttonE);
		buttonF = FlxDestroyUtil.destroy(buttonF);
		buttonG = FlxDestroyUtil.destroy(buttonG);
		buttonS = FlxDestroyUtil.destroy(buttonS);
		buttonV = FlxDestroyUtil.destroy(buttonV);
		buttonX = FlxDestroyUtil.destroy(buttonX);
		buttonY = FlxDestroyUtil.destroy(buttonY);
		buttonZ = FlxDestroyUtil.destroy(buttonZ);
		buttonP = FlxDestroyUtil.destroy(buttonP);

		for (btn in extraKeys)
			FlxDestroyUtil.destroy(btn);
		extraKeys = [];
	}
}
