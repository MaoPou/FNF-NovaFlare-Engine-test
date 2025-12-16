package objects.state.freeplayState.song;

import objects.HealthIcon;

class SongRect extends FlxSpriteGroup {

    static public final fixHeight:Int = #if mobile 80 #else 70 #end;

    public var id:Int = 0;
    
    public var onSelectChange:String->Void;

    public var bgPath:String;

    /////////////////////////////////////////////////////////////////////

    public var haveDiffDis:Bool = false;
    private var _songCharter:Array<String>;
    private var _songColor:FlxColor;

    public var diffRectGroup:FlxSpriteGroup;

    static public var focusRect:SongRect;
    static public var openRect:SongRect;

    public var light:Rect;
    private var bg:FlxSprite;
    private var icon:HealthIcon;
    private var songName:FlxText;
    private var musican:FlxText;

    public function new(songNameSt:String, songIcon:String, songMusican:String, songCharter:Array<String>, songColor:Array<Int>) {
        super(0, 0);

        diffRectGroup = new FlxSpriteGroup();
        add(diffRectGroup);

        light = new Rect(2, 0, 560, fixHeight, fixHeight / 4, fixHeight / 4, FlxColor.WHITE, 1, 0, EngineSet.mainColor);
        light.antialiasing = ClientPrefs.data.antialiasing;
        add(light);
        
        var path:String = PreThreadLoad.bgPathCheck(Mods.currentModDirectory, 'data/${songNameSt}/bg');
        if (Cache.getFrame(path) == null) addBGCache(path);
        bgPath = path;

        bg = new FlxSprite();
        bg.frames = Cache.getFrame(path);
		bg.antialiasing = ClientPrefs.data.antialiasing;
        if (path.indexOf('menuDesat') != -1)
            bg.color = FlxColor.fromRGB(songColor[0], songColor[1], songColor[2]);
		add(bg);

        _songCharter = songCharter;
        _songColor = FlxColor.fromRGB(songColor[0], songColor[1], songColor[2]);

        icon = new HealthIcon(songIcon, false, false);
		icon.setGraphicSize(Std.int(bg.height * 0.8));
		icon.x += bg.height / 2 - icon.height / 2;
		icon.y += bg.height / 2 - icon.height / 2;
		icon.updateHitbox();
		add(icon);

        songName = new FlxText(0, 0, 0, songNameSt, 20);
		songName.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(light.height * 0.3), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        songName.borderStyle = NONE;
		songName.antialiasing = ClientPrefs.data.antialiasing;
		songName.x += bg.height / 2 - icon.height / 2 + icon.width * 1.1;
		add(songName);

        musican = new FlxText(0, 0, 0, songMusican, 20);
		musican.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(light.height * 0.2), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        musican.borderStyle = NONE;
		musican.antialiasing = ClientPrefs.data.antialiasing;
		musican.x += bg.height / 2 - icon.height / 2 + icon.width * 1.1;
		musican.y += songName.textField.textHeight;
		add(musican);
    }

    function addBGCache(filesLoad:String) {
        var newGraphic:FlxGraphic = Paths.cacheBitmap(filesLoad, null, false);

        var matrix:Matrix = new Matrix();
        var scale:Float = light.width / newGraphic.width;
        if (light.height / newGraphic.height > scale)
            scale = light.height / newGraphic.height;
        matrix.scale(scale, scale);
        matrix.translate(-(newGraphic.width * scale - light.width) / 2, -(newGraphic.height * scale - light.height) / 2);

        var resizedBitmapData:BitmapData = new BitmapData(Std.int(light.width), Std.int(light.height), true, 0x00000000);
        resizedBitmapData.draw(newGraphic.bitmap, matrix);
        
        resizedBitmapData.copyChannel(light.pixels, new Rectangle(0, 0, light.width, light.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);

        newGraphic = FlxGraphic.fromBitmapData(resizedBitmapData);

        Cache.setFrame(filesLoad, newGraphic.imageFrame);

        var mainBGcache:FlxGraphic = Paths.cacheBitmap(filesLoad, null, false);
        Cache.setFrame('freePlayBG-' + filesLoad, mainBGcache.imageFrame); //预加载大界面的图像
	}

    public var onFocus(default, set):Bool = true; //是当前这个歌曲被选择
    override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (FreeplayState.curSelected != this.id) onFocus = false;
        else onFocus = true;

        var mouse = FreeplayState.instance.mouseEvent;

		var overlaps = mouse.overlaps(this.bg);

        if (overlaps) {
            if (mouse.justReleased) {
                overForce();
            }
        }
	}

    public static function updateFocus() {
        focusRect = FreeplayState.instance.songGroup[FreeplayState.curSelected];
    }
	
    //////////////////////////////////////////////////////////////////////////////////////////////
	
	function overForce() {
	    FreeplayState.curSelected = this.id;
        updateFocus();
        createDiff();
	}

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

        for (mem in FreeplayState.instance.songGroup) {
            diffAdded = false;
            if (mem.id >= focusRect.id) mem.addInterY(fixHeight * 0.1);
            else mem.addInterY(0);
            if (mem.id > focusRect.id) mem.addDiffY();
            else mem.addDiffY(false);
            if (mem != focusRect) mem.destoryDiff();
        }

        for (diff in 0...Difficulty.list.length)
		{
			var chart:String = _songCharter[diff];
			if (_songCharter[diff] == null)
				chart = _songCharter[0];
			var rect = new DiffRect(this, Difficulty.list[diff], _songColor, chart);
			diffRectGroup.add(rect);
			rect.member = diff;
			rect.startTarY = bg.height + 10 + diff * DiffRect.fixHeight * 1.05;
			if (imme)
				rect.startY = rect.startTarY;
			if (diff == FreeplayState.curDifficulty)
				rect.onFocus = true;
			else
				rect.onFocus = false;
		}

        diffAdded = true;
        openRect = this;
        FreeplayState.instance.changeSelection();
        FreeplayState.instance.updateSongLayerOrder();
    }
    
    public function destoryDiff() {
        if (!diffAdded && diffRectGroup.length < 1) return;
        for (member in diffRectGroup.members)
		{
			if (member == null)
				continue;
			diffRectGroup.remove(member);
			member.destroy();
		}
        diffAdded = false;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////

    public var moveX:Float = 0;
    public var chooseX:Float = 0;
    public var diffX:Float = 0;
    public function calcX() {
        moveX = Math.pow(Math.abs(this.y + this.light.height / 2 - FlxG.height / 2) / (FlxG.height / 2) * 10, 1.8);

        var chooseTar = onFocus ? -20 : 0;
        if (Math.abs(chooseX - chooseTar) > 0.5) chooseX = FlxMath.lerp(chooseTar, chooseX, Math.exp(-FreeplayState.instance.songsMove.saveElapsed * FreeplayState.instance.songsMove.lerpSmooth));
        else chooseX = chooseTar;

        var diffTar = diffAdded ? -50 : 0;
        if (Math.abs(diffX - diffTar) > 0.5) diffX = FlxMath.lerp(diffTar, diffX, Math.exp(-FreeplayState.instance.songsMove.saveElapsed * FreeplayState.instance.songsMove.lerpSmooth));
        else diffX = diffTar;
        
        this.x = FlxG.width - this.light.width + 80 + moveX + chooseX + diffX;
        diffCalcX();
    }

    private function diffCalcX() {
        if (diffAdded) {
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
        if (Math.abs(interY - interYTar) > 0.5)
            interY = FlxMath.lerp(interYTar, interY, Math.exp(-FreeplayState.instance.songsMove.saveElapsed * FreeplayState.instance.songsMove.lerpSmooth));
        else 
            interY = interYTar;
        
        if (Math.abs(diffY - diffYTar) > 0.5)
            diffY = FlxMath.lerp(diffYTar, diffY, Math.exp(-FreeplayState.instance.songsMove.saveElapsed * FreeplayState.instance.songsMove.lerpSmooth));
        else 
            diffY = diffYTar;

        this.y = startY + interY + diffY;
        diffCalcY();
    }

    private function diffCalcY() {
        if (diffAdded) {
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
        diffYTar = isAdd ? 10 + Difficulty.list.length * DiffRect.fixHeight * 1.05 : 0;
        //trace(diffYTar);
    }
}




















class CurLight extends FlxSprite
{
    /**
     * 圆角矩形，带从左到右的透明度渐变，并支持缓存复用。
     */
    public function new(
        X:Float = 0, Y:Float = 0,
        width:Float = 0, height:Float = 0,
        roundWidth:Float = 0, roundHeight:Float = 0,
        Color:FlxColor = FlxColor.WHITE,
        alphaLeft:Float = 0, alphaRight:Float = 1,
        easingPower:Float = 1.0
    ) {
        super(X, Y);

        var key = CurLight.cacheKey(width, height, roundWidth, roundHeight, alphaLeft, alphaRight, easingPower);

        if (Cache.getFrame(key) == null) {
            CurLight.addCache(key, width, height, roundWidth, roundHeight, alphaLeft, alphaRight, easingPower);
        }
        frames = Cache.getFrame(key);

        antialiasing = ClientPrefs.data.antialiasing;
        color = Color;
        alpha = 1;
    }

    static inline function cacheKey(
        width:Float, height:Float,
        roundWidth:Float, roundHeight:Float,
        alphaLeft:Float, alphaRight:Float,
        easingPower:Float
    ):String {
        var w = Std.int(width);
        var h = Std.int(height);
        var rw = Std.int(roundWidth);
        var rh = Std.int(roundHeight);
        var al = Std.int(alphaLeft * 1000);
        var ar = Std.int(alphaRight * 1000);
        var ep = Std.int(easingPower * 1000);
        return 'curlight-w'+w+'-h:'+h+'-rw:'+rw+'-rh:'+rh+'-al:'+al+'-ar:'+ar+'-ep:'+ep;
    }

    static function addCache(
        key:String,
        width:Float, height:Float,
        roundWidth:Float, roundHeight:Float,
        alphaLeft:Float, alphaRight:Float,
        easingPower:Float
    ):Void {
        var bmp = CurLight.drawCurLight(width, height, roundWidth, roundHeight, alphaLeft, alphaRight, easingPower);
        var g:FlxGraphic = FlxGraphic.fromBitmapData(bmp);
        g.persist = true;
        g.destroyOnNoUse = false;
        Cache.setFrame(key, g.imageFrame);
    }

    static function drawCurLight(
        width:Float, height:Float,
        roundWidth:Float, roundHeight:Float,
        alphaLeft:Float, alphaRight:Float,
        easingPower:Float
    ):BitmapData {
        // 圆角遮罩
        var shape:Shape = new Shape();
        shape.graphics.beginFill(0xFFFFFFFF);
        shape.graphics.drawRoundRect(0, 0, Std.int(width), Std.int(height), roundWidth, roundHeight);
        shape.graphics.endFill();

        var maskBmp:BitmapData = new BitmapData(Std.int(width), Std.int(height), true, 0x00000000);
        maskBmp.draw(shape);

        // 构建渐变 alpha 并与遮罩相交
        var finalBmp:BitmapData = new BitmapData(Std.int(width), Std.int(height), true, 0x00000000);
        var w:Int = Std.int(width);
        var h:Int = Std.int(height);

        var colAlpha:Array<Int> = [];
        for (x in 0...w) {
            var t:Float = w <= 1 ? 1.0 : x / (w - 1);
            if (easingPower != 1.0) t = Math.pow(t, easingPower);
            var a:Float = alphaLeft + (alphaRight - alphaLeft) * t;
            if (a < 0) a = 0; else if (a > 1) a = 1;
            colAlpha[x] = Std.int(a * 255);
        }

        for (x in 0...w) {
            var ca:Int = colAlpha[x];
            for (y in 0...h) {
                var m:Int = maskBmp.getPixel32(x, y);
                var ma:Int = (m >>> 24) & 0xFF;
                if (ma > 0) {
                    var fa:Int = ca < ma ? ca : ma;
                    var pixel:Int = (fa << 24) | 0xFFFFFF;
                    finalBmp.setPixel32(x, y, pixel);
                }
            }
        }
        return finalBmp;
    }
}
