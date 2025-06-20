package states;

import backend.WeekData;
import backend.Highscore;

import flixel.addons.transition.FlxTransitionableState;
import flixel.input.gamepad.FlxGamepad;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import shaders.ColorblindFilter;
import states.StoryMenuState;
import states.OutdatedState;
import states.MainMenuState;
import states.TitleState;
#if mobile
import mobile.states.CopyState;
#end
import lime.app.Application;
#if hxvlc
import hxvlc.flixel.FlxVideoSprite;
#end
#if android
import backend.device.AppData;
import states.PirateState;
#end

class InitState extends MusicBeatState
{
	public static var initialized:Bool = false;
	public static var inGame:Bool = false;

	public static var ignoreCopy:Bool = false;

	var skipVideo:FlxText;

	var checkOpenFirst:Bool = false;

	var mustUpdate:Bool = false;

	public static var updateVersion:String = '';

	override public function create():Void
	{
		Paths.clearStoredMemory();
		
		FlxTransitionableState.skipNextTransOut = true;
		FlxTransitionableState.skipNextTransIn = true;

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		super.create();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		
		ClientPrefs.loadPrefs();
		
		#if LUA_ALLOWED
		#if (android && EXTERNAL || MEDIA)
		try
		{
		#end
			Mods.pushGlobalMods();
		#if (android && EXTERNAL || MEDIA)
		}
		catch (e:Dynamic)
		{
			SUtil.showPopUp("permission is not obtained, restart the application", "Error!");
			Sys.exit(1);
		}
		#end
		#end
	
		Mods.loadTopMod();
	
		#if CHECK_FOR_UPDATES
		if (ClientPrefs.data.checkForUpdates && !closedState)
		{
			try
			{
				trace('checking for update');
				var http = new haxe.Http("https://raw.githubusercontent.com/beihu235/FNF-NovaFlare-Engine/main/gitVersion.txt");
	
				http.onData = function(data:String)
				{
					updateVersion = data.split('\n')[0].trim();
					var curVersion:Float = MainMenuState.novaFlareEngineDataVersion;
					trace('version online: ' + data.split('\n')[0].trim() + ', your version: ' + MainMenuState.novaFlareEngineVersion);
					if (Std.parseFloat(updateVersion) > curVersion)
					{
						trace('versions arent matching!');
						mustUpdate = true;
					}
				}
	
				http.onError = function(error)
				{
					trace('error: $error');
				}
	
				http.request();
			}
		}
		#end
	
		Language.resetData();
	
		Highscore.load();

		#if android
		if (AppData.getVersionName() != Application.current.meta.get('version')
			|| AppData.getAppName() != Application.current.meta.get('file')
			|| (AppData.getPackageName() != Application.current.meta.get('packageName')
				&& AppData.getPackageName() != Application.current.meta.get('packageName') + 'Backup1' // 共存
				&& AppData.getPackageName() != Application.current.meta.get('packageName') + 'Backup2' // 共存
				&& AppData.getPackageName() != 'com.antutu.ABenchMark' // 超频测试 安兔兔
				&& AppData.getPackageName() != 'com.ludashi.benchmark' // 超频测试 鲁大师
			))
			FlxG.switchState(new PirateState());
		#end

		#if mobile // 检查assets/version.txt存不存在且里面保存的上一个版本号与当前的版本号一不一致，如果不一致或不存在，强制启动copy。
		if (!FileSystem.exists(Paths.getSharedPath('version.txt')))
		{
			sys.io.File.saveContent(Paths.getSharedPath('version.txt'), 'now version: ' + Std.string(states.MainMenuState.novaFlareEngineVersion));
			FlxG.switchState(new CopyState(true));
			return;
		}
		else
		{
			if (sys.io.File.getContent(Paths.getSharedPath('version.txt')) != 'now version: ' + Std.string(states.MainMenuState.novaFlareEngineVersion))
			{
				sys.io.File.saveContent(Paths.getSharedPath('version.txt'), 'now version: ' + Std.string(states.MainMenuState.novaFlareEngineVersion));
				FlxG.switchState(new CopyState(true));
				return;
			}
		}

		if (ClientPrefs.data.filesCheck)
		{
			if (!CopyState.checkExistingFiles() && !ignoreCopy)
			{
				// ClientPrefs.data.filesCheck = false;
				ClientPrefs.saveSettings();
				FlxG.switchState(new CopyState());
				return;
			}
		}
		#end
		
		#if LUA_ALLOWED
		#if (android && EXTERNAL || MEDIA)
		try
		{
		#end
			Mods.pushGlobalMods();
		#if (android && EXTERNAL || MEDIA)
		}
		catch (e:Dynamic)
		{
			SUtil.showPopUp("permission is not obtained, restart the application", "Error!");
			Sys.exit(1);
		}
		#end
		#end
	
		Mods.loadTopMod();
	
		#if CHECK_FOR_UPDATES
		if (ClientPrefs.data.checkForUpdates && !closedState)
		{
			try
			{
				trace('checking for update');
				var http = new haxe.Http("https://raw.githubusercontent.com/beihu235/FNF-NovaFlare-Engine/main/gitVersion.txt");
	
				http.onData = function(data:String)
				{
					updateVersion = data.split('\n')[0].trim();
					var curVersion:Float = MainMenuState.novaFlareEngineDataVersion;
					trace('version online: ' + data.split('\n')[0].trim() + ', your version: ' + MainMenuState.novaFlareEngineVersion);
					if (Std.parseFloat(updateVersion) > curVersion)
					{
						trace('versions arent matching!');
						mustUpdate = true;
					}
				}
	
				http.onError = function(error)
				{
					trace('error: $error');
				}
	
				http.request();
			}
		}
		#end
	
		Language.resetData();
	
		Highscore.load();
	
		if (!initialized)
		{
			if (FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				// trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}
	
		ColorblindFilter.UpdateColors();
	
		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}
	
		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if (!ClientPrefs.data.openedFlash)
		{
			ClientPrefs.data.openedFlash = true;
			ClientPrefs.saveSettings();
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		}
		else
		{
			if (initialized)
				startCutscenesIn();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startCutscenesIn();
				});
			}
		}
		#end
	}
	
	function startCutscenesIn()
	{
		if (inGame)
		{
			startIntro();
			return;
		}
		if (!ClientPrefs.data.skipTitleVideo)
			#if VIDEOS_ALLOWED
			startVideo('menuExtend/titleIntro');
			#else
			startCutscenesOut();
			#end
		else
			startCutscenesOut();
	}
	
	function startCutscenesOut()
	{
		inGame = true;
		startIntro();
	}
	
	function startIntro()
	{
		persistentUpdate = true;
		Paths.clearUnusedMemory();
	}
	
	private static var playJingle:Bool = false;
	
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
			
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;
	
		#if FLX_TOUCH
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end
	
		#if android
		if (videoBool)
		{
			pressedEnter = false;
			if (FlxG.android.justReleased.BACK)
				pressedEnter = true;
		}
		#end
	
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
	
		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;
	
			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (pressedEnter)
		{
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				if (mustUpdate && !OutdatedState.leftState)
				{
					MusicBeatState.switchState(new OutdatedState());
				}
				else
				{
					MusicBeatState.switchState(new TitleState());
				}
				closedState = true;
			});
		}
	
		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}
	
		if (videoBool)
		{
			if (pressedEnter)
			{
				video.stop();
				video.visible = false;
				videoBool = false;
				skipVideo.visible = false;
				startCutscenesOut();
			}
		}
	
		super.update(elapsed);
	}
	
	public static var closedState:Bool = false;
	
	var skippedIntro:Bool = false;
	
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			if (playJingle)
			{
				playJingle = false;
			}
			skippedIntro = true;
		}
	}
	
	#if VIDEOS_ALLOWED
	var video:FlxVideoSprite;
	var videoBool:Bool = false;
	
	function startVideo(name:String)
	{
		skipVideo = new FlxText(0, FlxG.height - 26, 0, "Press " + #if android "Back on your Phone " #else "Enter " #end + "to skip", 18);
		skipVideo.setFormat(Assets.getFont("assets/fonts/montserrat.ttf").fontName, 18);
		skipVideo.alpha = 0;
		skipVideo.alignment = CENTER;
		skipVideo.screenCenter(X);
		skipVideo.scrollFactor.set();
		skipVideo.antialiasing = ClientPrefs.data.antialiasing;
	
		#if VIDEOS_ALLOWED
		var filepath:String = Paths.video(name);
		#if sys
		if (!FileSystem.exists(filepath))
		#else
		if (!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			videoEnd();
			return;
		}
	
		video = new FlxVideoSprite(0, 0);
		video.antialiasing = true;
		video.bitmap.onFormatSetup.add(function():Void
		{
			if (video.bitmap != null && video.bitmap.bitmapData != null)
			{
				final scale:Float = Math.min(FlxG.width / video.bitmap.bitmapData.width, FlxG.height / video.bitmap.bitmapData.height);
	
				video.setGraphicSize(video.bitmap.bitmapData.width * scale, video.bitmap.bitmapData.height * scale);
				video.updateHitbox();
				video.screenCenter();
			}
		});
		video.bitmap.onEndReached.add(video.destroy);
		add(video);
		video.load(filepath);
		video.play();
		videoBool = true;
	
		video.bitmap.onEndReached.add(function()
		{
			videoEnd();
		});
	
		showText();
		#else
		FlxG.log.warn('Platform not supported!');
		videoEnd();
		return;
		#end
	}
	
	function videoEnd()
	{
		skipVideo.visible = false;
		if (video != null)
			video.stop();
		video.visible = false;
		startCutscenesOut();
		videoBool = false;
		trace("end");
	}
	
	function showText()
	{
		add(skipVideo);
		FlxTween.tween(skipVideo, {alpha: 1}, 1, {ease: FlxEase.quadIn});
		FlxTween.tween(skipVideo, {alpha: 0}, 1, {ease: FlxEase.quadIn, startDelay: 4});
	}
	#end
}
