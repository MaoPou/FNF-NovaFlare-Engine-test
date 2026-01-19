package scripts.init;

import crowplexus.iris.Iris;

import scripts.lua.*;

//hxcodec
import vlc.MP4Handler; //2.5.0-2.5.1
import VideoHandler; //2.6.0-2.6.1
import hxcodec.flixel.FlxVideo; //3.0.0-3.0.1

class InitScriptData {
    public static function init() {
        
        //psychlua
        Iris.proxyImports.set("psychlua.CallbackHandler", CallbackHandler);
        Iris.proxyImports.set("psychlua.CustomSubstate", CustomSubstate);
        Iris.proxyImports.set("psychlua.DebugLuaText", DebugLuaText);
        Iris.proxyImports.set("psychlua.DeprecatedFunctions", DeprecatedFunctions);
        Iris.proxyImports.set("psychlua.ExtraFunctions", ExtraFunctions);
        Iris.proxyImports.set("psychlua.FlxAnimateFunctions", FlxAnimateFunctions);
        Iris.proxyImports.set("psychlua.FunkinLua", FunkinLua);
        Iris.proxyImports.set("psychlua.LuaUtils", LuaUtils);
        Iris.proxyImports.set("psychlua.ModchartAnimateSprite", ModchartAnimateSprite);
        Iris.proxyImports.set("psychlua.ModchartSprite", ModchartSprite);
        Iris.proxyImports.set("psychlua.ReflectionFunctions", ReflectionFunctions);
        Iris.proxyImports.set("psychlua.ShaderFunctions", ShaderFunctions);
        Iris.proxyImports.set("psychlua.TextFunctions", TextFunctions);


        //hxcodec
        Iris.proxyImports.set("vlc.MP4Handler", MP4Handler);
        Iris.proxyImports.set("VideoHandler", VideoHandler);
        Iris.proxyImports.set("hxcodec.VideoHandler", VideoHandler);
        Iris.proxyImports.set("hxcodec.flixel.FlxVideo", FlxVideo);


        //-------------------- PSYCH v0.7.3? --------------------\\
        //backend
        Iris.proxyImports.set("backend.animation.PsychAnimationController", backend.animation.PsychAnimationController);  //animation
        Iris.proxyImports.set("backend.Achievements", backend.Achievements);
        Iris.proxyImports.set("backend.BaseStage", backend.BaseStage);
        Iris.proxyImports.set("backend.ClientPrefs", backend.ClientPrefs);
        Iris.proxyImports.set("backend.Conductor", backend.Conductor);
        Iris.proxyImports.set("backend.Controls", backend.Controls);
        Iris.proxyImports.set("backend.CoolUtil", backend.CoolUtil);
        Iris.proxyImports.set("backend.CustomFadeTransition", backend.CustomFadeTransition);
        Iris.proxyImports.set("backend.Difficulty", backend.Difficulty);
        //Iris.proxyImports.set("Discord", backend.Discord);    //Psych 073有这个，但编译出错)
        Iris.proxyImports.set("backend.Highscore", backend.Highscore);
        Iris.proxyImports.set("backend.InputFormatter", backend.InputFormatter);
        Iris.proxyImports.set("backend.Mods", backend.Mods);
        Iris.proxyImports.set("backend.MusicBeatState", backend.MusicBeatState);
        Iris.proxyImports.set("backend.MusicBeatSubstate", backend.MusicBeatSubstate);
        Iris.proxyImports.set("backend.NoteTypesConfig", backend.NoteTypesConfig);
        Iris.proxyImports.set("backend.Paths", backend.Paths);
        Iris.proxyImports.set("backend.PsychCamera", backend.PsychCamera);
        Iris.proxyImports.set("backend.Rating", backend.Rating);
        Iris.proxyImports.set("backend.Section", backend.Section);
        Iris.proxyImports.set("backend.Song", backend.Song);
        Iris.proxyImports.set("backend.StageData", backend.StageData);
        Iris.proxyImports.set("backend.WeekData", backend.WeekData);

        //cutscenes
        Iris.proxyImports.set("cutscenes.CutsceneHandler", cutscenes.CutsceneHandler);
        Iris.proxyImports.set("cutscenes.DialogueBox", cutscenes.DialogueBox);
        Iris.proxyImports.set("cutscenes.DialogueBoxPsych", cutscenes.DialogueBoxPsych);
        Iris.proxyImports.set("cutscenes.DialogueCharacter", cutscenes.DialogueCharacter);

        //debug
        Iris.proxyImports.set("debug.FPSCounter", developer.display.FPSCounter);

        //objects
        Iris.proxyImports.set("objects.AchievementPopup", objects.AchievementPopup);
        Iris.proxyImports.set("objects.Alphabet", objects.Alphabet);
        Iris.proxyImports.set("objects.AttachedSprite", objects.AttachedSprite);
        Iris.proxyImports.set("objects.AttachedText", objects.AttachedText);
        Iris.proxyImports.set("objects.Bar", objects.Bar);
        Iris.proxyImports.set("objects.BGSprite", objects.BGSprite);
        Iris.proxyImports.set("objects.Character", objects.Character);
        Iris.proxyImports.set("objects.CheckboxThingie", objects.CheckboxThingie);
        Iris.proxyImports.set("objects.HealthIcon", objects.HealthIcon);
        Iris.proxyImports.set("objects.MenuCharacter", objects.MenuCharacter);
        Iris.proxyImports.set("objects.MenuItem", objects.MenuItem);
        Iris.proxyImports.set("objects.MusicPlayer", objects.MusicPlayer);
        Iris.proxyImports.set("objects.Note", objects.Note);
        Iris.proxyImports.set("objects.NoteSplash", objects.NoteSplash);
        Iris.proxyImports.set("objects.StrumNote", objects.StrumNote);
        Iris.proxyImports.set("objects.TypedAlphabet", objects.TypedAlphabet);

        //options
        Iris.proxyImports.set("options.BaseOptionsMenu", options.base.BaseOptionsMenu);
        Iris.proxyImports.set("options.ControlsSubState", options.base.ControlsSubState);
        Iris.proxyImports.set("options.ModSettingsSubState", options.base.ModSettingsSubState);
        Iris.proxyImports.set("options.NoteOffsetState", options.base.NoteOffsetState);
        Iris.proxyImports.set("options.NotesSubState", options.base.NotesSubState);
        Iris.proxyImports.set("options.Option", options.base.OptionBase);
        Iris.proxyImports.set("options.OptionsMenu", options.base.BaseOptionsMenu);
        Iris.proxyImports.set("options.OptionsState", options.OptionsState);
        //0.7.3特有，当前项目不存在或已迁移
        //Iris.proxyImports.set("options.GameplaySettingsSubState", null);
        //Iris.proxyImports.set("options.GraphicsSettingsSubState", null);
        //Iris.proxyImports.set("options.VisualsUISubState", null);

        //shaders
        Iris.proxyImports.set("shaders.BlendModeEffect", shaders.BlendModeEffect);
        Iris.proxyImports.set("shaders.ColorSwap", shaders.ColorSwap);
        Iris.proxyImports.set("shaders.OverlayShader", shaders.OverlayShader);
        Iris.proxyImports.set("shaders.RGBPalette", shaders.RGBPalette);
        Iris.proxyImports.set("shaders.WiggleEffect", shaders.WiggleEffect);

        //states
        Iris.proxyImports.set("states.AchievementsMenuState", states.AchievementsMenuState);
        Iris.proxyImports.set("states.CreditsState", states.CreditsState);
        Iris.proxyImports.set("states.FlashingState", states.FlashingState);
        //Iris.proxyImports.set("states.FreeplayState", states.FreeplayState);
        Iris.proxyImports.set("states.FreeplayState", states.FreeplayStatePsych);  //兼容Psych界面)
        Iris.proxyImports.set("states.LoadingState", states.LoadingState);
        Iris.proxyImports.set("states.MainMenuState", states.MainMenuState);
        Iris.proxyImports.set("states.ModsMenuState", states.ModsMenuState);
        Iris.proxyImports.set("states.OutdatedState", states.OutdatedState);
        Iris.proxyImports.set("states.PlayState", states.PlayState);
        Iris.proxyImports.set("states.ScaleSimulationState", states.ScaleSimulationState);
        Iris.proxyImports.set("states.StoryMenuState", states.StoryMenuState);
        Iris.proxyImports.set("states.TitleState", states.TitleState);

        //states.editors
        Iris.proxyImports.set("states.editors.CharacterEditorState", states.editors.CharacterEditorState);
        Iris.proxyImports.set("states.editors.ChartingState", states.editors.ChartingState);
        Iris.proxyImports.set("states.editors.DialogueCharacterEditorState", states.editors.DialogueCharacterEditorState);
        Iris.proxyImports.set("states.editors.DialogueEditorState", states.editors.DialogueEditorState);
        Iris.proxyImports.set("states.editors.EditorPlayState", states.editors.EditorPlayState);
        Iris.proxyImports.set("states.editors.MasterEditorMenu", states.editors.MasterEditorMenu);
        Iris.proxyImports.set("states.editors.MenuCharacterEditorState", states.editors.MenuCharacterEditorState);
        Iris.proxyImports.set("states.editors.NoteSplashDebugState", states.editors.NoteSplashDebugState);
        Iris.proxyImports.set("states.editors.WeekEditorState", states.editors.WeekEditorState);
    
        //states.stages            //呃呃我不知道这个应不应该加上————牢喵233
        Iris.proxyImports.set("stages.Limo", states.stages.Limo);
        Iris.proxyImports.set("stages.Mall", states.stages.Mall);
        Iris.proxyImports.set("stages.MallEvil", states.stages.MallEvil);
        Iris.proxyImports.set("stages.Philly", states.stages.Philly);
        Iris.proxyImports.set("stages.School", states.stages.School);
        Iris.proxyImports.set("stages.SchoolEvil", states.stages.SchoolEvil);
        Iris.proxyImports.set("stages.Spooky", states.stages.Spooky);
        Iris.proxyImports.set("stages.StageWeek1", states.stages.StageWeek1);
        Iris.proxyImports.set("stages.Tank", states.stages.Tank);
        //Iris.proxyImports.set("stages.Template", states.stages.Template); //加上这个会提示找不到"Note"，报错指向Template第137行
        //states.stages.objects
        Iris.proxyImports.set("stages.objects.BackgroundDancer", states.stages.objects.BackgroundDancer);
        Iris.proxyImports.set("stages.objects.BackgroundGirls", states.stages.objects.BackgroundGirls);
        Iris.proxyImports.set("stages.objects.BackgroundTank", states.stages.objects.BackgroundTank);
        Iris.proxyImports.set("stages.objects.DadBattleFog", states.stages.objects.DadBattleFog);
        Iris.proxyImports.set("stages.objects.MallCrowd", states.stages.objects.MallCrowd);
        Iris.proxyImports.set("stages.objects.PhillyGlowGradient", states.stages.objects.PhillyGlowGradient);
        Iris.proxyImports.set("stages.objects.PhillyGlowParticle", states.stages.objects.PhillyGlowParticle);
        Iris.proxyImports.set("stages.objects.PhillyTrain", states.stages.objects.PhillyTrain);
        Iris.proxyImports.set("stages.objects.TankmenBG", states.stages.objects.TankmenBG);


        //substates
        Iris.proxyImports.set("substates.GameOverSubstate", substates.GameOverSubstate);
        Iris.proxyImports.set("substates.GameplayChangersSubstate", substates.GameplayChangersSubstate);
        Iris.proxyImports.set("substates.PauseSubState", substates.PauseSubState);
        Iris.proxyImports.set("substates.Prompt", substates.Prompt);
        Iris.proxyImports.set("substates.ResetScoreSubState", substates.ResetScoreSubState);

        //-------------------- PSYCH v0.6.3? --------------------\\
        //backend
        Iris.proxyImports.set("Achievements", backend.Achievements);
        Iris.proxyImports.set("ClientPrefs", backend.ClientPrefs);
        Iris.proxyImports.set("Conductor", backend.Conductor);
        Iris.proxyImports.set("Controls", backend.Controls);
        Iris.proxyImports.set("CoolUtil", backend.CoolUtil);
        Iris.proxyImports.set("CustomFadeTransition", backend.CustomFadeTransition);
        Iris.proxyImports.set("Highscore", backend.Highscore);
        Iris.proxyImports.set("InputFormatter", backend.InputFormatter);
        Iris.proxyImports.set("MusicBeatState", backend.MusicBeatState);
        Iris.proxyImports.set("MusicBeatSubstate", backend.MusicBeatSubstate);
        Iris.proxyImports.set("Paths", backend.Paths);
        Iris.proxyImports.set("PlayerSettings", backend.ClientPrefs);  // PlayerSettings可能合并到ClientPrefs
        Iris.proxyImports.set("Section", backend.Section);
        Iris.proxyImports.set("Song", backend.Song);
        Iris.proxyImports.set("StageData", backend.StageData);
        Iris.proxyImports.set("WeekData", backend.WeekData);

        //cutscenes
        Iris.proxyImports.set("CutsceneHandler", cutscenes.CutsceneHandler);
        Iris.proxyImports.set("DialogueBox", cutscenes.DialogueBox);
        Iris.proxyImports.set("DialogueBoxPsych", cutscenes.DialogueBoxPsych);

        //objects
        Iris.proxyImports.set("Alphabet", objects.Alphabet);
        Iris.proxyImports.set("AttachedSprite", objects.AttachedSprite);
        Iris.proxyImports.set("AttachedText", objects.AttachedText);
        Iris.proxyImports.set("BGSprite", objects.BGSprite);
        Iris.proxyImports.set("BackgroundDancer", states.stages.objects.BackgroundDancer);
        Iris.proxyImports.set("BackgroundGirls", states.stages.objects.BackgroundGirls);
        Iris.proxyImports.set("Boyfriend", objects.Character);  // Boyfriend在0.6.3独立，现在合并到Character
        Iris.proxyImports.set("Character", objects.Character);
        Iris.proxyImports.set("CheckboxThingie", objects.CheckboxThingie);
        Iris.proxyImports.set("HealthIcon", objects.HealthIcon);
        Iris.proxyImports.set("MenuCharacter", objects.MenuCharacter);
        Iris.proxyImports.set("MenuItem", objects.MenuItem);
        Iris.proxyImports.set("Note", objects.Note);
        Iris.proxyImports.set("NoteSplash", objects.NoteSplash);
        Iris.proxyImports.set("StrumNote", objects.StrumNote);
        Iris.proxyImports.set("TankmenBG", states.stages.objects.TankmenBG);
        Iris.proxyImports.set("TypedAlphabet", objects.TypedAlphabet);

        //options
        Iris.proxyImports.set("BaseOptionsMenu", options.base.BaseOptionsMenu);
        Iris.proxyImports.set("ControlsSubState", options.base.ControlsSubState);
        //Iris.proxyImports.set("GameplaySettingsSubState", substates.GameplayChangersSubstate);  // 0.6.3特有
        //Iris.proxyImports.set("GraphicsSettingsSubState", options.groupData.GraphicsGroup);  // 0.6.3特有
        Iris.proxyImports.set("LatencyState", options.base.NoteOffsetState);  // LatencyState可能合并到NoteOffsetState
        Iris.proxyImports.set("NoteOffsetState", options.base.NoteOffsetState);
        Iris.proxyImports.set("NotesSubState", options.base.NotesSubState);
        Iris.proxyImports.set("Option", options.base.OptionBase);
        Iris.proxyImports.set("OptionsState", options.OptionsState);
        //Iris.proxyImports.set("VisualsUISubState", options.OptionsState);  // 0.6.3特有，当前项目不存在

        //shaders
        Iris.proxyImports.set("BlendModeEffect", shaders.BlendModeEffect);
        Iris.proxyImports.set("ColorSwap", shaders.ColorSwap);
        Iris.proxyImports.set("OverlayShader", shaders.OverlayShader);
        Iris.proxyImports.set("PhillyGlow", shaders.BlendModeEffect);  // PhillyGlow可能合并到Philly
        Iris.proxyImports.set("WiggleEffect", shaders.WiggleEffect);

        //states
        Iris.proxyImports.set("AchievementsMenuState", states.AchievementsMenuState);
        Iris.proxyImports.set("CreditsState", states.CreditsState);
        Iris.proxyImports.set("FlashingState", states.FlashingState);
        Iris.proxyImports.set("FreeplayState", states.FreeplayState);
        Iris.proxyImports.set("LoadingState", states.LoadingState);
        Iris.proxyImports.set("MainMenuState", states.MainMenuState);
        Iris.proxyImports.set("ModsMenuState", states.ModsMenuState);
        Iris.proxyImports.set("OutdatedState", states.OutdatedState);
        Iris.proxyImports.set("PlayState", states.PlayState);
        Iris.proxyImports.set("StoryMenuState", states.StoryMenuState);
        Iris.proxyImports.set("TitleState", states.TitleState);

        //states.editors
        Iris.proxyImports.set("editors.CharacterEditorState", states.editors.CharacterEditorState);
        Iris.proxyImports.set("editors.ChartingState", states.editors.ChartingState);
        Iris.proxyImports.set("editors.DialogueCharacterEditorState", states.editors.DialogueCharacterEditorState);
        Iris.proxyImports.set("editors.DialogueEditorState", states.editors.DialogueEditorState);
        Iris.proxyImports.set("editors.EditorLua", scripts.lua.FunkinLua);  // EditorLua合并到FunkinLua
        Iris.proxyImports.set("editors.EditorPlayState", states.editors.EditorPlayState);
        Iris.proxyImports.set("editors.MasterEditorMenu", states.editors.MasterEditorMenu);
        Iris.proxyImports.set("editors.MenuCharacterEditorState", states.editors.MenuCharacterEditorState);
        Iris.proxyImports.set("editors.WeekEditorState", states.editors.WeekEditorState);

        //substates
        Iris.proxyImports.set("GameOverSubstate", substates.GameOverSubstate);
        Iris.proxyImports.set("GameplayChangersSubstate", substates.GameplayChangersSubstate);
        Iris.proxyImports.set("GitarooPause", substates.PauseSubState);  // GitarooPause用PauseSubState代替
        Iris.proxyImports.set("PauseSubState", substates.PauseSubState);
        Iris.proxyImports.set("Prompt", substates.Prompt);
        Iris.proxyImports.set("ResetScoreSubState", substates.ResetScoreSubState);

        //animateatlas (0.6.3特有，当前项目无)
        //Iris.proxyImports.set("animateatlas.AtlasFrameMaker", animateatlas.AtlasFrameMaker);
        //Iris.proxyImports.set("animateatlas.HelperEnums", animateatlas.HelperEnums);
        //Iris.proxyImports.set("animateatlas.JSONData", animateatlas.JSONData);
        //Iris.proxyImports.set("animateatlas.JSONData2020", animateatlas.JSONData2020);
        //Iris.proxyImports.set("animateatlas.Main", animateatlas.Main);
        //Iris.proxyImports.set("animateatlas.displayobject.SpriteAnimationLibrary", animateatlas.displayobject.SpriteAnimationLibrary);
        //Iris.proxyImports.set("animateatlas.displayobject.SpriteMovieClip", animateatlas.displayobject.SpriteMovieClip);
        //Iris.proxyImports.set("animateatlas.displayobject.SpriteSymbol", animateatlas.displayobject.SpriteSymbol);
        //Iris.proxyImports.set("animateatlas.tilecontainer.TileAnimationLibrary", animateatlas.tilecontainer.TileAnimationLibrary);
        //Iris.proxyImports.set("animateatlas.tilecontainer.TileContainerMovieClip", animateatlas.tilecontainer.TileContainerMovieClip);
        //Iris.proxyImports.set("animateatlas.tilecontainer.TileContainerSymbol", animateatlas.tilecontainer.TileContainerSymbol);


    }
}