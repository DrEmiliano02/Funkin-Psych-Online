import openfl.filters.BlurFilter;

var blurFilter:BlurFilter;

function onCreatePost() {
    blurFilter = new BlurFilter(0, 0);
    game.camGame.filters = [blurFilter];
    game.camHUD.filters = [blurFilter];
}

function onPause() {
    blurFilter.blurX = 20;
    blurFilter.blurY = 20;
    return Function_Continue;
}

function onResume()
    FlxTween.tween(blurFilter, {blurX: 0, blurY: 0}, 0.2, {ease: FlxEase.quartIn});