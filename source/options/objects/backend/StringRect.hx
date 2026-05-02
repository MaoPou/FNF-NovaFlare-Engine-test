package options.objects.backend;

import openfl.display.Shape;
import openfl.display.BitmapData;

class StringRect extends FlxSpriteGroup{
    public var bg:Rect;
    public var dis:FlxSprite;
    public var disText:FlxText;

    var follow:Option;

    var innerX:Float; //该摁键在option的x
    var innerY:Float; //该摁键在option的y

    public var isOpend:Bool = false;

    public function new(X:Float, Y:Float, width:Float, height:Float, follow:Option) {
        super(X, Y);

        this.follow = follow;
        innerX = X;
        innerY = Y;

        bg = new Rect(0, 0, width, height, width / 20, width / 20, 0x000000, 0.3);
        bg.antialiasing = ClientPrefs.data.antialiasing;
        add(bg);

        disText = new FlxText(0, 0, 0, 'Tap to choose', Std.int(bg.width / 20 / 2));
		disText.setFormat(Paths.font(Language.get('fontName', 'main') + '.ttf'), Std.int(bg.height / 2), 0xffffff, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        disText.antialiasing = ClientPrefs.data.antialiasing;
		disText.borderStyle = NONE;
		disText.x += bg.mainRound;
		disText.alpha = 0.3;
        disText.y += (bg.height - disText.height) / 2;
		add(disText);

        dis = new FlxSprite();
        dis.loadGraphic(createButton(height * 0.75, 0xffffff));
        dis.antialiasing = ClientPrefs.data.antialiasing;
        dis.x += bg.width - dis.width - (bg.height - dis.height) / 2; 
        dis.y += (bg.height - dis.height) / 2;
        dis.flipY = true;
        add(dis);
    }

    public var allowUpdate:Bool = true;
    var timeCalc:Float;
    override function update(elapsed:Float) {
        super.update(elapsed);

        timeCalc += elapsed;

        if (!follow.allowUpdate) {
            timeCalc = 0;
            return;
        }
        
        if (!allowUpdate) return;

        if (timeCalc < 0.6) return;

        if (OptionsState.instance.mouseEvent.overlaps(OptionsState.instance.specBG) || OptionsState.instance.mouseEvent.overlaps(OptionsState.instance.downBG)) return;
        
        var mouse = OptionsState.instance.mouseEvent;

        if (mouse.overlaps(bg)) {

            bg.color = 0xffffff;
            bg.alpha = 0.3;

            disText.color = EngineSet.mainColor;
            disText.alpha = 1;

            dis.color = EngineSet.mainColor;
            dis.alpha = 1;

            if (mouse.justReleased) {
                change();
            }
        } else {
            bg.color = 0x000000;
            bg.alpha = 0.3;

            disText.color = 0xffffff;
            disText.alpha = 0.3;

            dis.color = 0xffffff;
            dis.alpha = 0.3;
        }
    }

    var alphaTween:Array<FlxTween> = [];
    var changeTimer:Float = 0.45;
    public function change() {
        for (tween in alphaTween) {
            tween.cancel();
        }

        if (!follow.follow.peerCheck(follow)) return;

        if (isOpend) { //关闭
            disText.text = 'Tap to choose';
            dis.flipY = true;
            
            var tween = FlxTween.tween(follow.select.bg, {alpha: 0}, changeTimer, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween){follow.select.active = follow.select.visible = false; if (OptionsState.instance.stringCount.contains(follow.select)) OptionsState.instance.stringCount.remove(follow.select);} });
            alphaTween.push(tween);
            var tween = FlxTween.tween(follow.select.slider, {alpha: 0}, changeTimer, {ease: FlxEase.expoOut});
            alphaTween.push(tween);
            
            for (i in 0...follow.select.optionSprites.length) {
                follow.select.optionSprites[i].allowUpdate = false;
                var tween = FlxTween.tween(follow.select.optionSprites[i].textDis, {alpha: 0}, changeTimer, {ease: FlxEase.expoOut});
                alphaTween.push(tween);
            }

            follow.follow.optionAdjust(follow, -1 * (follow.select.bg.height + follow.inter));
            isOpend = !isOpend;
            follow.select.isOpend = isOpend;
        } else { //开启 
            if (!OptionsState.instance.stringCount.contains(follow.select)) OptionsState.instance.stringCount.push(follow.select);
            disText.text = 'Tap to close';
            dis.flipY = false;

            follow.select.active = follow.select.visible = true;
            var tween = FlxTween.tween(follow.select.bg, {alpha: 0.1}, changeTimer, {ease: FlxEase.expoIn});
            alphaTween.push(tween);
            var tween = FlxTween.tween(follow.select.slider, {alpha: 0.8}, changeTimer, {ease: FlxEase.expoIn});
            alphaTween.push(tween);
            for (i in 0...follow.select.optionSprites.length) {
                var tween = FlxTween.tween(follow.select.optionSprites[i].textDis, {alpha: 1}, changeTimer, {ease: FlxEase.expoIn, onComplete: function(twn:FlxTween){ follow.select.optionSprites[i].allowUpdate = true;} });
                alphaTween.push(tween);
            }

            follow.follow.optionAdjust(follow, follow.select.bg.height + follow.inter);
            isOpend = !isOpend;
            follow.select.isOpend = isOpend;
        }
    }

    private function createButton(size:Float, color:Int) {
        var button = new Shape();
        button.graphics.beginFill(color);
        
        // 2. 设置符号绘制样式
        button.graphics.lineStyle(3, 0xffffff); // 白色线条，3像素粗
        
        // 3. 计算符号位置（保留30%边距）
        var margin = size * 0.3;
        var centerX = size / 2;
        var symbolHeight = size * 0.4; // 符号高度占40%
        
        // 4. 绘制"^"符号
        button.graphics.moveTo(centerX, margin); // 起点：顶部中心
        button.graphics.lineTo(size * 0.22, margin + symbolHeight); // 向左下画线
        button.graphics.moveTo(centerX, margin); // 回到起点
        button.graphics.lineTo(size * 0.78, margin + symbolHeight); // 向右下画线
        
        // 5. 转换为BitmapData
        var bitmap = new BitmapData(Std.int(size), Std.int(size), true, 0);
        bitmap.draw(button);
        return bitmap;
    }
}