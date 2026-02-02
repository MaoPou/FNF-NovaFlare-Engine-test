package objects.state.general;

import flixel.system.FlxAssets.FlxGraphicAsset;

class MoveSprite extends FlxSprite{

	public var bgFollowSmooth:Float = 15;

    public var allowMove:Bool = true;

    public function new(X:Float = 0, Y:Float = 0) {
        super(X, Y);
    }

	private var realWidth:Float;
	private var realHeight:Float;
	private var scaleValue:Float = 1.05;
    public function load(graphic:FlxGraphicAsset, scaleValue:Float = 1.05) {
        this.loadGraphic(graphic, false, 0, 0, false);
		this.scaleValue = scaleValue;
        updateSize();
    }

	public function updateSize() {
		var scale = Math.max(FlxG.width * scaleValue / this.width, FlxG.height * scaleValue / this.height);
		realWidth = this.width * scale;
		realHeight = this.height * scale;
		this.scale.x = this.scale.y = scale;
		this.offset.x = this.offset.y = 0;
        updateHitbox();
    }
    
	private var offsetX:Float = 0;
    private var offsetY:Float = 0;
    override function draw()
	{
		super.draw();
        if (allowMove) {
			var mouseX = FlxG.mouse.getWorldPosition().x;
			var mouseY = FlxG.mouse.getWorldPosition().y;
			var centerX = FlxG.width / 2;
			var centerY = FlxG.height / 2;
			
			var targetOffsetX = Math.min(0.99, (mouseX - centerX) / (FlxG.width / 2)) * (realWidth - FlxG.width) / 2;
			var targetOffsetY = Math.min(0.99, (mouseY - centerY) / (FlxG.height / 2)) * (realHeight - FlxG.height) / 2;
			
			if (Math.abs(offsetX - targetOffsetX) > 0.5) offsetX = FlxMath.lerp(targetOffsetX, offsetX, Math.exp(-FlxG.drawElapsed * bgFollowSmooth));
			else offsetX = targetOffsetX;
			if (Math.abs(offsetY - targetOffsetY) > 0.5) offsetY = FlxMath.lerp(targetOffsetY, offsetY, Math.exp(-FlxG.drawElapsed * bgFollowSmooth));
			else offsetY = targetOffsetY;
			
			this.x = centerX - realWidth / 2 + offsetX;
			this.y = centerY - realHeight / 2 + offsetY;
		}
    }

	var colorTween:FlxTween = null;
	public function changeColor(color:Int, time:Float = 0.6) {
		if (colorTween != null) colorTween.cancel();
		var sr = this.color;
		var er = color;
		var startRGB:FlxColor = FlxColor.fromRGB((sr >> 16) & 0xFF, (sr >> 8) & 0xFF, sr & 0xFF);
		var endRGB:FlxColor = FlxColor.fromRGB((er >> 16) & 0xFF, (er >> 8) & 0xFF, er & 0xFF);
		colorTween = FlxTween.num(0, 1, time, null, function(v:Float) {
			this.color = FlxColor.interpolate(startRGB, endRGB, v);
		});
	}
}
