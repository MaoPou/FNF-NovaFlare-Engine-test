package states;

import flixel.addons.transition.FlxTransitionableState;

import haxe.Json;
import haxe.ds.ArraySort;

import openfl.system.System;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import backend.diffCalc.DiffCalc;
import backend.Replay;
import backend.diffCalc.StarRating;

import backend.state.freeplayState.*;
import backend.state.freeplayState.PreThreadLoad.DataPrepare;
import objects.state.freeplayState.detail.*;
import objects.state.freeplayState.down.*;
import objects.state.freeplayState.others.*;
import objects.state.freeplayState.select.*;
import objects.state.freeplayState.song.*;
import flixel.FlxCamera;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;
import substates.ErrorSubState;

import states.MainMenuState;
import states.PlayState;
import states.LoadingState;
import states.editors.ChartingState;
import options.OptionsState;
import shaders.states.freeplayState.BlurFilter;

import sys.thread.Thread;
import sys.thread.Mutex;

class FreeplayState extends MusicBeatState
{
	static public var filePath:String = 'menuExtendHide/freeplay/';
	static public var instance:FreeplayState;
	
	static public var curSelected:Int = 0;
	static public var curDifficulty:Int = -1;

	///////////////////////////////////////////////////////////////////////////////////////////////

	var songsData:Array<SongMetadata> = [];

	public var songGroup:Array<SongRect> = [];
	public var songsMove:MouseMove;

	var camBG:FlxCamera;
	var camSongs:FlxCamera;
	var camAfter:FlxCamera;

	public static var vocals:FlxSound = null;

	public var mouseEvent:MouseEvent;

	///////////////////////////////////////////////////////////////////////////////////////////////

	var background:ChangeSprite;
	var intendedColor:Int;

	var detailRect:DetailRect;

	var detailSongName:FlxText;
	var detailMusican:FlxText;

	var detailPlaySign:FlxSprite;
	var detailPlayText:FlxText;

	var detailTimeSign:FlxSprite;
	var detailTimeText:FlxText;

	var detailBpmSign:FlxSprite;
	var detailBpmText:FlxText;

	var detailStar:StarRect;
	var detailMapper:FlxText;

	var noteData:DataDis;
	var holdNoteData:DataDis;
	var speedData:DataDis;
	var keyCountData:DataDis;

	///////////////////////////////////////////////////////////////////////////////////////////////

	//public var prepareLoad:PreThreadLoad;

	///////////////////////////////////////////////////////////////////////////////////////////////

	var historyGroup:Array<HistoryRect> = [];

	///////////////////////////////////////////////////////////////////////////////////////////////

	var funcData:Array<String> = ['option', 'mod', 'changer', 'editor', 'reset', 'random'];
	var funcColors:Array<FlxColor> = [0x63d6ff, 0xd1fc52, 0xff354e, 0xff617e, 0xfd6dff, 0x6dff6d];
	var downBG:Rect;
	var backRect:BackButton;
	var funcGroup:Array<FuncButton> = [];
	var playButton:PlayButton;

	///////////////////////////////////////////////////////////////////////////////////////////////

	var selectedBG:FlxSprite;
	var searchButton:SearchButton;
	var diffSelect:DiffSelect;
	var sortButton:SortButton;
	var collectionButton:CollectionButton;

	override function create()
	{
		super.create();

		instance = this;

		#if !mobile
		FlxG.mouse.visible = true;
		#end

		mouseEvent = new MouseEvent();
		add(mouseEvent);

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		
		for (i in 0...WeekData.weeksList.length)
		{
			if (weekIsLocked(WeekData.weeksList[i]))
				continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);

			WeekData.setDirectoryFromWeek(leWeek);
			
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if (colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				var muscan:String = song[3];
				if (song[3] == null)
					muscan = 'N/A';
				var charter:Array<String> = song[4];
				if (song[4] == null)
					charter = ['N/A', 'N/A', 'N/A'];
				songsData.push(new SongMetadata(song[0], i, song[1], muscan, charter, colors));
			}
		}

		Mods.loadTopMod();
		
		//////////////////////////////////////////////////////////////////////////////////////////

		camBG = new FlxCamera();
		camBG.bgColor = 0x00000000;
		FlxG.cameras.add(camBG);
		camSongs = new FlxCamera();
		camSongs.bgColor = 0x00000000;
		FlxG.cameras.add(camSongs);
		camAfter = new FlxCamera();
		camAfter.bgColor = 0x00000000;
		FlxG.cameras.add(camAfter);

		background = new ChangeSprite(0, 0).load(Paths.image('menuDesat'), 1.05);
		background.antialiasing = ClientPrefs.data.antialiasing;
		background.camera = camBG;
		add(background);
		var bgBlur = new BlurFilter(15.0);
		bgBlur.apply(camBG);

		detailRect = new DetailRect(0, 0);
		detailRect.camera = camAfter;
		add(detailRect);

		detailSongName = new FlxText(0, 0, 0, 'songName', Std.int(detailRect.bg1.height * 0.25));
		detailSongName.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(detailRect.bg1.height * 0.15), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        detailSongName.borderStyle = NONE;
		detailSongName.antialiasing = ClientPrefs.data.antialiasing;
		detailSongName.x = 10;
		detailSongName.camera = camAfter;
		add(detailSongName);

		detailMusican = new FlxText(0, 0, 0, 'musican', Std.int(detailRect.bg1.height * 0.25));
		detailMusican.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(detailRect.bg1.height * 0.09), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        detailMusican.borderStyle = NONE;
		detailMusican.antialiasing = ClientPrefs.data.antialiasing;
		detailMusican.x = detailSongName.x;
		detailMusican.y = detailSongName.y + detailSongName.textField.textHeight;
		detailMusican.camera = camAfter;
		add(detailMusican);

		detailPlaySign = new FlxSprite(0).loadGraphic(Paths.image(filePath + 'playedCount'));
		detailPlaySign.setGraphicSize(Std.int(50));
		detailPlaySign.updateHitbox();
		detailPlaySign.antialiasing = ClientPrefs.data.antialiasing;
		detailPlaySign.x = detailSongName.x;
		detailPlaySign.y = detailMusican.y + detailMusican.height + 5;
		detailPlaySign.camera = camAfter;
		detailPlaySign.offset.set(0,0);
		add(detailPlaySign);

		detailPlayText = new FlxText(0, 0, 0, '0', Std.int(detailRect.bg1.height * 0.25));
		detailPlayText.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(detailRect.bg1.height * 0.09), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        detailPlayText.borderStyle = NONE;
		detailPlayText.antialiasing = ClientPrefs.data.antialiasing;
		detailPlayText.x = detailPlaySign.x + detailPlaySign.width + 5;
		detailPlayText.y = detailPlaySign.y + (detailPlaySign.height - detailPlayText.height) / 2;
		detailPlayText.camera = camAfter;
		add(detailPlayText);

		detailTimeSign = new FlxSprite(0).loadGraphic(Paths.image(filePath + 'songTime'));
		detailTimeSign.setGraphicSize(Std.int(50));
		detailTimeSign.updateHitbox();
		detailTimeSign.antialiasing = ClientPrefs.data.antialiasing;
		detailTimeSign.x = detailSongName.x + 150;
		detailTimeSign.camera = camAfter;
		detailTimeSign.y = detailPlaySign.y;
		detailTimeSign.offset.set(0,0);
		add(detailTimeSign);

		detailTimeText = new FlxText(0, 0, 0, '1:00', Std.int(detailRect.bg1.height * 0.25));
		detailTimeText.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(detailRect.bg1.height * 0.09), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        detailTimeText.borderStyle = NONE;
		detailTimeText.antialiasing = ClientPrefs.data.antialiasing;
		detailTimeText.x = detailTimeSign.x + detailTimeSign.width + 5;
		detailTimeText.y = detailTimeSign.y + (detailTimeSign.height - detailTimeText.height) / 2;
		detailTimeText.camera = camAfter;
		add(detailTimeText);

		detailBpmSign = new FlxSprite(0).loadGraphic(Paths.image(filePath + 'bpmCount'));
		detailBpmSign.setGraphicSize(Std.int(50));
		detailBpmSign.updateHitbox();
		detailBpmSign.antialiasing = ClientPrefs.data.antialiasing;
		detailBpmSign.x = detailSongName.x + 300;
		detailBpmSign.camera = camAfter;
		detailBpmSign.y = detailPlaySign.y;
		detailBpmSign.offset.set(0,0);
		add(detailBpmSign);

		detailBpmText = new FlxText(0, 0, 0, '300', Std.int(detailRect.bg1.height * 0.25));
		detailBpmText.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(detailRect.bg1.height * 0.09), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        detailBpmText.borderStyle = NONE;
		detailBpmText.antialiasing = ClientPrefs.data.antialiasing;
		detailBpmText.x = detailBpmSign.x + detailBpmSign.width + 5;
		detailBpmText.y = detailBpmSign.y + (detailBpmSign.height - detailBpmText.height) / 2;
		detailBpmText.camera = camAfter;
		add(detailBpmText);

		detailStar = new StarRect(detailSongName.x, detailRect.bg2.y, 80, (detailRect.bg2.height - detailRect.bg3.height) * 0.7);
		detailStar.y += (detailRect.bg2.height - detailRect.bg3.height) * 0.5 - detailStar.height * 0.5;
		add(detailStar);

		detailMapper = new FlxText(0, 0, 0, '0.99 eazy mapped by test', Std.int(detailRect.bg1.height * 0.25));
		detailMapper.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int((detailRect.bg2.height - detailRect.bg3.height) * 0.7 * 0.6), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        detailMapper.borderStyle = NONE;
		detailMapper.antialiasing = ClientPrefs.data.antialiasing;
		detailMapper.x = detailStar.x + detailStar.width + 10;
		detailMapper.y = detailRect.bg2.y + (detailRect.bg2.height - detailRect.bg3.height) * 0.5 - detailMapper.height * 0.5;
		detailMapper.camera = camAfter;
		detailMapper.color = 0x9bff7a;
		add(detailMapper);


		noteData = new DataDis(10, detailRect.bg3.y + 5, 120, 5, 'Notes');
		noteData.camera = camAfter;
		add(noteData);

		holdNoteData = new DataDis(noteData.x + noteData.lineDis.width * 1.2, detailRect.bg3.y + 8, 120, 5, 'Hold Notes');
		holdNoteData.camera = camAfter;
		add(holdNoteData);

		speedData = new DataDis(holdNoteData.x + holdNoteData.lineDis.width * 1.2, detailRect.bg3.y + 8, 120, 5, 'Speed');
		speedData.camera = camAfter;
		add(speedData);

		keyCountData = new DataDis(speedData.x + speedData.lineDis.width * 1.2, detailRect.bg3.y + 8, 120, 5, 'Key count');
		keyCountData.camera = camAfter;
		add(keyCountData);

		//////////////////////////////////////////////////////////////////////////////////////////

		/*
		var songRectload:Array<DataPrepare> = [];

		for (time in 0...Math.ceil((Math.ceil(FlxG.height / SongRect.fixHeight * rectInter) + 2) / songsData.length)){
			for (i in 0...songsData.length)
			{
				var data = songsData[i];
				var rectGrp = {modPath: songsData[i].folder, bgPath: data.songName, iconPath: data.songCharacter, color: data.color};
				songRectload.push(rectGrp);
			}
		}

		prepareLoad = new PreThreadLoad();
		prepareLoad.start(songRectload); //狗屎haxe，多线程无效了
		*/

		for (i in 0...songsData.length)
		{
			Mods.currentModDirectory = songsData[i].folder;
			var data = songsData[i];
			var rect = new SongRect(data.songName, data.songCharacter, data.songMusican, data.songCharter, data.color);
			rect.id = i;
			add(rect);
			songGroup.push(rect);
			rect.camera = camSongs;
		}

		songsMove = new MouseMove(FreeplayState, 'songPosiData', 
								[songPosiData - (songGroup.length + 1) * SongRect.fixHeight, FlxG.height * 0.5 - SongRect.fixHeight * 0.5],
								[	
									[FlxG.width * 0.6, FlxG.width], 
									[0, FlxG.height]
								],
								songMoveEvent);
		songsMove.useLerp = true;
		songsMove.lerpSmooth = 8;
		add(songsMove);

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		selectedBG = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image(FreeplayState.filePath + 'selectBG'));
        selectedBG.antialiasing = ClientPrefs.data.antialiasing;
		selectedBG.x -= selectedBG.width;
		selectedBG.alpha = 0.6;
        add(selectedBG);
		selectedBG.cameras = [camAfter];

		searchButton = new SearchButton(695, 5);
		add(searchButton);
		searchButton.cameras = [camAfter];

		diffSelect = new DiffSelect(688, 65);
		add(diffSelect);
		diffSelect.cameras = [camAfter];

		sortButton = new SortButton(682, 105);
		add(sortButton);
		sortButton.cameras = [camAfter];

		collectionButton = new CollectionButton(977, 105);
		add(collectionButton);
		collectionButton.cameras = [camAfter];

		//////////////////////////////////////////////////////////////////////////////////////////

		downBG = new Rect(0, FlxG.height - 49, FlxG.width, 51, 0, 0); //嗯卧槽怎么全屏会漏
		downBG.color = 0x242A2E;
		add(downBG);
		downBG.cameras = [camAfter];

		backRect = new BackButton(0, FlxG.height - 65, 195, 65);
		add(backRect);
		backRect.cameras = [camAfter];

		for (data in 0...funcData.length)
		{
			var button = new FuncButton(backRect.x + backRect.width + 15 + 140 * data, backRect.y, funcData[data], funcColors[data]);
			add(button);
			funcGroup.push(button);
			button.cameras = [camAfter];
		}

		playButton = new PlayButton(1100, 560);
		add(playButton);
		playButton.cameras = [camAfter];

		//////////////////////////////////////////////////////////////////////////////////////////

		

		//////////////////////////////////////////////////////////////////////////////////////////

		WeekData.setDirectoryFromWeek();
		songGroup[curSelected].changeSelectAll(true);
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	public final songPosiStart:Float = 720 * 0.3;
	public static var songPosiData:Float = 720 * 0.3; //神人haxe不能用FlxG.height
	public var rectInter:Float = 0.97;
	public function songMoveEvent(){
		if (songGroup.length <= 0) return;
		for (i in 0...songGroup.length) {
			songGroup[i].moveY(songPosiData + (songGroup[i].id) * SongRect.fixHeight * rectInter);
			songGroup[i].calcX();
		}
		updateSongVisibility();
	}

	var holdTime:Float = 0;

	public var allowUpdate:Bool = false;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);

		var shiftMult:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftMult = 3;

		if (songGroup.length > 1)
		{
			if (FlxG.keys.justPressed.HOME)
			{
				curSelected = 0;
				changeSelection();
				holdTime = 0;
			}
			else if (FlxG.keys.justPressed.END)
			{
				curSelected = songGroup.length - 1;
				changeSelection();
				holdTime = 0;
			}
			if (controls.UI_UP_P)
			{
				holdTime = 0;
				if (curSelected != SongRect.openRect.id) {
					var newCurSelected:Int = FlxMath.wrap(curSelected - shiftMult, 0, songGroup.length - 1);
					if (newCurSelected == SongRect.openRect.id) {
						curDifficulty = Difficulty.list.length - 1;
						songGroup[newCurSelected].diffFouceUpdate();
						curSelected = newCurSelected;
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
						songsMove.tweenData = FlxG.height * 0.5 - SongRect.fixHeight * 0.5 - curSelected * SongRect.fixHeight * rectInter - (curDifficulty+1) * DiffRect.fixHeight * 1.05;
					} else {
						curDifficulty = -1;
						songGroup[curSelected].diffFouceUpdate();
						changeSelection(-shiftMult);
					}
				} else {
					if (curDifficulty >= 0) {
						curDifficulty--;
						songGroup[curSelected].diffFouceUpdate();
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
						if (curDifficulty >= 0) songsMove.tweenData = FlxG.height * 0.5 - SongRect.fixHeight * 0.5 - curSelected * SongRect.fixHeight * rectInter - (curDifficulty+1) * DiffRect.fixHeight * 1.05;
						else songsMove.tweenData = FlxG.height * 0.5 - SongRect.fixHeight * 0.5 - curSelected * SongRect.fixHeight * rectInter;
					} else {
						curDifficulty = -1;
						songGroup[curSelected].diffFouceUpdate();
						changeSelection(-shiftMult);
					}
				}
			}
			if (controls.UI_DOWN_P)
			{
				holdTime = 0;
				if (curSelected != SongRect.openRect.id)
					changeSelection(shiftMult);
				else {
					if (curDifficulty < Difficulty.list.length - 1) {
						curDifficulty++;
						songGroup[curSelected].diffFouceUpdate();
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
						songsMove.tweenData = FlxG.height * 0.5 - SongRect.fixHeight * 0.5 - curSelected * SongRect.fixHeight * rectInter - (curDifficulty+1) * DiffRect.fixHeight * 1.05;
					} else {
						curDifficulty = -1;
						songGroup[curSelected].diffFouceUpdate();
						changeSelection(shiftMult);
					}
				}
				
			}

			if (controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 30);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 30);

				if (holdTime > 0.5 && checkNewHold - checkLastHold > 0) {
					curDifficulty = -1;
					SongRect.openRect.diffFouceUpdate();
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}
			}
			
			if (controls.ACCEPT) 			
			{
				if (curSelected != SongRect.openRect.id) {
			   		songGroup[curSelected].changeSelectAll();
				} else {
					startGame();
				}
			}
		}
		updateSongVisibility();
	}

	public function startGame() {
		if (curDifficulty >= 0 && curDifficulty < Difficulty.list.length) {
			var songLowercase:String = Paths.formatToSongPath(songsData[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

			try
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			}
			catch (e:Dynamic)
			{
				trace('ERROR! $e');

				var errorStr:String = e.toString();
				if (errorStr.startsWith('[lime.utils.Assets] ERROR:'))
					errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length - 1); // Missing chart

				trace(errorStr);
				FlxG.sound.play(Paths.sound('cancelMenu'));
				return;
			}

			LoadingState.prepareToSong();
			if (ClientPrefs.data.loadingScreen)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
			}
			LoadingState.loadAndSwitchState(new PlayState());
			destroyFreeplayVocals();
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		}
	}

	public function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, songGroup.length - 1);

		songsMove.tweenData = FlxG.height * 0.5 - SongRect.fixHeight * 0.5 - curSelected * SongRect.fixHeight * rectInter - (curSelected <= SongRect.openRect.id ? 0 : Difficulty.list.length * DiffRect.fixHeight * 1.05 + SongRect.fixHeight * (0.1 * 2));
		
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		background.changeSprite(Cache.getFrame('freePlayBG-' + songGroup[curSelected].bgPath));
		
		var colors:Array<Int> = songsData[curSelected].color;
		var newColor:Int = FlxColor.fromRGB(Std.int(colors[0] * 1.0), Std.int(colors[1] * 1.0), Std.int(colors[2] * 1.0));
		if (newColor != intendedColor)
		{
			intendedColor = newColor;
			background.changeColor(intendedColor);
		}

		Mods.currentModDirectory = songsData[curSelected].folder;
		PlayState.storyWeek = songsData[curSelected].week;
	}

	public function updateSongLayerOrder():Void
	{
		if (songGroup.length == 0 || SongRect.openRect == null) return;
		var start:Int = members.indexOf(songGroup[0]);
		if (start < 0) return;
		var sorted:Array<SongRect> = songGroup.copy();
		ArraySort.sort(sorted, function(a:SongRect, b:SongRect) {
			var da:Int = Std.int(Math.abs(a.id - SongRect.openRect.id));
			var db:Int = Std.int(Math.abs(b.id - SongRect.openRect.id));
			return db - da;
		});
		for (rect in songGroup) remove(rect, true);
		var idx:Int = start;
		for (rect in sorted) {
			insert(idx, rect);
			idx++;
		}
	}

	function rectOnScreen(r:SongRect):Bool {
		var cy:Float = camSongs.scroll.y;
		var ch:Float = camSongs.height;
		var ry:Float = r.y;
		var rh:Float = r.selectShow.height;

		if (r == SongRect.openRect) {
			rh = r.selectShow.height + Difficulty.list.length * DiffRect.fixHeight * 1.05 + SongRect.fixHeight * (0.1 * 2);
		}
		return ry + rh > cy && ry < cy + ch;
	}

	public function updateSongVisibility():Void {
		if (songGroup.length == 0) return;
		for (r in songGroup) {
			var ons:Bool = rectOnScreen(r);
			r.visible = ons;
			r.active = ons;
		}
	}
	
	function changeDiff(change:Int = 0)
	{
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length - 1);
	}

	override function beatHit()
	{
		super.beatHit();
		if (Std.int(Conductor.getBeat(Conductor.songPosition)) % 2 == 0) SongRect.openRect.beatHit();
	}
	
	public static function destroyFreeplayVocals() {
		
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Array<Int> = [0, 0, 0];
	public var folder:String = "";
	public var bg:Dynamic;
	public var searchnum:Int = 0;
	public var songMusican:String = 'N/A';
	public var songCharter:Array<String> = ['N/A', 'N/A', 'N/A'];

	public function new(song:String, week:Int, songCharacter:String, musican:String, charter:Array<String>, color:Array<Int>)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		this.bg = Paths.image('menuDesat', null, false);
		this.searchnum = 0;
		this.songMusican = musican;
		this.songCharter = charter;
		if (this.folder == null)
			this.folder = '';
	}
}
