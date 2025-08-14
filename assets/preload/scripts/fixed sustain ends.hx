function onCreatePost(){
    if(PlayState.isPixelStage){
        return;
    }
    for(note in unspawnNotes){
        if(StringTools.endsWith(note.animation.curAnim.name.toLowerCase(), "end")){
            note.scale.y = 0.7;
            note.updateHitbox();
            note.centerOffsets();
        }
    }
}