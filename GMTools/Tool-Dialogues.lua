-- ============================================================
-- Tool-Dialogues.lua
-- Pestaña de diálogos organizados por EVENTOS (categorías).
-- Cada evento se guarda como sección del documento
-- GMToolsDialoguesDB.lua (WTF\...\SavedVariables).
-- Diseño igual al resto del addon: bordes UI-Tooltip-Border
-- edgeSize 12, botones 44x22/37x37, fuentes normales
-- (diálogos ×0.5, botones y títulos ×0.6).
-- Extensible sin tocar GMTools.lua.
-- ============================================================

-- ── Tamaño de letra: categorías y escala global (ajustable)
local FUENTE_DIALOGO = 0.5
local FUENTE_BOTON   = 0.6

GMToolsDialoguesFontScale = GMToolsDialoguesFontScale or 0.8

local fuentes = {}
local function registrarFuente(fs, base, cat)
    fuentes[#fuentes + 1] = { fs = fs, base = base, cat = cat }
    fs:SetFont("Fonts\\FRIZQT__.TTF", base * cat * GMToolsDialoguesFontScale)
end

local function aplicarFuentes()
    for _, e in ipairs(fuentes) do
        e.fs:SetFont("Fonts\\FRIZQT__.TTF", e.base * e.cat * GMToolsDialoguesFontScale)
    end
end

function GMToolsDialoguesSetFontScale(s)
    GMToolsDialoguesFontScale = s
    aplicarFuentes()
end

-- ── Base de datos (documento aparte, array ordenado por categoría)
local function ordenarEventos(db)
    table.sort(db.eventos, function(a, b)
        return string.lower(a.nombre) < string.lower(b.nombre)
    end)
end

local function buscarEvento(db, nombre)
    for _, ev in ipairs(db.eventos) do
        if ev.nombre == nombre then
            return ev
        end
    end
    return nil
end

local function getDB()
    if not GMToolsDialoguesDB then
        GMToolsDialoguesDB = {}
    end
    local db = GMToolsDialoguesDB
    if type(db.eventos) ~= "table" then
        db.eventos = {}
    end
    local primerValor = next(db.eventos)
    if primerValor ~= nil and type(primerValor) == "string" then
        local nuevo = {}
        for nombre, ev in pairs(db.eventos) do
            table.insert(nuevo, { nombre = nombre, dialogos = (ev and ev.dialogos) or {} })
        end
        db.eventos = nuevo
    end
    ordenarEventos(db)
    return db
end

local botonOrigen = GMToolsDialoguesBtn
local parent = GMToolsFrame

-- ── Diseño estándar del addon (igual que la ventana principal:
-- misma transparencia, colores y alfa)
local function panel(f)
    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f:SetBackdropColor(0.12, 0.18, 0.40, 0.45)
    f:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    f:EnableMouse(true)
end

local function bordeBoton(b, r, g, bl, a)
    b:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    b:SetBackdropColor(r, g, bl, a)
    b:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
end

local frame = CreateFrame("Frame", "ToolDialoguesFrame", parent or UIParent, "BackdropTemplate")
frame:SetSize(880, 650)
panel(frame)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop",  frame.StopMovingOrSizing)
frame:Hide()

local izq = GMToolsFrame
if izq then
    frame:SetPoint("BOTTOM", izq, "TOP", 0, 5)
elseif botonOrigen then
    frame:SetPoint("BOTTOM", botonOrigen, "TOP", 0, 4)
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
registrarFuente(closeX, 26, FUENTE_BOTON)
closeX:SetText("×")
closeX:SetTextColor(0.85, 0.3, 0.3)
closeButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
closeButton:SetScript("OnEnter", function() closeBg:Show() closeX:SetTextColor(1, 0.5, 0.5) end)
closeButton:SetScript("OnLeave", function() closeBg:Hide() closeX:SetTextColor(0.85, 0.3, 0.3) end)
closeButton:SetScript("OnClick", function() frame:Hide() end)

-- ── Botones AÑADIR y BORRAR (arriba a la derecha)
local function botonTexto(parent, texto, ancho, alto, tamFuente)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(ancho, alto)
    bordeBoton(b, 0.1, 0.11, 0.15, 0.9)
    local label = b:CreateFontString(nil, "OVERLAY")
    label:SetPoint("CENTER")
    registrarFuente(label, tamFuente or 24, FUENTE_BOTON)
    label:SetTextColor(1, 1, 1)
    label:SetText(texto)
    return b
end

local btnAnadir = botonTexto(frame, "CREAR NUEVO", 96, 22)
GMToolsBtnAnadir = btnAnadir

local btnBorrar = botonTexto(frame, "BORRAR", 60, 22)

-- ── DESPLEGABLE DE EVENTOS (arriba a la izquierda)
local btnEvento = CreateFrame("Button", nil, frame, "BackdropTemplate")
btnEvento:SetSize(260, 30)
btnEvento:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -8)
bordeBoton(btnEvento, 0.1, 0.11, 0.15, 0.9)

local lblEvento = btnEvento:CreateFontString(nil, "OVERLAY")
lblEvento:SetPoint("LEFT", btnEvento, "LEFT", 10, 0)
registrarFuente(lblEvento, 26, FUENTE_BOTON)
lblEvento:SetText("Seleccionar Evento")
lblEvento:SetTextColor(0.7, 0.7, 0.7)

local flecha = btnEvento:CreateTexture(nil, "OVERLAY")
flecha:SetSize(18, 18)
flecha:SetPoint("RIGHT", btnEvento, "RIGHT", -10, 0)
flecha:SetTexture("Interface\\Icons\\eps_arc_xtraarrowdown")

local popup = CreateFrame("Frame", "GMToolsDialogosPopup", frame, "BackdropTemplate")
popup:SetWidth(260)
popup:SetPoint("TOPLEFT", btnEvento, "BOTTOMLEFT", 1, -6)
panel(popup)
popup:SetBackdropColor(0.12, 0.18, 0.30, 0.93)
popup:SetFrameLevel(frame:GetFrameLevel() + 10)
popup:Hide()

local filasEvento = {}
local lineasEvento = {}
local btnCrear
local editNuevo
local btnOK
-- Pre-declaraciones: las funciones/variables se usan antes de definirse
local refrescarDesplegable
local refrescarLista
local confirmarNombre
local txtConfirmar
local confirm
local dialogoSeleccionado
local dragOrigen
local editBox
local btnGuardar
local scrollEdit
local abrirNuevo
local abrirDialogo
local contarCaracteres

local contarBytes
local cortarPorBytes
local dividirPorPalabras
local actualizarBtnCanal
local actualizarNumero
-- ── INVIS (falso diálogo Detection a TODOS, integrado en Diálogos)
local modoInvis
local invisAccion
local panelInvis
local btnPonerInvis
local btnQuitarInvis
local editNumeroInvis
local entrarModoInvis
local salirModoInvis
local actualizarPanelInvis
local parseInvis
local esMarcadorInvis
local construirMarcadorInvis
local obtenerDetectionID
local enviarInvis
-- ── Target optativo para NPC / NPC E (historial por evento)
local editTarget
local targetCaja
local popupTargetSug
local filasTargetSug
local aplicandoTarget
local actualizarVisibilidadTarget
local cargarTargetDialogo
local obtenerTargetsEvento
local obtenerTargetsPorDialogo
local recordarTarget
local refrescarSugerenciasTarget
local ocultarSugerenciasTarget
local ejecutarTar

local textoReal = ""
local textoGuardado = ""
local aplicandoTexto = false
local estabilizando = 0
-- Para el scroll del editor: detectar pegados grandes y forzar vista arriba.
local lenAnterior = 0
local forzarArribaUnaVez = false

-- ── INVIS: estado y helpers (falso diálogo, no rompe los ya creados:
-- -- los diálogos normales siguen siendo strings; el INVIS se guarda
-- -- como marcador string "[INVIS:PONER:12]").
modoInvis = false
invisAccion = "PONER"

parseInvis = function(texto)
    if type(texto) ~= "string" then return nil end
    -- NOTA: los patrones Lua NO soportan (A|B); se captura genérico y se valida.
    local s = texto:match("^%s*(.-)%s*$") or texto
    local acc, numStr = s:match("^%[INVIS:(%a+):(%d+)%]$")
    if not acc or not numStr then return nil end
    if acc ~= "PONER" and acc ~= "QUITAR" then return nil end
    local num = tonumber(numStr)
    if not num or num < 1 or num > 29 then return nil end
    return acc, num
end

esMarcadorInvis = function(texto)
    return parseInvis(texto) ~= nil
end

construirMarcadorInvis = function(acc, num)
    num = tonumber(num)
    if (acc ~= "PONER" and acc ~= "QUITAR") or not num or num < 1 or num > 29 then
        return nil
    end
    return ("[INVIS:%s:%d]"):format(acc, num)
end

-- Mapa Detection 1-29 (igual que Tools-Invis.lua). Si el panel Invis
-- está cargado se usa su tabla global para no duplicar datos.
local DETECTION_MAP_LOCAL = {
    [1] = 49416,  [2] = 49417,  [3] = 60922,  [4] = 90161,  [5] = 94566,
    [6] = 94567,  [7] = 94568,  [8] = 94569,  [9] = 94570,  [10] = 84481,
    [11] = 96737, [12] = 96823, [13] = 96832, [14] = 81742, [15] = 98392,
    [16] = 98433, [17] = 98546, [18] = 98564, [19] = 98920, [20] = 103339,
    [21] = 103458, [22] = 100044, [23] = 94184, [24] = 87418, [25] = 103059,
    [26] = 94226, [27] = 94227, [28] = 89306, [29] = 103786,
}

obtenerDetectionID = function(num)
    num = tonumber(num)
    if not num then return nil end
    if type(GMToolsInvisDetectionIDs) == "table" and GMToolsInvisDetectionIDs[num] then
        return GMToolsInvisDetectionIDs[num]
    end
    return DETECTION_MAP_LOCAL[num]
end

-- ── Target NPC: historial por evento y target actual por diálogo.
-- -- ev.targets = historial de sugerencias (más reciente primero, máx 20).
-- -- ev.targetPorDialogo[índice] = objetivo asociado a ese diálogo.
aplicandoTarget = false

obtenerTargetsEvento = function(ev)
    if not ev then return nil end
    if type(ev.targets) ~= "table" then
        ev.targets = {}
    end
    -- Sanea entradas corruptas sin reescribir diálogos.
    local limpio = {}
    for _, v in ipairs(ev.targets) do
        if type(v) == "string" then
            local s = v:match("^%s*(.-)%s*$") or ""
            if s ~= "" and #limpio < 20 then
                limpio[#limpio + 1] = s
            end
        end
    end
    ev.targets = limpio
    return ev.targets
end

obtenerTargetsPorDialogo = function(ev)
    if not ev then return nil end
    if type(ev.targetPorDialogo) ~= "table" then
        ev.targetPorDialogo = {}
    end
    return ev.targetPorDialogo
end

recordarTarget = function(ev, nombre)
    if not ev or type(nombre) ~= "string" then return end
    local s = nombre:match("^%s*(.-)%s*$") or ""
    if s == "" then return end
    local lista = obtenerTargetsEvento(ev)
    if not lista then return end
    local bajo = string.lower(s)
    for i = #lista, 1, -1 do
        if string.lower(lista[i] or "") == bajo then
            table.remove(lista, i)
        end
    end
    table.insert(lista, 1, s)
    while #lista > 20 do
        table.remove(lista)
    end
end

-- Ejecuta el /tar previo al .npc say / .npc e (solo cliente, no se guarda).
ejecutarTar = function(nombre)
    if type(nombre) ~= "string" then return end
    local s = nombre:match("^%s*(.-)%s*$") or ""
    if s == "" then return end
    if C_Epsilon and C_Epsilon.RunPrivileged then
        pcall(C_Epsilon.RunPrivileged, ("TargetUnit(%q)"):format(s))
    else
        pcall(TargetUnit, s)
    end
end

local function limpiarEditor()
    dialogoSeleccionado = nil
    textoReal = ""
    textoGuardado = ""
    modoInvis = false
    invisAccion = "PONER"
    if panelInvis then panelInvis:Hide() end
    if editNumeroInvis then editNumeroInvis:SetText("") end
    aplicandoTexto = true
    editBox:SetText("")
    aplicandoTexto = false
    editBox:Hide()
    editBox:ClearFocus()
    btnGuardar:Hide()
    if cargarTargetDialogo then cargarTargetDialogo(nil) end
    actualizarNumero()
    if actualizarBtnCanal then actualizarBtnCanal() end
end

local function seleccionarEvento(nombre)
    local db = getDB()
    if not buscarEvento(db, nombre) then return end
    db.eventoActual = nombre
    limpiarEditor()
    lblEvento:SetText(nombre)
    lblEvento:SetTextColor(1, 0.85, 0)
    refrescarLista()
end

local function preguntarEliminar(nombre)
    confirmarNombre = nombre
    txtConfirmar:SetText("¿Eliminar \"" .. nombre .. "\"?\nSe borrarán también sus textos.")
    confirm:Show()
end

local function crearEvento(nombre)
    local db = getDB()
    if not nombre or #nombre == 0 then return end
    if buscarEvento(db, nombre) then
        print("GMTools | El evento \"" .. nombre .. "\" ya existe.")
        return
    end
    table.insert(db.eventos, { nombre = nombre, dialogos = {} })
    ordenarEventos(db)
    db.eventoActual = nombre
    limpiarEditor()
    lblEvento:SetText(nombre)
    lblEvento:SetTextColor(1, 0.85, 0)
    refrescarDesplegable()
    refrescarLista()
end

local function eliminarEvento(nombre)
    local db = getDB()
    for i, ev in ipairs(db.eventos) do
        if ev.nombre == nombre then
            table.remove(db.eventos, i)
            break
        end
    end
    if db.eventoActual == nombre then
        db.eventoActual = nil
        limpiarEditor()
        lblEvento:SetText("Seleccionar Evento")
        lblEvento:SetTextColor(0.7, 0.7, 0.7)
    end
    refrescarDesplegable()
    refrescarLista()
end

refrescarDesplegable = function()
    local db = getDB()
    for _, f in ipairs(filasEvento) do
        f:Hide()
    end
    for i, ev in ipairs(db.eventos) do
        local nombre = ev.nombre
        local fila = filasEvento[i]
        if not fila then
            fila = CreateFrame("Button", nil, popup)
            fila:SetSize(260, 30)
            fila:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
            fila:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.15)

            local txt = fila:CreateFontString(nil, "OVERLAY")
            txt:SetPoint("LEFT", fila, "LEFT", 10, 0)
            registrarFuente(txt, 26, FUENTE_BOTON)
            fila.txt = txt

            local btnElim = CreateFrame("Button", nil, fila, "BackdropTemplate")
            btnElim:SetSize(60, 22)
            btnElim:SetPoint("RIGHT", fila, "RIGHT", -8, 0)
            bordeBoton(btnElim, 0.4, 0.1, 0.1, 0.9)
            local el = btnElim:CreateFontString(nil, "OVERLAY")
            el:SetPoint("CENTER")
            registrarFuente(el, 22, FUENTE_BOTON)
            el:SetTextColor(1, 1, 1)
            el:SetText("Eliminar")
            fila.btnElim = btnElim
            filasEvento[i] = fila
        end

        fila:ClearAllPoints()
        fila:SetPoint("TOPLEFT", popup, "TOPLEFT", 0, -(i - 1) * 34 - 6)
        fila.txt:SetText(nombre)
        if nombre == db.eventoActual then
            fila.txt:SetTextColor(1, 0.85, 0)
        else
            fila.txt:SetTextColor(1, 1, 1)
        end
        fila:SetScript("OnClick", function()
            seleccionarEvento(nombre)
            popup:Hide()
        end)
        fila.btnElim:SetScript("OnClick", function()
            preguntarEliminar(nombre)
            popup:Hide()
        end)
        fila:Show()
    end

    local alturaFilas = #db.eventos * 34 + 6
    btnCrear:SetPoint("TOPLEFT", popup, "TOPLEFT", 10, -(alturaFilas + 8))
    editNuevo:SetPoint("TOPLEFT", popup, "TOPLEFT", 10, -(alturaFilas + 10))
    btnOK:SetPoint("LEFT", editNuevo, "RIGHT", 8, 0)
    popup:SetHeight(alturaFilas + 42)
    btnCrear:Show()
    editNuevo:Hide()
    btnOK:Hide()

    for _, l in ipairs(lineasEvento) do
        l:Hide()
    end
    for i = 1, #db.eventos do
        local linea = lineasEvento[i]
        if not linea then
            linea = popup:CreateTexture(nil, "ARTWORK")
            linea:SetHeight(1)
            linea:SetColorTexture(0.3, 0.5, 0.8, 0.9)
            linea:SetAlpha(0.7)
            lineasEvento[i] = linea
        end
        linea:SetWidth(240)
        linea:ClearAllPoints()
        linea:SetPoint("TOPLEFT", popup, "TOPLEFT", 10, -(i * 34))
        linea:Show()
    end
end

local function confirmarCrear()
    local nombre = editNuevo:GetText()
    if nombre and #nombre > 0 then
        crearEvento(nombre)
    end
    editNuevo:SetText("")
    popup:Hide()
end

btnCrear = CreateFrame("Button", nil, popup, "BackdropTemplate")
btnCrear:SetSize(60, 24)
bordeBoton(btnCrear, 0.1, 0.11, 0.15, 0.9)
local lc = btnCrear:CreateFontString(nil, "OVERLAY")
lc:SetPoint("CENTER")
registrarFuente(lc, 24, FUENTE_BOTON)
lc:SetTextColor(1, 1, 1)
lc:SetText("Crear")
btnCrear:SetScript("OnClick", function()
    btnCrear:Hide()
    editNuevo:Show()
    btnOK:Show()
    editNuevo:SetFocus()
end)

editNuevo = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
editNuevo:SetSize(170, 24)
editNuevo:SetMultiLine(false)
editNuevo:SetAutoFocus(false)
editNuevo:SetMaxLetters(60)
editNuevo:SetTextInsets(6, 6, 4, 4)
registrarFuente(editNuevo, 28, FUENTE_DIALOGO)
editNuevo:SetTextColor(1, 1, 1)
editNuevo:SetScript("OnEnterPressed", confirmarCrear)
editNuevo:Hide()

btnOK = CreateFrame("Button", nil, popup, "BackdropTemplate")
btnOK:SetSize(50, 24)
bordeBoton(btnOK, 0.1, 0.11, 0.15, 0.9)
local lok = btnOK:CreateFontString(nil, "OVERLAY")
lok:SetPoint("CENTER")
registrarFuente(lok, 24, FUENTE_BOTON)
lok:SetTextColor(1, 1, 1)
lok:SetText("OK")
btnOK:SetScript("OnClick", confirmarCrear)
btnOK:Hide()

btnEvento:SetScript("OnClick", function()
    if popup:IsShown() then
        popup:Hide()
    else
        refrescarDesplegable()
        popup:Show()
    end
end)

-- ── Confirmación de eliminación
confirm = CreateFrame("Frame", nil, frame, "BackdropTemplate")
confirm:SetSize(420, 85)
confirm:SetPoint("CENTER", frame, "CENTER")
panel(confirm)
confirm:SetFrameLevel(frame:GetFrameLevel() + 20)
confirm:Hide()

txtConfirmar = confirm:CreateFontString(nil, "OVERLAY")
txtConfirmar:SetPoint("TOP", confirm, "TOP", 0, -10)
registrarFuente(txtConfirmar, 28, FUENTE_BOTON)
txtConfirmar:SetJustifyH("CENTER")
txtConfirmar:SetTextColor(1, 1, 1)

local btnSi = CreateFrame("Button", nil, confirm, "BackdropTemplate")
btnSi:SetSize(60, 24)
btnSi:SetPoint("BOTTOMLEFT", confirm, "BOTTOMLEFT", 90, 10)
bordeBoton(btnSi, 0.4, 0.1, 0.1, 0.9)
local lsi = btnSi:CreateFontString(nil, "OVERLAY")
lsi:SetPoint("CENTER")
registrarFuente(lsi, 24, FUENTE_BOTON)
lsi:SetTextColor(1, 1, 1)
lsi:SetText("SÍ")
btnSi:SetScript("OnClick", function()
    if confirmarNombre then
        eliminarEvento(confirmarNombre)
        confirmarNombre = nil
    end
    confirm:Hide()
end)

local btnNo = CreateFrame("Button", nil, confirm, "BackdropTemplate")
btnNo:SetSize(60, 24)
btnNo:SetPoint("BOTTOMRIGHT", confirm, "BOTTOMRIGHT", -90, 10)
bordeBoton(btnNo, 0.1, 0.11, 0.15, 0.9)
local lno = btnNo:CreateFontString(nil, "OVERLAY")
lno:SetPoint("CENTER")
registrarFuente(lno, 24, FUENTE_BOTON)
lno:SetTextColor(1, 1, 1)
lno:SetText("NO")
btnNo:SetScript("OnClick", function()
    confirmarNombre = nil
    confirm:Hide()
end)

-- ── Confirmación de borrado de diálogo
local confirmDialogo = CreateFrame("Frame", nil, frame, "BackdropTemplate")
confirmDialogo:SetSize(420, 85)
confirmDialogo:SetPoint("CENTER", frame, "CENTER")
panel(confirmDialogo)
confirmDialogo:SetBackdropColor(0.12, 0.18, 0.40, 0.7)
confirmDialogo:SetFrameLevel(frame:GetFrameLevel() + 20)
confirmDialogo:Hide()

local txtConfirmarDialogo = confirmDialogo:CreateFontString(nil, "OVERLAY")
txtConfirmarDialogo:SetPoint("TOP", confirmDialogo, "TOP", 0, -18)
registrarFuente(txtConfirmarDialogo, 28, FUENTE_BOTON)
txtConfirmarDialogo:SetJustifyH("CENTER")
txtConfirmarDialogo:SetTextColor(1, 1, 1)

local btnSiDialogo = CreateFrame("Button", nil, confirmDialogo, "BackdropTemplate")
btnSiDialogo:SetSize(60, 24)
btnSiDialogo:SetPoint("BOTTOMLEFT", confirmDialogo, "BOTTOMLEFT", 90, 18)
bordeBoton(btnSiDialogo, 0.4, 0.1, 0.1, 0.9)
local lsiD = btnSiDialogo:CreateFontString(nil, "OVERLAY")
lsiD:SetPoint("CENTER")
registrarFuente(lsiD, 24, FUENTE_BOTON)
lsiD:SetTextColor(1, 1, 1)
lsiD:SetText("SÍ")
btnSiDialogo:SetScript("OnClick", function()
    local db = getDB()
    local ev = buscarEvento(db, db.eventoActual)
    if ev and dialogoSeleccionado and ev.dialogos[dialogoSeleccionado] then
        local indiceBorrado = dialogoSeleccionado
        table.remove(ev.dialogos, indiceBorrado)
        local targets = ev.targetPorDialogo
        if type(targets) == "table" then
            targets[indiceBorrado] = nil
            for i = indiceBorrado, #ev.dialogos do
                targets[i] = targets[i + 1]
            end
            targets[#ev.dialogos + 1] = nil
        end
        dialogoSeleccionado = nil
        textoGuardado = ""
        textoReal = ""
        modoInvis = false
        invisAccion = "PONER"
        if panelInvis then panelInvis:Hide() end
        if editNumeroInvis then editNumeroInvis:SetText("") end
        if cargarTargetDialogo then cargarTargetDialogo(nil) end
        aplicandoTexto = true
        editBox:SetText("")
        aplicandoTexto = false
        editBox:Hide()
        editBox:ClearFocus()
        btnGuardar:Hide()
        refrescarLista()
        actualizarNumero()
        actualizarBtnCanal()
    end
    confirmDialogo:Hide()
end)

local btnNoDialogo = CreateFrame("Button", nil, confirmDialogo, "BackdropTemplate")
btnNoDialogo:SetSize(60, 24)
btnNoDialogo:SetPoint("BOTTOMRIGHT", confirmDialogo, "BOTTOMRIGHT", -90, 18)
bordeBoton(btnNoDialogo, 0.1, 0.11, 0.15, 0.9)
local lnoD = btnNoDialogo:CreateFontString(nil, "OVERLAY")
lnoD:SetPoint("CENTER")
registrarFuente(lnoD, 24, FUENTE_BOTON)
lnoD:SetTextColor(1, 1, 1)
lnoD:SetText("NO")
btnNoDialogo:SetScript("OnClick", function()
    confirmDialogo:Hide()
end)

-- ── Subventanas interiores (2/3 arriba, 1/3 abajo)
local function subventanaInterior()
    local sub = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    sub:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    sub:SetBackdropColor(0, 0, 0, 0)
    sub:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    sub:EnableMouse(true)
    return sub
end

local sub1 = subventanaInterior()
sub1:SetSize(860, 400)
sub1:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -44)

local sub2 = subventanaInterior()
sub2:SetSize(860, 186)
sub2:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)

frame.sub1 = sub1
frame.sub2 = sub2
ToolDialoguesSub1 = sub1
ToolDialoguesSub2 = sub2

-- TEMPORAL (AJUSTE): botón para ocultar/mostrar la lista de diálogos (sub1). QUITAR después.
local btnOcultarLista = CreateFrame("Button", "GMToolsBtnOcultar", frame)
btnOcultarLista:SetSize(31.2, 31.2)
btnOcultarLista:SetFrameStrata("HIGH")
btnOcultarLista:SetFrameLevel(frame:GetFrameLevel() + 30)
btnOcultarLista:SetPoint("BOTTOM", btnAnadir, "TOP", 12, 152)
btnOcultarLista:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
local hlOcultar = btnOcultarLista:GetHighlightTexture()
if hlOcultar then
    hlOcultar:SetVertexColor(1, 1, 1, 0.15)
    hlOcultar:SetPoint("TOPLEFT", btnOcultarLista, "TOPLEFT", 4.8, -4.8)
    hlOcultar:SetPoint("BOTTOMRIGHT", btnOcultarLista, "BOTTOMRIGHT", -4.8, 4.8)
end
local iconOcultar = btnOcultarLista:CreateTexture("GMToolsBtnOcultarIcon", "ARTWORK")
iconOcultar:SetSize(21.6, 21.6)
iconOcultar:SetPoint("CENTER")
iconOcultar:SetTexture("Interface\\Icons\\eps_arc_xtraarrowdown")
local listaVisible = true
btnOcultarLista:SetScript("OnClick", function()
    listaVisible = not listaVisible
    iconOcultar:SetTexture(listaVisible and "Interface\\Icons\\eps_arc_xtraarrowdown" or "Interface\\Icons\\eps_arc_xtraarrowup")
    local l = frame:GetLeft()
    local b = frame:GetBottom()
    if not l or not b then return end
    local teniaFoco = editBox:HasFocus()
    frame:SetClampedToScreen(false)
    if listaVisible then
        frame:SetHeight(650)
        sub1:Show()
    else
        sub1:Hide()
        frame:SetHeight(250)
    end
    frame:ClearAllPoints()
    frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", l, b)
    frame:SetClampedToScreen(true)
    if teniaFoco and editBox:IsShown() then
        editBox:SetFocus()
        editBox:HighlightText(0, 0)
    end
end)

-- ── Lista de diálogos del evento actual (sub1)
local scroll = CreateFrame("ScrollFrame", nil, sub1, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", sub1, "TOPLEFT", 6, -6)
scroll:SetPoint("BOTTOMRIGHT", sub1, "BOTTOMRIGHT", -6, 6)

local barraScroll = scroll.ScrollBar
if barraScroll then
    barraScroll:ClearAllPoints()
    barraScroll:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", -5, -18)
    barraScroll:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", -5, 18)
end

local content = CreateFrame("Frame", nil, scroll)
scroll:SetScrollChild(content)
content:SetWidth(scroll:GetWidth() - 20)
content.rows = {}

local placeholder = content:CreateFontString(nil, "OVERLAY")
placeholder:SetPoint("TOPLEFT", content, "TOPLEFT", 6, -6)
registrarFuente(placeholder, 28, FUENTE_DIALOGO)
placeholder:SetTextColor(0.6, 0.6, 0.6)
placeholder:SetText("Selecciona un evento para ver sus diálogos")
placeholder:Hide()

local function truncar(texto, max)
    texto = tostring(texto):gsub("[\r\n]+", " ")
    if #texto > max then
        return texto:sub(1, max) .. "..."
    end
    return texto
end

local function indiceEnCursor(lista)
    if not lista or #lista == 0 then return nil end
    -- 1) Destino más fiable: la fila que está bajo el ratón.
    --    Evita errores de escala/coords y permite soltar "en medio".
    for i, fila in ipairs(content.rows) do
        if fila and fila:IsShown() and i <= #lista and fila:IsMouseOver() then
            return i
        end
    end
    -- 2) Fallback por coordenadas (ratón entre filas o fuera de la lista).
    --    NOTA: GetCursorPosition devuelve x, y. Hay que usar el 2º valor.
    local _, cursorY = GetCursorPosition()
    if not cursorY then return nil end
    local escala = content:GetEffectiveScale()
    if not escala or escala == 0 then escala = 1 end
    local y = cursorY / escala
    local top = content:GetTop()
    if not top then return nil end
    -- La primera fila empieza con offset -6 (ver refrescarLista).
    local rel = (top - y) - 6
    if rel < 0 then return 1 end
    local idx = math.floor(rel / 24) + 1
    return math.max(1, math.min(#lista, idx))
end

refrescarLista = function()
    local db = getDB()
    local ev = buscarEvento(db, db.eventoActual)
    local lista = ev and ev.dialogos or {}
    for _, r in ipairs(content.rows) do
        r:Hide()
    end
    if not ev then
        placeholder:Show()
        content:SetHeight(scroll:GetHeight())
        scroll:UpdateScrollChildRect()
        return
    end
    placeholder:Hide()
    local n = #lista
    local anchoFila = math.max(50, content:GetWidth() - 6)
    for i = 1, n do
        local k = i
        local fila = content.rows[i]
        if not fila then
            fila = CreateFrame("Button", nil, content)
            fila:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
            fila:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.12)

            local num = fila:CreateFontString(nil, "OVERLAY")
            num:SetPoint("LEFT", fila, "LEFT", 6, 0)
            num:SetWidth(56)
            num:SetJustifyH("LEFT")
            registrarFuente(num, 28, FUENTE_DIALOGO)
            fila.num = num

            local txt = fila:CreateFontString(nil, "OVERLAY")
            txt:SetPoint("LEFT", fila, "LEFT", 68, 0)
            txt:SetJustifyH("LEFT")
            registrarFuente(txt, 28, FUENTE_DIALOGO)
            fila.txt = txt

            fila:RegisterForDrag("LeftButton")
            content.rows[i] = fila
        end
        fila:SetSize(anchoFila, 24)
        fila:ClearAllPoints()
        fila:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -6 - (i - 1) * 24)
        fila.num:SetText(string.format("[%03d]", k))
        fila.num:SetTextColor(0.6, 0.6, 0.6)
        do
            local acc, num = parseInvis(lista[k])
            if acc and num then
                fila.txt:SetText(("[INVIS %s %d]"):format(acc, num))
                if dialogoSeleccionado == k then
                    fila.txt:SetTextColor(1, 0.85, 0)
                else
                    fila.txt:SetTextColor(0.6, 0.8, 1)
                end
            else
                fila.txt:SetText(truncar(lista[k], 100))
                if dialogoSeleccionado == k then
                    fila.txt:SetTextColor(1, 0.85, 0)
                else
                    fila.txt:SetTextColor(1, 1, 1)
                end
            end
        end
        fila:SetScript("OnClick", function()
            if dialogoSeleccionado == k then
                dialogoSeleccionado = nil
                textoReal = ""
                textoGuardado = ""
                modoInvis = false
                invisAccion = "PONER"
                if panelInvis then panelInvis:Hide() end
                if editNumeroInvis then editNumeroInvis:SetText("") end
                if cargarTargetDialogo then cargarTargetDialogo(nil) end
                aplicandoTexto = true
                editBox:SetText("")
                aplicandoTexto = false
                editBox:Hide()
                editBox:ClearFocus()
                btnGuardar:Hide()
                actualizarNumero()
                actualizarBtnCanal()
            else
                abrirDialogo(k)
            end
            refrescarLista()
        end)
        fila:SetScript("OnDragStart", function()
            dragOrigen = k
        end)
        fila:SetScript("OnDragStop", function()
            local desde = dragOrigen
            dragOrigen = nil
            if not desde or not ev then return end
            local destino = indiceEnCursor(lista)
            if not destino then return end
            local a = desde
            local b = destino
            if a == b then return end
            local elem = table.remove(lista, a)
            table.insert(lista, b, elem)
            local targets = ev.targetPorDialogo
            if type(targets) == "table" then
                local targetMovido = targets[a]
                if a < b then
                    for i = a, b - 1 do
                        targets[i] = targets[i + 1]
                    end
                else
                    for i = a, b + 1, -1 do
                        targets[i] = targets[i - 1]
                    end
                end
                targets[b] = targetMovido
            end
            if dialogoSeleccionado == a then
                dialogoSeleccionado = b
            elseif dialogoSeleccionado then
                local sel = dialogoSeleccionado
                if a < b then
                    if sel > a and sel <= b then sel = sel - 1 end
                elseif sel >= b and sel < a then
                    sel = sel + 1
                end
                dialogoSeleccionado = sel
            end
            refrescarLista()
        end)
        fila:Show()
    end
    content:SetHeight(math.max(n * 24, scroll:GetHeight()))
    scroll:UpdateScrollChildRect()
end

-- ── Área de escritura (sub2): edit box + botón GUARDAR
local fondoEdit = CreateFrame("Frame", nil, sub2, "BackdropTemplate")
fondoEdit:SetPoint("TOPLEFT", sub2, "TOPLEFT", 12, -12)
-- Termina por encima de la fila de target/canal: así el campo NPC no
-- queda encima del panel ni del borde del editor multilínea.
fondoEdit:SetPoint("BOTTOMRIGHT", sub2, "BOTTOMRIGHT", -12, 82)
fondoEdit:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
fondoEdit:SetBackdropColor(0.1, 0.1, 0.15, 0.5)
fondoEdit:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

local clipEdit = CreateFrame("Frame", "GMToolsEditClip", sub2, "BackdropTemplate")
clipEdit:SetFrameLevel(fondoEdit:GetFrameLevel() + 1)
clipEdit:SetPoint("TOPLEFT", sub2, "TOPLEFT", 19, -19)
-- Deja una separación real con la fila de botones/caja NPC inferior:
-- evita que el editBox multilínea quede dibujado por debajo del target.
clipEdit:SetSize(820, 84)
clipEdit:SetClipsChildren(true)
clipEdit:EnableMouse(true)

local visor = CreateFrame("Frame", nil, clipEdit)
visor:SetPoint("TOPLEFT", clipEdit, "TOPLEFT")
visor:SetPoint("TOPRIGHT", clipEdit, "TOPRIGHT")
visor:SetHeight(1)

editBox = CreateFrame("EditBox", nil, visor)
editBox:SetPoint("TOPLEFT", visor, "TOPLEFT", 0, 0)
editBox:SetPoint("BOTTOMRIGHT", visor, "BOTTOMRIGHT")
editBox:SetMultiLine(true)
editBox:SetAutoFocus(false)
editBox:SetMaxLetters(5000)
editBox:SetTextInsets(6, 6, 4, 4)
editBox:SetSpacing(2)
registrarFuente(editBox, 28, FUENTE_DIALOGO / 0.8)
editBox:SetTextColor(1, 1, 1)
editBox:Hide()

scrollEdit = CreateFrame("Slider", "GMToolsEditScroll", clipEdit, "UIPanelScrollBarTemplate")
scrollEdit:SetPoint("TOPLEFT", clipEdit, "TOPRIGHT", 6, -16)
scrollEdit:SetPoint("BOTTOMLEFT", clipEdit, "BOTTOMRIGHT", 6, 16)
scrollEdit:SetValueStep(20)
scrollEdit:SetStepsPerPage(1)
scrollEdit:SetObeyStepOnDrag(true)
scrollEdit:Hide()

local function moverVisor()
    local v = scrollEdit:GetValue() or 0
    visor:ClearAllPoints()
    visor:SetPoint("TOPLEFT", clipEdit, "TOPLEFT", 0, v)
    visor:SetPoint("TOPRIGHT", clipEdit, "TOPRIGHT", 0, v)
end
scrollEdit:SetScript("OnValueChanged", moverVisor)

local function actualizarScroll()
    if not editBox:IsShown() then return end
    local esNuevo = abrirNuevo
    abrirNuevo = false
    local forzarArriba = forzarArribaUnaVez
    forzarArribaUnaVez = false
    local altoClip = clipEdit:GetHeight()
    local altoBox = visor:GetHeight()
    local max = math.max(0, altoBox - altoClip)
    local _, maxAnt = scrollEdit:GetMinMaxValues()
    maxAnt = maxAnt or 0
    local v = scrollEdit:GetValue() or 0
    -- Solo se considera "estaba al fondo" si antes ya había contenido
    -- desplazable. Si maxAnt == 0 (texto corto) no hay fondo: quedarse arriba.
    local fondo = (maxAnt > 8) and (v >= maxAnt - 8)
    scrollEdit:SetMinMaxValues(0, max)
    if max == 0 then
        scrollEdit:Hide()
        scrollEdit:SetValue(0)
        moverVisor()
    else
        scrollEdit:Show()
        if forzarArriba or esNuevo then
            -- Al abrir diálogo o al pegar texto: mostrar desde arriba (0)
            -- para leer desde el principio sin tener que subir a mano.
            scrollEdit:SetValue(0)
            moverVisor()
        elseif fondo then
            scrollEdit:SetValue(max)
        end
    end
end

local fsMedir = sub2:CreateFontString(nil, "OVERLAY")
fsMedir:SetFont("Fonts\\FRIZQT__.TTF", 28 * (FUENTE_DIALOGO / 0.8) * GMToolsDialoguesFontScale)
fsMedir:SetWidth(10)
fsMedir:SetText("A")
local altoUnaLinea = fsMedir:GetStringHeight()
fsMedir:SetText("A\nB")
local altoLinea = math.max(1, fsMedir:GetStringHeight() - altoUnaLinea)
fsMedir:Hide()

local function rueda(d)
    if not editBox:IsShown() then return end
    local v = scrollEdit:GetValue()
    local _, max = scrollEdit:GetMinMaxValues()
    scrollEdit:SetValue(math.max(0, math.min(max, v - d * 40)))
end
clipEdit:SetScript("OnMouseWheel", function(_, d) rueda(d) end)
editBox:SetScript("OnMouseWheel", function(_, d) rueda(d) end)

abrirDialogo = function(k)
    local db = getDB()
    local ev = buscarEvento(db, db.eventoActual)
    local dialogo = ev and ev.dialogos[k]
    if not dialogo then return end
    dialogoSeleccionado = k
    -- Falso diálogo INVIS: mostrar panel PONER/QUITAR + número.
    local acc, num = parseInvis(dialogo)
    if acc and num then
        if cargarTargetDialogo then cargarTargetDialogo(nil) end
        modoInvis = true
        invisAccion = acc
        textoGuardado = dialogo
        textoReal = dialogo
        lenAnterior = #dialogo
        aplicandoTexto = true
        editBox:Hide()
        editBox:ClearFocus()
        if scrollEdit then scrollEdit:Hide() end
        if editNumeroInvis then
            editNumeroInvis:SetText(tostring(num))
        end
        if panelInvis then panelInvis:Show() end
        if actualizarPanelInvis then actualizarPanelInvis() end
        if ocultarSugerenciasTarget then ocultarSugerenciasTarget() end
        aplicandoTexto = false
        estabilizando = 0
        actualizarNumero()
        actualizarBtnCanal()
        btnGuardar:Show()
        refrescarLista()
        actualizarNumero()
        return
    end
    modoInvis = false
    if cargarTargetDialogo then cargarTargetDialogo(k) end
    if panelInvis then panelInvis:Hide() end
    abrirNuevo = true
    aplicandoTexto = true
    editBox:Show()
    editBox:SetText(dialogo)
    textoGuardado = editBox:GetText()
    textoReal = textoGuardado
    aplicandoTexto = false
    estabilizando = 5
    if ocultarSugerenciasTarget then ocultarSugerenciasTarget() end
    actualizarNumero()
    actualizarBtnCanal()
    btnGuardar:Show()
    editBox:SetFocus()
    scrollEdit:SetValue(0)
    refrescarLista()
    actualizarNumero()
end

local function navegarDialogo(delta)
    local db = getDB()
    local ev = buscarEvento(db, db.eventoActual)
    if not ev then return end
    local n = #ev.dialogos
    if n == 0 then return end
    local k
    if dialogoSeleccionado then
        k = dialogoSeleccionado + delta
        if k < 1 then k = 1 end
        if k > n then k = n end
    else
        k = 1
    end
    abrirDialogo(k)
end

local txtContador = sub2:CreateFontString(nil, "OVERLAY")
registrarFuente(txtContador, 22, FUENTE_BOTON)
txtContador:SetTextColor(0.8, 0.8, 0.8)
txtContador:SetText("Caracteres: 0")

btnBorrar:SetPoint("BOTTOMLEFT", sub2, "BOTTOMLEFT", 14, 19)
txtContador:SetPoint("LEFT", btnBorrar, "RIGHT", 10, 0)

local txtNumero = sub2:CreateFontString(nil, "OVERLAY")
registrarFuente(txtNumero, 22, FUENTE_BOTON)
txtNumero:SetTextColor(0.6, 0.6, 0.6)
txtNumero:SetPoint("LEFT", txtContador, "RIGHT", 10, 0)
txtNumero:SetText("")

local txtSinGuardar

actualizarNumero = function()
    local db = getDB()
    local ev = buscarEvento(db, db.eventoActual)
    if not ev then
        txtNumero:SetText("")
        txtSinGuardar:Hide()
        return
    end
    -- Modo INVIS: el editBox está oculto pero el panel sí muestra.
    if modoInvis and panelInvis and panelInvis:IsShown() then
        if dialogoSeleccionado and ev.dialogos[dialogoSeleccionado] then
            txtNumero:SetText(("[%03d]"):format(dialogoSeleccionado))
        else
            txtNumero:SetText(("[%03d]"):format(#ev.dialogos + 1))
        end
        local actual = nil
        if editNumeroInvis then
            local n = tonumber(editNumeroInvis:GetText() or "")
            if n then actual = construirMarcadorInvis(invisAccion, n) end
        end
        if actual ~= textoGuardado then
            txtSinGuardar:Show()
        else
            txtSinGuardar:Hide()
        end
        return
    end
    if not editBox:IsShown() then
        txtNumero:SetText("")
        txtSinGuardar:Hide()
        return
    end
    if dialogoSeleccionado and ev.dialogos[dialogoSeleccionado] then
        txtNumero:SetText(("[%03d]"):format(dialogoSeleccionado))
    else
        txtNumero:SetText(("[%03d]"):format(#ev.dialogos + 1))
    end
    if textoReal ~= textoGuardado then
        txtSinGuardar:Show()
    else
        txtSinGuardar:Hide()
    end
end

contarCaracteres = function(s)
    local _, n = s:gsub("[^\128-\191]", "")
    return n
end

local LIMITE_BYTES = 255

contarBytes = function(s)
    return #s
end

cortarPorBytes = function(palabra, limite)
    local trozos = {}
    local n = #palabra
    local i = 1
    while i <= n do
        local fin = math.min(i + limite - 1, n)
        local s = fin + 1
        while s <= n do
            local b = palabra:byte(s)
            if b and b >= 0x80 and b <= 0xBF then
                s = s - 1
            else
                break
            end
        end
        if s > i then fin = s - 1 end
        trozos[#trozos + 1] = palabra:sub(i, fin)
        i = fin + 1
    end
    return trozos
end

dividirPorPalabras = function(texto, limite)
    limite = limite or LIMITE_BYTES
    local fragmentos = {}
    local actual = ""
    for palabra in texto:gmatch("%S+") do
        if #actual > 0 then
            if #actual + 1 + #palabra <= limite then
                actual = actual .. " " .. palabra
            else
                fragmentos[#fragmentos + 1] = actual
                actual = palabra
            end
        else
            actual = palabra
        end
        if #actual > limite then
            local trozos = cortarPorBytes(actual, limite)
            local resto = table.remove(trozos)
            for _, t in ipairs(trozos) do
                fragmentos[#fragmentos + 1] = t
            end
            actual = resto
        end
    end
    if #actual > 0 then
        fragmentos[#fragmentos + 1] = actual
    end
    return fragmentos
end

local function hayParrafoLargo(texto)
    for linea in texto:gmatch("[^\n\r]+") do
        if contarBytes(linea) > LIMITE_BYTES then
            return true
        end
    end
    return false
end

editBox:SetScript("OnTextChanged", function(_, userInput)
    local nuevoTexto = editBox:GetText() or ""
    -- Detección de pegado: entrada del usuario con crecimiento grande de golpe.
    -- Escribir a mano añade 1-2 bytes; pegar añade decenas/cientos de golpe.
    -- En ese caso forzamos vista arriba para leer desde el principio.
    local delta = #nuevoTexto - (lenAnterior or 0)
    if userInput and delta > 20 then
        forzarArribaUnaVez = true
    end
    lenAnterior = #nuevoTexto
    textoReal = nuevoTexto
    local n = contarCaracteres(textoReal)
    txtContador:SetText(("Caracteres: %d"):format(n))
    actualizarBtnCanal()
    if hayParrafoLargo(textoReal) then
        txtContador:SetTextColor(1, 0.3, 0.3)
        editBox:SetTextColor(1, 0.35, 0.35)
        fondoEdit:SetBackdropBorderColor(1, 0.3, 0.3, 0.9)
    else
        txtContador:SetTextColor(0.8, 0.8, 0.8)
        editBox:SetTextColor(1, 1, 1)
        fondoEdit:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    end
    fsMedir:SetWidth(math.max(10, editBox:GetWidth() - 12))
    fsMedir:SetText(textoReal)
    local altoMedido = fsMedir:GetStringHeight()
    local lineas = math.max(1, math.ceil(altoMedido / altoLinea))
    visor:SetHeight(math.max(clipEdit:GetHeight(), altoMedido + (lineas - 1) * 2 + 12))
    actualizarScroll()
    if estabilizando > 0 then return end
    if not aplicandoTexto then
        actualizarNumero()
    end
end)

local function guardarEnDisco()
    if C_Epsilon and C_Epsilon.RunPrivileged then
        C_Epsilon.RunPrivileged("SaveVariables()")
    else
        pcall(SaveVariables)
    end
end

local function guardar()
    local db = getDB()
    local ev = buscarEvento(db, db.eventoActual)
    if not ev then return end
    -- Capturar el target para asociarlo al índice de este diálogo
    -- después de insertarlo/actualizarlo. No se guarda un target global.
    local targetVisible = editTarget and editTarget:IsShown()
    local targetTexto = ""
    if targetVisible then
        targetTexto = editTarget:GetText() or ""
        targetTexto = targetTexto:match("^%s*(.-)%s*$") or ""
    end
    -- ── Guardar falso diálogo INVIS (marcador, no texto libre)
    if modoInvis then
        local numTxt = editNumeroInvis and editNumeroInvis:GetText() or ""
        local num = tonumber(numTxt)
        if not num or num < 1 or num > 29 then
            print("GMTools | INVIS: escribe un número del 1 al 29.")
            if editNumeroInvis then editNumeroInvis:SetFocus() end
            return
        end
        local marcador = construirMarcadorInvis(invisAccion, num)
        if not marcador then return end
        if dialogoSeleccionado and ev.dialogos[dialogoSeleccionado] then
            ev.dialogos[dialogoSeleccionado] = marcador
        else
            table.insert(ev.dialogos, marcador)
            dialogoSeleccionado = #ev.dialogos
        end
        textoGuardado = marcador
        textoReal = marcador
        lenAnterior = #marcador
        if panelInvis then panelInvis:Show() end
        editBox:Hide()
        btnGuardar:Show()
        refrescarLista()
        actualizarNumero()
        actualizarBtnCanal()
        guardarEnDisco()
        return
    end
    local texto = textoReal
    if not texto or #texto == 0 then return end
    -- Seguridad: un marcador INVIS nunca se guarda como texto normal.
    if esMarcadorInvis(texto) then return end
    local indiceGuardado
    if dialogoSeleccionado and ev.dialogos[dialogoSeleccionado] then
        ev.dialogos[dialogoSeleccionado] = texto
        indiceGuardado = dialogoSeleccionado
    else
        table.insert(ev.dialogos, texto)
        dialogoSeleccionado = #ev.dialogos
        indiceGuardado = dialogoSeleccionado
    end
    if targetVisible then
        local targets = obtenerTargetsPorDialogo(ev)
        if targetTexto ~= "" then
            targets[indiceGuardado] = targetTexto
            recordarTarget(ev, targetTexto)
        else
            targets[indiceGuardado] = nil
        end
    end
    textoGuardado = texto
    textoReal = texto
    aplicandoTexto = true
    editBox:SetText(texto)
    aplicandoTexto = false
    estabilizando = 5
    editBox:Show()
    editBox:SetFocus()
    btnGuardar:Show()
    refrescarLista()
    actualizarNumero()
    guardarEnDisco()
end

btnGuardar = botonTexto(sub2, "GUARDAR", 70, 22)
btnGuardar:SetScript("OnClick", guardar)
btnGuardar:Hide()

txtSinGuardar = sub2:CreateFontString(nil, "OVERLAY")
registrarFuente(txtSinGuardar, 22, FUENTE_BOTON)
txtSinGuardar:SetTextColor(1, 0.85, 0)
txtSinGuardar:SetText("¡Texto sin guardar!")
txtSinGuardar:Hide()

btnAnadir:SetPoint("BOTTOMRIGHT", sub2, "BOTTOMRIGHT", -12, 14)
btnGuardar:SetPoint("RIGHT", btnAnadir, "LEFT", -6, 0)

-- ── Panel INVIS (falso diálogo): PONER / QUITAR + número 1-29.
-- -- Ocupa la zona del texto (fondoEdit). Solo se muestra en modoInvis
-- -- con mensaje nuevo vacío o al abrir un marcador ya guardado.
panelInvis = CreateFrame("Frame", nil, sub2, "BackdropTemplate")
panelInvis:SetPoint("TOPLEFT", sub2, "TOPLEFT", 12, -12)
panelInvis:SetPoint("BOTTOMRIGHT", sub2, "BOTTOMRIGHT", -12, 44)
panelInvis:SetFrameLevel((fondoEdit:GetFrameLevel() or 1) + 2)
panelInvis:Hide()

btnPonerInvis = botonTexto(panelInvis, "PONER", 70, 22)
btnPonerInvis:SetPoint("LEFT", panelInvis, "CENTER", -110, 10)
btnQuitarInvis = botonTexto(panelInvis, "QUITAR", 70, 22)
btnQuitarInvis:SetPoint("LEFT", btnPonerInvis, "RIGHT", 10, 0)

local lblNumInvis = panelInvis:CreateFontString(nil, "OVERLAY")
registrarFuente(lblNumInvis, 22, FUENTE_BOTON)
lblNumInvis:SetPoint("LEFT", btnQuitarInvis, "RIGHT", 12, 0)
lblNumInvis:SetTextColor(1, 1, 1)
lblNumInvis:SetText("Nº:")

editNumeroInvis = CreateFrame("EditBox", nil, panelInvis, "InputBoxTemplate")
editNumeroInvis:SetSize(56, 24)
editNumeroInvis:SetPoint("LEFT", lblNumInvis, "RIGHT", 6, 0)
editNumeroInvis:SetMultiLine(false)
editNumeroInvis:SetAutoFocus(false)
editNumeroInvis:SetMaxLetters(2)
editNumeroInvis:SetTextInsets(6, 6, 4, 4)
registrarFuente(editNumeroInvis, 28, FUENTE_DIALOGO)
editNumeroInvis:SetTextColor(1, 1, 1)
editNumeroInvis:SetText("")

actualizarPanelInvis = function()
    if not panelInvis then return end
    if invisAccion == "QUITAR" then
        bordeBoton(btnQuitarInvis, 0.4, 0.1, 0.1, 0.9)
        bordeBoton(btnPonerInvis, 0.1, 0.11, 0.15, 0.9)
    else
        bordeBoton(btnPonerInvis, 0.1, 0.35, 0.15, 0.9)
        bordeBoton(btnQuitarInvis, 0.1, 0.11, 0.15, 0.9)
    end
end

entrarModoInvis = function()
    modoInvis = true
    if not invisAccion or (invisAccion ~= "PONER" and invisAccion ~= "QUITAR") then
        invisAccion = "PONER"
    end
    editBox:Hide()
    editBox:ClearFocus()
    if scrollEdit then scrollEdit:Hide() end
    if editNumeroInvis and editNumeroInvis:GetText() == "" then
        local sel = tonumber(GMToolsInvisSeleccion)
        if sel and sel >= 1 and sel <= 29 then
            editNumeroInvis:SetText(tostring(sel))
        end
    end
    panelInvis:Show()
    actualizarPanelInvis()
    btnGuardar:Show()
    actualizarNumero()
    actualizarBtnCanal()
    if editNumeroInvis then editNumeroInvis:SetFocus() end
end

salirModoInvis = function()
    modoInvis = false
    if panelInvis then panelInvis:Hide() end
    actualizarBtnCanal()
    actualizarNumero()
end

btnPonerInvis:SetScript("OnClick", function()
    invisAccion = "PONER"
    actualizarPanelInvis()
    actualizarNumero()
    if editNumeroInvis then editNumeroInvis:SetFocus() end
end)
btnQuitarInvis:SetScript("OnClick", function()
    invisAccion = "QUITAR"
    actualizarPanelInvis()
    actualizarNumero()
    if editNumeroInvis then editNumeroInvis:SetFocus() end
end)
editNumeroInvis:SetScript("OnTextChanged", function(_, userInput)
    if userInput then
        local t = editNumeroInvis:GetText() or ""
        local limpio = t:gsub("%D", ""):sub(1, 2)
        if limpio ~= t then
            editNumeroInvis:SetText(limpio)
        end
    end
    if not aplicandoTexto and estabilizando <= 0 then
        actualizarNumero()
    end
end)
editNumeroInvis:SetScript("OnEnterPressed", function() guardar() end)

-- ── Desplegable de canal de chat (encima de CREAR NUEVO)
local CANALES_ENVIO = {
    { etiqueta = "DECIR", canal = "SAY",         prefijo = "" },
    { etiqueta = "NPC",   canal = "NPC",         prefijo = ".npc say " },
    { etiqueta = "EMOTE", canal = "EMOTE",       prefijo = "/e " },
    { etiqueta = "NPC E", canal = "NPC_E",       prefijo = ".npc e " },
    { etiqueta = "AVISO", canal = "RAID_WARNING", prefijo = "/rw " },
    { etiqueta = "RAID",  canal = "RAID",        prefijo = "/raid " },
    { etiqueta = "GRUPO", canal = "PARTY",       prefijo = "/p " },
    { etiqueta = "INVIS", canal = "INVIS",       prefijo = nil },
}

local function canalDesdeTexto(texto)
    if not texto then return "DECIR" end
    if esMarcadorInvis(texto) then return "INVIS" end
    if texto:match("^%.npc say") then return "NPC" end
    if texto:match("^%.npc e") then return "NPC E" end
    local cmd = texto:match("^/(%S+)%s")
    if not cmd then return "DECIR" end
    if cmd == "say" then return "DECIR" end
    if cmd == "e" or cmd == "emote" then return "EMOTE" end
    if cmd == "rw" or cmd == "raidwarning" then return "AVISO" end
    if cmd == "raid" or cmd == "ra" then return "RAID" end
    if cmd == "p" or cmd == "party" then return "GRUPO" end
    return "DECIR"
end

local function aplicarComando(texto, prefijo)
    texto = texto:gsub("^%.npc%s+%S+%s*", "")
    texto = texto:gsub("^/%S+%s*", "")
    if prefijo == "" then return texto end
    return prefijo .. texto
end

local btnCanal = CreateFrame("Button", nil, sub2, "BackdropTemplate")
btnCanal:SetSize(57, 21)
bordeBoton(btnCanal, 0.1, 0.11, 0.15, 0.9)
local lblCanal = btnCanal:CreateFontString(nil, "OVERLAY")
lblCanal:SetPoint("CENTER")
registrarFuente(lblCanal, 24, FUENTE_BOTON)
lblCanal:SetTextColor(1, 1, 1)
lblCanal:SetText("DECIR")
actualizarBtnCanal = function()
    if modoInvis then
        lblCanal:SetText("INVIS")
    else
        lblCanal:SetText(canalDesdeTexto(textoReal))
    end
    if actualizarVisibilidadTarget then actualizarVisibilidadTarget() end
end
btnCanal:SetPoint("BOTTOM", btnAnadir, "TOP", 10, 17)
btnCanal:SetFrameLevel(frame:GetFrameLevel() + 25)
GMToolsBtnCanal = btnCanal
txtSinGuardar:SetPoint("RIGHT", btnGuardar, "LEFT", -6, 0)

local popupCanal = CreateFrame("Frame", nil, sub2, "BackdropTemplate")
popupCanal:SetWidth(80)
popupCanal:SetPoint("BOTTOM", btnCanal, "TOP", 100, -30)
panel(popupCanal)
popupCanal:SetBackdropColor(0.12, 0.18, 0.30, 0.93)
popupCanal:SetFrameLevel(frame:GetFrameLevel() + 30)
GMToolsPopupCanal = popupCanal
popupCanal:Hide()

local filasCanal = {}
for i, op in ipairs(CANALES_ENVIO) do
    local fila = CreateFrame("Button", nil, popupCanal)
    fila:SetSize(76, 26)
    fila:SetPoint("TOP", popupCanal, "TOP", 0, -(i - 1) * 28 - 3)
    fila:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
    fila:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.15)
    local txt = fila:CreateFontString(nil, "OVERLAY")
    txt:SetPoint("CENTER")
    registrarFuente(txt, 24, FUENTE_BOTON)
    txt:SetTextColor(1, 1, 1)
    txt:SetText(op.etiqueta)
    fila.txt = txt
    fila:SetScript("OnClick", function()
        -- ── INVIS: solo con mensaje nuevo VACÍO (falso diálogo).
        if op.etiqueta == "INVIS" then
            if modoInvis then
                popupCanal:Hide()
                return
            end
            local vacio = (not dialogoSeleccionado) and (not textoReal or textoReal:match("^%s*$"))
            if not vacio then
                print("GMTools | INVIS solo disponible en mensaje nuevo vacío (pulsa CREAR NUEVO con el texto vacío).")
                return
            end
            entrarModoInvis()
            popupCanal:Hide()
            return
        end
        -- Salir de INVIS hacia un canal normal (sin autoguardar basura).
        if modoInvis then
            salirModoInvis()
            aplicandoTexto = true
            editBox:Show()
            editBox:SetText(op.prefijo or "")
            textoReal = editBox:GetText()
            lenAnterior = #textoReal
            aplicandoTexto = false
            estabilizando = 5
            actualizarNumero()
            actualizarBtnCanal()
            popupCanal:Hide()
            editBox:SetFocus()
            return
        end
        aplicandoTexto = true
        editBox:SetText(aplicarComando(textoReal, op.prefijo))
        textoGuardado = editBox:GetText()
        textoReal = textoGuardado
        aplicandoTexto = false
        estabilizando = 5
        actualizarNumero()
        guardar()
        popupCanal:Hide()
    end)
    filasCanal[i] = fila
    fila:Show()
end
popupCanal:SetHeight(#CANALES_ENVIO * 28 + 4)

btnCanal:SetScript("OnClick", function()
    if popupCanal:IsShown() then
        popupCanal:Hide()
    else
        local canalActual
        if modoInvis then
            canalActual = "INVIS"
        else
            canalActual = canalDesdeTexto(textoReal)
        end
        for i, op in ipairs(CANALES_ENVIO) do
            if op.etiqueta == canalActual then
                filasCanal[i].txt:SetTextColor(1, 0.85, 0)
            else
                filasCanal[i].txt:SetTextColor(1, 1, 1)
            end
        end
        popupCanal:Show()
    end
end)

-- ── Target optativo para NPC / NPC E (a la izquierda de btnCanal,
-- -- mismo alto 21, ancho 200). Optativo: si está relleno, antes del
-- -- .npc say / .npc e se ejecuta /tar X (no se guarda en el diálogo).
-- -- Historial SOLO del evento actual con sugerencias al escribir.
targetCaja = CreateFrame("Frame", nil, sub2, "BackdropTemplate")
targetCaja:SetSize(200, 21)
targetCaja:SetPoint("RIGHT", btnCanal, "LEFT", -8, 0)
-- La caja visual separada evita superponer el backdrop/template del editor.
targetCaja:SetFrameLevel(clipEdit:GetFrameLevel() + 5)
targetCaja:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true, tileSize = 16, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
targetCaja:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
targetCaja:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

-- EditBox nativo sin backdrop propio: solo texto/cursor, todo el borde
-- azul y fondo oscuro pertenecen a targetCaja.
editTarget = CreateFrame("EditBox", nil, targetCaja)
editTarget:SetAllPoints(targetCaja)
editTarget:SetFrameLevel(targetCaja:GetFrameLevel() + 1)
editTarget:EnableMouse(true)
editTarget:SetMultiLine(false)
editTarget:SetAutoFocus(false)
editTarget:SetMaxLetters(60)
editTarget:SetTextInsets(6, 6, 4, 4)
registrarFuente(editTarget, 24, FUENTE_BOTON)
editTarget:SetTextColor(1, 1, 1)
editTarget:SetText("")
-- Placeholder gris cuando está vacía (no intercepta el ratón).
local phTarget = editTarget:CreateFontString(nil, "OVERLAY")
phTarget:SetPoint("LEFT", editTarget, "LEFT", 8, 0)
registrarFuente(phTarget, 24, FUENTE_BOTON)
phTarget:SetTextColor(0.55, 0.55, 0.55)
phTarget:SetText("Nombre del NPC Objetivo...")
editTarget.phTarget = phTarget
phTarget:Show()
editTarget:Hide()

popupTargetSug = CreateFrame("Frame", nil, sub2, "BackdropTemplate")
popupTargetSug:SetWidth(200)
popupTargetSug:SetPoint("BOTTOMLEFT", targetCaja, "TOPLEFT", 0, 4)
panel(popupTargetSug)
popupTargetSug:SetBackdropColor(0.12, 0.18, 0.30, 0.95)
popupTargetSug:SetFrameLevel(targetCaja:GetFrameLevel() + 4)
popupTargetSug:Hide()
filasTargetSug = {}

ocultarSugerenciasTarget = function()
    if popupTargetSug then popupTargetSug:Hide() end
end

refrescarSugerenciasTarget = function()
    if not editTarget or not editTarget:IsShown() then
        ocultarSugerenciasTarget()
        return
    end
    local db = getDB()
    local ev = buscarEvento(db, db.eventoActual)
    if not ev then
        ocultarSugerenciasTarget()
        return
    end
    local lista = obtenerTargetsEvento(ev)
    if not lista or #lista == 0 then
        ocultarSugerenciasTarget()
        return
    end
    local actual = editTarget:GetText() or ""
    local pref = string.lower(actual:match("^%s*(.-)%s*$") or "")
    -- No desplegar toda la lista al entrar en la caja: sugerir solo
    -- después de que se haya escrito un prefijo.
    if pref == "" then
        ocultarSugerenciasTarget()
        return
    end
    local coinc = {}
    for _, nombre in ipairs(lista) do
        if string.lower(nombre):sub(1, #pref) == pref then
            if string.lower(nombre) ~= pref then
                coinc[#coinc + 1] = nombre
            end
            if #coinc >= 6 then break end
        end
    end
    if #coinc == 0 then
        ocultarSugerenciasTarget()
        return
    end
    for idx, nombre in ipairs(coinc) do
        local fila = filasTargetSug[idx]
        if not fila then
            fila = CreateFrame("Button", nil, popupTargetSug)
            fila:SetSize(192, 22)
            fila:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
            fila:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.15)
            local txt = fila:CreateFontString(nil, "OVERLAY")
            txt:SetPoint("LEFT", fila, "LEFT", 10, 0)
            registrarFuente(txt, 24, FUENTE_BOTON)
            txt:SetTextColor(1, 1, 1)
            fila.txt = txt
            filasTargetSug[idx] = fila
        end
        fila:ClearAllPoints()
        fila:SetPoint("TOPLEFT", popupTargetSug, "TOPLEFT", 4, -(idx - 1) * 24 - 4)
        fila.txt:SetText(nombre)
        fila:SetScript("OnClick", function()
            aplicandoTarget = true
            editTarget:SetText(nombre)
            aplicandoTarget = false
            ocultarSugerenciasTarget()
            editTarget:SetFocus()
        end)
        fila:Show()
    end
    for i = #coinc + 1, #filasTargetSug do
        filasTargetSug[i]:Hide()
    end
    popupTargetSug:SetHeight(math.min(152, #coinc * 24 + 8))
    popupTargetSug:Show()
end

-- Carga el target asociado al índice de diálogo seleccionado.
cargarTargetDialogo = function(indice)
    if not editTarget then return end
    local db = getDB()
    local ev = buscarEvento(db, db.eventoActual)
    local nombre
    if ev and indice then
        local targets = ev.targetPorDialogo
        nombre = type(targets) == "table" and targets[indice] or nil
    end
    aplicandoTarget = true
    if type(nombre) == "string" then
        editTarget:SetText(nombre)
    else
        editTarget:SetText("")
    end
    aplicandoTarget = false
    ocultarSugerenciasTarget()
end

-- Visible SOLO cuando el diálogo actual es NPC o NPC E.
actualizarVisibilidadTarget = function()
    if not editTarget then return end
    local mostrar = false
    if not modoInvis and editBox and editBox:IsShown() then
        local canal = canalDesdeTexto(textoReal)
        if canal == "NPC" or canal == "NPC E" then
            mostrar = true
        end
    end
    if mostrar then
        if targetCaja then targetCaja:Show() end
        editTarget:Show()
    else
        editTarget:Hide()
        if targetCaja then targetCaja:Hide() end
        ocultarSugerenciasTarget()
    end
end

editTarget:SetScript("OnTextChanged", function(_, userInput)
    local txt = editTarget:GetText() or ""
    if editTarget.phTarget then
        if txt == "" then
            editTarget.phTarget:Show()
        else
            editTarget.phTarget:Hide()
        end
    end
    if aplicandoTarget then return end
    if userInput then
        refrescarSugerenciasTarget()
    else
        ocultarSugerenciasTarget()
    end
end)
editTarget:SetScript("OnMouseDown", function(self)
    self:SetFocus()
end)
editTarget:SetScript("OnEnterPressed", function()
    ocultarSugerenciasTarget()
    editTarget:ClearFocus()
    if editBox and editBox:IsShown() then editBox:SetFocus() end
end)
editTarget:SetScript("OnEscapePressed", function()
    ocultarSugerenciasTarget()
    editTarget:ClearFocus()
end)
editTarget:SetScript("OnEditFocusGained", function()
    ocultarSugerenciasTarget()
end)
editTarget:SetScript("OnEditFocusLost", function()
    C_Timer.After(0.15, function()
        if editTarget and not editTarget:HasFocus() then
            ocultarSugerenciasTarget()
        end
    end)
end)

local CANALES_CHAT = {
    say = "SAY", s = "SAY",
    yell = "YELL", y = "YELL",
    party = "PARTY", p = "PARTY",
    raid = "RAID", ra = "RAID",
    guild = "GUILD", g = "GUILD",
    emote = "EMOTE", e = "EMOTE", me = "EMOTE",
    whisper = "WHISPER", w = "WHISPER", tell = "WHISPER", t = "WHISPER",
    rw = "RAID_WARNING", raidwarning = "RAID_WARNING",
    instance = "INSTANCE_CHAT", i = "INSTANCE_CHAT",
    bg = "BATTLEGROUND", battleground = "BATTLEGROUND",
}

local function enviarPrivilegiado(lua)
    if C_Epsilon and C_Epsilon.RunPrivileged then
        C_Epsilon.RunPrivileged(lua)
    else
        loadstring(lua)()
    end
end

local function enviarLinea(linea, canalDefecto)
    local contenido, canal, destino = linea, canalDefecto or "SAY", nil
    if linea:sub(1, 1) == "/" then
        local cmd, resto = linea:match("^/(%S+)%s*(.*)$")
        if cmd then
            local c = CANALES_CHAT[cmd:lower()]
            if c then
                canal = c
                contenido = resto or ""
                if canal == "WHISPER" then
                    local nombre, msg = resto:match("^(%S+)%s+(.+)$")
                    if nombre and msg then
                        contenido, destino = msg, nombre
                    else
                        return
                    end
                end
            elseif cmd:match("^%d+$") then
                canal, contenido, destino = "CHANNEL", resto or "", cmd
            elseif SlashCmdList and SlashCmdList[cmd:upper()] then
                SlashCmdList[cmd:upper()](resto or "")
                return
            end
        end
    end
    if contarBytes(contenido) > LIMITE_BYTES then
        for _, frag in ipairs(dividirPorPalabras(contenido, LIMITE_BYTES)) do
            if destino then
                enviarPrivilegiado(("SendChatMessage(%q, %q, nil, %q)"):format(frag, canal, destino))
            else
                enviarPrivilegiado(("SendChatMessage(%q, %q)"):format(frag, canal))
            end
        end
    elseif destino then
        enviarPrivilegiado(("SendChatMessage(%q, %q, nil, %q)"):format(contenido, canal, destino))
    else
        enviarPrivilegiado(("SendChatMessage(%q, %q)"):format(contenido, canal))
    end
end

-- Envía un falso diálogo INVIS igual que el panel Detections/Invis
-- en modo DETECTION + TODOS: .ph aura ID (PONER) o .ph unaura ID (QUITAR).
enviarInvis = function(acc, num)
    local id = obtenerDetectionID(num)
    if not id then
        print("GMTools | INVIS: número inválido (" .. tostring(num) .. ").")
        return
    end
    local msg
    if acc == "QUITAR" then
        msg = ".ph unaura " .. id
    else
        msg = ".ph aura " .. id
    end
    enviarPrivilegiado(("SendChatMessage(%q, %q)"):format(msg, "SAY"))
end

local btnEnviar = botonTexto(sub2, "ENVIAR", 70, 30, 30)
btnEnviar:SetPoint("BOTTOM", sub2, "BOTTOM", 0, 10)
btnEnviar:SetScript("OnClick", function()
    -- Si estamos en modo INVIS (nuevo sin guardar o marcador abierto),
    -- guardar el marcador y enviar el Detection a TODOS.
    if modoInvis then
        guardar()
        local acc, num = parseInvis(textoGuardado)
        if not acc then
            local n2 = tonumber(editNumeroInvis and editNumeroInvis:GetText() or "")
            if n2 then acc, num = invisAccion, n2 end
        end
        if acc and num then
            enviarInvis(acc, num)
        end
        return
    end
    local texto = textoReal
    if not texto or #texto == 0 then return end
    -- Un marcador guardado (por si se envía sin pasar por modoInvis).
    do
        local acc, num = parseInvis(texto)
        if acc and num then
            guardar()
            enviarInvis(acc, num)
            return
        end
    end
    guardar()
    -- Target optativo: si es NPC/NPC E y hay objetivo, /tar X primero
    -- (línea por encima, no se guarda en el diálogo).
    do
        local canal = canalDesdeTexto(texto)
        if (canal == "NPC" or canal == "NPC E") and editTarget and editTarget:IsShown() then
            local tgt = (editTarget:GetText() or ""):match("^%s*(.-)%s*$") or ""
            if tgt ~= "" then
                ejecutarTar(tgt)
            end
        end
    end
    for linea in texto:gmatch("[^\n\r]+") do
        local l = linea:match("^%s*(.-)%s*$")
        if l and #l > 0 then
            enviarLinea(l)
        end
    end
end)

local function botonIcono(icono)
    local b = CreateFrame("Button", nil, sub2, "BackdropTemplate")
    b:SetSize(30, 30)
    bordeBoton(b, 0.1, 0.11, 0.15, 0.9)
    local tex = b:CreateTexture(nil, "OVERLAY")
    tex:SetPoint("TOPLEFT", b, "TOPLEFT", 3, -3)
    tex:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -3, 3)
    tex:SetTexture(icono)
    return b
end

local btnIzq = botonIcono("Interface\\Icons\\eps_arc_xtraarrowleft")
btnIzq:SetPoint("RIGHT", btnEnviar, "LEFT", -6, 0)
btnIzq:SetScript("OnClick", function() navegarDialogo(-1) end)

local btnDer = botonIcono("Interface\\Icons\\eps_arc_xtraarrowright")
btnDer:SetPoint("LEFT", btnEnviar, "RIGHT", 6, 0)
btnDer:SetScript("OnClick", function() navegarDialogo(1) end)

-- ── Acciones
btnAnadir:SetScript("OnClick", function()
    local db = getDB()
    if not buscarEvento(db, db.eventoActual) then
        print("GMTools | Selecciona un evento antes de añadir un diálogo.")
        return
    end
    dialogoSeleccionado = nil
    modoInvis = false
    invisAccion = "PONER"
    if panelInvis then panelInvis:Hide() end
    if editNumeroInvis then editNumeroInvis:SetText("") end
    if cargarTargetDialogo then cargarTargetDialogo(nil) end
    if ocultarSugerenciasTarget then ocultarSugerenciasTarget() end
    refrescarLista()
    aplicandoTexto = true
    editBox:Show()
    editBox:SetText("")
    textoGuardado = editBox:GetText()
    textoReal = textoGuardado
    lenAnterior = #textoReal
    aplicandoTexto = false
    estabilizando = 5
    actualizarNumero()
    actualizarBtnCanal()
    btnGuardar:Show()
    editBox:SetFocus()
end)

btnBorrar:SetScript("OnClick", function()
    local db = getDB()
    local ev = buscarEvento(db, db.eventoActual)
    if ev and dialogoSeleccionado and ev.dialogos[dialogoSeleccionado] then
        txtConfirmarDialogo:SetText("¿Estás seguro de que quieres borrar #" .. dialogoSeleccionado .. "?")
        confirmDialogo:Show()
    end
end)

-- ── Inicio: refresca cuando el SavedVariables ya está cargado
local cargador = CreateFrame("Frame")
cargador:RegisterEvent("ADDON_LOADED")
cargador:SetScript("OnEvent", function(self, _, addon)
    if addon ~= "GMTools" then return end
    GMToolsDialoguesSetFontScale(GMToolsDialoguesFontScale or 1)
    local db = getDB()
    if db.eventoActual and not buscarEvento(db, db.eventoActual) then
        db.eventoActual = nil
    end
    if db.eventoActual then
        lblEvento:SetText(db.eventoActual)
        lblEvento:SetTextColor(1, 0.85, 0)
    else
        lblEvento:SetText("Seleccionar Evento")
        lblEvento:SetTextColor(0.7, 0.7, 0.7)
    end
    refrescarDesplegable()
    refrescarLista()
    self:UnregisterAllEvents()
end)

frame:SetScript("OnUpdate", function()
    if estabilizando > 0 then
        estabilizando = estabilizando - 1
        if estabilizando == 0 then
            textoGuardado = editBox:GetText()
            textoReal = textoGuardado
            actualizarNumero()
        end
    end
end)

ToolDialoguesFrame = frame

SLASH_GMDIALOGOS1 = "/dialogos"
SLASH_GMDIALOGOS2 = "/dialogo"
SlashCmdList["GMDIALOGOS"] = function()
    if ToolDialoguesFrame then
        if ToolDialoguesFrame:IsShown() then
            ToolDialoguesFrame:Hide()
        else
            ToolDialoguesFrame:Show()
        end
    end
end
