package;

import developer.display.FPSViewer;
import developer.display.Graphics;
import developer.console.TraceInterceptor;

import screen.mouseEvent.MouseEffect;

import flixel.graphics.FlxGraphic;
import flixel.FlxGame;

import haxe.io.Path;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import openfl.events.KeyboardEvent;
import lime.system.System as LimeSystem;
import lime.app.Application;
import states.TitleState;
import states.backend.InitState;
import states.backend.PassState;
import mobile.backend.Data;
import backend.extraKeys.ExtraKeysHandler;

#if android
import backend.device.AppData;
import states.backend.PirateState;
import sys.io.File;
#end

#if desktop
import backend.device.ALSoftConfig;
#end
#if hl
import hl.Api;
#end
#if linux
import lime.graphics.Image;

@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

import haxe.ui.Toolkit;


class Main extends Sprite
{
	private static var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: InitState,
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPSViewer;
	public static var watermark:Watermark;

	#if mobile
	public static final platform:String = "Phones";
	#else
	public static final platform:String = "PCs";
	#end

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
	    TraceInterceptor.init();
		#if (cpp && windows)
		backend.device.Native.fixScaling();
		backend.device.Native.setWindowDarkMode(true, true);
		#end
		
		Lib.current.addChild(new Main());
		#if cpp

		cpp.vm.Gc.enable(true);
		cpp.vm.Gc.run(true);  
		#end
	}
	
	public function new()
	{
		super();
		#if android
		SUtil.doPermissionsShit();
		#end
		mobile.backend.CrashHandler.init();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		#if VIDEOS_ALLOWED
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0") ['--no-lua'] #end);
		#end
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}

		Toolkit.init();

		#if LUA_ALLOWED llua.Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(scripts.lua.CallbackHandler.call)); #end
		Controls.instance = new Controls();

		#if mobile
		#if android
		if (!FileSystem.exists(AndroidEnvironment.getExternalStorageDirectory() + '/.' + Application.current.meta.get('file')))
			FileSystem.createDirectory(AndroidEnvironment.getExternalStorageDirectory() + '/.' + Application.current.meta.get('file'));
		#end
		Sys.setCwd(SUtil.getStorageDirectory());
		#end

		#if android
			if (AppData.getVersionName() != Application.current.meta.get('version')
				|| AppData.getAppName() != Application.current.meta.get('file')                                                                                                                                                                                                                                                                                                                                                                                                                         || !AppData.verifySignature()
				|| (AppData.getPackageName() != Application.current.meta.get('packageName')
					&& AppData.getPackageName() != Application.current.meta.get('packageName') + 'Backup1' // 共存
					&& AppData.getPackageName() != Application.current.meta.get('packageName') + 'Backup2' // 共存
					&& AppData.getPackageName() != 'com.antutu.ABenchMark' // 超频测试 安兔兔
					&& AppData.getPackageName() != 'com.ludashi.benchmark' // 超频测试 鲁大师
				)) {
					FlxG.switchState(new PirateState());
					return;
				}
		#end

		///////////////////////////////////////////   --包含有读取文件的别在这个的上面运行

		ExtraKeysHandler.instance = new ExtraKeysHandler();
		ClientPrefs.loadDefaultKeys();

		var flxGame:FlxGame = new FlxGame(#if (openfl >= "9.2.0") 1280, 720 #else game.width, game.height #end,game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen);
		addChild(flxGame);

		fpsVar = new FPSViewer(5, 5);
		FlxG.addChildBelowMouse(fpsVar);

		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		var image:String = Paths.modFolders('images/menuExtend/Others/watermark.png');

		if (FileSystem.exists(image))
		{
			if (watermark != null)
				removeChild(watermark);
			watermark = new Watermark(5, Lib.current.stage.stageHeight - 5, 0.4);
			addChild(watermark);
			watermark.y -= watermark.bitmapData.height;
		}
		if (watermark != null)
		{
			watermark.scaleX = watermark.scaleY = ClientPrefs.data.WatermarkScale;
			watermark.y += (1 - ClientPrefs.data.WatermarkScale) * watermark.bitmapData.height;
			watermark.visible = ClientPrefs.data.showWatermark;
		}

		var effect = new MouseEffect();
		addChild(effect);

		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end

		#if mobile
		LimeSystem.allowScreenTimeout = ClientPrefs.data.screensaver;
		#end
		Data.setup();

		#if !debug
			//cpp.NativeGc.enterGCFreeZone();
		#end
	}

	@:allow(states.backend.InitState)
	static function resetSpriteCache(sprite:Sprite):Void
	{
		@:privateAccess {
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	@:allow(states.backend.InitState)
	private static function initScriptModules() {
		#if (MODS_ALLOWED && HSCRIPT_ALLOWED)
		var paths:Array<String> = [];

		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'stageScripts/modules/'))
			if(FileSystem.exists(folder) && FileSystem.isDirectory(folder)) {
				final path = Path.addTrailingSlash(folder);
				paths.push(path + "$" + Mods.toDisplayPath(path));
			}

		trace("scriptClass Paths: " + paths);
		scripts.stages.modules.ScriptedModuleNotify.init([scripts.stages.modules.ScriptedModule], paths, scripts.stages.modules.ModuleHandler.includeExtension, [
			// Extended Class
			"ScriptedState" => scripts.scriptClasses.ScriptedState,
			"ScriptedBaseStage" => scripts.scriptClasses.ScriptedBaseStage,
			"ScriptedGroup" => scripts.scriptClasses.ScriptedGroup,
			"ScriptedSprite" => scripts.scriptClasses.ScriptedSprite,
			"ScriptedSpriteGroup" => scripts.scriptClasses.ScriptedSpriteGroup,
			"ScriptedSubstate" => scripts.scriptClasses.ScriptedSubstate,

			// Flixel Something
			"FlxG" => flixel.FlxG,
			"FlxSprite" => flixel.FlxSprite,
			"FlxGroup" => flixel.group.FlxGroup,
			"FlxSpriteGroup" => flixel.group.FlxSpriteGroup,
			"FlxText" => flixel.text.FlxText,

			"MusicBeatState" => backend.MusicBeatState,
			"PlayState" => states.PlayState,
			"Application" => lime.app.Application,

			// Engine Something
			'Conductor' => backend.Conductor,
			"Paths" => backend.Paths,
			'ClientPrefs' => backend.ClientPrefs,
			#if ACHIEVEMENTS_ALLOWED
			'Achievements' => backend.Achievements,
			#end
		]);
		#end
	}

	@:allow(states.backend.InitState)
	static function toggleFullScreen(event:KeyboardEvent)
	{
		if (Controls.instance.justReleased('fullscreen'))
			FlxG.fullscreen = !FlxG.fullscreen;
	}

	static public var type:Bool = ClientPrefs.data.gcFreeZone;
	static public function GcZoneChange()
	{
		#if !debug
		if (type == true)
		{
			//cpp.NativeGc.exitGCFreeZone();
			type = false;
		}
		else
		{
			//cpp.NativeGc.enterGCFreeZone();
			type = true;
		}
		#end
	}
}
