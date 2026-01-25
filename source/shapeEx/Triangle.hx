package shapeEx;
import openfl.display.Sprite;
import openfl.display.BlendMode;
import openfl.display.Shape;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.display.GraphicsPathCommand;
import openfl.display.GraphicsPathWinding;
import openfl.Vector;

class Triangle extends FlxSprite
{
	public function new(X:Float, Y:Float, Size:Float, Inner:Float)
	{
		super(X, Y);

		if (!Cache.checkFrame('triangle-v2-s:'+Std.int(Size)+'-i:'+Std.int(Inner))) addCache(Size, Inner);
		frames = Cache.getFrame('triangle-v2-s:'+Std.int(Size)+'-i:'+Std.int(Inner));
		antialiasing = ClientPrefs.data.antialiasing;
	}

	function addCache(sizeLength:Float, innerPixels:Float)
	{
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(drawHollowTriangle(sizeLength, innerPixels));
		newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;
		Cache.setFrame('triangle-v2-s:'+Std.int(sizeLength)+'-i:'+Std.int(innerPixels), {graphic:newGraphic, frame:null});
	}

	function drawHollowTriangle(sideLength:Float, innerPixels:Float):BitmapData
	{
		var ring:Shape = new Shape();

		var h:Float = sideLength * Math.sqrt(3) / 2;
		var margin:Int = 4;
		var bw:Int = Std.int(sideLength + margin * 2);
		var R:Float = sideLength / Math.sqrt(3);
		var bh:Int = Std.int(2 * (margin + R));

		var cx:Float = bw / 2;
		var cy:Float = bh / 2;
		var a1:Float = -Math.PI / 2;
		var a2:Float = a1 + 2 * Math.PI / 3;
		var a3:Float = a1 + 4 * Math.PI / 3;
		var p1:Point = new Point(cx + R * Math.cos(a1), cy + R * Math.sin(a1));
		var p2:Point = new Point(cx + R * Math.cos(a2), cy + R * Math.sin(a2));
		var p3:Point = new Point(cx + R * Math.cos(a3), cy + R * Math.sin(a3));

		var innerSide:Float = Math.min(Math.max(innerPixels, 0), sideLength);
		var scale:Float = innerSide / sideLength;

		var ip1:Point = new Point(cx + (p1.x - cx) * scale, cy + (p1.y - cy) * scale);
		var ip2:Point = new Point(cx + (p2.x - cx) * scale, cy + (p2.y - cy) * scale);
		var ip3:Point = new Point(cx + (p3.x - cx) * scale, cy + (p3.y - cy) * scale);

		var commands:Vector<Int> = new Vector<Int>();
		var data:Vector<Float> = new Vector<Float>();
		commands.push(GraphicsPathCommand.MOVE_TO);
		data.push(p1.x); data.push(p1.y);
		commands.push(GraphicsPathCommand.LINE_TO);
		data.push(p2.x); data.push(p2.y);
		commands.push(GraphicsPathCommand.LINE_TO);
		data.push(p3.x); data.push(p3.y);
		commands.push(GraphicsPathCommand.LINE_TO);
		data.push(p1.x); data.push(p1.y);
		commands.push(GraphicsPathCommand.MOVE_TO);
		data.push(ip1.x); data.push(ip1.y);
		commands.push(GraphicsPathCommand.LINE_TO);
		data.push(ip2.x); data.push(ip2.y);
		commands.push(GraphicsPathCommand.LINE_TO);
		data.push(ip3.x); data.push(ip3.y);
		commands.push(GraphicsPathCommand.LINE_TO);
		data.push(ip1.x); data.push(ip1.y);

		ring.graphics.beginFill(0xFFFFFF);
		ring.graphics.drawPath(commands, data, GraphicsPathWinding.EVEN_ODD);
		ring.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(bw, bh, true, 0);
		bitmap.draw(ring);
		return bitmap;
	}
}
