package states.backend;

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
import states.FreeplayState;
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
import states.backend.PirateState;
import sys.io.File;
#end

import sys.thread.Thread;

class InitState extends MusicBeatState
{
	var skipVideo:FlxText;

	var mustUpdate:Bool = false;

	public static var updateVersion:String = '';

	public static var ignoreCopy = false; //用于copystate，别删

	override public function create():Void
	{
		Paths.clearStoredMemory();

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		#if mobile
		try{
			#if android
			if (!FileSystem.exists(AndroidEnvironment.getExternalStorageDirectory() + '/.' + Application.current.meta.get('file')))
				FileSystem.createDirectory(AndroidEnvironment.getExternalStorageDirectory() + '/.' + Application.current.meta.get('file'));
			#end
			Sys.setCwd(SUtil.getStorageDirectory());
		}
		#end

		super.create();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());

		ClientPrefs.loadPrefs();

		Language.resetData();

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

		#if CHECK_FOR_UPDATES
		if (ClientPrefs.data.checkForUpdates)
		{
			var thread = Thread.create(() ->
        	{
				try
				{
					trace('checking for update');
					var http = new haxe.Http("https://raw.githubusercontent.com/NovaFlare-Engine-Concentration/FNF-NovaFlare-Engine/refs/heads/main/gitVersion.txt");
		
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
			});
		}
		#end

		#if mobile
		if (ClientPrefs.data.filesCheck)
		{
			if (!CopyState.checkExistingFiles())
			{
				FlxG.switchState(new CopyState());
				return;
			}
		}

		// 检查assets/version.txt存不存在且里面保存的上一个版本号与当前的版本号一不一致，如果不一致或不存在，强制启动copy。
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
		#end

		Highscore.load();

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

		if (FlxG.save.data != null && FlxG.save.data.fullscreen)
		{
			FlxG.fullscreen = FlxG.save.data.fullscreen;
			// trace('LOADED FULLSCREEN SETTING!!');
		}
		persistentUpdate = true;
		persistentDraw = true;

		Main.initScriptModules();
		#if HSCRIPT_ALLOWED
		scripts.stages.modules.ModuleHandler.init();
		scripts.stages.GlobalHandler.init();
		#end

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
			startCutscenesIn();
		}
		#end
	}
	
	function startCutscenesIn()
	{
		if (!ClientPrefs.data.skipTitleVideo)
			#if VIDEOS_ALLOWED
			changeState(); //startVideo('menuExtend/titleIntro');
			#else
			changeState();
			#end
		else
			changeState();
	}
	
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
			
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;
	
		#if ios
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end
	
		#if android
		if (FlxG.android.justReleased.BACK)
			pressedEnter = true;
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
			changeState();
			return;
		}
	
		super.update(elapsed);
	}
	
	#if VIDEOS_ALLOWED
	var video:FlxVideoSprite;
	
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
		if (skipVideo != null) skipVideo.visible = false;
		if (video != null) {
			video.stop();
			video.visible = false;
		}
		changeState();
		trace("end");
	}
	
	function showText()
	{
		add(skipVideo);
		FlxTween.tween(skipVideo, {alpha: 1}, 1, {ease: FlxEase.quadIn});
		FlxTween.tween(skipVideo, {alpha: 0}, 1, {ease: FlxEase.quadIn, startDelay: 4});
	}
	#end

	function changeState() {
		if (mustUpdate && !OutdatedState.leftState)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new OutdatedState());
		}
		else
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new TitleState());
		}
	}
}
