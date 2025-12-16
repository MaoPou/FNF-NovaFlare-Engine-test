package shapeEx;

class SkewRoundRect extends FlxSprite
{
	public var mainRoundWidth:Float;
	public var mainRoundHeight:Float;

	public function new(
		X:Float = 0, Y:Float = 0,
		width:Float = 0, height:Float = 0,
		roundWidth:Float = 0, roundHeight:Float = 0,
		skewXDeg:Float = 0, skewYDeg:Float = 0,
		Color:FlxColor = FlxColor.WHITE, ?Alpha:Float = 1,
		?lineStyle:Int = 0, ?lineColor:FlxColor = FlxColor.WHITE
	)
	{
		super(X, Y);

		mainRoundWidth = roundWidth;
		mainRoundHeight = roundHeight;

		var key = 'skewRoundRect-w' + Std.int(width) + '-h:' + Std.int(height)
			+ '-rw:' + Std.int(roundWidth) + '-rh:' + Std.int(roundHeight)
			+ '-sx:' + Std.int(skewXDeg) + '-sy:' + Std.int(skewYDeg)
			+ '-ls:' + lineStyle + '-lc:' + lineColor;

		if (!Cache.checkFrame(key)) addCache(width, height, roundWidth, roundHeight, skewXDeg, skewYDeg, lineStyle, lineColor);
		frames = Cache.getFrame(key);

		antialiasing = ClientPrefs.data.antialiasing;
		color = Color;
		alpha = Alpha;
	}

	function addCache(
		width:Float, height:Float,
		roundWidth:Float, roundHeight:Float,
		skewXDeg:Float, skewYDeg:Float,
		lineStyle:Int, lineColor:FlxColor
	)
	{
		var bitmap:BitmapData = drawSkewRoundRect(width, height, roundWidth, roundHeight, skewXDeg, skewYDeg, lineStyle, lineColor);
		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;

		var key = 'skewRoundRect-w' + Std.int(width) + '-h:' + Std.int(height)
			+ '-rw:' + Std.int(roundWidth) + '-rh:' + Std.int(roundHeight)
			+ '-sx:' + Std.int(skewXDeg) + '-sy:' + Std.int(skewYDeg)
			+ '-ls:' + lineStyle + '-lc:' + lineColor;
		Cache.setFrame(key, graphic.imageFrame);
	}

	function drawSkewRoundRect(
		width:Float, height:Float,
		roundWidth:Float, roundHeight:Float,
		skewXDeg:Float, skewYDeg:Float,
		lineStyle:Int, lineColor:FlxColor
	):BitmapData
	{
		var sx = Math.tan(skewXDeg * Math.PI / 180);
		var sy = Math.tan(skewYDeg * Math.PI / 180);

		var targetW = Std.int(width + Math.abs(sx * height));
		var targetH = Std.int(height + Math.abs(sy * width));

		var tx = sx < 0 ? -sx * height : 0;
		var ty = sy < 0 ? -sy * width : 0;

		var m = new Matrix();
		m.a = 1;
		m.b = sy;
		m.c = sx;
		m.d = 1;
		m.tx = tx;
		m.ty = ty;

		var baseShape:Shape = new Shape();
		baseShape.graphics.beginFill(0xFFFFFF);
		baseShape.graphics.drawRoundRect(0, 0, Std.int(width), Std.int(height), roundWidth, roundHeight);
		baseShape.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(targetW, targetH, true, 0);
		bitmap.draw(baseShape, m);

		if (lineStyle > 0)
		{
			var borderShape:Shape = new Shape();
			borderShape.graphics.lineStyle(lineStyle, lineColor, 1);
			borderShape.graphics.drawRoundRect(0, 0, Std.int(width), Std.int(height), roundWidth, roundHeight);
			borderShape.graphics.endFill();
			bitmap.draw(borderShape, m);
		}

		return bitmap;
	}
}
