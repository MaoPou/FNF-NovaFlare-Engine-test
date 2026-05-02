package options.objects.others;

class AlphaText extends FlxSpriteGroup
{
    public var mainText:FlxText;
    public var minorText:FlxText;

    public var mainX:Float;
	public var mainY:Float;
    public var mainSize:Float;

    public function new(X:Float, Y:Float, boud:Float, text:String, size:Int) {
        super(X, Y);

        mainSize = size;

        mainText = new FlxText(0, 0, boud, text, size);
        mainText.antialiasing = ClientPrefs.data.antialiasing;
		add(mainText);

        minorText = new FlxText(0, 0, boud, text, size);
        minorText.alpha = 0.0000001;
        minorText.antialiasing = ClientPrefs.data.antialiasing;
        
		add(minorText);
    }

    public function setFormat(?Font:String = null, Size:Int = 8, Color:FlxColor = FlxColor.WHITE, ?Alignment:FlxTextAlign, ?BorderStyle:FlxTextBorderStyle,
			BorderColor:FlxColor = FlxColor.TRANSPARENT, EmbeddedFont:Bool = true) {
                if (Font == null) Font =  Paths.font(Language.get('fontName', 'main') + '.ttf');
                mainText.setFormat(Font, Size, Color, Alignment, BorderStyle, BorderColor, EmbeddedFont);
                minorText.setFormat(Font, Size, Color, Alignment, BorderStyle, BorderColor, EmbeddedFont);

                mainText.borderStyle = NONE;
                minorText.borderStyle = NONE;
    }

    var mainTween:FlxTween;
    var minorTween:FlxTween;
    var saveText:String = '';
    public function changeText(newText:String, time:Float = 0.6) {
        if (newText == saveText) return;

        saveText = newText;

        if (mainTween != null) { mainTween.cancel(); mainText.alpha = 1; }
        if (minorTween != null) { minorTween.cancel(); minorText.alpha = 0; }

        minorText.text = newText;
        minorText.scale.x = minorText.scale.y = 1;
        minorText.x = mainX;
        minorText.y = mainY;
        
        mainTween = FlxTween.tween(mainText, {alpha: 0}, time / 2, {
            ease: FlxEase.expoIn,
            onComplete: function(twn:FlxTween)
            {
                minorTween = FlxTween.tween(minorText, {alpha: 1}, time / 2, {
                    ease: FlxEase.expoOut,
                    onComplete: function(twn:FlxTween)
                        {
                            minorText.alpha = 0.00001;

                            mainText.alpha = 1;
                            mainText.text = newText;
            
                            mainText.scale.x = mainText.scale.y = 1;
                            mainText.x = mainX;
                            mainText.y = mainY;
                        }
                });
            }
		});
    }
} 