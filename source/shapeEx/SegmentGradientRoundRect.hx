package shapeEx;

class SegmentGradientRoundRect extends FlxSprite
{
	public var mainWidth:Int;
	public var mainHeight:Int;
	public var mainRound:Float;
	public var mainColor:FlxColor;
	public var baseAlpha:Float;
	public var pStart:Array<Float>;
	public var pEnd:Array<Float>;

	public function new(X:Float = 0, Y:Float = 0, width:Int, height:Int, round:Float, color:FlxColor = FlxColor.WHITE, pairs:Array<Array<Float>>, ?alphaMul:Float = 1.0)
	{
		super(X, Y);
		mainWidth = width;
		mainHeight = height;
		mainRound = round;
		mainColor = color;
		baseAlpha = alphaMul;
		pStart = normalizePoint(width, height, pairs != null && pairs.length >= 1 ? pairs[0] : [0, 0, 0]);
		pEnd = normalizePoint(width, height, pairs != null && pairs.length >= 2 ? pairs[1] : [width - 1, 0, 1]);

		var key = getKey(width, height, round, pStart, pEnd, alphaMul);
		if (!Cache.checkFrame(key)) addCache(width, height, round, pStart, pEnd, alphaMul);
		frames = Cache.getFrame(key);
		antialiasing = ClientPrefs.data.antialiasing;
		this.color = color;
		alpha = 1.0;
	}

	function getKey(w:Int, h:Int, r:Float, s:Array<Float>, e:Array<Float>, a:Float):String
	{
		return 'segGradRoundRect-w' + w + '-h:' + h + '-r:' + Std.int(r) +
			'-a:' + Std.int(a * 1000) +
			'-s:' + Std.int(s[0]) + ',' + Std.int(s[1]) + ',' + Std.int(s[2] * 1000) +
			'-e:' + Std.int(e[0]) + ',' + Std.int(e[1]) + ',' + Std.int(e[2] * 1000);
	}

	function addCache(width:Int, height:Int, round:Float, s:Array<Float>, e:Array<Float>, alphaMul:Float)
	{
		var bmp = drawSegmentGradientRoundRect(width, height, round, s, e, alphaMul);
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bmp);
		newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;
		Cache.setFrame(getKey(width, height, round, s, e, alphaMul), {graphic:newGraphic, frame:null});
	}

	inline function normalizePoint(w:Int, h:Int, p:Array<Float>):Array<Float>
	{
		var sx = p != null && p.length > 0 ? p[0] : 0;
		var sy = p != null && p.length > 1 ? p[1] : 0;
		var sa = p != null && p.length > 2 ? p[2] : 1;
		if (sx >= 0 && sx <= 1) sx = sx * (w - 1);
		if (sy >= 0 && sy <= 1) sy = sy * (h - 1);
		if (sx < 0) sx = 0;
		if (sy < 0) sy = 0;
		if (sx > w - 1) sx = w - 1;
		if (sy > h - 1) sy = h - 1;
		sa = clamp(sa);
		return [sx, sy, sa];
	}

	inline function alphaAlongSegment(px:Float, py:Float, sx:Float, sy:Float, sa:Float, ex:Float, ey:Float, ea:Float):Float
	{
		var dx = ex - sx;
		var dy = ey - sy;
		var len2 = dx * dx + dy * dy;
		if (len2 <= 0.000001) return sa;
		var tRaw = ((px - sx) * dx + (py - sy) * dy) / len2;
		if (tRaw <= 0) return sa;
		if (tRaw >= 1) return ea;
		return clamp(sa + tRaw * (ea - sa));
	}

	function drawSegmentGradientRoundRect(width:Int, height:Int, round:Float, s:Array<Float>, e:Array<Float>, alphaMul:Float):BitmapData
	{
		var bmp = new BitmapData(width, height, true, 0);
		var w = width;
		var h = height;
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0xFFFFFF);
		shape.graphics.drawRoundRect(0, 0, w, h, round, round);
		shape.graphics.endFill();
		var mask:BitmapData = new BitmapData(w, h, true, 0);
		mask.draw(shape);
		for (y in 0...h) {
			for (x in 0...w) {
				var ma = (mask.getPixel32(x, y) >>> 24) & 0xFF;
				if (ma == 0) continue;
				var a = alphaAlongSegment(x, y, s[0], s[1], s[2], e[0], e[1], e[2]);
				a = clamp(a * alphaMul);
				var ab = Std.int(a * ma) & 0xFF;
				bmp.setPixel32(x, y, (ab << 24) | 0xFFFFFF);
			}
		}
		return bmp;
	}

	inline function clamp(v:Float):Float
	{
		return v < 0 ? 0 : (v > 1 ? 1 : v);
	}
}
