package objects.state.general;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.graphics.frames.FlxFramesCollection;

class ChangeSprite extends FlxSpriteGroup //背景切换
{
	var bg1:MoveSprite;
	var bg2:MoveSprite;

	public function new(X:Float, Y:Float)
	{
		super(X, Y);

        bg1 = new MoveSprite(0, 0);
        bg1.antialiasing = ClientPrefs.data.antialiasing;
		add(bg1);

		bg2 = new MoveSprite(0, 0);
        bg2.antialiasing = ClientPrefs.data.antialiasing;
		add(bg2);
	}

    public function load(graphic:FlxGraphicAsset, scaleValue:Float = 1.1) {
        bg1.load(graphic, scaleValue);
        bg2.load(graphic, scaleValue);
        return this;
    }

	var mainTween:FlxTween;
    public function changeSprite(graphic:Dynamic, time:Float = 0.6) {
        if (mainTween != null) { 
            mainTween.cancel();
        }

        if ((graphic is FlxFramesCollection))
		{
			bg2.frames = graphic;
		}
		else
		{
			bg2.loadGraphic(graphic, false, 0, 0, false, null);
		}
        
        mainTween = FlxTween.tween(bg1, {alpha: 0}, time, {
            ease: FlxEase.expoIn,
            onComplete: function(twn:FlxTween)
            {
              if ((graphic is FlxFramesCollection))
                {
                    bg1.frames = graphic;
                }
                else
                {
                    bg1.loadGraphic(graphic, false, 0, 0, false, null);
                }
              bg1.alpha = 1;
            }
		});
    }
}
