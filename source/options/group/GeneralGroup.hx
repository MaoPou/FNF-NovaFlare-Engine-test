package options.group;

import shaders.ColorblindFilter;
import options.OptionsState;
import flixel.addons.transition.FlxTransitionableState;

class GeneralGroup
{
    //var languages = ClientPrefs.data.language;
    static public function add(follow:OptionBG) {

        var option:Option = new Option(
            Language.getStr('General'),
            TITLE
        );
        follow.addOption(option);
       
        var reset:ResetRect = new ResetRect(450, 20, follow);
        follow.add(reset);

        var option:Option = new Option(
            Language.getStr('framerate'),
            'framerate',
            INT,
            24,
            500,
            'FPS'
        );
        follow.addOption(option);
        option.onChange = onChangeFramerate;

        var langArray:Array<String> = [Language.member[0], Language.member[1], Language.member[2]];
        var option:Option = new Option(
            Language.getStr('languageName'),
            'language',
            STRING,
            langArray
        );
        follow.addOption(option);
        option.onChange = onChangeLanguage;

        var colorblindFilterArray:Array<String> = ['None', 'Protanopia', 'Protanomaly', 'Deuteranopia','Deuteranomaly','Tritanopia','Tritanomaly','Achromatopsia','Achromatomaly'];

        var option:Option = new Option(
            Language.getStr('colorblindMode'),
            'colorblindMode',
            STRING,
            colorblindFilterArray
        );
        follow.addOption(option);
        option.onChange = onChangeFilter;

        var option:Option = new Option(
            Language.getStr('lowQuality'),
            'lowQuality',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('gameQuality'),
            'gameQuality',
            INT,
            0,
            3
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('antialiasing'),
            'antialiasing',
            BOOL
        );
        follow.addOption(option);
        
        var option:Option = new Option(
            Language.getStr('flashing'),
            'flashing',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('shaders'),
            'shaders',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('cacheOnGPU'),
            'cacheOnGPU',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('autoPause'),
            'autoPause',
            BOOL
        );
        follow.addOption(option);
        option.onChange = onChangePause;
    }

    static function onChangeFramerate()
    {
        if(ClientPrefs.data.framerate > FlxG.drawFramerate)
        {
            FlxG.updateFramerate = ClientPrefs.data.framerate;
            FlxG.drawFramerate = ClientPrefs.data.framerate;
        }
        else
        {
            FlxG.drawFramerate = ClientPrefs.data.framerate;
            FlxG.updateFramerate = ClientPrefs.data.framerate;
        }
    }

    static function onChangeFilter()
    {
        ColorblindFilter.UpdateColors();
    }
    

    static function onChangePause()
    {
        FlxG.autoPause = ClientPrefs.data.autoPause;
    }

    static function onChangeLanguage()
    {
        FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
        MusicBeatState.switchState(new OptionsState());
    }
}


    