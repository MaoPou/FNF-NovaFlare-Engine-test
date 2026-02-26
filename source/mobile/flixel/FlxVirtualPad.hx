package mobile.flixel;

import flixel.graphics.frames.FlxTileFrames;
import flixel.input.keyboard.FlxKey;

import mobile.flixel.input.FlxMobileInputManager;
import mobile.flixel.FlxButton;

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

	/**
	 * Create a gamepad.
	 *
	 * @param   DPadMode     The D-Pad mode. `LEFT_FULL` for example.
	 * @param   ActionMode   The action buttons mode. `A_B_C` for example.
	 */
	public function new(DPad:FlxDPadMode, Action:FlxActionMode)
	{
		super();

		switch (DPad)
		{
			case UP_DOWN:
				add(buttonUp = createButton(0, FlxG.height - 255, 132, 127, 'up', keyboardSet('ui_up'), 0xFF12FA05));
				add(buttonDown = createButton(0, FlxG.height - 135, 132, 127, 'down', keyboardSet('ui_down'), 0xFF00FFFF));
			case LEFT_RIGHT:
				add(buttonLeft = createButton(0, FlxG.height - 135, 132, 127, 'left', keyboardSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(127, FlxG.height - 135, 132, 127, 'right', keyboardSet('ui_right'), 0xFFF9393F));
			case UP_LEFT_RIGHT:
				add(buttonUp = createButton(105, FlxG.height - 243, 132, 127, 'up', keyboardSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, FlxG.height - 135, 132, 127, 'left', keyboardSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(207, FlxG.height - 135, 132, 127, 'right', keyboardSet('ui_right'), 0xFFF9393F));
			case LEFT_FULL:
				add(buttonUp = createButton(105, FlxG.height - 345, 132, 127, 'up', keyboardSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, FlxG.height - 243, 132, 127, 'left', keyboardSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(207, FlxG.height - 243, 132, 127, 'right', keyboardSet('ui_right'), 0xFFF9393F));
				add(buttonDown = createButton(105, FlxG.height - 135, 132, 127, 'down', keyboardSet('ui_down'), 0xFF00FFFF));
			case LEFT_FULL_GAME:
				add(buttonUp = createButton(105, FlxG.height - 345, 132, 127, 'up', keyboardSet('note_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, FlxG.height - 243, 132, 127, 'left', keyboardSet('note_left'), 0xFFC24B99));
				add(buttonRight = createButton(207, FlxG.height - 243, 132, 127, 'right', keyboardSet('note_right'), 0xFFF9393F));
				add(buttonDown = createButton(105, FlxG.height - 135, 132, 127, 'down', keyboardSet('note_down'), 0xFF00FFFF));
			case RIGHT_FULL:
				add(buttonUp = createButton(FlxG.width - 258, FlxG.height - 408, 132, 127, 'up', keyboardSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(FlxG.width - 384, FlxG.height - 309, 132, 127, 'left', keyboardSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(FlxG.width - 132, FlxG.height - 309, 132, 127, 'right', keyboardSet('ui_right'), 0xFFF9393F));
				add(buttonDown = createButton(FlxG.width - 258, FlxG.height - 201, 132, 127, 'down', keyboardSet('ui_down'), 0xFF00FFFF));
			case RIGHT_FULL_GAME:
				add(buttonUp = createButton(FlxG.width - 258, FlxG.height - 408, 132, 127, 'up', keyboardSet('note_up'), 0xFF12FA05));
				add(buttonLeft = createButton(FlxG.width - 384, FlxG.height - 309, 132, 127, 'left', keyboardSet('note_left'), 0xFFC24B99));
				add(buttonRight = createButton(FlxG.width - 132, FlxG.height - 309, 132, 127, 'right', keyboardSet('note_right'), 0xFFF9393F));
				add(buttonDown = createButton(FlxG.width - 258, FlxG.height - 201, 132, 127, 'down', keyboardSet('note_down'), 0xFF00FFFF));
			case BOTH:
				add(buttonUp = createButton(105, FlxG.height - 345, 132, 127, 'up', keyboardSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, FlxG.height - 243, 132, 127, 'left', keyboardSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(207, FlxG.height - 243, 132, 127, 'right', keyboardSet('ui_right'), 0xFFF9393F));
				add(buttonDown = createButton(105, FlxG.height - 135, 132, 127, 'down', keyboardSet('ui_down'), 0xFF00FFFF));
				add(buttonUp2 = createButton(FlxG.width - 258, FlxG.height - 408, 132, 127, 'up', keyboardSet('ui_up'), 0xFF12FA05));
				add(buttonLeft2 = createButton(FlxG.width - 384, FlxG.height - 309, 132, 127, 'left', keyboardSet('ui_left'), 0xFFC24B99));
				add(buttonRight2 = createButton(FlxG.width - 132, FlxG.height - 309, 132, 127, 'right', keyboardSet('ui_right'), 0xFFF9393F));
				add(buttonDown2 = createButton(FlxG.width - 258, FlxG.height - 201, 132, 127, 'down', keyboardSet('ui_down'), 0xFF00FFFF));
			case BOTH_GAME:
				add(buttonUp = createButton(105, FlxG.height - 345, 132, 127, 'up', keyboardSet('note_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, FlxG.height - 243, 132, 127, 'left', keyboardSet('note_left'), 0xFFC24B99));
				add(buttonRight = createButton(207, FlxG.height - 243, 132, 127, 'right', keyboardSet('note_right'), 0xFFF9393F));
				add(buttonDown = createButton(105, FlxG.height - 135, 132, 127, 'down', keyboardSet('note_down'), 0xFF00FFFF));
				add(buttonUp2 = createButton(FlxG.width - 258, FlxG.height - 408, 132, 127, 'up', keyboardSet('note_up', 1), 0xFF12FA05));
				add(buttonLeft2 = createButton(FlxG.width - 384, FlxG.height - 309, 132, 127, 'left', keyboardSet('note_left', 1), 0xFFC24B99));
				add(buttonRight2 = createButton(FlxG.width - 132, FlxG.height - 309, 132, 127, 'right', keyboardSet('note_right', 1), 0xFFF9393F));
				add(buttonDown2 = createButton(FlxG.width - 258, FlxG.height - 201, 132, 127, 'down', keyboardSet('note_down', 1), 0xFF00FFFF));
			case PauseSubstateC:
				add(buttonUp = createButton(0, FlxG.height - 85 * 3, 44 * 3, 127, "up", keyboardSet('ui_up'), 0x00FF00));
				add(buttonDown = createButton(0, FlxG.height - 45 * 3, 44 * 3, 127, "down", keyboardSet('ui_down'), 0x00FFFF));
				add(buttonLeft = createButton(42 * 3, FlxG.height - 45 * 3, 44 * 3, 127, "left", keyboardSet('ui_left'), 0xFF00FF));
				add(buttonRight = createButton(84 * 3, FlxG.height - 45 * 3, 44 * 3, 127, "right", keyboardSet('ui_right'), 0xFF0000));
			case OptionStateC:
				add(buttonUp = createButton(0, FlxG.height - 85 * 3, 44 * 3, 127, "up", keyboardSet('ui_up'), 0x00FF00));
				add(buttonDown = createButton(0, FlxG.height - 45 * 3, 44 * 3, 127, "down", keyboardSet('ui_down'), 0x00FFFF));
			case MainMenuStateC:
				add(buttonUp = createButton(FlxG.width - 44 * 3, FlxG.height - 165 * 3, 44 * 3, 127, 'up', keyboardSet('ui_up'), 0xFF12FA05));
				add(buttonDown = createButton(FlxG.width - 44 * 3, FlxG.height - 125 * 3, 44 * 3, 127, 'down', keyboardSet('ui_down'), 0xFF00FFFF));
			case ChartingStateC:
				add(buttonUp = createButton(0, FlxG.height - 85 * 3, 132, 127, 'up', keyboardSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(132, FlxG.height - 85 * 3, 132, 127, 'left', keyboardSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(132, FlxG.height - 45 * 3, 132, 127, 'right', keyboardSet('ui_right'), 0xFFF9393F));
				add(buttonDown = createButton(0, FlxG.height - 45 * 3, 132, 127, 'down', keyboardSet('ui_down'), 0xFF00FFFF));
			case DIALOGUE_PORTRAIT:
				add(buttonUp = createButton(105, FlxG.height - 345, 132, 127, 'up', keyboardSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, FlxG.height - 243, 132, 127, 'left', keyboardSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(207, FlxG.height - 243, 132, 127, 'right', keyboardSet('ui_right'), 0xFFF9393F));
				add(buttonDown = createButton(105, FlxG.height - 135, 132, 127, 'down', keyboardSet('ui_down'), 0xFF00FFFF));
				add(buttonUp2 = createButton(105, 0, 132, 127, 'up', keyboardSet('ui_up'), 0xFF12FA05));
				add(buttonLeft2 = createButton(0, 82, 132, 127, 'left', keyboardSet('ui_left'), 0xFFC24B99));
				add(buttonRight2 = createButton(207, 82, 132, 127, 'right', keyboardSet('ui_right'), 0xFFF9393F));
				add(buttonDown2 = createButton(105, 190, 132, 127, 'down', keyboardSet('ui_down'), 0xFF00FFFF));
			case MENU_CHARACTER:
				add(buttonUp = createButton(105, 0, 132, 127, 'up', keyboardSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, 82, 132, 127, 'left', keyboardSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(207, 82, 132, 127, 'right', keyboardSet('ui_right'), 0xFFF9393F));
				add(buttonDown = createButton(105, 190, 132, 127, 'down', keyboardSet('ui_down'), 0xFF00FFFF));
			case NOTE_SPLASH_DEBUG:
				add(buttonUp = createButton(0, 125, 132, 127, 'up', keyboardSet('ui_up'), 0xFF12FA05));
				add(buttonLeft = createButton(0, 0, 132, 127, 'left', keyboardSet('ui_left'), 0xFFC24B99));
				add(buttonRight = createButton(127, 0, 132, 127, 'right', keyboardSet('ui_right'), 0xFFF9393F));
				add(buttonDown = createButton(127, 125, 132, 127, 'down', keyboardSet('ui_down'), 0xFF00FFFF));
				add(buttonUp2 = createButton(127, 393, 132, 127, 'up', keyboardSet('ui_up', 1), 0xFF12FA05));
				add(buttonLeft2 = createButton(0, 393, 132, 127, 'left', keyboardSet('ui_left', 1), 0xFFC24B99));
				add(buttonRight2 = createButton(1145, 393, 132, 127, 'right', keyboardSet('ui_right', 1), 0xFFF9393F));
				add(buttonDown2 = createButton(1015, 393, 132, 127, 'down', keyboardSet('ui_down', 1), 0xFF00FFFF));
			case NONE: // do nothing
		}

		switch (Action)
		{
			case A:
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', keyboardSet('accept'), 0xFF0000));
			case B:
				add(buttonB = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
			case B_X:
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
				add(buttonX = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'x', 0x99062D));
			case A_B:
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', keyboardSet('accept'), 0xFF0000));
			case A_B_C:
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', keyboardSet('accept'), 0xFF0000));
			case A_B_E:
				add(buttonE = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'e', 0xFF7D00));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', keyboardSet('accept'), 0xFF0000));
			case A_B_X_Y:
				add(buttonX = createButton(FlxG.width - 510, FlxG.height - 135, 132, 127, 'x', 0x99062D));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
				add(buttonY = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'y', 0x4A35B9));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', keyboardSet('accept'), 0xFF0000));
			case A_B_C_X_Y:
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonX = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'x', 0x99062D));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
				add(buttonY = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'y', 0x4A35B9));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', keyboardSet('accept'), 0xFF0000));
			case A_B_C_X_Y_Z:
				add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 132, 127, 'x', 0x99062D));
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'y', 0x4A35B9));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
				add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', keyboardSet('accept'), 0xFF0000));
			case A_B_C_D_V_X_Y_Z:
				add(buttonV = createButton(FlxG.width - 510, FlxG.height - 255, 132, 127, 'v', 0x49A9B2));
				add(buttonD = createButton(FlxG.width - 510, FlxG.height - 135, 132, 127, 'd', 0x0078FF));
				add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 132, 127, 'x', 0x99062D));
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'y', 0x4A35B9));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
				add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', keyboardSet('accept'), 0xFF0000));
			case controlExtend:
				
			case OptionStateC:
				add(buttonLeft = createButton(FlxG.width - 258, FlxG.height - 85 * 3, 44 * 3, 127, "left", 0xFF00FF));
				add(buttonRight = createButton(FlxG.width - 132, FlxG.height - 85 * 3, 44 * 3, 127, "right", 0xFF0000));
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', keyboardSet('accept'), 0xFF0000));
			case ChartingStateC:
				add(buttonS = createButton(FlxG.width - 132, FlxG.height - 375, 132, 127, 's', 0x49A9B2));
				add(buttonG = createButton(FlxG.width - (44 + 42 * 1) * 3, 25, 132, 127, 'g', 0x49A9B2));
				add(buttonP = createButton(FlxG.width - 636, FlxG.height - 255, 132, 127, 'up', 0x49A9B2));
				add(buttonE = createButton(FlxG.width - 636, FlxG.height - 135, 132, 127, 'down', 0x49A9B2));
				add(buttonV = createButton(FlxG.width - 510, FlxG.height - 255, 132, 127, 'v', 0x49A9B2));
				add(buttonD = createButton(FlxG.width - 510, FlxG.height - 135, 132, 127, 'd', 0x0078FF));
				add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 132, 127, 'x', 0x99062D));
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'y', 0x4A35B9));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
				add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', keyboardSet('accept'), 0xFF0000));
			case CHARACTER_EDITOR:
				add(buttonV = createButton(FlxG.width - 510, FlxG.height - 255, 132, 127, 'v', 0x49A9B2));
				add(buttonD = createButton(FlxG.width - 510, FlxG.height - 135, 132, 127, 'd', 0x0078FF));
				add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 132, 127, 'x', 0x99062D));
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonS = createButton(FlxG.width - 636, FlxG.height - 135, 132, 127, 's', 0xEA00FF));
				add(buttonG = createButton(FlxG.width - 636, FlxG.height - 255, 132, 127, 'g', 0xEA00FF));
				add(buttonF = createButton(FlxG.width - 410, 0, 132, 127, 'f', 0xFF009D));
				add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'y', 0x4A35B9));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
				add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', keyboardSet('accept'), 0xFF0000));
			case DIALOGUE_PORTRAIT:
				add(buttonX = createButton(FlxG.width - 384, 0, 132, 127, 'x', 0x99062D));
				add(buttonC = createButton(FlxG.width - 384, 125, 132, 127, 'c', 0x44FF00));
				add(buttonY = createButton(FlxG.width - 258, 0, 132, 127, 'y', 0x4A35B9));
				add(buttonB = createButton(FlxG.width - 258, 125, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
				add(buttonZ = createButton(FlxG.width - 132, 0, 132, 127, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, 125, 132, 127, 'a', keyboardSet('accept'), 0xFF0000));
			case MENU_CHARACTER:
				add(buttonC = createButton(FlxG.width - 384, 0, 132, 127, 'c', 0x44FF00));
				add(buttonB = createButton(FlxG.width - 258, 0, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, 0, 132, 127, 'a', keyboardSet('accept'), 0xFF0000));
			case NOTE_SPLASH_DEBUG:
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
				add(buttonE = createButton(FlxG.width - 132, 0, 132, 127, 'e', 0xFF7D00));
				add(buttonX = createButton(FlxG.width - 258, 0, 132, 127, 'x', 0x99062D));
				add(buttonY = createButton(FlxG.width - 132, 250, 132, 127, 'y', 0x4A35B9));
				add(buttonZ = createButton(FlxG.width - 258, 250, 132, 127, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', keyboardSet('accept'), 0xFF0000));
				add(buttonC = createButton(FlxG.width - 132, 125, 132, 127, 'c', 0x44FF00));
				add(buttonV = createButton(FlxG.width - 258, 125, 132, 127, 'v', 0x49A9B2));
			case P:
				add(buttonP = createButton(FlxG.width - 132, 0, 132, 127, 'x', 0x99062D));
			case B_C:
				add(buttonC = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', keyboardSet('back'), 0xFFCB00));
			case NONE: // do nothing
		}

		scrollFactor.set();
		updateTrackedButtons();
	}

	private function createButton(X:Float, Y:Float, Width:Int, Height:Int, Graphic:String,  ?IDs:Array<FlxKey> = null, ?Color:Int = 0xFFFFFF):FlxButton
	{
		var button = new FlxButton(X, Y, IDs);
		button.frames = FlxTileFrames.fromFrame(Paths.getSparrowAtlas('virtualpad').getByName(Graphic), FlxPoint.get(Width, Height));
		button.resetSizeFromFrame();
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
		return button;
	}

	private function keyboardSet(keyName:String, defaultKey:Int = 0):Array<FlxKey>
	{
		if (ClientPrefs.keyBinds.exists(keyName))
			return ClientPrefs.keyBinds.get(keyName);

		return [];
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
	}
}
