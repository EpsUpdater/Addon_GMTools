-- ════════════════════════════════════════════════════════════
-- Tool-Control-Auras.lua
-- Pestaña "Control de Auras": ventana estrecha (500px) con 2
-- subventanas verticales que detectan en tiempo real las auras de
-- los jugadores del grupo:
--   1ª SCREENFX/SKYBOX → auras con "Screeneffect"/"skybox" en el
--                        nombre, o cuyo id es uno de los skyboxes
--                        (mitad del alto por defecto; crece solo si
--                        su lista lo pide, sin tocar a la de abajo).
--   BANDA DE AVISOS    → checkbox "Recibir avisos de cambios." (la
--                        misma función que la pestaña de Invis):
--                        avisa en el chat cuando un jugador se
--                        quita por su cuenta un skybox de la
--                        ventana de encima.
--   2ª OTRAS           → el resto de auras (incluye invis/detection
--                        de la pestaña de Tool-Invis).
--                        Sin aviso.
-- Mismo sistema de detección que Invis (escaner por eventos y filas
-- con QUITAR/PH AURA a la derecha).
-- La ventana sale a media altura (370) y se puede agrandar hasta
-- 740; las subventanas reparten el espacio (2/3 − 1/3).
-- EXCLUYE a las demás pestañas: al abrirla se cierran skyboxes y
-- weather. Se guarda su propia posición al moverla.
-- ════════════════════════════════════════════════════════════

local ok, err = pcall(function()

local PAD_SIDE = 8
local SEARCH_H = 32
local WIN_W    = 500
local WIN_H_DEF = 370  -- altura por defecto (mitad)
local WIN_H_MAX = 740  -- altura máxima al crecer con las filas

local escaner
local function activarEscaner() end
local function desactivarEscaner() end
local function recalcular() end

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
    frame:SetBackdropColor(0.12, 0.18, 0.38, 0.82)
    frame:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
end

local ctrlVentana

-- Abre esta ventana. Si se pasa "desde" (la pestaña base activa),
-- se coloca con su esquina superior derecha EXACTA en la de esa
-- pestaña (encajada arriba a la derecha), guardando esa posición
-- como la compartida de esta ventana.
function GMToolsControlAurasAbrir(desde)
    if desde and desde:IsShown() then
        local r, t = desde:GetRight(), desde:GetTop()
        if r and t and ctrlVentana then
            GMToolsControlAurasPos = { math.floor(r - ctrlVentana:GetWidth()), math.floor(t - ctrlVentana:GetHeight()) }
        end
    end
    if GMToolsControlAurasFrame then
        GMToolsControlAurasFrame:Show()
    end
    -- Esta función solo se llama desde clicks reales de botones
    -- (contexto de usuario garantizado): se dispara la cola de
    -- lookups de ids pendientes para el borde dorado.
    if GMTOOLS_SKY_DISP_COLA then GMTOOLS_SKY_DISP_COLA() end
end

ctrlVentana = CreateFrame("Frame", "GMToolsControlAurasFrame", UIParent, "BackdropTemplate")
ctrlVentana:SetSize(WIN_W, WIN_H_DEF)
ApplyDarkPanel(ctrlVentana)
ctrlVentana:EnableMouse(true)
ctrlVentana:SetMovable(true)
ctrlVentana:SetClampedToScreen(true)
ctrlVentana:RegisterForDrag("LeftButton")
ctrlVentana:SetScript("OnDragStart", ctrlVentana.StartMoving)
ctrlVentana:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local l, b = self:GetLeft(), self:GetBottom()
    if l and b then
        GMToolsControlAurasPos = { math.floor(l), math.floor(b) }
    end
end)
ctrlVentana:Hide()

-- ════════════════════════════════════════════════════════════
-- BOTÓN EN LA SUBVENTANA IZQUIERDA (fila 2, col 2: entre skybox
-- e invis), mismo estilo que los de la rejilla. Abre/cierra
-- esta ventana.
-- ════════════════════════════════════════════════════════════
local subVentanaIzq = _G["GMToolsSubVentanaIzq"]
local btnAuras = CreateFrame("Button", nil, subVentanaIzq or UIParent)
btnAuras:SetSize(37, 37)
if subVentanaIzq then
    btnAuras:SetPoint("TOPLEFT", subVentanaIzq, "TOPLEFT", 86, -45)
end

local iconAuras = btnAuras:CreateTexture(nil, "BACKGROUND")
iconAuras:SetSize(36, 36)
iconAuras:SetPoint("CENTER")
iconAuras:SetTexture("Interface\\AddOns\\GMTools\\icons\\icono-auras")

local glowAurasOk = pcall(function()
    btnAuras:SetHighlightAtlas("ChallengeMode-KeystoneSlotFrameGlow")
end)
if glowAurasOk then
    local glow = btnAuras:GetHighlightTexture()
    glow:ClearAllPoints()
    glow:SetPoint("CENTER")
    glow:SetSize(37 * 1.66, 37 * 1.66)
    glow:SetAlpha(0.5)
end

GMToolsBtnAuras = btnAuras
btnAuras:RegisterForClicks("LeftButtonUp")
btnAuras:SetScript("OnClick", function()
    if ctrlVentana:IsShown() then
        ctrlVentana:Hide()
    else
        GMToolsControlAurasAbrir()
    end
end)

ctrlVentana:SetScript("OnShow", function()
    -- Exclusivo: al abrir esta ventana se cierran las demás pestañas
    if GMToolsSkyboxFrame then GMToolsSkyboxFrame:Hide() end
    if GMToolsWeatherFrame then GMToolsWeatherFrame:Hide() end
    -- Posición guardada; si no hay ninguna, esquina superior derecha.
    -- La ventana se ancla por el borde SUPERIOR (el alto guardado se
    -- convierte al momento): así el crecimiento automático (SetHeight
    -- al refrescar) extiende la ventana hacia abajo sin mover su
    -- esquina, y al abrirla desde skyboxes no se desplaza arriba.
    if GMToolsControlAurasPos then
        local l, b = GMToolsControlAurasPos[1], GMToolsControlAurasPos[2]
        local al = ctrlVentana:GetHeight() or WIN_H_DEF
        -- OJO CON EL SIGNO: el ancla TOPLEFT de UIParent está arriba del
        -- todo; el offset en Y se suma a esa y (hacia ARRIBA), por eso
        -- para poner el borde superior en y=b+al hay que restar: dy = y - altoPantalla.
        local dy = (b + al) - (UIParent:GetHeight() or 0)
        ctrlVentana:ClearAllPoints()
        ctrlVentana:SetPoint("TOPLEFT", UIParent, "TOPLEFT", l, dy)
    else
        -- Sin posición guardada: primera vez. Esquina inf. derecha de
        -- esta ventana pegada a la esquina sup. derecha de la pestaña
        -- derecha de GMTools, 5 px por encima. El ancla es TOPRIGHT de
        -- UIParent, así que dy = (arriba deseado) - altoPantalla.
        local der = GMToolsFrame
        local r, t = der and der:GetRight() or nil, der and der:GetTop() or nil
        if r and t then
            local al = ctrlVentana:GetHeight() or WIN_H_DEF
            local ph = UIParent:GetHeight() or 0
            ctrlVentana:ClearAllPoints()
            ctrlVentana:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", r - (UIParent:GetWidth() or 0), (t + 5 + al) - ph)
        else
            ctrlVentana:ClearAllPoints()
            ctrlVentana:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -30, -60)
        end
    end
    recalcular()
    activarEscaner()
end)
ctrlVentana:SetScript("OnHide", desactivarEscaner)
ctrlVentana:SetScript("OnSizeChanged", function()
    recalcular()
end)

-- ════════════════════════════════════════════════════════════
-- BARRA SUPERIOR: X de cerrar + botones "Skyboxes" y "Weather"
-- (al pulsarlos, esta ventana se cierra y se abre la elegida).
-- ════════════════════════════════════════════════════════════
local searchRow = CreateFrame("Frame", nil, ctrlVentana, "BackdropTemplate")
searchRow:SetHeight(SEARCH_H)
searchRow:SetPoint("TOPLEFT",  ctrlVentana, "TOPLEFT",   PAD_SIDE, -PAD_SIDE)
searchRow:SetPoint("TOPRIGHT", ctrlVentana, "TOPRIGHT", -PAD_SIDE, -PAD_SIDE)
ApplyDarkPanel(searchRow)
searchRow:SetBackdropColor(0.1, 0.11, 0.15, 0.9)

local closeButton = CreateFrame("Button", nil, searchRow)
closeButton:SetSize(26, 26)
closeButton:SetPoint("RIGHT", searchRow, "RIGHT", -4, 0)
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
closeButton:SetScript("OnClick", function() ctrlVentana:Hide() end)

local function crearBotonEstilo(wrapper, texto, ancho, onClic)
    wrapper:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    wrapper:SetBackdropBorderColor(0, 0, 0, 0)

    local btn = CreateFrame("Button", nil, wrapper, "BackdropTemplate")
    btn:SetSize(ancho, math.floor((SEARCH_H - 10) * 0.9))
    btn:SetPoint("CENTER", wrapper, "CENTER", 0, 0)
    btn:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    btn:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
    btn:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER", btn, "CENTER", 0, 0)
    label:SetText(texto)
    label:SetTextColor(1, 0.85, 0)

    btn:SetScript("OnClick", onClic)
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.2, 0.3, 0.55, 0.95)
        self:SetBackdropBorderColor(0.5, 0.75, 1, 1)
        wrapper:SetBackdropBorderColor(0.9, 0.75, 0.1, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
        self:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
        wrapper:SetBackdropBorderColor(0, 0, 0, 0)
    end)
    return btn
end

-- "Skyboxes" — junto a la X: cierra esta y abre skyboxes
local wrapperSky = CreateFrame("Frame", nil, searchRow, "BackdropTemplate")
wrapperSky:SetSize(76, SEARCH_H - 6)
wrapperSky:SetPoint("RIGHT", closeButton, "LEFT", -6, 0)
crearBotonEstilo(wrapperSky, "Skyboxes", 72, function()
    ctrlVentana:Hide()
    if GMToolsWeatherFrame then GMToolsWeatherFrame:Hide() end
    if GMToolsSkyboxFrame then GMToolsSkyboxFrame:Show() end
    -- Click real (contexto de usuario): dispara la carga completa
    -- de ids pendientes al volver a la pestaña de skyboxes.
    if GMTOOLS_SKY_DISP_COLA then GMTOOLS_SKY_DISP_COLA() end
end)

-- "Weather" — a la izquierda: cierra esta y abre weather
local wrapperW = CreateFrame("Frame", nil, searchRow, "BackdropTemplate")
wrapperW:SetSize(76, SEARCH_H - 6)
wrapperW:SetPoint("RIGHT", wrapperSky, "LEFT", -6, 0)
crearBotonEstilo(wrapperW, "Weather", 72, function()
    ctrlVentana:Hide()
    if GMToolsSkyboxFrame then GMToolsSkyboxFrame:Hide() end
    if GMToolsWeatherFrame then GMToolsWeatherFrame:Show() end
end)

-- ════════════════════════════════════════════════════════════
-- BOTÓN TODOS / SOLO YO (copiado de la pestaña de skyboxes):
-- elige el alcance de los comandos de PH AURA / QUITAR:
--   TODOS   → .ph aura/.ph unaura (afecta a todos)
--   SOLO YO → .aura/.unaura (solo a ti)
-- Por defecto TODOS. El texto activo se ilumina en dorado y el
-- inactivo queda gris. A su izquierda, el texto blanco "Auras"
-- pegado a la izquierda del subpanel que contiene los botones.
-- ════════════════════════════════════════════════════════════
local alcanceTodos = true

local btnAlcance = CreateFrame("Frame", nil, searchRow, "BackdropTemplate")
btnAlcance:SetSize(160, math.floor((SEARCH_H - 10) * 0.9))
btnAlcance:SetPoint("RIGHT", wrapperW, "LEFT", -10, 0)
btnAlcance:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true, tileSize = 16, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
btnAlcance:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
btnAlcance:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

local function crearMitad(lado)
    local mitad = CreateFrame("Button", nil, btnAlcance)
    mitad:SetSize(80, math.floor((SEARCH_H - 10) * 0.9))
    if lado == "izq" then
        mitad:SetPoint("LEFT", btnAlcance, "LEFT", 0, 0)
    else
        mitad:SetPoint("RIGHT", btnAlcance, "RIGHT", 0, 0)
    end
    mitad:EnableMouse(true)

    local luz = mitad:CreateTexture(nil, "BACKGROUND")
    luz:SetColorTexture(0.2, 0.3, 0.55, 0.95)
    luz:SetPoint("TOPLEFT", mitad, "TOPLEFT", 1, -1)
    luz:SetPoint("BOTTOMRIGHT", mitad, "BOTTOMRIGHT", -1, 1)
    luz:Hide()

    local lbl = mitad:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    if lado == "izq" then
        lbl:SetPoint("LEFT", mitad, "LEFT", 8, 0)
    else
        lbl:SetPoint("RIGHT", mitad, "RIGHT", -8, 0)
    end
    return mitad, luz, lbl
end

local mitadIzq, luzIzq, lblTodos  = crearMitad("izq")
lblTodos:SetText("TODOS")
local mitadDer, luzDer, lblSoloYo = crearMitad("der")
lblSoloYo:SetText("SOLO YO")

local function pintarAlcance()
    if alcanceTodos then
        lblTodos:SetTextColor(1, 0.85, 0)
        lblSoloYo:SetTextColor(0.5, 0.55, 0.62)
    else
        lblTodos:SetTextColor(0.5, 0.55, 0.62)
        lblSoloYo:SetTextColor(1, 0.85, 0)
    end
end

local function pintarLuz()
    luzIzq:SetShown(alcanceTodos)
    luzDer:SetShown(not alcanceTodos)
end

mitadIzq:SetScript("OnClick", function()
    alcanceTodos = true
    pintarAlcance()
    pintarLuz()
end)

mitadDer:SetScript("OnClick", function()
    alcanceTodos = false
    pintarAlcance()
    pintarLuz()
end)

-- Icono de info a la izquierda de TODOS/SOLO YO: explica el alcance y
-- el click derecho invertido de los botones de las auras.
local TEXTO_ALCANCE = "Intercambia entre aplicar el aura a todos los jugadores de la fase o solo a ti.\nAdemás pulsar click derecho en los botones de las auras hará la función contraria, es decir, si haces click derecho en PH AURA, aplicará solo el comando aura (solo a ti). Lo mismo para quitar y viceversa."
local infoAlcance = CreateFrame("Button", nil, searchRow)
infoAlcance:SetSize(24, 24)
infoAlcance:SetPoint("RIGHT", btnAlcance, "LEFT", -8, 0)
local infoTex = infoAlcance:CreateTexture(nil, "OVERLAY")
infoTex:SetAllPoints()
infoTex:SetTexture("Interface\\Common\\help-i")
infoAlcance:SetScript("OnEnter", function()
    GameTooltip:SetOwner(infoAlcance, "ANCHOR_TOP")
    GameTooltip:SetText(TEXTO_ALCANCE, nil, nil, nil, nil, true)
    GameTooltip:Show()
end)
infoAlcance:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

pintarAlcance()
pintarLuz()

-- Texto blanco "Auras" pegado al borde izquierdo de la barra (5px)
local lblAuras = searchRow:CreateFontString(nil, "OVERLAY")
lblAuras:SetFont("Fonts\\FRIZQT__.TTF", 13)
lblAuras:SetPoint("LEFT", searchRow, "LEFT", 10, 0)
lblAuras:SetTextColor(1, 1, 1)
lblAuras:SetText("Auras")

-- ════════════════════════════════════════════════════════════
-- 2 SUBVENTANAS VERTICALES: cada una es un listado con scroll
-- (mismo diseño que la subventana de detección de Invis: panel
-- oscuro con borde). La 1ª (Screeneffect/Skybox) ocupa 2/3 por
-- defecto y la 2ª (Resto) el 1/3 restante.
-- ════════════════════════════════════════════════════════════
local GAP_SUB = 8
local BANDA_AVISO_H = 40  -- banda "Recibir avisos de cambios" (igual que Invis)
-- Cada subventana tiene su PROPIO alto: la mitad del mínimo de la
-- ventana (129) cuando no hay filas, y crece solo ella (hasta 314)
-- si su lista lo pide, sin tocar a la otra. 112 + 129*2 = 370 (mín)
-- y 112 + 314*2 = 740 (máx).
local MIN_SUB = 129
local MAX_SUB = 314
local subAncho = WIN_W - 2 * PAD_SIDE
local TITULOS = { "Skybox", "Resto de auras" }

local subs = {}

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
    btn.etiqueta = t  -- el texto se puede cambiar en caliente (AURA/PH AURA)
    -- Click izquierdo = función normal; click derecho = función
    -- CONTRARIA (según TODOS/SOLO YO), p.ej. PH AURA con derecho
    -- aplica solo a ti, y en modo SOLO YO aplica a todos.
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    return btn
end

local function crearFila(sub)
    local fila = CreateFrame("Button", nil, sub.content)
    fila:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
    local hlFila = fila:GetHighlightTexture()
    if hlFila then
        hlFila:SetVertexColor(1, 1, 1, 0.12)
        hlFila:ClearAllPoints()
        hlFila:SetPoint("TOPLEFT", fila, "TOPLEFT", 0, 2)
        hlFila:SetPoint("BOTTOMRIGHT", fila, "BOTTOMRIGHT", 0, 0)
    end

    local lbl = fila:CreateFontString(nil, "OVERLAY")
    lbl:SetPoint("TOPLEFT", fila, "TOPLEFT", 4, -4)
    -- El texto no se mete por debajo de los botones (que están a la
    -- derecha): se reserva el ancho de QUITAR+PH AURA en la fila.
    lbl:SetPoint("TOPRIGHT", fila, "TOPRIGHT", -140, -4)
    lbl:SetJustifyH("LEFT")
    lbl:SetFont("Fonts\\FRIZQT__.TTF", 12)
    lbl:SetText("")
    lbl:SetTextColor(1, 1, 1)
    fila.lbl = lbl

    -- Lista de jugadores que tienen el aura (solo en "Resto de auras"):
    -- texto gris junto al nombre, truncado; al pasar el ratón por la
    -- fila, tooltip con la lista completa por si se cortó.
    local jugadores = fila:CreateFontString(nil, "OVERLAY")
    jugadores:SetPoint("TOPLEFT", fila, "TOPLEFT", 4, -4)
    jugadores:SetPoint("RIGHT", fila, "RIGHT", -140, 0)
    jugadores:SetJustifyH("LEFT")
    jugadores:SetFont("Fonts\\FRIZQT__.TTF", 10)
    jugadores:SetTextColor(0.65, 0.65, 0.65)
    jugadores:SetText("")
    fila.jugadores = jugadores

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

local prevSub = nil
for i = 1, 2 do
    local sub = CreateFrame("Frame", nil, ctrlVentana, "BackdropTemplate")
    sub:SetWidth(subAncho)
    ApplyDarkPanel(sub)
    if i == 1 then
        sub:SetPoint("TOP", searchRow, "BOTTOM", 0, -GAP_SUB)
    else
        sub:SetPoint("TOP", prevSub, "BOTTOM", 0, -GAP_SUB)
    end

    -- Título de la subventana
    local titulo = sub:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    titulo:SetPoint("TOPLEFT", sub, "TOPLEFT", 8, -6)
    titulo:SetText(TITULOS[i])
    titulo:SetTextColor(1, 0.85, 0)

    -- Scroll interior
    local scroll = CreateFrame("ScrollFrame", nil, sub, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", sub, "TOPLEFT", 6, -24)
    scroll:SetPoint("BOTTOMRIGHT", sub, "BOTTOMRIGHT", -6, 6)
    local barra = scroll.ScrollBar
    if barra then
        barra:ClearAllPoints()
        barra:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", -5, -18)
        barra:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", -5, 18)
    end

    local content = CreateFrame("Frame", nil, scroll)
    scroll:SetScrollChild(content)
    -- El ancho real se fija en recalcular()/refrescar, cuando el
    -- scroll ya está medido; aquí un valor provisional.
    content:SetWidth(subAncho - 28)

    local placeholder = content:CreateFontString(nil, "OVERLAY")
    placeholder:SetPoint("TOPLEFT", content, "TOPLEFT", 6, -6)
    placeholder:SetFont("Fonts\\FRIZQT__.TTF", 12)
    placeholder:SetTextColor(0.6, 0.6, 0.6)
    placeholder:SetText("No hay ningún aura de este tipo activa.")
    placeholder:Hide()

    subs[i] = { panel = sub, scroll = scroll, content = content,
                placeholder = placeholder, filas = {} }
    prevSub = sub
end

-- Cada subventana se ajusta SOLO a su propio contenido: la mitad
-- del mínimo (129) si no hay filas, y hasta 314 si su lista crece,
-- sin que la otra tenga que crecer también. También fija el ancho
-- real del contenido ahora que el scroll ya está medido (evita que
-- las filas salgan demasiado estrechas).
recalcular = function()
    if not ctrlVentana or not subs[1] then return end
    local function nec(st)
        local n = (st.necesario or 6) + 30
        if n < MIN_SUB then n = MIN_SUB end
        if n > MAX_SUB then n = MAX_SUB end
        return n
    end
    subs[1].panel:SetHeight(nec(subs[1]))
    subs[2].panel:SetHeight(nec(subs[2]))
    for i = 1, 2 do
        local st = subs[i]
        if st.scroll:GetWidth() and st.scroll:GetWidth() > 0 then
            st.content:SetWidth(st.scroll:GetWidth() - 20)
        end
    end
end

-- ════════════════════════════════════════════════════════════
-- DETECCIÓN DE AURAS (mismo sistema que Invis)
-- ════════════════════════════════════════════════════════════
local function unidadesGrupo()
    local lista = { "player" }
    local n = GetNumGroupMembers() or 0
    local prefijo = IsInRaid() and "raid" or "party"
    for i = 1, n do
        lista[#lista + 1] = prefijo .. i
    end
    return lista
end

-- Devuelve la lista de {nombre, id} de auras de una unidad, sin repetidos.
-- OJO CON LA POSICIÓN DEL ID: este cliente devuelve el spellID en la
-- 10ª posición (igual que lee Epsilon_AuraManager con select(10, ...));
-- en la 11ª NO está, por eso antes llegaba 0/nil y había que resolver
-- el id con .lo (lento: el servidor responde 1 por segundo y corta a
-- los 3). Leyendo la posición correcta la detección es instantánea.
local function aurasUnidad(unidad)
    local resultado, visto = {}, {}
    local function push(nombre, id)
        local key = (id and id ~= 0 and ("i" .. id)) or ("n" .. tostring(nombre or ""))
        if not visto[key] then
            visto[key] = true
            resultado[#resultado + 1] = { nombre = nombre, id = id or 0 }
        end
    end
    if AuraUtil and AuraUtil.ForEachAura then
        pcall(function()
            AuraUtil.ForEachAura(unidad, nil, 64, function(...)
                local nombreAura = select(1, ...)
                local spellId = select(10, ...)
                if nombreAura then push(nombreAura, spellId or 0) end
            end)
        end)
    end
    for _, filtro in ipairs({ "HELPFUL", "HARMFUL" }) do
        for i = 1, 40 do
            local nombre, _, _, _, _, _, _, _, _, id = UnitAura(unidad, i, filtro)
            if not nombre then break end
            push(nombre, id)
        end
    end
    return resultado
end

-- Resuelve el id REAL de un aura sin mapear miles de nombres: este
-- cliente devuelve spellId=0 en UnitAura, pero GetSpellInfo(nombre)
-- acepta el nombre y devuelve el id como 7º valor. Si tampoco lo da,
-- se usan los dígitos finales del nombre como último recurso.
local function idReal(nombre, id)
    local num = tonumber(id)
    if num and num ~= 0 then return num end
    local r
    local ok = pcall(function()
        r = select(7, GetSpellInfo(tostring(nombre or "")))
    end)
    if ok then
        local res = tonumber(r or 0)
        if res and res ~= 0 then return res end
    end
    return tonumber(tostring(nombre or ""):match("(%d+)%s*$"))
end

-- Clasifica una aura en 1 (Screeneffect / skybox) o 2 (resto).
-- Devuelve cat y el id de comando. nil si se excluye.
local function clasificar(nombre, id)
    nombre = tostring(nombre or "")
    local nl = nombre:lower()
    -- 1ª: "Screeneffect"/"skybox" en el nombre, o id de un skybox
    local num = idReal(nombre, id)
    if num and GMTOOLS_SKY_AURAS and GMTOOLS_SKY_AURAS[num] then
        return 1, num
    end
    if GMTOOLS_SKY_NOMBRES and GMTOOLS_SKY_NOMBRES[nombre] then
        return 1, num or 0
    end
    if nl:find("screeneffect", 1, true) or nl:find("skybox", 1, true) then
        return 1, num or 0
    end
    -- 2ª: el resto (incluye invis/detection de la pestaña de Invis)
    return 2, num or 0
end

-- ════════════════════════════════════════════════════════════
-- ESTADO COMPARTIDO CON LA PESTAÑA DE SKYBOXES
-- GMToolsSkyboxIDCache: nombre de aura detectado → id REAL
-- (aprendido con los lookups .lo; este cliente no lo reporta).
-- GMToolsSkyboxActivos: conjunto de ids de skybox que alguien del
-- grupo tiene puestos; la pestaña de skyboxes lo lee para iluminar
-- en dorado la celda del skybox aplicado.
-- ════════════════════════════════════════════════════════════
GMToolsSkyboxIDCache = GMToolsSkyboxIDCache or {}
GMToolsSkyboxActivos = GMToolsSkyboxActivos or {}

-- Cola de lookups automáticos para el borde dorado: cuando se ve un
-- aura de skybox cuyo id real no se conoce, se encola su nombre y un
-- .lo silencioso lo resuelve (desde el filtro de chat o un click).
-- colaLookup[nombre] = momento a partir del cual se puede probar;
-- el primer intento es INMEDIATO y el enfriamiento (60 s) se aplica
-- solo a los reintentos tras una búsqueda que expiró sin respuesta.
-- esperando[nombre] = timestamp del .lo que está en vuelo (para
-- resolver las respuestas aunque haya varias a la vez, por nombre).
local colaLookup = {}
local esperando = {}
local LOOKUP_ENFRIAMIENTO = 60
-- Máximo de .lo por lote: este cliente corta los envíos de "." en
-- ráfaga (más de 3 seguidos da "Interface action failed"). Como el
-- id real ya se lee directo de UnitAura (10ª posición), la cola solo
-- se usa como último recurso para nombres raros sin dígitos.
local LOOKUP_MAX_COLA = 3

-- Recalcula qué skyboxes están activos en el grupo. Se apoya en el
-- cache de ids aprendidos (.lo): para los nombres custom el cliente
-- no da el id real (GetSpellInfo falla y solo quedarían los dígitos
-- del nombre, que NO son el id del aura). Si se ve un skybox cuyo
-- id aún no se conoce, se encola su resolución silenciosa.
local function actualizarActivos()
    local activos = {}
    local unidades = unidadesGrupo()
    for _, u in ipairs(unidades) do
        if UnitExists(u) and UnitIsConnected(u) then
            for _, aura in ipairs(aurasUnidad(u)) do
                local nombre = aura.nombre or ""
                local num = GMToolsSkyboxIDCache[nombre] or idReal(nombre, aura.id)
                if num and num ~= 0 and GMTOOLS_SKY_AURAS and GMTOOLS_SKY_AURAS[num] then
                    activos[num] = true
                elseif clasificar(nombre, aura.id) == 1 then
                    -- El id real aprendido con el .lo (p.ej. 1003147) no
                    -- tiene por qué estar en GMTOOLS_SKY_AURAS (que usa el
                    -- id de comando con el que acaba el nombre, p.ej. 3586):
                    -- si no casa el real, se prueban los dígitos finales
                    -- para no perder la detección del borde dorado.
                    local cmd = tonumber(tostring(nombre):match("(%d+)%s*$"))
                    if cmd and GMTOOLS_SKY_AURAS and GMTOOLS_SKY_AURAS[cmd] then
                        activos[cmd] = true
                    elseif not GMToolsSkyboxIDCache[nombre]
                        and not colaLookup[nombre] then
                        -- Skybox sin id conocido: encolar resolución (.lo).
                        -- El primer intento es inmediato (hasta = ahora).
                        local n = 0
                        for _ in pairs(colaLookup) do n = n + 1 end
                        if n < LOOKUP_MAX_COLA then
                            colaLookup[nombre] = 0
                        end
                    end
                end
            end
        end
    end
    GMToolsSkyboxActivos = activos
end

-- Re-escaneo local para la pestaña de skyboxes: relee las auras del
-- grupo y repinta los bordes dorados. Solo toca estado e interfaz
-- (SIN envíos de .lo: esos requieren contexto de click o del filtro
-- de chat). El OnUpdate de la ventana de skyboxes lo llama de forma
-- periódica mientras esté abierta, y APLICAR/QUITAR lo fuerzan.
GMTOOLS_SKY_REESCAN = function()
    actualizarActivos()
    if GMToolsSkyboxFrame and GMToolsSkyboxFrame:IsShown() and GMTOOLS_SKY_REPINTAR then
        GMTOOLS_SKY_REPINTAR()
    end
end

-- ════════════════════════════════════════════════════════════
-- OBTENCIÓN DE ID POR LOOKUP (vía FILTRO de chat)
-- Cuando se pulsa PH AURA / QUITAR y no se conoce el id real, se
-- envía ".lo spell <nombre>" al chat DESDE EL CLICK DEL BOTÓN
-- (contexto de usuario: la única vía fiable para enviar comandos
-- "." en este cliente). El servidor responde con las coincidencias
-- por CHAT_MSG_SYSTEM; del PRIMER resultado se lee el número que
-- antecede al guion ("1003147 - [Skybox Lightdata 3586] - ...") y
-- ese número se usa para ".ph aura %d" / ".ph unaura %d".
-- IMPORTANTE: la detección de la respuesta y el envío del comando
-- final se hacen DENTRO de un filtro de chat
-- (ChatFrame_AddMessageEventFilter), el mismo patrón que usa
-- EpsilonLib para ".gobject select" (GobjectNearFilter): es el
-- único contexto donde este cliente deja enviar comandos "." desde
-- un addon. Hacerlo desde el evento CHAT_MSG_SYSTEM, desde un
-- C_Timer o con C_Epsilon.RunPrivileged da "Interface action
-- failed because of an AddOn" (probado).
-- ════════════════════════════════════════════════════════════
local pendiente = nil  -- { tipo = "aura"|"unaura", nombre, hasta = GetTime()+5 }
local silencioHasta = 0  -- hasta cuándo ocultar las líneas de respuesta del .lo

-- Quita los códigos de color/hyperlink para quedarse solo con texto
-- plano y poder leer el número inicial de la respuesta del .lo.
local function limpiarApariencia(msg)
    msg = msg:gsub("%|c[0-9a-fA-F]+", "")
    msg = msg:gsub("%|H[^|]*%|h", "")
    msg = msg:gsub("%|h", "")
    msg = msg:gsub("%|r", "")
    return msg
end

-- ¿Es una línea de la respuesta del servidor al ".lo spell"?
-- (el formato es "<id> - [Nombre...] - [Learn] - [Cast] - ..." y
-- el cierre "You have reached the end of your lookup.")
-- Se limpia primero: la primera línea suele llevar códigos de
-- color/hyperlink entre el número y el guion que romperían el match.
local function esLineaLookup(msg)
    if not msg then return false end
    local limpio = limpiarApariencia(msg)
    if limpio:match("%d+%s*%-%s*%[") then return true end
    if limpio:find("You have reached the end of your lookup", 1, true) then return true end
    return false
end

-- Envía los .lo de TODOS los nombres listos de la cola automática en
-- una sola llamada (hasta LOOKUP_MAX_COLA en vuelo), desde un
-- contexto de usuario (click o filtro de chat): al abrir la pestaña
-- de skyboxes se lanza la carga COMPLETA de una vez, no de una en una.
-- En este modo NO se aplica nada: solo se aprende el id real para el
-- borde dorado. Devuelve cuántos se dispararon.
local function contarEsperando()
    local n = 0
    for _ in pairs(esperando) do n = n + 1 end
    return n
end

local function dispararLookup()
    local lista = {}
    for nombre, hasta in pairs(colaLookup) do
        if GetTime() >= hasta then
            lista[#lista + 1] = nombre
        end
    end
    if #lista == 0 then return 0 end
    local enviados = 0
    for i = 1, #lista do
        if enviados + contarEsperando() >= LOOKUP_MAX_COLA then break end
        local nombre = lista[i]
        colaLookup[nombre] = nil
        local x = tostring(nombre):gsub("^%s*%[", ""):gsub("%]%s*$", "")
        if x ~= "" then
            -- Se marca como en vuelo ANTES de enviar: así, si hay varias
            -- respuestas entrelazadas, cada una se casa con su nombre.
            esperando[nombre] = GetTime()
            silencioHasta = math.max(silencioHasta, GetTime() + 5.5)
            -- Mismo canal que el .lo manual (probado): SAY
            SendChatMessage(".lo spell " .. x, "SAY")
            enviados = enviados + 1
        end
    end
    return enviados
end

-- Disparo desde la pestaña de skyboxes (OnShow): primero refresca el
-- escaneo (por si tras un /reload aún no se habían visto las auras y
-- la cola está vacía) y luego lanza TODA la cola de golpe.
GMTOOLS_SKY_DISP_COLA = function()
    actualizarActivos()
    return dispararLookup()
end

-- Filtro de CHAT_MSG_SYSTEM: detecta la respuesta del .lo mientras
-- haya una búsqueda pendiente y, si coincide el nombre y hay id,
-- envía al momento el ".ph aura/unaura <id>" por GUILD. Además
-- oculta las líneas de respuesta del .lo (búsqueda silenciosa):
-- se devuelve true solo para ellas y mientras dure la búsqueda.
-- Si no hay nada en vuelo, re-dispara la cola automática de lookups
-- (cualquier mensaje de sistema sirve de contexto de usuario).
local function filtroLookup(self, evento, msg, ...)
    local limpio = limpiarApariencia(msg or "")

    -- 1º: respuestas de la cola automática (varias en vuelo, se casan
    -- por nombre: la línea citada contiene el nombre buscado).
    if next(esperando) then
        local id = tonumber(limpio:match("(%d+)%s*%-"))
        if id and id > 0 then
            local aprendido = false
            for nombre, t in pairs(esperando) do
                local okNombre = not not limpio:lower():find(tostring(nombre):lower(), 1, true)
                if okNombre then
                    esperando[nombre] = nil
                    if not GMToolsSkyboxIDCache[nombre] then
                        GMToolsSkyboxIDCache[nombre] = id
                    end
                    aprendido = true
                end
            end
            if aprendido then
                silencioHasta = math.max(silencioHasta, GetTime() + 2)
                actualizarActivos()
                if GMToolsSkyboxFrame and GMToolsSkyboxFrame:IsShown() and GMTOOLS_SKY_REPINTAR then
                    GMTOOLS_SKY_REPINTAR()
                end
                -- Continúa la cadena con lo que quede en la cola
                -- (siempre DENTRO del filtro: contexto fiable).
                dispararLookup()
            end
        end
    end

    -- 2º: si no hay nada en vuelo, se re-dispara la cola automática.
    if not pendiente and next(esperando) == nil then
        dispararLookup()
    end

    -- 3º: resolución del lookup manual de PH AURA / QUITAR (id único).
    if pendiente then
        local okNombre = true
        if pendiente.nombre then
            okNombre = not not limpio:lower():find(pendiente.nombre:lower(), 1, true)
        end
        local id = tonumber(limpio:match("(%d+)%s*%-"))
        if okNombre and id and id > 0 then
            local p = pendiente
            pendiente = nil
            -- Se aprende el id real de ese nombre: el tracker de
            -- skyboxes activos lo usará sin tener que volver a mirar.
            if p.nombre then
                GMToolsSkyboxIDCache[p.nombre] = id
            end
            -- Tras dar con el id quedan más líneas (Learn/Cast/Aura/
            -- Gobject y "end of your lookup"): se siguen ocultando.
            silencioHasta = math.max(silencioHasta, GetTime() + 2)
            if p.tipo == "aura" or p.tipo == "unaura" then
                -- Comando según TODOS/SOLO YO (o su inverso si el
                -- click fue derecho): .ph aura/unaura o .aura/unaura.
                -- Sin espacios sobrantes al componer el prefijo.
                local cmd = (p.tipo == "aura")
                    and ((p.ph and ".ph aura " or ".aura ") .. id)
                    or ((p.ph and ".ph unaura " or ".unaura ") .. id)
                -- Se envía por GUILD, igual que EpsilonLib con sus comandos
                SendChatMessage(cmd, "GUILD")
            end
            -- El id aprendido puede encender el borde dorado al momento
            actualizarActivos()
            if GMToolsSkyboxFrame and GMToolsSkyboxFrame:IsShown() and GMTOOLS_SKY_REPINTAR then
                GMTOOLS_SKY_REPINTAR()
            end
        end
    end
    if GetTime() <= silencioHasta and esLineaLookup(msg) then
        return true  -- oculta la línea, pero no se envía nada más
    end
    return false, msg, ...
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", filtroLookup)

-- Si no llega respuesta en 5 s, se descarta la búsqueda. Si era un
-- lookup automático (en vuelo en "esperando"), se re-encola con
-- enfriamiento para reintentarlo más tarde (sin spam).
local proxyTimeout = CreateFrame("Frame")
proxyTimeout:SetScript("OnUpdate", function(self, elapsed)
    local ahora = GetTime()
    if pendiente and ahora > pendiente.hasta then
        local p = pendiente
        pendiente = nil
        if p.tipo == "soloId" and p.nombre and not GMToolsSkyboxIDCache[p.nombre] then
            colaLookup[p.nombre] = ahora + LOOKUP_ENFRIAMIENTO
        end
    end
    -- Lookups automáticos en vuelo sin respuesta: expiran y se
    -- re-encolan con enfriamiento (se reintentarán con la próxima
    -- apertura o mensaje). Sin esto, un .lo perdido bloquearía el
    -- hueco de la cola para siempre.
    local viejos = {}
    for nombre, t in pairs(esperando) do
        if ahora - t > 8 then
            viejos[#viejos + 1] = nombre
        end
    end
    -- Mientras la ventana de skyboxes esté ABIERTA el reintento es
    -- corto (5 s): el usuario pidió que siga cargando en caliente;
    -- con la ventana cerrada se aplica el enfriamiento largo (60 s)
    -- para no hacer spam de .lo en segundo plano.
    local enfriamiento = (GMToolsSkyboxFrame and GMToolsSkyboxFrame:IsShown())
        and 5 or LOOKUP_ENFRIAMIENTO
    for _, nombre in ipairs(viejos) do
        esperando[nombre] = nil
        if not GMToolsSkyboxIDCache[nombre] then
            colaLookup[nombre] = ahora + enfriamiento
        end
    end
end)

-- Lanza la búsqueda del id real de un aura por su nombre.
-- nombre = nombre EXACTO detectado (p.ej. "[Skybox Lightdata]").
-- tipo = "aura" (PH AURA) o "unaura" (QUITAR).
-- ph = true → .ph aura/unaura (a todos); false → .aura/unaura (solo a ti).
local function buscarIdPorNombre(nombre, tipo, ph)
    local x = tostring(nombre or ""):gsub("^%s*%[", ""):gsub("%]%s*$", "")
    if x == "" then
        print("GMTools | Tool-Control-Auras | sin nombre para .lo spell")
        return
    end
    pendiente = { tipo = tipo, ph = ph, nombre = tostring(nombre or ""), hasta = GetTime() + 5 }
    silencioHasta = GetTime() + 5.5
    -- El .lo se envía desde el click (contexto de usuario): enviarlo
    -- desde un evento/timer da "Interface action failed because of an AddOn".
    SendChatMessage(".lo spell " .. x, "SAY")
end

local function ejecutar(f, ...)
    local ok2, e = pcall(f, ...)
    if not ok2 then
        print("GMTools | Tool-Control-Auras error: " .. tostring(e))
    end
end

-- ════════════════════════════════════════════════════════════
-- BANDA DE AVISOS DE CAMBIOS (misma función que la pestaña de
-- Invis, con botón e info iguales): entre la subventana de
-- Screeneffect/Skybox y la de Resto. Si el checkbox está marcado,
-- avisa en el chat cuando un jugador se quita por su cuenta uno de
-- los skyboxes/screeneffect de la ventana de encima.
-- ════════════════════════════════════════════════════════════
local avisoActivo = false
local anteriorSky = {}

local bandaAviso = CreateFrame("Frame", nil, ctrlVentana, "BackdropTemplate")
bandaAviso:SetWidth(subAncho)
bandaAviso:SetHeight(BANDA_AVISO_H)
ApplyDarkPanel(bandaAviso)
bandaAviso:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
bandaAviso:SetPoint("TOP", subs[1].panel, "BOTTOM", 0, -GAP_SUB)

-- La subventana de "Resto de auras" se ancla debajo de la banda.
subs[2].panel:ClearAllPoints()
subs[2].panel:SetPoint("TOP", bandaAviso, "BOTTOM", 0, -GAP_SUB)

local btnCheck = CreateFrame("Button", nil, bandaAviso, "BackdropTemplate")
btnCheck:SetSize(20, 20)
btnCheck:SetPoint("BOTTOMLEFT", bandaAviso, "BOTTOMLEFT", 10, 10)
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

local lblCheck = bandaAviso:CreateFontString(nil, "OVERLAY")
lblCheck:SetFont("Fonts\\FRIZQT__.TTF", 12)
lblCheck:SetPoint("LEFT", btnCheck, "RIGHT", 6, 0)
lblCheck:SetTextColor(1, 1, 1)
lblCheck:SetText("Recibir avisos de cambios en las skybox.")

local infoCheck = CreateFrame("Button", nil, bandaAviso)
infoCheck:SetSize(29, 29)
infoCheck:SetPoint("LEFT", lblCheck, "RIGHT", 0, 2)
local infoTex = infoCheck:CreateTexture(nil, "OVERLAY")
infoTex:SetAllPoints()
infoTex:SetTexture("Interface\\Common\\help-i")
local TEXTO_INFO_CHECK = "En la ventana de arriba se muestran las skyboxes que tienen activas los jugadores. Al marcar esta opción te avisará en el chat cuando un jugador se quite por su cuenta una de las auras."
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

local function refrescarTodo()
    if not ctrlVentana:IsShown() then return end
    for i = 1, 2 do
        local st = subs[i]
        for _, r in ipairs(st.filas) do r:Hide() end
    end

    local datos = { {}, {} }
    local uSkybox = {}
    local unidades = unidadesGrupo()
    local total = 0
    for _, u in ipairs(unidades) do
        if UnitExists(u) and UnitIsConnected(u) then
            total = total + 1
            local uVisto = {}
            local setSky = {}
            uSkybox[u] = setSky
            for _, aura in ipairs(aurasUnidad(u)) do
                local cat, cmd = clasificar(aura.nombre, aura.id)
                if cat then
                    local key = (aura.id and aura.id ~= 0 and ("i" .. aura.id))
                        or ("n" .. (aura.nombre or ""))
                    local uk = cat .. key
                    -- Aviso de cambios: se recuerda qué skyboxes tiene
                    -- cada jugador (la ventana de encima) para detectar
                    -- cuándo se quita uno por su cuenta.
                    if cat == 1 then
                        local etiqueta = GMTOOLS_SKY_AURAS and GMTOOLS_SKY_AURAS[cmd]
                            or aura.nombre or ("Skybox " .. cmd)
                        setSky[key] = etiqueta
                    end
                    if not uVisto[uk] then
                        uVisto[uk] = true
                        local d = datos[cat][key]
                        if not d then
                            d = { conteo = 0, cmdId = cmd or 0, nombre = aura.nombre, jugadores = {} }
                            datos[cat][key] = d
                            if cat == 1 then
                                local nombreSky = GMTOOLS_SKY_AURAS and GMTOOLS_SKY_AURAS[cmd]
                                d.label = nombreSky or aura.nombre or ("Skybox " .. cmd)
                            else
                                d.label = aura.nombre or ("Aura " .. cmd)
                            end
                        end
                        d.conteo = d.conteo + 1
                        d.jugadores[#d.jugadores + 1] = UnitName(u) or u
                    end
                end
            end
        end
    end

    -- Aviso de cambios (misma función que la pestaña de Invis): si el
    -- checkbox está marcado, avisa en el chat cuando un jugador se
    -- quita por su cuenta un skybox de la ventana de encima. Los que
    -- salen del grupo se limpian sin avisar.
    if avisoActivo then
        local enGrupo = {}
        for _, u in ipairs(unidades) do
            if UnitExists(u) and UnitIsConnected(u) then enGrupo[u] = true end
        end
        for u in pairs(anteriorSky) do
            if not enGrupo[u] then anteriorSky[u] = nil end
        end
        for u, claves in pairs(anteriorSky) do
            local ahora = uSkybox[u]
            for clave, etiqueta in pairs(claves) do
                if not (ahora and ahora[clave]) then
                    local nombre = UnitName(u) or u
                    DEFAULT_CHAT_FRAME:AddMessage(
                        ("|cffff3030[¡Atención!]|r |cffffff00El jugador %s se ha quitado %s|r"):format(nombre, etiqueta))
                end
            end
        end
    end
    anteriorSky = uSkybox

    for i = 1, 2 do
        local st = subs[i]
        local keys = {}
        for k in pairs(datos[i]) do keys[#keys + 1] = k end
        table.sort(keys)
        if #keys == 0 then
            st.placeholder:Show()
        else
            st.placeholder:Hide()
        end
        local anchoScroll = st.scroll:GetWidth() or 0
        local anchoFila = math.max(50, (anchoScroll > 0 and (anchoScroll - 28)) or (subAncho - 28))
        local posY = -6
        local altoTotal = 0
        local conAviso = i == 1
        for j, key in ipairs(keys) do
            local d = datos[i][key]
            local fila = st.filas[j]
            if not fila then
                fila = crearFila(st)
                st.filas[j] = fila
            end
            local completa = conAviso and (d.conteo >= total)
            local alto = (conAviso and not completa) and 37 or 24
            fila:SetSize(anchoFila, alto)
            fila:ClearAllPoints()
            fila:SetPoint("TOPLEFT", st.content, "TOPLEFT", 0, posY)
            fila.btnQuitar:ClearAllPoints()
            fila.btnQuitar:SetPoint("RIGHT", fila, "RIGHT", -4, -11 + alto / 2)
            fila.btnPH:ClearAllPoints()
            fila.btnPH:SetPoint("RIGHT", fila.btnQuitar, "LEFT", -3, 0)
            -- En "Resto de auras" el nombre se corta a 25 caracteres
            -- para dejar sitio a los nombres de los jugadores.
            local maxNombre = (i == 2) and 25 or 40
            fila.lbl:SetText(truncar(d.label, maxNombre))
            if conAviso then
                fila.lbl:SetTextColor(1, 1, 1)
                if completa then
                    fila.aviso:Hide()
                else
                    fila.aviso:Show()
                end
            else
                fila.lbl:SetTextColor(1, 1, 1)
                fila.aviso:Hide()
            end
            local idcmd = d.cmdId or 0
            local nombreRow = d.nombre or ""
            -- Tooltip al pasar el ratón (en las DOS subventanas): nombre
            -- completo del aura en amarillo, debajo el listado completo
            -- de jugadores que la tienen en gris y, en rojo, el listado
            -- de los del grupo/raid/instancia que NO la tienen (mismo
            -- tamaño de fuente). Sin guiones intermedios.
            local listaCompleta = table.concat(d.jugadores or {}, ", ")
            local conAura = {}
            for _, n in ipairs(d.jugadores or {}) do conAura[n] = true end
            local sinAura = {}
            for _, u in ipairs(unidades) do
                if UnitExists(u) and UnitIsConnected(u) then
                    local nm = UnitName(u) or u
                    if not conAura[nm] then sinAura[#sinAura + 1] = nm end
                end
            end
            local listaSin = table.concat(sinAura, ", ")
            fila:SetScript("OnEnter", function()
                GameTooltip:SetOwner(fila, "ANCHOR_TOP")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(d.label, 1, 0.85, 0)
                GameTooltip:AddLine(listaCompleta, 1, 1, 1, true)
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
            -- Solo en "Resto de auras": nombres de los jugadores en gris
            -- junto al nombre del aura (con un guion delante; el guion
            -- NO sale en el tooltip). Se ancla al ancho REAL del texto
            -- del nombre (GetStringWidth), no a su borde de ancla (que
            -- llega hasta los botones y no dejaba sitio).
            if i == 2 then
                local anchoNombre = fila.lbl:GetStringWidth() or 0
                fila.jugadores:ClearAllPoints()
                fila.jugadores:SetPoint("TOPLEFT", fila, "TOPLEFT", 4 + anchoNombre + 10, -4)
                fila.jugadores:SetPoint("RIGHT", fila, "RIGHT", -140, 0)
                fila.jugadores:SetText(truncar("- " .. listaCompleta, 48))
            end
            -- Mismo método que la pestaña de skyboxes: si el aura trae
            -- el id real (10ª posición de UnitAura), el comando se
            -- envía DIRECTO desde el click, sin la vuelta del .lo.
            -- El .lo solo queda como último recurso para ids 0.
            -- El prefijo depende de TODOS/SOLO YO (.ph o nada) y el
            -- click DERECHO invierte la función: PH AURA derecho =
            -- .aura (solo a ti), y en SOLO YO el izquierdo hace el
            -- papel de PH AURA.
            fila.btnPH:SetScript("OnClick", function(self, boton)
                local esPh = alcanceTodos ~= (boton == "RightButton")
                if idcmd and idcmd ~= 0 then
                    SendChatMessage((esPh and ".ph aura " or ".aura ") .. idcmd, "SAY")
                else
                    ejecutar(buscarIdPorNombre, nombreRow, "aura", esPh)
                end
            end)
            fila.btnQuitar:SetScript("OnClick", function(self, boton)
                local esPh = alcanceTodos ~= (boton == "RightButton")
                if idcmd and idcmd ~= 0 then
                    SendChatMessage((esPh and ".ph unaura " or ".unaura ") .. idcmd, "SAY")
                else
                    ejecutar(buscarIdPorNombre, nombreRow, "unaura", esPh)
                end
            end)
            -- Texto del botón según TODOS/SOLO YO: con TODOS dice
            -- "PH AURA" (comando .ph aura); con SOLO YO dice "AURA"
            -- (comando .aura). Solo en control de auras.
            fila.btnPH.etiqueta:SetText(alcanceTodos and "PH AURA" or "AURA")
            fila:Show()
            altoTotal = altoTotal + alto + 2
            posY = posY - alto - 2
        end
        st.content:SetHeight(math.max(6 + altoTotal, st.scroll:GetHeight()))
        st.scroll:UpdateScrollChildRect()
        st.necesario = 6 + altoTotal
    end

    -- Crecimiento automático (mismo sistema que Invis): la ventana se
    -- ajusta a la suma de los altos independientes de cada subventana
    -- (cada una crece solo con su propia lista, entre 129 y 314; por
    -- defecto mitad y mitad). El objetivo sale del contenido real, no
    -- del alto actual, así que converge y nunca oscila.
    local function nec(i)
        local n = (subs[i].necesario or 6) + 30
        if n < MIN_SUB then n = MIN_SUB end
        if n > MAX_SUB then n = MAX_SUB end
        return n
    end
    local objetivo = PAD_SIDE + (PAD_SIDE + SEARCH_H) + (3 * GAP_SUB) + BANDA_AVISO_H
        + nec(1) + nec(2)
    if objetivo > WIN_H_MAX then objetivo = WIN_H_MAX end
    if objetivo < WIN_H_DEF then objetivo = WIN_H_DEF end
    if math.abs(ctrlVentana:GetHeight() - objetivo) > 1 then
        ctrlVentana:SetHeight(objetivo)
    end
end

-- Refresco continuo mientras la ventana esté abierta (mismo método
-- que la pestaña de skyboxes): cada segundo se releen las auras del
-- grupo y se repuebla el listado. Solo toca estado e interfaz (sin
-- envíos), así que no da el error de addon.
local tickCtrl = 0
ctrlVentana:SetScript("OnUpdate", function(self, elapsed)
    if not self:IsShown() then
        tickCtrl = 0
        return
    end
    tickCtrl = tickCtrl + (elapsed or 0)
    if tickCtrl >= 1.0 then
        tickCtrl = 0
        refrescarTodo()
    end
end)

escaner = CreateFrame("Frame")
escaner:SetScript("OnEvent", function(self, evento)
    if evento == "GROUP_ROSTER_UPDATE" then
        self:UnregisterEvent("UNIT_AURA")
        self:RegisterUnitEvent("UNIT_AURA", unpack(unidadesGrupo()))
    end
    -- El estado de skyboxes activos se mantiene SIEMPRE (aunque esta
    -- ventana esté oculta): la pestaña de skyboxes lo usa para el
    -- borde dorado. La interfaz solo se refresca si está visible.
    actualizarActivos()
    if ctrlVentana:IsShown() then refrescarTodo() end
    if GMToolsSkyboxFrame and GMToolsSkyboxFrame:IsShown() and GMTOOLS_SKY_REPINTAR then
        GMTOOLS_SKY_REPINTAR()
    end
end)
-- El escaneo del estado queda registrado desde la carga, aunque la
-- ventana de Tool-Control-Auras nunca se abra: el borde dorado de la
-- pestaña de skyboxes depende de él.
escaner:RegisterEvent("GROUP_ROSTER_UPDATE")
escaner:UnregisterEvent("UNIT_AURA")
escaner:RegisterUnitEvent("UNIT_AURA", unpack(unidadesGrupo()))
escaner:RegisterUnitEvent("UNIT_CONNECTION", unpack(unidadesGrupo()))

activarEscaner = function()
    actualizarActivos()
    refrescarTodo()
    -- OJO: este OnShow NO dispara la cola de lookups. En este cliente
    -- el OnShow solo es contexto de usuario si se ejecuta DENTRO de un
    -- click que muestra la ventana (skyboxes); el OnShow de control de
    -- auras puede venir de fuera del contexto seguro de un click. La
    -- cola se dispara desde clicks reales y desde el filtro de chat
    -- (contextos seguros y probados).
end

desactivarEscaner = function()
    -- El escaneo de estado (GMToolsSkyboxActivos) sigue vivo aunque
    -- la ventana se oculte; aquí solo se ocultan las filas.
    for i = 1, 2 do
        local st = subs[i]
        for _, r in ipairs(st.filas) do r:Hide() end
    end
end

SLASH_GMAURAS1 = "/auras"
SLASH_GMAURAS2 = "/control"
SlashCmdList["GMAURAS"] = function()
    local f = GMToolsControlAurasFrame
    if not f then return end
    if f:IsShown() then
        f:Hide()
    else
        if GMToolsControlAurasAbrir then
            GMToolsControlAurasAbrir()
        else
            f:Show()
        end
    end
end

end)
