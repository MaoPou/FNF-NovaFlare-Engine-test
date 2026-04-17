package states.freeplayState.objects.detail;

typedef StarRectColorStop = {
    var value:Float;
    var color:FlxColor;
};

class StarRect extends FlxSpriteGroup{
    public var bg:Rect;
    private var star:Star;
    public var text:FlxText;

    private var _colorStops:Array<StarRectColorStop> = [
        {value: 0, color: 0x7FFFFB},
        {value: 0.166, color: 0x83ff7F},
        {value: 0.33, color: 0xFFF17F},
        {value: 0.5, color: 0xFF7F7F},
        {value: 0.666, color: 0xFF7FF9},
        {value: 0.833, color: 0x4444FE},
        {value: 1, color: 0x21202C},
    ];

    public function new(x:Float, y:Float, width:Float, height:Float){
        super(x, y);

        bg = new Rect(0, 0, width, height, height, height, 0x9bff7a);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

        star = new Star(0, 0, height * 0.5, 0, 0x242A2E);
        star.antialiasing = ClientPrefs.data.antialiasing;
        var offsetMove = (bg.height - star.height) / 2;
        star.x += offsetMove * 1.25;
        star.y += offsetMove * 0.85;
        add(star);

        text = new FlxText(0, 0, 0, '0.99', Std.int(height * 0.25));
		text.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(height * 0.6), 0x242A2E, CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        text.borderStyle = NONE;
		text.antialiasing = ClientPrefs.data.antialiasing;
		text.x = star.x + star.width * 0.9;
		text.y = (bg.height - text.height) / 2;
		add(text);
    }

    public function setRate(rate:Float){
        text.text = Std.string(Math.floor(rate * 100) / 100);
        applyColorByValue(rate / 10, 1);
    }

    public function setGradient(values:Array<Float>, colors:Array<FlxColor>):Void{
        if (values == null || colors == null) return;
        if (values.length == 0 || colors.length == 0) return;
        if (values.length != colors.length) return;

        var stops:Array<StarRectColorStop> = [];
        for (i in 0...values.length){
            stops.push({value: values[i], color: colors[i]});
        }
        stops.sort(function(a, b){
            return (a.value < b.value) ? -1 : ((a.value > b.value) ? 1 : 0);
        });
        _colorStops = stops;
    }

    public function getColorByValue(value:Float):FlxColor{
        if (_colorStops == null || _colorStops.length == 0) return bg.color;
        if (_colorStops.length == 1) return _colorStops[0].color;

        var first = _colorStops[0];
        if (value <= first.value) return first.color;

        var last = _colorStops[_colorStops.length - 1];
        if (value >= last.value) return last.color;

        for (i in 0..._colorStops.length - 1){
            var a = _colorStops[i];
            var b = _colorStops[i + 1];
            if (value <= b.value){
                var denom = (b.value - a.value);
                var t:Float = (denom == 0) ? 1 : (value - a.value) / denom;
                if (t < 0) t = 0;
                if (t > 1) t = 1;
                return FlxColor.interpolate(a.color, b.color, t);
            }
        }
        return last.color;
    }

    public function applyColorByValue(value:Float, ?lerp:Float = 1):Void{
        var target = getColorByValue(value);
        if (lerp == null || lerp >= 1){
            bg.color = target;
            return;
        }
        if (lerp <= 0) return;
        bg.color = FlxColor.interpolate(bg.color, target, lerp);
    }
}
