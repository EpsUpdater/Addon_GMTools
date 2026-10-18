-- ============================================================
-- GMTools.lua
-- Addon principal
-- ============================================================

-- ════════════════════════════════════════════════════════════
-- COMANDOS DE CHAT — registrado primero para que /gm funcione
-- aunque falle la creación de la ventana
-- ════════════════════════════════════════════════════════════
SLASH_GMBASICTOOLS1 = "/gm"

SlashCmdList["GMBASICTOOLS"] = function()
    local ventana = GMToolsFrame
    local ventanaIzq = GMToolsFrameIzq
    if not ventana then
        return
    end
    if ventana:IsShown() then
        ventana:Hide()
        if ventanaIzq then ventanaIzq:Hide() end
        if GMToolsNPCFrame and GMToolsNPCFrame:IsShown() and GMToolsNPCToggle then
            GMToolsNPCToggle()
        end
        if GMToolsCerrarGobs then
            GMToolsCerrarGobs()
        end
        return
    end

    local l = ventana:GetLeft()
    local t = ventana:GetTop()
    local li = ventanaIzq and ventanaIzq:GetLeft() or l
    local ti = ventanaIzq and ventanaIzq:GetTop() or t
    local pw, ph = UIParent:GetWidth(), UIParent:GetHeight()
    if not l or not t or not li or not ti or l < -50 or t < -50 or l + ventana:GetWidth() > pw + 50 or t + ventana:GetHeight() > ph + 50 or li < -50 or ti < -50 or li + (ventanaIzq and ventanaIzq:GetWidth() or 0) > pw + 50 or ti + (ventanaIzq and ventanaIzq:GetHeight() or 0) > ph + 50 then
        if GMToolsAnclarVentana then GMToolsAnclarVentana() end
    end
    ventana:Show()
    if ventanaIzq then ventanaIzq:Show() end
end

local ok, err = pcall(function()

-- Estado de la casilla "Pestaña siempre activa" (engranaje), por
-- personaje. Se guarda en DOS sitios para que funcione en este cliente:
--  1) SV por personaje (SavedVariablesPerCharacter) — se escribe al
--     cerrar sesión.
--  2) Un CVar con el nombre del personaje — la tabla de CVars vive en
--     memoria y sobrevive a /reload; al salir se vuelca a Config.wtf.
-- Estado de la casilla "Pestaña siempre activa" (engranaje), por
-- personaje. Fuente principal: un CVar por personaje que vive en
-- memoria del cliente y sobrevive a /reload sin volcarse a disco.
-- La SV (SavedVariablesPerCharacter, se escribe al cerrar sesión)
-- queda de respaldo y refleja siempre lo mismo.
GMToolsMecanicoDB = GMToolsMecanicoDB or {}
local charSiempre = (UnitName("player") or "anonimo")
local function cvarSiempre()
    return "gmToolsSiempre_" .. charSiempre
end
local cvSiempre = GetCVar(cvarSiempre())
if cvSiempre == "1" or cvSiempre == "0" then
    -- Reload dentro de la misma sesión: manda la memoria.
    GMToolsMecanicoDB.siempreActiva = (cvSiempre == "1")
else
    -- Sesión nueva sin CVar: usa la SV guardada al salir la última vez.
    GMToolsMecanicoDB.siempreActiva = (GMToolsMecanicoDB.siempreActiva == true)
end

local function guardarCVar()
    local nombre = cvarSiempre()
    local valor = GMToolsMecanicoDB.siempreActiva and "1" or "0"
    local okCvar = pcall(SetCVar, nombre, valor)
    local okCons = pcall(function()
        if C_Console and C_Console.Execute then
            C_Console.Execute("set " .. nombre .. " " .. valor)
        end
    end)
    return okCvar, okCons
end

local WIN_W = 668
local WIN_H = 52

-- ════════════════════════════════════════════════════════════
-- HELPER: PANEL OSCURO
-- ════════════════════════════════════════════════════════════
local function ApplyDarkPanel(frame)
    frame:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    frame:SetBackdropColor(0.12, 0.18, 0.40, 0.25)
    frame:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
end

-- ════════════════════════════════════════════════════════════
-- VENTANA PRINCIPAL (la de la DERECHA, la que tiene la X):
-- conserva el NOMBRE original (GMToolsFrame), el ancho original
-- (668) y el ancla original (sobre la barra de acciones). Así
-- TODAS las demás ventanas del addon siguen anclándose a ella
-- exactamente igual que antes, sin tocar nada más.
-- A su izquierda se pega la NUEVA GMToolsFrameIzq con los 5
-- primeros botones + su subventana; ambas van siempre juntas.
-- ════════════════════════════════════════════════════════════
local ventana = CreateFrame("Frame", "GMToolsFrame", UIParent, "BackdropTemplate")
ventana:SetSize(487, WIN_H)
-- La IZQUIERDA empieza COLAPSADA (alto de la derecha): solo la
-- fila 1 (4 botones). Al pasar el ratón se expande hacia arriba
-- hasta IZQ_ALTO_EXPANDIDA mostrando las 2 filas.
local ventanaIzq = CreateFrame("Frame", "GMToolsFrameIzq", UIParent, "BackdropTemplate")
ventanaIzq:SetSize(181, WIN_H)
ventanaIzq:SetClipsChildren(true)
local xBarra = -2
local yBarra = 53

local function anclarVentana()
    ventana:ClearAllPoints()
    ventanaIzq:ClearAllPoints()
    local barraRef = MultiBarBottomRight or MultiBarBottomLeft
    if barraRef then
        ventana:SetPoint("BOTTOMRIGHT", barraRef, "TOPRIGHT", xBarra, yBarra)
    else
        ventana:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -80, -80)
    end
    ventanaIzq:SetPoint("BOTTOMRIGHT", ventana, "BOTTOMLEFT", -2, 0)
end
GMToolsAnclarVentana = anclarVentana
anclarVentana()
ApplyDarkPanel(ventana)
ApplyDarkPanel(ventanaIzq)
ventana:EnableMouse(true)
ventana:SetMovable(true)
ventana:SetClampedToScreen(true)
ventana:RegisterForDrag("LeftButton")
ventana:SetScript("OnDragStart", ventana.StartMoving)
ventana:SetScript("OnDragStop",  ventana.StopMovingOrSizing)
-- Arrastrar la IZQUIERDA mueve la DERECHA (raíz del ancla): así
-- ambas van siempre juntas y nunca se separan.
ventanaIzq:EnableMouse(true)
ventanaIzq:RegisterForDrag("LeftButton")
ventanaIzq:SetScript("OnDragStart", function() ventana:StartMoving() end)
ventanaIzq:SetScript("OnDragStop",  function() ventana:StopMovingOrSizing() end)
ventana:Hide()
ventanaIzq:Hide()

-- ════════════════════════════════════════════════════════════
-- BOTÓN DE CIERRE (X) — arriba a la derecha (como siempre)
-- ════════════════════════════════════════════════════════════
local closeButton = CreateFrame("Button", nil, ventana)
closeButton:SetSize(18, 18)
closeButton:SetPoint("TOPRIGHT", ventana, "TOPRIGHT", -6, -5)
local closeBg = closeButton:CreateTexture(nil, "BACKGROUND")
closeBg:SetAllPoints()
closeBg:SetColorTexture(0.55, 0.1, 0.1, 0.85)
closeBg:Hide()
local closeX = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
closeX:SetAllPoints()
closeX:SetText("×")
closeX:SetTextColor(0.85, 0.3, 0.3)
closeButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
closeButton:SetScript("OnEnter", function() closeBg:Show() closeX:SetTextColor(1, 0.5, 0.5) end)
closeButton:SetScript("OnLeave", function() closeBg:Hide() closeX:SetTextColor(0.85, 0.3, 0.3) end)
closeButton:SetScript("OnClick", function()
    ventana:Hide()
    ventanaIzq:Hide()
end)

-- ════════════════════════════════════════════════════════════
-- BOTÓN DEBAJO DE LA X — icono pet_type_mechanical, mismo estilo
-- de resaltado que los botones de la barra.
-- ════════════════════════════════════════════════════════════
local btnMecanico = CreateFrame("Button", nil, ventana)
btnMecanico:SetSize(22, 22)
btnMecanico:SetPoint("TOPRIGHT", closeButton, "BOTTOMRIGHT", 2, -1)

local iconMecanico = btnMecanico:CreateTexture(nil, "BACKGROUND")
iconMecanico:SetSize(20, 20)
iconMecanico:SetPoint("CENTER")
iconMecanico:SetTexture("Interface\\Icons\\pet_type_mechanical")

-- Al poner el ratón encima: se ilumina el propio icono en amarillo
-- (solo sus partes opacas, como la flecha del slider de velocidad,
-- sin cuadrado de relleno sobre la parte transparente)
btnMecanico:SetHighlightTexture("Interface\\Icons\\pet_type_mechanical", "ADD")
local hlMecanico = btnMecanico:GetHighlightTexture()
if hlMecanico then
    hlMecanico:SetVertexColor(1, 1, 0)
    hlMecanico:ClearAllPoints()
    hlMecanico:SetAllPoints(iconMecanico)
end

GMToolsBtnMecanico = btnMecanico

-- ════════════════════════════════════════════════════════════
-- PESTAÑA QUE ABRE EL BOTÓN DE ENGRANAJE — caja con un check
-- "siempre activa" (se guarda a nivel de cuenta).
-- ════════════════════════════════════════════════════════════
local tabMecanica = CreateFrame("Frame", "GMToolsMecanicaFrame", ventana, "BackdropTemplate")
tabMecanica:SetSize(250, 75)
tabMecanica:SetPoint("BOTTOMRIGHT", ventana, "TOPRIGHT", 0, 3)
ApplyDarkPanel(tabMecanica)
tabMecanica:Hide()

local textVersion = tabMecanica:CreateFontString(nil, "OVERLAY")
textVersion:SetFont("Fonts\\FRIZQT__.TTF", 13)
textVersion:SetPoint("TOP", tabMecanica, "TOP", -75, -15)
textVersion:SetTextColor(1, 0.82, 0)
local function leerVersionToc()
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        local ok, v = pcall(C_AddOns.GetAddOnMetadata, "GMTools", "Version")
        if ok and v and v ~= "" then return v end
    end
    if GetAddOnMetadata then
        local ok, v = pcall(GetAddOnMetadata, "GMTools", "Version")
        if ok and v and v ~= "" then return v end
    end
    return "?"
end
textVersion:SetText("Versión " .. leerVersionToc())

local btnCheckSiempre = CreateFrame("Button", nil, tabMecanica, "BackdropTemplate")
btnCheckSiempre:SetSize(18, 18)
btnCheckSiempre:SetPoint("LEFT", tabMecanica, "BOTTOMLEFT", 14, 25)
btnCheckSiempre:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true, tileSize = 8, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
btnCheckSiempre:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
btnCheckSiempre:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.9)
btnCheckSiempre:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
local hlCheckSiempre = btnCheckSiempre:GetHighlightTexture()
if hlCheckSiempre then hlCheckSiempre:SetAlpha(0.3) end
local marcaCheckSiempre = btnCheckSiempre:CreateFontString(nil, "OVERLAY")
marcaCheckSiempre:SetFont("Fonts\\FRIZQT__.TTF", 16)
marcaCheckSiempre:SetPoint("CENTER", -0.5, -0.5)
marcaCheckSiempre:SetTextColor(1, 1, 1)

local textSiempre1 = tabMecanica:CreateFontString(nil, "OVERLAY")
textSiempre1:SetFont("Fonts\\FRIZQT__.TTF", 12)
textSiempre1:SetPoint("LEFT", btnCheckSiempre, "RIGHT", 8, 7)
textSiempre1:SetTextColor(1, 1, 1)
textSiempre1:SetText("Pestaña siempre activa")

local textSiempre2 = tabMecanica:CreateFontString(nil, "OVERLAY")
textSiempre2:SetFont("Fonts\\FRIZQT__.TTF", 12)
textSiempre2:SetPoint("LEFT", btnCheckSiempre, "RIGHT", 8, -7)
textSiempre2:SetTextColor(1, 1, 1)
textSiempre2:SetText("en este personaje")

local function pintarCheck()
    if GMToolsMecanicoDB.siempreActiva then
        marcaCheckSiempre:SetText("×")
        btnCheckSiempre:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    else
        marcaCheckSiempre:SetText("")
        btnCheckSiempre:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.9)
    end
end
pintarCheck()
-- Al abrir la pestaña se repinta la casilla desde el estado guardado:
-- así el dibujo nunca se queda desincronizado con el valor real.
-- Además se enfoca el primer campo del ajuste de versión.
tabMecanica:SetScript("OnShow", pintarCheck)

btnCheckSiempre:SetScript("OnClick", function()
    GMToolsMecanicoDB.siempreActiva = not GMToolsMecanicoDB.siempreActiva
    pintarCheck()
    guardarCVar()
    pcall(SaveAddOns)
end)

btnMecanico:RegisterForClicks("LeftButtonUp")
btnMecanico:SetScript("OnClick", function()
    if tabMecanica:IsShown() then
        tabMecanica:Hide()
    else
        tabMecanica:Show()
    end
end)


-- ════════════════════════════════════════════════════════════
-- SUBVENTANA DE ICONOS — ahora en la ventana IZQUIERDA nueva.
-- Rejilla de 4 botones por fila (fila 0 = botones 1-4, fila 1 = el
-- 5º, quedan 3 huecos para futuros botones). La subventana va
-- DENTRO de la izquierda, centrada, con su propio borde.
-- ════════════════════════════════════════════════════════════
local BTN_SIZE = 37
local BTN_GAP = 4
local COLUMNAS = 4

local subVentana = CreateFrame("Frame", "GMToolsSubVentanaIzq", ventanaIzq, "BackdropTemplate")
subVentana:SetSize(171, 88)
subVentana:SetPoint("CENTER", ventanaIzq, "CENTER", 0, 0)
subVentana:SetClipsChildren(true)
subVentana:SetFrameLevel(ventanaIzq:GetFrameLevel() + 5)
subVentana:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
subVentana:SetBackdropColor(0, 0, 0, 0)
subVentana:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

local ICONOS = {
    "Interface\\AddOns\\Epsilon_Phase_Codex\\assets\\EpsilonTrayIconCodex.blp",
    "Interface\\AddOns\\Epsilon_Launcher\\assets\\EpsilonTrayIconObjectMover.blp",
    "Interface\\AddOns\\Epsilon_Launcher\\assets\\EpsilonTrayIconViewer.blp",
    "Interface\\AddOns\\GMTools\\icons\\animviewer-icon.blp",
    "Interface\\AddOns\\GMTools\\icons\\chat-icon.blp",
}

local function clickIzquierdo(i)
    if i == 1 then
        if EpsilonPhases and EpsilonPhases.Show then EpsilonPhases:Show() end
    elseif i == 3 then
        if SlashCmdList and SlashCmdList["EPSV"] then SlashCmdList["EPSV"]() end
    end
end

for i = 1, #ICONOS do
    local btn = CreateFrame("Button", nil, subVentana)
    btn:SetSize(BTN_SIZE, BTN_SIZE)
    -- 4 botones por fila: fila 0 = botones 1-4, fila 1 = el 5º
    local col = (i - 1) % COLUMNAS
    local fila = math.floor((i - 1) / COLUMNAS)
    btn:SetPoint("TOPLEFT", subVentana, "TOPLEFT", 4 + col * (BTN_SIZE + BTN_GAP), -4 - fila * (BTN_SIZE + BTN_GAP))

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(36, 36)
    icon:SetPoint("CENTER")
    icon:SetTexture(ICONOS[i])

    local glowOk = pcall(function()
        btn:SetHighlightAtlas("ChallengeMode-KeystoneSlotFrameGlow")
    end)
    if glowOk then
        local glow = btn:GetHighlightTexture()
        glow:ClearAllPoints()
        glow:SetPoint("CENTER")
        glow:SetSize(BTN_SIZE * 1.66, BTN_SIZE * 1.66)
        glow:SetAlpha(0.5)
    end

    if i == 2 then
        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        btn:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                if SlashCmdList and SlashCmdList["OM_SHOWCLOSE"] then
                    SlashCmdList["OM_SHOWCLOSE"](true)
                end
            else
                if ObjectToolboxFrame and ObjectToolboxFrame.Toggle then
                    ObjectToolboxFrame:Toggle()
                end
            end
        end)
    elseif i == 4 then
        btn:RegisterForClicks("LeftButtonUp")
        btn:SetScript("OnClick", function()
            if SlashCmdList and SlashCmdList["NPCANIMVIEWER"] then
                SlashCmdList["NPCANIMVIEWER"]("")
            else
                SendChatMessage("/anim")
            end
        end)
    elseif i == 5 then
        GMToolsDialoguesBtn = btn
        btn:RegisterForClicks("LeftButtonUp")
        btn:SetScript("OnClick", function()
            if ToolDialoguesFrame then
                if ToolDialoguesFrame:IsShown() then
                    ToolDialoguesFrame:Hide()
                else
                    ToolDialoguesFrame:Show()
                end
            end
        end)
    else
        btn:RegisterForClicks("LeftButtonUp")
        btn:SetScript("OnClick", function()
            clickIzquierdo(i)
        end)
    end
end

-- ════════════════════════════════════════════════════════════
-- EXPANSIÓN SUAVE DE LA IZQUIERDA — colapsada muestra solo la
-- fila 1 (4 botones, alto igual a la derecha); al pasar el ratón
-- se expande hacia arriba (las alturas de los sliders de abajo
-- son los OBJETIVOS expandidos) y se revela la fila 2 completa.
-- ════════════════════════════════════════════════════════════
local IZQ_ALTO_COLAPSADA = WIN_H
local IZQ_ALTO_EXPANDIDA = 98
local SUB_ALTO_COLAPSADA = 45
local SUB_ALTO_EXPANDIDA = 88
local ANIM_DURACION = 0.30
local expandK = 0
local expandObjetivo = 0

subVentana:SetSize(171, SUB_ALTO_COLAPSADA)

ventanaIzq:SetScript("OnShow", function()
    expandK = 0
    expandObjetivo = 0
    ventanaIzq:SetHeight(IZQ_ALTO_COLAPSADA)
    subVentana:SetHeight(SUB_ALTO_COLAPSADA)
end)

ventanaIzq:SetScript("OnUpdate", function(self, elapsed)
    local objetivo = self:IsMouseOver() and 1 or 0
    if objetivo ~= expandObjetivo then
        expandObjetivo = objetivo
    end
    if expandObjetivo ~= expandK then
        if expandObjetivo == 1 then
            expandK = math.min(expandK + elapsed / ANIM_DURACION, 1)
        else
            expandK = math.max(expandK - elapsed / ANIM_DURACION, 0)
        end
        local suave = expandK * expandK * (3 - 2 * expandK)
        self:SetHeight(IZQ_ALTO_COLAPSADA + (IZQ_ALTO_EXPANDIDA - IZQ_ALTO_COLAPSADA) * suave)
        subVentana:SetHeight(SUB_ALTO_COLAPSADA + (SUB_ALTO_EXPANDIDA - SUB_ALTO_COLAPSADA) * suave)
    end
end)



-- ════════════════════════════════════════════════════════════
-- FIN DE LA CARGA
-- ════════════════════════════════════════════════════════════
-- "Pestaña siempre activa": si la casilla está marcada (guardado por
-- personaje), /gm queda abierto al entrar. Se hace una pasada al
-- cargar y otra un segundo después (con la UI ya asentada): si las
-- ventanas quedaron fuera de pantalla se vuelven a anclar sobre la
-- barra de acciones, igual que hace /gm, sin tocar ventanas movidas.
if GMToolsMecanicoDB and GMToolsMecanicoDB.siempreActiva then
    ventana:Show()
    ventanaIzq:Show()
end
C_Timer.After(1, function()
    if not (GMToolsMecanicoDB and GMToolsMecanicoDB.siempreActiva) then return end
    local l, t = ventana:GetLeft(), ventana:GetTop()
    local pw, ph = UIParent:GetWidth(), UIParent:GetHeight()
    if not l or not t or l < -50 or t < -50 or l + ventana:GetWidth() > pw + 50 or t + ventana:GetHeight() > ph + 50 then
        if GMToolsAnclarVentana then GMToolsAnclarVentana() end
    end
    ventana:Show()
    ventanaIzq:Show()
end)

end)
