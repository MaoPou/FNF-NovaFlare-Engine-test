package options.group;

class BackendGroup
{
    static public function add(follow:OptionBG) {
        var option:Option = new Option(
            Language.getStr('Backend'),
            TITLE
        );
        follow.addOption(option);

        var reset:ResetRect = new ResetRect(450, 20, follow);
        follow.add(reset);

        ///////////////////////////////

        var option:Option = new Option(
            Language.getStr('Gameplaybackend'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('pauseButton'),
            'pauseButton',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('ratingOffset'),
            'ratingOffset',
            INT,
            -500,
            500,
            'MS'
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('NoteOffsetState'),
            'NoteOffsetState',
            STATE
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('safeFrames'),
            'safeFrames',
            FLOAT,
            0,
            10,
            1
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('marvelousWindow'),
            'marvelousWindow',
            INT,
            0,
            166,
            'MS'
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('sickWindow'),
            'sickWindow',
            INT,
            0,
            166,
            'MS'
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('goodWindow'),
            'goodWindow',
            INT,
            0,
            166,
            'MS'
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('badWindow'),
            'badWindow',
            INT,
            0,
            166,
            'MS'
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('marvelousRating'),
            'marvelousRating',
            BOOL
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.getStr('marvelousSprite'),
            'marvelousSprite',
            BOOL
        );
        follow.addOption(option);
    }
}
