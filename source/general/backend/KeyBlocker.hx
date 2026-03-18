package general.backend;

import flixel.input.keyboard.FlxKey;
import lime.ui.KeyCode;

class KeyBlocker {
    public static function block(key:FlxKey):Void {
        var codes = toLimeKeyCodes(key);
        var window = FlxG.stage.window;
        
        for (code in codes) {
            if (window.disabledKeys.indexOf(code) == -1) {
                window.disabledKeys.push(code);
            }
        }
    }

    public static function unblock(key:FlxKey):Void {
        var codes = toLimeKeyCodes(key);
        var window = FlxG.stage.window;
        
        for (code in codes) {
            window.disabledKeys.remove(code);
        }
    }

    private static function toLimeKeyCodes(key:Int):Array<KeyCode> {
        // 1. 字母 A-Z (FlxKey 65-90 -> Lime 97-122)
        if (key >= 65 && key <= 90) return [key + 32];
        
        // 2. 数字 0-9 (相同)
        if (key >= 48 && key <= 57) return [key];

        // 3. F1 - F12 (FlxKey 112-123 -> Lime 0x4000003A...)
        if (key >= 112 && key <= 123) return [0x4000003A + (key - 112)];

        // 4. 小键盘数字 0-9 (FlxKey 96-105 -> Lime 乱序映射)
        // 查表法映射小键盘
        if (key >= 96 && key <= 105) {
            switch (key) {
                case 96: return [0x40000062]; // NUMPAD_0
                case 97: return [0x40000059]; // NUMPAD_1
                case 98: return [0x4000005A]; // NUMPAD_2
                case 99: return [0x4000005B]; // NUMPAD_3
                case 100: return [0x4000005C]; // NUMPAD_4
                case 101: return [0x4000005D]; // NUMPAD_5
                case 102: return [0x4000005E]; // NUMPAD_6
                case 103: return [0x4000005F]; // NUMPAD_7
                case 104: return [0x40000060]; // NUMPAD_8
                case 105: return [0x40000061]; // NUMPAD_9
            }
        }

        // 5. 特殊键映射
        return switch (key) {
            // --- 常用控制键 ---
            case 32: [KeyCode.SPACE]; // 32
            case 13: [KeyCode.RETURN]; // 13
            case 27: [KeyCode.ESCAPE]; // 27
            case 8:  [KeyCode.BACKSPACE]; // 8
            case 9:  [KeyCode.TAB]; // 9
            
            // --- 方向键 (Lime 偏移量很大) ---
            case 37: [0x40000050]; // LEFT
            case 38: [0x40000052]; // UP
            case 39: [0x4000004F]; // RIGHT
            case 40: [0x40000051]; // DOWN
            
            // --- 导航键 ---
            case 45: [0x40000049]; // INSERT
            case 46: [0x7F];       // DELETE (Lime 使用 ASCII DEL)
            case 36: [0x4000004A]; // HOME
            case 35: [0x4000004D]; // END
            case 33: [0x4000004B]; // PAGEUP
            case 34: [0x4000004E]; // PAGEDOWN
            
            // --- 修饰键 (同时禁用左右) ---
            case 16: [0x400000E1, 0x400000E5]; // SHIFT -> LEFT_SHIFT, RIGHT_SHIFT
            case 17: [0x400000E0, 0x400000E4]; // CONTROL -> LEFT_CTRL, RIGHT_CTRL
            case 18: [0x400000E2, 0x400000E6]; // ALT -> LEFT_ALT, RIGHT_ALT
            
            // --- 符号键 (FlxKey VK -> Lime ASCII) ---
            // 注意：FlxKey 的 187/189 等是 Windows 键码，Lime 用 ASCII
            case 189: [KeyCode.MINUS];        // - (45)
            case 187: [KeyCode.EQUALS];       // = (61) (注意：+号键不按Shift通常是=)
            case 219: [KeyCode.LEFT_BRACKET]; // [ (91)
            case 221: [KeyCode.RIGHT_BRACKET];// ] (93)
            case 220: [KeyCode.BACKSLASH];    // \ (92)
            case 186: [KeyCode.SEMICOLON];    // ; (59)
            case 222: [KeyCode.SINGLE_QUOTE]; // ' (39) (注意：Lime区分单双引号，键通常是单引号)
            case 188: [KeyCode.COMMA];        // , (44)
            case 190: [KeyCode.PERIOD];       // . (46)
            case 191: [KeyCode.SLASH];        // / (47)
            case 192: [KeyCode.GRAVE];        // ` (96)
            
            // --- 其他 ---
            case 20:  [0x40000039]; // CAPS_LOCK
            case 144: [0x40000053]; // NUM_LOCK
            case 145: [0x40000047]; // SCROLL_LOCK
            case 301: [0x40000046]; // PRINT_SCREEN
            case 302: [0x40000065]; // MENU (APPLICATION)
            case 15:  [0x400000E3, 0x400000E7]; // WINDOWS (META)
            
            // --- 小键盘符号 ---
            case 106: [0x40000055]; // NUMPAD_MULTIPLY
            case 107: [0x40000057]; // NUMPAD_PLUS
            case 109: [0x40000056]; // NUMPAD_MINUS
            case 110: [0x40000063]; // NUMPAD_PERIOD
            case 111: [0x40000054]; // NUMPAD_SLASH (DIVIDE)

            // 默认作为兜底
            default: [key];
        }
    }
}