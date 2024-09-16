package states;

import flixel.util.FlxSpriteUtil;
import flixel.addons.transition.FlxTransitionableState;

import haxe.Json;
import haxe.ds.ArraySort;

import sys.thread.Thread;
import sys.thread.Mutex;

import openfl.filters.BlurFilter;
import openfl.filters.GlowFilter;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import backend.DiffCalc;

import objects.HealthIcon;
import objects.shape.ShapeEX;
import objects.shape.FreeplayShape;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import states.MainMenuState;
import states.PlayState;
import states.LoadingState;
import states.editors.ChartingState;
import options.OptionsState;

class FreeplayState extends MusicBeatState
{
	static public var instance:FreeplayState;

	static public var curSelected:Int = 0;
	private static var position:Float = 360 - 45;
	private static var lerpPosition:Float = 360 - 45;
	private static var diffPosition:Float = 0;
	private static var diffLerpPosition:Float = 0;
	static public var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	public var grpSongs:Array<SongRect> = [];
	public var saveGrpSongs:Array<SongRect> = [];
	public var songs:Array<SongMetadata> = [];
	public var saveSongs:Array<SongMetadata> = [];
	public var sortSongs:Array<SongMetadata> = [];

	var camGame:FlxCamera;
	var camAudio:FlxCamera;
	var camUI:FlxCamera;
	var camHS:FlxCamera;

	var magenta:FlxSprite;
	var intendedColor:Int;

	var smallMag:SpecRect;

	var extraAudio:ExtraTopRect;
	var extraHS:ExtraTopRect;

	var instDis:ExtraAudio;
	var voiceDis:ExtraAudio;
	var voiceLine:MusicLine;

	var infoRating:InfoText;
	var infoNote:InfoText;
	var infoSpeed:InfoText;

	var timeSave:FlxText;
	var accSave:FlxText;
	var scoreSave:FlxText;
	var result:ResultRect;

	var optionEvent:EventRect;
	var modsEvent:EventRect;
	var randomEvent:EventRect;
	var resetEvent:EventRect;
	var editorEvent:EventRect;
	var ChangersEvent:EventRect;
	var skipEvent:EventRect;
	var eventArray:Array<EventRect> = [];

	var playButton:PlayRect;
	var backButton:BackRect;

	var disLine:Rect;

	public static var vocals:FlxSound = null;
	public static var opponentVocals:FlxSound = null;

	override function create()
	{
		super.create();

		instance = this;

		#if !mobile
		FlxG.mouse.visible = true;
		#end

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = initPsychCamera();

		for (i in 0...WeekData.weeksList.length)
		{
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}

		sortSongs = songs.copy();
		saveSongs = songs.copy();

		ArraySort.sort(sortSongs, function(a:SongMetadata, b:SongMetadata) {
			return Reflect.compare(a.songName.toLowerCase(), b.songName.toLowerCase());
		});

		Mods.loadTopMod();
		
		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scale.x = FlxG.width * 1.05 / magenta.width;
		magenta.scale.y = FlxG.height * 1.05 / magenta.height;
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		add(magenta);

		var specBG:SpecRectBG = new SpecRectBG(0, 0);
		specBG.alpha = 0.3;
		add(specBG);

		for (i in 0...songs.length)
		{
			Mods.currentModDirectory = songs[i].folder;
			
			var songRect:SongRect = new SongRect(660, 50 + i * 100, songs[i].songName, songs[i].songCharacter, songs[i].color);
			add(songRect);
			songRect.member = i;
			grpSongs.push(songRect);

			if (i == curSelected) songRect.lerpPosX = songRect.posX;
		}

		saveGrpSongs = grpSongs.copy();
			
		WeekData.setDirectoryFromWeek();

		var upBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, Std.int(FlxG.height * 0.25), FlxColor.BLACK);
		upBG.alpha = 0.7;
		add(upBG);

		var searchMenu:SearchButton = new SearchButton(640, 20, FlxG.width - 640 - 20, 80);
		add(searchMenu);

		var order:OrderRect = new OrderRect(searchMenu.x, searchMenu.y + searchMenu.height + 15, searchMenu.width, 50, useSort);
		add(order);

		smallMag = new SpecRect(0, 0, 'menuDesat');
		add(smallMag);

		var infoBG:Rect = new Rect(12, FlxG.height * 0.42, FlxG.width * 0.45 - 12, FlxG.height * 0.15, 20, 20, FlxColor.BLACK, 0.5);
		add(infoBG);

		infoSpeed = new InfoText(infoBG.x + 15, infoBG.y + 7, "speed", 5);
		add(infoSpeed);

		infoNote = new InfoText(infoBG.x + 15, infoBG.y + 38, "note count", 10);
		add(infoNote);

		infoRating = new InfoText(infoBG.x + 15, infoBG.y + 70, "rating", 20);
		add(infoRating);

		var extraBG:Rect = new Rect(12, FlxG.height * 0.585, FlxG.width * 0.45 - 12, FlxG.height * 0.3, 20, 20, FlxColor.BLACK, 0.5);
		add(extraBG);

		extraAudio = new ExtraTopRect(extraBG.x, extraBG.y, extraBG.width / 2, 50, 11, true, 'Audio DisPlay', 0, FlxColor.BLACK, extraChange);
		add(extraAudio);

		extraHS = new ExtraTopRect(extraBG.x + extraAudio.width, extraBG.y, extraBG.width / 2, 50, 11, false, 'History Score', 0, FlxColor.BLACK, extraChange);
		add(extraHS);

		camAudio = new FlxCamera(Std.int(extraAudio.x), Std.int(extraAudio.y + extraAudio.height), Std.int(extraBG.width), Std.int(extraBG.height - extraAudio.height));
		camAudio.bgColor = 0x00;
		camHS = new FlxCamera(Std.int(extraAudio.x), Std.int(extraAudio.y + extraAudio.height), Std.int(extraBG.width), Std.int(extraBG.height - extraAudio.height));
		camHS.bgColor = 0x00;
		camHS.visible = false;
		FlxG.cameras.add(camAudio, false);
		FlxG.cameras.add(camHS, false);

		voiceDis = new ExtraAudio(10, 10, Std.int(camAudio.width / 2 - 20), 90, FlxG.sound.music);
		add(voiceDis);
		voiceDis.camera = camAudio;
		voiceDis.alpha = 0.7;

		instDis = new ExtraAudio(Std.int(camAudio.width) - 10 - Std.int(camAudio.width / 2 - 20) + 1, 10, Std.int(camAudio.width / 2 - 20), 90, FlxG.sound.music);
		add(instDis);
		instDis.camera = camAudio;
		instDis.alpha = 0.7;

		voiceLine = new MusicLine(Std.int(extraAudio.x) + 10, Std.int(extraAudio.y + extraAudio.height) + 110, 545);
		add(voiceLine);

		timeSave = new FlxText(10, 0, 0, '', 15);
		timeSave.font = Paths.font('montserrat.ttf'); 	
        timeSave.antialiasing = ClientPrefs.data.antialiasing;	
		timeSave.camera = camHS;
		add(timeSave);

		accSave = new FlxText(10, 20, 0, '', 15);
		accSave.font = Paths.font('montserrat.ttf'); 	
        accSave.antialiasing = ClientPrefs.data.antialiasing;	
		accSave.camera = camHS;
		add(accSave);

		scoreSave = new FlxText(10 + camHS.width * 0.4, 20, 0, '', 15);
		scoreSave.font = Paths.font('montserrat.ttf'); 	
        scoreSave.antialiasing = ClientPrefs.data.antialiasing;	
		scoreSave.camera = camHS;
		add(scoreSave);
		
		result = new ResultRect(10, camHS.y + 10, camHS.width - 20, 110);
		result.updateRect();
		result.x = 20;
		result.y = 515;
		result.visible = false;
		add(result);

		var bottomBG:FlxSprite = new FlxSprite(0, FlxG.height * 0.9).makeGraphic(FlxG.width, Std.int(FlxG.height * 0.1));
		bottomBG.color = FlxColor.BLACK;
		bottomBG.alpha = 0.6;
		add(bottomBG);

		optionEvent = new EventRect(215, bottomBG.y, "option", 0x63d6ff, specEvent);
		add(optionEvent);
		modsEvent = new EventRect(optionEvent.x + optionEvent.width - 1, bottomBG.y, "mods", 0xd1fc52, specEvent);
		add(modsEvent);
		ChangersEvent = new EventRect(modsEvent.x + modsEvent.width - 1, bottomBG.y, "changers", 0xff354e, specEvent);
		add(ChangersEvent);
		editorEvent = new EventRect(ChangersEvent.x + ChangersEvent.width - 1, bottomBG.y, "editor", 0xff617e, specEvent);
		add(editorEvent);
		resetEvent = new EventRect(editorEvent.x + editorEvent.width - 1, bottomBG.y, "reset", 0xfd6dff, specEvent);
		add(resetEvent);
		randomEvent = new EventRect(resetEvent.x + resetEvent.width - 1, bottomBG.y, "random", 0x6dff6d, specEvent);
		add(randomEvent);
		skipEvent = new EventRect(randomEvent.x + randomEvent.width - 1, bottomBG.y, "skip", 0x61edfa, specEvent);
		add(skipEvent);
		eventArray.push(optionEvent);
		eventArray.push(modsEvent);
		eventArray.push(ChangersEvent);
		eventArray.push(editorEvent);
		eventArray.push(resetEvent);
		eventArray.push(randomEvent);
		eventArray.push(skipEvent);

		disLine = new Rect(0, bottomBG.y - 4, FlxG.width, 4, 0, 0, FlxColor.WHITE, 0);
		add(disLine);

		playButton = new PlayRect(FlxG.width, bottomBG.y, 200, bottomBG.height, "PLAY", 0xFC4EFF, startGame);
		add(playButton);

		backButton = new BackRect(0, bottomBG.y, 200, bottomBG.height, "BACK", 0x41E9FF, backMenu);
		add(backButton);

		changeSelection(0, false, true);
		songsRectPosUpdate(true);
	}

	public var ignoreCheck:Bool = false; //最高级控制更新
	var isPressed:Bool = false; //修复出判定释放
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (ignoreCheck) return;

		if (vocals != null && (Math.abs(vocals.time - FlxG.sound.music.time) > 5)) {
			vocals.time = FlxG.sound.music.time;
		}

		var reduceAlpha:Bool = true;
		for (i in 0...eventArray.length){
			if (FlxG.mouse.overlaps(eventArray[i]))
			{
				eventMember = i;
				disLine.color = eventArray[i].background.color;
				disLine.alpha += elapsed * 8;
				reduceAlpha = false;
			}
		}
		if (reduceAlpha) disLine.alpha -= elapsed * 8;

		mouseMove();

		if (FlxG.mouse.x >= 660 && FlxG.mouse.x <= FlxG.width && FlxG.mouse.y >= FlxG.height * 0.25 && FlxG.mouse.y <= FlxG.height * 0.9)
		{
			position += FlxG.mouse.wheel * 180;
			if (FlxG.mouse.pressed) 
			{
				isPressed = true;
				position += moveData;
				lerpPosition = position;
				songsRectPosUpdate(true);
			}
			if (FlxG.mouse.justReleased)
			{
				position += avgSpeed * 1.5 * (0.0166 / elapsed) * Math.pow(1.1, Math.abs(avgSpeed * 0.8));
				if (Math.abs(avgSpeed * (0.0166 / elapsed)) < 1) {
					for (i in 0...grpSongs.length)
					{
						if (FlxG.mouse.overlaps(grpSongs[i]) && !grpSongs[i].ignoreCheck)
						{
							if (curSelected != i)
							{
								curSelected = i;
								changeSelection();
							}
						}
					}
				}
				updateInfo(); //难度数据更新
			}
		} else {
			if (FlxG.mouse.pressed && isPressed == true) 
			{
				isPressed = false;
				position += avgSpeed * 1.5 * (0.0166 / elapsed) * Math.pow(1.1, Math.abs(avgSpeed * 0.8));
			}
		}

		if (position > 360 - 45) position = FlxMath.lerp(360 - 45, position, Math.exp(-elapsed * 15));
		if (position < 360 - 45 - 100 * (songs.length - 1) - Difficulty.list.length * 70) position = FlxMath.lerp(360 - 45 - 100 * (songs.length - 1) - Difficulty.list.length * 70, position, Math.exp(-elapsed * 15));

		if (Math.abs(lerpPosition - position) < 0.1) lerpPosition = position;
		else lerpPosition = FlxMath.lerp(position, lerpPosition, Math.exp(-elapsed * 15));
		
		songsRectPosUpdate(false);
	}

	override function closeSubState()
	{				
		super.closeSubState();
		
		new FlxTimer().start(0.1, function(tmr:FlxTimer){
			ignoreCheck = false;
		});
	}

	var pressCheck:Bool = false;
	function backMenu() {
		Mods.loadTopMod();
		if (!pressCheck){
			pressCheck = true;
			FlxG.sound.music.stop();
			destroyFreeplayVocals();
			FlxG.sound.music.volume = 0;
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);

			MusicBeatState.switchState(new MainMenuState());
		}
	}

	function startGame() {
		if (Math.abs(lerpPosition - position) > 1) return;
		if (!musicMutex.tryAcquire()) return;

		try
		{
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
		}
		catch(e:Dynamic)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));

			return;
		}
		LoadingState.prepareToSong();
		if (ClientPrefs.data.loadingScreen) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		} else {
			destroyFreeplayVocals();
		}
		LoadingState.loadAndSwitchState(new PlayState());
		FlxG.mouse.visible = false;
	}

	function extraChange() {
		if (FlxG.mouse.overlaps(extraHS))
		{
			camAudio.visible = false;
			voiceLine.visible = false;
			camHS.visible = true;
			result.visible = true;
		} else {
			camAudio.visible = true;
			voiceLine.visible = true;
			camHS.visible = false;
			result.visible = false;
		}
	}

	var eventMember:Int = -1;
	var eventPressCheck:Bool = false;
	function specEvent() {
		switch (eventMember)
		{
			case 0:
				if (!eventPressCheck)
				{
					if (Math.abs(lerpPosition - position) > 1) return;
					if (!musicMutex.tryAcquire()) return;
					eventPressCheck = true;
					destroyFreeplayVocals();
					FlxG.sound.music.stop();

					FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);

					OptionsState.stateType = 1;
					LoadingState.loadAndSwitchState(new OptionsState());
				}
			case 1:
				if (Math.abs(lerpPosition - position) > 1) return;
				if (!musicMutex.tryAcquire()) return;
				ignoreCheck = true;
				destroyFreeplayVocals();
				FlxG.sound.music.stop();

				FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);
				
				ModsMenuState.isFreePlay = true;
				MusicBeatState.switchState(new ModsMenuState());
			case 2:
				if (Math.abs(lerpPosition - position) > 1) return;
				ignoreCheck = true;
				openSubState(new GameplayChangersSubstate());
			case 3:
				if (Math.abs(lerpPosition - position) > 1) return;
				if (!musicMutex.tryAcquire()) return;
				if (!eventPressCheck)
				{
					eventPressCheck = true;
					destroyFreeplayVocals();
					FlxG.sound.music.stop();
					ChartingState.isFreePlay = true;
					LoadingState.loadAndSwitchState(new ChartingState());
				}
			case 4: 
				if (Math.abs(lerpPosition - position) > 1) return;
				ignoreCheck = true;
				openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			case 5:
				randomSel();
			case 6:
				if (songs.length > 21 && curSelected < 22) {
					curSelected = 22;
					changeSelection(0);
				}
		}
	}

	function randomSel() {
		var data = FlxG.random.int(0, songs.length-1);
		if (curSelected != data) {
			curSelected = data;
			changeSelection(0);
		} else {
			randomSel();
		}
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) vocals.stop();
		vocals = FlxDestroyUtil.destroy(vocals);

		if(opponentVocals != null) opponentVocals.stop();
		opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
	}

	var saveMouseY:Int = 0;
	var moveData:Int = 0;
	var avgSpeed:Float = 0;
	function mouseMove()
	{
		if (FlxG.mouse.justPressed) saveMouseY = FlxG.mouse.y;
		moveData = FlxG.mouse.y - saveMouseY;
		saveMouseY = FlxG.mouse.y;
		avgSpeed = avgSpeed * 0.75 + moveData * 0.25;
	}

	function songsRectPosUpdate(forceUpdate:Bool = false) 
	{
		if (!forceUpdate && lerpPosition == position) return; //优化
		for (i in 0...grpSongs.length){
			grpSongs[i].y = lerpPosition + i * 100 + grpSongs[i].lerpPosY;
			grpSongs[i].x = 660 + Math.abs(grpSongs[i].y + grpSongs[i].background.height / 2 - FlxG.height / 2) / FlxG.height / 2 * 250 + grpSongs[i].lerpPosX;
		}
	}

	public function changeSelection(change:Int = 0, playSound:Bool = true, start:Bool = false)
	{
		if (songs.length < 1) return;

		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length-1);
		position = 315 - 100 - curSelected * 100;
		_updateSongLastDifficulty();

		grpSongs[curSelected].onFocus = true;

		for (i in 0...grpSongs.length)
		{
			if (curSelected != i) grpSongs[i].onFocus = false;			
		}

		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();

		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor)
		{
			intendedColor = newColor;
			FlxTween.cancelTweensOf(magenta);
			FlxTween.color(magenta, 1, magenta.color, intendedColor);
		}

		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !Difficulty.list.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		createDiff(start);
		updateRect();
		updateInfo();
		updateVoice();
		_updateSongLastDifficulty();
	}

	inline private function _updateSongLastDifficulty()
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);

	function createDiff(start:Bool = false) 
	{
		for (num in 0...grpSongs.length) 
		{
			grpSongs[num].posY = Difficulty.list.length * 70;
			if (start && num > curSelected) grpSongs[num].lerpPosY = Difficulty.list.length * 70;
		}
		
		grpSongs[curSelected].createDiff(songs[curSelected].color, start);
		updateDiff();
	}

	public function updateDiff() {
		timeSave.text = 'Played Time: ' + Std.string(Highscore.getTime(songs[curSelected].songName, curDifficulty));
		accSave.text = 'Accurate: ' + Std.string(FlxMath.roundDecimal(Highscore.getRating(songs[curSelected].songName, curDifficulty) * 100, 2)) + '%';
		scoreSave.text = 'Score: ' + Std.string(Highscore.getScore(songs[curSelected].songName, curDifficulty));
		
		var msArray = Highscore.getMsGroup(songs[curSelected].songName, curDifficulty);
		var timeArray = Highscore.getTimeGroup(songs[curSelected].songName, curDifficulty);
		result.updateRect(msArray, timeArray);
	}

	var rectMutex:Mutex = new Mutex();
	function updateRect() {
		magenta.loadGraphic(Paths.image('menuDesat'));
		magenta.scale.x = FlxG.width * 1.05 / magenta.width;
		magenta.scale.y = FlxG.height * 1.05 / magenta.height;
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		
		smallMag.updateRect(magenta.pixels);			
	}

	var rateMutex:Mutex = new Mutex();
	function updateInfo() {
		
		var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
		var jsonData:SwagSong = null;
		var speed:Float = 0;
		var count:Int = 0;
		try
		{
		jsonData = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
		speed = jsonData.speed;
		} catch(a:Any){
			return;
		}

		Thread.create(() -> {			
			rateMutex.acquire();
			for (i in jsonData.notes) // sections
			{
				for (ii in i.sectionNotes) // notes
				{
					var gottaHitNote:Bool = i.mustHitSection;
					if ((ii[1] >= 4 && !gottaHitNote) || (ii[1] <= 3 && gottaHitNote))
						count++;
				}
			}

			var rate = DiffCalc.CalculateDiff(Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase())) / 5;
			rate = FlxMath.roundDecimal(rate, 2);
			speed = FlxMath.roundDecimal(speed, 2);

			infoNote.maxData = Math.floor(rate * 500);
			infoNote.data = count;
			infoRating.data = rate;
			infoSpeed.data = speed;

			rateMutex.release();
		});	
	}

	public var useSort:Bool = false;
	public function updateSearch(text:String) 
	{
		if (grpSongs.length > 0) 
		{
			grpSongs[curSelected].onFocus = false;
			grpSongs[curSelected].desDiff();
		}

		songs = [];
		grpSongs = [];

		if (!useSort) {
			for (i in 0...saveSongs.length){
				if (saveSongs[i].songName.trim().toLowerCase().indexOf(text.trim().toLowerCase()) != -1)
				songs.push(saveSongs[i]);
			}
		} else {
			for (i in 0...sortSongs.length){
				if (sortSongs[i].songName.trim().toLowerCase().indexOf(text.trim().toLowerCase()) != -1)
				songs.push(sortSongs[i]);
			}
		}
 
		for (rect in 0...saveGrpSongs.length)
		{
			saveGrpSongs[rect].ignoreCheck = true;
			saveGrpSongs[rect].alpha = 0.6;
			saveGrpSongs[rect].haveAdd = false;
		}
		
		var data:Int = 0;
		for (song in 0...songs.length){
			var added:Bool = false;
			for (rect in 0...saveGrpSongs.length){
				var rect = saveGrpSongs[rect];
				if (rect.name.trim().toLowerCase() == songs[song].songName.trim().toLowerCase() && !rect.haveAdd && !added)
				{
					added = true;
					
					rect.member = data;
					rect.haveAdd = true;
					data++;
					rect.ignoreCheck = false;		
					grpSongs.push(rect);		
				}
			}
		}

		changeSelection();

		if (grpSongs[curSelected] != null)
		{
			grpSongs[curSelected].onFocus = true;
			grpSongs[curSelected].lerpPosX = grpSongs[curSelected].posX;
			grpSongs[curSelected].createDiff(songs[curSelected].color, true);
		}

		if (grpSongs.length > 0)
		{
			for (num in 0...grpSongs.length)
			{
				if (num > curSelected) grpSongs[num].lerpPosY = grpSongs[num].posY;
				else grpSongs[num].lerpPosY = 0;
			}
		}

		position = 315 - 100 - curSelected * 100;
		songsRectPosUpdate(true);

		if (songs.length > 0) updateVoice();
	}

	var musicMutex:Mutex = new Mutex();
	var timer:FlxTimer = new FlxTimer();
	var playedSongName:String = '';
	function updateVoice() {
		if (timer != null) timer.cancel;

		timer.start(0.5, function(tmr:FlxTimer){

			if (songs[curSelected] == null) return;		

			Thread.create(() -> {			
				musicMutex.acquire();

				if (songs[curSelected].songName == playedSongName)
				{
					musicMutex.release();
					return;
				}

				playedSongName = songs[curSelected].songName;

				destroyFreeplayVocals();
				FlxG.sound.music.stop();

				voiceDis.audioDis.stopUpdate = true;
				instDis.audioDis.stopUpdate = true;
				
				try
				{
					var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());

					if (PlayState.SONG.needsVoices)
					{
						vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
						FlxG.sound.list.add(vocals);
						vocals.persist = vocals.looped = true;
						vocals.volume = 0.8;
					}
					else if (vocals != null)
					{
						vocals.stop();
						vocals.destroy();
						vocals = null;
					}
				}catch(e:Any){
					musicMutex.release();
					return;
				}

				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
				if (vocals != null) vocals.play();
				if (opponentVocals != null) opponentVocals.play();

				try{
					voiceDis.audioDis.changeAnalyzer(FlxG.sound.music);
					if (vocals != null) instDis.audioDis.changeAnalyzer(vocals);
					else instDis.audioDis.changeAnalyzer(FlxG.sound.music);
				} catch(e:Any){
					instDis.audioDis.clearUpdate();
				}

				musicMutex.release();
			});
		});
	}

	var waitTime:FlxTimer = new FlxTimer();
	public function updateMusicTime(data:Int, bigJump:Bool) {
		FlxG.sound.music.pause();
		if(opponentVocals != null) opponentVocals.pause();
		if(vocals != null) vocals.pause();

		if (bigJump) FlxG.sound.music.time += Math.floor(FlxG.sound.music.length / 100) * data;
		else FlxG.sound.music.time += 1000 * data;
		if (FlxG.sound.music.time < 0) FlxG.sound.music.time = FlxG.sound.music.length;
		if (FlxG.sound.music.time > FlxG.sound.music.length) FlxG.sound.music.time = 0;
		if(vocals != null) vocals.time = FlxG.sound.music.time;
		if(opponentVocals != null) opponentVocals.time = FlxG.sound.music.time;

		if (waitTime != null) waitTime.cancel();
		waitTime.start(0.1, function(tmr:FlxTimer){
			FlxG.sound.music.resume();
			if(opponentVocals != null) opponentVocals.resume();
			if(vocals != null) vocals.resume();
		});
	}

	public function updateMusicRate(data:Int) {
		FlxG.sound.music.pitch += 0.05 * data;
		FlxG.sound.music.pitch = FlxMath.roundDecimal(FlxG.sound.music.pitch, 2);
		if (FlxG.sound.music.pitch < 0.5) FlxG.sound.music.pitch = 0.5;
		if (FlxG.sound.music.pitch > 4) FlxG.sound.music.pitch = 4;
		if(vocals != null) vocals.pitch = FlxG.sound.music.pitch;
		if(opponentVocals != null) opponentVocals.pitch = FlxG.sound.music.pitch;
	}

	function getVocalFromCharacter(char:String)
	{
		try
		{
			var path:String = Paths.getPath('characters/$char.json', TEXT);
			#if MODS_ALLOWED
			var character:Dynamic = Json.parse(File.getContent(path));
			#else
			var character:Dynamic = Json.parse(Assets.getText(path));
			#end
			return character.vocals_file;
		}
		return null;
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}
	
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;
	public var bg:Dynamic;
	public var searchnum:Int = 0;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		this.bg = Paths.image('menuDesat');
		this.searchnum = 0;
		if(this.folder == null) this.folder = '';
	}
}
