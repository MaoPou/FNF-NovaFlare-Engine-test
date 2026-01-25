package shapeEx;

import openfl.display.GraphicsPathCommand;
import openfl.display.GraphicsPathWinding;
import openfl.Vector;

class Star extends FlxSprite
{
	public function new(
		X:Float = 0, Y:Float = 0,
		size:Float = 0, innerRatio:Float = 0.5,
		Color:FlxColor = FlxColor.WHITE, ?Alpha:Float = 1,
		?lineStyle:Int = 0, ?lineColor:FlxColor = FlxColor.WHITE
	)
	{
		super(X, Y);
		var key = 'star5-s:' + Std.int(size) + '-ir:' + Std.int(innerRatio * 100) + '-ls:' + lineStyle + '-lc:' + lineColor;
		if (!Cache.checkFrame(key)) addCache(size, innerRatio, lineStyle, lineColor);
		frames = Cache.getFrame(key);
		antialiasing = ClientPrefs.data.antialiasing;
		color = Color;
		alpha = Alpha;
	}

	function addCache(size:Float, innerRatio:Float, lineStyle:Int, lineColor:FlxColor)
	{
		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(drawStar5(size, innerRatio, lineStyle, lineColor));
		graphic.persist = true;
		graphic.destroyOnNoUse = true;
		var key = 'star5-s:' + Std.int(size) + '-ir:' + Std.int(innerRatio * 100) + '-ls:' + lineStyle + '-lc:' + lineColor;
		Cache.setFrame(key, {graphic:graphic, frame:null});
	}

	function drawStar5(size:Float, innerRatio:Float, lineStyle:Int, lineColor:FlxColor):BitmapData
	{
		var rOuter:Float = size / 2;
		var k:Float = Math.sin(Math.PI / 10) / Math.sin(3 * Math.PI / 10);
		var rInner:Float = rOuter * k;
		var bw:Int = Std.int(size);
		var bh:Int = Std.int(size);
		var cx:Float = bw / 2;
		var cy:Float = bh / 2;

		var ring:Shape = new Shape();
		var commands:Vector<Int> = new Vector<Int>();
		var data:Vector<Float> = new Vector<Float>();

		for (i in 0...5)
		{
			var aOuter:Float = -Math.PI / 2 + i * (2 * Math.PI / 5);
			var aInner:Float = aOuter + Math.PI / 5;
			var ox:Float = cx + rOuter * Math.cos(aOuter);
			var oy:Float = cy + rOuter * Math.sin(aOuter);
			var ix:Float = cx + rInner * Math.cos(aInner);
			var iy:Float = cy + rInner * Math.sin(aInner);
			if (i == 0) {
				commands.push(GraphicsPathCommand.MOVE_TO);
				data.push(ox); data.push(oy);
			} else {
				commands.push(GraphicsPathCommand.LINE_TO);
				data.push(ox); data.push(oy);
			}
			commands.push(GraphicsPathCommand.LINE_TO);
			data.push(ix); data.push(iy);
		}
		commands.push(GraphicsPathCommand.LINE_TO);
		data.push(cx + rOuter * Math.cos(-Math.PI / 2)); data.push(cy + rOuter * Math.sin(-Math.PI / 2));

		var ir:Float = Math.max(0, Math.min(innerRatio, 0.98));
		var rOuter2:Float = rOuter * ir;
		var rInner2:Float = rOuter2 * k;
		for (i in 0...5)
		{
			var aOuter2:Float = -Math.PI / 2 + i * (2 * Math.PI / 5);
			var aInner2:Float = aOuter2 + Math.PI / 5;
			var ox2:Float = cx + rOuter2 * Math.cos(aOuter2);
			var oy2:Float = cy + rOuter2 * Math.sin(aOuter2);
			var ix2:Float = cx + rInner2 * Math.cos(aInner2);
			var iy2:Float = cy + rInner2 * Math.sin(aInner2);
			if (i == 0) {
				commands.push(GraphicsPathCommand.MOVE_TO);
				data.push(ox2); data.push(oy2);
			} else {
				commands.push(GraphicsPathCommand.LINE_TO);
				data.push(ox2); data.push(oy2);
			}
			commands.push(GraphicsPathCommand.LINE_TO);
			data.push(ix2); data.push(iy2);
		}
		commands.push(GraphicsPathCommand.LINE_TO);
		data.push(cx + rOuter2 * Math.cos(-Math.PI / 2)); data.push(cy + rOuter2 * Math.sin(-Math.PI / 2));

		ring.graphics.beginFill(0xFFFFFF);
		ring.graphics.drawPath(commands, data, GraphicsPathWinding.EVEN_ODD);
		ring.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(bw, bh, true, 0);
		bitmap.draw(ring);

		if (lineStyle > 0)
		{
			var outline:Shape = new Shape();
			outline.graphics.lineStyle(lineStyle, lineColor, 1);
			outline.graphics.drawPath(commands, data, GraphicsPathWinding.EVEN_ODD);
			bitmap.draw(outline);
		}

		return bitmap;
	}
}
