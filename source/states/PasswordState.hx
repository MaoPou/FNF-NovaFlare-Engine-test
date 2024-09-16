package states;

import flixel.addons.ui.FlxUIInputText;
import flixel.addons.transition.FlxTransitionableState;
import states.MainMenuState;

class PasswordState extends MusicBeatState
{
    public var needpass:Bool = true;

    override function create()
	{
		super.create();
		var password:FlxUIInputText;
	                                                                                                                                                                                                var fuckpass = "immaopou";
		password = new FlxUIInputText(200, 200, 500, "Please Enter PassWord");
		
		addVirtualPad(NONE, A);
	}
	
	override function update(elapsed:Float)
	{
	    if (controls.ACCEPT)
	    {
	        if (password == fuckpass)
	        {
	            MusicBeatState.switchState(new TitleState());
	            ClientPrefs.data.needpass = false;
	        }
	    }
	
	    super.update(elapsed);
	}
}