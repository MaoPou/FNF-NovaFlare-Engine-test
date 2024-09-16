package states;

import flixel.addons.ui.FlxUIInputText;
import flixel.addons.transition.FlxTransitionableState;
import states.MainMenuState;

class PasswordState extends MusicBeatState
{
    private var password:FlxUIInputText;
	                                                                                                                                                                                              private var fuckpass = "immaopou";
    override function create()
	{
		super.create();
		password = new FlxUIInputText(200, 200, 500, "Please Enter PassWord");
		add(password);
		
		addVirtualPad(NONE, A);
	}
	
	override function update(elapsed:Float)
	{
	    if (controls.ACCEPT)
	    {
	        if (password.text == fuckpass)
	        {
	            MusicBeatState.switchState(new TitleState());
	            ClientPrefs.data.needpass = false;
	        }
	    }
	
	    super.update(elapsed);
	}
}