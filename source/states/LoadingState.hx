package states;

import haxe.Json;

import lime.utils.Assets;

import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.display.BitmapData;
import openfl.display.Shape;

import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFilterFrames;

import states.FreeplayState;

import backend.Song;
import backend.StageData;
import backend.Rating;
import backend.state.loadingState.*;
import backend.AsyncTextureUploader;

import sys.thread.Thread;
import sys.thread.Mutex;


import lime.system.ThreadPool;
import lime.system.WorkOutput;

import thread.ThreadEvent;

import luahscript.exprs.LuaExpr;
import luahscript.LuaParser;
import crowplexus.hscript.Expr;
import crowplexus.hscript.Tools;
import crowplexus.hscript.Parser;
import cutscenes.DialogueBoxPsych;

class LoadingState extends MusicBeatState
{
	public static var loaded:Int = 0; //已经加载的数量
	public static var loadMax:Int = 0; //总体需要加载的数量
	static var pendingUploads:Int = 0;
	static var useAsyncUpload:Bool = false;

	static var requestedBitmaps:Map<String, BitmapData> = []; //储存下加载的纹理，再最后进入playstate的时候输出总结

	static var loadThread:ThreadPool = null; //真正加载时的总线程池

	static var prepareMutex:Mutex = new Mutex(); //准备资源锁，这是为了防止数据提前被主线程接收

	static var isPlayState:Bool = false; //如果是要进入playstate
	static var waitPrepare:Bool = false; //允许执行prepare事件,false时候不让界面update

	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false, intrusive:Bool = true)
		MusicBeatState.switchState(getNextState(target, stopMusic, intrusive));

	static function getNextState(target:FlxState, stopMusic = false, intrusive:Bool = true):FlxState
	{
		var directory:String = 'shared';
		var weekDir:String = StageData.forceNextDirectory;
		StageData.forceNextDirectory = null;

		if (weekDir != null && weekDir.length > 0 && weekDir != '')
			directory = weekDir;

		Paths.setCurrentLevel(directory);
		trace('Setting asset folder to ' + directory);

		var doPrecache:Bool = false; //建议别去动这个
		if (ClientPrefs.data.loadingScreen)
		{
			if (intrusive)
			{
				if (waitPrepare)
					return new LoadingState(target, stopMusic);
			}
			else
				doPrecache = true;
		}

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (doPrecache)
		{
			startThreads();
			while (true)
			{
				if (checkLoaded())
				{
					imagesToPrepare = [];
					soundsToPrepare = [];
					musicToPrepare = [];
					songsToPrepare = [];
					if (loadThread != null) loadThread.cancel(); // kill all workers safely
					loadThread = null;
					break;
				}
				else
					Sys.sleep(0.01);
			}
		}
		return target;
	}

	function new(target:FlxState, stopMusic:Bool)
	{
		this.target = target;
		this.stopMusic = stopMusic;
		loaded = 0;
		super();
	}

	var target:FlxState = null;
	var stopMusic:Bool = false;

	var filePath:String = 'menuExtend/LoadingState/';

	var bar:FlxSprite;

	var button:LoadButton;
	var barHeight:Int = 10;

	var intendedPercent:Float = 0;
	var curPercent:Float = 0;
	var precentText:FlxText;
	var JustSay:FlxText;
	var loads:FlxSprite;

	override public function create()
	{
		Paths.clearStoredMemory();

		var bg = new FlxSprite().loadGraphic(Paths.image(filePath + 'loadScreen'));
		bg.setGraphicSize(Std.int(FlxG.width));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.updateHitbox();
		add(bg);

		loads = new FlxSprite().loadGraphic(Paths.image(filePath + 'loadIcon'));
		loads.antialiasing = ClientPrefs.data.antialiasing;
		loads.updateHitbox();
		loads.x = FlxG.width - loads.width - 2;
		loads.y = 5;
		add(loads);

		var bg:FlxSprite = new FlxSprite(0, FlxG.height - barHeight).makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, barHeight);
		bg.updateHitbox();
		bg.alpha = 0.4;
		bg.screenCenter(X);
		add(bg);

		bar = new FlxSprite(0, FlxG.height - barHeight).makeGraphic(1, 1, FlxColor.WHITE);
		bar.scale.set(0, barHeight);
		bar.alpha = 0.6;
		bar.updateHitbox();
		add(bar);

		button = new LoadButton(0, 0, 35, barHeight);
		button.y = FlxG.height - button.height;
		button.antialiasing = ClientPrefs.data.antialiasing;
		button.updateHitbox();
		add(button);

		precentText = new FlxText(520, 600, 400, '0%', 30);
		precentText.setFormat(Paths.font("loadScreen.ttf"), 25, FlxColor.WHITE, RIGHT, OUTLINE_FAST, FlxColor.TRANSPARENT);
		precentText.borderSize = 0;
		precentText.antialiasing = ClientPrefs.data.antialiasing;
		add(precentText);
		precentText.x = FlxG.width - precentText.width - 2;
		precentText.y = FlxG.height - precentText.height - barHeight - 2;

		JustSay = new FlxText(0, 600, FlxG.width, '', 30);
		JustSay.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), 25, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.TRANSPARENT);
		JustSay.antialiasing = ClientPrefs.data.antialiasing;
		add(JustSay);

		JustSay.y = FlxG.height - precentText.height - barHeight - 2;
		JustSay.x = 10;

		try
		{
			var filename:String = 'language/JustSay/JustSay-' + Language.get('justsayLang', 'ma') + '.txt';
			var file:String = File.getContent(Paths.getSharedPath(filename));
			var lines:Array<String> = file.split('\n');
			var randomIndex:Int = FlxG.random.int(0, lines.length);
			var randomLine:String = lines[randomIndex];
			JustSay.text = 'Tags: ' + randomLine;
		}
		catch (e:Dynamic)
		{
			JustSay.text = Std.string(e);
		}

		GCManager.enable(false);
		useAsyncUpload = true;

		super.create();

		FlxG.signals.postUpdate.addOnce(function()
		{
			ThreadEvent.create(function() {
				prepareMutex.acquire();
				startPrepare();
				prepareMutex.release();
			}, startThreads);
		});
		
	}

	public static var imagesToPrepare:Array<String> = [];
	public static var soundsToPrepare:Array<String> = [];
	public static var musicToPrepare:Array<String> = [];
	public static var songsToPrepare:Array<String> = [];

	public static var chartEvents:Array<Array<Dynamic>> = [];
	public static var chartNoteTypes:Array<String> = [];

	public static function prepare(images:Array<String> = null, sounds:Array<String> = null, music:Array<String> = null)
	{
		if (images != null)
			for (file in images) putPreload(imagesToPrepare, file);
		if (sounds != null)
			for (file in sounds) putPreload(soundsToPrepare, file);
		if (music != null)
			for (file in music) putPreload(musicToPrepare, file);
	}

	public static function prepareToSong()
	{
		if (!ClientPrefs.data.loadingScreen)
			return;

		clearInvalids();

		isPlayState = true;
		waitPrepare = true;
	}

	static function startPrepare()
	{
		var song:SwagSong = PlayState.SONG;
		var folder:String = Paths.formatToSongPath(song.song);
		try
		{
			var path:String = Paths.json('$folder/preload');
			var json:Dynamic = null;

			#if MODS_ALLOWED
			var moddyFile:String = Paths.modsJson('$folder/preload');
			if (FileSystem.exists(moddyFile))
				json = Json.parse(File.getContent(moddyFile));
			else if (FileSystem.exists(path))
				json = Json.parse(File.getContent(path));
			#else
			json = Json.parse(Assets.getText(path));
			#end

			if (json != null)
				prepare((!ClientPrefs.data.lowQuality || json.images_low) ? json.images : json.images_low, json.sounds, json.music);
		}
		catch (e:Dynamic){}

		if (song.stage == null || song.stage.length < 1)
			song.stage = StageData.vanillaSongStage(folder);

		var stageData:StageFile = StageData.getStageFile(song.stage);
		if (stageData != null)
		{
			var imgs:Array<String> = [];
			var snds:Array<String> = [];
			var mscs:Array<String> = [];
			if(stageData.preload != null)
			{
				for (asset in Reflect.fields(stageData.preload))
				{
					var filters:Int = Reflect.field(stageData.preload, asset);
					var asset:String = asset.trim();

					if(filters < 0 || StageData.validateVisibility(filters))
					{
						if(asset.startsWith('images/'))
							imgs.push(asset.substr('images/'.length));
						else if(asset.startsWith('sounds/'))
							snds.push(asset.substr('sounds/'.length));
						else if(asset.startsWith('music/'))
							mscs.push(asset.substr('music/'.length));
					}
				}
			}
			
			if (stageData.objects != null)
			{
				for (sprite in stageData.objects)
				{
					if(sprite.type == 'sprite' || sprite.type == 'animatedSprite')
						if((sprite.filters < 0 || StageData.validateVisibility(sprite.filters)) && !imgs.contains(sprite.image))
							imgs.push(sprite.image);
				}
			}
			prepare(imgs, snds, mscs);
		}

		putPreload(songsToPrepare, '$folder/Inst');

		var player1:String = song.player1;
		var player2:String = song.player2;
		var gfVersion:String = song.gfVersion;
		var needsVoices:Bool = song.needsVoices;
		var prefixVocals:String = needsVoices ? '$folder/Voices' : null;
		if (gfVersion == null)
			gfVersion = 'gf';

		preloadCharacter(player1, prefixVocals);

		if (prefixVocals != null)
		{
			putPreload(songsToPrepare, prefixVocals);
			putPreload(songsToPrepare, '$prefixVocals-Player');
			putPreload(songsToPrepare, '$prefixVocals-Opponent');
		}

		if (player2 != player1)
			preloadCharacter(player2, prefixVocals);
		if (stageData != null && !stageData.hide_girlfriend && gfVersion != player2 && gfVersion != player1)
			preloadCharacter(gfVersion);

		chartNoteTypes = [];
		for (section in PlayState.SONG.notes)
		{
			for (songNotes in section.sectionNotes)
			{
				if (!chartNoteTypes.contains(songNotes[3]))
				{
					chartNoteTypes.push(songNotes[3]);
				}
			}
		}
		chartEvents = [];
		for (event in PlayState.SONG.events) // Event Notes
			chartEvents.push(event);

		preloadMisc();
		preloadScript();

		waitPrepare = false;
	}
	

	public static function preloadCharacter(char:String, ?prefixVocals:String)
	{
		try
		{
			var path:String = Paths.getPath('characters/$char.json', TEXT);
			#if MODS_ALLOWED
			var character:Dynamic = Json.parse(File.getContent(path));
			#else
			var character:Dynamic = Json.parse(Assets.getText(path));
			#end

			var isAnimateAtlas:Bool = false;
			var img:String = character.image;
			img = img.trim();
			#if flxanimate
			var animToFind:String = Paths.getPath('images/$img/Animation.json', TEXT);
			if (#if MODS_ALLOWED FileSystem.exists(animToFind) || #end Assets.exists(animToFind))
				isAnimateAtlas = true;
			#end

			if(!isAnimateAtlas)
			{
				var split:Array<String> = img.split(',');
				for (file in split)
				{
					putPreload(imagesToPrepare, file.trim());
				}
			}
			#if flxanimate
			else
			{
				for (i in 0...10)
				{
					var st:String = '$i';
					if(i == 0) st = '';
	
					if(Paths.fileExists('images/$img/spritemap$st.png', IMAGE))
					{
						//trace('found Sprite PNG');
						putPreload(imagesToPrepare, '$img/spritemap$st');
						break;
					}
				}
			}
			#end

			putPreload(imagesToPrepare, 'icons/' + character.healthicon);
			putPreload(imagesToPrepare, 'icons/icon-' + character.healthicon);

			if (prefixVocals != null && character.vocals_file != null && character.vocals_file.length > 0)
			{
				putPreload(songsToPrepare, prefixVocals + "-" + character.vocals_file);
			}
			startLuaNamed('characters/' + char + '.lua');
		}
		catch (e:Dynamic)
		{
		}
	}

	static function preloadMisc()
	{
		var ratingsData:Array<Rating> = Rating.loadDefault();
		var stageData:StageFile = StageData.getStageFile(PlayState.SONG.stage);

		var uiPrefix:String = '';
		var uiSuffix:String = '';

		if (stageData == null)
		{ // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = StageData.dummy();
		}

		PlayState.stageUI = 'normal'; // fix
		if (stageData.stageUI != null && stageData.stageUI.trim().length > 0)
			PlayState.stageUI = stageData.stageUI;
		else
		{
			if (stageData.isPixelStage)
				PlayState.stageUI = "pixel";
		}
		if (PlayState.stageUI != "normal")
		{
			uiPrefix = PlayState.stageUI + 'UI/';
			if (PlayState.isPixelStage)
				uiSuffix = '-pixel';
		}

		for (rating in ratingsData)
		{
			putPreload(imagesToPrepare, uiPrefix + rating.image + uiSuffix);
		}

		for (i in 0...10)
			putPreload(imagesToPrepare, uiPrefix + 'num' + i + uiSuffix);

		putPreload(imagesToPrepare, uiPrefix + 'ready' + uiSuffix);
		putPreload(imagesToPrepare, uiPrefix + 'set' + uiSuffix);
		putPreload(imagesToPrepare, uiPrefix + 'go' + uiSuffix);
		putPreload(imagesToPrepare, 'healthBar');

		if (PlayState.isStoryMode)  {
			putPreload(imagesToPrepare, 'speech_bubble');
		}
	}

	static function preloadScript()
	{
		#if ((LUA_ALLOWED || HSCRIPT_ALLOWED) && sys)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if (file.toLowerCase().endsWith('.lua'))
					luaFilesCheck(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if (file.toLowerCase().endsWith('.hx'))
					hscriptFilesCheck(folder + file);
				#end
			}

		var songName = PlayState.SONG.song;
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'data/$songName/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if (file.toLowerCase().endsWith('.lua'))
					luaFilesCheck(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if (file.toLowerCase().endsWith('.hx'))
					hscriptFilesCheck(folder + file);
				#end
			}

		startLuaNamed('stages/' + PlayState.SONG.stage + '.lua');
		startHscriptNamed('stages/' + PlayState.SONG.stage + '.hx');

		for (noteType in chartNoteTypes)
		{
			startLuaNamed('custom_notetypes/' + noteType + '.lua');
			startHscriptNamed('custom_notetypes/' + noteType + '.hx');
		}

		for (event in chartEvents)
		{
			startLuaNamed('custom_events/' + event + '.lua');
			startHscriptNamed('custom_events/' + event + '.hx');
		}
		#end
	}

	static function startLuaNamed(filePath:String)
	{
		#if MODS_ALLOWED
		var pathToLoad:String = Paths.modFolders(filePath);
		if (!FileSystem.exists(pathToLoad))
			pathToLoad = Paths.getSharedPath(filePath);

		if (FileSystem.exists(pathToLoad))
		#else
		var pathToLoad:String = Paths.getSharedPath(filePath);
		if (Assets.exists(pathToLoad))
		#end
		{
			luaFilesCheck(pathToLoad);
		}
	}

	static function luaFilesCheck(path:String)
	{
		var input:String = File.getContent(path);	

		if (StringTools.fastCodeAt(input, 0) == 0xFEFF) {
			input = input.substr(1);
		} //防止BOM字符 <UTF-8 with BOM> <\65279>

		var parser = new LuaParser();
		var e:LuaExpr = parser.parseFromString(input);

		if (e == null)
			return;
	
		ScriptExprTools.lua_searchCallback(e, function(e:LuaExpr, params:Array<LuaExpr>) {
			switch(e.expr) {
				case EIdent('makeLuaSprite'):
					if (ScriptExprTools.lua_getValue(params[1]) != null || ScriptExprTools.lua_getValue(params[1]) != '')
						putPreload(imagesToPrepare, Std.string(ScriptExprTools.lua_getValue(params[1])));
				case EIdent('makeAnimatedLuaSprite'):
					if (ScriptExprTools.lua_getValue(params[1]) != null || ScriptExprTools.lua_getValue(params[1]) != '')
							putPreload(imagesToPrepare, Std.string(ScriptExprTools.lua_getValue(params[1])));
				case EIdent('precacheImage'):
					if (ScriptExprTools.lua_getValue(params[0]) != null || ScriptExprTools.lua_getValue(params[0]) != '')
							putPreload(imagesToPrepare, Std.string(ScriptExprTools.lua_getValue(params[0])));
				case EIdent('addCharacterToList'):
					if (ScriptExprTools.lua_getValue(params[0]) != null || ScriptExprTools.lua_getValue(params[0]) != '')
							putPreload(imagesToPrepare, Std.string(ScriptExprTools.lua_getValue(params[0])));

				////////////////////////////////////////////////////////////////////////////////////////////////////////

				case EIdent('precacheSound'):
					if (ScriptExprTools.lua_getValue(params[0]) != null || ScriptExprTools.lua_getValue(params[0]) != '')
							putPreload(soundsToPrepare, Std.string(ScriptExprTools.lua_getValue(params[0])));
				case EIdent('precacheMusic'):
					if (ScriptExprTools.lua_getValue(params[0]) != null || ScriptExprTools.lua_getValue(params[0]) != '')
							putPreload(musicToPrepare, Std.string(ScriptExprTools.lua_getValue(params[0])));

				case EIdent('playSound'):
					if (ScriptExprTools.lua_getValue(params[0]) != null || ScriptExprTools.lua_getValue(params[0]) != '')
							putPreload(soundsToPrepare, Std.string(ScriptExprTools.lua_getValue(params[0])));
				case EIdent('playMusic'):
					if (ScriptExprTools.lua_getValue(params[0]) != null || ScriptExprTools.lua_getValue(params[0]) != '')
							putPreload(musicToPrepare, Std.string(ScriptExprTools.lua_getValue(params[0])));

				////////////////////////////////////////////////////////////////////////////////////////////////////////

				case EIdent('addLuaScript'):
					if (ScriptExprTools.lua_getValue(params[0]) != null || ScriptExprTools.lua_getValue(params[0]) != '')
							startLuaNamed(Std.string(ScriptExprTools.lua_getValue(params[0])));

				case EIdent('runHaxeCode'):
					if (ScriptExprTools.lua_getValue(params[0]) != null || ScriptExprTools.lua_getValue(params[0]) != '')
							hscriptFilesCheck(Std.string(ScriptExprTools.lua_getValue(params[0])), false);
				case EIdent('startDialogue'):
					if (PlayState.isStoryMode)  {
						if (ScriptExprTools.lua_getValue(params[0]) != null || ScriptExprTools.lua_getValue(params[0]) != '') {
							var dialogueFile = Std.string(ScriptExprTools.lua_getValue(params[0]));
							var path:String;
							#if MODS_ALLOWED
							path = Paths.modsJson(Paths.formatToSongPath(PlayState.SONG.song) + '/' + dialogueFile);
							if (!FileSystem.exists(path))
							#end
							path = Paths.json(Paths.formatToSongPath(PlayState.SONG.song) + '/' + dialogueFile);

							#if MODS_ALLOWED
							if (FileSystem.exists(path))
							#else
							if (Assets.exists(path))
							#end
							{
								var dialogueList:DialogueFile = DialogueBoxPsych.parseDialogue(path);
								for (i in 0...dialogueList.dialogue.length)							
									if (dialogueList.dialogue[i] != null) {							
										putPreload(imagesToPrepare, 'dialogue/' + Std.string(dialogueList.dialogue[i].portrait));		
										putPreload(soundsToPrepare, Std.string(dialogueList.dialogue[i].sound));		
									}														
							}
						}
						if (ScriptExprTools.lua_getValue(params[1]) != null || ScriptExprTools.lua_getValue(params[1]) != '') {
							putPreload(musicToPrepare, Std.string(ScriptExprTools.lua_getValue(params[1])));
						}
					}
				case _:
			}
		});
	}

	static function startHscriptNamed(filePath:String)
	{
		#if MODS_ALLOWED
		var pathToLoad:String = Paths.modFolders(filePath);
		if (!FileSystem.exists(pathToLoad))
			pathToLoad = Paths.getSharedPath(filePath);

		if (FileSystem.exists(pathToLoad))
		#else
		var pathToLoad:String = Paths.getSharedPath(filePath);
		if (Assets.exists(pathToLoad))
		#end
		{
			hscriptFilesCheck(pathToLoad);
		}
	}

	static function hscriptFilesCheck(file:String, isFile:Bool = true)
	{
		var input:String = '';
		if (isFile){
			File.getContent(file);	
			//trace('Hscript: load Path: ' + file);
		} else {
			input = file;
		}

		if (StringTools.fastCodeAt(input, 0) == 0xFEFF) {
			input = input.substr(1);
		} //防止BOM字符 <UTF-8 with BOM> <\65279>

		var parser = new Parser();
		parser.allowTypes = parser.allowMetadata = parser.allowJSON = true;
		var e:Expr = parser.parseString(input);

		ScriptExprTools.hx_searchCallback(e, function(e:Expr, params:Array<Expr>) {
			switch(Tools.expr(e)) {
				case EField(e, f, _):
					ScriptExprTools.hx_recursion(e, function(e:Expr) {
						switch(Tools.expr(e)) {
							case EIdent("Paths") if(f == "image"):
								if (ScriptExprTools.hx_getValue(params[0]) != null || ScriptExprTools.hx_getValue(params[0]) != '')
									putPreload(imagesToPrepare, Std.string(ScriptExprTools.hx_getValue(params[0])));
							case EIdent("Paths") if(f == "cacheBitmap"):
								if (ScriptExprTools.hx_getValue(params[0]) != null || ScriptExprTools.hx_getValue(params[0]) != '')
									putPreload(imagesToPrepare, Std.string(ScriptExprTools.hx_getValue(params[0])));
							case EIdent("Paths") if(f == "sound"):
								if (ScriptExprTools.hx_getValue(params[0]) != null || ScriptExprTools.hx_getValue(params[0]) != '')
									putPreload(soundsToPrepare, Std.string(ScriptExprTools.hx_getValue(params[0])));
							case EIdent("Paths") if(f == "music"):
								if (ScriptExprTools.hx_getValue(params[0]) != null || ScriptExprTools.hx_getValue(params[0]) != '')
									putPreload(musicToPrepare, Std.string(ScriptExprTools.hx_getValue(params[0])));
							case _:
						}
					});
				case _:
			}
		});
	}

	//上面为数据准备部分
	///////////////////////////////////////////
	//下面开始游戏加载流程

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		loads.angle += 1.5;
		
		if (waitPrepare) 
			return;

		if (curPercent != intendedPercent)
		{
			if (Math.abs(curPercent - intendedPercent) < 0.005)
				curPercent = intendedPercent;
			else
				curPercent = FlxMath.lerp(intendedPercent, curPercent, Math.exp(-elapsed * 15));

			bar.scale.x = button.width / 2 + (FlxG.width - button.width) * curPercent;
			button.x = FlxG.width * curPercent - button.width * curPercent;
			bar.updateHitbox();
			button.updateHitbox();
			var precent:Float = Math.floor(curPercent * 10000) / 100;
			if (precent % 1 == 0)
				precentText.text = precent + '.00%';
			else if ((precent * 10) % 1 == 0)
				precentText.text = precent + '0%';
			else
				precentText.text = precent + '%'; // 修复显示问题
		};

		if (loadMax > 0)
			intendedPercent = loaded / loadMax;
		else
			intendedPercent = 1;

		if (curPercent == 1)
		{
			onLoad();
			return;
		}
	}

	function onLoad() //加载完毕进行跳转
	{
		useAsyncUpload = false;
		checkLoaded();

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if (FreeplayState.vocalsPlayer1 != null)
			FreeplayState.destroyFreeplayVocals();

		imagesToPrepare = [];
		soundsToPrepare = [];
		musicToPrepare = [];
		songsToPrepare = [];

		GCManager.enable(true);

		if (isPlayState)
		{
			isPlayState = false;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new PlayState());
		}
		else
		{
			requestedBitmaps.clear();
			MusicBeatState.switchState(target);
		}
	}

	static function checkLoaded():Bool
	{
		if (useAsyncUpload) {
			var keys = [for (k in requestedBitmaps.keys()) k];
			for (key in keys) {
				var bitmap = requestedBitmaps.get(key);
				requestedBitmaps.remove(key);
				if (bitmap != null) {
					pendingUploads++;
					AsyncTextureUploader.uploadFromBitmap(key, bitmap, function() {
						pendingUploads--;
					}, function(err:String) {
						trace('IMAGE: failed to async upload image $key: $err');
						// 如果异步失败，尝试回退到同步缓存（或者直接报错）
						// 这里我们保守处理，直接用原始bitmap缓存
						if (Paths.cacheBitmap(key, bitmap, false) != null) {
							trace('IMAGE: fallback synchronous caching for $key');
						}
						pendingUploads--;
					});
				}
			}
			return (loaded == loadMax && pendingUploads == 0 && !requestedBitmaps.iterator().hasNext());
		}

		for (key => bitmap in requestedBitmaps)
		{
			if (bitmap != null && Paths.cacheBitmap(key, bitmap, false) != null) {
				trace('IMAGE: finished preloading image $key');
			} else
				trace('IMAGE: failed to cache image $key');
		}
		return (loaded == loadMax);
	}

	public static function startThreads()
	{
		clearInvalids();
		loaded = 0;
		loadMax = imagesToPrepare.length + soundsToPrepare.length + musicToPrepare.length + songsToPrepare.length;

		//trace('LoadingState: startThreads, loadMax: $loadMax');
		loadThread = new ThreadPool(ClientPrefs.data.loadThreads, ClientPrefs.data.loadThreads, MULTI_THREADED);
		threadInit();

		for (sound in soundsToPrepare)
			threadWork(() -> 
			{
				return {type:'sound', path:sound, file:Paths.sound(sound, true), alreadyLoaded: false, error: null};
			});

		for (music in musicToPrepare)
			threadWork(() ->
			{
				return {type:'music', path:music, file:Paths.music(music, true), alreadyLoaded: false, error: null};
			});
		for (song in songsToPrepare)
			threadWork(() ->
			{
				return {type:'song', path:song, file:Paths.returnSound(null, song, 'songs', true), alreadyLoaded: false, error: null};
			});

		
		for (image in imagesToPrepare) {
			//trace('LoadingState: startThreads, image: $image');
			threadWork(() -> 
			{
				var bitmap:BitmapData = null;
				var realPath:String = null;

				#if MODS_ALLOWED
				realPath = Paths.modsImages(image);
				if (Cache.currentTrackedAssets.exists(realPath))
				{
					return {type:'image', path: realPath, file: null, alreadyLoaded: true, error: null};
				}
				else if (FileSystem.exists(realPath)) {
					try { 
						bitmap = BitmapData.fromFile(realPath); 
					} catch(e) {
						return {type:'image', path: realPath, file: null, alreadyLoaded: false, error: e};
					}
				}
				else
				#end
				{
					realPath = Paths.getPath('images/$image.png', IMAGE);
					if (Cache.currentTrackedAssets.exists(realPath))
					{
						return {type:'image', path: realPath, file: null, alreadyLoaded: true, error: null};
					}
					else if (OpenFlAssets.exists(realPath, IMAGE)) {
						try { 
							bitmap = OpenFlAssets.getBitmapData(realPath); 
						} catch(e) {
							return {type:'image', path: realPath, file: null, alreadyLoaded: false, error: e};
						}
					}
				}
				return {type:'image', path: realPath, file: bitmap, alreadyLoaded: false, error: null};
			});
		};
	}

	static function threadInit():Void {
		loadThread.onComplete.add(function(msg:{type:String, path:String, file:Dynamic, alreadyLoaded:Bool, error:Dynamic}) {
			switch (msg.type) {
				case 'sound', 'song', 'music':
					trace(msg.type.toUpperCase() + ': finished preloading ' + msg.path);
				case 'image':
					if (!msg.alreadyLoaded) requestedBitmaps.set(msg.path, msg.file);
			}
			addLoadCount();
		});
		loadThread.onError.add(function(msg:{type:String, path:String, error:Dynamic}) {
			if (msg.error != null) {
				switch (msg.type) {
					case 'system':
						trace('SYSTEM: data send error because of ' + msg.error);
					case _:
						trace(msg.type.toUpperCase() + ': ERROR! fail on preloading because of ' + msg.error);
				}
			} else {
				trace(msg.type.toUpperCase() + ': no such ' + msg.path + ' exists');
			}
			addLoadCount();
		});
	}

	static function threadWork(func:Void->Dynamic):Void {
		loadThread.run(sendThreadData, {func: func});
	}

	static function sendThreadData(state:{func:Void->Dynamic}, out:WorkOutput):Void {
		try {
			var result:Dynamic = state.func();

			if (result.error == null) {
				switch (result.type) {
					case 'sound', 'song', 'music':
						if ((Reflect.hasField(result, "file") && result.file != null)) 
						{
							out.sendComplete({type:result.type, path: result.path, file: result.file, error: result.error});
						} else {
							out.sendError({type:result.type, path: result.path, error:null});
						}
					case 'image':
						if ((Reflect.hasField(result, "file") && result.file != null) || 
							(Reflect.hasField(result, "alreadyLoaded") && result.alreadyLoaded)) 
						{
							out.sendComplete({type:result.type, path: result.path, file: result.file, alreadyLoaded: result.alreadyLoaded, error: result.error});
						} else {
							out.sendError({type:result.type, path: result.path, error:null});
						}
				}
			}
			else out.sendError({type:result.type, path: result.path, error: result.error});
		} catch (e:Dynamic) {
			out.sendError({type: 'system', path:null, error: e});
		}
	}

	///////////////////////////////////////////////////////////////////////////////

	static function addLoadCount() {
		loaded++;
	}

	static function putPreload(tar:Dynamic, file:String) {
		if (!tar.contains(file)) tar.push(file);
	}

	//////////////////////////////////////////////

	public static function clearInvalids()
	{
		clearInvalidFrom(imagesToPrepare, 'images', '.png', IMAGE);
		clearInvalidFrom(soundsToPrepare, 'sounds', '.${Paths.SOUND_EXT}', SOUND);
		clearInvalidFrom(musicToPrepare, 'music', '.${Paths.SOUND_EXT}', SOUND);
		clearInvalidFrom(songsToPrepare, 'songs', '.${Paths.SOUND_EXT}', SOUND);

		for (arr in [imagesToPrepare, soundsToPrepare, musicToPrepare, songsToPrepare])
			while (arr.contains(null))
				arr.remove(null);
	}

	static function clearInvalidFrom(arr:Array<String>, prefix:String, ext:String, type:AssetType, ?library:String = null)
	{
		for (i in 0...arr.length)
		{
			var folder:String = arr[i];
			if (folder.trim().endsWith('/'))
			{
				for (subfolder in Mods.directoriesWithFile(Paths.getSharedPath(), '$prefix/$folder'))
					for (file in FileSystem.readDirectory(subfolder))
						if (file.endsWith(ext))
							arr.push(folder + file.substr(0, file.length - ext.length));
			}
		}

		var i:Int = 0;
		while (i < arr.length)
		{
			var member:String = arr[i];
			var myKey = '$prefix/$member$ext';
			// if(library == 'songs') myKey = '$member$ext';

			//trace('attempting on $prefix: $myKey');
			var doTrace:Bool = false;
			if (member.endsWith('/') || (!Paths.fileExists(myKey, type, false, library) && (doTrace = true)))
			{
				arr.remove(member);
			}
			else
				i++;
		}
	}
	
	//////////////////////////////////////////////

	
}

class LoadButton extends FlxSprite
{
	public function new(x:Float, y:Float, Width:Int, Height:Int)
	{
		super(x, y);
		makeGraphic(Width, Height, 0x00);

		var shape:Shape = new Shape();
		shape.graphics.beginFill(color);
		shape.graphics.drawRoundRect(0, 0, Width, Height, Std.int(Height / 1), Std.int(Height / 1));
		shape.graphics.endFill();

		var BitmapData:BitmapData = new BitmapData(Width, Height, 0x00);
		BitmapData.draw(shape);

		pixels = BitmapData;
		setGraphicSize(Width, Height);
	}
}
