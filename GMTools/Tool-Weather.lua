-- ════════════════════════════════════════════════════════════
-- Tool-Weather.lua
-- Pestaña de weather, IDÉNTICA a la de skyboxes pero SIN los
-- paneles centrales 3x3 (zona central vacía).
-- Los botones se conservan todos igual. La pestaña es
-- INCOMPATIBLE con la de skyboxes: al abrir una se cierra la
-- otra, y ambas comparten la posición (si se mueve una, la otra
-- aparece en esa posición al abrirse).
-- ── /weather abre/cierra esta ventana.
-- ════════════════════════════════════════════════════════════

local ventana = _G["GMToolsFrame"]

local ok, err = pcall(function()

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

-- ════════════════════════════════════════════════════════════
-- CONSTANTES DE LAYOUT (las mismas que skyboxes)
-- ════════════════════════════════════════════════════════════
local PAD_SIDE  = 8
local SEARCH_H  = 32
local BOTTOM_H  = 36
local WIN_H     = 740
local WIN_W     = 1000

-- ════════════════════════════════════════════════════════════
-- VENTANA PRINCIPAL (misma posición por defecto que skyboxes:
-- 8 px por encima del centro superior de GMTools)
-- ════════════════════════════════════════════════════════════
local weatherVentana = CreateFrame("Frame", "GMToolsWeatherFrame", UIParent, "BackdropTemplate")
weatherVentana:SetSize(WIN_W, WIN_H)
weatherVentana:SetPoint("BOTTOM", ventana, "TOP", 0, 8)
ApplyDarkPanel(weatherVentana)
weatherVentana:EnableMouse(true)
weatherVentana:SetMovable(true)
weatherVentana:RegisterForDrag("LeftButton")
weatherVentana:SetScript("OnDragStart", weatherVentana.StartMoving)
weatherVentana:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Guarda la posición compartida con la pestaña de skyboxes
    local l, b = self:GetLeft(), self:GetBottom()
    if l and b then
        GMToolsWeatherPos = { math.floor(l), math.floor(b) }
    end
end)
weatherVentana:Hide()

weatherVentana:SetScript("OnShow", function()
    -- Incompatible con skyboxes: al abrir esta se cierra la otra
    if GMToolsSkyboxFrame and GMToolsSkyboxFrame:IsShown() then
        GMToolsSkyboxFrame:Hide()
    end
    -- Y también se cierra la ventana de Control de Auras (exclusivas)
    if GMToolsControlAurasFrame then
        GMToolsControlAurasFrame:Hide()
    end
    -- Si hay posición compartida (la otra pestaña se movió), aparece ahí
    if GMToolsWeatherPos then
        local l, b = GMToolsWeatherPos[1], GMToolsWeatherPos[2]
        if l and b then
            weatherVentana:ClearAllPoints()
            weatherVentana:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", l, b)
        end
    end
end)

-- ════════════════════════════════════════════════════════════
-- BARRA DE BÚSQUEDA (idéntica, sin efecto: no hay grid)
-- ════════════════════════════════════════════════════════════
local searchRow = CreateFrame("Frame", nil, weatherVentana, "BackdropTemplate")
searchRow:SetHeight(SEARCH_H)
searchRow:SetPoint("TOPLEFT",  weatherVentana, "TOPLEFT",   PAD_SIDE, -PAD_SIDE)
searchRow:SetPoint("TOPRIGHT", weatherVentana, "TOPRIGHT", -PAD_SIDE, -PAD_SIDE)
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
closeButton:SetScript("OnClick", function() weatherVentana:Hide() end)

-- ════════════════════════════════════════════════════════════
-- BOTONES DE ARRIBA (idénticos a skyboxes): "Control de Auras"
-- y, en vez de "Weather", el botón "Skyboxes" que vuelve a la
-- pestaña de skyboxes. A su izquierda el TODOS / SOLO YO.
-- ════════════════════════════════════════════════════════════
local function crearBotonEstilo(wrapper, texto, ancho, onClic, onEnter, onLeave)
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
    btn:SetScript("OnEnter", onEnter)
    btn:SetScript("OnLeave", onLeave)
    return btn, label
end

-- "Control de Auras" — junto a la X
local wrapperAuras = CreateFrame("Frame", nil, searchRow, "BackdropTemplate")
wrapperAuras:SetSize(110 + 4, SEARCH_H - 6)
wrapperAuras:SetPoint("RIGHT", closeButton, "LEFT", -6, 0)

local botonAuras
botonAuras = crearBotonEstilo(wrapperAuras, "Control de Auras", 110,
    function()
        GMToolsControlAurasAbrir(weatherVentana)
    end,
    function(self)
        self:SetBackdropColor(0.2, 0.3, 0.55, 0.95)
        self:SetBackdropBorderColor(0.5, 0.75, 1, 1)
        wrapperAuras:SetBackdropBorderColor(0.9, 0.75, 0.1, 1)
    end,
    function(self)
        self:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
        self:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
        wrapperAuras:SetBackdropBorderColor(0, 0, 0, 0)
    end)

-- "Skyboxes" — a la izquierda de Control de Auras (el equivalente
-- al botón "Weather" de la otra pestaña: vuelve a skyboxes)
local wrapperTab = CreateFrame("Frame", nil, searchRow, "BackdropTemplate")
wrapperTab:SetSize(72, SEARCH_H - 6)
wrapperTab:SetPoint("RIGHT", wrapperAuras, "LEFT", -6, 0)

local botonTab
botonTab = crearBotonEstilo(wrapperTab, "Skyboxes", 68,
    function()
        -- Vuelve a SKYBOXES: pasa la posición EXACTA de esta pestaña
        -- para que skyboxes salga en el mismo sitio.
        local l, b = weatherVentana:GetLeft(), weatherVentana:GetBottom()
        GMToolsWeatherPos = (l and b) and { math.floor(l), math.floor(b) } or nil
        weatherVentana:Hide()
        if GMToolsSkyboxFrame then
            GMToolsSkyboxFrame:Show()
        end
        -- Click real (contexto de usuario): dispara la carga completa
        -- de ids pendientes del borde dorado al volver a skyboxes.
        if GMTOOLS_SKY_DISP_COLA then GMTOOLS_SKY_DISP_COLA() end
    end,
    function(self)
        self:SetBackdropColor(0.2, 0.3, 0.55, 0.95)
        self:SetBackdropBorderColor(0.5, 0.75, 1, 1)
        wrapperTab:SetBackdropBorderColor(0.9, 0.75, 0.1, 1)
    end,
    function(self)
        self:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
        self:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
        wrapperTab:SetBackdropBorderColor(0, 0, 0, 0)
    end)

-- ════════════════════════════════════════════════════════════
-- LISTADO DE OPCIONES DE CLIMA
-- Igual que el listado de auras de Invis/Detection: cada opción
-- con su explicación breve y, a su derecha, los dos MISMOS
-- botones (QUITAR / APLICAR), mismo tamaño y diseño. Las filas
-- de sección (títulos) NO se pueden pulsar.
-- Los botones aún no hacen nada: comando temporal placeholder.
-- ════════════════════════════════════════════════════════════
local WEATHER_OPCIONES = {
    { titulo = "Clima convencional" },
    { nombre = "normal",         desc = "Soleado" },
    { nombre = "fog",            desc = "Niebla" },
    { nombre = "rain",           desc = "Lluvia" },
    { nombre = "snow",           desc = "Nieve" },
    { nombre = "thunderstorm",   desc = "Tormenta" },
    { nombre = "wind",           desc = "Viento" },
    { nombre = "gale",           desc = "Vendaval" },
    { nombre = "sandstorm",      desc = "Tormenta de arena" },

    { titulo = "Niebla, humo y partículas atmosféricas" },
    { nombre = "mistrain",       desc = "Lluvia con bruma" },
    { nombre = "mistyellow",     desc = "Niebla amarilla" },
    { nombre = "mistwhite",      desc = "Niebla blanca" },
    { nombre = "mistblack",      desc = "Niebla negra" },
    { nombre = "smog",           desc = "Humo" },
    { nombre = "ash",            desc = "Ceniza" },
    { nombre = "soot",           desc = "Hollín" },
    { nombre = "pollen",         desc = "Polen" },
    { nombre = "blacksand",      desc = "Arena negra" },

    { titulo = "Fuego y calor" },
    { nombre = "fireball",       desc = "Bolas de fuego" },
    { nombre = "firespark",      desc = "Chispas de fuego" },
    { nombre = "embers",         desc = "Brasas" },
    { nombre = "burning",        desc = "Ambiente/partículas de fuego" },
    { nombre = "firerain",       desc = "Lluvia de fuego" },
    { nombre = "firestreakrain", desc = "Lluvia con estelas de fuego" },

    { titulo = "Rayos y energía eléctrica" },
    { nombre = "thunderstorm",   desc = "Tormenta eléctrica" },
    { nombre = "arcan lightning", desc = "Rayos arcanos" },
    { nombre = "redboltrain",    desc = "Rayos rojos" },

    { titulo = "Magia / energía arcana" },
    { nombre = "arcanespark",    desc = "Chispas arcanas" },
    { nombre = "arcanerain",     desc = "Lluvia arcana" },
    { nombre = "arcanefissure",  desc = "Fisuras arcanas" },
    { nombre = "bluefissure",    desc = "Fisuras azules de energía" },
    { nombre = "deathwing",      desc = "Efecto especial asociado a Deathwing" },

    { titulo = "Climas oscuros / corruptos" },
    { nombre = "blackrain",      desc = "Lluvia negra" },
    { nombre = "bloodrain",      desc = "Lluvia de sangre" },
    { nombre = "blacksnow",      desc = "Nieve negra" },

    { titulo = "Espíritus y fenómenos sobrenaturales" },
    { nombre = "spirits",        desc = "Espíritus" },
    { nombre = "wisps",          desc = "Luces/espíritus flotantes" },
    { nombre = "spirittowers",   desc = "Torres o columnas de espíritus" },

    { titulo = "Naturaleza" },
    { nombre = "petals",         desc = "Pétalos" },
    { nombre = "pollen",         desc = "Polen" },
    { nombre = "wind",           desc = "Viento" },

    { titulo = "Cósmico / cielo" },
    { nombre = "star rain",      desc = "Lluvia estelar" },
    { nombre = "starfall",       desc = "Caída de estrellas" },
    { nombre = "pulsars",        desc = "Efecto de púlsares" },
    { nombre = "twinkle",        desc = "Destellos" },

    { titulo = "Partículas y efectos especiales" },
    { nombre = "redspark",       desc = "Chispas rojas" },
    { nombre = "twinkle",        desc = "Destellos" },
    { nombre = "bluefissure",    desc = "Fisura azul" },
}

-- Subventana: entre la barra de búsqueda y la barra inferior,
-- ocupando TODO el ancho (igual que la barra de búsqueda de arriba).
local ANCHO_SUBV = WIN_W - PAD_SIDE * 2
local subVentana = CreateFrame("Frame", nil, weatherVentana, "BackdropTemplate")
subVentana:SetPoint("TOPLEFT", weatherVentana, "TOPLEFT", PAD_SIDE, -(PAD_SIDE * 2 + SEARCH_H))
subVentana:SetPoint("TOPRIGHT", weatherVentana, "TOPRIGHT", -PAD_SIDE, -(PAD_SIDE * 2 + SEARCH_H))
subVentana:SetPoint("BOTTOMLEFT", weatherVentana, "BOTTOMLEFT", PAD_SIDE, PAD_SIDE + BOTTOM_H + 14 + 15)
ApplyDarkPanel(subVentana)

local scrollWeather = CreateFrame("ScrollFrame", nil, subVentana, "UIPanelScrollFrameTemplate")
scrollWeather:SetPoint("TOPLEFT", subVentana, "TOPLEFT", 8, -8)
scrollWeather:SetPoint("BOTTOMRIGHT", subVentana, "BOTTOMRIGHT", -8, 8)
local barraWeather = scrollWeather.ScrollBar
if barraWeather then
    barraWeather:ClearAllPoints()
    barraWeather:SetPoint("TOPRIGHT", scrollWeather, "TOPRIGHT", -5, -18)
    barraWeather:SetPoint("BOTTOMRIGHT", scrollWeather, "BOTTOMRIGHT", -5, 18)
end

local contentWeather = CreateFrame("Frame", nil, scrollWeather)
scrollWeather:SetScrollChild(contentWeather)
local ACTIVO_CONTENT = ANCHO_SUBV - 16 - 20
contentWeather:SetWidth(ACTIVO_CONTENT)

-- Botón mini (QUITAR / PH AURA): mismo tamaño y diseño que Invis
local function botonMiniWeather(parent, texto, r, g, b)
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

local function truncarWeather(texto, max)
    texto = tostring(texto or "")
    if #texto > max then
        return texto:sub(1, max) .. "..."
    end
    return texto
end

-- Envía el comando de weather al chat como texto.
--   APLICAR → .ph set weather <tipo> <intensidad deslizador 0-100>
--   QUITAR  → .ph set weather normal 100 (siempre)
local function comandoWeather(tipo, quitar)
    local msg
    if quitar then
        msg = ".ph set weather normal 100"
    else
        msg = (".ph set weather %s %d"):format(tipo, GMToolsWeatherIntensidad)
    end
    SendChatMessage(msg, "SAY")
end

-- Construcción del listado (estático)
local posY = -2
local altoTotal = 0
local ANCHO_FILA = ACTIVO_CONTENT - 6

for _, item in ipairs(WEATHER_OPCIONES) do
    if item.titulo then
        -- Fila de sección: solo texto, NO es pulsable. Encima lleva
        -- una línea divisoria y más separación con la sección anterior.
        posY = posY - 12
        local linea = contentWeather:CreateTexture(nil, "OVERLAY")
        linea:SetColorTexture(0.55, 0.75, 1, 0.9)
        linea:SetHeight(2)
        linea:SetPoint("TOPLEFT", contentWeather, "TOPLEFT", 6, posY)
        linea:SetPoint("TOPRIGHT", contentWeather, "TOPRIGHT", -4, posY)
        posY = posY - 16
        local head = contentWeather:CreateFontString(nil, "OVERLAY")
        head:SetPoint("TOPLEFT", contentWeather, "TOPLEFT", 10, posY)
        head:SetFont("Fonts\\FRIZQT__.TTF", 12)
        head:SetJustifyH("LEFT")
        head:SetTextColor(1, 0.85, 0)
        head:SetText(item.titulo)
        posY = posY - 18
        altoTotal = altoTotal + 12 + 16 + 18
    else
        -- Fila de opción: igual que las auras de Invis/Detection
        local fila = CreateFrame("Button", nil, contentWeather)
        fila:SetSize(ANCHO_FILA, 24)
        fila:SetPoint("TOPLEFT", contentWeather, "TOPLEFT", 0, posY)
        fila:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
        local hlFila = fila:GetHighlightTexture()
        if hlFila then
            hlFila:SetVertexColor(1, 1, 1, 0.12)
            hlFila:ClearAllPoints()
            hlFila:SetPoint("TOPLEFT", fila, "TOPLEFT", 0, 2)
            hlFila:SetPoint("BOTTOMRIGHT", fila, "BOTTOMRIGHT", 0, 0)
        end

        local lbl = fila:CreateFontString(nil, "OVERLAY")
        lbl:SetPoint("TOPLEFT", fila, "TOPLEFT", 6, -4)
        lbl:SetJustifyH("LEFT")
        lbl:SetFont("Fonts\\FRIZQT__.TTF", 12)
        lbl:SetText(item.nombre)
        lbl:SetTextColor(1, 1, 1)

        local desc = fila:CreateFontString(nil, "OVERLAY")
        desc:SetPoint("LEFT", lbl, "RIGHT", 8, 0)
        desc:SetJustifyH("LEFT")
        desc:SetFont("Fonts\\FRIZQT__.TTF", 12)
        desc:SetTextColor(0.75, 0.8, 0.9)
        desc:SetWidth(400)
        desc:SetText("— " .. truncarWeather(item.desc, 40))

        local btnQuitar = botonMiniWeather(fila, "QUITAR", 0.4, 0.1, 0.1)
        btnQuitar:SetPoint("RIGHT", fila, "RIGHT", -4, 1)
        btnQuitar:SetScript("OnClick", function()
            comandoWeather(item.nombre, true)
        end)

        local btnPH = botonMiniWeather(fila, "APLICAR", 0.1, 0.11, 0.15)
        btnPH:SetPoint("RIGHT", btnQuitar, "LEFT", -3, 0)
        btnPH:SetScript("OnClick", function()
            comandoWeather(item.nombre, false)
        end)

        posY = posY - 24 - 2
        altoTotal = altoTotal + 24 + 2
    end
end

contentWeather:SetHeight(altoTotal + 6)
scrollWeather:UpdateScrollChildRect()

-- ════════════════════════════════════════════════════════════
-- DESLIZADOR DE INTENSIDAD (abajo del todo, centrado, casi todo
-- el ancho). Mismo estilo que el de Invis/Detection
-- (OptionsSliderTemplate). Valores 0-100 en pasos de 10.
-- Aún sin efecto (placeholder): solo guarda el valor elegido.
-- ════════════════════════════════════════════════════════════
local anchoSlider = WIN_W - 2 * PAD_SIDE - 30

local txtIntensidad = weatherVentana:CreateFontString(nil, "OVERLAY", "GameFontNormal")
txtIntensidad:SetText("Intensidad")
txtIntensidad:SetTextColor(1, 0.85, 0)

local sliderIntensidad = CreateFrame("Slider", "GMToolsWeatherIntensidad", weatherVentana, "OptionsSliderTemplate")
sliderIntensidad:SetSize(anchoSlider, 17)
sliderIntensidad:SetMinMaxValues(0, 100)
sliderIntensidad:SetValueStep(10)
sliderIntensidad:SetObeyStepOnDrag(true)
sliderIntensidad:SetValue(100)

-- Sin textos del template: dibujamos las 11 marcas (0..100) centradas
-- sobre la barra, alineadas con las posiciones del pulgar. Sus
-- posiciones son ajustables desde la ventana temporal de la izquierda.
sliderIntensidad.Text:SetText("")
sliderIntensidad.Low:SetText("")
sliderIntensidad.High:SetText("")

local marcas, posMarca = {}, {}
local posSlider = { dx = -2, dy = 35 }
local posTitulo = { dx = 0, dy = 55 }

local deltasX = { [0] = 16, [10] = 12, [20] = 10, [30] = 7, [40] = 3,
                  [50] = 0, [60] = -2, [70] = -5, [80] = -8, [90] = -12, [100] = -16 }

for v = 0, 100, 10 do
    local marca = weatherVentana:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    marca:SetFont("Fonts\\FRIZQT__.TTF", 10)
    marca:SetText(tostring(v))
    marca:SetTextColor(0.8, 0.85, 0.95)
    marcas[v] = marca
    posMarca[v] = { base = (v / 100) * anchoSlider, dx = deltasX[v], dy = -16 }
end

-- Recalcula y aplica la posición de marcas, deslizador y título según
-- los valores (base + dx / dy) de la tabla posMarca/posSlider/posTitulo.
local function reposicionar()
    for v, marca in pairs(marcas) do
        local p = posMarca[v]
        marca:ClearAllPoints()
        marca:SetPoint("CENTER", sliderIntensidad, "LEFT", p.base + p.dx, p.dy)
    end
    sliderIntensidad:ClearAllPoints()
    sliderIntensidad:SetPoint("BOTTOM", weatherVentana, "BOTTOM", posSlider.dx, posSlider.dy)
    txtIntensidad:ClearAllPoints()
    txtIntensidad:SetPoint("BOTTOM", weatherVentana, "BOTTOM", posTitulo.dx, posTitulo.dy)
end
reposicionar()

sliderIntensidad:SetScript("OnValueChanged", function(self, value)
    GMToolsWeatherIntensidad = value
end)
GMToolsWeatherIntensidadSlider = sliderIntensidad
GMToolsWeatherIntensidad = sliderIntensidad:GetValue()

-- ════════════════════════════════════════════════════════════
-- COMANDO DE CHAT
-- ════════════════════════════════════════════════════════════
SLASH_GTOOLSWEATHER1 = "/weather"

SlashCmdList["GTOOLSWEATHER"] = function()
    if GMToolsWeatherFrame:IsShown() then
        GMToolsWeatherFrame:Hide()
    else
        GMToolsWeatherFrame:Show()
    end
end

end)
