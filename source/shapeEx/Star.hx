package shapeEx;

class Star extends FlxSprite
{
	public function new(
		X:Float = 0, Y:Float = 0,
		outerRadius:Float = 0, innerRatio:Float = 0.5,
		Color:FlxColor = FlxColor.WHITE, ?Alpha:Float = 1,
		?lineStyle:Int = 0, ?lineColor:FlxColor = FlxColor.WHITE
	)
	{
		super(X, Y);
		var key = 'star5-or:' + Std.int(outerRadius) + '-ir:' + Std.int(innerRatio * 100) + '-ls:' + lineStyle + '-lc:' + lineColor;
		if (!Cache.checkFrame(key)) addCache(outerRadius, innerRatio, lineStyle, lineColor);
		frames = Cache.getFrame(key);
		antialiasing = ClientPrefs.data.antialiasing;
		color = Color;
		alpha = Alpha;
	}

	function addCache(outerRadius:Float, innerRatio:Float, lineStyle:Int, lineColor:FlxColor)
	{
		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(drawStar5(outerRadius, innerRatio, lineStyle, lineColor));
		graphic.persist = true;
		graphic.destroyOnNoUse = false;
		var key = 'star5-or:' + Std.int(outerRadius) + '-ir:' + Std.int(innerRatio * 100) + '-ls:' + lineStyle + '-lc:' + lineColor;
		Cache.setFrame(key, graphic.imageFrame);
	}

	function drawStar5(outerRadius:Float, innerRatio:Float, lineStyle:Int, lineColor:FlxColor):BitmapData
	{
		var margin:Int = 4;
		var rOuter:Float = outerRadius;
		var rInner:Float = rOuter * innerRatio;
		var bw:Int = Std.int(rOuter * 2 + margin * 2);
		var bh:Int = bw;
		var cx:Float = bw / 2;
		var cy:Float = bh / 2;

		var shape:Shape = new Shape();
		shape.graphics.beginFill(0xFFFFFF);
		for (i in 0...5)
		{
			var aOuter:Float = -Math.PI / 2 + i * (2 * Math.PI / 5);
			var aInner:Float = aOuter + Math.PI / 5;
			var ox:Float = cx + rOuter * Math.cos(aOuter);
			var oy:Float = cy + rOuter * Math.sin(aOuter);
			var ix:Float = cx + rInner * Math.cos(aInner);
			var iy:Float = cy + rInner * Math.sin(aInner);
			if (i == 0) shape.graphics.moveTo(ox, oy);
			else shape.graphics.lineTo(ox, oy);
			shape.graphics.lineTo(ix, iy);
		}
		shape.graphics.lineTo(cx + rOuter * Math.cos(-Math.PI / 2), cy + rOuter * Math.sin(-Math.PI / 2));
		shape.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(bw, bh, true, 0);
		bitmap.draw(shape);

		if (lineStyle > 0)
		{
			var border:Shape = new Shape();
			border.graphics.lineStyle(lineStyle, lineColor, 1);
			for (i in 0...5)
			{
				var aOuter:Float = -Math.PI / 2 + i * (2 * Math.PI / 5);
				var aInner:Float = aOuter + Math.PI / 5;
				var ox:Float = cx + rOuter * Math.cos(aOuter);
				var oy:Float = cy + rOuter * Math.sin(aOuter);
				var ix:Float = cx + rInner * Math.cos(aInner);
				var iy:Float = cy + rInner * Math.sin(aInner);
				if (i == 0) border.graphics.moveTo(ox, oy);
				else border.graphics.lineTo(ox, oy);
				border.graphics.lineTo(ix, iy);
			}
			border.graphics.lineTo(cx + rOuter * Math.cos(-Math.PI / 2), cy + rOuter * Math.sin(-Math.PI / 2));
			bitmap.draw(border);
		}

		return bitmap;
	}
}
