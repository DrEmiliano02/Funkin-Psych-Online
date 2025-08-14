local holdBop = {p1 = false, p2 = false}
local bopScale = 1.15 -- tamaño máximo del bop
local bopSpeed = 8    -- velocidad de suavizado
local beatPulseSpeed = 4 -- velocidad del latido en nota larga
local beatPulseAmount = 0.05 -- amplitud del latido

function onCreatePost()
    setProperty('iconP1.antialiasing', true)
    setProperty('iconP2.antialiasing', true)
end

function onBeatHit()
    -- bop normal en cada beat
    doIconBop('p1')
    doIconBop('p2')
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if isSustainNote then
        holdBop.p1 = true
    else
        doIconBop('p1')
    end
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
    if isSustainNote then
        holdBop.p2 = true
    else
        doIconBop('p2')
    end
end

function noteMiss(id, direction, noteType, isSustainNote)
    if isSustainNote then
        holdBop.p1 = false
    end
end

function noteMissPress(direction)
    holdBop.p1 = false
end

function onUpdatePost(elapsed)
    local time = getSongPosition() / 1000

    -- bop continuo pero ahora con latido suave
    if holdBop.p1 then
        smoothBopWithPulse('iconP1', elapsed, time)
    else
        smoothReturn('iconP1', elapsed)
    end

    if holdBop.p2 then
        smoothBopWithPulse('iconP2', elapsed, time)
    else
        smoothReturn('iconP2', elapsed)
    end
end

-- bop inmediato en beats o notas normales
function doIconBop(which)
    local icon = (which == 'p1') and 'iconP1' or 'iconP2'
    setProperty(icon..'.scale.x', bopScale)
    setProperty(icon..'.scale.y', bopScale)
end

-- bop continuo con pulso tipo latido
function smoothBopWithPulse(icon, elapsed, time)
    local targetScale = bopScale + math.sin(time * beatPulseSpeed) * beatPulseAmount
    setProperty(icon..'.scale.x', lerp(getProperty(icon..'.scale.x'), targetScale, bopSpeed * elapsed))
    setProperty(icon..'.scale.y', lerp(getProperty(icon..'.scale.y'), targetScale, bopSpeed * elapsed))
end

-- volver suavemente al tamaño original
function smoothReturn(icon, elapsed)
    setProperty(icon..'.scale.x', lerp(getProperty(icon..'.scale.x'), 1, bopSpeed * elapsed))
    setProperty(icon..'.scale.y', lerp(getProperty(icon..'.scale.y'), 1, bopSpeed * elapsed))
end

function lerp(a, b, ratio)
    return a + ratio * (b - a)
end
