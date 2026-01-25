package backend;

import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.FlxGraphic;
import flixel.animation.FlxAnimationController;

import openfl.media.Sound;

class Cache {
    // define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];  //用于列举当前状态的所有资源（包括图形，声音）

    public static var currentTrackedAssets:Map<String, FlxGraphic> = []; //用于列举当前状态的所有图形资源

    public static var currentTrackedSounds:Map<String, Sound> = []; //用于列举当前状态的所有声音资源

	public static var currentTrackedFrames:Map<String, {graphic:FlxGraphic, frame:FlxFramesCollection}> = []; //用于列举当前状态的所有图形资源

	public static var currentTrackedAnims:Map<String, FlxAnimationController> = []; //用于列举当前状态的所有动画资源

    public static function excludeAsset(key:String)
	{
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> = [
		'assets/shared/music/freakyMenu.$Paths.SOUND_EXT',
		'assets/shared/music/breakfast.$Paths.SOUND_EXT',
		'assets/shared/music/tea-time.$Paths.SOUND_EXT',
	];

	public static function setFrame(key:String, data:{graphic:FlxGraphic, frame:FlxFramesCollection})
	{
		Cache.currentTrackedFrames.set(key, data);
	}

	public static function checkFrame(key:String):Bool
	{
		if (currentTrackedFrames.get(key) == null) return false;

		if (currentTrackedFrames.get(key).graphic != null
			&& currentTrackedFrames.get(key).graphic.imageFrame != null 
			&& currentTrackedFrames.get(key).graphic.imageFrame.frames != null 
			&& currentTrackedFrames.get(key).graphic.imageFrame.frames.length > 0) {
			return true;
		}

		if (currentTrackedFrames.get(key).frame != null 
			&& currentTrackedFrames.get(key).frame.frames != null 
			&& currentTrackedFrames.get(key).frame.frames.length > 0) {
			return true;
		}

		currentTrackedFrames.remove(key);
		return false;
	}

	public static function getFrame(key:String):FlxFramesCollection
	{
		if (currentTrackedFrames.get(key).frame != null) {
			return currentTrackedFrames.get(key).frame;
		} else if (currentTrackedFrames.get(key).graphic != null) {
			return currentTrackedFrames.get(key).graphic.imageFrame;
		}
		return null;
	}
}