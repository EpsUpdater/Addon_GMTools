-- ============================================================
-- Tool-Scale.lua
-- Pestaña de escala: copia completa de "How to Scale"
-- (MattScale), ya integrada en GMTools para no depender de ese
-- addon. Textos en español y el mismo estilo de ventana y
-- botones que skyboxes, manteniendo los tamaños y posiciones
-- originales de MattScale (ventana 320x250).
-- El botón nuevo de la barra (a la derecha de andar/volar) la
-- abre/cierra. ── /gmscale (o /escala) hace lo mismo.
-- ============================================================

local ventana = _G["GMToolsFrame"]
local btnVolar = _G["GMToolsBtnDerecha3"]

if not ventana then
    return
end

local ok, err = pcall(function()

-- ════════════════════════════════════════════════════════════
-- HELPER: PANEL OSCURO (mismo estilo que skyboxes)
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
-- DATOS: altura base de cada raza (cm), por sexo. Los Tauren y
-- los Zandalari tienen además la altura de lore (lMale/lFemale).
-- Copiado íntegro de MattScale.
-- ════════════════════════════════════════════════════════════
local ALTURAS_RAZAS = {
    ["Blood Elf"] = { male = 189.4005864, female = 175.8510072 },
    ["Void Elf"] = { male = 189.4005864, female = 175.8510072 },
    ["Draenei"] = { male = 226.3350312, female = 215.025732 },
    ["Lightforged Draenei"] = { male = 226.3350312, female = 215.025732 },
    ["Dwarf"] = { male = 142.481808, female = 137.649204 },
    ["Forsaken"] = { male = 188.7513624, female = 173.0191104 },
    ["Gnome"] = { male = 105.63606, female = 101.1655584 },
    ["Goblin"] = { male = 119.1408336, female = 125.09814966 },
    ["Human"] = { male = 185.0224392, female = 173.9490552 },
    ["Night Elf"] = { male = 221.2994304, female = 206.823564 },
    ["Orc"] = { male = 210.3979536, female = 184.5112896 },
    ["Pandaren"] = { male = 216.5061456, female = 199.4297256 },
    ["Tauren"] = { male = 266.6006352, female = 244.5818832, lMale = 1.144, lFemale = 1.122 },
    ["Highmountain Tauren"] = { male = 266.6006352, female = 244.5818832, lMale = 1.144, lFemale = 1.122 },
    ["Troll"] = { male = 255.3910056, female = 218.1630384 },
    ["Worgen"] = { male = 235.2650616, female = 208.4914296 },
    ["Nightborne"] = { male = 221.2994304, female = 206.823564 },
    ["Kul Tiran"] = { male = 237.3206328, female = 220.8879504 },
    ["Zandalari Troll"] = { male = 254.3696208, female = 250.879356, lMale = 1.198, lFemale = 1.134 },
    ["Mag'har Orc"] = { male = 235.2650616, female = 208.4914296 },
    ["Dark Iron Dwarf"] = { male = 142.481808, female = 137.649204 },
    ["Vulpera"] = { male = 118.6260264, female = 118.3718232 },
    ["Thin Human"] = { male = 172.7557632 },
}

-- Nombres en español para mostrar en los menús (las claves
-- internas siguen siendo las de UnitRace)
local NOMBRES_RAZAS_ES = {
    ["Blood Elf"] = "Elfo de Sangre",
    ["Void Elf"] = "Elfo del Vacío",
    ["Draenei"] = "Draenei",
    ["Lightforged Draenei"] = "Draenei Forjado por la Luz",
    ["Dwarf"] = "Enano",
    ["Forsaken"] = "Renegado",
    ["Gnome"] = "Gnomo",
    ["Goblin"] = "Goblin",
    ["Human"] = "Humano",
    ["Night Elf"] = "Elfo de la Noche",
    ["Orc"] = "Orco",
    ["Pandaren"] = "Pandaren",
    ["Tauren"] = "Tauren",
    ["Highmountain Tauren"] = "Tauren Monte Alto",
    ["Troll"] = "Troll",
    ["Worgen"] = "Huargen",
    ["Nightborne"] = "Nocheterna",
    ["Kul Tiran"] = "Humano de Kul Tiras",
    ["Zandalari Troll"] = "Troll Zandalari",
    ["Mag'har Orc"] = "Orco Mag'har",
    ["Dark Iron Dwarf"] = "Enano Hierro Negro",
    ["Vulpera"] = "Vulpera",
    ["Thin Human"] = "Humano Delgado",
}
local NOMBRES_RAZAS_EN = {}
for en, es in pairs(NOMBRES_RAZAS_ES) do
    NOMBRES_RAZAS_EN[es] = en
end

local NOMBRES_SEXO_ES = { Male = "Hombre", Female = "Mujer" }
local NOMBRES_SEXO_EN = { Hombre = "Male", Mujer = "Female" }
local SEXOS_UNIT = { [2] = "Male", [3] = "Female" }

-- ════════════════════════════════════════════════════════════
-- LÓGICA (copiada de MattScale): limpiar entrada, resolver
-- raza/sexo del jugador, medir una escala y calcular la escala
-- para una altura (todo en centímetros).
-- ════════════════════════════════════════════════════════════

-- Quita letras y espacios; conserva dígitos y puntos
local function sanitizarEntrada(texto)
    if type(texto) == "number" then
        return texto
    end
    return (texto:gsub("[^%d*%.?%'%d*%\"]", ""):gsub("/", ""))
end

-- Resuelve la raza: si se le pasa "Raza"/nil usa la del jugador;
-- si viene el nombre en español devuelve la clave interna.
local function ponerRaza(raza)
    if raza == "Raza" or raza == nil or raza == "" then
        local _, razaEN = UnitRace("player")
        if not razaEN then
            razaEN = "Human"
        end
        if razaEN == "Undead" then
            razaEN = "Forsaken"
        end
        if razaEN == "ThinHuman" then
            razaEN = "Thin Human"
        end
        return razaEN
    end
    return NOMBRES_RAZAS_EN[raza] or raza
end

-- Igual para el sexo: "Sexo"/nil → el del jugador; español → clave.
local function ponerSexo(sexo)
    if sexo == "Sexo" or sexo == nil or sexo == "" then
        return SEXOS_UNIT[UnitSex("player")] or "Male"
    end
    return NOMBRES_SEXO_EN[sexo] or sexo
end

local function infoRaza(raza)
    return ALTURAS_RAZAS[raza] or ALTURAS_RAZAS["Human"]
end

-- Devuelve la escala (texto) y el resultado en centímetros
local function medirEscala(escala, raza, sexo)
    escala = sanitizarEntrada(escala)
    raza = ponerRaza(raza)
    sexo = ponerSexo(sexo):lower()
    local alturaBase = infoRaza(raza)[sexo]
    local metrico = escala * alturaBase
    return string.format("%0.6f", escala), string.format("%0.3f", metrico)
end

-- Calcula la escala necesaria para una altura dada en centímetros
local function calcularEscala(entrada, raza, sexo)
    entrada = sanitizarEntrada(entrada)
    raza = ponerRaza(raza)
    sexo = ponerSexo(sexo):lower()
    if entrada == "" or entrada == nil then
        return "1"
    end
    local alturaBase = infoRaza(raza)[sexo]
    return entrada / alturaBase
end

-- ════════════════════════════════════════════════════════════
-- VENTANA (tamaño original de MattScale: 320x250, estilo de
-- skyboxes). Comparte la posición guardada con skyboxes/weather.
-- ════════════════════════════════════════════════════════════
local escalaVentana = CreateFrame("Frame", "GMToolsScaleFrame", UIParent, "BackdropTemplate")
escalaVentana:SetSize(320, 200)
escalaVentana:SetPoint("BOTTOM", ventana, "TOP", 0, 8)
ApplyDarkPanel(escalaVentana)
escalaVentana:EnableMouse(true)
escalaVentana:SetMovable(true)
escalaVentana:RegisterForDrag("LeftButton")
escalaVentana:SetScript("OnDragStart", escalaVentana.StartMoving)
escalaVentana:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Guarda la posición compartida con skyboxes/weather
    local l, b = self:GetLeft(), self:GetBottom()
    if l and b then
        GMToolsWeatherPos = { math.floor(l), math.floor(b) }
    end
end)
escalaVentana:Hide()

escalaVentana:SetScript("OnShow", function()
    -- Incompatible con las demás pestañas: al abrir esta se cierran
    if GMToolsSkyboxFrame and GMToolsSkyboxFrame:IsShown() then
        GMToolsSkyboxFrame:Hide()
    end
    if GMToolsWeatherFrame and GMToolsWeatherFrame:IsShown() then
        GMToolsWeatherFrame:Hide()
    end
    if GMToolsControlAurasFrame then
        GMToolsControlAurasFrame:Hide()
    end
    -- Si hay posición compartida (otra pestaña se movió), aparece ahí
    if GMToolsWeatherPos then
        local l, b = GMToolsWeatherPos[1], GMToolsWeatherPos[2]
        if l and b then
            escalaVentana:ClearAllPoints()
            escalaVentana:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", l, b)
        end
    end
end)

-- Y a la inversa: si se abre skyboxes o weather, se cierra esta
local skyboxVentana = _G["GMToolsSkyboxFrame"]
if skyboxVentana then
    skyboxVentana:HookScript("OnShow", function() escalaVentana:Hide() end)
end
local weatherVentana = _G["GMToolsWeatherFrame"]
if weatherVentana then
    weatherVentana:HookScript("OnShow", function() escalaVentana:Hide() end)
end

-- Título
local titulo = escalaVentana:CreateFontString(nil, "OVERLAY")
titulo:SetFont("Fonts\\FRIZQT__.TTF", 14)
titulo:SetPoint("TOP", escalaVentana, "TOP", 0, -12)
titulo:SetTextColor(1, 0.85, 0)
titulo:SetText("ESCALA")

-- Botón de cierre (X)
local closeButton = CreateFrame("Button", nil, escalaVentana)
closeButton:SetSize(26, 26)
closeButton:SetPoint("TOPRIGHT", escalaVentana, "TOPRIGHT", -8, -8)
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
closeButton:SetScript("OnClick", function() escalaVentana:Hide() end)

-- ════════════════════════════════════════════════════════════
-- MENÚS DE RAZA Y SEXO (posiciones originales de MattScale,
-- con el mismo estilo de los botones del panel de invis)
-- ════════════════════════════════════════════════════════════
local function estilizarDesplegable(dd)
    -- Quitar el acabado de plata por defecto del template
    dd:SetBackdrop(nil)
    for _, k in ipairs({ "Left", "Middle", "Right" }) do
        local t = dd[k]
        if t and t.Hide then t:Hide() end
    end

    -- Fondo y borde iguales que la ventana principal de escala
    dd:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    dd:SetBackdropColor(0.12, 0.18, 0.38, 0.82)
    dd:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    dd:EnableMouse(true)

    -- El texto del template queda oculto; se pinta uno propio.
    -- El botón interno (el que recibe los clics) cubre el cuadro.
    if dd.Text then dd.Text:Hide() end
    if dd.Button then
        dd.Button:ClearAllPoints()
        dd.Button:SetPoint("TOPLEFT", dd, "TOPLEFT", 0, 0)
        dd.Button:SetPoint("BOTTOMRIGHT", dd, "BOTTOMRIGHT", 0, 0)
        if dd.Button.Text then dd.Button.Text:Hide() end
        -- Flecha hacia abajo: 5 px más a la izquierda
        if dd.Button.NormalTexture then
            dd.Button.NormalTexture:ClearAllPoints()
            dd.Button.NormalTexture:SetPoint("RIGHT", dd.Button, "RIGHT", -5, 0)
        end
        -- Su iluminación (la que cae sobre la flecha) sigue a la flecha
        if dd.Button.HighlightTexture then
            dd.Button.HighlightTexture:ClearAllPoints()
            dd.Button.HighlightTexture:SetPoint("RIGHT", dd.Button, "RIGHT", -5, 0)
        end
    end

    local label = dd:CreateFontString(nil, "OVERLAY")
    label:SetFont("Fonts\\FRIZQT__.TTF", 12)
    label:SetPoint("LEFT", dd, "LEFT", 8, 0)
    label:SetTextColor(1, 1, 1)
    dd.miLabel = label

    -- Hover igual que los botones del addon
    dd:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.2, 0.3, 0.55, 0.95)
        self:SetBackdropBorderColor(0.5, 0.75, 1, 1)
    end)
    dd:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.12, 0.18, 0.38, 0.82)
        self:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    end)
end

-- Recorta un texto a 12 caracteres y añade "..." si es más largo
local function recortarTexto(texto, max)
    texto = tostring(texto or "")
    if #texto > max then
        return texto:sub(1, max) .. "..."
    end
    return texto
end

-- Pone el texto del desplegable (estado interno del template +
-- el texto propio visible). El texto interno siempre queda completo
-- (la lógica lo usa para saber la raza); solo se recorta lo que se
-- ve si el desplegable tiene RECORTAR.
local function setearTextoDD(dd, texto)
    UIDropDownMenu_SetText(dd, texto)
    if dd.miLabel then
        if dd.RECORTAR then
            dd.miLabel:SetText(recortarTexto(texto, 12))
        else
            dd.miLabel:SetText(texto)
        end
    end
end

-- ════════════════════════════════════════════════════════════
-- POPUP DE LOS MENÚS (la lista que se despliega): mismo estilo
-- de ventana que la principal (fondo azul oscuro y borde claro).
-- Se aplica al añadir cada fila (hook de UIDropDownMenu_AddButton)
-- y en cada apertura; las filas se reutilizan entre aperturas,
-- así que basta con quitarles las texturas plateadas una vez.
-- ════════════════════════════════════════════════════════════

local listaPopup

-- La lista se localiza por el nombre global o, si no está, por el
-- padre del primer botón (los botones siempre se nombran solos).
local function obtenerListaPopup()
    local lista = _G["DropDownList1"]
    if lista and lista.GetFrameType then return lista end
    for i = 1, 40 do
        local btn = _G["DropDownList1Button" .. i]
        if not btn then break end
        if btn:GetParent() then return btn:GetParent() end
    end
    return nil
end

-- Si el cliente no permite SetBackdrop en esta ventana, se pintan
-- el fondo y el borde con texturas propias (mismo aspecto).
local function ponerFondoManual(lista)
    if lista.miFondo then return end

    local fondo = lista:CreateTexture(nil, "BACKGROUND")
    fondo:SetAllPoints(lista)
    fondo:SetTexture("Interface\\Buttons\\WHITE8X8")
    fondo:SetVertexColor(0.12, 0.18, 0.38, 0.82)
    lista.miFondo = fondo

    local borde = {}
    local function tira()
        local t = lista:CreateTexture(nil, "BORDER")
        t:SetTexture("Interface\\Buttons\\WHITE8X8")
        t:SetVertexColor(0.3, 0.5, 0.8, 0.9)
        borde[#borde + 1] = t
        return t
    end

    local sup = tira()
    sup:SetPoint("TOPLEFT", lista, "TOPLEFT", -4, 0)
    sup:SetPoint("TOPRIGHT", lista, "TOPRIGHT", 4, 0)
    sup:SetHeight(3)

    local inf = tira()
    inf:SetPoint("BOTTOMLEFT", lista, "BOTTOMLEFT", -4, 0)
    inf:SetPoint("BOTTOMRIGHT", lista, "BOTTOMRIGHT", 4, 0)
    inf:SetHeight(3)

    local izq = tira()
    izq:SetPoint("TOPLEFT", lista, "TOPLEFT", -4, 0)
    izq:SetPoint("BOTTOMLEFT", lista, "BOTTOMLEFT", -4, 0)
    izq:SetWidth(3)

    local der = tira()
    der:SetPoint("TOPRIGHT", lista, "TOPRIGHT", 4, 0)
    der:SetPoint("BOTTOMRIGHT", lista, "BOTTOMRIGHT", 4, 0)
    der:SetWidth(3)

    lista.miBorde = borde
end

local function estilizarListaPopup(lista)
    -- Carenado plateado clásico de la propia lista
    for _, k in ipairs({ "Left", "Middle", "Right" }) do
        local t = lista:GetNamedChild(k)
        if t and t.Hide then t:Hide() end
    end

    local ok = pcall(function()
        lista:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        lista:SetBackdropColor(0.12, 0.18, 0.38, 0.82)
        lista:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    end)
    if not ok then ponerFondoManual(lista) end

    -- Filas: quitar las texturas plateadas y pintar el highlight
    for _, btn in ipairs({ lista:GetChildren() }) do
        if btn and btn.GetObjectType and btn:GetObjectType() == "Button" then
            if btn.Left then btn.Left:Hide() end
            if btn.Middle then btn.Middle:Hide() end
            if btn.Right then btn.Right:Hide() end
            if btn.Highlight then
                btn.Highlight:SetTexture("Interface\\Buttons\\WHITE8X8")
                btn.Highlight:SetVertexColor(0.2, 0.3, 0.55, 0.6)
            end
        end
    end

    -- Reforzar: también se reestila al mostrarse la lista
    if not lista.OnShowHookeado then
        lista:HookScript("OnShow", estilizarPopupMenus)
        lista.OnShowHookeado = true
    end
end

-- Imprime una sola vez qué ventana es la lista del desplegable y
-- qué se pudo aplicar (para verificar en el juego)
local function estilizarPopupMenus()
    local menu = UIDROPDOWNMENU_OPEN_MENU
    -- El botón de sexo no abre desplegable: se cierra al instante
    if menu == _G["GMToolsScaleSexoMenu"] then
        HideDropDownMenus(1)
        return
    end
    if menu ~= _G["GMToolsScaleRazaMenu"] then
        return
    end
    local lista = listaPopup or obtenerListaPopup()
    if not lista then return end
    listaPopup = lista
    estilizarListaPopup(lista)
end

local hookAddButtonOK = pcall(function()
    hooksecurefunc("UIDropDownMenu_AddButton", estilizarPopupMenus)
end)
-- Segundo punto de enganche: al abrirse el menú, la lista ya está
-- poblada; el estilado se repite cada vez que se abre.
pcall(function()
    hooksecurefunc("ToggleDropDownMenu", estilizarPopupMenus)
end)

-- Declarada aquí (antes que los menús): los desplegables la usan en
-- sus clics y se define más abajo, tras todos los elementos que usa
local aplicarEnterAltura

local razaInfo = CreateFrame("Frame", "GMToolsScaleRazaMenu", escalaVentana, "UIDropDownMenuTemplate, BackdropTemplate")
razaInfo:SetPoint("TOPLEFT", escalaVentana, "TOPLEFT", 18, -40)
razaInfo:SetSize(85, 24)
estilizarDesplegable(razaInfo)
razaInfo.RECORTAR = true
UIDropDownMenu_SetWidth(razaInfo, 85)
setearTextoDD(razaInfo, "Raza")

razaInfo.initialize = function(self, level)
    local info = UIDropDownMenu_CreateInfo()
    local orden = {}
    for k in pairs(ALTURAS_RAZAS) do
        orden[#orden + 1] = k
    end
    table.sort(orden)
    for _, razaEN in ipairs(orden) do
        local texto = NOMBRES_RAZAS_ES[razaEN] or razaEN
        info.text = texto
        info.value = razaEN
        info.func = function(item)
            pcall(function()
                UIDropDownMenu_SetSelectedID(self, item:GetID())
            end)
            setearTextoDD(razaInfo, texto)
            aplicarEnterAltura()
        end
        info.checked = false
        UIDropDownMenu_AddButton(info)
    end
end
UIDropDownMenu_Initialize(razaInfo, razaInfo.initialize)

local sexoInfo = CreateFrame("Frame", "GMToolsScaleSexoMenu", escalaVentana, "UIDropDownMenuTemplate, BackdropTemplate")
sexoInfo:SetPoint("TOPLEFT", escalaVentana, "TOPLEFT", 165, -40)
sexoInfo:SetSize(85, 24)
estilizarDesplegable(sexoInfo)
-- El botón derecho no abre desplegable: solo cambia su flecha hacia
-- abajo por una a la derecha (mismo tamaño y posición), y al hacer
-- clic alterna directamente Mujer/Hombre
if sexoInfo.Button and sexoInfo.Button.NormalTexture then
    sexoInfo.Button.NormalTexture:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
end
local function alternarSexo()
    local texto = UIDropDownMenu_GetText(sexoInfo)
    local nuevo = (texto == "Mujer") and "Male" or "Female"
    local nuevoTexto = NOMBRES_SEXO_ES[nuevo] or nuevo
    setearTextoDD(sexoInfo, nuevoTexto)
    aplicarEnterAltura()
    PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
end
sexoInfo.Button:SetScript("OnClick", alternarSexo)
sexoInfo.Button:SetScript("OnMouseDown", nil)
sexoInfo.Button:SetScript("OnMouseUp", nil)
pcall(function() sexoInfo:SetScript("OnClick", alternarSexo) end)
pcall(function() sexoInfo:SetScript("OnMouseDown", nil) end)
pcall(function() sexoInfo:SetScript("OnMouseUp", nil) end)
UIDropDownMenu_SetWidth(sexoInfo, 85)
setearTextoDD(sexoInfo, "Sexo")

sexoInfo.list = { "Male", "Female" }
sexoInfo.initialize = function(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for _, sexoEN in ipairs(sexoInfo.list) do
        local texto = NOMBRES_SEXO_ES[sexoEN] or sexoEN
        info.text = texto
        info.func = function(item)
            pcall(function()
                UIDropDownMenu_SetSelectedID(self, item:GetID())
            end)
            setearTextoDD(sexoInfo, texto)
            aplicarEnterAltura()
        end
        info.checked = false
        UIDropDownMenu_AddButton(info)
    end
end
UIDropDownMenu_Initialize(sexoInfo, sexoInfo.initialize)

-- ════════════════════════════════════════════════════════════
-- CAMPOS DE TEXTO: ALTURA y ESCALA (posiciones originales)
-- ════════════════════════════════════════════════════════════
local alturaLabel = escalaVentana:CreateFontString(nil, "OVERLAY", "GameFontNormal")
alturaLabel:SetPoint("TOPLEFT", escalaVentana, "TOPLEFT", 20, -83)
alturaLabel:SetText("Altura: ")

local alturaBox = CreateFrame("EditBox", "GMToolsScaleAlturaInput", escalaVentana, "InputBoxTemplate")
alturaBox:SetPoint("TOPLEFT", escalaVentana, "TOPLEFT", 75, -80)
alturaBox:SetFontObject(GameFontHighlight)
alturaBox:SetSize(150, 20)
alturaBox:SetAutoFocus(false)
alturaBox:SetMultiLine(false)
alturaBox:SetMaxLetters(8)

-- Texto amarillo "centímetros" a la derecha de la casilla de altura
local cmLabel = escalaVentana:CreateFontString(nil, "OVERLAY")
cmLabel:SetFont("Fonts\\FRIZQT__.TTF", 12)
cmLabel:SetPoint("LEFT", alturaBox, "RIGHT", 4, 0)
cmLabel:SetTextColor(1, 0.85, 0)
cmLabel:SetText("centímetros")

local escalaLabel = escalaVentana:CreateFontString(nil, "OVERLAY", "GameFontNormal")
escalaLabel:SetPoint("TOPLEFT", escalaVentana, "TOPLEFT", 20, -103)
escalaLabel:SetText("Escala: ")

local escalaBox = CreateFrame("EditBox", "GMToolsScaleEscalaInput", escalaVentana, "InputBoxTemplate")
escalaBox:SetPoint("TOPLEFT", escalaVentana, "TOPLEFT", 75, -100)
escalaBox:SetFontObject(GameFontHighlight)
escalaBox:SetSize(150, 20)
escalaBox:SetAutoFocus(false)
escalaBox:SetMultiLine(false)
escalaBox:SetMaxLetters(8)

-- ════════════════════════════════════════════════════════════
-- LÍNEAS DE RESULTADO (posiciones originales)
-- ════════════════════════════════════════════════════════════
local escalaDisplay = escalaVentana:CreateFontString(nil, "OVERLAY", "GameFontNormal")
escalaDisplay:SetPoint("TOPLEFT", escalaVentana, "TOPLEFT", 20, -130)
escalaDisplay:SetText("Escala |cff00ccff1.000|r de la raza")

local customDisplay = escalaVentana:CreateFontString(nil, "OVERLAY", "GameFontNormal")
customDisplay:SetPoint("TOPLEFT", escalaVentana, "TOPLEFT", 25, -155)
customDisplay:SetText("Escala |cff00ccff???|r = |cff00ccff???|r cm")
customDisplay:Hide()

-- ════════════════════════════════════════════════════════════
-- BOTONES (estilo de skyboxes, tamaño original 80x35):
-- APLICAR (envía .mod scale) y COMPARTIR.
-- ════════════════════════════════════════════════════════════
local function crearBotonEscala(texto, xOffset)
    local btn = CreateFrame("Button", nil, escalaVentana, "BackdropTemplate")
    btn:SetSize(90, 35)
    btn:SetPoint("CENTER", escalaVentana, "CENTER", xOffset, -70)
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

-- ════════════════════════════════════════════════════════════
-- ACTUALIZAR RESULTADOS según los menús (con altura de lore
-- para Tauren y Zandalari)
-- ════════════════════════════════════════════════════════════
-- Igual que pulsar Enter en la casilla de altura: recalcula la escala,
-- pinta la línea de la raza y el resultado. Si la casilla de altura
-- está vacía, la escala pasa a 1 y la casilla de altura se rellena con
-- los centímetros de esa raza. Se usa al pulsar Enter en altura y
-- también al cambiar de raza o de género en los desplegables.
function aplicarEnterAltura()
    local raza = ponerRaza(UIDropDownMenu_GetText(razaInfo))
    local sexo = ponerSexo(UIDropDownMenu_GetText(sexoInfo))
    local alturaEscrita = alturaBox:GetText()
    if alturaEscrita == nil or alturaEscrita == "" then
        escalaBox:SetText("1")
        local escala, metrico = medirEscala("1", raza, sexo)
        alturaBox:SetText(metrico)
        escalaDisplay:SetText("Escala |cff00ccff" .. escala .. "|r de la raza = |cff00ccff" .. metrico .. " cm|r")
    else
        escalaBox:SetText(calcularEscala(alturaEscrita, raza, sexo))
        local escala, metrico = medirEscala("1", raza, sexo)
        escalaDisplay:SetText("Escala |cff00ccff" .. escala .. "|r de la raza = |cff00ccff" .. metrico .. " cm|r")
    end
    local escala, metrico = medirEscala(escalaBox:GetText(), raza, sexo)
    customDisplay:SetText("Escala |cff00ccff" .. escala .. "|r = |cff00ccff" .. metrico .. " cm|r")
    setearTextoDD(razaInfo, NOMBRES_RAZAS_ES[raza] or raza)
    setearTextoDD(sexoInfo, NOMBRES_SEXO_ES[sexo] or sexo)
end

-- Altura → escala (Enter en el campo de altura)
alturaBox:SetScript("OnEnterPressed", function(self)
    aplicarEnterAltura()
end)

-- Escala → altura (Enter en el campo de escala)
escalaBox:SetScript("OnEnterPressed", function(self)
    if escalaBox:GetText():match("%a") then
        print("GMTools | Escala | Solo números.")
        escalaBox:SetText("")
    else
        local raza = ponerRaza(UIDropDownMenu_GetText(razaInfo))
        local sexo = ponerSexo(UIDropDownMenu_GetText(sexoInfo))
        local n = tonumber(escalaBox:GetText())
        if n and n > 0 and n < 10 then
            local escala, metrico = medirEscala(escalaBox:GetText(), raza, sexo)
            customDisplay:SetText("Escala |cff00ccff" .. escala .. "|r = |cff00ccff" .. metrico .. " cm|r")
            alturaBox:SetText(metrico)
        end
    end
end)

-- Botón APLICAR: envía el .mod scale al chat
local btnEscalar = crearBotonEscala("Aplicar", -100)
btnEscalar:SetScript("OnClick", function()
    local texto = escalaBox:GetText()
    if texto == nil or texto == "" then
        return
    end
    local n = tonumber(texto)
    if n and n > 0 and n < 10 then
        local raza = ponerRaza(UIDropDownMenu_GetText(razaInfo))
        local sexo = ponerSexo(UIDropDownMenu_GetText(sexoInfo))
        if escalaBox:GetText() == "" then
            escalaBox:SetText(calcularEscala(alturaBox:GetText(), raza, sexo))
        end
        local escala, metrico = medirEscala(escalaBox:GetText(), raza, sexo)
        customDisplay:SetText("Escala |cff00ccff" .. escala .. "|r = |cff00ccff" .. metrico .. " cm|r")
        SendChatMessage(".mod scale " .. escala, "GUILD")
    end
end)

-- Botón COMPARTIR: deja la información en el chat para enviarla
local btnCompartir = crearBotonEscala("Compartir", -1)
btnCompartir:SetScript("OnClick", function()
    local raza = ponerRaza(UIDropDownMenu_GetText(razaInfo))
    local sexo = ponerSexo(UIDropDownMenu_GetText(sexoInfo))
    local escala = calcularEscala(alturaBox:GetText(), raza, sexo)
    local e, m = medirEscala(escala, raza, sexo)
    ChatFrame1EditBox:SetFocus()
    ChatFrame1EditBox:SetText("Escala " .. e .. " para " .. (NOMBRES_RAZAS_ES[raza] or raza) .. " " .. (NOMBRES_SEXO_ES[sexo] or sexo) .. " = " .. m .. " cm")
    ChatFrame1EditBox:HighlightText()
end)

-- Botón NPC: igual que APLICAR, pero envía el .npc scale al chat;
-- con el botón derecho envía el .ph forge npc scale
local btnNPC = crearBotonEscala("NPC", 98)
btnNPC:RegisterForClicks("LeftButtonUp", "RightButtonUp")
btnNPC:SetScript("OnClick", function(self, boton)
    local texto = escalaBox:GetText()
    if texto == nil or texto == "" then
        return
    end
    local n = tonumber(texto)
    if n and n > 0 and n < 10 then
        local raza = ponerRaza(UIDropDownMenu_GetText(razaInfo))
        local sexo = ponerSexo(UIDropDownMenu_GetText(sexoInfo))
        if escalaBox:GetText() == "" then
            escalaBox:SetText(calcularEscala(alturaBox:GetText(), raza, sexo))
        end
        local escala, metrico = medirEscala(escalaBox:GetText(), raza, sexo)
        customDisplay:SetText("Escala |cff00ccff" .. escala .. "|r = |cff00ccff" .. metrico .. " cm|r")
        if boton == "RightButton" then
            SendChatMessage(".ph forge npc scale " .. escala, "GUILD")
        else
            SendChatMessage(".npc scale " .. escala, "GUILD")
        end
    end
end)
-- Texto informativo al pasar el ratón por encima (tooltip propio:
-- las dos líneas usan exactamente la misma fuente y tamaño)
local tipNPC = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
tipNPC:SetFrameStrata("TOOLTIP")
tipNPC:SetFrameLevel(100)
tipNPC:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
tipNPC:SetBackdropColor(0.12, 0.18, 0.38, 0.85)
tipNPC:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
tipNPC:Hide()

local tipNPCIzq = tipNPC:CreateFontString(nil, "OVERLAY")
tipNPCIzq:SetFont("Fonts\\FRIZQT__.TTF", 12)
tipNPCIzq:SetPoint("TOPLEFT", tipNPC, "TOPLEFT", 8, -5)
tipNPCIzq:SetTextColor(1, 1, 1)
tipNPCIzq:SetText("|cffd9d900Click izquierdo: |cff00ccff.npc scale")

local tipNPCDer = tipNPC:CreateFontString(nil, "OVERLAY")
tipNPCDer:SetFont("Fonts\\FRIZQT__.TTF", 12)
tipNPCDer:SetPoint("TOPLEFT", tipNPCIzq, "BOTTOMLEFT", 0, -2)
tipNPCDer:SetTextColor(1, 1, 1)
tipNPCDer:SetText("|cffd9d900Click derecho: |cff00ccff.ph forge npc scale")

tipNPC:SetScript("OnShow", function()
    tipNPC:SetWidth(math.max(tipNPCIzq:GetStringWidth(), tipNPCDer:GetStringWidth()) + 16)
    tipNPC:SetHeight(tipNPCIzq:GetStringHeight() + tipNPCDer:GetStringHeight() + 10)
end)

btnNPC:HookScript("OnEnter", function()
    tipNPC:ClearAllPoints()
    tipNPC:SetPoint("LEFT", btnNPC, "RIGHT", 5, 0)
    tipNPC:Show()
end)
btnNPC:HookScript("OnLeave", function()
    tipNPC:Hide()
end)


-- ════════════════════════════════════════════════════════════
-- VALORES POR DEFECTO AL CARGAR: la raza y el sexo del jugador
-- ════════════════════════════════════════════════════════════
local raza = ponerRaza(nil)
local sexo = ponerSexo(nil)
setearTextoDD(razaInfo, NOMBRES_RAZAS_ES[raza] or raza)
setearTextoDD(sexoInfo, NOMBRES_SEXO_ES[sexo] or sexo)
local escala, metrico = medirEscala("1", raza, sexo)
escalaDisplay:SetText("Escala |cff00ccff" .. escala .. "|r de la raza = |cff00ccff" .. metrico .. " cm|r")

-- ════════════════════════════════════════════════════════════
-- BOTÓN EN LA BARRA PRINCIPAL — a la derecha del de andar/volar
-- ════════════════════════════════════════════════════════════
local btnEscala = CreateFrame("Button", nil, ventana)
btnEscala:SetSize(20, 20)
if btnVolar then
    btnEscala:SetPoint("LEFT", btnVolar, "RIGHT", -150, 23)
else
    btnEscala:SetPoint("LEFT", ventana, "LEFT", 402, 0)
end

local iconEscala = btnEscala:CreateTexture(nil, "BACKGROUND")
iconEscala:SetSize(19, 19)
iconEscala:SetPoint("CENTER")
iconEscala:SetTexture("Interface\\Icons\\eps_arc_xtraarrowup")

local glowEscalaOk = pcall(function()
    btnEscala:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
end)
local glowEscala
if glowEscalaOk then
    glowEscala = btnEscala:GetHighlightTexture()
    glowEscala:ClearAllPoints()
    glowEscala:SetPoint("CENTER")
    glowEscala:SetVertexColor(0.6, 0.8, 1)
    glowEscala:SetSize(20 * 1.2, 20 * 1.2)
    glowEscala:SetAlpha(0.5)
end

GMToolsBtnScale = btnEscala

-- Solo se muestra en modo ESCALA: al estar en VELOCIDAD se oculta.
-- El modo lo alterna el botón de flecha de la barra (Tool-Gobs.lua).
local function actualizarBotonBarra()
    if GMToolsModoActual and GMToolsModoActual() == "escala" then
        btnEscala:Show()
    else
        btnEscala:Hide()
    end
end
actualizarBotonBarra()
if GMToolsBtnFlecha then
    GMToolsBtnFlecha:HookScript("OnClick", actualizarBotonBarra)
end

-- Texto al pasar el ratón por encima: "Abrir el panel de escalas."
-- en dorado, hacia la derecha del botón
local tipEscalaBarra = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
tipEscalaBarra:SetFrameStrata("TOOLTIP")
tipEscalaBarra:SetFrameLevel(100)
tipEscalaBarra:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
tipEscalaBarra:SetBackdropColor(0.12, 0.18, 0.38, 0.85)
tipEscalaBarra:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
tipEscalaBarra:Hide()

local tipEscalaTxt = tipEscalaBarra:CreateFontString(nil, "OVERLAY")
tipEscalaTxt:SetFont("Fonts\\FRIZQT__.TTF", 12)
tipEscalaTxt:SetPoint("TOPLEFT", tipEscalaBarra, "TOPLEFT", 8, -5)
tipEscalaTxt:SetTextColor(1, 0.85, 0)
tipEscalaTxt:SetText("Abrir el panel de escalas.")

tipEscalaBarra:SetScript("OnShow", function()
    tipEscalaBarra:SetWidth(tipEscalaTxt:GetStringWidth() + 16)
    tipEscalaBarra:SetHeight(tipEscalaTxt:GetStringHeight() + 10)
end)

btnEscala:SetScript("OnEnter", function()
    tipEscalaBarra:ClearAllPoints()
    tipEscalaBarra:SetPoint("LEFT", btnEscala, "RIGHT", 5, 0)
    tipEscalaBarra:Show()
end)
btnEscala:SetScript("OnLeave", function()
    tipEscalaBarra:Hide()
end)


end)

-- ════════════════════════════════════════════════════════════
-- RED DE SEGURIDAD: el OnClick del botón se registra fuera del
-- pcall; si la ventana no se creó, no hace nada.
-- ════════════════════════════════════════════════════════════
if GMToolsBtnScale then
    GMToolsBtnScale:SetScript("OnClick", function()
        local w = GMToolsScaleFrame
        if not w then return end
        if w:IsShown() then
            w:Hide()
        else
            w:Show()
        end
    end)
end
