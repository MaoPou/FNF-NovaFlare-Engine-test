package objects.state.optionState;

import objects.state.optionState.Option.OptionType;

class OptionCata extends FlxSpriteGroup
{
	public var mainX:Float;
	public var mainY:Float;

	public var heightSet:Float = 0;
	public var heightSetOffset:Float = 0; //用于特殊的高度处理

	public var modAdd:Bool = false;
	public var modsName:String;

	public var optionArray:Array<Option> = [];
	public var saveArray:Array<Option> = []; //用于保存最初所有的option

	public var bg:RoundRect;
	public var follow:NaviGroup;
	public var mem:NaviMember;

	public function new(X:Float, Y:Float, width:Float, height:Float)
	{
		super(X, Y);

		mainX = X;
		mainY = Y;

		bg = new RoundRect(0, 0, width, height, width / 75, LEFT_UP, OptionsState.instance.mainColor);
		bg.alpha = 0.75;
		bg.mainX = mainX;
		bg.mainY = mainY;
		add(bg);
	}

	public function addOption(tar:Option, sameY:Bool = false) {
		var putX:Float = this.width / 2 / 50;
		var putY:Float = heightSet;
		if (sameY) {
			putX += (this.width - this.width / 2 / 50) / 2;
			putY -= optionArray[optionArray.length - 1].saveHeight;
		}
		tar.sameY = sameY; //用于string展开的时候兼容
		add(tar);

		var specX:Float = 0;
		switch (tar.type)
		{
			case STRING:
				if (sameY)
					specX = (this.width - this.width / 2 / 50) / 2;
			default:
		}

		tar.initX(mainX, putX, specX);
		tar.initY(mainY, putY);

		optionArray.push(tar);
		saveArray.push(tar);

		if (!sameY) heightSet += tar.saveHeight;
	}

	override function update(elapsed:Float)
	{
		mainX = this.x;
		mainY = this.y;
		bg.mainX = mainX;
		bg.mainY = mainY;

		super.update(elapsed);

		
		if (checkPoint()) {
			mem.cataChoose = true;
		} else {
			mem.cataChoose = false;
		}
	}

	public function resetData() {
		for (option in optionArray)
			option.resetData();
	}

	public function changeLanguage() {
		for (option in optionArray) {
			option.changeLanguage();
		}
	}

	var addOptions:Array<Option> = [];
	var removeOptions:Array<Option> = [];
	public function startSearch(text:String, time = 0.6) {
		addOptions = [];
		removeOptions = [];
		for (i in 0...saveArray.length) {
			addOptions.push(saveArray[i]);
		}
		if (text != "") {
			for (option in saveArray) {
				if (!option.startSearch(text)) {
					addOptions.remove(option);
					removeOptions.push(option);
				}
			}
		}
		changeOption(time);
	}

	function changeOption(time = 0.6) {
		for (option in addOptions) {
			option.allowUpdate = true;
			option.changeAlpha(true, time);
		}
		for (option in removeOptions) {
			option.allowUpdate = false;
			option.changeAlpha(false, time);
		}
	}

	public function optionAdjust(str:Option, outputData:Float, time:Float = 0.45) {
		var start:Int = -1;
		for (op in 0...optionArray.length) {
			if (str == optionArray[op]) {
				start = op;
				if (start != (optionArray.length - 1) && str.type == STRING && !str.sameY && optionArray[start + 1].sameY)
					start++;
			}

			if (start != -1 && op > start) { 
				optionArray[op].changeOffY(outputData, time);
			}
		}
		heightSetOffset += outputData;

		changeHeight(time);
		OptionsState.instance.cataMoveChange();
	}

	public function peerCheck(str:Option):Bool {
		for (op in 0...optionArray.length) {
			if (str == optionArray[op]) {
				if (optionArray[op].sameY) {
					if (optionArray[op - 1].type == STRING && optionArray[op - 1].select.isOpend) {
						return false;
						break;
					}
				} else {
					if (op != optionArray.length - 1 && optionArray[op + 1].type == STRING && optionArray[op + 1].select.isOpend) {
						return false;
						break;
					}
				}
			}
		}

		return true;
	}

	public function changeHeight(time:Float = 0.6) {
		bg.changeHeight(heightSet + heightSetOffset, time, 'expoInOut');
	}

	public function checkPoint():Bool {
		if (this.y < FlxG.height / 2 && this.y + bg.realHeight > FlxG.height / 2) return true;
		return false;
	}
}