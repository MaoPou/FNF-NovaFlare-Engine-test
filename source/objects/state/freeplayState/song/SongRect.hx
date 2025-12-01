package objects.state.freeplayState.song;

import objects.HealthIcon;

class SongRect extends FlxSpriteGroup {
    
    public var light:Rect;
    private var bg:FlxSprite;
    public var diffGroup:Array<DiffRect> = [];
    private var icon:HealthIcon;
	private var songName:FlxText;
	private var musican:FlxText;

    /////////////////////////////////////////////////////////////////////

    static public final fixHeight:Int = #if mobile 80 #else 60 #end;

    static public var focusRect:SongRect;

    public var id:Int = 0;
    public var currect:Int = 0;
    
    public var onSelectChange:String->Void;
    public function new(songNameSt:String, songChar:String, songMusican:String, songCharter:Array<String>, songColor:Array<Int>) {
        super(0, 0);

        light = new Rect(0, 0, 560, fixHeight, fixHeight / 2, fixHeight / 2, FlxColor.WHITE, 1, 1, EngineSet.mainColor);
        light.antialiasing = ClientPrefs.data.antialiasing;
        add(light);
        
        var path:String = PreThreadLoad.bgPathCheck(Mods.currentModDirectory, 'data/${songNameSt}/bg');
        if (Cache.getFrame(path + ' r:' + songColor[0] + ' g:' + songColor[1] + ' b:' + songColor[2]) == null) addBGCache(path, songColor);

        bg = new FlxSprite();
        bg.frames = Cache.getFrame(path + ' r:' + songColor[0] + ' g:' + songColor[1] + ' b:' + songColor[2]);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

        icon = new HealthIcon(songChar, false, false);
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
		//songName.y = light.height * 0.05;
		add(songName);

        musican = new FlxText(0, 0, 0, songMusican, 20);
		musican.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(light.height * 0.2), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        musican.borderStyle = NONE;
		musican.antialiasing = ClientPrefs.data.antialiasing;
		musican.x += bg.height / 2 - icon.height / 2 + icon.width * 1.1;
		musican.y += songName.textField.textHeight;
		add(musican);
    }

    function addBGCache(filesLoad:String, songColor:Array<Int>) {
        var newGraphic:FlxGraphic = Paths.cacheBitmap(filesLoad, null, false);

        var matrix:Matrix = new Matrix();
        var scale:Float = light.width / newGraphic.width;
        if (light.height / newGraphic.height > scale)
            scale = light.height / newGraphic.height;
        matrix.scale(scale, scale);
        matrix.translate(-(newGraphic.width * scale - light.width) / 2, -(newGraphic.height * scale - light.height) / 2);

        var resizedBitmapData:BitmapData = new BitmapData(Std.int(light.width), Std.int(light.height), true, 0x00000000);
        resizedBitmapData.draw(newGraphic.bitmap, matrix);
        
        if (filesLoad.indexOf('menuDesat') != -1)
        {
            var colorTransform:ColorTransform = new ColorTransform();
            var color:FlxColor = FlxColor.fromRGB(songColor[0], songColor[1], songColor[2]);
            colorTransform.redMultiplier = color.redFloat;
            colorTransform.greenMultiplier = color.greenFloat;
            colorTransform.blueMultiplier = color.blueFloat;
            
            resizedBitmapData.colorTransform(new Rectangle(0, 0, resizedBitmapData.width, resizedBitmapData.height), colorTransform);
        }

        drawLine(resizedBitmapData);
        
        resizedBitmapData.copyChannel(light.pixels, new Rectangle(0, 0, light.width, light.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);

        newGraphic = FlxGraphic.fromBitmapData(resizedBitmapData);

        Cache.setFrame(filesLoad + ' r:' + songColor[0] + ' g:' + songColor[1] + ' b:' + songColor[2], newGraphic.imageFrame);

        var mainBGcache:FlxGraphic = Paths.cacheBitmap(filesLoad, null, false);
        Cache.setFrame('freePlayBG-' + filesLoad, mainBGcache.imageFrame); //预加载大界面的图像
	}

    static var lineShape:Shape = null;
    function drawLine(bitmap:BitmapData)
	{
        if (lineShape == null) {
            lineShape = new Shape();
            var lineSize:Int = 2;
            var round:Int = Std.int(bitmap.height / 2);
            lineShape.graphics.beginFill(EngineSet.mainColor);
            lineShape.graphics.lineStyle(1, EngineSet.mainColor, 1);
            lineShape.graphics.drawRoundRect(0, 0, bitmap.width, bitmap.height, round, round);
            lineShape.graphics.lineStyle(0, 0, 0);
            lineShape.graphics.drawRoundRect(lineSize, lineSize, bitmap.width - lineSize * 2, bitmap.height - lineSize * 2, round - lineSize * 2, round - lineSize * 2);
            lineShape.graphics.endFill();
        }

		bitmap.draw(lineShape);
	}

    public var onFocus(default, set):Bool = true; //是当前这个歌曲被选择
    override function update(elapsed:Float)
	{
		super.update(elapsed);

        calcX();

        var mouse = FreeplayState.instance.mouseEvent;

		var overlaps = mouse.overlaps(this);

        if (overlaps) {
            if (mouse.justReleased) {
                choose();
            }
        }

        updateFocus();
        
	}

    public static function updateFocus() {
        focusRect = FreeplayState.instance.songGroup[FreeplayState.curSelected];
    }
	
    //////////////////////////////////////////////////////////////////////////////////////////////
	
	function choose() {
	    FreeplayState.curSelected = this.id;
	    FreeplayState.moveSelected = this.currect;
	    FreeplayState.instance.changeSelection();   
        updateFocus();
        createDiff();
	}

    private function set_onFocus(value:Bool):Bool
	{
		if (onFocus == value)
			return onFocus;
		onFocus = value;
		if (onFocus)
		{

		} else {
			
		}
		return value;
	}

    //////////////////////////////////////////////////////////////////////////////////////////////

    public var diffAdded:Bool = false;
    public function createDiff() {
        if (diffAdded) return;

        Difficulty.loadFromWeek();

        for (mem in FreeplayState.instance.songGroup) {
            mem.diffAdded = false;
            if (mem.currect > focusRect.currect) mem.addInterY(fixHeight * 0.15);
            else if (mem.currect == focusRect.currect) mem.addInterY(fixHeight * 0.1);
            else mem.addInterY(0);
            
            if (mem.currect > focusRect.currect) mem.addDiffY();
            else mem.addDiffY(false);
            
            if (mem != focusRect) mem.destoryDiff();
        }
        
        diffAdded = true;
    }
    
    public function destoryDiff() {
        if (!diffAdded) return;
        
        diffAdded = false;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////

    public function setCurrect(state:String, put:Int) {
        if (state == 'up') {
            var nextRect = FreeplayState.instance.songGroup[FlxMath.wrap(this.id - 1, 0, FreeplayState.instance.songGroup.length - 1)];
            
            if (this.currect < put) {
                this.interY = nextRect.interY;
                this.diffY = nextRect.diffY;
            }
        } else if (state == 'down') {
            var lastRect = FreeplayState.instance.songGroup[FlxMath.wrap(this.id + 1, 0, FreeplayState.instance.songGroup.length - 1)];
            if (this.currect > put) {
                this.interY = lastRect.interY;
                this.diffY = lastRect.diffY;
            }
        }

        this.currect = put;
    }

    /*
    public function createDiff(color:FlxColor, charter:Array<String>, imme:Bool = false)
	{
		desDiff();
		haveDiffDis = true;
		for (diff in 0...Difficulty.list.length)
		{
			var chart:String = charter[diff];
			if (charter[diff] == null)
				chart = charter[0];
			var rect = new DiffRect(Difficulty.list[diff], color, chart, this);
			diffRectGroup.add(rect);
			diffRectArray.push(rect);
			rect.member = diff;
			rect.posY = background.height + 10 + diff * 70;
			if (imme)
				rect.lerpPosY = rect.posY;
			if (diff == FreeplayState.curDifficulty)
				rect.onFocus = true;
			else
				rect.onFocus = false;
		}
	}

	public function desDiff()
	{
		haveDiffDis = false;
		if (diffRectArray.length < 1)
			return;
		for (i in 0...diffRectGroup.length)
		{
			diffRectArray.shift();
		}

		for (member in diffRectGroup.members)
		{
			if (member == null)
				return; // 奇葩bug了属于
			diffRectGroup.remove(member);
			member.destroy();
		}
	}
    */

    ///////////////////////////////////////////////////////////////////////

    public var moveX:Float = 0;
    public var chooseX:Float = 0;
    public var diffX:Float = 0;
    public function calcX() {
        moveX = Math.pow(Math.abs(this.y + this.light.height / 2 - FlxG.height / 2) / (FlxG.height / 2) * 10, 1.9);
        this.x = FlxG.width - this.light.width + 70 + moveX + chooseX + diffX;
    }
    
    var moveTime:Float = 0.3;

    public var interY:Float = 0;
    public var diffY:Float = 0;    
    public function moveY(startY:Float) {        
        this.y = startY + interY + diffY;
    }
    
    private var interTween:FlxTween;
    public function addInterY(target:Float) {
        if (interTween != null) interTween.cancel();
        interTween = FlxTween.num(interY, target, moveTime, {ease: FlxEase.expoInOut}, function(v){interY = v;});
    }
    
    private var diffTween:FlxTween;
    public function addDiffY(isAdd:Bool = true) {
        if (diffTween != null) diffTween.cancel();
        diffTween = FlxTween.num(diffY, isAdd ? Difficulty.list.length * DiffRect.fixHeight * 1.05 : 0, moveTime, {ease: FlxEase.expoInOut}, function(v){diffY = v;});
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