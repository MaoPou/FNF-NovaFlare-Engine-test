package options.group;

class InputGroup
{
    static public function add(follow:OptionBG) {
        var option:Option = new Option(
            Language.getStr('Input'),
            TITLE
        );
        follow.addOption(option);

        var reset:ResetRect = new ResetRect(450, 20, follow);
        follow.add(reset);

        ///////////////////////////////

        var option:Option = new Option(
            Language.getStr('ControlsSubState'),
            'ControlsSubState',
            STATE
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('TouchMain'),
            TEXT
        );
        follow.addOption(option);
        
        #if desktop
        var option:Option = new Option(
            Language.getStr('needMobileControl'),
            'needMobileControl',
            BOOL
        );
        follow.addOption(option);
        #end

        var option:Option = new Option(
            Language.getStr('controlsAlpha'),
            'controlsAlpha',
            FLOAT,
            0,
            1,
            1
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('TouchGame'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('MobileControlSelectSubState'),
            'MobileControlSelectSubState',
            STATE
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('dynamicColors'),
            'dynamicColors',
            BOOL
        );
        follow.addOption(option);

        var hitboxLocationArray:Array<String> = ['Bottom', 'Top'];

        var option:Option = new Option(
            Language.getStr('hitboxLocation'),
            'hitboxLocation',
            STRING,
            hitboxLocationArray
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('playControlsAlpha'),
            'playControlsAlpha',
            FLOAT,
            0,
            1,
            1
        );
        follow.addOption(option);
    }
}
