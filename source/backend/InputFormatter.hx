package backend;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;

class InputFormatter
{
	public static function getKeyName(key:FlxKey):String
	{
		switch (key)
		{
			case NONE: return "---";
			case A: return "A";
			case B: return "B";
			case C: return "C";
			case D: return "D";
			case E: return "E";
			case F: return "F";
			case G: return "G";
			case H: return "H";
			case I: return "I";
			case J: return "J";
			case K: return "K";
			case L: return "L";
			case M: return "M";
			case N: return "N";
			case O: return "O";
			case P: return "P";
			case Q: return "Q";
			case R: return "R";
			case S: return "S";
			case T: return "T";
			case U: return "U";
			case V: return "V";
			case W: return "W";
			case X: return "X";
			case Y: return "Y";
			case Z: return "Z";
			case ZERO: return "0";
			case ONE: return "1";
			case TWO: return "2";
			case THREE: return "3";
			case FOUR: return "4";
			case FIVE: return "5";
			case SIX: return "6";
			case SEVEN: return "7";
			case EIGHT: return "8";
			case NINE: return "9";
			case PAGEUP: return "PgUp";
			case PAGEDOWN: return "PgDown";
			case HOME: return "Home";
			case END: return "End";
			case INSERT: return "Ins";
			case ESCAPE: return "Esc";
			case MINUS: return "-";
			case PLUS: return "+";
			case DELETE: return "Del";
			case BACKSPACE: return "BckSpc";
			case LBRACKET: return "[";
			case RBRACKET: return "]";
			case BACKSLASH: return "\\";
			case CAPSLOCK: return "Caps";
			case SCROLL_LOCK: return "ScrLk";
			case NUMLOCK: return "NumLk";
			case SEMICOLON: return ";";
			case QUOTE: return "'";
			case ENTER: return "Enter";
			case SHIFT: return "Shift";
			case COMMA: return ",";
			case PERIOD: return ".";
			case SLASH: return "/";
			case GRAVEACCENT: return "`";
			case CONTROL: return "Ctrl";
			case ALT: return "Alt";
			case SPACE: return "Space";
			case UP: return "Up";
			case DOWN: return "Down";
			case LEFT: return "Left";
			case RIGHT: return "Right";
			case TAB: return "Tab";
			case WINDOWS: return "Win";
			case MENU: return "Menu";
			case PRINTSCREEN: return "PrtScrn";
			case BREAK: return "Break";
			case F1: return "F1";
			case F2: return "F2";
			case F3: return "F3";
			case F4: return "F4";
			case F5: return "F5";
			case F6: return "F6";
			case F7: return "F7";
			case F8: return "F8";
			case F9: return "F9";
			case F10: return "F10";
			case F11: return "F11";
			case F12: return "F12";
			case NUMPADZERO: return "#0";
			case NUMPADONE: return "#1";
			case NUMPADTWO: return "#2";
			case NUMPADTHREE: return "#3";
			case NUMPADFOUR: return "#4";
			case NUMPADFIVE: return "#5";
			case NUMPADSIX: return "#6";
			case NUMPADSEVEN: return "#7";
			case NUMPADEIGHT: return "#8";
			case NUMPADNINE: return "#9";
			case NUMPADMINUS: return "#-";
			case NUMPADPLUS: return "#+";
			case NUMPADPERIOD: return "#.";
			case NUMPADMULTIPLY: return "#*";
			case NUMPADSLASH: return "#/";
			default:
				var label:String = Std.string(key);
				if (label.toLowerCase() == 'null')
					return '---';

				var arr:Array<String> = label.split('_');
				for (i in 0...arr.length)
					arr[i] = CoolUtil.capitalize(arr[i]);
				return arr.join(' ');
		}
	}

	public static function getFlxKey(name:String):FlxKey
	{
		switch (name)
		{
			case "---": return NONE;
			case "A": return A;
			case "B": return B;
			case "C": return C;
			case "D": return D;
			case "E": return E;
			case "F": return F;
			case "G": return G;
			case "H": return H;
			case "I": return I;
			case "J": return J;
			case "K": return K;
			case "L": return L;
			case "M": return M;
			case "N": return N;
			case "O": return O;
			case "P": return P;
			case "Q": return Q;
			case "R": return R;
			case "S": return S;
			case "T": return T;
			case "U": return U;
			case "V": return V;
			case "W": return W;
			case "X": return X;
			case "Y": return Y;
			case "Z": return Z;
			case "0": return ZERO;
			case "1": return ONE;
			case "2": return TWO;
			case "3": return THREE;
			case "4": return FOUR;
			case "5": return FIVE;
			case "6": return SIX;
			case "7": return SEVEN;
			case "8": return EIGHT;
			case "9": return NINE;
			case "PgUp": return PAGEUP;
			case "PgDown": return PAGEDOWN;
			case "Home": return HOME;
			case "End": return END;
			case "Ins": return INSERT;
			case "Esc": return ESCAPE;
			case "-": return MINUS;
			case "+": return PLUS;
			case "Del": return DELETE;
			case "BckSpc": return BACKSPACE;
			case "[": return LBRACKET;
			case "]": return RBRACKET;
			case "\\": return BACKSLASH;
			case "Caps": return CAPSLOCK;
			case "ScrLk": return SCROLL_LOCK;
			case "NumLk": return NUMLOCK;
			case ";": return SEMICOLON;
			case "'": return QUOTE;
			case "Enter": return ENTER;
			case "Shift": return SHIFT;
			case ",": return COMMA;
			case ".": return PERIOD;
			case "/": return SLASH;
			case "`": return GRAVEACCENT;
			case "Ctrl": return CONTROL;
			case "Alt": return ALT;
			case "Space": return SPACE;
			case "Up": return UP;
			case "Down": return DOWN;
			case "Left": return LEFT;
			case "Right": return RIGHT;
			case "Tab": return TAB;
			case "Win": return WINDOWS;
			case "Menu": return MENU;
			case "PrtScrn": return PRINTSCREEN;
			case "Break": return BREAK;
			case "F1": return F1;
			case "F2": return F2;
			case "F3": return F3;
			case "F4": return F4;
			case "F5": return F5;
			case "F6": return F6;
			case "F7": return F7;
			case "F8": return F8;
			case "F9": return F9;
			case "F10": return F10;
			case "F11": return F11;
			case "F12": return F12;
			case "#0": return NUMPADZERO;
			case "#1": return NUMPADONE;
			case "#2": return NUMPADTWO;
			case "#3": return NUMPADTHREE;
			case "#4": return NUMPADFOUR;
			case "#5": return NUMPADFIVE;
			case "#6": return NUMPADSIX;
			case "#7": return NUMPADSEVEN;
			case "#8": return NUMPADEIGHT;
			case "#9": return NUMPADNINE;
			case "#-": return NUMPADMINUS;
			case "#+": return NUMPADPLUS;
			case "#.": return NUMPADPERIOD;
			case "#*": return NUMPADMULTIPLY;
			case "#/": return NUMPADSLASH;
			default: return FlxKey.fromString(name);
		}
	}

	public static function getGamepadName(key:FlxGamepadInputID)
	{
		var gamepad:FlxGamepad = FlxG.gamepads.firstActive;
		var model:FlxGamepadModel = gamepad != null ? gamepad.detectedModel : UNKNOWN;

		switch (key)
		{
			// Analogs
			case LEFT_STICK_DIGITAL_LEFT:
				return "Left";
			case LEFT_STICK_DIGITAL_RIGHT:
				return "Right";
			case LEFT_STICK_DIGITAL_UP:
				return "Up";
			case LEFT_STICK_DIGITAL_DOWN:
				return "Down";
			case LEFT_STICK_CLICK:
				switch (model)
				{
					case PS4: return "L3";
					case XINPUT: return "LS";
					default: return "Analog Click";
				}

			case RIGHT_STICK_DIGITAL_LEFT:
				return "C. Left";
			case RIGHT_STICK_DIGITAL_RIGHT:
				return "C. Right";
			case RIGHT_STICK_DIGITAL_UP:
				return "C. Up";
			case RIGHT_STICK_DIGITAL_DOWN:
				return "C. Down";
			case RIGHT_STICK_CLICK:
				switch (model)
				{
					case PS4: return "R3";
					case XINPUT: return "RS";
					default: return "C. Click";
				}

			// Directional
			case DPAD_LEFT:
				return "D. Left";
			case DPAD_RIGHT:
				return "D. Right";
			case DPAD_UP:
				return "D. Up";
			case DPAD_DOWN:
				return "D. Down";

			// Top buttons
			case LEFT_SHOULDER:
				switch (model)
				{
					case PS4: return "L1";
					case XINPUT: return "LB";
					default: return "L. Bumper";
				}
			case RIGHT_SHOULDER:
				switch (model)
				{
					case PS4: return "R1";
					case XINPUT: return "RB";
					default: return "R. Bumper";
				}
			case LEFT_TRIGGER, LEFT_TRIGGER_BUTTON:
				switch (model)
				{
					case PS4: return "L2";
					case XINPUT: return "LT";
					default: return "L. Trigger";
				}
			case RIGHT_TRIGGER, RIGHT_TRIGGER_BUTTON:
				switch (model)
				{
					case PS4: return "R2";
					case XINPUT: return "RT";
					default: return "R. Trigger";
				}

			// Buttons
			case A:
				switch (model)
				{
					case PS4: return "X";
					case XINPUT: return "A";
					default: return "Action Down";
				}
			case B:
				switch (model)
				{
					case PS4: return "O";
					case XINPUT: return "B";
					default: return "Action Right";
				}
			case X:
				switch (model)
				{
					case PS4: return "["; // This gets its image changed through code
					case XINPUT: return "X";
					default: return "Action Left";
				}
			case Y:
				switch (model)
				{
					case PS4: return "]"; // This gets its image changed through code
					case XINPUT: return "Y";
					default: return "Action Up";
				}

			case BACK:
				switch (model)
				{
					case PS4: return "Share";
					case XINPUT: return "Back";
					default: return "Select";
				}
			case START:
				switch (model)
				{
					case PS4: return "Options";
					default: return "Start";
				}

			case NONE:
				return '---';

			default:
				var label:String = Std.string(key);
				if (label.toLowerCase() == 'null')
					return '---';

				var arr:Array<String> = label.split('_');
				for (i in 0...arr.length)
					arr[i] = CoolUtil.capitalize(arr[i]);
				return arr.join(' ');
		}
	}
}
