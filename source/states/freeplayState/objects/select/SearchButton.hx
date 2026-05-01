package states.freeplayState.objects.select;

class SearchButton extends FlxSpriteGroup {
    var bg:FlxSprite;
    var search:PsychUIInputText;
    var tapText:FlxText;
    
    public var onSearchChange:String->Void;
    var timer:FlxTimer = null;

    public function new(x:Float, y:Float) {
        super(x, y);

        bg = new FlxSprite().loadGraphic(Paths.image(FreeplayState.filePath + 'searchButton'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        add(bg);
        
        search = new PsychUIInputText(13, 8, Std.int(bg.width - 90), '', Std.int(bg.height / 2));
		search.bg.visible = false;
		search.behindText.alpha = 0;
		search.textObj.font = Paths.font(Language.get('fontName', 'ma') + '.ttf');
		search.textObj.antialiasing = ClientPrefs.data.antialiasing;
		search.textObj.color = FlxColor.WHITE;
		search.caret.color = 0x727E7E7E;
        add(search);

        tapText = new FlxText(13, 0, 0, 'Tap to search', Std.int(bg.height / 2));
        tapText.font = Paths.font(Language.get('fontName', 'ma') + '.ttf');
        tapText.antialiasing = ClientPrefs.data.antialiasing;
        tapText.alpha = 0.6;
        tapText.y += (bg.height - tapText.height) / 2;
        add(tapText);

        search.onChange = function(old:String, cur:String) {
            if (cur == '')
                tapText.visible = true;
            else
                tapText.visible = false;
            startSearch(cur);
        }
    }

    public function startSearch(text:String) {
        if (timer != null) timer.cancel();
        timer = new FlxTimer().start(0.3, function(tmr:FlxTimer) {
            if (onSearchChange != null)
                onSearchChange(text);
        });
    }

    public function isFocused():Bool {
        return PsychUIInputText.focusOn == search;
    }

    public function focus() {
        PsychUIInputText.focusOn = search;
    }
}
