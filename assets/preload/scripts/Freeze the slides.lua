function opponentNoteHit(i)
    setProperty('dad.animation.curAnim.paused', stringEndsWith(getProperty('notes.members['..i..'].animation.curAnim.name'), 'hold'))
end
function goodNoteHit(i)
    setProperty('boyfriend.animation.curAnim.paused', stringEndsWith(getProperty('notes.members['..i..'].animation.curAnim.name'), 'hold'))
end