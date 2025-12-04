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

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;
import substates.ErrorSubState;

import states.MainMenuState;
import states.PlayState;
import states.LoadingState;
import states.editors.ChartingState;
import options.OptionsState;

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

	public static var vocals:FlxSound = null;

	public var mouseEvent:MouseEvent;

	///////////////////////////////////////////////////////////////////////////////////////////////

	var background:ChangeSprite;

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

		background = new ChangeSprite(0, 0).load(Paths.image('menuDesat'));
		background.antialiasing = ClientPrefs.data.antialiasing;
		add(background);

		detailRect = new DetailRect(0, 0);
		add(detailRect);

		detailSongName = new FlxText(0, 0, 0, 'songName', Std.int(detailRect.bg1.height * 0.25));
		detailSongName.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(detailRect.bg1.height * 0.15), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        detailSongName.borderStyle = NONE;
		detailSongName.antialiasing = ClientPrefs.data.antialiasing;
		detailSongName.x = 10;
		add(detailSongName);

		detailMusican = new FlxText(0, 0, 0, 'musican', Std.int(detailRect.bg1.height * 0.25));
		detailMusican.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(detailRect.bg1.height * 0.09), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        detailMusican.borderStyle = NONE;
		detailMusican.antialiasing = ClientPrefs.data.antialiasing;
		detailMusican.x = detailSongName.x;
		detailMusican.y = detailSongName.y + detailSongName.textField.textHeight;
		add(detailMusican);

		detailPlaySign = new FlxSprite(0).loadGraphic(Paths.image(filePath + 'playedCount'));
		detailPlaySign.setGraphicSize(Std.int(50));
		detailPlaySign.updateHitbox();
		detailPlaySign.antialiasing = ClientPrefs.data.antialiasing;
		detailPlaySign.x = detailSongName.x;
		detailPlaySign.y = detailMusican.y + detailMusican.height + 5;
		detailPlaySign.offset.set(0,0);
		add(detailPlaySign);

		detailPlayText = new FlxText(0, 0, 0, '0', Std.int(detailRect.bg1.height * 0.25));
		detailPlayText.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(detailRect.bg1.height * 0.09), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        detailPlayText.borderStyle = NONE;
		detailPlayText.antialiasing = ClientPrefs.data.antialiasing;
		detailPlayText.x = detailPlaySign.x + detailPlaySign.width + 5;
		detailPlayText.y = detailPlaySign.y + (detailPlaySign.height - detailPlayText.height) / 2;
		add(detailPlayText);

		detailTimeSign = new FlxSprite(0).loadGraphic(Paths.image(filePath + 'songTime'));
		detailTimeSign.setGraphicSize(Std.int(50));
		detailTimeSign.updateHitbox();
		detailTimeSign.antialiasing = ClientPrefs.data.antialiasing;
		detailTimeSign.x = detailSongName.x + 150;
		detailTimeSign.y = detailPlaySign.y;
		detailTimeSign.offset.set(0,0);
		add(detailTimeSign);

		detailTimeText = new FlxText(0, 0, 0, '1:00', Std.int(detailRect.bg1.height * 0.25));
		detailTimeText.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(detailRect.bg1.height * 0.09), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        detailTimeText.borderStyle = NONE;
		detailTimeText.antialiasing = ClientPrefs.data.antialiasing;
		detailTimeText.x = detailTimeSign.x + detailTimeSign.width + 5;
		detailTimeText.y = detailTimeSign.y + (detailTimeSign.height - detailTimeText.height) / 2;
		add(detailTimeText);

		detailBpmSign = new FlxSprite(0).loadGraphic(Paths.image(filePath + 'bpmCount'));
		detailBpmSign.setGraphicSize(Std.int(50));
		detailBpmSign.updateHitbox();
		detailBpmSign.antialiasing = ClientPrefs.data.antialiasing;
		detailBpmSign.x = detailSongName.x + 300;
		detailBpmSign.y = detailPlaySign.y;
		detailBpmSign.offset.set(0,0);
		add(detailBpmSign);

		detailBpmText = new FlxText(0, 0, 0, '300', Std.int(detailRect.bg1.height * 0.25));
		detailBpmText.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(detailRect.bg1.height * 0.09), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        detailBpmText.borderStyle = NONE;
		detailBpmText.antialiasing = ClientPrefs.data.antialiasing;
		detailBpmText.x = detailBpmSign.x + detailBpmSign.width + 5;
		detailBpmText.y = detailBpmSign.y + (detailBpmSign.height - detailBpmText.height) / 2;
		add(detailBpmText);

		detailStar = new StarRect(detailSongName.x, detailRect.bg2.y + (detailRect.bg2.height - detailRect.bg3.height) * 0.15, 60, (detailRect.bg2.height - detailRect.bg3.height) * 0.7);
		add(detailStar);

		detailMapper = new FlxText(0, 0, 0, 'eazy mapped by test', Std.int(detailRect.bg1.height * 0.25));
		detailMapper.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(detailRect.bg1.height * 0.09), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        detailMapper.borderStyle = NONE;
		detailMapper.antialiasing = ClientPrefs.data.antialiasing;
		detailMapper.x = detailStar.x + detailStar.width + 10;
		detailMapper.y = detailRect.bg2.y;
		add(detailMapper);

		noteData = new DataDis(10, detailRect.bg3.y + 10, 120, 5, 'Notes');
		add(noteData);

		holdNoteData = new DataDis(noteData.x + noteData.lineDis.width * 1.2, detailRect.bg3.y + 10, 120, 5, 'Hold Notes');
		add(holdNoteData);

		speedData = new DataDis(holdNoteData.x + holdNoteData.lineDis.width * 1.2, detailRect.bg3.y + 10, 120, 5, 'Speed');
		add(speedData);

		keyCountData = new DataDis(speedData.x + speedData.lineDis.width * 1.2, detailRect.bg3.y + 10, 120, 5, 'Key count');
		add(keyCountData);

		//////////////////////////////////////////////////////////////////////////////////////////

		/*
		var songRectload:Array<DataPrepare> = [];

		for (time in 0...Math.ceil((Math.ceil(FlxG.height / SongRect.fixHeight * inter) + 2) / songsData.length)){
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

		for (time in 0...Math.ceil((Math.ceil(FlxG.height / SongRect.fixHeight * inter) + 2) / songsData.length)){
			for (i in 0...songsData.length)
			{
				Mods.currentModDirectory = songsData[i].folder;
				var data = songsData[i];
				var rect = new SongRect(data.songName, data.songCharacter, data.songMusican, data.songCharter, data.color);
				rect.id = rect.currect = time * songsData.length + i;
				add(rect);
				songGroup.push(rect);
			}
		}

		songsMove = new MouseMove(FreeplayState, 'songPosiData', 
								[-songGroup.length * SongRect.fixHeight, 720 * 0.3],
								[	
									[FlxG.width * 0.5, FlxG.width], 
									[0, FlxG.height]
								],
								songMoveEvent);
		songsMove.tweenTime = SongRect.moveTime;
		songsMove.tweenType = 'expoInOut';
		add(songsMove);

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		selectedBG = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image(FreeplayState.filePath + 'selectBG'));
        selectedBG.antialiasing = ClientPrefs.data.antialiasing;
		selectedBG.x -= selectedBG.width;
		selectedBG.alpha = 0.6;
        add(selectedBG);

		searchButton = new SearchButton(695, 5);
		add(searchButton);

		diffSelect = new DiffSelect(688, 65);
		add(diffSelect);

		sortButton = new SortButton(682, 105);
		add(sortButton);

		collectionButton = new CollectionButton(977, 105);
		add(collectionButton);

		//////////////////////////////////////////////////////////////////////////////////////////

		downBG = new Rect(0, FlxG.height - 49, FlxG.width, 51, 0, 0); //嗯卧槽怎么全屏会漏
		downBG.color = 0x242A2E;
		add(downBG);

		backRect = new BackButton(0, FlxG.height - 65, 195, 65);
		add(backRect);

		for (data in 0...funcData.length)
		{
			var button = new FuncButton(backRect.x + backRect.width + 15 + 140 * data, backRect.y, funcData[data], funcColors[data]);
			add(button);
			funcGroup.push(button);
		}

		playButton = new PlayButton(1100, 560);
		add(playButton);

		//////////////////////////////////////////////////////////////////////////////////////////

		

		//////////////////////////////////////////////////////////////////////////////////////////

		WeekData.setDirectoryFromWeek();

		changeSelection();
		SongRect.focusRect.createDiff();
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	public var songPosiStart:Float = 720 * 0.30;
	public static var songPosiData:Float = 720 * 0.30; //神人haxe不能用FlxG.height
	public var inter:Float = 0.95;
	public function songMoveEvent(){
		if (songGroup.length <= 0) return;
		for (i in 0...songGroup.length) {
			songGroup[i].moveY(songPosiData + songGroup[i].diffY + (songGroup[i].currect) * SongRect.fixHeight * inter);
			songGroup[i].calcX();
		}
	}

	var holdTime:Float = 0;

	public var allowUpdate:Bool = false;
	override function update(elapsed:Float)
	{
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
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (controls.UI_DOWN_P)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if (controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 30);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 30);

				if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
			}
			
			if (controls.ACCEPT) {
			    var target = songGroup[curSelected];
			    if (!target.diffAdded) {			        
			        target.createDiff();
			    } else {
			    
			    }
			}
		}
	}

	public function changeSelection(change:Int = 0, playSound:Bool = true)
	{
	    songsMove.tweenData = songPosiStart - curSelected * SongRect.fixHeight * inter;

		curSelected = FlxMath.wrap(curSelected + change, 0, songGroup.length - 1);
		SongRect.updateFocus();

		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		/*
		var newColor:Int = songsData[curSelected].color;
		if (newColor != intendedColor)
		{
			intendedColor = newColor;
			FlxTween.cancelTweensOf(bg);
			FlxTween.color(bg, 1, bg.color, intendedColor);
		}
			*/

		Mods.currentModDirectory = songsData[curSelected].folder;
		PlayState.storyWeek = songsData[curSelected].week;
		
	}
	
	function changeDiff(change:Int = 0)
	{
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length - 1);
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
