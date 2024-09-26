package options.group;

class GameplayGroup
{
    static public function add(follow:OptionBG) {

        var option:Option = new Option(
            Language.getStr('Gameplay'),
            TITLE
        );
        follow.addOption(option);

        var reset:ResetRect = new ResetRect(450, 20, follow);
        follow.add(reset);

        var option:Option = new Option(
            Language.getStr('downScroll'),
            'downScroll',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('middleScroll'),
            'middleScroll',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('ghostTapping'),
            'ghostTapping',
            BOOL
        );
        follow.addOption(option);
    }
}
