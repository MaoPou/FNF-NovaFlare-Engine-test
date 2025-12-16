package shapeEx;
import openfl.display.Sprite;
import openfl.display.BlendMode;

class Triangle extends FlxSprite
{
	public function new(X:Float, Y:Float, Size:Float, Inner:Float)
	{
		super(X, Y);

		if (!Cache.checkFrame('triangle-s:'+Std.int(Size)+'-i:'+Std.int(Inner * 100))) addCache(Size, Inner);
		frames = Cache.getFrame('triangle-s:'+Std.int(Size)+'-i:'+Std.int(Inner * 100));
		antialiasing = ClientPrefs.data.antialiasing;
	}

	function addCache(sizeLength:Float, innerRatio:Float)
	{
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(drawHollowTriangle(sizeLength, innerRatio));
		newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;
		Cache.setFrame('triangle-s:'+Std.int(sizeLength)+'-i:'+Std.int(innerRatio * 100), newGraphic.imageFrame);
	}

	function drawHollowTriangle(sideLength:Float, innerRatio:Float):BitmapData
	{
		var container:Sprite = new Sprite();
		var outer:Shape = new Shape();
		var inner:Shape = new Shape();

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

		var innerSide:Float = sideLength * (1 - innerRatio);
		var scale:Float = innerSide / sideLength;

		var ip1:Point = new Point(cx + (p1.x - cx) * scale, cy + (p1.y - cy) * scale);
		var ip2:Point = new Point(cx + (p2.x - cx) * scale, cy + (p2.y - cy) * scale);
		var ip3:Point = new Point(cx + (p3.x - cx) * scale, cy + (p3.y - cy) * scale);

		outer.graphics.beginFill(0xFFFFFF);
		outer.graphics.lineStyle(2, 0xFFFFFF, 1);
		outer.graphics.moveTo(p1.x, p1.y);
		outer.graphics.lineTo(p2.x, p2.y);
		outer.graphics.lineTo(p3.x, p3.y);
		outer.graphics.lineTo(p1.x, p1.y);
		outer.graphics.endFill();

		inner.graphics.beginFill(0xFFFFFF);
		inner.graphics.moveTo(ip1.x, ip1.y);
		inner.graphics.lineTo(ip2.x, ip2.y);
		inner.graphics.lineTo(ip3.x, ip3.y);
		inner.graphics.lineTo(ip1.x, ip1.y);
		inner.graphics.endFill();
		inner.blendMode = BlendMode.ERASE;

		container.addChild(outer);
		container.addChild(inner);

		var bitmap:BitmapData = new BitmapData(bw, bh, true, 0);
		bitmap.draw(container);
		return bitmap;
	}
}
