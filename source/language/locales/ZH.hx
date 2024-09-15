package language.locales;

class ZH
{
    static public var langTran:Map<String, String> = [

        'LangName' => '简体中文',
        'languageName' => '选择语言',
        'FontName' => 'Lang-ZH',

        'Reset' => '数据重置',
        //==General==\\
        'General' => '常规设置',
        'framerate' => '更改帧数上限',
        'colorblindMode' => '色盲滤镜',
        'lowQuality' => '低质量模式',
        'gameQuality' =>'更改屏幕的游戏画面质量',
        'antialiasing' => '使用抗锯齿，提高图形质量，但性能略有下降',
        'flashing' => '允许可能导致引发癫痫的特效使用',
        'shaders' => '启用着色器',
        'cacheOnGPU' => '允许将 GPU 用于缓存纹理，从而减少 RAM 使用率',
        'autoPause' => '当游戏未在前台时自动停止游戏',

        //==Gameplay==\\
        'Gameplay' => '游玩设置',
        ////////
        'downScroll' =>'箭头改为从上往下滚动',
        'middleScroll' => '将箭头居中放置',
        'flipChart' => '铺面箭头翻转',
        'ghostTapping' => '当没有箭头时按下会Miss',
        'guitarHeroSustains' => '如果长箭断了，则无法再次触发',
        'noReset' => '按 R 键会立刻死亡',
        ////////
        'Opponent' => '对手设置',
        ////////
        'playOpponent' => '游玩对方铺面',
        'opponentCodeFix' => '把GoodNoteHit和opponentNoteHit函数触发进行交换',
        'botOpponentFix' => '脚本会认为您打开了机器人',
        'HealthDrainOPPO' => '对手也可以通过击中箭头推条',
        'HealthDrainOPPOMult' => '对手的推条系数',

        //==Backend==\\
        'Backend' => '后端设置',
        'Gameplaybackend' => '游戏后端设置',
        'fixLNL' => '减少长键长度',
        'pauseMusic' => '暂停界面播放的歌曲',
        'hitsoundType' => '打击音效',
        'hitsoundVolume' =>'打击音效音量大小',
        'oldHscriptVersion' => '使用 Hscript 为 runhaxecode 工作以兼容旧模组',
        'pauseButton' => '在游玩时左上角添加暂停按钮',
        'gameOverVibration' => '设备将在游戏死亡时振动',
        'ratingOffset' => '更改整体判定的最大区间',
        'NoteOffsetState' => '更改音乐偏移和UI贴图的位置',
        'safeFrames' => '修改整体判定大小系数',
        'marvelousWindow' => '更改Marvelous评分判定的最大区间',
        'sickWindow' => '更改Sick评分判定的最大区间',
        'goodWindow' => '更改Good评分判定的最大区间',
        'badWindow' => '更改Bad评分判定的最大区间',
        'marvelousRating' => '增加Marvelous判定',
        'marvelousSprite' => 'Marvelous评分仍然使用Sick的贴图',
        ////////
        'Appbackend' => '软件后端设置',
        ////////
        'discordRPC' => '从 Discord 上的“正在播放”框中显示应用程序',
        'checkForUpdates' => '检查应用程序版本',
        'screensaver' => '处于非活动状态不会进入休眠状态',
        'filesCheck' => '检查游戏是否丢失文件',

        //==Game UI==\\
        'GameUI' => '游戏界面设置',
        'Game UI' => '游戏界面设置',
        ////////
        'Visble' => '显示设置',
        ////////
        'hideHud' => '隐藏UI',
        'showComboNum' => '显示连击数字',
        'showRating' => '显示评级贴图',
        'opponentStrums' => '显示对手的箭头',
        'judgementCounter' => '显示计数板',
        'keyboardDisplay' => '显示键盘反馈',
        ////////
        'TimeBar' => '时长条',
        ////////
        'timeBarType' => '显示类型',
        ////////
        'HealthBar' => '生命条',
        'healthBarAlpha' => '透明度',
        'oldHealthBarVersion' => '使用psych 0.63h的血条以修复旧模组',
        ////////
        'Combo' => '连击设置',
        ////////
        'comboColor' => '允许贴图获取和使用评级颜色',
        'comboOffsetFix' => '修复偏移',
        ////////
        'KeyBoard' => '键盘反馈',
        ////////
        'keyboardAlpha' => '透明度',
        'keyboardTime' =>'滞留时长',
        'keyboardBGColor' => '背景颜色',
        'keyboardTextColor' => '文字颜色',
        ////////
        'Camera' => '摄像机',
        ////////
        'camZooms' => '摄像机根据音乐节奏进行Beat',
        'scoreZoom' => '击打箭头会使分数栏Beat',

        //==Skin==\\
        'Skin' => '皮肤设置',
        ////////
        'Note' => '箭头皮肤设置',
        'noteSkin' => '类型',
        'noteRGB' => '启用着色器',
        'NotesSubState' => '颜色设置',
        ////////
        'Splash' => '溅射皮肤设置',
        ////////
        'splashSkin' => '类型',
        'splashRGB' => '启用着色器',
        'showSplash' => '显示',
        'splashAlpha' => '透明度',

        //==Input==\\
        'Input' => '输出设置',
        ////////
        'ControlsSubState' => '键盘输出设置',
        ////////
        'TouchMain' => '触屏设置',
        ////////
        'needMobileControl' => '触屏支持',
        'controlsAlpha' => '按键透明度',
        ////////
        'TouchGame' => '游戏内触屏按键设置',
        ////////
        'MobileControlSelectSubState' => '触屏摁键类型',
        'dynamicColors' => '摁键跟随箭头颜色',
        'hitboxLocation' => 'Hitbox 特殊键位置',
        'playControlsAlpha' => '游戏内按键透明度',
        'extraKey' => '特殊摁键数量',
        'MobileExtraControl' => '特殊按键输出设置',



        //==User Interface==\\
        'UserInterface' => '用户界面设置',
        'User Interface' => '用户界面设置',
        ////////
        'CustomFade' => '自定义过场动画类型',
        'CustomFadeSound' => '自定义过场音量',
        'CustomFadeText' => '自定义过场文本可见',
        'skipTitleVideo' => '跳过游戏启动时的动画',
        'freeplayOld' => '使用Psych的FreePlay界面',
        'resultsScreen' => '在结尾歌曲处打开结算界面',
        'loadingScreen' => '为 PlayState 添加预加载界面并更快地加载，如果遇到问题，请禁用它',



        //==Watermark==\\
        'Watermark' => '水印设置',
        ////////
        'FPScounter' => '数据显示',
        ////////
        'showFPS' => '显示帧数',
        'showExtra' => '显示更多性能数值',
        'rainbowFPS' => '字体颜色跟随帧数进行变化',
        'memoryType' => '运存展示数据类型',
        'FPSScale' => '大小',

        'showWatermark' => '显示水印',
        'WatermarkScale' => '大小'
    ];
}