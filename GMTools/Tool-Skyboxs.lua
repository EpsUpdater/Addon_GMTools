-- ============================================================
-- Tool-Skyboxs.lua
-- Pestaña de skyboxes (copia del diseño de NPC Anim Viewer).
-- Grid 3x3: título encima de cada textura, debajo 2 botones
-- (APLICAR / QUITAR, por ahora sin acción). Buscador, flechas
-- y categorías idénticos. Las categorías de cada skybox son
-- INTERNAS (no se muestran en la UI); solo filtran el pool.
-- ============================================================

local ventana = _G["GMToolsFrame"]
local subVentanaIzq = _G["GMToolsSubVentanaIzq"]
if not ventana then
    return
end

local ok, err = pcall(function()

local ASSETS = "Interface\\AddOns\\GMTools\\icons\\"

-- ════════════════════════════════════════════════════════════
-- DATOS: los 91 skyboxes de la carpeta skybox-ui.
-- nombre = nombre del archivo sin extensión; archivo = ruta
-- relativa al addon.
-- ════════════════════════════════════════════════════════════
local SKYBOXES = {
    { nombre = "Anochecer - 337389", archivo = "skybox-ui\\Anochecer - 337389.blp", categorias = { "NOCHE" } },
    { nombre = "Atardecer - 1002527", archivo = "skybox-ui\\Atardecer - 1002527.blp", categorias = { "ATARDECER" } },
    { nombre = "Atardecer - 1002812", archivo = "skybox-ui\\Atardecer - 1002812.blp", categorias = { "ATARDECER" } },
    { nombre = "Atardecer - 1003147", archivo = "skybox-ui\\Atardecer - 1003147.blp", categorias = { "ATARDECER" } },
    { nombre = "Atardecer - 1003187", archivo = "skybox-ui\\Atardecer - 1003187.blp", categorias = { "ATARDECER" } },
    { nombre = "Atardecer - 1003354", archivo = "skybox-ui\\Atardecer - 1003354.blp", categorias = { "ATARDECER" } },
    { nombre = "Atardecer - 1003526", archivo = "skybox-ui\\Atardecer - 1003526.blp", categorias = { "ATARDECER" } },
    { nombre = "Atardecer con Estrellas - 1003536", archivo = "skybox-ui\\Atardecer con Estrellas - 1003536.blp", categorias = { "ATARDECER", "NOCHE" } },
    { nombre = "Aurora Boreal - 1001716", archivo = "skybox-ui\\Aurora Boreal - 1001716.blp", categorias = { "NOCHE" } },
    { nombre = "Aurora tras la Tormenta - 239944", archivo = "skybox-ui\\Aurora tras la Tormenta - 239944.blp", categorias = { "NOCHE" } },
    { nombre = "Cielo Azul Nublado - 1002576", archivo = "skybox-ui\\Cielo Azul Nublado - 1002576.blp", categorias = { "DESPEJADO", "NUBLADO" } },
    { nombre = "Cielo de Tormenta - 1002495", archivo = "skybox-ui\\Cielo de Tormenta - 1002495.blp", categorias = { "TORMENTA" } },
    { nombre = "Cielo Despejado - 1001885", archivo = "skybox-ui\\Cielo Despejado - 1001885.blp", categorias = { "DESPEJADO" } },
    { nombre = "Cielo Despejado - 1001963", archivo = "skybox-ui\\Cielo Despejado - 1001963.blp", categorias = { "DESPEJADO" } },
    { nombre = "Cielo Despejado - 1003166", archivo = "skybox-ui\\Cielo Despejado - 1003166.blp", categorias = { "DESPEJADO" } },
    { nombre = "Cielo Gris - 1002464", archivo = "skybox-ui\\Cielo Gris - 1002464.blp", categorias = { "NUBLADO" } },
    { nombre = "Cielo Gris - 1003040", archivo = "skybox-ui\\Cielo Gris - 1003040.blp", categorias = { "NUBLADO" } },
    { nombre = "Cielo Morado - 1001864", archivo = "skybox-ui\\Cielo Morado - 1001864.blp", categorias = { "ATARDECER" } },
    { nombre = "Cielo Morado - 1003829", archivo = "skybox-ui\\Cielo Morado - 1003829.blp", categorias = { "ATARDECER" } },
    { nombre = "Cielo Nublado - 1002041", archivo = "skybox-ui\\Cielo Nublado - 1002041.blp", categorias = { "NUBLADO" } },
    { nombre = "Cielo Oscuro Nublado - 1003094", archivo = "skybox-ui\\Cielo Oscuro Nublado - 1003094.blp", categorias = { "NUBLADO" } },
    { nombre = "Cielo Oscuro Rojo - 1003208", archivo = "skybox-ui\\Cielo Oscuro Rojo - 1003208.blp", categorias = { "ATARDECER" } },
    { nombre = "Cielo Rojo - 1003216", archivo = "skybox-ui\\Cielo Rojo - 1003216.blp", categorias = { "DESPEJADO", "ATARDECER" } },
    { nombre = "Cielo Rosado - 1001722", archivo = "skybox-ui\\Cielo Rosado - 1001722.blp", categorias = { "DESPEJADO", "ATARDECER" } },
    { nombre = "Daltonismo - 1000564", archivo = "skybox-ui\\Daltonismo - 1000564.blp", categorias = { "DESPEJADO", "ESPECIALES" } },
    { nombre = "Despejado con Nubes - 1002071", archivo = "skybox-ui\\Despejado con Nubes - 1002071.blp", categorias = { "DESPEJADO", "NUBLADO" } },
    { nombre = "Eclipse Lunar - 284382", archivo = "skybox-ui\\Eclipse Lunar - 284382.blp", categorias = { "NOCHE" } },
    { nombre = "Espiral de la Muerte - 1000901", archivo = "skybox-ui\\Espiral de la Muerte - 1000901.blp", categorias = { "ESPECIALES" } },
    { nombre = "Formas geométricas mágicas - 1000965", archivo = "skybox-ui\\Formas geométricas mágicas - 1000965.blp", categorias = { "ESPECIALES" } },
    { nombre = "Fuego en el Cielo - 52598", archivo = "skybox-ui\\Fuego en el Cielo - 52598.blp", categorias = { "NIEBLA Y HUMO" } },
    { nombre = "Fuego en el Cielo - 90418", archivo = "skybox-ui\\Fuego en el Cielo - 90418.blp", categorias = { "NIEBLA Y HUMO" } },
    { nombre = "Fuego en el Cielo - 98978", archivo = "skybox-ui\\Fuego en el Cielo - 98978.blp", categorias = { "NIEBLA Y HUMO" } },
    { nombre = "Grandes Nubes - 1002810", archivo = "skybox-ui\\Grandes Nubes - 1002810.blp", categorias = { "NUBLADO" } },
    { nombre = "Grandes Nubes - 1003027", archivo = "skybox-ui\\Grandes Nubes - 1003027.blp", categorias = { "NUBLADO" } },
    { nombre = "Grandes Nubes - 1003129", archivo = "skybox-ui\\Grandes Nubes - 1003129.blp", categorias = { "NUBLADO" } },
    { nombre = "Grandes Nubes - 1003242", archivo = "skybox-ui\\Grandes Nubes - 1003242.blp", categorias = { "NUBLADO" } },
    { nombre = "Grandes Nubes - 1003344", archivo = "skybox-ui\\Grandes Nubes - 1003344.blp", categorias = { "NUBLADO" } },
    { nombre = "Grandes Nubes - 1003397", archivo = "skybox-ui\\Grandes Nubes - 1003397.blp", categorias = { "NUBLADO" } },
    { nombre = "Humo de Incendio - 1001728", archivo = "skybox-ui\\Humo de Incendio - 1001728.blp", categorias = { "NIEBLA Y HUMO" } },
    { nombre = "Humo en el Horizonte - 1001845", archivo = "skybox-ui\\Humo en el Horizonte - 1001845.blp", categorias = { "NIEBLA Y HUMO" } },
    { nombre = "Huracán Oscuro - 1002145", archivo = "skybox-ui\\Huracán Oscuro - 1002145.blp", categorias = { "TORMENTA" } },
    { nombre = "Interior de Cueva - 1003198", archivo = "skybox-ui\\Interior de Cueva - 1003198.blp", categorias = { "ESPECIALES" } },
    { nombre = "Luna Creciente - 284385", archivo = "skybox-ui\\Luna Creciente - 284385.blp", categorias = { "NOCHE" } },
    { nombre = "Luna Roja - 1003132", archivo = "skybox-ui\\Luna Roja - 1003132.blp", categorias = { "NOCHE" } },
    { nombre = "Luz Solar - 1002331", archivo = "skybox-ui\\Luz Solar - 1002331.png", categorias = { "DESPEJADO" } },
    { nombre = "Niebla Ligera - 1003183", archivo = "skybox-ui\\Niebla Ligera - 1003183.blp", categorias = { "NIEBLA Y HUMO" } },
    { nombre = "Niebla verde - 1001042", archivo = "skybox-ui\\Niebla verde - 1001042.blp", categorias = { "NIEBLA Y HUMO" } },
    { nombre = "Nieve con Niebla - 1002811", archivo = "skybox-ui\\Nieve con Niebla - 1002811.blp", categorias = { "NIEBLA Y HUMO" } },
    { nombre = "Noche algo oscura - 1001041", archivo = "skybox-ui\\Noche algo oscura - 1001041.blp", categorias = { "NOCHE" } },
    { nombre = "Noche de Niebla Baja - 1003191", archivo = "skybox-ui\\Noche de Niebla Baja - 1003191.blp", categorias = { "NOCHE", "NIEBLA Y HUMO" } },
    { nombre = "Noche Estrellada - 1002669", archivo = "skybox-ui\\Noche Estrellada - 1002669.blp", categorias = { "NOCHE" } },
    { nombre = "Noche Morada - 1003531", archivo = "skybox-ui\\Noche Morada - 1003531.blp", categorias = { "NOCHE" } },
    { nombre = "Noche Oscura - 1002488", archivo = "skybox-ui\\Noche Oscura - 1002488.blp", categorias = { "NOCHE" } },
    { nombre = "Noche Violácea - 1000870", archivo = "skybox-ui\\Noche Violácea - 1000870.blp", categorias = { "NOCHE" } },
    { nombre = "Nubes (con movimiento) - 1002029", archivo = "skybox-ui\\Nubes (con movimiento) - 1002029.blp", categorias = { "NUBLADO" } },
    { nombre = "Nubes - 1002050", archivo = "skybox-ui\\Nubes - 1002050.blp", categorias = { "NUBLADO" } },
    { nombre = "Nubes - 1002471", archivo = "skybox-ui\\Nubes - 1002471.blp", categorias = { "NUBLADO" } },
    { nombre = "Nubes - 1002726", archivo = "skybox-ui\\Nubes - 1002726.blp", categorias = { "NUBLADO" } },
    { nombre = "Nubes Azules - 1002188", archivo = "skybox-ui\\Nubes Azules - 1002188.blp", categorias = { "DESPEJADO", "NUBLADO" } },
    { nombre = "Nubes con Relámpagos - 1002059", archivo = "skybox-ui\\Nubes con Relámpagos - 1002059.blp", categorias = { "TORMENTA" } },
    { nombre = "Nubes Doradas - 1002112", archivo = "skybox-ui\\Nubes Doradas - 1002112.blp", categorias = { "DESPEJADO", "ATARDECER" } },
    { nombre = "Nubes en el Horizonte - 1001769", archivo = "skybox-ui\\Nubes en el Horizonte - 1001769.blp", categorias = { "NUBLADO" } },
    { nombre = "Nubes en el Horizonte - 1001895", archivo = "skybox-ui\\Nubes en el Horizonte - 1001895.blp", categorias = { "NUBLADO" } },
    { nombre = "Nubes en el Horizonte - 124985", archivo = "skybox-ui\\Nubes en el Horizonte - 124985.blp", categorias = { "NUBLADO" } },
    { nombre = "Nubes Grandes - 1001977", archivo = "skybox-ui\\Nubes Grandes - 1001977.blp", categorias = { "NUBLADO" } },
    { nombre = "Nubes Marrones - 1003582", archivo = "skybox-ui\\Nubes Marrones - 1003582.blp", categorias = { "NUBLADO" } },
    { nombre = "Nubes Oscuras - 1003244", archivo = "skybox-ui\\Nubes Oscuras - 1003244.blp", categorias = { "NUBLADO" } },
    { nombre = "Nublado - 214608", archivo = "skybox-ui\\Nublado - 214608.blp", categorias = { "NUBLADO" } },
    { nombre = "Nublado Gris - 1003170", archivo = "skybox-ui\\Nublado Gris - 1003170.blp", categorias = { "NUBLADO" } },
    { nombre = "Nublado Gris - 1003215", archivo = "skybox-ui\\Nublado Gris - 1003215.blp", categorias = { "NUBLADO" } },
    { nombre = "Nublado Gris - 1003247", archivo = "skybox-ui\\Nublado Gris - 1003247.blp", categorias = { "NUBLADO" } },
    { nombre = "Nublado Marrón - 1001856", archivo = "skybox-ui\\Nublado Marrón - 1001856.blp", categorias = { "NUBLADO" } },
    { nombre = "Nublado Marrón - 1003144", archivo = "skybox-ui\\Nublado Marrón - 1003144.blp", categorias = { "NUBLADO" } },
    { nombre = "Nublado Marrón - 1003444", archivo = "skybox-ui\\Nublado Marrón - 1003444.blp", categorias = { "NUBLADO" } },
    { nombre = "Nublado Oscuro - 1002060", archivo = "skybox-ui\\Nublado Oscuro - 1002060.blp", categorias = { "NUBLADO" } },
    { nombre = "Nublado Oscuro - 1002985", archivo = "skybox-ui\\Nublado Oscuro - 1002985.blp", categorias = { "NUBLADO" } },
    { nombre = "Nublado Oscuro - 1003126", archivo = "skybox-ui\\Nublado Oscuro - 1003126.blp", categorias = { "NUBLADO" } },
    { nombre = "Nublado Oscuro - 1003225", archivo = "skybox-ui\\Nublado Oscuro - 1003225.blp", categorias = { "NUBLADO" } },
    { nombre = "Nublado Verdoso - 1003222", archivo = "skybox-ui\\Nublado Verdoso - 1003222.blp", categorias = { "NIEBLA Y HUMO" } },
    { nombre = "Tormenta - 1003285", archivo = "skybox-ui\\Tormenta - 1003285.blp", categorias = { "TORMENTA" } },
    { nombre = "Tormenta Azul con Relámpagos - 1001741", archivo = "skybox-ui\\Tormenta Azul con Relámpagos - 1001741.blp", categorias = { "TORMENTA" } },
    { nombre = "Tormenta con Relámpagos - 1001792", archivo = "skybox-ui\\Tormenta con Relámpagos - 1001792.blp", categorias = { "TORMENTA" } },
    { nombre = "Tormenta con Relámpagos - 1001996", archivo = "skybox-ui\\Tormenta con Relámpagos - 1001996.blp", categorias = { "TORMENTA" } },
    { nombre = "Tormenta con Relámpagos - 148137", archivo = "skybox-ui\\Tormenta con Relámpagos - 148137.blp", categorias = { "TORMENTA" } },
    { nombre = "Tormenta de Arena - 1002492", archivo = "skybox-ui\\Tormenta de Arena - 1002492.blp", categorias = { "TORMENTA" } },
    { nombre = "Tormenta de Arena - 1003283", archivo = "skybox-ui\\Tormenta de Arena - 1003283.blp", categorias = { "TORMENTA" } },
    { nombre = "Tormenta de Nieve Fuerte - 1001886", archivo = "skybox-ui\\Tormenta de Nieve Fuerte - 1001886.blp", categorias = { "TORMENTA" } },
    { nombre = "Tormenta Gris - 1002066", archivo = "skybox-ui\\Tormenta Gris - 1002066.blp", categorias = { "TORMENTA" } },
    { nombre = "Tormenta Morada - 297309", archivo = "skybox-ui\\Tormenta Morada - 297309.blp", categorias = { "TORMENTA" } },
    { nombre = "Tormenta Morada con Relámpagos - 1001901", archivo = "skybox-ui\\Tormenta Morada con Relámpagos - 1001901.blp", categorias = { "TORMENTA" } },
    { nombre = "Tormenta Oscura con Relámpagos - 1002581", archivo = "skybox-ui\\Tormenta Oscura con Relámpagos - 1002581.blp", categorias = { "TORMENTA" } },
}

-- ════════════════════════════════════════════════════════════
-- ORDEN GUARDADO (por cuenta): el jugador intercambia skyboxes
-- con las flechitas de cada celda y el orden se guarda en
-- GMToolsSkyboxOrden (SavedVariables, compartido entre personajes).
-- ════════════════════════════════════════════════════════════
local ORDEN = {}          -- ORDEN[pos] = índice en SKYBOXES
local posDeNombre = {}    -- posDeNombre[nombre] = posición (1..#SKYBOXES)
local listaOrdenada = {}  -- SKYBOXES reordenados según ORDEN

local function reconstruirLista()
    wipe(listaOrdenada)
    for pos, idx in ipairs(ORDEN) do
        listaOrdenada[pos] = SKYBOXES[idx]
    end
    wipe(posDeNombre)
    for pos, idx in ipairs(ORDEN) do
        posDeNombre[SKYBOXES[idx].nombre] = pos
    end
end

local function guardarOrden()
    GMToolsSkyboxOrden = {}
    for pos, idx in ipairs(ORDEN) do
        GMToolsSkyboxOrden[pos] = SKYBOXES[idx].nombre
    end
end

-- Cargar el orden guardado; si no es válido, se usa el por defecto
local ordenValido = type(GMToolsSkyboxOrden) == "table" and #GMToolsSkyboxOrden == #SKYBOXES
if ordenValido then
    local idxPorNombre = {}
    for i, e in ipairs(SKYBOXES) do idxPorNombre[e.nombre] = i end
    for pos, nombre in ipairs(GMToolsSkyboxOrden) do
        local idx = idxPorNombre[nombre]
        if not idx then
            ordenValido = false
            break
        end
        ORDEN[pos] = idx
    end
end
if not ordenValido then
    ORDEN = {}
    for i = 1, #SKYBOXES do ORDEN[i] = i end
end
reconstruirLista()

local function getSkyboxes()
    return listaOrdenada
end

local function resetearOrden()
    ORDEN = {}
    for i = 1, #SKYBOXES do ORDEN[i] = i end
    reconstruirLista()
    GMToolsSkyboxOrden = nil
end

-- API expuesta para la pestaña de weather (Tool-Weather.lua):
-- el reset funciona sobre el mismo orden compartido.
GMTOOLS_SKY_RESETEAR = resetearOrden

-- API expuesta para la pestaña de Control de Auras (Tool-Control-Auras.lua):
-- mapa de id de aura → nombre del skybox (el número con el que acaba
-- el nombre es el id de aura que usan APLICAR/QUITAR) y el conjunto
-- de nombres completos, para poder detectar qué skyboxes tiene
-- activos cada jugador aunque el cliente no reporte el id del aura.
GMTOOLS_SKY_AURAS = {}
GMTOOLS_SKY_NOMBRES = {}
for _, e in ipairs(SKYBOXES) do
    local num = e.nombre:match("(%d+)%s*$")
    if num then
        GMTOOLS_SKY_AURAS[tonumber(num)] = e.nombre
        GMTOOLS_SKY_NOMBRES[e.nombre] = true
    end
end

-- ════════════════════════════════════════════════════════════
-- BOTÓN EN LA SUBVENTANA IZQUIERDA (fila 2, a la derecha de
-- diálogos), mismo estilo que los de la rejilla.
-- ════════════════════════════════════════════════════════════
local btnSkybox = CreateFrame("Button", nil, subVentanaIzq or ventana)
btnSkybox:SetSize(37, 37)
if subVentanaIzq then
    btnSkybox:SetPoint("TOPLEFT", subVentanaIzq, "TOPLEFT", 45, -45)
else
    btnSkybox:SetPoint("LEFT", ventana, "LEFT", 313, 0)
end

local iconSkybox = btnSkybox:CreateTexture(nil, "BACKGROUND")
iconSkybox:SetSize(36, 36)
iconSkybox:SetPoint("CENTER")
iconSkybox:SetTexture("Interface\\AddOns\\GMTools\\icons\\icono-skybox")

local glowSkyboxOk = pcall(function()
    btnSkybox:SetHighlightAtlas("ChallengeMode-KeystoneSlotFrameGlow")
end)
if glowSkyboxOk then
    local glow = btnSkybox:GetHighlightTexture()
    glow:ClearAllPoints()
    glow:SetPoint("CENTER")
    glow:SetSize(37 * 1.66, 37 * 1.66)
    glow:SetAlpha(0.5)
end

GMToolsBtnSkybox = btnSkybox

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
-- CONSTANTES DE LAYOUT (grid 3x3)
-- ════════════════════════════════════════════════════════════
local NUM_COLS  = 3
local NUM_ROWS  = 3
local NUM_SLOTS = NUM_COLS * NUM_ROWS   -- 9 celdas visibles siempre
local PAD_SIDE  = 8
local PAD_TOP   = 8
local PAD_ROW   = 8
local PAD_BOT   = 10
local SEARCH_H  = 32
local BOTTOM_H  = 36
local TITLE_H   = 18   -- zona del título encima de la textura
local BTN_ZONE  = 30   -- zona de los botones debajo de la textura
local WIN_H     = 740
local WIN_W     = 1000
local AVAIL_H   = WIN_H - PAD_SIDE - SEARCH_H - PAD_TOP - PAD_ROW - PAD_BOT
                  - BOTTOM_H - PAD_SIDE - math.floor(BOTTOM_H / 2)
local CELL_H    = math.floor(AVAIL_H / NUM_ROWS)
local PADDING_X = 12
local AVAIL_W   = WIN_W - PAD_SIDE * 2
local MODEL_W   = math.floor((AVAIL_W - PADDING_X * (NUM_COLS - 1)) / NUM_COLS)

local function cellX(c)
    local totalW = NUM_COLS * MODEL_W + (NUM_COLS - 1) * PADDING_X
    local startX = -(totalW / 2) + (MODEL_W / 2)
    return startX + (c - 1) * (MODEL_W + PADDING_X)
end

-- ════════════════════════════════════════════════════════════
-- ESTADO DE PAGINACIÓN Y BÚSQUEDA
-- ════════════════════════════════════════════════════════════
local paginaActual    = 1
local listaActiva     = nil
local categoriasActivas = {}
local labelPagina     = nil

-- Constantes de botones de categoría (necesarias también para las flechas)
local CAT_W, CAT_H, CAT_GAP = 90, 34, 6

local function totalPaginas()
    return math.max(1, math.ceil(#listaActiva / NUM_SLOTS))
end

-- ════════════════════════════════════════════════════════════
-- VENTANA PRINCIPAL
-- ════════════════════════════════════════════════════════════
local skyboxVentana = CreateFrame("Frame", "GMToolsSkyboxFrame", UIParent, "BackdropTemplate")
skyboxVentana:SetSize(WIN_W, WIN_H)
-- Anclada al centro superior de la pestaña general derecha de GMTools,
-- 5 px por encima (su borde inferior toca arriba de la principal).
local izq = GMToolsFrame
if izq then
    skyboxVentana:SetPoint("BOTTOM", izq, "TOP", 0, 5)
else
    skyboxVentana:SetPoint("BOTTOM", ventana, "TOP", 0, 8)
end
ApplyDarkPanel(skyboxVentana)
skyboxVentana:EnableMouse(true)
skyboxVentana:SetMovable(true)
skyboxVentana:RegisterForDrag("LeftButton")
skyboxVentana:SetScript("OnDragStart", skyboxVentana.StartMoving)
skyboxVentana:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Guarda la posición (compartida con la pestaña de weather):
    -- si luego se abre la otra, aparece en la posición de esta.
    local l, b = self:GetLeft(), self:GetBottom()
    if l and b then
        GMToolsWeatherPos = { math.floor(l), math.floor(b) }
    end
end)
skyboxVentana:Hide()

-- ════════════════════════════════════════════════════════════
-- BARRA DE BÚSQUEDA
-- ════════════════════════════════════════════════════════════
local searchRow = CreateFrame("Frame", nil, skyboxVentana, "BackdropTemplate")
searchRow:SetHeight(SEARCH_H)
searchRow:SetPoint("TOPLEFT",  skyboxVentana, "TOPLEFT",   PAD_SIDE, -PAD_SIDE)
searchRow:SetPoint("TOPRIGHT", skyboxVentana, "TOPRIGHT", -PAD_SIDE, -PAD_SIDE)
ApplyDarkPanel(searchRow)
searchRow:SetBackdropColor(0.1, 0.11, 0.15, 0.9)

local inputBusqueda = CreateFrame("EditBox", "GMToolsSkyboxInput", searchRow, "InputBoxTemplate")
inputBusqueda:SetHeight(22)
inputBusqueda:SetPoint("LEFT",  searchRow, "LEFT",   10,  0)
inputBusqueda:SetPoint("RIGHT", searchRow, "CENTER", -5,  0)
inputBusqueda:SetAutoFocus(false)
inputBusqueda:SetFontObject("GameFontHighlight")

local placeholder = searchRow:CreateFontString(nil, "OVERLAY", "GameFontDisable")
placeholder:SetPoint("LEFT", inputBusqueda, "LEFT", 2, 0)
placeholder:SetText("Buscar skybox...")
inputBusqueda:HookScript("OnTextChanged",    function(self) placeholder:SetShown(self:GetText() == "") end)
inputBusqueda:HookScript("OnEditFocusGained",function()     placeholder:Hide() end)
inputBusqueda:HookScript("OnEditFocusLost",  function(self) placeholder:SetShown(self:GetText() == "") end)

local botonBuscar = CreateFrame("Button", nil, searchRow)
botonBuscar:SetSize(30, 30)
botonBuscar:SetPoint("LEFT", searchRow, "CENTER", 4, 0)
local iconSearch = botonBuscar:CreateTexture(nil, "ARTWORK")
iconSearch:SetAllPoints()
iconSearch:SetTexture(ASSETS .. "skybox-search")
botonBuscar:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

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
closeButton:SetScript("OnClick", function() skyboxVentana:Hide() end)

-- Botón "Control de Auras" — junto a la X
local wrapperEditar = CreateFrame("Frame", nil, searchRow, "BackdropTemplate")
wrapperEditar:SetSize(110 + 4, SEARCH_H - 6)
wrapperEditar:SetPoint("RIGHT", closeButton, "LEFT", -6, 0)
wrapperEditar:SetBackdrop({
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 2,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
wrapperEditar:SetBackdropBorderColor(0, 0, 0, 0)

local botonEditar = CreateFrame("Button", nil, wrapperEditar, "BackdropTemplate")
botonEditar:SetSize(110, math.floor((SEARCH_H - 10) * 0.9))
botonEditar:SetPoint("CENTER", wrapperEditar, "CENTER", 0, 0)
botonEditar:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true, tileSize = 16, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
botonEditar:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
botonEditar:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

local labelEditar = botonEditar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
labelEditar:SetPoint("CENTER", botonEditar, "CENTER", 0, 0)
labelEditar:SetText("Control de Auras")
labelEditar:SetTextColor(1, 0.85, 0)

botonEditar:SetScript("OnClick", function()
    -- GMToolsControlAurasAbrir ya dispara la cola de lookups (click).
    GMToolsControlAurasAbrir(skyboxVentana)
end)
botonEditar:SetScript("OnEnter", function(self)
    self:SetBackdropColor(0.2, 0.3, 0.55, 0.95)
    self:SetBackdropBorderColor(0.5, 0.75, 1, 1)
    wrapperEditar:SetBackdropBorderColor(0.9, 0.75, 0.1, 1)
end)
botonEditar:SetScript("OnLeave", function(self)
    self:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
    self:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    wrapperEditar:SetBackdropBorderColor(0, 0, 0, 0)
end)

-- Botón "Weather" — a la izquierda de Control de Auras
local wrapperEliminar = CreateFrame("Frame", nil, searchRow, "BackdropTemplate")
wrapperEliminar:SetSize(72, SEARCH_H - 6)
wrapperEliminar:SetPoint("RIGHT", wrapperEditar, "LEFT", -6, 0)
wrapperEliminar:SetBackdrop({
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 2,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
wrapperEliminar:SetBackdropBorderColor(0, 0, 0, 0)

local botonEliminar = CreateFrame("Button", nil, wrapperEliminar, "BackdropTemplate")
botonEliminar:SetSize(68, math.floor((SEARCH_H - 10) * 0.9))
botonEliminar:SetPoint("CENTER", wrapperEliminar, "CENTER", 0, 0)
botonEliminar:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true, tileSize = 16, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
botonEliminar:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
botonEliminar:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

local labelEliminar = botonEliminar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
labelEliminar:SetPoint("CENTER", botonEliminar, "CENTER", 0, 0)
labelEliminar:SetText("Weather")
labelEliminar:SetTextColor(1, 0.85, 0)

botonEliminar:SetScript("OnClick", function()
    -- Cambia a la pestaña de WEATHER: pasa la posición EXACTA de
    -- esta pestaña para que weather salga en el mismo sitio.
    local l, b = skyboxVentana:GetLeft(), skyboxVentana:GetBottom()
    GMToolsWeatherPos = (l and b) and { math.floor(l), math.floor(b) } or nil
    skyboxVentana:Hide()
    if GMToolsWeatherFrame then
        GMToolsWeatherFrame:Show()
    end
end)
botonEliminar:SetScript("OnEnter", function(self)
    self:SetBackdropColor(0.2, 0.3, 0.55, 0.95)
    self:SetBackdropBorderColor(0.5, 0.75, 1, 1)
    wrapperEliminar:SetBackdropBorderColor(0.9, 0.75, 0.1, 1)
end)
botonEliminar:SetScript("OnLeave", function(self)
    self:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
    self:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    wrapperEliminar:SetBackdropBorderColor(0, 0, 0, 0)
end)

-- ════════════════════════════════════════════════════════════
-- BOTÓN TODOS / SOLO YO (mismo diseño que los botones de arriba,
-- más ancho, con los dos textos a los lados):
--   TODOS   → .ph aura/.ph unaura (afecta a todos)
--   SOLO YO → .aura/.unaura (solo a ti)
-- Por defecto está en TODOS. El texto activo se ilumina en dorado
-- y el inactivo queda gris. El efecto de luz al posar el ratón
-- SOLO se aplica a la mitad que está activa (dos mitades sin borde
-- intermedio dentro del botón).
-- ════════════════════════════════════════════════════════════
local alcanceTodos = true

local btnAlcance = CreateFrame("Frame", nil, searchRow, "BackdropTemplate")
btnAlcance:SetSize(160, math.floor((SEARCH_H - 10) * 0.9))
btnAlcance:SetPoint("RIGHT", wrapperEliminar, "LEFT", -10, 0)
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
    -- 1px de margen por cada lado: el borde del botón queda POR
    -- DELANTE (se ve), la luz no lo tapa.
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

-- La luz queda fija SIEMPRE en la mitad activa
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

pintarAlcance()
pintarLuz()

-- ════════════════════════════════════════════════════════════
-- CHECKBOX "SOLO DORADOS" (a la izquierda de TODOS/SOLO YO):
-- cuadrado sin texto; al marcarlo se rellena del mismo dorado de los
-- bordes (1, 0.85, 0). Por defecto desmarcado. Marcado → la lista
-- solo muestra las skyboxes con el borde dorado en ese momento.
-- ════════════════════════════════════════════════════════════
local soloDorados = false
local ultimaClaveDorados = ""

local chkDorados = CreateFrame("Button", nil, searchRow, "BackdropTemplate")
chkDorados:SetSize(math.floor((SEARCH_H - 10) * 0.9), math.floor((SEARCH_H - 10) * 0.9))
chkDorados:SetPoint("RIGHT", btnAlcance, "LEFT", -10, 0)
chkDorados:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true, tileSize = 16, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
chkDorados:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
chkDorados:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

local chkDoradosRelleno = chkDorados:CreateTexture(nil, "BACKGROUND")
chkDoradosRelleno:SetColorTexture(1, 0.85, 0, 1)
chkDoradosRelleno:SetPoint("TOPLEFT", chkDorados, "TOPLEFT", 2, -2)
chkDoradosRelleno:SetPoint("BOTTOMRIGHT", chkDorados, "BOTTOMRIGHT", -2, 2)
chkDoradosRelleno:Hide()

local function pintarChkDorados()
    chkDoradosRelleno:SetShown(soloDorados)
    if soloDorados then
        chkDorados:SetBackdropBorderColor(1, 0.85, 0, 1)
    else
        chkDorados:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    end
end

-- Clave de los ids activos ordenados: la lista dorada solo se
-- re-filtra cuando este conjunto cambia (evita resetear la página
-- del listado a cada tick del refresco).
local function generarClaveDorados()
    local claves = {}
    for id in pairs(GMToolsSkyboxActivos or {}) do
        claves[#claves + 1] = tostring(id)
    end
    table.sort(claves)
    return table.concat(claves, ",")
end

-- El OnClick se asigna MÁS ABAJO (después de la definición de
-- calcularListaActiva/mostrarPagina): si se asignara aquí, esos
-- nombres locales todavía no estarían en ámbito y el click fallaría.

pintarChkDorados()

-- Dispara los lookups de ids pendientes. SOLO debe llamarse desde
-- clicks reales (contexto de usuario garantizado) o desde el filtro
-- de chat; desde OnShow/timers da "Interface action failed because
-- of an AddOn" en este cliente.
local function dispararLookups()
    if GMTOOLS_SKY_DISP_COLA then GMTOOLS_SKY_DISP_COLA() end
end

-- Comando de aura según el deslizador
local function comandoAura(id, quitar)
    local msg
    if alcanceTodos then
        msg = quitar and (".ph unaura " .. id) or (".ph aura " .. id)
    else
        msg = quitar and (".unaura " .. id) or (".aura " .. id)
    end
    SendChatMessage(msg, "SAY")
end

-- ════════════════════════════════════════════════════════════
-- 9 CELDAS (slots reutilizables)
-- Cada celda es una subventana con el mismo estilo que el resto
-- (fondo oscuro + borde azul) y dentro lleva título, textura,
-- botones APLICAR/QUITAR y dos flechitas para intercambiar su
-- posición con la celda de al lado (el orden se guarda por cuenta).
-- ════════════════════════════════════════════════════════════

-- Declaración previa: los OnClick de las flechas y el numerito se
-- definen aquí, antes de las funciones; sin esto Lua las trataría
-- como globales.
local swapPosiciones
local moverA
local refrescarDespuesDeCambio
local mostrarPagina
local calcularListaActiva

local slots = {}

for i = 1, NUM_SLOTS do
    local col  = ((i - 1) % NUM_COLS) + 1
    local fila = math.floor((i - 1) / NUM_COLS)
    local anchorY = -PAD_TOP - fila * (CELL_H + PAD_ROW)

    local cell = CreateFrame("Frame", nil, skyboxVentana, "BackdropTemplate")
    cell:SetSize(MODEL_W, CELL_H)
    cell:SetPoint("TOP", searchRow, "BOTTOM", cellX(col), anchorY)
    ApplyDarkPanel(cell)
    cell:Hide()

    -- Título encima de la textura (textito pequeño)
    local etiqueta = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    etiqueta:SetPoint("TOP", cell, "TOP", 0, -8)
    etiqueta:SetTextColor(1, 1, 1)

    -- Numerito de posición editable (arriba a la izquierda),
    -- INVISIBLE (sin fondo ni borde): solo se ve el número, con la
    -- misma fuente/tamaño que el texto de los botones APLICAR/QUITAR.
    local numBox = CreateFrame("EditBox", nil, cell, "BackdropTemplate")
    numBox:SetSize(34, 18)
    numBox:SetPoint("TOPLEFT", cell, "TOPLEFT", 5, -3)
    numBox:SetBackdropColor(0, 0, 0, 0)
    numBox:SetFontObject(GameFontHighlightSmall)
    numBox:SetTextColor(1, 1, 1)
    numBox:SetTextInsets(2, 2, 0, 0)
    numBox:SetAutoFocus(false)

    local function aplicarNumero(self)
        local inicioNum = (paginaActual - 1) * NUM_SLOTS + 1
        local entrada = listaActiva[inicioNum + i - 1]
        if not entrada then return end
        local p = posDeNombre[entrada.nombre]
        if not p then return end
        local q = tonumber(self:GetText())
        if not q then return end
        moverA(p, math.floor(q))
    end
    numBox:SetScript("OnEnterPressed", function(self)
        aplicarNumero(self)
        self:ClearFocus()
    end)
    numBox:SetScript("OnEditFocusLost", aplicarNumero)

    -- Textura del skybox (centro): proporción natural 2:1, un poco
    -- más pequeña que la zona para que no se vea forzada, centrada.
    local TEX_ASPECT = 2
    local TEX_SCALE  = 0.9
    local texHMax    = CELL_H - TITLE_H - BTN_ZONE
    local texWMax    = MODEL_W - 4
    local texH       = math.min(texHMax, texWMax / TEX_ASPECT) * TEX_SCALE
    local texW       = texH * TEX_ASPECT
    local texOffsetY = -(TITLE_H + texHMax / 2) + CELL_H / 2

    local tex = cell:CreateTexture(nil, "ARTWORK")
    tex:SetSize(texW, texH)
    tex:SetPoint("CENTER", cell, "CENTER", 0, texOffsetY)

    -- Botones debajo: APLICAR (izquierda) / QUITAR (derecha)
    local BTN_W   = 72
    local BTN_H   = 24
    local BTN_GAP = 4

    local function crearBoton(texto, xOffset)
        local btn = CreateFrame("Button", nil, cell, "BackdropTemplate")
        btn:SetSize(BTN_W, BTN_H)
        btn:SetPoint("BOTTOM", cell, "BOTTOM", xOffset, 9)
        btn:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            tile = true, tileSize = 16, edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        btn:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
        btn:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
        local label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("CENTER")
        label:SetTextColor(1, 1, 1)
        label:SetText(texto)
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.2, 0.3, 0.55, 0.95)
            self:SetBackdropBorderColor(0.5, 0.75, 1, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
            self:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
        end)
        return btn
    end

    local btnAplicar = crearBoton("APLICAR", -(BTN_W / 2 + BTN_GAP / 2))
    local btnQuitar  = crearBoton("QUITAR",  (BTN_W / 2 + BTN_GAP / 2))

    -- APLICAR → comando según el deslizador (TODOS/SOLO YO)
    -- QUITAR → versión de quitar del mismo
    btnAplicar:SetScript("OnClick", function()
        local entrada = slots[i].entrada
        if not entrada then return end
        local id = entrada.nombre:match("(%d+)$")
        if id then comandoAura(id, false) end
        -- Refresco forzado: se re-dispara la cola de lookups (aprender
        -- ids pendientes) y se relee/repinta al momento. El aura
        -- aplicada tarda un momento en aparecer en la unidad: el
        -- OnUpdate de la ventana la capta y pinta el dorado solo.
        dispararLookups()
        if GMTOOLS_SKY_REESCAN then GMTOOLS_SKY_REESCAN() end
    end)
    btnQuitar:SetScript("OnClick", function()
        local entrada = slots[i].entrada
        if not entrada then return end
        local id = entrada.nombre:match("(%d+)$")
        if id then comandoAura(id, true) end
        dispararLookups()
        if GMTOOLS_SKY_REESCAN then GMTOOLS_SKY_REESCAN() end
    end)

    -- Flechitas de intercambio: la izquierda cambia la posición con
    -- la entrada anterior y la derecha con la siguiente, SEGÚN LA
    -- LISTA FILTRADA ACTUAL: con filtros activos se salta a los
    -- desactivados (no intercambian).
    local flechaIzq = CreateFrame("Button", nil, cell)
    flechaIzq:SetSize(27, 27)
    flechaIzq:SetPoint("BOTTOMLEFT", cell, "BOTTOMLEFT", 5, 5)
    flechaIzq:EnableMouse(true)
    local texIzq = flechaIzq:CreateTexture(nil, "ARTWORK")
    texIzq:SetAllPoints()
    texIzq:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    flechaIzq:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    flechaIzq:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    flechaIzq:SetScript("OnClick", function()
        local k = (paginaActual - 1) * NUM_SLOTS + i
        local vecino = listaActiva[k - 1]
        if not vecino then return end
        local entrada = listaActiva[k]
        if not entrada then return end
        local p  = posDeNombre[entrada.nombre]
        local pv = posDeNombre[vecino.nombre]
        if p and pv then swapPosiciones(p, pv) end
        dispararLookups()
    end)

    local flechaDer = CreateFrame("Button", nil, cell)
    flechaDer:SetSize(27, 27)
    flechaDer:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT", -5, 5)
    flechaDer:EnableMouse(true)
    local texDer = flechaDer:CreateTexture(nil, "ARTWORK")
    texDer:SetAllPoints()
    texDer:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    flechaDer:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    flechaDer:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    flechaDer:SetScript("OnClick", function()
        local k = (paginaActual - 1) * NUM_SLOTS + i
        local vecino = listaActiva[k + 1]
        if not vecino then return end
        local entrada = listaActiva[k]
        if not entrada then return end
        local p  = posDeNombre[entrada.nombre]
        local pv = posDeNombre[vecino.nombre]
        if p and pv then swapPosiciones(p, pv) end
        dispararLookups()
    end)

    slots[i] = { cell = cell, col = col, fila = fila, etiqueta = etiqueta,
                 numBox = numBox, tex = tex, btnAplicar = btnAplicar,
                 btnQuitar = btnQuitar, flechaIzq = flechaIzq, flechaDer = flechaDer }
end

-- ════════════════════════════════════════════════════════════
-- REORDENADO POR POSICIONES (1..#ORDEN = orden maestro guardado)
-- swapPosiciones: intercambia dos posiciones (flechas: ±1).
-- moverA: saca la entrada de la posición p y la mete en la q
-- (desplazando las demás), p.ej. de 10 a 2 → 1 10 2 3 4 5 6 7 8 9 11...
-- ════════════════════════════════════════════════════════════
refrescarDespuesDeCambio = function()
    if calcularListaActiva(inputBusqueda:GetText()) then
        mostrarPagina(listaActiva, paginaActual)
    end
end

swapPosiciones = function(p, q)
    if not p or not q then return end
    if p < 1 or q < 1 or p > #ORDEN or q > #ORDEN or p == q then return end
    ORDEN[p], ORDEN[q] = ORDEN[q], ORDEN[p]
    reconstruirLista()
    guardarOrden()
    refrescarDespuesDeCambio()
end

moverA = function(p, q)
    if not p or not q then return end
    if p < 1 or p > #ORDEN then return end
    if q < 1 then q = 1 end
    if q > #ORDEN then q = #ORDEN end
    if p == q then return end
    local idx = table.remove(ORDEN, p)
    table.insert(ORDEN, q, idx)
    reconstruirLista()
    guardarOrden()
    refrescarDespuesDeCambio()
end

-- ════════════════════════════════════════════════════════════
-- FUNCIÓN PARA POBLAR LOS SLOTS CON UNA PÁGINA
-- ════════════════════════════════════════════════════════════
-- ════════════════════════════════════════════════════════════
-- BORDE DORADO DE SKYBOXES ACTIVOS
-- GMToolsSkyboxActivos lo mantiene Tool-Control-Auras (ids de skybox
-- que alguien del grupo tiene puestos); el id del skybox es el
-- número con el que acaba su nombre. La celda cuyo skybox esté
-- activo se pinta con borde dorado en lugar del azul normal.
-- ════════════════════════════════════════════════════════════
local function pintarActivos()
    local activos = GMToolsSkyboxActivos
    for i = 1, NUM_SLOTS do
        local slot = slots[i]
        if slot.entrada then
            local id = tonumber(slot.entrada.nombre:match("(%d+)$"))
            if activos and id and activos[id] then
                slot.cell:SetBackdropBorderColor(1, 0.85, 0, 1)
            else
                slot.cell:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
            end
        end
    end
end
GMTOOLS_SKY_REPINTAR = pintarActivos

mostrarPagina = function(lista, pagina)
    paginaActual = pagina
    local inicio = (pagina - 1) * NUM_SLOTS + 1
    for i = 1, NUM_SLOTS do
        local slot    = slots[i]
        local entrada = lista[inicio + i - 1]
        if entrada then
            slot.entrada = entrada
            slot.etiqueta:SetText(entrada.nombre)
            slot.tex:SetTexture("Interface\\AddOns\\GMTools\\" .. entrada.archivo)
            slot.numBox:SetText(tostring(posDeNombre[entrada.nombre] or ""))
            slot.cell:Show()
        else
            slot.entrada = nil
            slot.cell:Hide()
        end
    end
    if labelPagina then
        labelPagina:SetText("Página " .. pagina .. "/" .. totalPaginas())
    end
    pintarActivos()
    -- OJO: aquí NO se dispara la cola de lookups. El OnShow de esta
    -- ventana NO es contexto de usuario en este cliente (los envíos
    -- desde OnShow dan "Interface action failed because of an AddOn").
    -- Los lookups se disparan SOLO desde clicks reales (botones de la
    -- ventana y el botón de la barra) y desde el filtro de chat.
end

-- ════════════════════════════════════════════════════════════
-- BÚSQUEDA: nombre O tags (coincidencia parcial)
-- ════════════════════════════════════════════════════════════
local function coincideConBusqueda(entrada, busqueda)
    if entrada.nombre:lower():find(busqueda, 1, true) then return true end
    if entrada.tags then
        for _, tag in ipairs(entrada.tags) do
            if tag:lower():find(busqueda, 1, true) then return true end
        end
    end
    return false
end

-- Devuelve true si hay al menos una categoría activa
local function hayCategoriaActiva()
    for _, v in pairs(categoriasActivas) do
        if v then return true end
    end
    return false
end

-- Pool base: todos los skyboxes o solo los de categorías activas
-- (un skybox entra si coincide con CUALQUIERA de sus categorías)
local function getPoolBase()
    local todas = getSkyboxes()
    if not hayCategoriaActiva() then return todas end
    local filtradas = {}
    for _, entrada in ipairs(todas) do
        if entrada.categorias then
            for _, cat in ipairs(entrada.categorias) do
                if categoriasActivas[cat] then
                    table.insert(filtradas, entrada)
                    break
                end
            end
        end
    end
    return filtradas
end

calcularListaActiva = function(texto)
    local busqueda = texto:lower():gsub("^%s+", ""):gsub("%s+$", "")
    local pool = getPoolBase()
    local base
    if busqueda == "" then
        base = pool
    else
        local resultados = {}
        for _, entrada in ipairs(pool) do
            if coincideConBusqueda(entrada, busqueda) then
                table.insert(resultados, entrada)
            end
        end
        if #resultados == 0 then
            print("GMTools | Skyboxs | No encontrado: " .. texto)
            return false
        end
        base = resultados
    end
    -- Filtro del checkbox dorado: solo las skyboxes activas ahora mismo
    if soloDorados then
        local dorados = {}
        for _, entrada in ipairs(base) do
            local id = tonumber(entrada.nombre:match("(%d+)$"))
            if id and GMToolsSkyboxActivos and GMToolsSkyboxActivos[id] then
                table.insert(dorados, entrada)
            end
        end
        base = dorados
    end
    listaActiva = base
    return true
end

local function ejecutarBusqueda(texto)
    if calcularListaActiva(texto) then
        mostrarPagina(listaActiva, 1)
    end
end

local function aplicarFiltros()
    ejecutarBusqueda(inputBusqueda:GetText())
end

inputBusqueda:SetScript("OnEnterPressed", function(self)
    ejecutarBusqueda(self:GetText())
    self:ClearFocus()
end)
botonBuscar:SetScript("OnClick", function()
    ejecutarBusqueda(inputBusqueda:GetText())
    dispararLookups()
end)
inputBusqueda:HookScript("OnTextChanged", function(self, userInput)
    if userInput then ejecutarBusqueda(self:GetText()) end
end)

-- OnClick del checkbox dorado (asignado aquí: calcularListaActiva y
-- mostrarPagina ya están definidas y en ámbito).
chkDorados:SetScript("OnClick", function()
    soloDorados = not soloDorados
    pintarChkDorados()
    ultimaClaveDorados = generarClaveDorados()
    if calcularListaActiva(inputBusqueda:GetText()) then
        mostrarPagina(listaActiva, 1)
    end
end)

chkDorados:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Ver solo skyboxes activas.")
    GameTooltip:Show()
end)
chkDorados:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- ════════════════════════════════════════════════════════════
-- BARRA INFERIOR (transparente) + FLECHAS + CATEGORÍAS
-- ════════════════════════════════════════════════════════════
local bottomBar = CreateFrame("Frame", nil, skyboxVentana, "BackdropTemplate")
bottomBar:SetHeight(BOTTOM_H)
bottomBar:SetPoint("BOTTOMLEFT",  skyboxVentana, "BOTTOMLEFT",   PAD_SIDE, PAD_SIDE + 10)
bottomBar:SetPoint("BOTTOMRIGHT", skyboxVentana, "BOTTOMRIGHT", -PAD_SIDE, PAD_SIDE + 10)
bottomBar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", tile = true, tileSize = 8 })
bottomBar:SetBackdropColor(0, 0, 0, 0)
bottomBar:SetBackdropBorderColor(0, 0, 0, 0)

-- Flecha izquierda — base alineada con la base de los botones de categoría
local botonPrev = CreateFrame("Button", nil, bottomBar)
botonPrev:SetSize(30, CAT_H)
botonPrev:SetPoint("BOTTOMLEFT", bottomBar, "BOTTOMLEFT", 6, (BOTTOM_H - CAT_H) / 2 - 2)
local texPrev = botonPrev:CreateTexture(nil, "ARTWORK")
texPrev:SetAllPoints()
texPrev:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
botonPrev:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
botonPrev:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
botonPrev:SetScript("OnClick", function()
    local pagina = paginaActual - 1
    if pagina < 1 then pagina = totalPaginas() end
    mostrarPagina(listaActiva, pagina)
    dispararLookups()
end)

-- Botón "Restablecer orden" — a la derecha de la flecha izquierda
local botonReset = CreateFrame("Button", nil, bottomBar, "BackdropTemplate")
botonReset:SetSize(110, 20)
botonReset:SetPoint("BOTTOMLEFT", bottomBar, "BOTTOMLEFT", 38, 6)
botonReset:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true, tileSize = 16, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
botonReset:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
botonReset:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

local labelReset = botonReset:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
labelReset:SetPoint("CENTER")
labelReset:SetTextColor(1, 0.85, 0)
labelReset:SetText("Restablecer orden")

botonReset:SetScript("OnEnter", function(self)
    self:SetBackdropColor(0.2, 0.3, 0.55, 0.95)
    self:SetBackdropBorderColor(0.5, 0.75, 1, 1)
end)
botonReset:SetScript("OnLeave", function(self)
    self:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
    self:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
end)
-- Declaración previa: el OnClick de abajo se define antes que el
-- frame; sin esto Lua trataría confirmReset como global (nil).
local confirmReset

botonReset:SetScript("OnClick", function()
    confirmReset:Show()
end)

-- ════════════════════════════════════════════════════════════
-- VERIFICACIÓN DE RESTABLECER ORDEN (misma idea que la de
-- borrar diálogo): pregunta antes de resetear el orden.
-- ════════════════════════════════════════════════════════════
confirmReset = CreateFrame("Frame", nil, skyboxVentana, "BackdropTemplate")
confirmReset:SetSize(460, 120)
confirmReset:SetPoint("CENTER", skyboxVentana, "CENTER")
ApplyDarkPanel(confirmReset)
confirmReset:SetBackdropColor(0.12, 0.18, 0.40, 0.7)
confirmReset:SetFrameLevel(skyboxVentana:GetFrameLevel() + 20)
confirmReset:Hide()

local txtConfirmarReset = confirmReset:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
txtConfirmarReset:SetPoint("TOP", confirmReset, "TOP", 0, -14)
txtConfirmarReset:SetJustifyH("CENTER")
txtConfirmarReset:SetTextColor(1, 1, 1)
txtConfirmarReset:SetText("¿Estás seguro de que quieres restablecer el orden original?")

local txtExplicacionReset = confirmReset:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
txtExplicacionReset:SetPoint("TOP", txtConfirmarReset, "BOTTOM", 0, -6)
txtExplicacionReset:SetWidth(430)
txtExplicacionReset:SetJustifyH("CENTER")
txtExplicacionReset:SetTextColor(1, 0.85, 0)
txtExplicacionReset:SetText("Se ordenarán alfabéticamente y se perderá el orden que has establecido para tu cuenta. No puede restaurarse esta acción.")

local btnSiReset = CreateFrame("Button", nil, confirmReset, "BackdropTemplate")
btnSiReset:SetSize(60, 24)
btnSiReset:SetPoint("BOTTOMLEFT", confirmReset, "BOTTOMLEFT", 90, 12)
btnSiReset:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true, tileSize = 16, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
btnSiReset:SetBackdropColor(0.12, 0.12, 0.16, 0.9)
btnSiReset:SetBackdropBorderColor(0.7, 0.2, 0.2, 0.9)
local lblSiReset = btnSiReset:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
lblSiReset:SetPoint("CENTER")
lblSiReset:SetTextColor(1, 1, 1)
lblSiReset:SetText("SÍ")
btnSiReset:SetScript("OnClick", function()
    resetearOrden()
    aplicarFiltros()
    confirmReset:Hide()
end)

local btnNoReset = CreateFrame("Button", nil, confirmReset, "BackdropTemplate")
btnNoReset:SetSize(60, 24)
btnNoReset:SetPoint("BOTTOMRIGHT", confirmReset, "BOTTOMRIGHT", -90, 12)
btnNoReset:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true, tileSize = 16, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
btnNoReset:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
btnNoReset:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
local lblNoReset = btnNoReset:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
lblNoReset:SetPoint("CENTER")
lblNoReset:SetTextColor(1, 1, 1)
lblNoReset:SetText("NO")
btnNoReset:SetScript("OnClick", function()
    confirmReset:Hide()
end)

-- Flecha derecha — base alineada con la base de los botones de categoría
local botonNext = CreateFrame("Button", nil, bottomBar)
botonNext:SetSize(30, CAT_H)
botonNext:SetPoint("BOTTOMRIGHT", bottomBar, "BOTTOMRIGHT", -6, (BOTTOM_H - CAT_H) / 2 - 2)
local texNext = botonNext:CreateTexture(nil, "ARTWORK")
texNext:SetAllPoints()
texNext:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
botonNext:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
botonNext:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
botonNext:SetScript("OnClick", function()
    local pagina = paginaActual + 1
    if pagina > totalPaginas() then pagina = 1 end
    mostrarPagina(listaActiva, pagina)
    dispararLookups()
end)

-- Etiqueta de página — a la izquierda de la flecha derecha
labelPagina = bottomBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
labelPagina:SetPoint("RIGHT", botonNext, "LEFT", -8, 0)
labelPagina:SetTextColor(0.75, 0.9, 1)
labelPagina:SetText("Página 1/1")

-- Categorías con toggle — mismo estilo que botones de animación
local categoriasBottom = { "Despejado", "Nublado", "Atardecer", "Noche", "Tormenta", "Niebla y Humo", "Especiales" }
local CAT_TOTAL = #categoriasBottom * CAT_W + (#categoriasBottom - 1) * CAT_GAP
local prevCatBtn = nil

for i, nombre in ipairs(categoriasBottom) do
    local key = nombre:upper()

    -- Wrapper para el borde de selección
    local wrapper = CreateFrame("Frame", nil, bottomBar, "BackdropTemplate")
    wrapper:SetSize(CAT_W + 4, CAT_H + 4)
    if i == 1 then
        wrapper:SetPoint("LEFT", bottomBar, "CENTER", -(CAT_TOTAL / 2) - 2, 0)
    else
        wrapper:SetPoint("LEFT", prevCatBtn, "RIGHT", CAT_GAP - 4, 0)
    end
    wrapper:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    wrapper:SetBackdropBorderColor(0, 0, 0, 0)

    -- Botón estilo label de animación
    local btn = CreateFrame("Button", nil, wrapper, "BackdropTemplate")
    btn:SetSize(CAT_W, CAT_H)
    btn:SetPoint("CENTER", wrapper, "CENTER", 0, 0)
    btn:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    btn:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
    btn:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("CENTER")
    label:SetTextColor(1, 0.85, 0)
    label:SetText(nombre)

    btn.activo = false

    local function actualizarApariencia()
        if btn.activo then
            wrapper:SetBackdropBorderColor(0.9, 0.75, 0.1, 1)
            btn:SetBackdropColor(0.2, 0.3, 0.55, 0.95)
            btn:SetBackdropBorderColor(0.5, 0.75, 1, 1)
            label:SetTextColor(1, 0.85, 0)
        else
            wrapper:SetBackdropBorderColor(0, 0, 0, 0)
            btn:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
            btn:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
            label:SetTextColor(1, 0.85, 0)
        end
    end

    btn:SetScript("OnEnter", function(self)
        if not self.activo then
            self:SetBackdropColor(0.2, 0.3, 0.55, 0.95)
            self:SetBackdropBorderColor(0.5, 0.75, 1, 1)
        end
    end)
    btn:SetScript("OnLeave", function(self)
        if not self.activo then
            self:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
            self:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
        end
    end)
    btn:SetScript("OnClick", function(self)
        self.activo = not self.activo
        categoriasActivas[key] = self.activo
        actualizarApariencia()
        aplicarFiltros()
    end)

    prevCatBtn = wrapper
end

-- ════════════════════════════════════════════════════════════
-- INICIALIZACIÓN: mostrar primera página al abrir
-- ════════════════════════════════════════════════════════════
skyboxVentana:SetScript("OnShow", function()
    -- Incompatible con la pestaña de weather: al abrir una se cierra la otra
    if GMToolsWeatherFrame and GMToolsWeatherFrame:IsShown() then
        GMToolsWeatherFrame:Hide()
    end
    -- Y también se cierra la ventana de Control de Auras (exclusivas)
    if GMToolsControlAurasFrame then
        GMToolsControlAurasFrame:Hide()
    end
    -- Si hay posición compartida (la otra pestaña se movió), aparece ahí
    if GMToolsWeatherPos then
        local l, b = GMToolsWeatherPos[1], GMToolsWeatherPos[2]
        if l and b then
            skyboxVentana:ClearAllPoints()
            skyboxVentana:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", l, b)
        end
    end
    -- Al reabrir se reaplica el filtro de búsqueda y el del checkbox
    -- dorado (ambos conservan su estado al ocultar la ventana): si no,
    -- el botón seguiría marcado pero la lista saldría completa.
    if not calcularListaActiva(inputBusqueda:GetText()) then
        listaActiva = getSkyboxes()
    end
    mostrarPagina(listaActiva, 1)
    -- Carga completa al abrir: este OnShow se ejecuta DENTRO del click
    -- que muestra la ventana (botón de la barra, botón "Skyboxes" de
    -- control-auras/weather), así que hereda el contexto de usuario y
    -- el .lo de los ids pendientes se puede enviar sin error.
    -- Si la ventana se abre desde un slash (/skybox) la bandera lo
    -- detecta y NO se dispara: el slash no es contexto seguro en este
    -- cliente y enviar desde ahí da el error de addon.
    if not GMTOOLS_EN_SLASH then
        dispararLookups()
    end
    -- Repintado inmediato con el estado recién releído: el id real se
    -- obtiene al momento de UnitAura (10ª posición), así que al abrir
    -- ya se pinta el dorado de TODOS los activos a la vez.
    if GMTOOLS_SKY_REESCAN then GMTOOLS_SKY_REESCAN() end
end)

-- Refresco continuo mientras la ventana esté abierta: cada segundo se
-- releen las auras del grupo y se repintan los bordes dorados. Solo
-- hace operaciones locales (sin envíos), así que no da el error de
-- addon; con esto el dorado se actualiza solo tras APLICAR/QUITAR o
-- cuando otro jugador cambia su skybox, sin tener que reabrir.
local tickRefresco = 0
skyboxVentana:SetScript("OnUpdate", function(self, elapsed)
    if not self:IsShown() then
        tickRefresco = 0
        return
    end
    tickRefresco = tickRefresco + (elapsed or 0)
    if tickRefresco >= 1.0 then
        tickRefresco = 0
        if GMTOOLS_SKY_REESCAN then GMTOOLS_SKY_REESCAN() end
        -- Con el filtro dorado activo, si cambia el conjunto de
        -- skyboxes activas se re-filtra la lista al momento.
        if soloDorados then
            local clave = generarClaveDorados()
            if clave ~= ultimaClaveDorados then
                ultimaClaveDorados = clave
                if calcularListaActiva(inputBusqueda:GetText()) then
                    mostrarPagina(listaActiva, 1)
                end
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════
-- COMANDO DE CHAT
-- ════════════════════════════════════════════════════════════
SLASH_GMTOOLSSKYBOX1 = "/skybox"

SlashCmdList["GMTOOLSSKYBOX"] = function()
    -- El slash no es contexto seguro para enviar el .lo en este
    -- cliente; la bandera hace que el OnShow (que se dispara dentro
    -- de este Show) se salte la carga. La cola se resuelve con los
    -- clicks o con el filtro de chat.
    GMTOOLS_EN_SLASH = true
    if skyboxVentana:IsShown() then
        skyboxVentana:Hide()
    else
        skyboxVentana:Show()
    end
    GMTOOLS_EN_SLASH = false
end

end)

-- ════════════════════════════════════════════════════════════
-- RED DE SEGURIDAD: el OnClick del botón se registra fuera del
-- pcall; si la ventana no se creó, no hace nada.
-- ════════════════════════════════════════════════════════════
if GMToolsBtnSkybox then
    GMToolsBtnSkybox:SetScript("OnClick", function()
        local w = GMToolsSkyboxFrame
        if not w then return end
        if w:IsShown() then
            w:Hide()
        else
            -- El disparo de la cola lo hace el OnShow de la ventana
            -- (se ejecuta dentro de este click: contexto seguro).
            w:Show()
        end
    end)
end
