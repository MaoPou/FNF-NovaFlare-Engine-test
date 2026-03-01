package games.funkin.backend;

import flixel.input.keyboard.FlxKey;
import flixel.FlxBasic;
import server.util.EncryptUtil;
import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

typedef FrameSave = {
	var time:Float;
	var songSpeed:Float;
	var playbackRate:Float;
	var pressKey:Array<String>;
	var releaseKey:Array<String>;
}

typedef StateRecord = {
	var songName:String;
	var difficulty:String;
	var playDate:String;
	var songLength:Float;
	
	var songSpeed:Float;
	var playbackRate:Float;
	var healthGain:Float;
	var healthLoss:Float;
	var cpuControlled:Bool;
	var practiceMode:Bool;
	var instakillOnMiss:Bool;
	var playOpponent:Bool; 
	var flipChart:Bool;
	
	var songScore:Int; 
	var ratingPercent:Float;
	var ratingFC:String;
	var songHits:Int;
	var highestCombo:Int;
	var songMisses:Int;
	var hitMapTime:Array<Float>;
	var hitMapMs:Array<Float>;
}

class Replay extends FlxBasic
{
	private var frameData:Array<FrameSave> = [];
	private var follow:Dynamic;
	private var isRecording:Bool = true;
	public static var preparedPath:String;
	private var keysHeld:Map<FlxKey, Bool> = new Map<FlxKey, Bool>();

	/////////////////////////////////////////////

	public function new(follow:Dynamic)
	{
		super();
		this.follow = follow;
	}

	public function load() {
		isRecording = false;
		frameData = ReplaySave.loadPlayRecord();
	}

	private var lastSaveTime:Float = 0;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!isRecording) return;

		if (FlxG.keys.justPressed.ANY || FlxG.keys.justReleased.ANY || lastSaveTime >= 0.01666) {
			lastSaveTime = 0;
			frameData.push(inputUpload());
		} else {
			lastSaveTime += elapsed;
		}
	}

	private var lastFrameCount:Int = 0;
	override function handleInput(elapsed:Float) 
	{
		super.handleInput(elapsed);
		if (isRecording) return;

		while (lastFrameCount < frameData.length && frameData[lastFrameCount].time <= Conductor.songPosition) {
			var frame = frameData[lastFrameCount];
			
			for (keyName in frame.pressKey) {
				var flxKey = FlxKey.fromString(keyName);
				if (flxKey != FlxKey.NONE) {
					var keyObj = @:privateAccess FlxG.keys.getKey(flxKey);
					if (keyObj != null) {
						// Force key state to JUST_PRESSED
						@:privateAccess keyObj.current = 2;
					}
					
					keysHeld.set(flxKey, true);
				}
			}
			
			for (keyName in frame.releaseKey) {
				var flxKey = FlxKey.fromString(keyName);
				if (flxKey != FlxKey.NONE) {
					var keyObj = @:privateAccess FlxG.keys.getKey(flxKey);
					if (keyObj != null) {
						// Force key state to JUST_RELEASED
						@:privateAccess keyObj.current = -1;
					}
					
					keysHeld.remove(flxKey);
				}
			}
			lastFrameCount++;
		}
		
		// Maintain PRESSED state for held keys
		for (flxKey in keysHeld.keys()) {
			var keyObj = @:privateAccess FlxG.keys.getKey(flxKey);
			if (keyObj != null) {
				// If it's not JUST_PRESSED (2) or JUST_RELEASED (-1), force it to PRESSED (1)
				// This prevents Flixel from resetting it to RELEASED (0)
				if (keyObj.current != 2 && keyObj.current != -1) {
					@:privateAccess keyObj.current = 1;
				}
			}
		}
	}

	private var pressKey:Array<String> = [];
	private var releaseKey:Array<String> = [];
	private function inputUpload():FrameSave
	{
		pressKey = [];
		releaseKey = [];
		for (keyName in FlxKey.toStringMap.keys()) 
		{
			var key:FlxKey = FlxKey.toStringMap.get(keyName);
			
			if (key == FlxKey.ANY || key == FlxKey.NONE || key == FlxKey.ENTER) continue;

			if (FlxG.keys.checkStatus(key, JUST_PRESSED)) {
				pressKey.push(key);
			}
			if (FlxG.keys.checkStatus(key, JUST_RELEASED)) {
				releaseKey.push(key);
			}
		}
		return {
			time: Conductor.songPosition,
			songSpeed: follow.songSpeed,
			playbackRate: follow.playbackRate,
			pressKey: pressKey,
			releaseKey: releaseKey
		};
	}

	public function savePlayRecord(stateRecord:StateRecord) {
		ReplaySave.savePlayRecord(frameData, stateRecord);
	}
}

class ReplaySave {
	public static function loadPlayRecord():Array<FrameSave>
	{
		#if sys
		var content:String = File.getContent(Replay.preparedPath);
		content = EncryptUtil.aesDecrypt(content);
		var json:Dynamic = Json.parse(content);
		
		return json.frameRecord;
		#else
		return null;
		#end
	}

	public static function savePlayRecord(frameData:Array<FrameSave>, stateRecord:StateRecord)
	{
		#if sys
		var srdSave:StringBuf = new StringBuf();
		srdSave.add("{\n");
		
		// 1. stateRecord
		srdSave.add('\t"stateRecord": {\n');
		var fields = [
			"songName", "difficulty", "playDate", "songLength",
			"songSpeed", "playbackRate", "healthGain", "healthLoss",
			"cpuControlled", "practiceMode", "instakillOnMiss", "playOpponent", "flipChart",
			"songScore", "ratingPercent", "ratingFC", "songHits", "highestCombo", "songMisses",
			"hitMapTime", "hitMapMs"
		];
		for (i in 0...fields.length) {
			var key = fields[i];
			var val = Reflect.field(stateRecord, key);
			srdSave.add('\t\t"$key": ' + Json.stringify(val));
			if (i < fields.length - 1) srdSave.add(",\n");
		}
		srdSave.add("\n\t},\n");

		// 2. frameRecord
		srdSave.add('\t"frameRecord": [\n');
		for (i in 0...frameData.length) {
			var frame = frameData[i];
			srdSave.add('\t\t{\n');
			srdSave.add('\t\t\t"time": ' + frame.time + ',\n');
			srdSave.add('\t\t\t"songSpeed": ' + frame.songSpeed + ',\n');
			srdSave.add('\t\t\t"playbackRate": ' + frame.playbackRate + ',\n');
			srdSave.add('\t\t\t"pressKey": ' + Json.stringify(frame.pressKey) + ',\n');
			srdSave.add('\t\t\t"releaseKey": ' + Json.stringify(frame.releaseKey) + '\n');
			srdSave.add('\t\t}');
			if (i < frameData.length - 1) srdSave.add(",\n");
		}
		srdSave.add('\n\t]\n');
		srdSave.add("}");

		var content:String = srdSave.toString();
		content = EncryptUtil.aesEncrypt(content);

		if (!FileSystem.exists("replays/"))
			FileSystem.createDirectory("replays/");

		var folder:String;

		if (Mods.currentModDirectory == '') {
			folder = "replays/originFunkin/";
			if (!FileSystem.exists(folder))
				FileSystem.createDirectory(folder);
		} else {
			folder = "replays/" + Mods.currentModDirectory + "/";
			if (!FileSystem.exists(folder))
				FileSystem.createDirectory(folder);
		}

		folder = folder + stateRecord.songName + "/";
		if (!FileSystem.exists(folder))
			FileSystem.createDirectory(folder);

		folder = folder + "/" + Difficulty.getString().toUpperCase() + "/";
		if (!FileSystem.exists(folder))
			FileSystem.createDirectory(folder);

		var fileName:String = stateRecord.playDate + ".rsd";
		fileName = StringTools.replace(fileName, " ", "-");
		fileName = StringTools.replace(fileName, ":", ".");
		fileName = StringTools.replace(fileName, "/", "");
		fileName = StringTools.replace(fileName, "\\", "");
		
		var path:String = folder + fileName;
		Replay.preparedPath = path;
		File.saveContent(path, content);
		
		// Save as TXT
		var txtSave:StringBuf = new StringBuf();
		
		txtSave.add('Song Name: ${stateRecord.songName}\n');
		txtSave.add('Difficulty: ${stateRecord.difficulty}\n');
		txtSave.add('Song Length: ${stateRecord.songLength}\n');
		txtSave.add('Date: ${stateRecord.playDate}\n');
		txtSave.add('Song Speed: ${stateRecord.songSpeed}\n');
		txtSave.add('Playback Rate: ${stateRecord.playbackRate}\n');
		txtSave.add('Health Gain: ${stateRecord.healthGain}\n');
		txtSave.add('Health Loss: ${stateRecord.healthLoss}\n');
		txtSave.add('CPU Controlled: ${stateRecord.cpuControlled}\n');
		txtSave.add('Practice Mode: ${stateRecord.practiceMode}\n');
		txtSave.add('Instakill On Miss: ${stateRecord.instakillOnMiss}\n');
		txtSave.add('Play Opponent: ${stateRecord.playOpponent}\n');
		txtSave.add('Flip Chart: ${stateRecord.flipChart}\n');
		txtSave.add('Score: ${stateRecord.songScore}\n');
		txtSave.add('Rating: ${stateRecord.ratingPercent} (${stateRecord.ratingFC})\n');
		txtSave.add('Hits: ${stateRecord.songHits}\n');
		txtSave.add('Highest Combo: ${stateRecord.highestCombo}\n');
		txtSave.add('Misses: ${stateRecord.songMisses}\n');
		
		var txtFileName:String = StringTools.replace(fileName, ".rsd", ".txt");
		var txtPath:String = folder + txtFileName;
		File.saveContent(txtPath, txtSave.toString());
		#end
	}
}
