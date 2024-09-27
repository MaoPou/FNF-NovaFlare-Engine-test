package options.group;

class UIGroup
{
    static public function add(follow:OptionBG) {
        var option:Option = new Option(
            Language.getStr('GameUI'),
            TITLE
        );
        follow.addOption(option);

        var reset:ResetRect = new ResetRect(450, 20, follow);
        follow.add(reset);

        ///////////////////////////////

        var option:Option = new Option(
            Language.getStr('TimeBar'),
            TEXT
        );
        follow.addOption(option);

        var TimeBarArray:Array<String> = ['Time Left', 'Time Elapsed', 'Song Name', 'Disabled'];
        var option:Option = new Option(
            Language.getStr('timeBarType'),
            'timeBarType',
            STRING,
            TimeBarArray
        );
        follow.addOption(option);

        ///////////////////////////////
    }
}
