package general.backend.language;

class CustomLangGroup
{
	public var groupName:String;
	public var data:Map<String, String> = [];
	public var defaultData:Map<String, String> = [];

	public function new(groupName:String)
	{
		this.groupName = groupName;
	}

	public function get(value:String):String
	{
		if (data.get(value) != null)
			return data.get(value);
		else if (defaultData.get(value) != null)
			return defaultData.get(value);
		else
			return ClientPrefs.data.developerMode ? value + ' (404)' : value;
	}

	public function updateLang()
	{
		data.clear();
		defaultData.clear();

		var minorPath:String = '/' + groupName;
		var directoryPath:Array<String> = [Paths.getPath('language') + '/English' + minorPath];

		var path = Paths.getPath('language') + '/' + ClientPrefs.data.language + minorPath;
		if (FileSystem.isDirectory(path))
			directoryPath.push(path);

		Language.setupData(this, directoryPath);
	}
}
