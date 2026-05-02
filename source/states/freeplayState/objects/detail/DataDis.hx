package states.freeplayState.objects.detail;

import flixel.math.FlxRect;

class DataDis extends FlxSpriteGroup{
    var lineBG:Rect;
    public var lineDis:Rect;
    var text:FlxText;
    public var data:FlxText;

	var baseWidth:Float = 0;
	var baseHeight:Float = 0;

	public var minValue(default, null):Float = 0;
	public var maxValue(default, null):Float = 1;
	public var value(default, null):Float = 0;

	public var autoMin:Bool = false;
	public var autoMax:Bool = true;

	public var allowDecimal:Bool = true;
	public var allowTweenDecimal:Bool = true;
	public var decimalPlaces:Int = 2;

	public var enableColorByPercent:Bool = true;
	public var minColor:FlxColor = 0xFFAFFF8D;
	public var maxColor:FlxColor = 0xFFFF7975;

	var tween:FlxTween = null;

    public function new(x:Float, y:Float, width:Float, height:Float, dataName:String, ?minValue:Float = 0, ?maxValue:Float = 1, ?initValue:Float = 0){
        super(x, y);

		baseWidth = width;
		baseHeight = height;
		this.minValue = minValue;
		this.maxValue = maxValue;
		this.value = initValue;

        lineBG = new Rect(0, 0, width, height, height, height, 0xffffff);
		lineBG.antialiasing = ClientPrefs.data.antialiasing;
		lineBG.alpha = 0.35;
		add(lineBG);

        lineDis = new Rect(0, 0, width, height, height, height, 0x5cffe7);
		lineDis.antialiasing = ClientPrefs.data.antialiasing;
		lineDis.clipRect = new FlxRect(0, 0, 0, height);
		add(lineDis);

        text = new FlxText(0, 0, 0, dataName, 20);
		text.setFormat(Paths.font(Language.get('fontName', 'main') + '.ttf'), 14, 0xffffff, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        text.borderStyle = NONE;
		text.antialiasing = ClientPrefs.data.antialiasing;
        text.y += height * 1.5;
		add(text);

        data = new FlxText(0, 0, 0, '', 20);
		data.setFormat(Paths.font(Language.get('fontName', 'main') + '.ttf'), 14, 0xffffff, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        data.borderStyle = NONE;
		data.antialiasing = ClientPrefs.data.antialiasing;
        data.y += lineDis.height + text.textField.height;
		add(data);

		applyVisual(this.value, calcPercent(this.value, this.minValue, this.maxValue), this.minValue, this.maxValue, allowDecimal);
    }

	function calcPercent(v:Float, minV:Float, maxV:Float):Float {
		if (maxV <= minV) return 1;
		return FlxMath.bound((v - minV) / (maxV - minV), 0, 1);
	}

	function formatValue(v:Float, allowDecimal:Bool):String {
		if (!allowDecimal) return Std.string(Math.round(v));

		var rounded = Math.round(v);
		if (Math.abs(v - rounded) < 0.0001) return Std.string(rounded);

		var p:Int = decimalPlaces;
		if (p < 0) p = 0;
		if (p == 0) return Std.string(rounded);

		var mul:Float = Math.pow(10, p);
		return Std.string(Math.round(v * mul) / mul);
	}

	function applyVisual(v:Float, percent:Float, minV:Float, maxV:Float, allowDecimal:Bool) {
		value = v;
		var clipW:Float = baseWidth * percent;
		if (clipW < 0) clipW = 0;
		if (clipW > baseWidth) clipW = baseWidth;
		lineDis.clipRect = new FlxRect(0, 0, clipW, baseHeight);
		if (enableColorByPercent) {
			lineDis.color = FlxColor.interpolate(minColor, maxColor, percent);
		}
		data.text = formatValue(v, allowDecimal) + '  [' + formatValue(minV, allowDecimal) + ' - ' + formatValue(maxV, allowDecimal) + ']';
	}

	public function setColorRange(minColor:FlxColor, maxColor:FlxColor, ?applyNow:Bool = true) {
		this.minColor = minColor;
		this.maxColor = maxColor;
		if (applyNow) applyVisual(value, calcPercent(value, minValue, maxValue), minValue, maxValue, allowDecimal);
	}

	public function setMinMax(minV:Float, maxV:Float, ?tweenTime:Float = 0) {
		minValue = minV;
		maxValue = maxV;
		chanegData(value, tweenTime);
	}

    public function chanegData(data:Float, ?tweenTime:Float = 0.5) {
		var oldMin:Float = minValue;
		var oldMax:Float = maxValue;

		var targetMin:Float = minValue;
		var targetMax:Float = maxValue;
		if (autoMin) targetMin = Math.min(targetMin, data);
		if (autoMax) targetMax = Math.max(targetMax, data);
		minValue = targetMin;
		maxValue = targetMax;

		var startV:Float = value;
		var endV:Float = data;
		var startP:Float = calcPercent(startV, oldMin, oldMax);
		var endP:Float = calcPercent(endV, targetMin, targetMax);

		if (tween != null) tween.cancel();
		if (tweenTime <= 0) {
			applyVisual(endV, endP, targetMin, targetMax, allowDecimal);
			return;
		}

		tween = FlxTween.num(0, 1, tweenTime, {
			ease: FlxEase.expoOut,
			onComplete: function(_) {
				applyVisual(endV, endP, targetMin, targetMax, allowDecimal);
			}
		}, function(t:Float) {
			var v:Float = startV + (endV - startV) * t;
			var p:Float = startP + (endP - startP) * t;
			applyVisual(v, p, targetMin, targetMax, allowTweenDecimal);
		});

    }

}
