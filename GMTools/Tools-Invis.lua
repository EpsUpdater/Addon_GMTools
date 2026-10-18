-- ============================================================
-- Tools-Invis.lua
-- Pestaña de invisibilidad (en desarrollo).
-- Botón temporal a la derecha del botón de gobs que abre una
-- ventana con el diseño de la pestaña de diálogos (mismo panel,
-- tamaño y botón X de cierre) que contiene una rueda giratoria
-- de 20 números fijos: se elige con clic o con las flechas ◀ ▶.
-- ============================================================

local ventana = _G["GMToolsFrame"]
local subVentanaIzq = _G["GMToolsSubVentanaIzq"]

if not ventana then
    return
end

local ok, err = pcall(function()

-- ════════════════════════════════════════════════════════════
-- BOTÓN EN LA SUBVENTANA IZQUIERDA (fila 2, col 3: a la derecha
-- del de auras), mismo estilo que los de la rejilla.
-- ════════════════════════════════════════════════════════════
local btnInvis = CreateFrame("Button", nil, subVentanaIzq or ventana)
btnInvis:SetSize(37, 37)
if subVentanaIzq then
    btnInvis:SetPoint("TOPLEFT", subVentanaIzq, "TOPLEFT", 127, -45)
else
    btnInvis:SetPoint("LEFT", ventana, "LEFT", 268, 0)
end

local iconInvis = btnInvis:CreateTexture(nil, "BACKGROUND")
iconInvis:SetSize(36, 36)
iconInvis:SetPoint("CENTER")
iconInvis:SetTexture("Interface\\AddOns\\GMTools\\icons\\icono-invis")

local glowInvisOk = pcall(function()
    btnInvis:SetHighlightAtlas("ChallengeMode-KeystoneSlotFrameGlow")
end)
if glowInvisOk then
    local glow = btnInvis:GetHighlightTexture()
    glow:ClearAllPoints()
    glow:SetPoint("CENTER")
    glow:SetSize(37 * 1.66, 37 * 1.66)
    glow:SetAlpha(0.5)
end

GMToolsBtnInvis = btnInvis

-- ════════════════════════════════════════════════════════════
-- VENTANA (diseño de la pestaña de diálogos, vacía)
-- (el OnClick del botón se registra al final del archivo, fuera
-- del pcall, usando GMToolsInvisFrame — ver RED DE SEGURIDAD)
-- ════════════════════════════════════════════════════════════
local function panel(f)
    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f:SetBackdropColor(0.12, 0.18, 0.38, 0.82)
    f:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    f:EnableMouse(true)
end

local frame = CreateFrame("Frame", "GMToolsInvisFrame", UIParent, "BackdropTemplate")
frame:SetSize(250, 389)
panel(frame)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop",  frame.StopMovingOrSizing)
frame:Hide()

if ventana then
    frame:SetPoint("BOTTOMRIGHT", ventana, "TOPRIGHT", 0, 8)
else
    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 500, 500)
end

-- ── Botón X de cierre (arriba a la derecha)
local closeButton = CreateFrame("Button", nil, frame)
closeButton:SetSize(26, 26)
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -6)
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
closeButton:SetScript("OnClick", function() frame:Hide() end)
-- ════════════════════════════════════════════════════════════
-- RUEDA FIJA DE 20 NÚMEROS
-- 20 números repartidos cada 18° (2π/20) en el perímetro de un
-- círculo, como una pizza vista desde el centro.
-- La rueda NO se mueve: se elige con clic en un número (o con
-- la flecha ◀ ▶). Diseño escalado ×0.4 (solo cambia el tamaño de
-- texto y botones conserva su tamaño, pero no su posición).
-- ════════════════════════════════════════════════════════════
local N = 20
local STEP = 2 * math.pi / N
local DIAL_R = 78      -- radio al centro de los números (×0.4)
local DIAL_EXT = 176   -- tamaño del disco (×0.4)

local dial = CreateFrame("Frame", "GMToolsInvisDial", frame)
dial:SetSize(DIAL_EXT, DIAL_EXT)
dial:SetPoint("CENTER", frame, "CENTER", 0, -5)

-- Círculo dibujado con código (sin blp, sin disco interior):
-- aro azul de 1px, mismo grosor y color que el borde de los
-- botones (#4D80CC). Se compone de 72 segmentos tangentes.
local ANILLO_SEG = 72
local radioAro = 99
local segmentos = {}
local function dibujarAro()
    for k = 1, ANILLO_SEG do
        local a = (k - 1) * (2 * math.pi / ANILLO_SEG)
        local s = segmentos[k]
        s:ClearAllPoints()
        s:SetPoint("CENTER", dial, "CENTER", radioAro * math.sin(a), radioAro * math.cos(a))
    end
end
for k = 1, ANILLO_SEG do
    local a = (k - 1) * (2 * math.pi / ANILLO_SEG)
    local s = dial:CreateTexture(nil, "BACKGROUND")
    s:SetSize(10, 1)
    s:SetTexture("Interface\\Buttons\\WHITE8X8")
    s:SetRotation(-a)
    s:SetVertexColor(0.3, 0.5, 0.8, 0.9)
    s:SetPoint("CENTER", dial, "CENTER", radioAro * math.sin(a), radioAro * math.cos(a))
    segmentos[k] = s
end

-- Número grande en el centro (selección actual)
local lblSeleccion = dial:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
lblSeleccion:SetPoint("CENTER", dial, "CENTER", 0, -3)
lblSeleccion:SetFont("Fonts\\FRIZQT__.TTF", 64, "OUTLINE")
lblSeleccion:SetTextColor(1, 1, 1)

-- Ejecuta una acción protegiendo el error y mostrándolo en el chat
-- (así un fallo nunca queda silencioso)
local function ejecutar(f, ...)
    local ok2, e = pcall(f, ...)
    if not ok2 then
        print("GMTools | Invis error: " .. tostring(e))
    end
end

-- Estado de la rueda
local seleccion = 1
local extendido = false -- modo +: los slots 1-9 muestran 21-29
local botones = {} -- se rellena abajo, pero DEBE existir antes que las funciones

GMToolsInvisSeleccion = 1

-- Valor mostrado/efectivo de un slot (1-20 o 21-29 en modo +)
local function valorSlot(j)
    if extendido and j <= 9 then return j + 20 end
    return j
end

-- Resalta la selección (la rueda es fija, solo cambia el resaltado)
local function posicionar()
    for j = 1, N do
        local b = botones[j]
        b.label:SetText(valorSlot(j))
        local sel = j == seleccion
        if sel then b.fondo:Show() else b.fondo:Hide() end
        b.label:SetFont("Fonts\\FRIZQT__.TTF", sel and 19 or 15)
        b.label:SetTextColor(sel and 1 or 1, sel and 0.85 or 1, sel and 0.3 or 1)
    end
end

local function seleccionar(j)
    seleccion = j
    GMToolsInvisSeleccion = valorSlot(j)
    lblSeleccion:SetText(valorSlot(j))
    posicionar()
end

-- Botones de los números (30x30: su tamaño NO se escala, pero su
-- posición sí; separación en el perímetro = 2·R·sin(9°) ≈ 24px)
-- Rueda FIJA: cada número tiene su posición estática.
for j = 1, N do
    local b = CreateFrame("Button", nil, dial)
    b:SetSize(30, 30)
    b:SetPoint("CENTER", dial, "CENTER",
        DIAL_R * math.sin((j - 1) * STEP), DIAL_R * math.cos((j - 1) * STEP))

    b.fondo = b:CreateTexture(nil, "BACKGROUND")
    b.fondo:SetSize(29, 29)
    b.fondo:SetPoint("CENTER")
    b.fondo:SetTexture("Interface\\AddOns\\SpellCreator\\assets\\icon_portrait_gold_ring_border.blp")
    b.fondo:SetVertexColor(1, 0.85, 0.3, 1)
    b.fondo:Hide()

    b.label = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.label:SetFont("Fonts\\FRIZQT__.TTF", 15)
    b.label:SetPoint("CENTER")
    b.label:SetText(j)

    b:RegisterForClicks("LeftButtonUp")
    b:SetScript("OnClick", function()
        ejecutar(seleccionar, j)
    end)
    botones[j] = b
end

-- ════════════════════════════════════════════════════════════
-- DESLIZADORES DE 2 OPCIONES (encima del grupo; cuelgan del dial
-- para moverse con él como parte del pack)
--   DETECTION     INVIS
--   TODOS         SOLO YO
-- Usan el OptionsSliderTemplate típico de WoW (como el de los
-- sliders Roll/Pitch/Turn del ObjectMover): barra con pulgar
-- que encaja en los extremos. La opción activa en blanco.
-- Lógica: DETECTION → JUGADOR fijo y TODOS/SOLO YO activo;
--          INVIS → NPC (fijo) y TODOS/SOLO YO desactivado en gris.
-- Parámetros ajustables desde la ventana de AJUSTE TEMPORAL.
-- ════════════════════════════════════════════════════════════
local objetivoJugador = true
local alcanceTodos = true
GMToolsInvisObjetivo = "JUGADOR"
GMToolsInvisAlcance = "TODOS"

local deslizadorAncho = 151  -- longitud de las barras
local deslizadorY = 17       -- posición Y del par (desde el borde superior del dial)
local deslizadorSep = 0      -- separación entre los deslizadores
local textoOffset = 11       -- separación del texto con la barra deslizable

local pila = CreateFrame("Frame", nil, dial)
pila:SetSize(150, 40 * 2 + deslizadorSep)
pila:SetPoint("BOTTOM", dial, "TOP", 0, deslizadorY)

local function crearDeslizador(izqTxt, derTxt, esIzq, alCambiar, y)
    local grupo = CreateFrame("Frame", nil, pila)
    grupo:SetSize(150, 40)
    grupo:SetPoint("BOTTOM", pila, "BOTTOM", 0, y)

    local slider = CreateFrame("Slider", nil, grupo, "OptionsSliderTemplate")
    slider:SetSize(deslizadorAncho, 17)
    slider:SetPoint("BOTTOM", grupo, "BOTTOM", 0, 4)
    slider:SetMinMaxValues(1, 2)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(esIzq() and 1 or 2)

    slider.Text:SetText("")
    slider.Low:SetText(izqTxt)
    slider.High:SetText(derTxt)
    -- Texto encima de cada opción (en los extremos de la barra)
    slider.Low:ClearAllPoints()
    slider.Low:SetPoint("TOPLEFT", slider, "TOPLEFT", 2, textoOffset)
    slider.High:ClearAllPoints()
    slider.High:SetPoint("TOPRIGHT", slider, "TOPRIGHT", -2, textoOffset)

    local function pintar()
        if not slider:IsEnabled() then
            slider.Low:SetTextColor(0.45, 0.47, 0.5)
            slider.High:SetTextColor(0.45, 0.47, 0.5)
            return
        end
        local esIzqAhora = slider:GetValue() <= 1
        if esIzqAhora then
            slider.Low:SetTextColor(1, 1, 1)
            slider.High:SetTextColor(0.55, 0.58, 0.62)
        else
            slider.Low:SetTextColor(0.55, 0.58, 0.62)
            slider.High:SetTextColor(1, 1, 1)
        end
    end

    slider:SetScript("OnValueChanged", function(self, value)
        ejecutar(function()
            alCambiar(value <= 1)
            pintar()
        end)
    end)

    slider:HookScript("OnDisable", function(self)
        self.Thumb:SetVertexColor(0.5, 0.5, 0.5, 1)
        pintar()
    end)
    slider:HookScript("OnEnable", function(self)
        self.Thumb:SetVertexColor(1, 1, 1, 1)
        pintar()
    end)

    slider.pintar = pintar
    pintar()
    grupo.slider = slider
    return grupo
end

local s2 = crearDeslizador("TODOS", "SOLO YO",
    function() return alcanceTodos end,
    function(esIzq)
        alcanceTodos = esIzq
        GMToolsInvisAlcance = esIzq and "TODOS" or "SOLO YO"
    end, 0)
GMToolsBtnAlcance = s2.slider

local modoDetection = true
GMToolsInvisModo = "DETECTION"

-- DETECTION → JUGADOR fijo y TODOS/SOLO YO activo;
-- INVIS → NPC fijo y TODOS/SOLO YO en gris (no seleccionable)
local function sincronizar()
    if modoDetection then
        objetivoJugador = true
        GMToolsInvisObjetivo = "JUGADOR"
        s2.slider.Low:SetText("TODOS")
        s2.slider.High:SetText("SOLO YO")
        s2.slider:Enable()
    else
        objetivoJugador = false
        GMToolsInvisObjetivo = "NPC"
        s2.slider.Low:SetText("NPC")
        s2.slider.High:SetText("NPC")
        s2.slider:Disable()
    end
end

local s3 = crearDeslizador("DETECTION", "INVIS",
    function() return modoDetection end,
    function(esIzq)
        modoDetection = esIzq
        GMToolsInvisModo = esIzq and "DETECTION" or "INVIS"
        sincronizar()
    end, 40 + deslizadorSep)
GMToolsBtnModo = s3.slider

sincronizar()

-- ════════════════════════════════════════════════════════════
-- COMANDOS DE QUEST INVIS / DETECTION (copiados del NPCTinker)
-- Mapas de número → aura (1-20 completos)
-- ════════════════════════════════════════════════════════════
local QUEST_INVIS_MAP = {
    [1] = 49414,  [2] = 49415,  [3] = 60921,  [4] = 82343,  [5] = 80797,
    [6] = 82358,  [7] = 85096,  [8] = 78718,  [9] = 84886,  [10] = 80852,
    [11] = 83305, [12] = 83323, [13] = 84020, [14] = 81717, [15] = 83080,
    [16] = 84667, [17] = 90442, [18] = 87237, [19] = 84957, [20] = 85813,
    [21] = 87871, [22] = 87872, [23] = 89954, [24] = 94224, [25] = 94223,
    [26] = 94222, [27] = 89302, [28] = 89303, [29] = 89304,
}
local DETECTION_MAP = {
    [1] = 49416,  [2] = 49417,  [3] = 60922,  [4] = 90161,  [5] = 94566,
    [6] = 94567,  [7] = 94568,  [8] = 94569,  [9] = 94570,  [10] = 84481,
    [11] = 96737, [12] = 96823, [13] = 96832, [14] = 81742, [15] = 98392,
    [16] = 98433, [17] = 98546, [18] = 98564, [19] = 98920, [20] = 103339,
    [21] = 103458, [22] = 100044, [23] = 94184, [24] = 87418, [25] = 103059,
    [26] = 94226, [27] = 94227, [28] = 89306, [29] = 103786,
}

-- API para Tool-Control-Auras.lua: IDs de detección e invis quest para
-- EXCLUIRLOS del tercer listado ("el resto de auras").
GMToolsInvisDetectionIDs = DETECTION_MAP
GMToolsInvisQuestIDs = QUEST_INVIS_MAP

local function enviarComando(msg)
    SendChatMessage(msg, "SAY")
end

-- quitar=false → aplicar; quitar=true → quitar
local function aplicarQuitar(quitar)
    local num = valorSlot(seleccion)
    local msg
    if modoDetection then
        local id = DETECTION_MAP[num]
        if alcanceTodos then
            msg = quitar and (".ph unaura " .. id) or (".ph aura " .. id)
        else
            msg = quitar and (".unaura " .. id) or (".aura " .. id)
        end
    else
        local id = QUEST_INVIS_MAP[num]
        msg = quitar and (".npc set unaura " .. id) or (".npc set aura " .. id)
    end
    enviarComando(msg)
end

-- ════════════════════════════════════════════════════════════
-- CONTROLES BAJO LA RUEDA: ◀ anterior · APLICAR · siguiente ▶
-- (flechas con los mismos iconos del tab de diálogos)
-- ════════════════════════════════════════════════════════════
local function botonBase()
    local b = CreateFrame("Button", nil, frame, "BackdropTemplate")
    b:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    b:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
    b:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    b:RegisterForClicks("LeftButtonUp")
    return b
end

local btnAplicar = botonBase()
btnAplicar:SetSize(72, 28)
btnAplicar:SetPoint("TOP", dial, "BOTTOM", 0, -24)
local aplicarTexto = btnAplicar:CreateFontString(nil, "OVERLAY")
aplicarTexto:SetFont("Fonts\\FRIZQT__.TTF", 13)
aplicarTexto:SetPoint("CENTER")
aplicarTexto:SetText("APLICAR")
aplicarTexto:SetTextColor(1, 1, 1)
btnAplicar:SetScript("OnClick", function()
    ejecutar(aplicarQuitar, false)
end)
GMToolsBtnAplicar = btnAplicar

local function botonFlecha(icono)
    local b = botonBase()
    b:SetSize(28, 28)
    local tex = b:CreateTexture(nil, "OVERLAY")
    tex:SetPoint("TOPLEFT", b, "TOPLEFT", 3, -3)
    tex:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -3, 3)
    tex:SetTexture(icono)
    b.icono = tex
    return b
end

local btnIzq = botonFlecha("Interface\\Icons\\eps_arc_xtraarrowleft")
btnIzq:SetPoint("RIGHT", btnAplicar, "LEFT", -6, 0)
btnIzq:SetScript("OnClick", function()
    ejecutar(seleccionar, ((seleccion - 2) % N) + 1)
end)
GMToolsBtnIzq = btnIzq

local btnDer = botonFlecha("Interface\\Icons\\eps_arc_xtraarrowright")
btnDer:SetPoint("LEFT", btnAplicar, "RIGHT", 6, 0)
btnDer:SetScript("OnClick", function()
    ejecutar(seleccionar, (seleccion % N) + 1)
end)
GMToolsBtnDer = btnDer

-- Botón +/− a la derecha de ▶: alterna los números 1-9 por 21-29
-- (los demás no cambian; el giro sigue igual: 20 → 21 en vez de → 1)
-- Sin borde: solo el icono. Posición ajustable (X Y) con la ventanita
-- temporal de la izquierda.
local btnMasX, btnMasY = 8, 36
local btnMas = CreateFrame("Button", nil, frame)
btnMas:SetSize(28, 28)
btnMas.icono = btnMas:CreateTexture(nil, "OVERLAY")
btnMas.icono:SetPoint("TOPLEFT", btnMas, "TOPLEFT", 3, -3)
btnMas.icono:SetPoint("BOTTOMRIGHT", btnMas, "BOTTOMRIGHT", -3, 3)
btnMas.icono:SetTexture("Interface\\Icons\\hd_fellowshipplussign_mage")
btnMas:RegisterForClicks("LeftButtonUp")
-- Efecto hover: el propio icono se ilumina (tinte blanco aditivo, sin bordes)
btnMas:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
local hlMas = btnMas:GetHighlightTexture()
if hlMas then
    hlMas:SetVertexColor(1, 1, 1, 0.15)
    hlMas:SetPoint("TOPLEFT", btnMas, "TOPLEFT", 3, -3)
    hlMas:SetPoint("BOTTOMRIGHT", btnMas, "BOTTOMRIGHT", -3, 3)
end
btnMas:SetPoint("LEFT", btnDer, "RIGHT", btnMasX, btnMasY)
btnMas:SetScript("OnClick", function()
    ejecutar(function()
        extendido = not extendido
        btnMas.icono:SetTexture(extendido
            and "Interface\\Icons\\hd_fellowshipminussign_mage"
            or "Interface\\Icons\\hd_fellowshipplussign_mage")
        seleccionar(seleccion)
    end)
end)
GMToolsBtnMas = btnMas

-- Botón auxiliar: copia del de la pestaña de diálogos (pliega/despliega
-- la ventana intermedia). Aquí abre/cierra una ventana 200x200 a la
-- izquierda. Icono de la flecha <, mismo tamaño (31.2), efecto 15%.
local btnAuxX, btnAuxY = 36, -40
local btnAux = CreateFrame("Button", nil, frame)
btnAux:SetSize(31.2, 31.2)
local iconAux = btnAux:CreateTexture(nil, "OVERLAY")
iconAux:SetSize(21.6, 21.6)
iconAux:SetPoint("CENTER")
iconAux:SetTexture("Interface\\Icons\\eps_arc_xtraarrowleft")
btnAux:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
local hlAux = btnAux:GetHighlightTexture()
if hlAux then
    hlAux:SetVertexColor(1, 1, 1, 0.15)
    hlAux:SetPoint("TOPLEFT", btnAux, "TOPLEFT", 4.8, -4.8)
    hlAux:SetPoint("BOTTOMRIGHT", btnAux, "BOTTOMRIGHT", -4.8, 4.8)
end
btnAux:SetPoint("RIGHT", btnIzq, "LEFT", -btnAuxX, btnAuxY)
GMToolsBtnAux = btnAux

-- Ventana auxiliar (misma altura que la principal): su esquina
-- inferior derecha ancla a la esquina inferior izquierda de la
-- ventana. Muestra las auras de DETECTION del grupo.
local ventanaAux = CreateFrame("Frame", nil, frame, "BackdropTemplate")
ventanaAux:SetSize(290, 224)
panel(ventanaAux)
ventanaAux:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -10, 0)
ventanaAux:Hide()
btnAux:SetScript("OnClick", function()
    ejecutar(function()
        if ventanaAux:IsShown() then
            ventanaAux:Hide()
            iconAux:SetTexture("Interface\\Icons\\eps_arc_xtraarrowleft")
        else
            ventanaAux:Show()
            iconAux:SetTexture("Interface\\Icons\\eps_arc_xtraarrowright")
        end
    end)
end)

-- ════════════════════════════════════════════════════════════
-- SUBVENTANA INTERIOR: mismo diseño y estilo que la de diálogos
-- (la que contiene los diálogos, con su scroll vertical), pero
-- SIN poder plegarse. Cada línea es un aura: un DETECTION (1-29)
-- de la lista que tiene algún jugador de mi grupo.
-- ════════════════════════════════════════════════════════════
local subAux = CreateFrame("Frame", nil, ventanaAux, "BackdropTemplate")
subAux:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
subAux:SetBackdropColor(0.12, 0.18, 0.38, 0.82)
subAux:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
subAux:EnableMouse(true)
subAux:SetPoint("TOPLEFT", ventanaAux, "TOPLEFT", 8, -8)
subAux:SetPoint("BOTTOMRIGHT", ventanaAux, "BOTTOMRIGHT", -8, 40)

local scrollAux = CreateFrame("ScrollFrame", nil, subAux, "UIPanelScrollFrameTemplate")
scrollAux:SetPoint("TOPLEFT", subAux, "TOPLEFT", 6, -6)
scrollAux:SetPoint("BOTTOMRIGHT", subAux, "BOTTOMRIGHT", -6, 6)
local barraAux = scrollAux.ScrollBar
if barraAux then
    barraAux:ClearAllPoints()
    barraAux:SetPoint("TOPRIGHT", scrollAux, "TOPRIGHT", -5, -18)
    barraAux:SetPoint("BOTTOMRIGHT", scrollAux, "BOTTOMRIGHT", -5, 18)
end

local contentAux = CreateFrame("Frame", nil, scrollAux)
scrollAux:SetScrollChild(contentAux)
contentAux:SetWidth(scrollAux:GetWidth() - 20)

local placeholderAura = contentAux:CreateFontString(nil, "OVERLAY")
placeholderAura:SetPoint("TOPLEFT", contentAux, "TOPLEFT", 6, -6)
placeholderAura:SetFont("Fonts\\FRIZQT__.TTF", 12)
placeholderAura:SetTextColor(0.6, 0.6, 0.6)
placeholderAura:SetText("Sin auras de detección en el grupo")
placeholderAura:Hide()

local filasAura = {}

local function truncar(texto, max)
    texto = tostring(texto or "")
    if #texto > max then
        return texto:sub(1, max) .. "..."
    end
    return texto
end

local function botonMiniAura(parent, texto, r, g, b)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(texto == "QUITAR" and 56 or 64, 24)
    btn:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, tileSize = 8, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    btn:SetBackdropColor(r, g, b, 0.9)
    btn:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    btn:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
    btn:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.15)
    local t = btn:CreateFontString(nil, "OVERLAY")
    t:SetFont("Fonts\\FRIZQT__.TTF", 12)
    t:SetPoint("CENTER")
    t:SetText(texto)
    t:SetTextColor(1, 1, 1)
    btn:RegisterForClicks("LeftButtonUp")
    return btn
end

local function crearFilaAura()
    local fila = CreateFrame("Button", nil, contentAux)
    fila:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
    local hlFila = fila:GetHighlightTexture()
    if hlFila then
        hlFila:SetVertexColor(1, 1, 1, 0.12)
        -- Línea iluminada al pasar el ratón: 2px más alta por arriba
        -- y 2px más alta por abajo
        hlFila:ClearAllPoints()
        hlFila:SetPoint("TOPLEFT", fila, "TOPLEFT", 0, 2)
        hlFila:SetPoint("BOTTOMRIGHT", fila, "BOTTOMRIGHT", 0, 0)
    end

    local lbl = fila:CreateFontString(nil, "OVERLAY")
    lbl:SetPoint("TOPLEFT", fila, "TOPLEFT", 4, -4)
    lbl:SetJustifyH("LEFT")
    lbl:SetFont("Fonts\\FRIZQT__.TTF", 12)
    lbl:SetText("Detection ")
    lbl:SetTextColor(1, 1, 1)
    fila.lbl = lbl

    local num = fila:CreateFontString(nil, "OVERLAY")
    num:SetPoint("LEFT", lbl, "RIGHT", 0, 0)
    num:SetJustifyH("LEFT")
    num:SetFont("Fonts\\FRIZQT__.TTF", 12)
    num:SetTextColor(1, 0.85, 0)
    fila.num = num

    local aviso = fila:CreateFontString(nil, "OVERLAY")
    aviso:SetPoint("TOPLEFT", fila, "TOPLEFT", 4, -21)
    aviso:SetJustifyH("LEFT")
    aviso:SetFont("Fonts\\FRIZQT__.TTF", 10)
    aviso:SetText("¡No la tienen todos!")
    aviso:SetTextColor(1, 0.3, 0.3)
    aviso:Hide()
    fila.aviso = aviso

    local btnQuitar = botonMiniAura(fila, "QUITAR", 0.4, 0.1, 0.1)
    btnQuitar:SetPoint("RIGHT", fila, "RIGHT", -4, 1)
    fila.btnQuitar = btnQuitar

    local btnPH = botonMiniAura(fila, "PH AURA", 0.1, 0.11, 0.15)
    btnPH:SetPoint("RIGHT", btnQuitar, "LEFT", -3, 0)
    fila.btnPH = btnPH

    return fila
end

-- ════════════════════════════════════════════════════════════
-- ESCÁNER DE AURAS DE DETECTION EN EL GRUPO
-- Mientras la ventana de invis esté activa, revisa a los
-- jugadores de mi raid/grupo y busca las auras de detección
-- de la lista (1-29). Si alguien la tiene, sale una línea.
-- (API de Shadowlands 9.x: UnitAura / AuraUtil.ForEachAura;
-- eventos UNIT_AURA por unidad + GROUP_ROSTER_UPDATE)
-- ════════════════════════════════════════════════════════════
-- Mapa id de hechizo → número (1-29) por si algún aura llega con id real
local DETECCION_POR_ID = {}
for n = 1, 29 do
    DETECCION_POR_ID[DETECTION_MAP[n]] = n
end

local function unidadesGrupo()
    local lista = { "player" }
    local n = GetNumGroupMembers() or 0
    local prefijo = IsInRaid() and "raid" or "party"
    for i = 1, n do
        lista[#lista + 1] = prefijo .. i
    end
    return lista
end

-- El cliente no conoce estos hechizos: UnitAura devuelve id=0 y el
-- nombre genérico "Generic Quest Invisibility Detection N", donde N
-- es el número de la lista (1-29). Se detecta por ese patrón.
local function numeroDeAura(nombre, id)
    if id then
        local n = DETECCION_POR_ID[id]
        if n then return n end
    end
    if nombre then
        local n = tonumber(nombre:match("Detection%s+(%d+)$"))
        if n and n >= 1 and n <= 29 then return n end
    end
    return nil
end

local function aurasDetectadas(unidad)
    local resultado, visto = {}, {}
    -- 1) Iteración segura con AuraUtil (si existe)
    if AuraUtil and AuraUtil.ForEachAura then
        pcall(function()
            AuraUtil.ForEachAura(unidad, nil, 64, function(d)
                if d then
                    local num = numeroDeAura(d.name, d.spellId)
                    if num and not visto[num] then
                        visto[num] = true
                        resultado[#resultado + 1] = num
                    end
                end
            end)
        end)
    end
    -- 2) Recorrido manual complementario: buffs y debuffs
    for _, filtro in ipairs({ "HELPFUL", "HARMFUL" }) do
        for i = 1, 40 do
            local nombre, _, _, _, _, _, _, _, _, _, id = UnitAura(unidad, i, filtro)
            if not nombre then break end
            local num = numeroDeAura(nombre, id)
            if num and not visto[num] then
                visto[num] = true
                resultado[#resultado + 1] = num
            end
        end
    end
    return resultado
end

local anterior = {}
local avisoActivo = false

local function refrescarAuras()
    if not frame:IsShown() then return end
    for _, r in ipairs(filasAura) do r:Hide() end
    -- EN GENERAL: si cualquier jugador del grupo (incluido yo)
    -- tiene el aura N, esa aura aparece UNA vez en el listado.
    -- conteo = cuántos jugadores del grupo la tienen (para el rojo)
    local presentes, conteo, actual = {}, {}, {}
    local jugadoresCon = {}
    local unidades = unidadesGrupo()
    local total = 0
    for _, u in ipairs(unidades) do
        if UnitExists(u) and UnitIsConnected(u) then
            total = total + 1
            actual[u] = {}
            local nombreUnidad = UnitName(u) or u
            for _, num in ipairs(aurasDetectadas(u)) do
                presentes[num] = true
                conteo[num] = (conteo[num] or 0) + 1
                actual[u][num] = true
                local lista = jugadoresCon[num]
                if not lista then
                    lista = {}
                    jugadoresCon[num] = lista
                end
                lista[#lista + 1] = nombreUnidad
            end
        end
    end
    -- Aviso: si alguien se quita un aura de la lista (y el aviso está on)
    if avisoActivo then
        local enGrupo = {}
        for _, u in ipairs(unidades) do
            if UnitExists(u) and UnitIsConnected(u) then enGrupo[u] = true end
        end
        for u in pairs(anterior) do
            if not enGrupo[u] then anterior[u] = nil end
        end
        for u, nums in pairs(anterior) do
            local ahora = actual[u]
            for num in pairs(nums) do
                if not (ahora and ahora[num]) then
                    local nombre = UnitName(u) or u
                    DEFAULT_CHAT_FRAME:AddMessage(
                        ("|cffff3030[¡Atención!]|r |cffffff00El jugador %s se ha quitado Detection [%d]|r"):format(nombre, num))
                end
            end
        end
    end
    anterior = actual
    local nums = {}
    for num in pairs(presentes) do nums[#nums + 1] = num end
    table.sort(nums)
    if #nums == 0 then
        placeholderAura:Show()
    else
        placeholderAura:Hide()
    end
    local anchoFila = math.max(50, contentAux:GetWidth() - 6)
    local posY = -6
    local altoTotal = 0
    for i, num in ipairs(nums) do
        local fila = filasAura[i]
        if not fila then
            fila = crearFilaAura()
            filasAura[i] = fila
        end
        -- ROJO si no la tiene el 100% del grupo: fila más alta y aviso
        local completa = (conteo[num] or 0) >= total
        local alto = completa and 24 or 37
        fila:SetSize(anchoFila, alto)
        fila:ClearAllPoints()
        fila:SetPoint("TOPLEFT", contentAux, "TOPLEFT", 0, posY)
        -- Botones centrados con el texto "Detection ..." (centro con centro)
        fila.btnQuitar:ClearAllPoints()
        fila.btnQuitar:SetPoint("RIGHT", fila, "RIGHT", -4, -11 + alto / 2)
        fila.btnPH:ClearAllPoints()
        fila.btnPH:SetPoint("RIGHT", fila.btnQuitar, "LEFT", -3, 0)
        fila.lbl:SetText("Detection ")
        fila.num:SetText(string.format("[%d]", num))
        if completa then
            fila.lbl:SetTextColor(1, 1, 1)
            fila.num:SetTextColor(1, 0.85, 0)
            fila.aviso:Hide()
        else
            fila.lbl:SetTextColor(1, 0.3, 0.3)
            fila.num:SetTextColor(1, 0.3, 0.3)
            fila.aviso:Show()
        end
        local id = DETECTION_MAP[num]
        fila.btnPH:SetScript("OnClick", function()
            ejecutar(enviarComando, (".ph aura %d"):format(id))
        end)
        fila.btnQuitar:SetScript("OnClick", function()
            ejecutar(enviarComando, (".ph unaura %d"):format(id))
        end)
        -- Tooltip (mismo que en Tool-Control-Auras): nombre en dorado,
        -- jugadores que la tienen en blanco y, en rojo, los del
        -- grupo que NO la tienen (o el "√" en verde si no falta nadie).
        local con = jugadoresCon[num] or {}
        local conAura = {}
        for _, n in ipairs(con) do conAura[n] = true end
        local sinAura = {}
        for _, u in ipairs(unidades) do
            if UnitExists(u) and UnitIsConnected(u) then
                local nm = UnitName(u) or u
                if not conAura[nm] then sinAura[#sinAura + 1] = nm end
            end
        end
        local listaCon = table.concat(con, ", ")
        local listaSin = table.concat(sinAura, ", ")
        fila:SetScript("OnEnter", function()
            GameTooltip:SetOwner(fila, "ANCHOR_TOP")
            GameTooltip:ClearLines()
            GameTooltip:AddLine("Detection [" .. num .. "]", 1, 0.85, 0)
            GameTooltip:AddLine(listaCon, 1, 1, 1, true)
            if #sinAura > 0 then
                GameTooltip:AddLine(listaSin, 1, 0.3, 0.3, true)
            else
                GameTooltip:AddLine("√ Todos los jugadores del grupo", 0, 1, 0, true)
            end
            GameTooltip:Show()
        end)
        fila:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        fila:Show()
        altoTotal = altoTotal + alto + 2
        posY = posY - alto - 2
    end
    local contenidoNecesario = 6 + altoTotal
    contentAux:SetHeight(math.max(contenidoNecesario, scrollAux:GetHeight()))
    scrollAux:UpdateScrollChildRect()
    -- Altura automática: la ventana crece con las filas (máx 389) y
    -- se encoge al quitarlas (mín 224)
    ventanaAux:SetHeight(math.max(224, math.min(389, contenidoNecesario + 60)))
end

local escaner = CreateFrame("Frame")
escaner:SetScript("OnEvent", function(self, evento)
    if evento == "UNIT_AURA" or evento == "UNIT_CONNECTION" then
        if frame:IsShown() then refrescarAuras() end
    elseif evento == "GROUP_ROSTER_UPDATE" then
        if frame:IsShown() then
            self:UnregisterEvent("UNIT_AURA")
            self:RegisterUnitEvent("UNIT_AURA", unpack(unidadesGrupo()))
            refrescarAuras()
        end
    end
end)

local function activarEscaner()
    escaner:RegisterEvent("GROUP_ROSTER_UPDATE")
    escaner:UnregisterEvent("UNIT_AURA")
    escaner:RegisterUnitEvent("UNIT_AURA", unpack(unidadesGrupo()))
    escaner:RegisterUnitEvent("UNIT_CONNECTION", unpack(unidadesGrupo()))
    refrescarAuras()
end

local function desactivarEscaner()
    escaner:UnregisterEvent("UNIT_AURA")
    escaner:UnregisterEvent("UNIT_CONNECTION")
    escaner:UnregisterEvent("GROUP_ROSTER_UPDATE")
    anterior = {}
    for _, r in ipairs(filasAura) do r:Hide() end
end

frame:SetScript("OnShow", activarEscaner)
frame:SetScript("OnHide", desactivarEscaner)

ventanaAux:SetScript("OnShow", function()
    if frame:IsShown() then refrescarAuras() end
end)



-- ════════════════════════════════════════════════════════════
-- BANDA INFERIOR (40px): checkbox "Avisarme si no concuerdan".
-- Si está marcado, avisa al instante en el chat cuando alguien
-- se quita un aura de la lista de 29.
-- ════════════════════════════════════════════════════════════
local btnCheck = CreateFrame("Button", nil, ventanaAux, "BackdropTemplate")
btnCheck:SetSize(20, 20)
btnCheck:SetPoint("BOTTOMLEFT", ventanaAux, "BOTTOMLEFT", 10, 10)
btnCheck:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true, tileSize = 8, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
btnCheck:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
btnCheck:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
local hlCheck = btnCheck:GetHighlightTexture()
if hlCheck then hlCheck:SetAlpha(0.3) end
local marcaCheck = btnCheck:CreateFontString(nil, "OVERLAY")
marcaCheck:SetFont("Fonts\\FRIZQT__.TTF", 16)
marcaCheck:SetPoint("CENTER", -0.5, -0.5)
marcaCheck:SetTextColor(1, 1, 1)

local lblCheck = ventanaAux:CreateFontString(nil, "OVERLAY")
lblCheck:SetFont("Fonts\\FRIZQT__.TTF", 12)
lblCheck:SetPoint("LEFT", btnCheck, "RIGHT", 6, 0)
lblCheck:SetTextColor(1, 1, 1)
lblCheck:SetText("Recibir avisos de cambios.")

local infoCheck = CreateFrame("Button", nil, ventanaAux)
infoCheck:SetSize(29, 29)
infoCheck:SetPoint("LEFT", lblCheck, "RIGHT", 0, 2)
local infoTex = infoCheck:CreateTexture(nil, "OVERLAY")
infoTex:SetAllPoints()
infoTex:SetTexture("Interface\\Common\\help-i")
local TEXTO_INFO_CHECK = "En la pestaña superior se muestran los detections que tienen activos los jugadores. Al marcar esta opción te avisará en el chat cuando un jugador se quite por su cuenta una de las auras."
infoCheck:SetScript("OnEnter", function()
    GameTooltip:SetOwner(infoCheck, "ANCHOR_LEFT")
    GameTooltip:SetText(TEXTO_INFO_CHECK, nil, nil, nil, nil, true)
    GameTooltip:Show()
end)
infoCheck:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

local function pintarCheck()
    if avisoActivo then
        marcaCheck:SetText("×")
        btnCheck:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    else
        marcaCheck:SetText("")
        btnCheck:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.9)
    end
end
pintarCheck()

btnCheck:SetScript("OnClick", function()
    ejecutar(function()
        avisoActivo = not avisoActivo
        pintarCheck()
    end)
end)

-- Botón QUITAR: mismo tamaño y diseño que APLICAR, debajo de él
-- (misma separación de 6px que APLICAR tiene con las flechas).
-- Al pasar el ratón por encima: mismo efecto de resaltado, pero rojo.
local btnQuitar = botonBase()
btnQuitar:SetSize(72, 28)
btnQuitar:SetPoint("TOP", btnAplicar, "BOTTOM", 0, -6)
local quitarTexto = btnQuitar:CreateFontString(nil, "OVERLAY")
quitarTexto:SetFont("Fonts\\FRIZQT__.TTF", 13)
quitarTexto:SetPoint("CENTER")
quitarTexto:SetText("QUITAR")
quitarTexto:SetTextColor(1, 1, 1)
btnQuitar:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
local hlQuitar = btnQuitar:GetHighlightTexture()
if hlQuitar then hlQuitar:SetVertexColor(1, 0.2, 0.2) end
btnQuitar:SetScript("OnClick", function()
    ejecutar(aplicarQuitar, true)
end)
GMToolsBtnQuitar = btnQuitar

posicionar()
lblSeleccion:SetText(valorSlot(seleccion))

end)

-- ════════════════════════════════════════════════════════════
-- RED DE SEGURIDAD: el botón se cablea aquí, fuera del pcall,
-- usando solo globals. Si algo fallara dentro del pcall, el
-- botón nunca queda muerto.
-- ════════════════════════════════════════════════════════════
local btnSeguro = GMToolsBtnInvis
if btnSeguro then
    btnSeguro:RegisterForClicks("LeftButtonUp")
    btnSeguro:SetScript("OnClick", function()
        local f = GMToolsInvisFrame
        if not f then return end
        if f:IsShown() then f:Hide() else f:Show() end
    end)
end

SLASH_GMINVIS1 = "/invis"
SLASH_GMINVIS2 = "/detection"
SlashCmdList["GMINVIS"] = function()
    local f = GMToolsInvisFrame
    if not f then return end
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
    end
end
