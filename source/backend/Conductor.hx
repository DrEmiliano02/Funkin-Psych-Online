class Conductor {
	public static var bpm(default, set):Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000);
	public static var stepCrochet:Float = crochet / 4;
	public static var songPosition:Float = 0;
	public static var judgeSongPosition:Null<Float> = null;
	public static var judgePlaybackRate:Null<Float> = null;
	public static var offset:Float = 0;
	public static var safeZoneOffset:Float = 0;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];
	static final defaultChange:BPMChangeEvent = {
		stepTime: 0,
		songTime: 0,
		bpm: bpm,
		stepCrochet: stepCrochet
	};

	public function new() {}

	public static function judgeNote(arr:Array<Rating>, diff:Float=0):Rating {
		for (i in 0...arr.length-1) {
			if (diff <= arr[i].hitWindow) return arr[i];
		}
		return arr[arr.length - 1];
	}

	public static inline function getCrotchetAtTime(time:Float){
		return getBPMFromSeconds(time).stepCrochet * 4;
	}

	// Búsqueda binaria optimizada
	public static function getBPMFromSeconds(time:Float){
		if (bpmChangeMap.length == 0) return defaultChange;

		var low = 0;
		var high = bpmChangeMap.length - 1;
		while (low <= high) {
			var mid = (low + high) >> 1;
			if (bpmChangeMap[mid].songTime <= time) low = mid + 1; else high = mid - 1;
		}
		return bpmChangeMap[Math.max(high, 0)];
	}

	public static function getBPMFromStep(step:Float){
		if (bpmChangeMap.length == 0) return defaultChange;

		var low = 0;
		var high = bpmChangeMap.length - 1;
		while (low <= high) {
			var mid = (low + high) >> 1;
			if (bpmChangeMap[mid].stepTime <= step) low = mid + 1; else high = mid - 1;
		}
		return bpmChangeMap[Math.max(high, 0)];
	}

	public static inline function beatToSeconds(beat:Float):Float {
		var step = beat * 4;
		var lastChange = getBPMFromStep(step);
		return lastChange.songTime + ((step - lastChange.stepTime) * lastChange.stepCrochet);
	}

	public static inline function getStep(time:Float){
		var lastChange = getBPMFromSeconds(time);
		return lastChange.stepTime + (time - lastChange.songTime) / lastChange.stepCrochet;
	}

	public static inline function getStepRounded(time:Float){
		var lastChange = getBPMFromSeconds(time);
		return lastChange.stepTime + Math.floor(time - lastChange.songTime) / lastChange.stepCrochet;
	}

	public static inline function getBeat(time:Float){
		return getStep(time) / 4;
	}

	public static inline function getBeatRounded(time:Float):Int{
		return Math.floor(getStepRounded(time) / 4);
	}

	public static function mapBPMChanges(song:SwagSong) {
		bpmChangeMap = [];
		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		var msPerStep = (60 / curBPM) * 1000 / 4;

		for (i in 0...song.notes.length) {
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM) {
				curBPM = song.notes[i].bpm;
				msPerStep = (60 / curBPM) * 1000 / 4;
				bpmChangeMap.push({
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM,
					stepCrochet: msPerStep
				});
			}
			var deltaSteps = Math.round(getSectionBeats(song, i) * 4);
			totalSteps += deltaSteps;
			totalPos += msPerStep * deltaSteps;
		}
	}

	static inline function getSectionBeats(song:SwagSong, section:Int) {
		return song.notes[section]?.sectionBeats ?? 4;
	}

	public static inline function calculateCrochet(bpm:Float) {
		return (60 / bpm) * 1000;
	}

	public static function set_bpm(newBPM:Float):Float {
		bpm = newBPM;
		crochet = calculateCrochet(bpm);
		stepCrochet = crochet / 4;
		return bpm;
	}
}
