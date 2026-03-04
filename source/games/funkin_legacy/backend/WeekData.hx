package games.funkin_legacy.backend;

import haxe.Json;

import openfl.utils.Assets as OpenFlAssets;

typedef WeekFile =
{
	// JSON variables
	var songs:Array<Dynamic>;
	var weekCharacters:Array<String>;
	var weekBackground:String;
	var weekBefore:String;
	var storyName:String;
	var weekName:String;
	var freeplayColor:Array<Int>;
	var startUnlocked:Bool;
	var hiddenUntilUnlocked:Bool;
	var hideStoryMode:Bool;
	var hideFreeplay:Bool;
	var difficulties:String;
}

class WeekData
{
	public static var weeksLoaded:Map<String, WeekData> = new Map<String, WeekData>();
	public static var weeksList:Array<String> = [];

	public var folder:String = '';

	// JSON variables
	public var songs:Array<Dynamic>;
	public var weekCharacters:Array<String>;
	public var weekBackground:String;
	public var weekBefore:String;
	public var storyName:String;
	public var weekName:String;
	public var freeplayColor:Array<Int>;
	public var startUnlocked:Bool;
	public var hiddenUntilUnlocked:Bool;
	public var hideStoryMode:Bool;
	public var hideFreeplay:Bool;
	public var difficulties:String;

	public var fileName:String;

	public var fullName:String;

	public static function createWeekFile():WeekFile
	{
		var weekFile:WeekFile = {
			songs: [
				["Bopeebo", "dad", [146, 113, 253]],
				["Fresh", "dad", [146, 113, 253]],
				["Dad Battle", "dad", [146, 113, 253]]
			],
			weekCharacters: ['dad', 'bf', 'gf'],
			weekBackground: 'stage',
			weekBefore: 'tutorial',
			storyName: 'Your New Week',
			weekName: 'Custom Week',
			freeplayColor: [146, 113, 253],
			startUnlocked: true,
			hiddenUntilUnlocked: false,
			hideStoryMode: false,
			hideFreeplay: false,
			difficulties: ''
		};
		return weekFile;
	}

	// HELP: Is there any way to convert a WeekFile to WeekData without having to put all variables there manually? I'm kind of a noob in haxe lmao
	public function new(weekFile:WeekFile, fileName:String)
	{
		// here ya go - MiguelItsOut
		for (field in Reflect.fields(weekFile))
			if (Reflect.fields(this).contains(field)) // Reflect.hasField() won't fucking work :/
				Reflect.setProperty(this, field, Reflect.getProperty(weekFile, field));

		this.fileName = fileName;
	}

	public static function reloadWeekFiles(isStoryMode:Null<Bool> = false)
	{
		weeksList = [];
		weeksLoaded.clear();
		
		var originPath:Array<String> = [Paths.getSharedPath()];
		#if MODS_ALLOWED
		var modPath:Array<String> = [Paths.mods()];
		for (mod in Mods.parseList().enabled)
			modPath.push(Paths.mods(mod + '/'));
		#end
		
		var txtList:Array<String> = CoolUtil.coolTextFile(Paths.getSharedPath('weeks/weekList.txt'));
		for (path in 0...originPath.length)
		{
			for (i in 0...txtList.length)
			{
				var weekJson:String = originPath[path] + 'weeks/' + txtList[i] + '.json';
				if (!weeksLoaded.exists('origin-' + txtList[i]))
				{
					var jsonFile:WeekFile = getFile(weekJson);
					if (jsonFile != null)
					{
						var weekFile:WeekData = new WeekData(jsonFile, txtList[i]);
						weekFile.fullName = 'origin-' + txtList[i];

						if (weekFile != null
							&& (isStoryMode == null
								|| (isStoryMode && !weekFile.hideStoryMode && !weekFile.hiddenUntilUnlocked)
								|| (!isStoryMode && !weekFile.hideFreeplay)))
						{
							weeksLoaded.set('origin-' + txtList[i], weekFile);
							weeksList.push('origin-' + txtList[i]);
						}
					}
				}
			}
		}

		#if MODS_ALLOWED
		for (i in 0...modPath.length)
		{
			var folderPath:String = modPath[i] + 'weeks/';
			if (FileSystem.exists(folderPath))
			{
				var listOfWeeks:Array<String> = CoolUtil.coolTextFile(folderPath + 'weekList.txt');
				for (daWeek in listOfWeeks)
				{
					var path:String = folderPath + daWeek + '.json';
					if (FileSystem.exists(path))
					{
						addWeek(daWeek, path, modPath[i], i);
					}
				}

				for (file in FileSystem.readDirectory(folderPath))
				{
					var path = haxe.io.Path.join([folderPath, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.json'))
					{
						addWeek(file.substr(0, file.length - 5), path, modPath[i], i);
					}
				}
			}
		}
		#end
	}

	private static function addWeek(weekName:String, filePath:String, modPath:String, i:Int)
	{
		var modName = modPath.substring(Paths.mods().length, modPath.length - 1);

		if (!weeksLoaded.exists(modName + '-' + weekName))
		{
			var week:WeekFile = getFile(filePath);
			if (week != null)
			{
				var weekFile:WeekData = new WeekData(week, weekName);
				weekFile.folder = modName;
				weekFile.fullName = modName + '-' + weekName;
				if ((PlayState.isStoryMode && !weekFile.hideStoryMode && !weekFile.hiddenUntilUnlocked) || (!PlayState.isStoryMode && !weekFile.hideFreeplay))
				{
					weeksLoaded.set(modName + '-' + weekName, weekFile);
					weeksList.push(modName + '-' + weekName);
				}
			}
		}
	}

	private static function getFile(path:String):WeekFile
	{
		var rawJson:String = null;
		#if MODS_ALLOWED
		if (FileSystem.exists(path))
		{
			rawJson = File.getContent(path);
		}
		#else
		if (OpenFlAssets.exists(path))
		{
			rawJson = OpenFlAssets.getText(path);
		}
		#end

		if (rawJson != null && rawJson.length > 0)
		{
			return cast tjson.TJSON.parse(rawJson);
		}
		return null;
	}

	//   FUNCTIONS YOU WILL PROBABLY NEVER NEED TO USE
	// To use on PlayState.hx or Highscore stuff
	public static function getWeekFileName():String
	{
		return weeksList[PlayState.storyWeek];
	}

	// Used on LoadingState, nothing really too relevant
	public static function getCurrentWeek():WeekData
	{
		return weeksLoaded.get(weeksList[PlayState.storyWeek]);
	}

	public static function setDirectoryFromWeek(?data:WeekData = null)
	{
		Mods.currentModDirectory = '';
		if (data != null && data.folder != null && data.folder.length > 0)
		{
			Mods.currentModDirectory = data.folder;
		}
	}
}
