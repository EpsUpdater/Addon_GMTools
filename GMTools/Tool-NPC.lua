-- ============================================================
-- Tool-NPC.lua
-- Ventana de texto temporal NPC. Copia independiente de la
-- parte inferior de la ventana de Diálogos (campo de escritura,
-- borrar, caracteres, enviar, canal...), SIN la lista de
-- diálogos ni los eventos.
-- El texto es SOLO TEMPORAL: no se guarda en ningún archivo.
-- ENVIAR manda el texto al canal correspondiente y lo borra.
-- BORRAR vacía la pestaña (la deja a 0).
-- No comparte nada con Tool-Dialogues.lua.
-- Se abre/cierra con el segundo botón de gobs (btnDerecha2).
-- ============================================================

-- ── Tamaño de letra (misma escala que diálogos por defecto)
local FUENTE_DIALOGO = 0.5
local FUENTE_BOTON   = 0.6

GMToolsNPCFontScale = GMToolsNPCFontScale or 0.8

local fuentes = {}
local function registrarFuente(fs, base, cat)
    fuentes[#fuentes + 1] = { fs = fs, base = base, cat = cat }
    fs:SetFont("Fonts\\FRIZQT__.TTF", base * cat * GMToolsNPCFontScale)
end

local function aplicarFuentes()
    for _, e in ipairs(fuentes) do
        e.fs:SetFont("Fonts\\FRIZQT__.TTF", e.base * e.cat * GMToolsNPCFontScale)
    end
end

local parent = GMToolsFrame

-- ── Diseño estándar del addon (idéntico al de la ventana principal)
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

local frame = CreateFrame("Frame", "ToolNPCFrame", parent or UIParent, "BackdropTemplate")
frame:SetSize(487, 185)
panel(frame)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop",  frame.StopMovingOrSizing)
frame:Hide()

-- ── Ancla por defecto: esquina inferior derecha de la ventana NPC
-- a la esquina superior derecha de la ventana principal, 5 píxeles por encima.
frame:SetPoint("BOTTOMRIGHT", GMToolsFrame, "TOPRIGHT", 0, 5)

-- ── Botones de texto (mismo aspecto que en Diálogos)
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

-- ── Estado: solo texto temporal, no se guarda nada
local editBox
local textoReal = ""

local btnBorrar = botonTexto(frame, "BORRAR", 60, 22)

-- ── Área de escritura (la mitad inferior de Diálogos, copiada)
local fondoEdit = CreateFrame("Frame", nil, frame, "BackdropTemplate")
fondoEdit:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -12)
fondoEdit:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 44)
fondoEdit:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
fondoEdit:SetBackdropColor(0.1, 0.1, 0.15, 0.5)
fondoEdit:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

local clipEdit = CreateFrame("Frame", "GMToolsNPCClip", frame, "BackdropTemplate")
clipEdit:SetFrameLevel(fondoEdit:GetFrameLevel() + 1)
clipEdit:SetPoint("TOPLEFT", frame, "TOPLEFT", 19, -19)
clipEdit:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -19, 47)
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
editBox:Show()

local scrollEdit = CreateFrame("Slider", "GMToolsNPCScroll", clipEdit, "UIPanelScrollBarTemplate")
scrollEdit:SetPoint("TOPLEFT", clipEdit, "TOPRIGHT", 6, -16)
scrollEdit:SetPoint("BOTTOMLEFT", clipEdit, "BOTTOMRIGHT", 6, 16)
scrollEdit:SetValueStep(20)
scrollEdit:SetStepsPerPage(1)
scrollEdit:SetObeyStepOnDrag(true)
scrollEdit:Hide()

-- La vista NO se mueve sola: solo baja si el jugador hace scroll.
local function moverVisor()
    visor:SetPoint("TOPLEFT", clipEdit, "TOPLEFT", 0, scrollEdit:GetValue())
end
scrollEdit:SetScript("OnValueChanged", moverVisor)

local function actualizarScroll()
    local altoClip = clipEdit:GetHeight()
    local altoBox = visor:GetHeight()
    local max = math.max(0, altoBox - altoClip)
    scrollEdit:SetMinMaxValues(0, max)
    if max == 0 then
        scrollEdit:Hide()
        scrollEdit:SetValue(0)
        moverVisor()
    else
        scrollEdit:Show()
    end
end

local fsMedir = frame:CreateFontString(nil, "OVERLAY")
fsMedir:SetFont("Fonts\\FRIZQT__.TTF", 28 * (FUENTE_DIALOGO / 0.8) * GMToolsNPCFontScale)
fsMedir:SetWidth(10)
fsMedir:SetText("A")
local altoUnaLinea = fsMedir:GetStringHeight()
fsMedir:SetText("A\nB")
local altoLinea = math.max(1, fsMedir:GetStringHeight() - altoUnaLinea)
fsMedir:Hide()

local function rueda(d)
    local v = scrollEdit:GetValue()
    local _, max = scrollEdit:GetMinMaxValues()
    scrollEdit:SetValue(math.max(0, math.min(max, v - d * 40)))
end
clipEdit:SetScript("OnMouseWheel", function(_, d) rueda(d) end)
editBox:SetScript("OnMouseWheel", function(_, d) rueda(d) end)

-- ── Fila inferior: BORRAR y contador de caracteres
local txtContador = frame:CreateFontString(nil, "OVERLAY")
registrarFuente(txtContador, 22, FUENTE_BOTON)
txtContador:SetTextColor(0.8, 0.8, 0.8)
txtContador:SetText("Caracteres: 0")

btnBorrar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 14, 19)
txtContador:SetPoint("LEFT", btnBorrar, "RIGHT", 10, 0)

local function contarCaracteres(s)
    local _, n = s:gsub("[^\128-\191]", "")
    return n
end

local LIMITE_BYTES = 255
local function contarBytes(s)
    return #s
end

local function cortarPorBytes(palabra, limite)
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

local function dividirPorPalabras(texto, limite)
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

-- ── Desplegable de canal de chat (idéntico al de Diálogos, con NPC)
local CANALES_ENVIO = {
    { etiqueta = "NPC",       canal = "NPC",       prefijo = ".npc say " },
    { etiqueta = "NPC E",     canal = "NPC_E",     prefijo = ".npc e " },
    { etiqueta = "DECIR",     canal = "SAY",         prefijo = "" },
    { etiqueta = "EMOTE",     canal = "EMOTE",       prefijo = "/e " },
    { etiqueta = "AVISO",     canal = "RAID_WARNING", prefijo = "/rw " },
    { etiqueta = "RAID",      canal = "RAID",        prefijo = "/raid " },
    { etiqueta = "GRUPO",     canal = "PARTY",       prefijo = "/p " },
}

local function canalDesdeTexto(texto)
    if not texto then return "NPC" end
    if texto:match("^%.npc say") then return "NPC" end
    if texto:match("^%.npc e") then return "NPC E" end
    local cmd = texto:match("^/(%S+)%s")
    if not cmd then return "NPC" end
    if cmd == "say" then return "DECIR" end
    if cmd == "e" or cmd == "emote" then return "EMOTE" end
    if cmd == "rw" or cmd == "raidwarning" then return "AVISO" end
    if cmd == "raid" or cmd == "ra" then return "RAID" end
    if cmd == "p" or cmd == "party" then return "GRUPO" end
    return "NPC"
end

local function aplicarComando(texto, prefijo)
    texto = texto:gsub("^%.npc%s+%S+%s*", "")
    texto = texto:gsub("^/%S+%s*", "")
    if prefijo == "" then return texto end
    return prefijo .. texto
end

local btnCanal = CreateFrame("Button", nil, frame, "BackdropTemplate")
btnCanal:SetSize(57, 21)
btnCanal:SetPoint("BOTTOM", frame, "BOTTOMRIGHT", -42, 20)
bordeBoton(btnCanal, 0.1, 0.11, 0.15, 0.9)
local lblCanal = btnCanal:CreateFontString(nil, "OVERLAY")
lblCanal:SetPoint("CENTER")
registrarFuente(lblCanal, 24, FUENTE_BOTON)
lblCanal:SetTextColor(1, 1, 1)
lblCanal:SetText("NPC")

local function actualizarBtnCanal()
    lblCanal:SetText(canalDesdeTexto(textoReal))
end

local popupCanal = CreateFrame("Frame", nil, frame, "BackdropTemplate")
popupCanal:SetWidth(80)
popupCanal:SetPoint("BOTTOM", btnCanal, "TOP", 100, -30)
panel(popupCanal)
popupCanal:SetBackdropColor(0.12, 0.18, 0.30, 0.93)
popupCanal:SetFrameLevel(frame:GetFrameLevel() + 30)
popupCanal:Hide()

local prefijoActual = ".npc say "
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
        prefijoActual = op.prefijo
        editBox:SetText(aplicarComando(textoReal, op.prefijo))
        textoReal = editBox:GetText()
        actualizarBtnCanal()
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
        local canalActual = canalDesdeTexto(textoReal)
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

-- ── Envío al chat (el texto se borra después; no se guarda)
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

local btnEnviar = botonTexto(frame, "ENVIAR", 70, 30, 30)
btnEnviar:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
btnEnviar:SetScript("OnClick", function()
    local texto = textoReal
    if not texto or #texto == 0 then return end
    for linea in texto:gmatch("[^\n\r]+") do
        local l = linea:match("^%s*(.-)%s*$")
        if l and #l > 0 then
            enviarLinea(l)
        end
    end
    editBox:SetText(prefijoActual)
    textoReal = editBox:GetText()
    actualizarBtnCanal()
    txtContador:SetText(("Caracteres: %d"):format(contarCaracteres(textoReal)))
    editBox:SetFocus()
end)

-- ── BORRAR: vacía la pestaña (todo a 0, sin confirmar ni guardar)
btnBorrar:SetScript("OnClick", function()
    editBox:SetText(prefijoActual)
    textoReal = editBox:GetText()
    actualizarBtnCanal()
    txtContador:SetText(("Caracteres: %d"):format(contarCaracteres(textoReal)))
    fondoEdit:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    editBox:SetTextColor(1, 1, 1)
    editBox:SetFocus()
end)

-- ── Clic en la zona de escritura: da foco para escribir
local function enfocarEditor()
    editBox:SetFocus()
end
fondoEdit:SetScript("OnMouseDown", enfocarEditor)
clipEdit:SetScript("OnMouseDown", enfocarEditor)

-- ── Conexión del editor con el contador y el scroll
editBox:SetScript("OnTextChanged", function()
    textoReal = editBox:GetText()
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
    visor:SetHeight(math.max(clipEdit:GetHeight(), altoMedido + (lineas - 1) * 2 + 4 * altoLinea + 12))
    actualizarScroll()
    -- Recoloca el cursor al final: el cliente recalcula el desplazamiento
    -- interno con la caja ya crecida y no empuja el texto hacia arriba.
    local cur = editBox:GetCursorPosition()
    local num = editBox:GetNumLetters()
    if num > 0 and cur == num then
        editBox:SetCursorPosition(num - 1)
        editBox:SetCursorPosition(num)
    end
end)

-- NPC es el canal por defecto: el cuadro arranca con ".npc say "
editBox:SetText(".npc say ")
prefijoActual = ".npc say "

-- ════════════════════════════════════════════════════════════
-- VENTANA DE HERRAMIENTAS NPC — gemela de la ventana izquierda
-- del addon principal: 2 subventanas AL LADO (una al lado de la
-- otra) con 2 botones cada una (37x37, gap 4, mismo borde), de
-- forma que en total ocupan lo mismo que la ventana a la que se
-- ancla (181 de ancho). Los 4 botones son genéricos con el icono
-- temporal de los gobs. Se ancla: esquina inferior izquierda con
-- la esquina SUPERIOR IZQUIERDA de la ventana izquierda de GM,
-- 5 píxeles por encima (sube con ella si se expande).
-- Se muestra solo mientras la ventana NPC está abierta.
-- ════════════════════════════════════════════════════════════
local function panelOscuro(f)
    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f:SetBackdropColor(0.12, 0.18, 0.40, 0.25)
    f:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
end

local SUB_BTN = 37
local SUB_GAP = 4

local AYUDA_BOTONES = { "NPC Move", "NPC Go", "Turn 10", "Turn 10" }
local COMANDOS_HERRAMIENTAS = { ".npc move", ".npc go", ".npc turn 10", ".npc turn -10" }
local ICONOS_HERRAMIENTAS = {
    { tex = "Interface\\Icons\\eps_buildershaven_waypointmodposition", rot = math.pi },
    { tex = "Interface\\Icons\\eps_buildershaven_gobgo" },
    { tex = "Interface\\Icons\\eps_arc_xtraarrowleft" },
    { tex = "Interface\\Icons\\eps_arc_xtraarrowright" },
}
local indiceAyuda = 0

local herramientas = CreateFrame("Frame", "ToolNPCTools", UIParent, "BackdropTemplate")
herramientas:SetSize(181, 102)
panelOscuro(herramientas)
if GMToolsFrameIzq then
    herramientas:SetPoint("BOTTOMLEFT", GMToolsFrameIzq, "TOPLEFT", 0, 5)
else
    herramientas:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 400, 400)
end
herramientas:SetFrameLevel((GMToolsFrameIzq and GMToolsFrameIzq:GetFrameLevel() or 0) + 5)
herramientas:Hide()

local function crearSubHerramienta(parent, x, y)
    local sub = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    sub:SetSize(86, 45)
    sub:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    sub:SetClipsChildren(true)
    sub:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    sub:SetBackdropColor(0, 0, 0, 0)
    sub:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    for i = 1, 2 do
        local btn = CreateFrame("Button", nil, sub)
        btn:SetSize(SUB_BTN, SUB_BTN)
        btn:SetPoint("TOPLEFT", sub, "TOPLEFT", 4 + (i - 1) * (SUB_BTN + SUB_GAP), -4)
        btn:RegisterForClicks("LeftButtonUp")
        btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
        indiceAyuda = indiceAyuda + 1
        local ayuda = AYUDA_BOTONES[indiceAyuda]
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(ayuda)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        local icon = btn:CreateTexture(nil, "BACKGROUND")
        icon:SetSize(36, 36)
        icon:SetPoint("CENTER")
        icon:SetTexture(ICONOS_HERRAMIENTAS[indiceAyuda].tex)
        if ICONOS_HERRAMIENTAS[indiceAyuda].rot then
            icon:SetRotation(ICONOS_HERRAMIENTAS[indiceAyuda].rot)
        end
        local comando = COMANDOS_HERRAMIENTAS[indiceAyuda]
        btn:SetScript("OnClick", function()
            SendChatMessage(comando, "SAY")
        end)
    end
    return sub
end

crearSubHerramienta(herramientas, 2, -53)
crearSubHerramienta(herramientas, 2 + 86 + 3, -53)

GMToolsNPCTools = herramientas

-- ════════════════════════════════════════════════════════════
-- BOTÓN BORRAR — rojo, mismo ancho que las subventanas (86),
-- anclado por su borde inferior a la esquina superior izquierda
-- de la ventana de 8 botones, 5 píxeles por encima.
-- Envía .npc delete
-- ════════════════════════════════════════════════════════════
local btnBorrarNpc = CreateFrame("Button", "ToolNPCBorrar", UIParent, "BackdropTemplate")
btnBorrarNpc:SetSize(84, 22)
btnBorrarNpc:SetPoint("BOTTOMLEFT", herramientas, "TOPLEFT", 2, 5)
bordeBoton(btnBorrarNpc, 0.4, 0.1, 0.1, 0.9)
local lblBorrar = btnBorrarNpc:CreateFontString(nil, "OVERLAY")
lblBorrar:SetPoint("CENTER")
registrarFuente(lblBorrar, 24, FUENTE_BOTON)
lblBorrar:SetTextColor(1, 1, 1)
lblBorrar:SetText("BORRAR")
btnBorrarNpc:RegisterForClicks("LeftButtonUp")
btnBorrarNpc:SetScript("OnClick", function()
    SendChatMessage(".npc delete", "SAY")
end)
btnBorrarNpc:Hide()

GMToolsNPCBorrar = btnBorrarNpc

-- ════════════════════════════════════════════════════════════
-- FILA SUPERIOR DE SUBVENTANAS dentro de la misma ventana general:
-- a la izquierda Poseer / Cancelar Posesión, a la derecha
-- NPC Follow / Refresh.
-- ════════════════════════════════════════════════════════════
local subArribaIzq = CreateFrame("Frame", nil, herramientas, "BackdropTemplate")
subArribaIzq:SetSize(86, 45)
subArribaIzq:SetPoint("TOPLEFT", herramientas, "TOPLEFT", 2, -4)
subArribaIzq:SetClipsChildren(true)
subArribaIzq:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
subArribaIzq:SetBackdropColor(0, 0, 0, 0)
subArribaIzq:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

local AYUDA_ARRIBA = { "Poseer", "Cancelar Posesión" }
local COMANDOS_ARRIBA = { ".posses", ".unposses" }
local ICONOS_ARRIBA = {
    "Interface\\Icons\\eps_bg3_enthrall",
    "Interface\\Icons\\eps_bg3_entangle",
}
for i = 1, 2 do
    local btn = CreateFrame("Button", nil, subArribaIzq)
    btn:SetSize(SUB_BTN, SUB_BTN)
    btn:SetPoint("TOPLEFT", subArribaIzq, "TOPLEFT", 4 + (i - 1) * (SUB_BTN + SUB_GAP), -4)
    btn:RegisterForClicks("LeftButtonUp")
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(AYUDA_ARRIBA[i])
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(36, 36)
    icon:SetPoint("CENTER")
    icon:SetTexture(ICONOS_ARRIBA[i])
    btn:SetScript("OnClick", function()
        SendChatMessage(COMANDOS_ARRIBA[i], "SAY")
    end)
end

-- Segunda subventana superior, a la derecha, con 2 botones
-- (NPC Follow / Refresh), mismo estilo que las demás
local subArribaDer = CreateFrame("Frame", nil, herramientas, "BackdropTemplate")
subArribaDer:SetSize(86, 45)
subArribaDer:SetPoint("TOPLEFT", herramientas, "TOPLEFT", 2 + 86 + 3, -4)
subArribaDer:SetClipsChildren(true)
subArribaDer:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
subArribaDer:SetBackdropColor(0, 0, 0, 0)
subArribaDer:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

local function botonHerramientaArriba(parent, x)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(SUB_BTN, SUB_BTN)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 4 + (x - 1) * (SUB_BTN + SUB_GAP), -4)
    btn:RegisterForClicks("LeftButtonUp")
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(36, 36)
    icon:SetPoint("CENTER")
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return btn, icon
end

-- Botón 1: NPC Follow / NPC Follow Stop (alterna estado al pulsar)
local btnFollow, iconFollow = botonHerramientaArriba(subArribaDer, 1)
local siguiendoNpc = false
iconFollow:SetTexture("Interface\\AddOns\\GMTools\\icons\\icono-follow.blp")
btnFollow:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(siguiendoNpc and "NPC Follow Stop" or "NPC Follow")
    GameTooltip:Show()
end)
btnFollow:SetScript("OnClick", function()
    if siguiendoNpc then
        SendChatMessage(".npc follow stop", "SAY")
        siguiendoNpc = false
        iconFollow:SetTexture("Interface\\AddOns\\GMTools\\icons\\icono-follow.blp")
    else
        SendChatMessage(".npc follow", "SAY")
        siguiendoNpc = true
        iconFollow:SetTexture("Interface\\AddOns\\GMTools\\icons\\icono-followstop.blp")
    end
end)

-- Botón 2: Refresh
local btnRefresh, iconRefresh = botonHerramientaArriba(subArribaDer, 2)
iconRefresh:SetTexture("Interface\\AddOns\\GMTools\\icons\\icono-refresh.blp")
btnRefresh:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Refresh")
    GameTooltip:Show()
end)
btnRefresh:SetScript("OnClick", function()
    SendChatMessage(".refresh", "SAY")
end)

-- ── Apertura/cierre desde el botón de gobs (btnDerecha2)
function GMToolsNPCToggle()
    if frame:IsShown() then
        frame:Hide()
        if herramientas then herramientas:Hide() end
        if btnBorrarNpc then btnBorrarNpc:Hide() end
    else
        if GMToolsCerrarGobs then
            GMToolsCerrarGobs()
        end
        frame:Show()
        if herramientas then herramientas:Show() end
        if btnBorrarNpc then btnBorrarNpc:Show() end
    end
end

-- ── Inicio: aplica la escala de fuentes
local cargador = CreateFrame("Frame")
cargador:RegisterEvent("ADDON_LOADED")
cargador:SetScript("OnEvent", function(self, _, addon)
    if addon ~= "GMTools" then return end
    aplicarFuentes()
    self:UnregisterAllEvents()
end)

GMToolsNPCFrame = frame