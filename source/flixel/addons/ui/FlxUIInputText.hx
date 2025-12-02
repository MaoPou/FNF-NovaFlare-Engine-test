package flixel.addons.ui;

import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.addons.ui.interfaces.IResizable;
import flixel.util.FlxColor;
import openfl.Lib;
import lime.math.Rectangle;

/**
 * @author Lars Doucet
 */
class FlxUIInputText extends FlxInputText implements IResizable implements IFlxUIWidget implements IHasParams
{
    public var name:String;

    public var broadcastToFlxUI:Bool = true;

	public static inline var CHANGE_EVENT:String = "change_input_text"; // change in any way
	public static inline var ENTER_EVENT:String = "enter_input_text"; // hit enter in this text field
	public static inline var DELETE_EVENT:String = "delete_input_text"; // delete text in this text field
	public static inline var INPUT_EVENT:String = "input_input_text"; // input text in this text field
	public static inline var COPY_EVENT:String = "copy_input_text"; // copy text in this text field
	public static inline var PASTE_EVENT:String = "paste_input_text"; // paste text in this text field
    public static inline var CUT_EVENT:String = "cut_input_text"; // cut text in this text field

    var _composing:Bool = false;
    var _compBackupText:String = null;
    var _compBackupCaret:Int = -1;
    var _compPreviewText:String = null;

    public function new(X:Float = 0, Y:Float = 0, Width:Int = 150, ?Text:String, size:Int = 8, TextColor:Int = FlxColor.BLACK,
            BackgroundColor:Int = FlxColor.WHITE, EmbeddedFont:Bool = true)
    {
        super(X, Y, Width, Text, size, TextColor, BackgroundColor, EmbeddedFont);
        #if (lime >= "7.0")
        Lib.application.window.onTextInput.add(_handleTextInput);
        Lib.application.window.onTextEdit.add(_handleTextEditing);
        #end
    }

	public function resize(w:Float, h:Float):Void
	{
		width = w;
		height = h;
		calcFrame();
	}

    private override function onChange(action:String):Void
    {
        super.onChange(action);
        if (broadcastToFlxUI)
        {
			switch (action)
			{
				case FlxInputText.ENTER_ACTION: // press enter
					FlxUI.event(ENTER_EVENT, this, text, params);
				case FlxInputText.DELETE_ACTION, FlxInputText.BACKSPACE_ACTION: // deleted some text
					FlxUI.event(DELETE_EVENT, this, text, params);
					FlxUI.event(CHANGE_EVENT, this, text, params);
				case FlxInputText.INPUT_ACTION: // text was input
					FlxUI.event(INPUT_EVENT, this, text, params);
					FlxUI.event(CHANGE_EVENT, this, text, params);
				case FlxInputText.COPY_ACTION: // text was copied
					FlxUI.event(COPY_EVENT, this, text, params);
				case FlxInputText.PASTE_ACTION: // text was pasted
					FlxUI.event(PASTE_EVENT, this, text, params);
					FlxUI.event(CHANGE_EVENT, this, text, params);
				case FlxInputText.CUT_ACTION: // text was cut
					FlxUI.event(CUT_EVENT, this, text, params);
					FlxUI.event(CHANGE_EVENT, this, text, params);
            }
        }
    }

    private function _handleTextInput(t:String):Void
    {
        if (!hasFocus)
            return;
        if (t == null || t.length == 0)
            return;
        var toInsert = _filterIME(t);
        if (toInsert.length == 0)
            return;
        var allowed = toInsert;
        if (maxLength > 0)
        {
            var remain = Std.int(Math.max(0, maxLength - text.length));
            if (remain <= 0)
                return;
            allowed = toInsert.substr(0, remain);
        }
        var baseText = (_composing && _compBackupText != null) ? _compBackupText : text;
        var baseCaret = (_composing && _compBackupCaret >= 0) ? _compBackupCaret : caretIndex;
        text = baseText.substring(0, baseCaret) + allowed + baseText.substring(baseCaret);
        caretIndex = baseCaret + allowed.length;
        _composing = false;
        FlxInputText.imeComposing = false;
        _compBackupText = null;
        _compBackupCaret = -1;
        _compPreviewText = null;
        onChange(FlxInputText.INPUT_ACTION);
    }

    private function _handleTextEditing(t:String, start:Int, length:Int):Void
    {
        if (!hasFocus)
            return;
        if (!_composing)
        {
            _compBackupText = text;
            _compBackupCaret = caretIndex;
        }
        var preview = t == null ? "" : t;
        _compPreviewText = preview;
        text = _compBackupText.substring(0, _compBackupCaret) + preview + _compBackupText.substring(_compBackupCaret);
        caretIndex = _compBackupCaret + preview.length;
        onChange(FlxInputText.INPUT_ACTION);
        _composing = true;
        FlxInputText.imeComposing = true;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (hasFocus)
            _updateTextInputRect();
    }

    private function _filterIME(text:String):String
    {
        if (forceCase == FlxInputText.UPPER_CASE)
            text = text.toUpperCase();
        else if (forceCase == FlxInputText.LOWER_CASE)
            text = text.toLowerCase();

        if (filterMode != FlxInputText.NO_FILTER)
        {
            var pattern:EReg;
            switch (filterMode)
            {
                case FlxInputText.ONLY_ALPHA:
                    pattern = ~/[^a-zA-Z]*/g;
                case FlxInputText.ONLY_NUMERIC:
                    pattern = ~/[^0-9]*/g;
                case FlxInputText.ONLY_ALPHANUMERIC:
                    pattern = ~/[^a-zA-Z0-9]*/g;
                case FlxInputText.CUSTOM_FILTER:
                    pattern = customFilterPattern;
                default:
                    pattern = null;
            }
            if (pattern != null)
                text = pattern.replace(text, "");
        }
        return text;
    }

    inline function _updateTextInputRect():Void
    {
        var win = Lib.application.window;
        try {
            var p = getScreenPosition(camera);
            var rect = new Rectangle(Std.int(p.x), Std.int(p.y + height), Std.int(width), Std.int(height));
            win.setTextInputRect(rect);
        } catch (e:Dynamic) {}
    }

    override public function destroy():Void
    {
        #if (lime >= "7.0")
        Lib.application.window.onTextInput.remove(_handleTextInput);
        Lib.application.window.onTextEdit.remove(_handleTextEditing);
        #end
        super.destroy();
    }
}
