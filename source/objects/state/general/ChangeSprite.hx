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
		

		bg2 = new MoveSprite(0, 0);
        bg2.antialiasing = ClientPrefs.data.antialiasing;
		add(bg2);

        add(bg1);
	}

    public function load(graphic:FlxGraphicAsset, scaleValue:Float = 1.05) {
        bg1.load(graphic, scaleValue);
        bg2.load(graphic, scaleValue);
        return this;
    }

	var mainTween:FlxTween;
    var fixTween:FlxTween;
    var lastLoadGraphic:Dynamic;
    public function changeSprite(graphic:Dynamic, time:Float = 0.6) {
        if (lastLoadGraphic == graphic) return;
        lastLoadGraphic = graphic;

        if (mainTween != null || fixTween != null) {
            if (mainTween != null) mainTween.cancel();
            if (fixTween != null) fixTween.cancel();

            fixTween = FlxTween.tween(bg1, {alpha: 1}, time / 2, {
                ease: FlxEase.linear,
                onComplete: function(twn:FlxTween)
                {
                    updateGraphic(bg2, graphic);
                    mainTween = FlxTween.tween(bg1, {alpha: 0}, time, {
                        ease: FlxEase.linear,
                        onComplete: function(twn:FlxTween)
                        {
                        updateGraphic(bg1, graphic);
                        bg1.alpha = 1;
                        }
                    });
                }
            });

            return;
        }

        updateGraphic(bg2, graphic);
        mainTween = FlxTween.tween(bg1, {alpha: 0}, time, {
            ease: FlxEase.linear,
            onComplete: function(twn:FlxTween)
            {
                updateGraphic(bg1, graphic);
                bg1.alpha = 1;
            }
		});
    }

    private function updateGraphic(bg:MoveSprite, graphic:Dynamic) {
        if ((graphic is FlxFramesCollection))
			bg.frames = graphic;
		else
			bg.loadGraphic(graphic, false, 0, 0, false, null);

        bg.updateSize();
    }

    public function changeColor(color:Int, time:Float = 0.6) {
        bg1.changeColor(color, time);
        bg2.changeColor(color, time);
    }
}
