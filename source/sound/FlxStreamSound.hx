package sound;

import openfl.media.SoundChannel;
import flixel.system.FlxAssets.FlxSoundAsset;
#if hxvlc
import hxvlc.openfl.Video;
import hxvlc.util.Handle;
#end

class FlxStreamSound extends FlxSound
{
	#if hxvlc
	private var _vlcPlayer:Video;
	private var _onVLC:Bool = false;
	#end

	public function new()
	{
		super();
		#if hxvlc
		_initVlc();
		#end
	}

	#if hxvlc
	private function _initVlc():Void
	{
		if (_vlcPlayer != null) return;

		try {
			Handle.init();
			_vlcPlayer = new Video();
			_vlcPlayer.visible = false;
			
			// 绑定事件
			_vlcPlayer.onEndReached.add(function() {
				if (_onVLC) stopped();
			});
			_vlcPlayer.onEncounteredError.add(function(_) {
				if (_onVLC) cleanup(true);
			});
			_vlcPlayer.onOpening.add(function() {
				if (_vlcPlayer.videoTrack != -1) _vlcPlayer.videoTrack = -1;
			});
		} catch (e:Dynamic) {
			FlxG.log.warn("FlxStreamSound: VLC init failed (will retry on load): " + e);
		}
	}
	#end

	override public function loadStream(SoundURL:String, Looped:Bool = false, AutoDestroy:Bool = false, ?OnComplete:Void->Void, ?OnLoad:Void->Void):FlxSound
	{
		#if hxvlc
		_onVLC = true;
		cleanup(true);
		init(Looped, AutoDestroy, OnComplete);
		
		_initVlc();
		
		if (_vlcPlayer != null && _vlcPlayer.load(SoundURL))
		{
			_vlcPlayer.videoTrack = -1;
			if (OnLoad != null) OnLoad();
		}
		else 
		{
			FlxG.log.error("FlxStreamSound: Failed to load VLC stream (Player is null or Load failed): " + SoundURL);
		}
		return this;
		#else
		return super.loadStream(SoundURL, Looped, AutoDestroy, OnComplete, OnLoad);
		#end
	}

	override public function loadEmbedded(EmbeddedSound:FlxSoundAsset, Looped:Bool = false, AutoDestroy:Bool = false, ?OnComplete:Void->Void):FlxSound
	{
		#if hxvlc
		_onVLC = false;
		cleanup(true);
		if (_vlcPlayer != null)
		{
			_vlcPlayer.dispose();
			_vlcPlayer = null;
		}
		#end
		return super.loadEmbedded(EmbeddedSound, Looped, AutoDestroy, OnComplete);
	}

	override public function play(ForceRestart:Bool = false, StartTime:Float = 0.0, ?EndTime:Float):FlxSound
	{
		#if hxvlc
		if (!_onVLC) return super.play(ForceRestart, StartTime, EndTime);

		if (!exists) return this;
		if (ForceRestart) cleanup(false, true);
		else if (playing) return this;

		if (_paused)
		{
			resume();
		}
		else if (_vlcPlayer != null)
		{
			_vlcPlayer.play();
			if (StartTime > 0) _vlcPlayer.time = Std.int(StartTime);
			_paused = false;
			_channel = @:privateAccess new SoundChannel(null, null, null);
		}
		endTime = EndTime;
		return this;
		#else
		return super.play(ForceRestart, StartTime, EndTime);
		#end
	}

	override public function pause():FlxSound
	{
		#if hxvlc
		if (!_onVLC) return super.pause();

		if (_vlcPlayer != null && _vlcPlayer.isPlaying)
		{
			_vlcPlayer.pause();
			_paused = true;
		}
		return this;
		#else
		return super.pause();
		#end
	}

	override public function resume():FlxSound
	{
		#if hxvlc
		if (!_onVLC) return super.resume();

		if (_paused && _vlcPlayer != null)
		{
			_vlcPlayer.resume();
			_paused = false;
		}
		return this;
		#else
		return super.resume();
		#end
	}

	override function updateTransform():Void
	{
		super.updateTransform();
		#if hxvlc
		if (_vlcPlayer != null && _onVLC)
		{
			_vlcPlayer.volume = Std.int(_transform.volume * 100);
		}
		#end
	}

	override public function update(elapsed:Float):Void
	{
		#if hxvlc
		if (!_onVLC)
		{
			super.update(elapsed);
			return;
		}

		if (_vlcPlayer != null && _vlcPlayer.isPlaying)
		{
			if (_channel == null) 
				_channel = @:privateAccess new SoundChannel(null, null, null);
			
			_time = cast _vlcPlayer.time;
			_length = cast _vlcPlayer.length;
		}
		
		if (endTime != null && _time >= endTime)
		{
			stopped();
		}
		#else
		super.update(elapsed);
		#end
	}

	#if hxvlc
	override function cleanup(destroySound:Bool, resetPosition:Bool = true):Void
	{
		if (_vlcPlayer != null) 
		{
			try { _vlcPlayer.stop(); } catch(e:Dynamic) {}
		}

		super.cleanup(destroySound, resetPosition);
	}

	override public function destroy():Void
	{
		if (_vlcPlayer != null)
		{
			_vlcPlayer.dispose();
			_vlcPlayer = null;
		}
		super.destroy();
	}
	#end
}
