package language.locales;

class EN 
{
    static public var langTran:Map<String, String> = [
        'LangName' => 'English',
        'languageName' => 'Choose language',
        'FontName' => 'montserrat',
    
        'Reset' => 'Reset',
        //==General==\\
        'General' => 'General',
        'framerate' => 'Change your FPS cap',
        'colorblindMode' => 'Colorblind filter more playable for colorblind people',
        'lowQuality' => 'Turn off some object on stages',
        'gameQuality' =>'Change game quality for screen',
        'antialiasing' => 'Toggle antialiasing, improving graphics quality at a slight performance penalty',
        'flashing' => 'Toggle flashing lights that can cause epileptic seizures and strain',
        'shaders' => 'Shaders used for some visual effects',
        'cacheOnGPU' => 'Allows the GPU to be used for caching textures, decreasing RAM usage',
        'autoPause' => 'Stops game, when its unfocused',



        //==Gameplay==\\
        'Gameplay' => 'Gameplay',
        ////////
        'downScroll' =>'Notes go Down instead of Up, simple enough',
        'middleScroll' => 'Put your lane in the center or on the right',
        'flipChart' => 'Flip chart for playing',
        'ghostTapping' => 'Toggle counting pressing a directional input when no arrow is there as a miss',
        'guitarHeroSustains' => "Hold Notes can't be pressed if you miss",
        'noReset' => 'Toggle pressing R to gameover',
        ////////
        'Opponent' => 'Opponent',
        ////////
        'playOpponent' => 'Playing as opponent',
        'opponentCodeFix' => 'GoodNoteHit and opponentNoteHit function exchange effort',
        'botOpponentFix' => 'Script will thought you open the bot',
        'HealthDrainOPPO' => 'Health Drain on opponent mode',
        'HealthDrainOPPOMult' => 'Health drain multiplier on opponent mode',

        //==Backend==\\
        'Backend' => 'Backend',
        'Gameplaybackend' => 'Gameplay Backend',
        'fixLNL' => 'Reduce Long Note length',
        'pauseMusic' => 'Pause Screen song type',
        'hitsoundType' => 'Hitsound Type',
        'hitsoundVolume' =>'Hitsound Volume',
        'oldHscriptVersion' => 'Reduced version to use hscript work for runhaxecode',
        'pauseButton' => 'Add pauseButton in game',
        'gameOverVibration' => 'Device will vibrate at game over',
        'ratingOffset' => 'Changes rate offset',
        'NoteOffsetState' => 'Changes music offset and judgement position',
        'safeFrames' => 'Changes how many frames you have for hitting a note earlier or late',
        'marvelousWindow' => 'How many milliseconds are in the MARVELOUS judge',
        'sickWindow' => 'How many milliseconds are in the SICK judge',
        'goodWindow' => 'How many milliseconds are in the GOOD judge',
        'badWindow' => 'How many milliseconds are in the BAD judge',
        'marvelousRating' => 'Extend marvelous judge for playing',
        'marvelousSprite' => 'Marvelous judge will also use "sick!" judge sprite',
        ////////
        'Appbackend' => 'App backend',
        ////////
        'discordRPC' => 'Show the Application from your \"Playing\" box on Discord',
        'checkForUpdates' => 'checkForUpdates',
        'screensaver' => 'Phone will sleep after going inactive for few seconds',
        'filesCheck' => 'Check game whether miss files',



        //==Game UI==\\
        'GameUI' => 'GameUI',
        'Game UI' => 'Game UI',
        ////////
        'Visble' => 'Visble',
        ////////
        'hideHud' => 'Hide hud',
        'showComboNum' => 'Combo sprite appearance',
        'showRating' => 'Rating sprite appearance',
        'opponentStrums' => 'Shows opponent strums on screen',
        'judgementCounter' => 'Show your judgements',
        'keyboardDisplay' => 'Feedback the key you pressed',
        ////////
        'TimeBar' => 'TimeBar',
        ////////
        'timeBarType' => 'Display type',
        ////////
        'HealthBar' => 'HealthBar',
        'healthBarAlpha' => 'Alpha',
        'oldHealthBarVersion' => 'Reduced version to psych 0.63h',
        ////////
        'Combo' => 'Combo',
        ////////
        'comboColor' => 'Allow to get and use rating color',
        'comboOffsetFix' => 'Fix position offset',
        ////////
        'KeyBoard' => 'KeyBoard',
        ////////
        'keyboardAlpha' => 'Alpha',
        'keyboardTime' =>'Display sustain',
        'keyboardBGColor' => 'keyboardBGColor',
        'keyboardTextColor' => 'keyboardTextColor',
        ////////
        'Camera' => 'Camera',
        ////////
        'camZooms' => 'Toggle the camera zoom in-game',
        'scoreZoom' => 'Score beat when you hit note',



        //==Skin==\\
        'Skin' => 'Skin',
        ////////
        'Note' => 'Note',
        'noteSkin' => 'Change your current noteSkin',
        'noteRGB' => 'RGB for Note',
        'NotesSubState' => 'Note color setup',
        ////////
        'Splash' => 'Splash',
        ////////
        'splashSkin' => 'Change your current splashSkin',
        'splashRGB' => 'RGB for Splash',
        'showSplash' => 'Show on sick/marvelous judge',
        'splashAlpha' => 'Alpha',



        //==Input==\\
        'Input' => 'Input',
        ////////
        'ControlsSubState' => 'Controls setup',
        ////////
        'TouchMain' => 'Touch-Main',
        ////////
        'needMobileControl' => 'Touch control support',
        'controlsAlpha' => 'Control alpha',
        ////////
        'TouchGame' => 'Touch-Game',
        ////////
        'MobileControlSelectSubState' => 'Controls type',
        'dynamicColors' => 'dynamicColors',
        'hitboxLocation' => 'Hitbox extra key location',
        'playControlsAlpha' => 'Control alpha',
        'extraKey' => 'ExtraKey for special input',
        'MobileExtraControl' => 'ExtraKey input setup',



        //==User Interface==\\
        'UserInterface' => 'UserInterface',
        'User Interface' => 'User Interface',
        ////////
        'CustomFade' => 'Custom tade type',
        'CustomFadeSound' => 'Custom fade sound volume',
        'CustomFadeText' => 'Custom fade text visible',
        'skipTitleVideo' => 'Skip intro video',
        'freeplayOld' => 'Use psych freeplay',
        'resultsScreen' => 'Open Results Screen at end song',
        'loadingScreen' => 'Add a LoadingScreen for PlayState and load faster\nif have some problem please disable it',



        //==Watermark==\\
        'Watermark' => 'Watermark',
        ////////
        'FPScounter' => 'FPS counter',
        ////////
        'showFPS' => 'Show your FPS',
        'showExtra' => 'Show more data',
        'rainbowFPS' => 'Change color with FPS',
        'memoryType' => 'memory showcase data',
        'FPSScale' => 'Size',

        'showWatermark' => 'Visible',
        'WatermarkScale' => 'WatermarkScale'
    ];
}