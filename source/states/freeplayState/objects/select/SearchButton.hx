package states.freeplayState.objects.select;

class SearchButton extends FlxSpriteGroup {
    var bg:FlxSprite;
    var search:PsychUIInputText;
    
    public var onSearchChange:String->Void;

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
    }
}
