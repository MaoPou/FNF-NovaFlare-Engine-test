package options.objects.controlsSubState;

import flixel.util.FlxSpriteUtil;

class RabSprite extends FlxSpriteGroup
{
    public var sprite:FlxSprite;
    public var text:FlxText;

    public function new(x:Float, y:Float, wwidth:Float, hheight:Float, color:FlxColor = 0xFF908BB0, label:String = "")
    {
        super();

        sprite = new FlxSprite(x, y);
        sprite.makeGraphic(Std.int(wwidth), Std.int(hheight), FlxColor.TRANSPARENT, true);
        FlxSpriteUtil.drawRoundRectComplex(sprite, 0, 0, wwidth, hheight, 0, 0, 16, 16, color);
        sprite.updateHitbox();
        add(sprite);

        text = new FlxText(x, y, wwidth, label);
        text.autoSize = true;
        text.setFormat(Paths.font(Language.get('fontName', 'main') + '.ttf'), 16, FlxColor.WHITE, CENTER);
        text.fieldHeight = hheight;
        text.updateHitbox();
        add(text);

        centerSprite(text, sprite);
    }

    public function setScale(e:String, i:Float)
    {
        switch (e)
        {
            case "x":
                sprite.scale.x = i;
                text.scale.x = i;
            case "y":
                sprite.scale.y = i;
                text.scale.y = i;
        }

        sprite.updateHitbox();
        text.updateHitbox();

        centerSprite(text, sprite);
    }

    public function centerSprite(yourSprite:Dynamic, Sprite:Dynamic):Void
    {
        var x = Sprite.x + (Sprite.width / 2) - (yourSprite.width / 2);
        var y = Sprite.y + (Sprite.height / 2) - (yourSprite.height / 2);

        yourSprite.setPosition(x, y);
    }
}