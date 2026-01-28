package objects.state.freeplayState.song;

import objects.HealthIcon;

class SongRect extends FlxSpriteGroup {

    static public final fixWidth:Int = 560;
    static public final fixHeight:Int = #if mobile 80 #else 70 #end;

    public var id:Int = 0;
    
    public var onSelectChange:String->Void;

    public var bgPath:String;

    /////////////////////////////////////////////////////////////////////

    public var haveDiffDis:Bool = false;
    private var _songCharter:Array<String>;
    private var _songColor:FlxColor;

    public var diffRectGroup:FlxSpriteGroup;

    static public var openRect:SongRect;

    public var selectShow:Rect;
    private var bg:FlxSprite;
    private var light:SegmentGradientRoundRect;
    private var black:SegmentGradientRoundRect;
    private var icon:HealthIcon;
    private var songName:FlxText;
    private var musican:FlxText;
    private var selectLight:Rect;

    public function new(songNameSt:String, songIcon:String, songMusican:String, songCharter:Array<String>, songColor:Array<Int>) {
        super(0, 0);

        diffRectGroup = new FlxSpriteGroup();
        add(diffRectGroup);

        selectShow = new Rect(2, 0, fixWidth, fixHeight, fixHeight / 4, fixHeight / 4, FlxColor.WHITE, 1, 0, EngineSet.mainColor);
        selectShow.antialiasing = ClientPrefs.data.antialiasing;
        add(selectShow);
        
        var path:String = PreThreadLoad.bgPathCheck(Mods.currentModDirectory, 'data/${songNameSt}/bg');
        if (!Cache.checkFrame(path)) addBGCache(path);
        bgPath = path;

        bg = new FlxSprite();
        bg.frames = Cache.getFrame(path);
		bg.antialiasing = ClientPrefs.data.antialiasing;
        if (path.indexOf('menuDesat') != -1)
            bg.color = FlxColor.fromRGB(songColor[0], songColor[1], songColor[2]);
		add(bg);

        _songCharter = songCharter;
        _songColor = FlxColor.fromRGB(songColor[0], songColor[1], songColor[2]);

        black = new SegmentGradientRoundRect(0, 0, Std.int(selectShow.width), Std.int(selectShow.height), fixHeight / 4, FlxColor.BLACK , [[0, 0.5, 0.3], [0.7, 0.5, 0]], 1);
        black.antialiasing = ClientPrefs.data.antialiasing;
        add(black);

        light = new SegmentGradientRoundRect(0, 0, Std.int(selectShow.width), Std.int(selectShow.height), fixHeight / 4, FlxColor.WHITE, [[0.3, 0.5, 0], [1, 0.5, 0.3]], 1);
        light.antialiasing = ClientPrefs.data.antialiasing;
        light.blend = ADD;
        light.alpha = 0;
        add(light);

        icon = new HealthIcon(songIcon, false, false);
		icon.setGraphicSize(Std.int(bg.height * 0.8));
		icon.x += bg.height / 2 - icon.height / 2;
		icon.y += bg.height / 2 - icon.height / 2;
		icon.updateHitbox();
		add(icon);

        songName = new FlxText(0, 0, 0, songNameSt, 20);
		songName.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(selectShow.height * 0.3), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        songName.borderStyle = NONE;
		songName.antialiasing = ClientPrefs.data.antialiasing;
		songName.x += bg.height / 2 - icon.height / 2 + icon.width * 1.1;
		add(songName);

        musican = new FlxText(0, 0, 0, songMusican, 20);
		musican.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(selectShow.height * 0.2), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        musican.borderStyle = NONE;
		musican.antialiasing = ClientPrefs.data.antialiasing;
		musican.x += bg.height / 2 - icon.height / 2 + icon.width * 1.1;
		musican.y += songName.textField.textHeight;
		add(musican);

        selectLight = new Rect(0, 0, Std.int(selectShow.width + 50), Std.int(selectShow.height), fixHeight / 4, fixHeight / 4, 0xFFFFFF, 0);
        selectLight.antialiasing = ClientPrefs.data.antialiasing;
        selectLight.blend = ADD;
        selectLight.alpha = 0;
        add(selectLight);
    }

    function addBGCache(filesLoad:String) {
        var newGraphic:FlxGraphic = Paths.cacheBitmap(filesLoad, null, false);

        var matrix:Matrix = new Matrix();
        var scale:Float = selectShow.width / newGraphic.width;
        if (selectShow.height / newGraphic.height > scale)
            scale = selectShow.height / newGraphic.height;
        matrix.scale(scale, scale);
        matrix.translate(-(newGraphic.width * scale - selectShow.width) / 2, -(newGraphic.height * scale - selectShow.height) / 2);

        var resizedBitmapData:BitmapData = new BitmapData(Std.int(selectShow.width), Std.int(selectShow.height), true, 0x00000000);
        resizedBitmapData.draw(newGraphic.bitmap, matrix);
        
        resizedBitmapData.copyChannel(selectShow.pixels, new Rectangle(0, 0, selectShow.width, selectShow.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);

        newGraphic = FlxGraphic.fromBitmapData(resizedBitmapData);

        Cache.setFrame(filesLoad, {graphic:newGraphic, frame:null});

        var mainBGcache:FlxGraphic = Paths.cacheBitmap(filesLoad, null, false);
        Cache.setFrame('freePlayBG-' + filesLoad, {graphic:mainBGcache, frame:null}); //预加载大界面的图像
	}

    public var onFocus(default, set):Bool = true; //是当前这个歌曲被选择
    override function update(elapsed:Float)
	{
        if (FreeplayState.curSelected != this.id) onFocus = false;
        else {
            if (diffAdded) {
                if (FreeplayState.curDifficulty == -1) onFocus = true;
                else onFocus = false;
            } else {
                onFocus = true;
            }
        }

        var mouse = FreeplayState.instance.mouseEvent;

		var overlaps = mouse.overlaps(this.black);

        selectLight.alpha -= elapsed;

        if (overlaps) {
            if (FreeplayState.curSelected != this.id) selectLight.alpha = 0.1;
            if (mouse.justReleased) {
                changeSelectAll();
            }
        }

        if (onFocus) selectLight.alpha = 0.1;

        super.update(elapsed);

        if (light.alpha > 0) {
            light.alpha -= elapsed / (Conductor.crochet * 2 / 1000);
        }
	}

    public function beatHit() {
        light.alpha = 1;
        if (diffRectGroup.members[FreeplayState.curDifficulty] != null) {
            var diffRect = cast(diffRectGroup.members[FreeplayState.curDifficulty], DiffRect);
            diffRect.beatHit();
        }
    }

    public function changeSelectAll(imme:Bool = false) {
        openRect = this;
        selectLight.alpha = 0.6;
	    FreeplayState.curSelected = this.id;
        FreeplayState.instance.changeSelection();
        createDiff(imme);
        FreeplayState.instance.songsMove.tweenData = FlxG.height * 0.5 - SongRect.fixHeight * 0.5 - FreeplayState.curSelected * SongRect.fixHeight * FreeplayState.instance.rectInter - (FreeplayState.curDifficulty+1) * DiffRect.fixHeight * 1.05;
        FreeplayState.instance.initSongsData();
    }
	
    //////////////////////////////////////////////////////////////////////////////////////////////

    private function set_onFocus(value:Bool):Bool
	{
		if (onFocus == value)
			return onFocus;
		onFocus = value;
		return value;
	}

    //////////////////////////////////////////////////////////////////////////////////////////////

    public var diffAdded:Bool = false;
    public function createDiff(imme:Bool = false) {
        if (diffAdded) return;
        Difficulty.loadFromWeek();

        FreeplayState.curDifficulty = 0;

        for (mem in FreeplayState.instance.songGroup) {
            if (mem.id >= openRect.id) mem.addInterY(fixHeight * 0.1);
            else mem.addInterY(0);
            if (mem.id > openRect.id) mem.addDiffY();
            else mem.addDiffY(false);
            if (mem != openRect) mem.signDesDiff();
            mem.diffAdded = false;
        }

        if (diffRectGroup.members.length != Difficulty.list.length) {
            if (diffRectGroup.members.length != 0) {
                destroyDiff();
            }
            for (diff in 0...Difficulty.list.length)
            {
                var chart:String = _songCharter[diff];
                if (_songCharter[diff] == null)
                    chart = _songCharter[0];
                var rect = new DiffRect(this, Difficulty.list[diff], _songColor, chart);
                diffRectGroup.add(rect);
                rect.id = diff;
                rect.startTarY = bg.height + fixHeight / 10 + diff * DiffRect.fixHeight * 1.05;
                if (imme) {
                    rect.startY = rect.startTarY;
                    rect.allowSelect = true;
                } else {
                    FlxTimer.wait(0.1, () -> {
                        rect.allowSelect = true;
                    });
                }
            }
            diffFouceUpdate();
        } else {
            for (member in diffRectGroup.members)
            {
                var rect = cast(member, DiffRect);
                rect.allowDestroy = false;
                FlxTimer.wait(0.1, () -> {
                    rect.allowSelect = true;
                });
                rect.startTarY = bg.height + fixHeight / 10 + rect.id * DiffRect.fixHeight * 1.05;
            }
            diffFouceUpdate();
        }

        diffAdded = true;
        FlxTimer.wait(0.001, () -> {
            FreeplayState.instance.updateSongLayerOrder();
        });
    }
    
    private function signDesDiff() {
        if (!diffAdded) return;
        if (diffRectGroup.members.length > 0) {
            for (member in diffRectGroup.members)
            {
                if (member == null)
                    continue;
                var diffRect = cast(member, DiffRect);
                if (diffRect == null) continue;
                diffRect.startTarY = 0;
                diffRect.allowDestroy = true;
                diffRect.allowSelect = false;
                diffRect.onFocus = false;
            }
        }
    }

    public function destroyDiff() {
        for (member in diffRectGroup.members)
        {
            if (member == null)
                continue;
            diffRectGroup.remove(member, true);
            member.destroy();
        }
    }

    public function diffFouceUpdate() {
        if (diffRectGroup.members.length > 0) {
            for (diff in diffRectGroup.members) {
                var diffRect = cast(diff, DiffRect);
                if (diffRect == null) continue;
                diffRect.onFocus = diffRect.id == FreeplayState.curDifficulty;
            }
        }
    }

    //////////////////////////////////////////////////////////////////////////////////////////////

    public var moveX:Float = 0;
    public var chooseX:Float = 0;
    public var diffX:Float = 0;
    public function calcX() {
        moveX = Math.pow(Math.abs(this.y + this.selectShow.height / 2 - FlxG.height / 2) / (FlxG.height / 2) * 10, 1.8);

        var chooseTar = onFocus ? -20 : 0;
        if (Math.abs(chooseX - chooseTar) > 1) chooseX = FlxMath.lerp(chooseTar, chooseX, Math.exp(-FreeplayState.instance.songsMove.saveElapsed * FreeplayState.instance.songsMove.lerpSmooth));
        else chooseX = chooseTar;

        var diffTar = diffAdded ? -50 : 0;
        if (Math.abs(diffX - diffTar) > 1) diffX = FlxMath.lerp(diffTar, diffX, Math.exp(-FreeplayState.instance.songsMove.saveElapsed * FreeplayState.instance.songsMove.lerpSmooth));
        else diffX = diffTar;
        
        this.x = FlxG.width - this.selectShow.width + 80 + moveX + chooseX + diffX;
        diffCalcX();
    }

    private function diffCalcX() {
        if (diffRectGroup.members.length > 0) {
            for (diff in diffRectGroup.members) {
                var diffRect = cast(diff, DiffRect);
                if (diffRect == null) continue;
                diffRect.calcX();
            }
        }
    }

    public var interY:Float = 0;
    public var diffY:Float = 0;    
    public function moveY(startY:Float) {        
        if (Math.abs(interY - interYTar) > 1)
            interY = FlxMath.lerp(interYTar, interY, Math.exp(-FreeplayState.instance.songsMove.saveElapsed * FreeplayState.instance.songsMove.lerpSmooth));
        else 
            interY = interYTar;
        
        if (Math.abs(diffY - diffYTar) > 1)
            diffY = FlxMath.lerp(diffYTar, diffY, Math.exp(-FreeplayState.instance.songsMove.saveElapsed * FreeplayState.instance.songsMove.lerpSmooth));
        else 
            diffY = diffYTar;

        this.y = startY + interY + diffY;
        diffCalcY();
    }

    private function diffCalcY() {
        if (diffRectGroup.members.length > 0) {
            for (diff in diffRectGroup.members) {
                var diffRect = cast(diff, DiffRect);
                if (diffRect == null) continue;
                diffRect.calcY();
            }
        }
    }
    
    private var interYTar:Float = 0;
    public function addInterY(target:Float) {
        interYTar = target;
    }
    
    private var diffYTar:Float = 0;
    public function addDiffY(isAdd:Bool = true) {
        diffYTar = isAdd ? fixHeight / 10 * 2 + Difficulty.list.length * DiffRect.fixHeight * 1.05 : 0;
    }
}
