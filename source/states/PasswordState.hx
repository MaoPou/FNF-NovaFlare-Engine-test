package states;

import flixel.FlxSubState;

import flixel.addons.transition.FlxTransitionableState;
import states.MainMenuState;

import flixel.FlxState;
import flixel.FlxG;
import flixel.ui.FlxTextInput;
import flixel.ui.FlxText;

class PasswordState extends MusicBeatState
{
    private var passwordInput:FlxTextInput;
    private var feedbackText:FlxText;
    private var correctPassword:String = "maopouyyds";

    override public function create():Void
    {
        super.create();

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		add(bg);

        // 创建密码输入框
        passwordInput = new FlxTextInput(50, 50, 200);
        add(passwordInput);

        // 创建反馈文本
        feedbackText = new FlxText(50, 100, 200, "");
        feedbackText.setFormat(null, 16, FlxG.WHITE, "center");
        add(feedbackText);
        
        addVirtualPad(NONE, A);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if if (controls.ACCEPT)
        {
            if (passwordInput.text == correctPassword)
            {
                feedbackText.text = "Password Correct!";

                onPasswordCorrect();
            }
            else
            {
                feedbackText.text = "Incorrect Password!";
            }
        }
    }

    private function onPasswordCorrect():Void
    {
        MusicBeatState.switchState(new MainMenuState());
    }
}