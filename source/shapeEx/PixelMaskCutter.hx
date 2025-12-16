package shapeEx;

import flixel.FlxObject;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.math.FlxPoint;

class PixelMaskCutter
{
	public var mask:FlxSprite;
	public var shader:PixelMaskShader;

	public function new(maskObj:FlxObject)
	{
		if (Std.isOfType(maskObj, FlxSprite))
			mask = cast maskObj;
		else
			throw "PixelMaskCutter 需要 FlxSprite 作为遮罩对象";
		shader = new PixelMaskShader();
		shader.setMaskBitmap(mask.pixels);
	}

	public function cut(target:FlxSprite, inPlace:Bool = true, preserveAlpha:Bool = false):BitmapData
	{
		applyShader(target, preserveAlpha);
		return target.pixels;
	}

	public inline function cutSprite(target:FlxSprite):Void
	{
		applyShader(target, true);
	}

	function applyShader(target:FlxSprite, preserveAlpha:Bool):Void
	{
		var cam:FlxCamera = target.camera != null ? target.camera : FlxG.camera;
		var tp:FlxPoint = target.getScreenPosition(cam);
		var mp:FlxPoint = mask.getScreenPosition(cam);
		var tw:Float = target.frameWidth * target.scale.x;
		var th:Float = target.frameHeight * target.scale.y;
		var mw:Float = mask.frameWidth * mask.scale.x;
		var mh:Float = mask.frameHeight * mask.scale.y;

		shader.uMaskPos.value = [mp.x, mp.y];
		shader.uMaskSize.value = [mw, mh];
		shader.uTargetPos.value = [tp.x, tp.y];
		shader.uTargetSize.value = [tw, th];
		shader.uMultiplyAlpha.value = [preserveAlpha ? 1.0 : 0.0];
		target.shader = shader;
	}
}
