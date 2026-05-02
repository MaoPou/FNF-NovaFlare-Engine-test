package states.freeplayState.objects.select;

class SearchButton extends FlxSpriteGroup {
	var bg:FlxSprite;
	public var search:PsychUIInputText;
	var tapText:FlxText;

	public var onSearchChange:String->Void;
	public var searchDelay:Float = 0.2;
	var timer:FlxTimer = null;

	public var hasFocus(get, never):Bool;

	public function new(x:Float, y:Float) {
		super(x, y);

		bg = new FlxSprite().loadGraphic(Paths.image(FreeplayState.filePath + 'searchButton'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		search = new PsychUIInputText(13, 8, Std.int(bg.width - 90), '', Std.int(bg.height / 2));
		search.bg.visible = false;
		search.behindText.alpha = 0;
		search.textObj.font = Paths.font(Language.get('fontName', 'main') + '.ttf');
		search.textObj.antialiasing = ClientPrefs.data.antialiasing;
		search.textObj.color = FlxColor.WHITE;
		search.caret.color = 0x727E7E7E;
		search.onChange = function(old:String, cur:String) {
			if (cur == '')
				tapText.visible = true;
			else
				tapText.visible = false;
			startSearch(cur);
		}
		search.unfocus = function() {
			FreeplayState.instance.searchJustUnfocused = true;
			if (search.text == '' || search.text == null) {
				tapText.visible = true;
				startSearch('');
			}
		}
		add(search);

		tapText = new FlxText(13, 8, 0, Language.get('tapToSearch', 'freeplay'), Std.int(bg.height / 2));
		tapText.font = Paths.font(Language.get('fontName', 'main') + '.ttf');
		tapText.antialiasing = ClientPrefs.data.antialiasing;
		tapText.alpha = 0.6;
		tapText.color = FlxColor.WHITE;
		add(tapText);
	}

	function get_hasFocus():Bool {
		return PsychUIInputText.focusOn == search;
	}

	public function focusSearch() {
		PsychUIInputText.focusOn = search;
	}

	public function unfocusSearch() {
		if (PsychUIInputText.focusOn == search) {
			PsychUIInputText.focusOn = null;
			FreeplayState.instance.searchJustUnfocused = true;
		}
	}

	public function startSearch(text:String) {
		if (timer != null) timer.cancel();
		timer = new FlxTimer().start(searchDelay, function(tmr:FlxTimer) {
			if (onSearchChange != null)
				onSearchChange(text);
		});
	}

	public function changeLanguage() {
		tapText.text = Language.get('tapToSearch', 'freeplay');
		tapText.font = Paths.font(Language.get('fontName', 'main') + '.ttf');
		search.textObj.font = Paths.font(Language.get('fontName', 'main') + '.ttf');
	}
}
