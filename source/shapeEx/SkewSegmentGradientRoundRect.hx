package shapeEx;

class SkewSegmentGradientRoundRect extends FlxSprite
{
	public var mainRoundWidth:Float;
	public var mainRoundHeight:Float;
	public var baseAlpha:Float;
	public var pStart:Array<Float>;
	public var pEnd:Array<Float>;

	public function new(
		X:Float = 0, Y:Float = 0,
		width:Float = 0, height:Float = 0,
		roundWidth:Float = 0, roundHeight:Float = 0,
		skewXDeg:Float = 0, skewYDeg:Float = 0,
		color:FlxColor = FlxColor.WHITE,
		pairs:Array<Array<Float>>,
		?alphaMul:Float = 1.0
	)
	{
		super(X, Y);
		mainRoundWidth = roundWidth;
		mainRoundHeight = roundHeight;
		baseAlpha = alphaMul;
		var key = getKey(width, height, roundWidth, roundHeight, skewXDeg, skewYDeg, pairs, alphaMul);
		if (!Cache.checkFrame(key)) addCache(width, height, roundWidth, roundHeight, skewXDeg, skewYDeg, pairs, alphaMul);
		frames = Cache.getFrame(key);
		antialiasing = ClientPrefs.data.antialiasing;
		this.color = color;
		alpha = 1.0;
	}

	function getKey(
		w:Float, h:Float,
		rw:Float, rh:Float,
		sxDeg:Float, syDeg:Float,
		pairs:Array<Array<Float>>,
		a:Float
	):String
	{
		var s = pairs != null && pairs.length >= 1 ? pairs[0] : [0.0, 0.0, 0.0];
		var e = pairs != null && pairs.length >= 2 ? pairs[1] : [1.0, 0.0, 1.0];
		return 'skewSegGradRoundRect-w' + Std.int(w) + '-h:' + Std.int(h)
			+ '-rw:' + Std.int(rw) + '-rh:' + Std.int(rh)
			+ '-sx:' + Std.int(sxDeg) + '-sy:' + Std.int(syDeg)
			+ '-a:' + Std.int(a * 1000)
			+ '-s:' + Std.int(s[0] * 1000) + ',' + Std.int(s[1] * 1000) + ',' + Std.int(s[2] * 1000)
			+ '-e:' + Std.int(e[0] * 1000) + ',' + Std.int(e[1] * 1000) + ',' + Std.int(e[2] * 1000);
	}

	function addCache(
		width:Float, height:Float,
		roundWidth:Float, roundHeight:Float,
		skewXDeg:Float, skewYDeg:Float,
		pairs:Array<Array<Float>>,
		alphaMul:Float
	)
	{
		var bitmap:BitmapData = drawSkewSegmentGradientRoundRect(width, height, roundWidth, roundHeight, skewXDeg, skewYDeg, pairs, alphaMul);
		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;
		var key = getKey(width, height, roundWidth, roundHeight, skewXDeg, skewYDeg, pairs, alphaMul);
		Cache.setFrame(key, {graphic:graphic, frame:null});
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

	function drawSkewSegmentGradientRoundRect(
		width:Float, height:Float,
		roundWidth:Float, roundHeight:Float,
		skewXDeg:Float, skewYDeg:Float,
		pairs:Array<Array<Float>>,
		alphaMul:Float
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
		var mask:BitmapData = new BitmapData(targetW, targetH, true, 0);
		mask.draw(baseShape, m);
		var s = normalizePoint(targetW, targetH, pairs != null && pairs.length >= 1 ? pairs[0] : [0, 0, 0]);
		var e = normalizePoint(targetW, targetH, pairs != null && pairs.length >= 2 ? pairs[1] : [targetW - 1, 0, 1]);
		var bmp:BitmapData = new BitmapData(targetW, targetH, true, 0);
		for (y in 0...targetH) {
			for (x in 0...targetW) {
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
