--[[
| SIMPLE MINI INTRO v1.0 | [By LuaXdea] ^⁠_⁠^
    • [YouTube] = https://youtube.com/@lua-x-dea?si=r4OuzaxegTRuUUpD
    • | Versiones compatibles |
    | 0.6.3 | 0.7.1h | 0.7.2h |
    | 1.0-prerelease | 1.0 |
]]
-- | Opciones Básicas |
local songNameText = songName --[[ En caso de necesitarlo recuerda usar string = ''
    Ejemplo;
local songNameText = 'Dy-namix'

    [default songName]
    ]]
local CamIntroSong = 'camOther' -- Cámara dónde saldrá [default camOther]



-- No tocar nada (don't touch anything)
local objetosDecorativos = {}
local decorativoAncho = 20
local detenerAnimacion = false
function onCreate()
    makeLuaText('T1',songNameText or songName,nil,-200,210)
    setTextSize('T1',25)
    setProperty('T1.alpha',0)
    if version == '1.0' then
    setProperty('T1.camera',instanceArg(CamIntroSong or 'camOther'),false,true)
    else
    setObjectCamera('T1',CamIntroSong or 'camOther')
    end
    addLuaText('T1')
    local textoAncho = getTextWidth('T1')
    local decorativoRangoX = math.ceil(textoAncho / 20) * 20
    local numCuadros = math.floor(decorativoRangoX / decorativoAncho)
    for i = 1,numCuadros do
        local square = 'Square'..i
        makeLuaSprite(square,nil,-50,210)
        makeGraphic(square,decorativoAncho, decorativoAncho,'FFFFFF')
        if version == '1.0' then
        setProperty(square..'.camera',instanceArg(CamIntroSong or 'camOther'),false,true)
        else
        setObjectCamera(square,CamIntroSong or 'camOther')
        end
        addLuaSprite(square)
        table.insert(objetosDecorativos,square)
    end
    makeLuaSprite('BgSong',nil,-300,200)
    makeGraphic('BgSong',decorativoRangoX,50,'000000')
    setProperty('BgSong.alpha',0)
    if version == '1.0' then
    setProperty('BgSong.camera',instanceArg(CamIntroSong or 'camOther'),false,true)
    else
    setObjectCamera('BgSong',CamIntroSong or 'camOther')
    end
    addLuaSprite('BgSong')
    for _,square in ipairs(objetosDecorativos) do
        setObjectOrder(square,getObjectOrder('BgSong') - 1)
    end
    setObjectOrder('BgSong',getObjectOrder('T1') - 1)
    setObjectOrder('T1',getObjectOrder('T1') + 1)
end
-- | Versiones compatibles |
local compatibleVersions = {
    ['0.6.3'] = true,
    ['0.7.1h'] = true,
    ['0.7.2h'] = true,
    ['1.0-prerelease'] = true,
    ['1.0'] = true
}
function onSongStart()
    if not compatibleVersions[version] then
        debugPrint('Version not compatible with the script. Please use one of these Psych Engine versions: [ 0.6.3 | 0.7.1h | 0.7.2h | 1.0-Pre | 1.0 ]','FF0000')
        debugPrint('Versión no compatible con el script. Por favor use una de estas versiones de Psych Engine: [ 0.6.3 | 0.7.1h | 0.7.2h | 1.0-Pre | 1.0 ]','FF0000')
    end
    for _,obj in ipairs({'BgSong','T1'}) do
        doTweenX(obj..'_Enter',obj,0,0.5,'quadOut')
        doTweenAlpha(obj..'_Alpha',obj,1,0.5,'quadOut')
    end
    for i,square in ipairs(objetosDecorativos) do
        doTweenX(square..'_Enter',square,(i - 1) * decorativoAncho,0.7,'quadOut')
        animarCuadro(square)
    end
    runTimer('IntroOut',4.5)
end
function animarCuadro(square)
    if not detenerAnimacion then
        local nuevaEscala = math.random(4,5)
        doTweenY(square..'_ScaleUp',square..'.scale',nuevaEscala,0.5 + math.random() * 0.5,'sineInOut')
    end
end
function onTweenCompleted(t)
    if detenerAnimacion then return end
    for _,square in ipairs(objetosDecorativos) do
        if t == square..'_ScaleUp' then
            doTweenY(square..'_ScaleDown',square..'.scale',1,0.5 + math.random() * 0.5,'sineInOut')
        elseif t == square..'_ScaleDown' then
            animarCuadro(square)
        end
    end
end
function onTimerCompleted(t)
    if t == 'IntroOut' then
        detenerAnimacion = true
        for _,obj in ipairs({'BgSong','T1'}) do
            doTweenX(obj..'_ExitX',obj,-800,1,'quadIn')
            doTweenAlpha(obj..'_ExitAlpha',obj,0,1,'quadIn')
        end
        for _,square in ipairs(objetosDecorativos) do
            doTweenX(square..'_Exit',square,-200,0.5,'quadIn')
            doTweenAlpha(square..'_AlphaOut',square,0,0.5)
            doTweenY(square..'_ExitScale',square..'.scale',0.01,0.5)
        end
        runTimer('IntroRemove',1.2)
    elseif t == 'IntroRemove' then
        removeLuaSprite('BgSong',true)
        removeLuaText('T1',true)
        for _,square in ipairs(objetosDecorativos) do
            removeLuaSprite(square,true)
        end
    end
end
-- Simple (⁠*⁠_⁠*⁠)?