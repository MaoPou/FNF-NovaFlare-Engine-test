package states.freeplayState.objects.down;

class BackButton extends FlxSpriteGroup {
    var pressRect:Rect;
    var disRect:SkewRoundRect;

    var text:FlxText;

    var event:Dynamic -> Void = null;
    var normalColor:FlxColor;
    var hoverColor:FlxColor;

    public function new(x:Float, y:Float, width:Float, height:Float, onClick:Dynamic -> Void = null) {
        super(x, y);

        pressRect = new Rect(0, 0, width, height, height / 4, height / 4);
        add(pressRect);
        pressRect.alpha = 0;

        disRect = new SkewRoundRect(10, 0, width - 10, height - 10, height / 4, height / 4, -10, 0);
        normalColor = EngineSet.mainColor;
        hoverColor = CoolUtil.brightenColor(normalColor, 1.2);
        disRect.color = normalColor;
        add(disRect);

        text = new FlxText(0, 0, 0, 'Back');
        text.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), 24, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        text.borderStyle = NONE;
		text.antialiasing = ClientPrefs.data.antialiasing;
        add(text);
        text.x += 10 + (disRect.width - text.width) / 2;
        text.y += (disRect.height - text.height) / 2;

        this.event = onClick;
    }

    override function update(elapsed:Float)
	{
        var mouse = FreeplayState.instance.mouseEvent;

        var overlaps = mouse.overlaps(this.pressRect);
        disRect.color = overlaps ? hoverColor : normalColor;

        if (overlaps) {
            if (mouse.justReleased) {
                back2MainMenu();                 
            }
        }

        if (Controls.instance.justPressed('back')) {
            back2MainMenu();
        }

        super.update(elapsed);
    }

    function back2MainMenu() {
        FreeplayState.destroyFreeplayVocals();
        Mods.loadTopMod();
        FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
        MusicBeatState.switchState(new MainMenuState());
    }
}
