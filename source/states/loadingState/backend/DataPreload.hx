package states.loadingState.backend;

import general.backend.ClientPrefs;
import general.backend.Mods;
import general.backend.Paths;
import games.funkin_legacy.backend.Rating;
import games.funkin_legacy.backend.Song;
import games.funkin_legacy.backend.StageData;
import games.funkin_legacy.cutscenes.DialogueBoxPsych;
import games.funkin_legacy.PlayState;
import states.loadingState.LoadingState;
import sys.FileSystem;
import sys.io.File;
import lime.utils.Assets;
import haxe.Json;
import openfl.utils.AssetType;
import crowplexus.hscript.Parser;
import crowplexus.hscript.Expr;
import crowplexus.hscript.Tools;
import luahscript.LuaParser;
import luahscript.exprs.LuaExpr;

using StringTools;

class DataPreload
{
	public static function startPrepare()
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
				LoadingState.instance.prepare((!ClientPrefs.data.lowQuality || json.images_low) ? json.images : json.images_low, json.sounds, json.music);
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
			LoadingState.instance.prepare(imgs, snds, mscs);
		}

		LoadingState.instance.putPreload(LoadingState.instance.songsToPrepare, '$folder/Inst');

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
			LoadingState.instance.putPreload(LoadingState.instance.songsToPrepare, prefixVocals);
			LoadingState.instance.putPreload(LoadingState.instance.songsToPrepare, '$prefixVocals-Player');
			LoadingState.instance.putPreload(LoadingState.instance.songsToPrepare, '$prefixVocals-Opponent');
		}

		if (player2 != player1)
			preloadCharacter(player2, prefixVocals);
		if (stageData != null && !stageData.hide_girlfriend && gfVersion != player2 && gfVersion != player1)
			preloadCharacter(gfVersion);

		LoadingState.instance.chartNoteTypes = [];
		for (section in PlayState.SONG.notes)
		{
			for (songNotes in section.sectionNotes)
			{
				if (!LoadingState.instance.chartNoteTypes.contains(songNotes[3]))
				{
					LoadingState.instance.chartNoteTypes.push(songNotes[3]);
				}
			}
		}
		LoadingState.instance.chartEvents = [];
		for (event in PlayState.SONG.events) // Event Notes
			LoadingState.instance.chartEvents.push(event);

		preloadMisc();
		preloadScript();

		LoadingState.instance.waitPrepare = false;
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
					LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, file.trim());
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
						LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, '$img/spritemap$st');
						break;
					}
				}
			}
			#end

			LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, 'icons/' + character.healthicon);
			LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, 'icons/icon-' + character.healthicon);

			if (prefixVocals != null && character.vocals_file != null && character.vocals_file.length > 0)
			{
				LoadingState.instance.putPreload(LoadingState.instance.songsToPrepare, prefixVocals + "-" + character.vocals_file);
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
			LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, uiPrefix + rating.image + uiSuffix);
		}

		for (i in 0...10)
			LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, uiPrefix + 'num' + i + uiSuffix);

		LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, uiPrefix + 'ready' + uiSuffix);
		LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, uiPrefix + 'set' + uiSuffix);
		LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, uiPrefix + 'go' + uiSuffix);
		LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, 'healthBar');

		if (PlayState.isStoryMode)  {
			LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, 'speech_bubble');
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

		for (noteType in LoadingState.instance.chartNoteTypes)
		{
			startLuaNamed('custom_notetypes/' + noteType + '.lua');
			startHscriptNamed('custom_notetypes/' + noteType + '.hx');
		}

		for (event in LoadingState.instance.chartEvents)
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
						LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, Std.string(ScriptExprTools.lua_getValue(params[1])));
				case EIdent('makeAnimatedLuaSprite'):
					if (ScriptExprTools.lua_getValue(params[1]) != null || ScriptExprTools.lua_getValue(params[1]) != '')
							LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, Std.string(ScriptExprTools.lua_getValue(params[1])));
				case EIdent('precacheImage'):
					if (ScriptExprTools.lua_getValue(params[0]) != null || ScriptExprTools.lua_getValue(params[0]) != '')
							LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, Std.string(ScriptExprTools.lua_getValue(params[0])));
				case EIdent('addCharacterToList'):
					if (ScriptExprTools.lua_getValue(params[0]) != null || ScriptExprTools.lua_getValue(params[0]) != '')
							LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, Std.string(ScriptExprTools.lua_getValue(params[0])));

				////////////////////////////////////////////////////////////////////////////////////////////////////////

				case EIdent('precacheSound'):
					if (ScriptExprTools.lua_getValue(params[0]) != null || ScriptExprTools.lua_getValue(params[0]) != '')
							LoadingState.instance.putPreload(LoadingState.instance.soundsToPrepare, Std.string(ScriptExprTools.lua_getValue(params[0])));
				case EIdent('precacheMusic'):
					if (ScriptExprTools.lua_getValue(params[0]) != null || ScriptExprTools.lua_getValue(params[0]) != '')
							LoadingState.instance.putPreload(LoadingState.instance.musicToPrepare, Std.string(ScriptExprTools.lua_getValue(params[0])));

				case EIdent('playSound'):
					if (ScriptExprTools.lua_getValue(params[0]) != null || ScriptExprTools.lua_getValue(params[0]) != '')
							LoadingState.instance.putPreload(LoadingState.instance.soundsToPrepare, Std.string(ScriptExprTools.lua_getValue(params[0])));
				case EIdent('playMusic'):
					if (ScriptExprTools.lua_getValue(params[0]) != null || ScriptExprTools.lua_getValue(params[0]) != '')
							LoadingState.instance.putPreload(LoadingState.instance.musicToPrepare, Std.string(ScriptExprTools.lua_getValue(params[0])));

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
										LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, 'dialogue/' + Std.string(dialogueList.dialogue[i].portrait));		
										LoadingState.instance.putPreload(LoadingState.instance.soundsToPrepare, Std.string(dialogueList.dialogue[i].sound));		
									}														
							}
						}
						if (ScriptExprTools.lua_getValue(params[1]) != null || ScriptExprTools.lua_getValue(params[1]) != '') {
							LoadingState.instance.putPreload(LoadingState.instance.musicToPrepare, Std.string(ScriptExprTools.lua_getValue(params[1])));
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
									LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, Std.string(ScriptExprTools.hx_getValue(params[0])));
							case EIdent("Paths") if(f == "cacheBitmap"):
								if (ScriptExprTools.hx_getValue(params[0]) != null || ScriptExprTools.hx_getValue(params[0]) != '')
									LoadingState.instance.putPreload(LoadingState.instance.imagesToPrepare, Std.string(ScriptExprTools.hx_getValue(params[0])));
							case EIdent("Paths") if(f == "sound"):
								if (ScriptExprTools.hx_getValue(params[0]) != null || ScriptExprTools.hx_getValue(params[0]) != '')
									LoadingState.instance.putPreload(LoadingState.instance.soundsToPrepare, Std.string(ScriptExprTools.hx_getValue(params[0])));
							case EIdent("Paths") if(f == "music"):
								if (ScriptExprTools.hx_getValue(params[0]) != null || ScriptExprTools.hx_getValue(params[0]) != '')
									LoadingState.instance.putPreload(LoadingState.instance.musicToPrepare, Std.string(ScriptExprTools.hx_getValue(params[0])));
							case _:
						}
					});
				case _:
			}
		});
	}
}