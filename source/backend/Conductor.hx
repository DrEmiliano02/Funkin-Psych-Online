package backend;

typedef BPMChangeEvent = {
    var stepTime:Float;
    var songTime:Float;
    var bpm:Float;
    var stepCrochet:Float;
}

class Conductor
{
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

    public static var lastSongPos:Float = 0;
    public static var lastBpmChange:Null<BPMChangeEvent> = null;

    public function new()
    {
        // Constructor vacío si se necesita
    }

    public static function mapBPMChanges(song:Dynamic)
    {
        bpmChangeMap = [];
        bpm = song.bpm;

        var curStepTime:Float = 0;
        var curSongTime:Float = 0;

        bpmChangeMap.push({
            stepTime: curStepTime,
            songTime: curSongTime,
            bpm: bpm,
            stepCrochet: stepCrochet
        });

        if (song.notes != null)
        {
            for (section in song.notes)
            {
                if (section.changeBPM && section.bpm != bpm)
                {
                    bpm = section.bpm;
                    stepCrochet = ((60 / bpm) * 1000) / 4;

                    bpmChangeMap.push({
                        stepTime: curStepTime,
                        songTime: curSongTime,
                        bpm: bpm,
                        stepCrochet: stepCrochet
                    });
                }
                curStepTime += 16;
                curSongTime += 16 * stepCrochet;
            }
        }
    }

    public static function set_bpm(value:Float):Float
    {
        bpm = value;
        crochet = (60 / bpm) * 1000;
        stepCrochet = crochet / 4;
        return bpm;
    }

    public static function getBPMFromSeconds(time:Float):Float
    {
        var lastChange:BPMChangeEvent = defaultChange;
        for (change in bpmChangeMap)
        {
            if (time >= change.songTime) lastChange = change;
        }
        return lastChange.bpm;
    }
}
