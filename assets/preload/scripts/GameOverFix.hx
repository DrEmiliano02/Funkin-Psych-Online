import substates.GameOverSubstate;
import objects.Character;
import flixel.FlxObject;

var inGameOver:Bool = false;
var camFollow:FlxObject;
var moveCamera:Bool = false;
var playingDeathSound:Bool = false;
var isEnding:Bool = false;


function onUpdatePost(elapsed:Float) {
    if (inGameOver && !GameOverSubstate.instance.boyfriend.isAnimationNull() && GameOverSubstate.instance.boyfriend.isAnimateAtlas) {
		if (GameOverSubstate.instance.boyfriend.getAnimationName() == 'firstDeath' && GameOverSubstate.instance.boyfriend.isAnimationFinished() && GameOverSubstate.instance.startedDeath)
		GameOverSubstate.instance.boyfriend.playAnim('deathLoop');

		if (GameOverSubstate.instance.boyfriend.getAnimationName() == 'firstDeath') {
			if(getAnimationFrame(GameOverSubstate.instance.boyfriend) >= 12 && !moveCamera) {
				FlxG.camera.follow(camFollow, null, 0.6); //idk using LOCKON
				moveCamera = true;
			}

			if (GameOverSubstate.instance.boyfriend.isAnimationFinished() && !playingDeathSound) {
				GameOverSubstate.instance.startedDeath = true;
				if (PlayState.SONG.stage == 'tank') {
					playingDeathSound = true;
					coolStartDeath(0.2);

					FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25)), 1, false, null, true, function() {
						if (!isEnding) FlxG.sound.music.fadeIn(0.2, 1, 4);
					});
				} else {
					coolStartDeath(1);
				}
			}
		}
	}

  return;
}

function onGameOverStart() {
  inGameOver = true;

  camFollow = new FlxObject(0, 0, 1, 1);
  camFollow.setPosition(GameOverSubstate.instance.boyfriend.getGraphicMidpoint().x + GameOverSubstate.instance.boyfriend.cameraPosition[0], GameOverSubstate.instance.boyfriend.getGraphicMidpoint().y + GameOverSubstate.instance.boyfriend.cameraPosition[1]);
  add(camFollow);
}

function onGameOverConfirm() {
  isEnding = true;
}

function coolStartDeath(volume:Float = 1) {
  FlxG.sound.playMusic(Paths.music(GameOverSubstate.loopSoundName), volume);
}

function getAnimationFrame(char:Character) {
  if (char.isAnimationNull()) return;

  return !char.isAnimateAtlas ? char.animation.curAnim.curFrame : char.atlas.anim.curFrame;
}