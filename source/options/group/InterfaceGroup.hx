package options.group;

class InterfaceGroup
{
    static public function add(follow:OptionBG) {
        var option:Option = new Option(
            Language.getStr('UserInterface'),
            TITLE
        );
        follow.addOption(option);

        var reset:ResetRect = new ResetRect(450, 20, follow);
        follow.add(reset);

        var CustomFadeArray:Array<String> = ['Move', 'Alpha'];

        var option:Option = new Option(
            Language.getStr('CustomFade'),
            'CustomFade',
            STRING,
            CustomFadeArray
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('CustomFadeSound'),
            'CustomFadeSound',
            FLOAT,
            0,
            1,
            1
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('CustomFadeText'),
            'CustomFadeText',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('resultsScreen'),
            'resultsScreen',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('loadingScreen'),
            'loadingScreen',
            BOOL
        );
        follow.addOption(option);
    }
}
