package backend;

import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;

class MusicBeatState extends FlxUIState
{
	private var theWorld:Bool = false;

	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	public var controls(get, never):Controls;
	private function get_controls() return Controls.instance;

	public static var camBeat:FlxCamera;
	public static var timePassedOnState:Float = 0;

	override function create()
	{
		camBeat = FlxG.camera;
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		#if MODS_ALLOWED
		Mods.updatedOnState = false;
		#end

		super.create();

		if (!skip)
			openSubState(new CustomFadeTransition(0.7, true));

		FlxTransitionableState.skipNextTransOut = false;
		timePassedOnState = 0;
	}

	override function update(elapsed:Float)
	{
		if (theWorld)
		{
			super.update(elapsed);
			return;
		}

		var oldStep:Int = curStep;
		timePassedOnState += elapsed;

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
					updateSection();
				else
					rollbackSection();
			}
		}

		var saveData = FlxG.save.data;
		if (saveData != null) saveData.fullscreen = FlxG.fullscreen;

		stagesFunc(stage -> stage.update(elapsed));

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if (stepsToDo < 1)
			stepsToDo = Math.round(getBeatsOnSection(curSection) * 4);

		while (curStep >= stepsToDo)
		{
			curSection++;
			stepsToDo += Math.round(getBeatsOnSection(curSection) * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if (curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;

		var song = PlayState.SONG;
		if (song == null) return;

		var notes = song.notes;
		var len = notes.length;
		for (i in 0...len)
		{
			var section = notes[i];
			if (section != null)
			{
				stepsToDo += Math.round(getBeatsOnSection(i) * 4);
				if (stepsToDo > curStep) break;
				curSection++;
			}
		}

		if (curSection > lastSection)
			sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Std.int(curStep / 4);
		curDecBeat = curDecStep / 4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);
		var diff = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + diff;
		curStep = lastChange.stepTime + Std.int(diff);
	}

	override function startOutro(onOutroComplete:() -> Void):Void
	{
		if (!FlxTransitionableState.skipNextTransIn)
		{
			FlxG.state.openSubState(new CustomFadeTransition(0.6, false));
			CustomFadeTransition.finishCallback = onOutroComplete;
			return;
		}

		FlxTransitionableState.skipNextTransIn = false;
		onOutroComplete();
	}

	public static function getState():MusicBeatState
		return cast (FlxG.state, MusicBeatState);

	public function stepHit():Void
	{
		stagesFunc(stage -> {
			stage.curStep = curStep;
			stage.curDecStep = curDecStep;
			stage.stepHit();
		});

		if ((curStep & 3) == 0) // más rápido que %4
			beatHit();
	}

	public var stages:Array<BaseStage> = [];

	public function beatHit():Void
	{
		stagesFunc(stage -> {
			stage.curBeat = curBeat;
			stage.curDecBeat = curDecBeat;
			stage.beatHit();
		});
	}

	public function sectionHit():Void
	{
		stagesFunc(stage -> {
			stage.curSection = curSection;
			stage.sectionHit();
		});
	}

	inline function stagesFunc(func:BaseStage->Void)
	{
		for (stage in stages)
			if (stage != null && stage.exists && stage.active)
				func(stage);
	}

	inline function getBeatsOnSection(?sectionIndex:Int):Float
	{
		var song = PlayState.SONG;
		if (song != null && sectionIndex != null && song.notes[sectionIndex] != null)
		{
			var val = song.notes[sectionIndex].sectionBeats;
			return (val != null) ? val : 4;
		}
		return 4;
	}
}
