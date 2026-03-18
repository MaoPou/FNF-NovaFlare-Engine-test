package games.funkin_legacy.backend;

import games.funkin_legacy.objects.Note;
import games.funkin_legacy.objects.NoteData;
import flixel.group.FlxGroup.FlxTypedGroup;

class NotePool
{
	// Key: "TextureName::Postfix::M{mania}::{NORMAL|SUSTAIN}"
	public static var pools:Map<String, FlxTypedGroup<Note>> = new Map<String, FlxTypedGroup<Note>>();
	public static var MAX_POOL_SIZE:Int = 100;

	// 缓存常用的 Key 以前缀形式，减少重复计算
	private static var _sb:StringBuf = new StringBuf();

	/**
	 * Get a Note object from the pool
	 * @param data Data from NoteData
	 */
	public static function get(data:NoteData):Note
	{
		// 1. Optimized Key Generation
		var texture = (data.texture == null || data.texture.length < 1) ? Note.defaultNoteSkin : data.texture;
		var postfix = (data.skinPostfix == null) ? '' : data.skinPostfix;
		
		_sb = new StringBuf();
		_sb.add(texture);
		_sb.add("::");
		_sb.add(postfix);
		_sb.add("::M");
		_sb.add((PlayState.SONG != null) ? PlayState.SONG.mania : 3);
		_sb.add(data.isSustainNote ? "::SUSTAIN" : "::NORMAL");
		
		var key = _sb.toString();

		// 2. Check/Create Pool
		var group = pools.get(key);
		if (group == null)
		{
			group = new FlxTypedGroup<Note>();
			pools.set(key, group);
		}

		// 3. Recycle
		var note:Note = group.getFirstAvailable(Note);
		
		// Validate recycled note
		if (note != null && note.scale == null) // Was destroyed improperly
		{
			group.remove(note, true);
			note = null;
		}

		if (note == null)
		{
			// Create new note
			// Note: We pass the correct texture info right away to avoid double-loading
			note = new Note(data.strumTime, data.noteData, null, data.isSustainNote);
			
			// Force texture if needed (constructor might use default)
			if (note.texture != texture) {
				note.reloadNote(texture, postfix);
			}
			
			note.poolKey = key;
			group.add(note);
		}

		// 4. Reset State
		// resetFromData handles texture reloading if data differs from current note state
		note.resetFromData(data);
		
		// Ensure pool key is correct (in case it was lost)
		note.poolKey = key;

		// 5. Finalize
		if (!data.isSustainNote) {
			note.setGraphicSize(Std.int(note.frameWidth * note.trackedScale));
			note.updateHitbox();
		}

		return note;
	}

	/**
	 * Return Note object to pool
	 */
	public static function returnNote(note:Note)
	{
		var key = note.poolKey;
		// Fallback key generation if missing
		if (key == null) {
			var texture = (note.texture == null) ? Note.defaultNoteSkin : note.texture;
			var postfix = Note.getNoteSkinPostfix(texture);
			
			_sb = new StringBuf();
			_sb.add(texture);
			_sb.add("::");
			_sb.add(postfix);
			_sb.add("::M");
			_sb.add((PlayState.SONG != null) ? PlayState.SONG.mania : 3);
			_sb.add(note.isSustainNote ? "::SUSTAIN" : "::NORMAL");
			key = _sb.toString();
		}

		var group = pools.get(key);
		if (group == null) {
			note.destroy();
			return;
		}

		// Cleanup logic
		if (group.countDead() > MAX_POOL_SIZE)
		{
			group.remove(note, true);
			note.destroy(); 
		}
		else
		{
			note.kill();
			note.visible = false;
			note.alpha = 0;
		}
	}

	/**
	 * clear the pool
	 */
	public static function clear()
	{
		for (group in pools)
		{
			// Safe cleanup
			while (group.members.length > 0) {
				var note = group.members.pop();
				if (note != null) note.destroy();
			}
			group.clear();
		}
		pools.clear();
	}
}
