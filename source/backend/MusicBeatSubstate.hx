package backend;

import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return Controls.instance;

	override function update(elapsed:Float)
	{
		if (!persistentUpdate)
			MusicBeatState.timePassedOnState += elapsed;

		var oldStep:Int = curStep;
		updateCurStep();

		if (oldStep != curStep)
		{
			updateBeat();

			if (curStep > 0)
				stepHit();

			var song = PlayState.SONG;
			if (song != null)
			{
				if (oldStep < curStep)
					updateSection(song);
				else
					rollbackSection(song);
			}
		}

		super.update(elapsed);
	}

	private function updateSection(song:Dynamic):Void
	{
		if (stepsToDo < 1)
			stepsToDo = Math.round(getBeatsOnSection(song, curSection) * 4);

		while (curStep >= stepsToDo)
		{
			curSection++;
			stepsToDo += Math.round(getBeatsOnSection(song, curSection) * 4);
			sectionHit();
		}
	}

	private function rollbackSection(song:Dynamic):Void
	{
		if (curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;

		var notes = song.notes;
		var len = notes.length;
		for (i in 0...len)
		{
			var section = notes[i];
			if (section != null)
			{
				stepsToDo += Math.round(getBeatsOnSection(song, i) * 4);
				if (stepsToDo > curStep) break;
				curSection++;
			}
		}

		if (curSection > lastSection)
			sectionHit();
	}

	private inline function updateBeat():Void
	{
		curBeat = Std.int(curStep / 4);
		curDecBeat = curDecStep / 4;
	}

	private function updateCurStep():Void
	{
		var songPos = Conductor.songPosition;
		var offset = ClientPrefs.data.noteOffset;
		var lastChange = Conductor.getBPMFromSeconds(songPos);

		var diff = ((songPos - offset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + diff;
		curStep = lastChange.stepTime + Std.int(diff);
	}

	public function stepHit():Void
	{
		if ((curStep & 3) == 0) // más rápido que %4
			beatHit();
	}

	public function beatHit():Void
	{
		// intentionally empty
	}

	public function sectionHit():Void
	{
		// intentionally empty
	}

	private inline function getBeatsOnSection(song:Dynamic, sectionIndex:Int):Float
	{
		if (song != null && song.notes[sectionIndex] != null)
		{
			var val = song.notes[sectionIndex].sectionBeats;
			return (val != null) ? val : 4;
		}
		return 4;
	}
}
