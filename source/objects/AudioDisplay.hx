package objects;

import flixel.sound.FlxSound;
import funkin.vis.dsp.SpectralAnalyzer;
import funkin.vis.dsp.SpectralAnalyzer.Bar;

import shapeEx.Rect;

class AudioDisplay extends FlxSpriteGroup
{
	var analyzer:SpectralAnalyzer;

	public var snd:FlxSound;
	
	public var inRelax:Bool = false;

	var _height:Int;
	var line:Int;

	public var symmetry:Bool = false;

	public function new(snd:FlxSound = null, X:Float = 0, Y:Float = 0, Width:Int, Height:Int, line:Int, gap:Int, Color:FlxColor, symmetry:Bool = false)
	{
		super(X, Y);

		this.snd = snd;
		this.line = line;
		this.symmetry = symmetry;

		for (i in 0...line)
		{
			var newLine = new FlxSprite().makeGraphic(Std.int(Width / line - gap), 1, Color);
			newLine.x = (Width / line) * i;
			add(newLine);
		}

		_height = Height;
		@:privateAccess
		if (snd != null)
		{
		    if(!inRelax){
    			analyzer = new SpectralAnalyzer(snd._channel.__audioSource, line, 1, 5);
    			analyzer.fftN = 256 * ClientPrefs.data.audioDisplayQuality;
    		}else{
    		    analyzer = new SpectralAnalyzer(snd._channel.__audioSource, line, 1, 5);
    			analyzer.fftN = 256 * ClientPrefs.data.RelaxAudioDisplayQuality;
    		}
		}
	}

	public var stopUpdate:Bool = false;
	
	public var amplitude:Float = 0;

	var saveTime:Float = 0;
	var getValues:Array<Bar>;

	override function update(elapsed:Float)
	{
		if (stopUpdate)
			return;

		if (saveTime < ClientPrefs.data.audioDisplayUpdate)
		{
			saveTime += (elapsed * 1000);

			updateLine(elapsed);
			return;
		}
		else
		{
			saveTime = 0;
		}

		getValues = analyzer.getLevels();
		updateLine(elapsed);
		
		var Helpamplitude:Float = 0;
		
		for (i in 0...5) {
		    Helpamplitude += getValues[i].value;
		}
		
		amplitude = Helpamplitude / 5;

		super.update(elapsed);
	}

	function addAnalyzer(snd:FlxSound)
	{
		@:privateAccess
		if (snd != null && analyzer == null)
		{
			analyzer = new SpectralAnalyzer(snd._channel.__audioSource,line, 1, 5);
			analyzer.fftN = 256 * ClientPrefs.data.audioDisplayQuality;
		}
	}

	var animFrame:Int = 0;

	function updateLine(elapsed:Float)
	{
		if (getValues == null)
			return;

		for (i in 0...members.length)
		{
			if (i >= members.length / 2 && symmetry)
			{
				animFrame = Math.round(getValues[members.length - 1 - i].value * _height);
			}
			else
			{
				animFrame = Math.round(getValues[i].value * _height);
			}

			animFrame = Math.round(animFrame * FlxG.sound.volume);

			members[i].scale.y = FlxMath.lerp(animFrame, members[i].scale.y, Math.exp(-elapsed * 16));
			if (members[i].scale.y < _height / 40)
				members[i].scale.y = _height / 40;
			
			members[i].y = this.y - members[i].scale.y / 2;
		}
	}

	public function changeAnalyzer(snd:FlxSound)
	{
		@:privateAccess
		analyzer.changeSnd(snd._channel.__audioSource);

		stopUpdate = false;
	}

	public function clearUpdate()
	{
		for (i in 0...members.length)
		{
			members[i].scale.y = _height / 40;
			members[i].y = this.y - members[i].scale.y / 2;
		}
	}
}