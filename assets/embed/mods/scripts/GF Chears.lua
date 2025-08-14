local lastCombo = 0
local cheerCombos = {25, 50, 100, 200, 600, 1000} -- List of combo milestones for cheering

function goodNoteHit()
    for _, milestone in ipairs(cheerCombos) do
        if combo == milestone then
            playAnim('gf', 'cheer', true)
            setProperty('gf.specialAnim', true)
            break
        end
    end

    lastCombo = combo
end
