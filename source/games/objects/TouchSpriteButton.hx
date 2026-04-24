package games.objects;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;

class TouchSpriteButton extends FlxSprite
{
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
	}

	public function touchJustPressed(cam:FlxCamera):Bool
	{
		for (touch in FlxG.touches.list)
		{
			if (!touch.justPressed) continue;

			var p = touch.getScreenPosition(cam);
			if (p.x >= x && p.x <= x + width && p.y >= y && p.y <= y + height)
				return true;
		}
		return false;
	}
}
