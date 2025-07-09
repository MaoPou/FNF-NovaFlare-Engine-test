package substates;

import objects.AudioDisplay.AudioCircleDisplay;
import objects.state.relaxState.ButtonSprite;
import objects.state.relaxState.TopButtons;
import objects.state.relaxState.SongInfoDisplay;
import objects.state.relaxState.ControlButtons;
//import objects.state.relaxState.windows.PlayListWindow; 未完工

import openfl.filters.BlurFilter;
import openfl.display.Shape;

import flixel.graphics.frames.FlxFilterFrames;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.FlxSprite;
//import flixel.text.FlxText;
//import flixel.sound.FlxSound;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxTimer;

import sys.thread.Thread;

typedef SongInfo = {
	name: String, 							// 歌曲名称
	sound: Array<FlxSoundAsset>, 			// 音频资源
	background: Array<FlxGraphicAsset>, 	// 背景图像
	record: Array<FlxGraphicAsset>, 		// 唱片图像
	backendVideo: FlxGraphicAsset, 			// 背景视频
	bpm: Float, 							// 每分钟节拍数
	writer: String 							// 作曲家
};

typedef SongLists = {
	name: String,
	list: Array<SongInfo>
};

class RelaxSubState extends MusicBeatSubstate
{
	public var SongsArray:SongLists = {
		name: "Unknown",
		list: []
	};
	private var currentSongIndex:Int = 0;
	private var pendingSongIndex:Int = -1;
	private var curSelected:Int = 0; // 当前选中的歌曲索引
	private var currentPlaylistIndex:Int = 0; // 当前选中的歌单索引

	var camBack:FlxCamera;
	var camPic:FlxCamera;
	var camText:FlxCamera;
	var camHUD:FlxCamera;
	var camOption:FlxCamera;
	
	// BPM缩放相关变量
	private var currentBPM:Float = 100;
	private var beatTime:Float = 0.6; // 默认一拍时间（秒）
	private var beatTimer:Float = 0;
	private var defaultZoom:Float = 1.0;
	private var zoomIntensity:Float = 0.05; // 缩放强度
	public var enableBpmZoom:Bool = true; // 是否启用BPM缩放

	var maskRadius:Float = 150;
	var circleMask:Shape;
	
	var backendPicture:FlxSprite;
	var audio:AudioCircleDisplay;
	var recordPicture:FlxSprite;
	
	var oldBackendPicture:FlxSprite;
	var oldRecordPicture:FlxSprite;
	var oldAudio:AudioCircleDisplay;

	var transitionTime:Float = 0.5;
	var isTransitioning:Bool = false;
	
	public var enableRecordRotation:Bool = true;
	public var bgBlur:Bool = false;
	
	// 使用SongInfoDisplay类替代原有的文本显示

	public var controlButtons:ControlButtons;
	public var topButtons:TopButtons;
	public var songInfoDisplay:SongInfoDisplay;

	public function new()
	{
		super();
        FlxG.state.persistentUpdate = false;
		FlxG.sound.music.stop();
	}

	/**
	 *	@param	songInfo	歌曲信息
	**/
	public function loadSongs(songInfo:SongInfo = null):Void {
		if (isTransitioning || songInfo == null) return;
		isTransitioning = true;
		
		// 预加载资源
		if (songInfo.background != null && songInfo.background.length > 0) {
			for (bg in songInfo.background) {
				Paths.image(bg);
			}
		}
		
		if (songInfo.record != null && songInfo.record.length > 0) {
			for (rec in songInfo.record) {
				Paths.image(rec);
			}
		}
		
		if (songInfo.sound != null && songInfo.sound.length > 0) {
			for (snd in songInfo.sound) {
				Paths.music(snd);
			}
		}
		
		// 停止当前音乐并播放新音乐
		FlxG.sound.music.stop();
		if (songInfo.sound != null && songInfo.sound.length > 0) {
			FlxG.sound.playMusic(songInfo.sound[0], 1);
			FlxG.sound.music.onComplete = () -> {
				// 歌曲结束时直接切换到下一首
				nextSong();
			};
			
			// 重置歌曲进度文本
			if (songInfoDisplay.songLengthText != null) {
				songInfoDisplay.songLengthText.text = "0:00 / 0:00";
				songInfoDisplay.songLengthText.screenCenter(X);
			}
		}
		
		// 保存旧元素以便淡出
		if (backendPicture != null) {
			oldBackendPicture = backendPicture;
			backendPicture = null;
		}
		
		if (recordPicture != null) {
			oldRecordPicture = recordPicture;
			recordPicture = null;
		}
		
		if (audio != null) {
			oldAudio = audio;
			audio = null;
		}
		
		// 创建新元素
		var backgroundImage:FlxGraphicAsset = (songInfo.background != null && songInfo.background.length > 0) ? songInfo.background[0] : null;
		var recordImage:FlxGraphicAsset = (songInfo.record != null && songInfo.record.length > 0) ? songInfo.record[0] : null;
		
		createNewElements(backgroundImage, recordImage);
		applyBlurFilter();
		
		// 更新歌曲信息显示
		updateSongInfoDisplay(songInfo);
		
		var allComplete:Bool = false;
		var newElementsComplete:Bool = false;
		var oldElementsComplete:Bool = false;
		
		function checkAllComplete() {
			if (newElementsComplete && oldElementsComplete && !allComplete) {
				allComplete = true;
				isTransitioning = false;
				
				// 检查是否有待播放的歌曲
				if (pendingSongIndex != -1) {
					var indexToLoad = pendingSongIndex;
					pendingSongIndex = -1; // 重置待播放索引
					
					// 使用短延迟确保UI更新完成
					new FlxTimer().start(0.1, function(_) {
						if (indexToLoad >= 0 && indexToLoad < SongsArray.list.length) {
							currentSongIndex = indexToLoad;
							loadSongs(SongsArray.list[currentSongIndex]);
						}
					});
				}
			}
		}
		
		fadeInNewElements(() -> {
			newElementsComplete = true;
			checkAllComplete();
		});
		
		fadeOutOldElements(() -> {
			oldElementsComplete = true;
			checkAllComplete();
		});
	}

	private function fadeOutOldElements(onComplete:Void->Void):Void {
		var tweenCount = 0;
		var totalTweens = 0;
		
		if (oldBackendPicture != null) totalTweens++;
		if (oldRecordPicture != null) totalTweens++;
		if (oldAudio != null) totalTweens++;
		
		if (totalTweens == 0) {
			onComplete();
			return;
		}
		
		function checkComplete() {
			tweenCount++;
			if (tweenCount >= totalTweens) {
				onComplete();
			}
		}
		
		if (oldBackendPicture != null) {
			FlxTween.tween(oldBackendPicture, {alpha: 0}, transitionTime, {
				ease: FlxEase.quadIn,
				onComplete: function(twn:FlxTween) {
					remove(oldBackendPicture);
					oldBackendPicture.destroy();
					oldBackendPicture.kill();
					oldBackendPicture = null;
					checkComplete();
				}
			});
		}
		
		if (oldRecordPicture != null) {
			FlxTween.tween(oldRecordPicture, {alpha: 0, angle: 180}, transitionTime, {
				ease: FlxEase.quadIn,
				onComplete: function(twn:FlxTween) {
					remove(oldRecordPicture);
					oldRecordPicture.destroy();
					oldRecordPicture.kill();
					oldRecordPicture = null;
					checkComplete();
				}
			});
		}
		
		if (oldAudio != null) {
			FlxTween.tween(oldAudio, {alpha: 0}, transitionTime, {
				ease: FlxEase.quadIn,
				onComplete: function(twn:FlxTween) {
					remove(oldAudio);
					oldAudio.destroy();
					oldAudio = null;
					checkComplete();
				}
			});
		}
	}
	
	private function createNewElements(background:FlxGraphicAsset, recordImage:FlxGraphicAsset):Void {
		if (background != null) {
			backendPicture = new FlxSprite().loadGraphic(background);
			backendPicture.antialiasing = ClientPrefs.data.antialiasing;
			backendPicture.scale.set(1.1,1.1);
			backendPicture.updateHitbox();
			backendPicture.screenCenter();
			backendPicture.cameras = [camBack];
			backendPicture.alpha = 0;
			add(backendPicture);
		}

		audio = new AudioCircleDisplay(FlxG.sound.music, FlxG.width / 2, FlxG.height / 2, 
									  500, 100, 46, 4, FlxColor.WHITE, 150);
		audio.alpha = 0;
		audio.cameras = [camBack];
		add(audio);

		var actualRecordImage:FlxGraphicAsset = recordImage;
		if (actualRecordImage == null && background != null) {
			actualRecordImage = background;
		}
		
		if (actualRecordImage != null) {
			recordPicture = new FlxSprite().loadGraphic(actualRecordImage);
			recordPicture.antialiasing = ClientPrefs.data.antialiasing;
			updatePictureScale();
			recordPicture.cameras = [camPic];
			recordPicture.alpha = 0;
			add(recordPicture);
		}
	}
	
	/**
	 * 更新歌曲信息显示
	 * @param songInfo 歌曲信息
	 */
	private function updateSongInfoDisplay(songInfo:SongInfo):Void {
		if (songInfo == null) return;
		
		currentBPM = songInfo.bpm > 0 ? songInfo.bpm : 100;
		beatTime = 60 / currentBPM;
		beatTimer = 0;
		
		songInfoDisplay.updateSongInfo(
			songInfo, 
			controlButtons.MiddleButton.x, 
			controlButtons.MiddleButton.y, 
			controlButtons.MiddleButton.width, 
			controlButtons.MiddleButton.height
		);
	}
		
	private function applyBlurFilter():Void {
		if (backendPicture != null && bgBlur) {
			var blurFilter:BlurFilter = new BlurFilter(10, 10, 1);
			var filterFrames = FlxFilterFrames.fromFrames(backendPicture.frames, 
														Std.int(backendPicture.width), 
														Std.int(backendPicture.height), 
														[blurFilter]);
			filterFrames.applyToSprite(backendPicture, false, true);
		}
	}
	
	private function fadeInNewElements(onComplete:Void->Void):Void {
		var tweenCount = 0;
		var totalTweens = 0;
		
		if (backendPicture != null) totalTweens++;
		if (recordPicture != null) totalTweens++;
		if (audio != null) totalTweens++;
		
		if (totalTweens == 0) {
			onComplete();
			return;
		}
		
		function checkComplete() {
			tweenCount++;
			if (tweenCount >= totalTweens) {
				onComplete();
			}
		}
		
		if (backendPicture != null) {
			FlxTween.tween(backendPicture, {alpha: 1}, transitionTime, {
				ease: FlxEase.quadOut,
				onComplete: function(_) checkComplete()
			});
		}
		
		if (recordPicture != null) {
			FlxTween.tween(recordPicture, {alpha: 1, angle: 360}, transitionTime, {
				ease: FlxEase.quadOut,
				onComplete: function(_) checkComplete()
			});
		}
		
		if (audio != null) {
			FlxTween.tween(audio, {alpha: 0.7}, transitionTime, {
				ease: FlxEase.quadOut,
				onComplete: function(_) checkComplete()
			});
		}
	}

	var topTrapezoid:FlxSprite;
	var hideTimer:Float = 0; // 隐藏计时器
	var waitingToHide:Bool = false; // 是否正在等待隐藏
	var topTrapezoidTween:FlxTween = null; // 用于存储当前的tween动画
	var isTweening:Bool = false; // 是否正在进行tween动画

	private function drawTrapezoid(topWidth:Float, height:Float):Void {
		var bottomWidth = topWidth * 0.8;
		var sideSlope = (topWidth - bottomWidth) / 2;
		
		topTrapezoid.makeGraphic(Std.int(topWidth), Std.int(height), FlxColor.TRANSPARENT, true);
		
		var vertices = [
			new FlxPoint(0, 0),
			new FlxPoint(topWidth, 0),
			new FlxPoint(topWidth - sideSlope, height), 
			new FlxPoint(sideSlope, height)
		];
		FlxSpriteUtil.drawPolygon(topTrapezoid, vertices, 0xFF24232C);
	}

	private function createTopButtons():Void {
		topButtons = new TopButtons();
		
		// 设置相机
		for (member in topButtons.members) {
			if (member != null) {
				member.cameras = [camOption];
			}
		}
		
		// 将TopButtons添加到显示列表
		add(topButtons);
	}

	override function create()
	{
		camBack = new FlxCamera();
		camPic = new FlxCamera();
		camText = new FlxCamera();
		camHUD = new FlxCamera();

		camHUD.bgColor.alpha = 0;
		camPic.bgColor.alpha = 0;
		camText.bgColor.alpha = 0;
		camBack.bgColor.alpha = 0;

		camOption = new FlxCamera();
		camOption.bgColor.alpha = 0;
		camOption.y = 0;

		FlxG.cameras.add(camBack, false);
		FlxG.cameras.add(camPic, false);
		FlxG.cameras.add(camText, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOption, false);

		topTrapezoid = new FlxSprite();
		drawTrapezoid(FlxG.width * 0.7, 40);
		topTrapezoid.y = 0; // 初始位置为可见
		topTrapezoid.x = (FlxG.width - topTrapezoid.width) / 2;
		topTrapezoid.scrollFactor.set();
		topTrapezoid.cameras = [camOption];
		add(topTrapezoid);
		camOption.y = -topTrapezoid.height; // 初始隐藏

		createTopButtons();
		
		defaultZoom = 1.0;
		camPic.zoom = defaultZoom;

		super.create();

		createButtons();

		// 创建歌曲信息显示
		songInfoDisplay = new SongInfoDisplay();
		add(songInfoDisplay.songNameText);
		add(songInfoDisplay.writerText);
		add(songInfoDisplay.songLengthText);
		
		songInfoDisplay.songNameText.cameras = [camText];
		songInfoDisplay.writerText.cameras = [camText];
		songInfoDisplay.songLengthText.cameras = [camHUD];


		circleMask = new Shape();
		updateMask();

		initSongsList();
		
		if (SongsArray.list.length > 0) {
			currentSongIndex = 0;
			pendingSongIndex = -1;
			loadSongs(SongsArray.list[0]);
		}
	}

	function createButtons(){
		controlButtons = new ControlButtons();
		
		add(controlButtons.LeftButton);
		add(controlButtons.MiddleButton);
		add(controlButtons.RightButton);
		
		controlButtons.LeftButton.cameras = [camHUD];
		controlButtons.MiddleButton.cameras = [camHUD];
		controlButtons.RightButton.cameras = [camHUD];
		
		controlButtons.LeftButton.pixelPerfectPosition = true;
		controlButtons.RightButton.pixelPerfectPosition = true;
		controlButtons.MiddleButton.pixelPerfectPosition = true;
	}
	
	private function initSongsList():Void {
		SongsArray = {
			name: "example",
			list: [
				{
					name: "Aimai Attitude",
					sound: ["assets/shared/Playlists/example/songs/Aimai-Attitude.ogg"],
					background: ["assets/shared/Playlists/example/art/Aimai-Attitude.png"],
					record: null,
					backendVideo: null,
					bpm: 200,
					writer: "rejection"
				}
			]
		};
	}
	/**
	 * 切换到下一首歌曲
	 */
	private function nextSong():Void {
		if (SongsArray.list.length <= 1) return;
		
		var nextIndex = (currentSongIndex + 1) % SongsArray.list.length;
		
		if (isTransitioning) {
			pendingSongIndex = nextIndex;
			return;
		}
		
		currentSongIndex = nextIndex;
		loadSongs(SongsArray.list[currentSongIndex]);
	}
	
	/**
	 * 切换到上一首歌曲
	 */
	private function prevSong():Void {
		if (SongsArray.list.length <= 1) return;
		
		var prevIndex = (currentSongIndex - 1 + SongsArray.list.length) % SongsArray.list.length;
		
		if (isTransitioning) {
			pendingSongIndex = prevIndex;
			return;
		}
		
		currentSongIndex = prevIndex;
		loadSongs(SongsArray.list[currentSongIndex]);
	}
	
	/**
	 * 根据当前选中的索引更改歌曲
	 */
	private function changeSelection():Void {
		if (curSelected < 0 || curSelected >= SongsArray.list.length) return;
		
		if (isTransitioning) {
			pendingSongIndex = curSelected;
			return;
		}
		
		currentSongIndex = curSelected;
		loadSongs(SongsArray.list[currentSongIndex]);
	}

	private function updateMask():Void
	{
		if (circleMask == null) {
			circleMask = new Shape();
		}
		
		var maxRadius:Float = Math.min(FlxG.stage.stageWidth, FlxG.stage.stageHeight) / 2;
		maskRadius = Math.min(maskRadius, maxRadius);
		
		circleMask.graphics.clear();
		circleMask.graphics.beginFill(0xFFFFFF);
		
		var scaledRadius:Float = Math.min(
			maskRadius * (FlxG.stage.stageHeight / FlxG.height), 
			maskRadius * (FlxG.stage.stageWidth / FlxG.width)
		);
		
		circleMask.graphics.drawCircle(
			FlxG.stage.stageWidth / 2, 
			FlxG.stage.stageHeight / 2, 
			scaledRadius
		);
		circleMask.graphics.endFill();

		camPic.flashSprite.mask = circleMask;
		camText.flashSprite.mask = circleMask;
	}

	private function updatePictureScale():Void
	{
		if (recordPicture == null) return;
		
		var scaleX:Float = (maskRadius * 2) / recordPicture.width;
		var scaleY:Float = (maskRadius * 2) / recordPicture.height;
		var scale:Float = Math.max(scaleX, scaleY);

		recordPicture.scale.set(scale, scale);
		recordPicture.updateHitbox();
		recordPicture.screenCenter();
	}

	override function destroy()
	{
		// 取消所有活动的tween
		if (songInfoDisplay.songNameTween != null && songInfoDisplay.songNameTween.active) {
			songInfoDisplay.songNameTween.cancel();
			songInfoDisplay.songNameTween = null;
		}
		
		if (topTrapezoidTween != null && topTrapezoidTween.active) {
			topTrapezoidTween.cancel();
			topTrapezoidTween = null;
		}
		
		// 销毁图片和音频资源
		if (backendPicture != null) {
			backendPicture.destroy();
			backendPicture = null;
		}
		
		if (recordPicture != null) {
			recordPicture.destroy();
			recordPicture = null;
		}
		
		if (audio != null) {
			audio.destroy();
			audio = null;
		}
		
		// 销毁旧的过渡资源
		if (oldBackendPicture != null) {
			oldBackendPicture.destroy();
			oldBackendPicture = null;
		}
		
		if (oldRecordPicture != null) {
			oldRecordPicture.destroy();
			oldRecordPicture = null;
		}
		
		if (oldAudio != null) {
			oldAudio.destroy();
			oldAudio = null;
		}
		
		// 销毁UI组件
		if (controlButtons != null) {
			controlButtons.destroy();
			controlButtons = null;
		}
		
		if (topButtons != null) {
			topButtons.destroy();
			topButtons = null;
		}
		
		if (songInfoDisplay != null) {
			songInfoDisplay.destroy();
			songInfoDisplay = null;
		}
		
		// 销毁其他资源
		if (circleMask != null) {
			circleMask = null;
		}
		
		if (topTrapezoid != null) {
			topTrapezoid.destroy();
			topTrapezoid = null;
		}

		// 重置状态
		currentSongIndex = 0;
		pendingSongIndex = -1;
		SongsArray = {
			name: "Unknown",
			list: []
		};
		
		super.destroy();
	}

	// 处理顶部梯形的显示和隐藏
	private function handleTopTrapezoidVisibility(nearTop:Bool, elapsed:Float):Void {
		// 如果鼠标靠近顶部
		if (nearTop) {
			// 如果正在等待隐藏，取消等待
			if (waitingToHide) {
				waitingToHide = false;
				hideTimer = 0;
			}
			
			if (camOption.y < 0 && !isTweening) {
				if (topTrapezoidTween != null && topTrapezoidTween.active) {
					topTrapezoidTween.cancel();
				}
				
				isTweening = true;
				topTrapezoidTween = FlxTween.tween(camOption, {y: 0}, 0.3, {
					ease: FlxEase.quadOut,
					onComplete: function(_) {
						isTweening = false;
					}
				});
			}
		} 
		else {
			if (!waitingToHide && !isTweening) {
				waitingToHide = true;
				hideTimer = 0;
			}
			
			if (waitingToHide) {
				if(!clickList && !clickOption) hideTimer += elapsed;
				if (hideTimer >= 3.0 && !isTweening) {
					waitingToHide = false;

					if (topTrapezoidTween != null && topTrapezoidTween.active) {
						topTrapezoidTween.cancel();
					}
					
					isTweening = true;
					topTrapezoidTween = FlxTween.tween(camOption, {y: -topTrapezoid.height}, 0.3, {
						ease: FlxEase.quadIn,
						onComplete: function(_) {
							isTweening = false;
						}
					});
				}
			}
		}
	}

	var bgFollowSmooth:Float = 0.2;

	var clickList:Bool = false;
	var clickOption:Bool = false;
	var clickLock:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		updateMask();
		
		if (backendPicture != null && !isTransitioning) {
			var mouseX = FlxG.mouse.getScreenPosition(camHUD).x;
			var mouseY = FlxG.mouse.getScreenPosition(camHUD).y;
			var centerX = FlxG.width / 2;
			var centerY = FlxG.height / 2;
			
			var targetOffsetX = (mouseX - centerX) * 0.01;
			var targetOffsetY = (mouseY - centerY) * 0.01;
			
			var currentOffsetX = backendPicture.x - (centerX - backendPicture.width / 2);
			var currentOffsetY = backendPicture.y - (centerY - backendPicture.height / 2);
			
			var smoothX = FlxMath.lerp(currentOffsetX, targetOffsetX, bgFollowSmooth);
			var smoothY = FlxMath.lerp(currentOffsetY, targetOffsetY, bgFollowSmooth);
			
			backendPicture.x = centerX - backendPicture.width / 2 + smoothX;
			backendPicture.y = centerY - backendPicture.height / 2 + smoothY;
		}

		var mousePos = FlxG.mouse.getScreenPosition(camHUD);
		var nearTop = mousePos.y < 50;
		handleTopTrapezoidVisibility(nearTop, elapsed);

		songInfoDisplay.writerText.y = songInfoDisplay.songNameText.y + songInfoDisplay.songNameText.height + 10;
		
		// 更新歌曲时长文本位置
		songInfoDisplay.updateSongLengthPosition(
			controlButtons.MiddleButton.x,
			controlButtons.MiddleButton.y,
			controlButtons.MiddleButton.width,
			controlButtons.MiddleButton.height
		);
		
		if (enableBpmZoom && FlxG.sound.music != null && FlxG.sound.music.playing) {
			beatTimer += elapsed;
			
			if (beatTimer >= beatTime) {
				beatTimer -= beatTime;
				onBPMBeat();
			}
		}
		
		if (FlxG.sound.music != null) {
			var currentTime:Float = FlxG.sound.music.time / 1000;
			var totalTime:Float = FlxG.sound.music.length / 1000;
			
			// 使用SongInfoDisplay类更新歌曲长度
			songInfoDisplay.updateSongLength(currentTime, totalTime);
			
			// 更新歌曲长度文本位置
			songInfoDisplay.updateSongLengthPosition(
				controlButtons.MiddleButton.x,
				controlButtons.MiddleButton.y,
				controlButtons.MiddleButton.width,
				controlButtons.MiddleButton.height
			);
		}

		if (FlxG.keys.justPressed.LEFT) {
			prevSong();
		}
		else if (FlxG.keys.justPressed.RIGHT) {
			nextSong();
		}
		
		var mousePos = FlxG.mouse.getScreenPosition(camHUD);
		var isOverLeft = controlButtons.isMouseOverLeftButton(mousePos);
		var isOverMiddle = controlButtons.isMouseOverMiddleButton(mousePos);
		var isOverRight = controlButtons.isMouseOverRightButton(mousePos);

		var isOverList = topButtons.isMouseOverListButton(mousePos);
		var isOverSetting = topButtons.isMouseOverSettingButton(mousePos);
		var isOverRock = topButtons.isMouseOverLockButton(mousePos);
		
		controlButtons.setButtonAlphas(isOverLeft, isOverMiddle, isOverRight);
		topButtons.setButtonAlphas(isOverList, isOverSetting, isOverRock, clickList, clickOption, clickLock);
		
		if (FlxG.mouse.justPressed) {
			if (isOverLeft) {
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
				controlButtons.animateLeftButtonPress(0.1);
				prevSong();
			}
			else if (isOverMiddle && FlxG.sound.music != null) {
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
				
				if (FlxG.sound.music.playing) {
					FlxG.sound.music.pause();
				} else {
					FlxG.sound.music.play();
				}
			}
			else if (isOverRight) {
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
				controlButtons.animateRightButtonPress(0.1);
				nextSong();
			}
			else if (isOverList) {
				clickList = !clickList;
				if (clickList && clickOption)
					clickOption = !clickList;
			}
			else if (isOverSetting) {
				clickOption = !clickOption;
				if (clickList && clickOption)
					clickList = !clickOption;
				trace('setting');
			}
			else if (isOverRock) {
				clickLock = !clickLock;
				trace('lock');
			}
		}
		
		if (recordPicture != null && !isTransitioning && enableRecordRotation)
		{
			recordPicture.angle += elapsed * 20;
			if (recordPicture.angle >= 360) recordPicture.angle -= 360;
		}

		if (FlxG.keys.justPressed.A)
		{
			if (!isTransitioning) {
				currentSongIndex = 0;
				loadSongs(SongsArray.list[0]);
			} else {
				pendingSongIndex = 0;
			}
		}
		else if (FlxG.keys.justPressed.S)
		{
			if (!isTransitioning && SongsArray.list.length > 1) {
				currentSongIndex = 1;
				loadSongs(SongsArray.list[1]);
			} else if (SongsArray.list.length > 1) {
				pendingSongIndex = 1;
			}
		}
		else if (FlxG.keys.justPressed.D)
		{
			if (!isTransitioning && SongsArray.list.length > 2) {
				currentSongIndex = 2;
				loadSongs(SongsArray.list[2]);
			} else if (SongsArray.list.length > 2) {
				pendingSongIndex = 2;
			}
		}

		if (FlxG.keys.justPressed.B)
		{
			enableBpmZoom = !enableBpmZoom;
			if (!enableBpmZoom) {
				camPic.zoom = defaultZoom;
			}
		}
		
		if (FlxG.keys.justPressed.ESCAPE || (virtualPad != null && virtualPad.buttonB.justPressed))
		{
			FlxG.sound.music.play();
			close();
		}
	}

	var beatTimess:Int = 0;
	var helpBool:Bool = false;

	function onBPMBeat(){
		var targetZoom = defaultZoom + zoomIntensity;
		camPic.zoom = targetZoom;

		// 使用ControlButtons类处理按钮动画
		controlButtons.handleBeatAnimation(beatTime);
		
		FlxTween.tween(camPic, {zoom: defaultZoom}, beatTime * 0.5, {
			ease: FlxEase.quadOut
		});
		
		beatTimess++;
		helpBool = !helpBool;
		
		// 使用TopButtons类处理顶部按钮动画
		topButtons.handleBeatAnimation(helpBool, beatTime);
		
		// 处理水印动画
		if(helpBool){
			Main.watermark.scaleX = ClientPrefs.data.WatermarkScale + 0.1;
			Main.watermark.scaleY = ClientPrefs.data.WatermarkScale - 0.1;
		}else{
			Main.watermark.scaleX = ClientPrefs.data.WatermarkScale - 0.1;
			Main.watermark.scaleY = ClientPrefs.data.WatermarkScale + 0.1;
		}
		
		FlxTween.tween(Main.watermark, {scaleX: ClientPrefs.data.WatermarkScale, scaleY: ClientPrefs.data.WatermarkScale}, beatTime * 0.5, {
			ease: FlxEase.quadOut
		});

		if(beatTimess == 4)
		{
			beatTimess = 0;
			fourTimeBeat();
		}
	}
	function fourTimeBeat() {
		// 使用ControlButtons类处理四拍动画
		controlButtons.handleFourTimeBeatAnimation(beatTime);
		
		// 处理歌曲长度文本动画
		var currentY = songInfoDisplay.songLengthText.y;
		songInfoDisplay.songLengthText.y += 5;
		
		FlxTween.tween(songInfoDisplay.songLengthText, {y: currentY}, beatTime * 0.5, {
			ease: FlxEase.quadOut
		});
	}
}
