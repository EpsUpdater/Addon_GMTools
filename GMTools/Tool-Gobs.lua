-- ============================================================
-- Tool-Gobs.lua
-- Subventanas de botones GOBS: pestanya1 (3 botones) y
-- pestanya2 (5 botones), arrastrables, que envían sus
-- comandos .gob al chat. Se abren/cierran con el botón
-- derecho de la barra principal (GMToolsFrame).
-- ============================================================

local ventana = _G["GMToolsFrame"]

if not ventana then
    return
end

local ok, err = pcall(function()

-- ════════════════════════════════════════════════════════════
-- BOTÓN DERECHO (sin subcategoría) + DOS VENTANAS arrastrables:
-- pestanya1 (3 botones, BOTTOMLEFT → TOPLEFT de la principal +5)
-- y pestanya2 (5 botones, LEFT → RIGHT de pestanya1 +15),
-- botones 37x37 gap 2, envían su comando al chat
-- ════════════════════════════════════════════════════════════
local BTN_SIZE = 37
local BTN_GAP = 4
local VISTA_ALTO = 104
local VISTA_ALTO2 = 43 + 8
-- Modo GOB/GROUP del deslizador: declarado AQUÍ (antes que cualquier
-- botón) para que todos los clics compartan el mismo valor.
local modoGrupo = false

local btnDerecha = CreateFrame("Button", nil, ventana)
btnDerecha:SetSize(BTN_SIZE, BTN_SIZE)
btnDerecha:SetPoint("LEFT", ventana, "LEFT", 6, 0)

local iconDer = btnDerecha:CreateTexture(nil, "BACKGROUND")
iconDer:SetSize(36, 36)
iconDer:SetPoint("CENTER")
iconDer:SetTexture("Interface\\AddOns\\GMTools\\icons\\icono-gobs")

btnDerecha:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
GMToolsBtnDerecha = btnDerecha

-- ════════════════════════════════════════════════════════════
-- COPIA DEL BOTÓN DE GOBS — idéntico en aspecto y comportamiento,
-- justo a la derecha del original. Todo lo que iba después (flecha,
-- slider de velocidad y botón de volar) queda desplazado esos mismos
-- píxeles hacia la derecha; la X y el engranaje no se tocan.
-- ════════════════════════════════════════════════════════════
local btnDerecha2 = CreateFrame("Button", nil, ventana)
btnDerecha2:SetSize(BTN_SIZE, BTN_SIZE)
btnDerecha2:SetPoint("LEFT", btnDerecha, "RIGHT", 3, 0)

local iconDer2 = btnDerecha2:CreateTexture(nil, "BACKGROUND")
iconDer2:SetSize(36, 36)
iconDer2:SetPoint("CENTER")
iconDer2:SetTexture("Interface\\AddOns\\GMTools\\icons\\icono-npcs")

btnDerecha2:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
GMToolsBtnDerecha2 = btnDerecha2

-- ════════════════════════════════════════════════════════════
-- BOTÓN 2 — flecha (JumpUpArrow) en el hueco entre el botón de
-- gobs y el slider de velocidad. Sin borde.
-- ════════════════════════════════════════════════════════════
local btnFlecha = CreateFrame("Button", nil, ventana)
btnFlecha:SetSize(20, BTN_SIZE)
btnFlecha:SetPoint("LEFT", btnDerecha2, "RIGHT", 3, 0)
btnFlecha:SetHighlightTexture("Interface\\Minimap\\Minimap-PositionArrows", "ADD")
local hlFlecha = btnFlecha:GetHighlightTexture()
if hlFlecha then
    hlFlecha:SetVertexColor(1, 1, 0)
    hlFlecha:SetAllPoints(btnFlecha)
end
btnFlecha:RegisterForClicks("LeftButtonUp")

local texFlecha = btnFlecha:CreateTexture(nil, "OVERLAY")
texFlecha:SetAllPoints(btnFlecha)
texFlecha:SetTexture("Interface\\Minimap\\Minimap-PositionArrows")

GMToolsBtnFlecha = btnFlecha

-- ════════════════════════════════════════════════════════════
-- DESLIZADOR DE VELOCIDAD (copia del de Intensidad de Weather,
-- ajustado a esta barra). Título "VELOCIDAD" arriba, marcas
-- debajo: 0.1 1 2 5 10 20 30 40 50.
-- ════════════════════════════════════════════════════════════
local VELOCIDADES = { 0.1, 0.5, 1, 1.5, 2, 5, 10, 25, 50 }
local deltasVel = { 15, 12, 8, 3, 1, -3, -8, -12, -15 }

local ESCALAS = { 0.1, 0.2, 0.5, 1, 1.1, 1.5, 2, 5, 10 }
local deltasEsc = { 15, 12, 8, 4, -2, -5, -8, -11, -15 }

local modoActual = "velocidad"

function GMToolsModoActual()
    return modoActual
end

local txtVelocidad = ventana:CreateFontString(nil, "OVERLAY", "GameFontNormal")
txtVelocidad:SetText("VELOCIDAD")
txtVelocidad:SetTextColor(1, 0.85, 0)

local anchoSliderVel = 280
local sliderVelocidad = CreateFrame("Slider", "GMToolsVelocidadSlider", ventana, "OptionsSliderTemplate")
sliderVelocidad:SetSize(anchoSliderVel, 17)
sliderVelocidad:SetMinMaxValues(1, #VELOCIDADES)
sliderVelocidad:SetValueStep(1)
sliderVelocidad:SetObeyStepOnDrag(true)
sliderVelocidad:SetValue(3)
sliderVelocidad.Text:SetText("")
sliderVelocidad.Low:SetText("")
sliderVelocidad.High:SetText("")
sliderVelocidad:SetPoint("LEFT", btnFlecha, "RIGHT", 3, 0)
txtVelocidad:SetPoint("BOTTOM", sliderVelocidad, "TOP", 0, 0)

local marcasVel = {}
for i, v in ipairs(VELOCIDADES) do
    local marca = ventana:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    marca:SetFont("Fonts\\FRIZQT__.TTF", 10)
    marca:SetText(tostring(v))
    marca:SetTextColor(0.8, 0.85, 0.95)
    marca:SetPoint("CENTER", sliderVelocidad, "LEFT",
        ((i - 1) / 8) * anchoSliderVel + deltasVel[i], -13)
    marcasVel[i] = marca
end
GMToolsMarcasVel = marcasVel

-- Posición INDEPENDIENTE por modo: velocidad y escala guardan cada
-- una la suya, y al alternar el slider salta a la casilla de cada
-- modo (sin reenviar nada al cambiar).
local idxVel = 3
local idxEsc = 4
local cambiandoModo = false
sliderVelocidad:SetScript("OnValueChanged", function(self, value)
    local idx = math.max(1, math.min(9, math.floor(value + 0.5)))
    if cambiandoModo then return end
    if modoActual == "velocidad" then
        if idx ~= idxVel then
            idxVel = idx
            GMToolsVelocidad = VELOCIDADES[idx]
            SendChatMessage(".mod speed " .. tostring(VELOCIDADES[idx]), "SAY")
        end
    else
        if idx ~= idxEsc then
            idxEsc = idx
            GMToolsEscala = ESCALAS[idx]
            SendChatMessage(".mod scale " .. tostring(ESCALAS[idx]), "SAY")
        end
    end
end)
GMToolsVelocidad = 1
GMToolsEscala = 1
GMToolsVelocidadSlider = sliderVelocidad
GMToolsVelocidadTitulo = txtVelocidad

-- ════════════════════════════════════════════════════════════
-- MODO VELOCIDAD / ESCALA — alterna con el botón de flecha
-- ════════════════════════════════════════════════════════════
local function aplicarModo()
    cambiandoModo = true
    if modoActual == "velocidad" then
        txtVelocidad:SetText("VELOCIDAD")
        sliderVelocidad:SetValue(idxVel)
        for i = 1, 9 do
            marcasVel[i]:SetText(tostring(VELOCIDADES[i]))
            marcasVel[i]:ClearAllPoints()
            marcasVel[i]:SetPoint("CENTER", sliderVelocidad, "LEFT",
                ((i - 1) / 8) * anchoSliderVel + deltasVel[i], -13)
        end
    else
        txtVelocidad:SetText("ESCALA")
        sliderVelocidad:SetValue(idxEsc)
        for i = 1, 9 do
            marcasVel[i]:SetText(tostring(ESCALAS[i]))
            marcasVel[i]:ClearAllPoints()
            marcasVel[i]:SetPoint("CENTER", sliderVelocidad, "LEFT",
                ((i - 1) / 8) * anchoSliderVel + deltasEsc[i], -13)
        end
    end
    cambiandoModo = false
end

function GMToolsSetEscalaDx(i, dx)
    deltasEsc[i] = dx
    if modoActual == "escala" then
        marcasVel[i]:ClearAllPoints()
        marcasVel[i]:SetPoint("CENTER", sliderVelocidad, "LEFT",
            ((i - 1) / 8) * anchoSliderVel + dx, -13)
    end
end

function GMToolsGetEscalaDeltas()
    local t = {}
    for i = 1, 9 do t[i] = deltasEsc[i] end
    return t
end

btnFlecha:SetScript("OnClick", function()
    modoActual = modoActual == "velocidad" and "escala" or "velocidad"
    aplicarModo()
end)

-- ════════════════════════════════════════════════════════════
-- BOTÓN 3 — volar on/off: pluma = .cheat fly on, huella =
-- .cheat fly off. Alterna el icono con cada pulsación.
-- ════════════════════════════════════════════════════════════
local btnDerecha3 = CreateFrame("Button", nil, ventana)
btnDerecha3:SetSize(BTN_SIZE, BTN_SIZE)
btnDerecha3:SetPoint("LEFT", sliderVelocidad, "RIGHT", 8, 0)

local iconDer3 = btnDerecha3:CreateTexture(nil, "BACKGROUND")
iconDer3:SetSize(36, 36)
iconDer3:SetPoint("CENTER")
iconDer3:SetTexture("Interface\\Icons\\eps_bg3_longstrider")

btnDerecha3:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

local volando = false
btnDerecha3:RegisterForClicks("LeftButtonUp")
btnDerecha3:SetScript("OnClick", function()
    if volando then
        SendChatMessage(".cheat fly off", "SAY")
        volando = false
        iconDer3:SetTexture("Interface\\Icons\\eps_bg3_longstrider")
    else
        SendChatMessage(".cheat fly on", "SAY")
        volando = true
        iconDer3:SetTexture("Interface\\Icons\\eps_bg3_featherfall")
    end
end)

GMToolsBtnDerecha3 = btnDerecha3

-- ════════════════════════════════════════════════════════════
-- COPIA DEL BOTÓN DE LAS DOS FLECHAS — idéntico en aspecto y
-- comportamiento (alterna VELOCIDAD/ESCALA), a la derecha del botón
-- de volar con la misma separación que entre los dos botones de gobs.
-- ════════════════════════════════════════════════════════════
local btnFlecha2 = CreateFrame("Button", nil, ventana)
btnFlecha2:SetSize(20, BTN_SIZE)
btnFlecha2:SetPoint("LEFT", btnDerecha3, "RIGHT", 3, 0)
btnFlecha2:SetHighlightTexture("Interface\\Minimap\\Minimap-PositionArrows", "ADD")
local hlFlecha2 = btnFlecha2:GetHighlightTexture()
if hlFlecha2 then
    hlFlecha2:SetVertexColor(1, 1, 0)
    hlFlecha2:SetAllPoints(btnFlecha2)
end
btnFlecha2:RegisterForClicks("LeftButtonUp")

local texFlecha2 = btnFlecha2:CreateTexture(nil, "OVERLAY")
texFlecha2:SetAllPoints(btnFlecha2)
texFlecha2:SetTexture("Interface\\Minimap\\Minimap-PositionArrows")

GMToolsBtnFlecha2 = btnFlecha2

-- ════════════════════════════════════════════════════════════
-- BOTÓN DE MORFEO — el botón de las flechas nuevas alterna el modo
-- morfear: cuando está activo, el botón de volar/andar se cambia por
-- este (charmperson = sin morph, sleep = morph puesto). Hace lo
-- mismo que el macro, pero desde el addon:
--   /tar [@player]
--   /run if MorphOn then SendChatMessage(".demorph") MorphOn=false
--        else SendChatMessage(".morph 61365") MorphOn=true end
-- ════════════════════════════════════════════════════════════
local morphOn = false

local btnMorph = CreateFrame("Button", nil, ventana)
btnMorph:SetSize(BTN_SIZE, BTN_SIZE)
btnMorph:SetPoint("LEFT", sliderVelocidad, "RIGHT", 8, 0)

local iconMorph = btnMorph:CreateTexture(nil, "BACKGROUND")
iconMorph:SetSize(36, 36)
iconMorph:SetPoint("CENTER")
iconMorph:SetTexture("Interface\\Icons\\eps_bg3_charmperson")

btnMorph:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
btnMorph:RegisterForClicks("LeftButtonUp")
btnMorph:Hide()

local function pintarMorph()
    if morphOn then
        iconMorph:SetTexture("Interface\\Icons\\eps_bg3_sleep")
    else
        iconMorph:SetTexture("Interface\\Icons\\eps_bg3_charmperson")
    end
end

btnMorph:SetScript("OnClick", function()
    if morphOn then
        SendChatMessage(".demorph", "SAY")
        morphOn = false
    else
        SendChatMessage(".morph 61365", "SAY")
        morphOn = true
    end
    pintarMorph()
end)

-- Las flechas nuevas: encienden/apagan el modo morfear.
btnFlecha2:SetScript("OnClick", function()
    if btnMorph:IsShown() then
        btnMorph:Hide()
        btnDerecha3:Show()
    else
        btnMorph:Show()
        btnDerecha3:Hide()
    end
end)

GMToolsBtnMorph = btnMorph

local P_GAP = 2

local PESTANYA_DATOS = {
    { icon = "eps_buildershaven_gobselect",   verbo = "sel",       ayuda = "GOB Sel",    grupo = true },
    { icon = "eps_buildershaven_gobunselect", verbo = "unsel",     ayuda = "GOB Unsel",  grupo = true },
    { icon = "eps_buildershaven_gobdelete",   verbo = "delete",    ayuda = "GOB Del",    grupo = true },
    { icon = "eps_buildershaven_gobrotate10",  grados = 10,  grupo = true, pref = "gr" },
    { icon = "eps_buildershaven_gobrotate15",  grados = 15,  grupo = true, pref = "gr" },
    { icon = "eps_buildershaven_gobrotate30",  grados = 30,  grupo = true, pref = "gr" },
    { icon = "eps_buildershaven_gobrotate90",  grados = 90,  grupo = true, pref = "gr" },
    { icon = "eps_buildershaven_gobrotate180", grados = 180, grupo = true, pref = "gr" },
}

local function crearVentanaBotones(nombre, n)
    local w = CreateFrame("Frame", nombre, ventana, "BackdropTemplate")
    w:SetSize(4 + n * BTN_SIZE + (n - 1) * P_GAP + 4, 43)
    w:SetFrameLevel(ventana:GetFrameLevel() + 5)
    w:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    w:SetBackdropColor(0.12, 0.18, 0.40, 0.9)
    w:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    w:EnableMouse(true)
    w:SetMovable(true)
    w:SetClampedToScreen(true)
    w:RegisterForDrag("LeftButton")
    w:SetScript("OnDragStart", w.StartMoving)
    w:SetScript("OnDragStop",  w.StopMovingOrSizing)
    w:Hide()
    return w
end

local pestanya1 = crearVentanaBotones("GMToolsPestanya1", 3)
local pestanya2 = crearVentanaBotones("GMToolsPestanya2", 5)

-- ════════════════════════════════════════════════════════════
-- VENTANA EXTERIOR DE PESTANYA1 — gemela de la ventana de
-- herramientas NPC: caja oscura que contiene la subventana de
-- 3 botones. Se ancla por su esquina inferior izquierda a la
-- esquina SUPERIOR IZQUIERDA de la ventana izquierda que sube
-- y baja (GMToolsFrameIzq), 5 píxeles por encima.
-- ════════════════════════════════════════════════════════════
local vistaPestanya1 = CreateFrame("Frame", "GMToolsPestanya1Vista", UIParent, "BackdropTemplate")
vistaPestanya1:SetSize(4 + 3 * BTN_SIZE + 2 * P_GAP + 4 + 12, VISTA_ALTO)
vistaPestanya1:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
vistaPestanya1:SetBackdropColor(0.12, 0.18, 0.40, 0.25)
vistaPestanya1:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
if GMToolsFrameIzq then
    vistaPestanya1:SetPoint("BOTTOMLEFT", GMToolsFrameIzq, "TOPLEFT", 0, 5)
else
    vistaPestanya1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 400, 400)
end
vistaPestanya1:SetFrameLevel((GMToolsFrameIzq and GMToolsFrameIzq:GetFrameLevel() or 0) + 5)
vistaPestanya1:SetMovable(true)
vistaPestanya1:SetClampedToScreen(true)
vistaPestanya1:RegisterForDrag("LeftButton")
vistaPestanya1:SetScript("OnDragStart", vistaPestanya1.StartMoving)
vistaPestanya1:SetScript("OnDragStop",  vistaPestanya1.StopMovingOrSizing)
vistaPestanya1:Hide()

-- La subventana de 3 botones pasa a vivir DENTRO de la caja:
-- el arrastre lo toma la caja entera, no la subventana.
pestanya1:SetParent(vistaPestanya1)
pestanya1:SetPoint("TOPLEFT", vistaPestanya1, "TOPLEFT", 6, -56)
pestanya1:SetMovable(false)
pestanya1:SetScript("OnDragStart", nil)
pestanya1:SetScript("OnDragStop", nil)

pestanya2:SetPoint("LEFT", pestanya1, "RIGHT", 15, 0)

-- ════════════════════════════════════════════════════════════
-- VENTANA EXTERIOR DE PESTANYA2 — gemela de la de la izquierda
-- (misma caja oscura y misma altura): contiene la subventana de
-- los 5 botones de rotación, anclada a la derecha de la caja de
-- la izquierda. El arrastre lo toma la caja entera.
-- ════════════════════════════════════════════════════════════
local vistaPestanya2 = CreateFrame("Frame", "GMToolsPestanya2Vista", UIParent, "BackdropTemplate")
vistaPestanya2:SetSize(4 + 5 * BTN_SIZE + 4 * P_GAP + 4 + 12, VISTA_ALTO2)
vistaPestanya2:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
vistaPestanya2:SetBackdropColor(0.12, 0.18, 0.40, 0.25)
vistaPestanya2:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
vistaPestanya2:SetPoint("BOTTOMLEFT", vistaPestanya1, "BOTTOMRIGHT", 5, 0)
vistaPestanya2:SetFrameLevel(vistaPestanya1:GetFrameLevel())
vistaPestanya2:SetMovable(true)
vistaPestanya2:SetClampedToScreen(true)
vistaPestanya2:RegisterForDrag("LeftButton")
vistaPestanya2:SetScript("OnDragStart", vistaPestanya2.StartMoving)
vistaPestanya2:SetScript("OnDragStop",  vistaPestanya2.StopMovingOrSizing)
vistaPestanya2:Hide()

-- La subventana de 5 botones vive DENTRO de la caja (una sola
-- fila, como las ventanas principales del addon); el arrastre lo
-- toma la caja, no la subventana.
pestanya2:SetParent(vistaPestanya2)
pestanya2:SetPoint("TOPLEFT", vistaPestanya2, "TOPLEFT", 6, -4)
pestanya2:SetMovable(false)
pestanya2:SetScript("OnDragStart", nil)
pestanya2:SetScript("OnDragStop", nil)

-- ════════════════════════════════════════════════════════════
-- COPIA DE LA BARRA DE ROTACIÓN — 5 px ENCIMA de ella, mismas
-- caja y subventana, pero con 4 botones: move, go, info y
-- activate. La caja acaba justo con el tamaño de esos 4 botones
-- (no hay más botones a la derecha). Cada uno alterna el prefijo
-- según el modo (group / gr) y tiene su tooltip.
-- ════════════════════════════════════════════════════════════
local vistaPestanya2B = CreateFrame("Frame", "GMToolsPestanya2BVista", UIParent, "BackdropTemplate")
vistaPestanya2B:SetSize(4 + 4 * BTN_SIZE + 3 * P_GAP + 4 + 12, VISTA_ALTO2)
vistaPestanya2B:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
vistaPestanya2B:SetBackdropColor(0.12, 0.18, 0.40, 0.25)
vistaPestanya2B:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
vistaPestanya2B:SetPoint("BOTTOMLEFT", vistaPestanya2, "TOPLEFT", 0, 2)
vistaPestanya2B:SetFrameLevel(vistaPestanya2:GetFrameLevel())
vistaPestanya2B:SetMovable(true)
vistaPestanya2B:SetClampedToScreen(true)
vistaPestanya2B:RegisterForDrag("LeftButton")
vistaPestanya2B:SetScript("OnDragStart", vistaPestanya2B.StartMoving)
vistaPestanya2B:SetScript("OnDragStop",  vistaPestanya2B.StopMovingOrSizing)
vistaPestanya2B:Hide()

local subPestanya2B = CreateFrame("Frame", nil, vistaPestanya2B, "BackdropTemplate")
subPestanya2B:SetSize(4 + 4 * BTN_SIZE + 3 * P_GAP + 4, 43)
subPestanya2B:SetPoint("TOPLEFT", vistaPestanya2B, "TOPLEFT", 6, -4)
subPestanya2B:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
subPestanya2B:SetBackdropColor(0, 0, 0, 0)
subPestanya2B:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

local DATOS_BARRA4 = {
    { icon = "eps_buildershaven_gobmove",     verbo = "move",     pref = "group", ayuda = "GOB Move" },
    { icon = "eps_buildershaven_gobgo",       verbo = "go",       pref = "gr",    ayuda = "GOB Go" },
    { icon = "eps_buildershaven_gobinfo",     verbo = "info",     pref = "gr",    ayuda = "GOB Info" },
    { icon = "eps_buildershaven_gobactivate", verbo = "activate", pref = "gr",    ayuda = "GOB Activate" },
}
for i = 1, 4 do
    local d = DATOS_BARRA4[i]
    local btn = CreateFrame("Button", nil, subPestanya2B)
    btn:SetSize(BTN_SIZE, BTN_SIZE)
    btn:SetPoint("LEFT", subPestanya2B, "LEFT", 4 + (i - 1) * (BTN_SIZE + P_GAP), 0)
    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(36, 36)
    icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\Icons\\" .. d.icon)
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    btn:RegisterForClicks("LeftButtonUp")
    btn:SetScript("OnClick", function()
        SendChatMessage((modoGrupo and ".gob " .. (d.pref or "gr") .. " " or ".gob ") .. d.verbo, "SAY")
    end)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(d.ayuda)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end
GMToolsPestanya2B = vistaPestanya2B

-- ════════════════════════════════════════════════════════════
-- VENTANA EXTERIOR 3 — a la derecha de la de rotación (5 px),
-- MISMA altura que ella (una fila) y alineada horizontalmente,
-- con el ancho actual (hasta el borde derecho de GMToolsFrame).
-- Contiene 7 copias genéricas de rotar 10, sin uso todavía.
-- ════════════════════════════════════════════════════════════
local vistaPestanya3 = CreateFrame("Frame", "GMToolsPestanya3Vista", UIParent, "BackdropTemplate")
vistaPestanya3:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
vistaPestanya3:SetBackdropColor(0.12, 0.18, 0.40, 0.25)
vistaPestanya3:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
if GMToolsFrame then
    vistaPestanya3:SetPoint("TOPLEFT", vistaPestanya2, "TOPRIGHT", 5, 0)
    vistaPestanya3:SetPoint("TOPRIGHT", GMToolsFrame, "TOPRIGHT", 0, 0)
else
    vistaPestanya3:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 400, 400)
end
vistaPestanya3:SetHeight(VISTA_ALTO2)
vistaPestanya3:SetFrameLevel(vistaPestanya2:GetFrameLevel())
vistaPestanya3:Hide()

-- Relleno: 7 botones de ESCALA dentro de la subventana interior,
-- como la de rotación (misma alineación). Mandan
-- .gob scale X / .gob group scale X según el modo. El botón de
-- flechas de la derecha intercambia entre las 3 filas.
local SUB_P3_ICONO = "Interface\\AddOns\\GMTools\\icons\\escalas\\"
local FILAS_ESCALAS = {
    { { icon = "01", escala = "0.1" }, { icon = "02", escala = "0.2" }, { icon = "03", escala = "0.3" },
      { icon = "04", escala = "0.4" }, { icon = "05", escala = "0.5" }, { icon = "06", escala = "0.6" },
      { icon = "07", escala = "0.7" } },
    { { icon = "08", escala = "0.8" }, { icon = "09", escala = "0.9" }, { icon = "1",  escala = "1" },
      { icon = "11", escala = "1.1" }, { icon = "12", escala = "1.2" }, { icon = "13", escala = "1.3" },
      { icon = "14", escala = "1.4" } },
    { { icon = "15", escala = "1.5" }, { icon = "2",  escala = "2" },   { icon = "25", escala = "2.5" },
      { icon = "3",  escala = "3" },   { icon = "5",  escala = "5" },   { icon = "10", escala = "10" },
      { icon = "20", escala = "20" } },
}
local subPestanya3 = CreateFrame("Frame", nil, vistaPestanya3, "BackdropTemplate")
subPestanya3:SetSize(4 + 7 * BTN_SIZE + 6 * P_GAP + 4, 43)
subPestanya3:SetPoint("TOPLEFT", vistaPestanya3, "TOPLEFT", 6, -4)
subPestanya3:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
subPestanya3:SetBackdropColor(0, 0, 0, 0)
subPestanya3:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

local filaEscalas = 1
local botonesEscalas = {}
for i = 1, 7 do
    local btn = CreateFrame("Button", nil, subPestanya3)
    btn:SetSize(BTN_SIZE, BTN_SIZE)
    btn:SetPoint("LEFT", subPestanya3, "LEFT", 4 + (i - 1) * (BTN_SIZE + P_GAP), 0)
    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(36, 36)
    icon:SetPoint("CENTER")
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    btn:RegisterForClicks("LeftButtonUp")
    btn:SetScript("OnClick", function()
        local dato = FILAS_ESCALAS[filaEscalas][i]
        SendChatMessage((modoGrupo and ".gob gr scale " or ".gob scale ") .. dato.escala, "SAY")
    end)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Escala " .. FILAS_ESCALAS[filaEscalas][i].escala)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    botonesEscalas[i] = { btn = btn, icon = icon }
end

local function pintarFilaEscalas()
    local fila = FILAS_ESCALAS[filaEscalas]
    for i = 1, 7 do
        botonesEscalas[i].icon:SetTexture(SUB_P3_ICONO .. fila[i].icon)
    end
end
pintarFilaEscalas()

-- ════════════════════════════════════════════════════════════
-- BOTÓN DE FLECHITAS (copia del de VELOCIDAD/ESCALA de la pestaña
-- principal) a la derecha de la ventana 3: mismo aspecto y mismo
-- hover amarillo, sin función todavía.
-- ════════════════════════════════════════════════════════════
local btnFlechas3 = CreateFrame("Button", nil, UIParent)
btnFlechas3:SetSize(20, BTN_SIZE)
btnFlechas3:SetPoint("LEFT", vistaPestanya3, "RIGHT", -25, 0)
btnFlechas3:SetHighlightTexture("Interface\\Minimap\\Minimap-PositionArrows", "ADD")
local hlFlechas3 = btnFlechas3:GetHighlightTexture()
if hlFlechas3 then
    hlFlechas3:SetVertexColor(1, 1, 0)
    hlFlechas3:SetAllPoints(btnFlechas3)
end
local texFlechas3 = btnFlechas3:CreateTexture(nil, "OVERLAY")
texFlechas3:SetAllPoints(btnFlechas3)
texFlechas3:SetTexture("Interface\\Minimap\\Minimap-PositionArrows")
btnFlechas3:Hide()
btnFlechas3:RegisterForClicks("LeftButtonUp")
btnFlechas3:SetScript("OnClick", function()
    filaEscalas = filaEscalas % 3 + 1
    pintarFilaEscalas()
end)
GMToolsBtnFlechas3 = btnFlechas3
GMToolsPestanya3 = vistaPestanya3

-- ════════════════════════════════════════════════════════════
-- VENTANA DE SPELL — copia de la de escalas, 3 px ENCIMA de ella
-- (esquina inferior derecha contra la superior derecha de las
-- escalas). Texto "Spell:" y campo de texto (70 px) dentro de
-- una subventana con el mismo estilo que las de botones, con 8
-- px de separación entre ambos. Al escribir un número y pulsar
-- Enter envía .gob spell X (o .gob gr spell X en GROUP).
-- ════════════════════════════════════════════════════════════
local vistaSpell = CreateFrame("Frame", "GMToolsPestanya3Spell", UIParent, "BackdropTemplate")
vistaSpell:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
vistaSpell:SetBackdropColor(0.12, 0.18, 0.40, 0.25)
vistaSpell:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
vistaSpell:SetPoint("BOTTOMRIGHT", vistaPestanya3, "TOPRIGHT", 0, 3)
vistaSpell:SetHeight(VISTA_ALTO2)
vistaSpell:SetFrameLevel(vistaPestanya3:GetFrameLevel())

local lblSpell = vistaSpell:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
lblSpell:SetFont("Fonts\\FRIZQT__.TTF", 11)
lblSpell:SetText("Spell:")
lblSpell:SetPoint("LEFT", vistaSpell, "LEFT", 10, 0)

local editSpell = CreateFrame("EditBox", nil, vistaSpell, "InputBoxTemplate")
editSpell:SetSize(70, 18)
editSpell:SetPoint("LEFT", lblSpell, "RIGHT", 8, 0)
editSpell:SetFont("Fonts\\FRIZQT__.TTF", 11)
editSpell:SetAutoFocus(false)
editSpell:SetScript("OnEnterPressed", function(self)
    local v = tonumber(self:GetText())
    if v then
        SendChatMessage((modoGrupo and ".gob gr spell " or ".gob spell ") .. tostring(v), "SAY")
    end
    self:ClearFocus()
end)
editSpell:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
end)

vistaSpell:SetWidth(lblSpell:GetWidth() + 8 + 70 + 4 + 4 + 12)
vistaSpell:Hide()
GMToolsVistaSpell = vistaSpell

-- ════════════════════════════════════════════════════════════
-- DESLIZADOR GOB / GROUP — 2 casillas encima de la subventana de
-- 3 botones, centrado y con el MISMO ancho que ella (123). Las
-- dos opciones GOB y GROUP siempre visibles debajo, la activa en
-- amarillo y salto de 1 en 1.
-- En GOB los botones envían .gob sel/.gob unsel/.gob delete;
-- en GROUP, .gob group sel/.gob group unsel/.gob group delete.
-- ════════════════════════════════════════════════════════════
local anchoSubGob = 4 + 3 * BTN_SIZE + 2 * P_GAP + 4

local sliderModoGob = CreateFrame("Slider", "GMToolsModoGobSlider", vistaPestanya1, "OptionsSliderTemplate")
sliderModoGob:SetSize(anchoSubGob, 17)
sliderModoGob:SetMinMaxValues(1, 2)
sliderModoGob:SetValueStep(1)
sliderModoGob:SetObeyStepOnDrag(true)
sliderModoGob:SetValue(1)
sliderModoGob.Text:SetText("")
sliderModoGob.Low:SetText("")
sliderModoGob.High:SetText("")
sliderModoGob:SetPoint("TOPLEFT", vistaPestanya1, "TOPLEFT", 6, -14)

-- Las dos opciones SIEMPRE visibles debajo del deslizador:
-- la activa en amarillo, la otra en gris. Su posición X es
-- ajustable desde la ventana temporal GMToolsAjusteMarcas.
local posXGob = 15
local posXGroup = 103

local marcaGob = vistaPestanya1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
marcaGob:SetFont("Fonts\\FRIZQT__.TTF", 10)
marcaGob:SetText("GOB")

local marcaGroup = vistaPestanya1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
marcaGroup:SetFont("Fonts\\FRIZQT__.TTF", 10)
marcaGroup:SetText("GROUP")

local function reposarMarcas()
    marcaGob:ClearAllPoints()
    marcaGob:SetPoint("CENTER", sliderModoGob, "LEFT", posXGob, -15)
    marcaGroup:ClearAllPoints()
    marcaGroup:SetPoint("CENTER", sliderModoGob, "LEFT", posXGroup, -15)
end
reposarMarcas()

local function pintarModoGob()
    if modoGrupo then
        marcaGob:SetTextColor(0.8, 0.85, 0.95)
        marcaGroup:SetTextColor(1, 0.85, 0)
    else
        marcaGob:SetTextColor(1, 0.85, 0)
        marcaGroup:SetTextColor(0.8, 0.85, 0.95)
    end
end
pintarModoGob()

sliderModoGob:SetScript("OnValueChanged", function(self, value)
    local v = value >= 1.5
    modoGrupo = v
    pintarModoGob()
end)
GMToolsModoGobSlider = sliderModoGob

local pestanyaBotones = {}

local function crearBotonPestanya(w, j, datos)
    local btn = CreateFrame("Button", nil, w)
    btn:SetSize(BTN_SIZE, BTN_SIZE)
    btn:SetPoint("LEFT", w, "LEFT", 4 + (j - 1) * (BTN_SIZE + P_GAP), 0)

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(36, 36)
    icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\Icons\\" .. datos.icon)
    btn.icon = icon

    if datos.grados then
        local glowOk = pcall(function()
            btn:SetHighlightAtlas("ChallengeMode-KeystoneSlotFrameGlow")
        end)
        if glowOk then
            local glow = btn:GetHighlightTexture()
            glow:ClearAllPoints()
            glow:SetPoint("CENTER")
            glow:SetSize(BTN_SIZE * 1.66, BTN_SIZE * 1.66)
            glow:SetAlpha(0.5)
            btn.glow = glow
        end
    else
        btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    end

    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetScript("OnClick", function(_, boton)
        local verbo
        if datos.grados then
            verbo = "turn " .. ((boton == "RightButton") and "-" or "") .. datos.grados
        else
            verbo = datos.verbo
        end
        SendChatMessage((modoGrupo and ".gob " .. (datos.pref or "group") .. " " or ".gob ") .. verbo, "SAY")
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if datos.grados then
            GameTooltip:SetText(string.format("Rotar %d grados.\nUsa click derecho para el sentido inverso", datos.grados))
        else
            GameTooltip:SetText(datos.ayuda)
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    btn.window = w
    btn.indice = j
    w.botones = (w.botones or 0) + 1
    return btn
end

for i = 1, 3 do
    pestanyaBotones[i] = crearBotonPestanya(pestanya1, i, PESTANYA_DATOS[i])
end
for i = 4, 8 do
    pestanyaBotones[i] = crearBotonPestanya(pestanya2, i - 3, PESTANYA_DATOS[i])
end

function GMToolsPestanyaSetTam(t)
    t = math.max(20, t)
    for _, b in ipairs(pestanyaBotones) do
        b:SetSize(t, t)
        b:SetPoint("LEFT", b.window, "LEFT", 4 + (b.indice - 1) * (t + P_GAP), 0)
        if b.icon then b.icon:SetSize(t - 1, t - 1) end
        if b.glow then b.glow:SetSize(t * 1.66, t * 1.66) end
    end
    for _, w in ipairs({ pestanya1, pestanya2 }) do
        local n = w.botones
        w:SetWidth(4 + n * t + (n - 1) * P_GAP + 4)
    end
    if vistaPestanya1 then
        vistaPestanya1:SetSize(pestanya1:GetWidth() + 12, VISTA_ALTO)
    end
    if vistaPestanya2 then
        vistaPestanya2:SetSize(pestanya2:GetWidth() + 12, VISTA_ALTO2)
    end
    if sliderModoGob then
        sliderModoGob:SetWidth(pestanya1:GetWidth())
    end
    reposarMarcas()
end

GMToolsPestanya1 = pestanya1
GMToolsPestanya2 = pestanya2
GMToolsPestanyaBotones = pestanyaBotones
GMToolsBtnDerecha = btnDerecha

function GMToolsCerrarGobs()
    vistaPestanya1:Hide()
    vistaPestanya2:Hide()
    vistaPestanya2B:Hide()
    vistaPestanya3:Hide()
    vistaSpell:Hide()
    btnFlechas3:Hide()
end

btnDerecha:RegisterForClicks("LeftButtonUp")
btnDerecha:SetScript("OnClick", function()
    if vistaPestanya1:IsShown() then
        GMToolsCerrarGobs()
    else
        if GMToolsNPCFrame and GMToolsNPCFrame:IsShown() and GMToolsNPCToggle then
            GMToolsNPCToggle()
        end
        vistaPestanya1:Show()
        pestanya1:Show()
        vistaPestanya2:Show()
        pestanya2:Show()
        vistaPestanya2B:Show()
        vistaPestanya3:Show()
        vistaSpell:Show()
        btnFlechas3:Show()
    end
end)

btnDerecha2:RegisterForClicks("LeftButtonUp")
btnDerecha2:SetScript("OnClick", function()
    if GMToolsNPCToggle then
        GMToolsNPCToggle()
    end
end)

end)
