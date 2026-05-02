package general.backend.language;

class Language
{
	static var groups:Map<String, CustomLangGroup> = [];

	public static function get(value:String, type:String = 'options'):String
	{
		var group = groups.get(type);
		if (group != null)
			return group.get(value);
		return ClientPrefs.data.developerMode ? value + ' (404)' : value;
	}

	public static function resetData()
	{
		check();
		discoverGroups();
		for (group in groups)
			group.updateLang();
	}

	static function discoverGroups()
	{
		var basePath = Paths.getPath('language') + '/' + ClientPrefs.data.language;
		if (!FileSystem.isDirectory(basePath))
			return;

		for (entry in FileSystem.readDirectory(basePath))
		{
			if (FileSystem.isDirectory(basePath + '/' + entry))
			{
				if (!groups.exists(entry))
					groups.set(entry, new CustomLangGroup(entry));
			}
		}
	}

	public static function check()
	{
		if (!FileSystem.isDirectory(Paths.getPath('language') + '/' + ClientPrefs.data.language))
			ClientPrefs.data.language = 'English';
	}

	public static function setupData(follow:CustomLangGroup, directoryPath:Array<String>)
	{
		for (path in 0...directoryPath.length) {
			if (FileSystem.isDirectory(directoryPath[path])) {
				for (file in FileSystem.readDirectory(directoryPath[path])) {
					if (file.toLowerCase().endsWith('.lang')) {
						var outputData = CoolUtil.coolTextFile(directoryPath[path] + '/' + file);
						for (list in 0...outputData.length) {
							var line = outputData[list];
							if (line.length > 0 && line.indexOf(' => ') != -1) {
								var key:String = line.substr(0, line.indexOf(' => '));
								var value:String = line.substr(line.indexOf(' => ') + 4, line.length);
								if (path == 0)
									follow.defaultData.set(key, value);
								else
									follow.data.set(key, value);
							}
						}
					}
				}
			}
		}
	}
}
