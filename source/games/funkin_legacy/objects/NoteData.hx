package games.funkin_legacy.objects;

import flixel.FlxCamera;

@:structInit
class NoteData
{
	public var strumTime:Float;
	public var noteData:Int;
	public var mustPress:Bool;

	public var multAlpha:Float = 1;
	public var multSpeed:Float = 1;
	public var camera:FlxCamera;
	public var cameras:Array<FlxCamera>;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offset(default, null):FlxPoint;
	public var offsetAngle:Float = 0;
	public var angle:Float = 0;
	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0;
	public var ratingDisabled:Bool = false;
	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var noAnimation:Bool = false;
	public var noMissAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var lowPriority:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitsoundDisabled:Bool = false;
	
	public var earlyHitMult:Float = 1;
	public var lateHitMult:Float = 1;

	public var wasGoodHit:Bool = false;
	public var missed:Bool = false;
	public var tooLate:Bool = false;
	public var canBeHit:Bool = false;
	public var blockHit:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var spawned:Bool = false;
	public var killTail:Bool = false;

	public var scaleX:Float = 1;
	public var scaleY:Float = 1;

	public var noteType:String = null;
	public var isSustainNote:Bool = false;
	public var sustainLength:Float = 0;
	public var gfNote:Bool = false;

	public var texture:String = null;
	public var skinPostfix:String = "";
	public var animSuffix:String = "";

	public var parentData:NoteData = null; // Store reference to parent NoteData
	public var tail:Array<NoteData> = [];
	public var prevData:NoteData = null;

	public var extraParams:Map<String, Dynamic> = new Map<String, Dynamic>();

	public function new(strumTime:Float, noteData:Int, ?prevNote:NoteData, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		this.strumTime = strumTime;
		this.noteData = noteData;
		this.isSustainNote = sustainNote;

		offset = FlxPoint.get();
	}
}
