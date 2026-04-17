package states.freeplayState.objects.down;

class BackButton extends FlxSpriteGroup {
    var pressRect:Rect;
    var disRect:SkewRoundRect;

    var text:FlxText;

    var event:Dynamic -> Void = null;

    public function new(x:Float, y:Float, width:Float, height:Float, onClick:Dynamic -> Void = null) {
        super(x, y);

        pressRect = new Rect(0, 0, width, height, height / 4, height / 4);
        add(pressRect);
        pressRect.alpha = 0;

        disRect = new SkewRoundRect(10, 0, width - 10, height - 10, height / 4, height / 4, -15, 0, EngineSet.mainColor);
        add(disRect);

        this.event = onClick;
    }

    override function update(elapsed:Float)
	{
        var mouse = FreeplayState.instance.mouseEvent;

        var overlaps = mouse.overlaps(this.pressRect);

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