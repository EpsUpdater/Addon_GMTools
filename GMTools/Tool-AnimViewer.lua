-- ============================================================
-- Tool-AnimViewer.lua
-- Integrado en GMTools desde el addon independiente NPCAnimViewer.
-- Assets en: Interface\AddOns\GMTools\icons\animviewer\
-- ============================================================

-- ============================================================
-- TABLAS DE ANIMACIONES (antes NPCAnimViewer-Tablas.lua)
-- Formato:
--   { anim = SetAnimationID, nombre = "Nombre ES", categoria = "CAT",
--     IDingame = EmoteID, tags = { ... } }
--
-- anim      → ID para SetAnimation() del modelo del addon
-- IDingame  → ID del emote del servidor (.npc emote X repeat)
-- ============================================================

NPCAnimViewer_Animaciones = {

    -- ════════════════════════════════════════════════════════
    -- SOCIALES
    -- ════════════════════════════════════════════════════════
    { anim = 60,  nombre = "Hablar",               categoria = "SOCIALES", IDingame = 1,   tags = { "hablar", "talk", "conversar", "decir" } },
    { anim = 66,  nombre = "Reverencia",            categoria = "SOCIALES", IDingame = 2,   tags = { "bow", "reverencia", "inclinar", "respeto" } },
    { anim = 67,  nombre = "Saludar",               categoria = "SOCIALES", IDingame = 3,   tags = { "wave", "saludar", "hola", "adios" } },
    { anim = 68,  nombre = "Animar",               categoria = "SOCIALES", IDingame = 4,   tags = { "cheer", "aclamar", "victoria", "hurra","animar" } },
    { anim = 64,  nombre = "Gritar",           categoria = "SOCIALES", IDingame = 5,   tags = { "exclamacion", "sorpresa", "asombro","gritar" } },
    { anim = 65,  nombre = "Preguntar",              categoria = "SOCIALES", IDingame = 6,   tags = { "question", "pregunta", "que", "interrogacion" } },
    { anim = 70,  nombre = "Reír",                  categoria = "SOCIALES", IDingame = 11,  tags = { "reir", "risa", "laugh", "carcajada" } },
    { anim = 73,  nombre = "Insultar",            categoria = "SOCIALES", IDingame = 14,  tags = { "rude", "rudo", "grosero", "ofender","insultar","insulto" } },
    { anim = 76,  nombre = "Besar",                 categoria = "SOCIALES", IDingame = 17,  tags = { "kiss", "besar", "beso", "amor" } },
    { anim = 77,  nombre = "Llorar",                categoria = "SOCIALES", IDingame = 18,  tags = { "cry", "llorar", "llanto", "lagrimas", "triste" } },
    { anim = 78,  nombre = "Gallina",               categoria = "SOCIALES", IDingame = 19,  tags = { "chicken", "gallina", "cobarde", "miedoso" } },
    { anim = 79,  nombre = "Suplicar",              categoria = "SOCIALES", IDingame = 20,  tags = { "beg", "suplicar", "rogar", "pedir","arrodillarse","rodillas" } },
    { anim = 80,  nombre = "Aplaudir",              categoria = "SOCIALES", IDingame = 21,  tags = { "applaud", "aplaudir", "aplauso", "palmadas" } },
    { anim = 82,  nombre = "Posar",              categoria = "SOCIALES", IDingame = 23,  tags = { "flex", "presumir", "musculo", "fuerza", "posar" } },
    { anim = 83,  nombre = "Timidez",               categoria = "SOCIALES", IDingame = 24,  tags = { "shy", "timido", "vergüenza", "rubor" } },
    { anim = 84,  nombre = "Señalar",               categoria = "SOCIALES", IDingame = 25,  tags = { "point", "señalar", "apuntar", "mirar" } },
    { anim = 69,  nombre = "Bailar",                categoria = "SOCIALES", IDingame = 94,  tags = { "dance", "bailar", "baile", "danza" } },
    { anim = 185,  nombre = "Asentir",                    categoria = "SOCIALES", IDingame = 273, tags = { "yes", "si", "afirmar", "asentir" } },
    { anim = 186,  nombre = "Negar",                    categoria = "SOCIALES", IDingame = 274, tags = { "no", "negar", "rechazar" } },
    { anim = 211, nombre = "Bailar",        categoria = "SOCIALES", IDingame = 401, tags = { "dance", "danzar", "baile", "gilneas", "bailar" } },
    { anim = 506,  nombre = "Olfatear",              categoria = "SOCIALES", IDingame = 479, tags = { "sniff", "olfatear", "oler", "nariz" } },
    { anim = 1314,  nombre = "Beber",         categoria = "SOCIALES", IDingame = 748, tags = { "drink", "beber", "libre" } },
    { anim = 1310,  nombre = "Beber Borracho",           categoria = "SOCIALES", IDingame = 765, tags = { "drink", "beber", "ebrio", "borracho" } },

    -- ════════════════════════════════════════════════════════
    -- SENTADO
    -- ════════════════════════════════════════════════════════
    { anim = 326,  nombre = "Sentado",              categoria = "SENTADO",  IDingame = 455,  tags = { "sit", "sentar", "sentado", "descansar" } },
    { anim = 103,  nombre = "Silla Media",           categoria = "SENTADO",  IDingame = 415, tags = { "sit", "silla", "sentado", "chair" } },
    { anim = 104,  nombre = "Silla Alta",            categoria = "SENTADO",  IDingame = 426, tags = { "sit", "silla", "alta", "chair" } },
    { anim = 102,  nombre = "Silla Baja",            categoria = "SENTADO",  IDingame = 461, tags = { "sit", "silla", "baja", "chair" } },
    { anim = 520,  nombre = "Leer Sentado",          categoria = "SENTADO",  IDingame = 616, tags = { "read", "leer", "sentado", "libro" } },
    { anim = 520,  nombre = "Leer Sentado en Silla",    categoria = "SENTADO",  IDingame = 715, tags = { "read", "leer", "sentado", "silla" } },
    { anim = 61,  nombre = "Comer Sentado",         categoria = "SENTADO",  IDingame = 766, tags = { "eat", "comer", "sentado", "silla" } },
    { anim = 520,  nombre = "Leer y Hablar",         categoria = "TRABAJO",  IDingame = 588, tags = { "read", "leer", "hablar", "sentado" } },
    { anim = 520,  nombre = "Leer Sentado Navidad",  categoria = "SENTADO",  IDingame = 518, tags = { "read", "leer", "navidad", "christmas" } },

    -- ════════════════════════════════════════════════════════
    -- ERGUIDO
    -- ════════════════════════════════════════════════════════
    { anim = 0,   nombre = "De Pie",                categoria = "ERGUIDO",  IDingame = 26,  tags = { "stand", "pie", "erguido", "postura" } },
    { anim = 113, nombre = "Saludo Militar",        categoria = "ERGUIDO",  IDingame = 66,  tags = { "salute", "militar", "saludo", "honor" } },
    { anim = 75,  nombre = "Arrodillarse",           categoria = "ERGUIDO",  IDingame = 672, tags = { "kneel", "arrodillar", "rodilla" } },
    { anim = 732, nombre = "Meditar",               categoria = "ERGUIDO",  IDingame = 533, tags = { "meditate", "meditar", "paz", "zen" } },
    { anim = 710,   nombre = "Postura Grulla",        categoria = "ERGUIDO",  IDingame = 512, tags = { "crane", "grulla", "monje", "postura" } },
    { anim = 1240,   nombre = "Mano en la Cadera",             categoria = "ERGUIDO",  IDingame = 714, tags = { "guard", "guardia", "centinela", "cadera", "mano en la cadera" } },
    { anim = 1242,   nombre = "Firme con Arma Recta Izq.",             categoria = "ERGUIDO",  IDingame = 716, tags = { "guard", "guardia", "centinela", "firme con arma recta", "lanza" } },
    { anim = 1244,   nombre = "Firme con Arma Recta Der.",             categoria = "ERGUIDO",  IDingame = 717, tags = { "guard", "guardia", "centinela", "firme con arma recta", "lanza" } },
    { anim = 1260,   nombre = "Apoyado en la Pared",             categoria = "ERGUIDO",  IDingame = 720, tags = { "lean", "apoyado", "descanso", "pared","reclinado" } },
    { anim = 1160,   nombre = "Caminar Borracho",         categoria = "ESTADO",  IDingame = 721, tags = { "drunk", "ebrio", "borracho", "caminar" } },
    { anim = 1182, nombre = "Canalizar Magia",               categoria = "DISTANCIA",  IDingame = 725, tags = { "summon", "invocar", "ritual","castear","canalizar magia" ,"magia"} },
    { anim = 1154,   nombre = "Borracho",                 categoria = "ESTADO",  IDingame = 751, tags = { "drunk", "ebrio", "borracho" } },
    { anim = 590,   nombre = "Apoyado en la Barra",             categoria = "ERGUIDO",  IDingame = 886, tags = { "bartend", "tabernero", "bar", "posada","apoyado en la barra","barra","apoyado","reclinado" } },
    { anim = 1200,   nombre = "Pierna Delante",             categoria = "ERGUIDO",  IDingame = 878, tags = { "crier", "pregonero", "anunciar","firme","preparado","rodilla","pierna delante" } },
    { anim = 688,   nombre = "Monje Preparado",         categoria = "COMBATE",  IDingame = 706, tags = { "monk", "monje", "defensa", "guardia","monje preparado","preparado","combate" } },
    { anim = 1076,  nombre = "Palo al Hombro",         categoria = "ERGUIDO",  IDingame = 712, tags = { "monk", "monje", "idle" } },
    { anim = 13,  nombre = "Caminar Atrás",         categoria = "ESTADO",  IDingame = 456, tags = { "walk", "atras", "retroceder" } },
    { anim = 0, nombre = "Brazos Cruzados",        categoria = "ERGUIDO", IDingame = 5968, tags = { "brazos cruzados", "crossed arms", "cruzado", "crossed", "brazos", "arms" } },
    { anim = 0, nombre = "Ofrecer Mano",           categoria = "ERGUIDO", IDingame = 6042, tags = { "ofrecer mano", "offer hand", "mano", "hand", "ofrecer", "offer", "saludar", "greeting" } },
    { anim = 0, nombre = "Hablar",                 categoria = "ERGUIDO", IDingame = 5986, tags = { "hablar", "talk", "hablando", "talking", "conversar", "conversation", "nuevo", "new" } },

    -- ════════════════════════════════════════════════════════
    -- ESTADO
    -- ════════════════════════════════════════════════════════
    { anim = 71,  nombre = "Dormir",                categoria = "ESTADO",   IDingame = 902,  tags = { "sleep", "dormir", "descanso", "cama" } },
    { anim = 14,  nombre = "Aturdido",              categoria = "ESTADO",   IDingame = 64,  tags = { "stun", "aturdido", "mareado" } },
    { anim = 1,   nombre = "Morirse",                categoria = "ESTADO",   IDingame = 4001,  tags = { "dead", "muerto", "muerte", "caido","morirse" } },
    { anim = 63,   nombre = "Fabricar",           categoria = "ESTADO",   IDingame = 69,  tags = { "use", "usar", "interactuar","fabricar","craftear" } },
    { anim = 132,   nombre = "Ahogado",               categoria = "ESTADO",   IDingame = 383, tags = { "drown", "ahogado", "agua" } },
    { anim = 131,   nombre = "Ahogarse",              categoria = "ESTADO",   IDingame = 387, tags = { "drown", "ahogarse", "morir" } },
    { anim = 203,   nombre = "Arrodillarse",           categoria = "ESTADO",   IDingame = 398, tags = { "arrodillarse", "agachado", "arrodillado", "rodillas" } },
    { anim = 91,  nombre = "Montado",               categoria = "SENTADO",   IDingame = 424, tags = { "mount", "montado", "caballo", "montura" } },
    { anim = 40,   nombre = "Caer",                  categoria = "ESTADO",   IDingame = 427, tags = { "fall", "caer", "caida" } },
    { anim = 225,   nombre = "Miedo",           categoria = "ESTADO",   IDingame = 430, tags = { "cower", "acobardarse", "miedo", "terror", "aterrado", "temblar", "susto" } },
    { anim = 120, nombre = "Sigilo",                categoria = "ESTADO",   IDingame = 433, tags = { "stealth", "sigilo", "ocultar", "rogue" } },
    { anim = 41,  nombre = "Nadar Quieto",          categoria = "ESTADO",   IDingame = 437, tags = { "swim", "nadar", "agua", "quieto" } },
    { anim = 269,   nombre = "Caída en Vuelo",        categoria = "ESTADO",   IDingame = 444, tags = { "fall", "caida", "vuelo", "fly" } },
    { anim = 520,   nombre = "Leer",                  categoria = "TRABAJO",   IDingame = 483, tags = { "read", "leer", "libro", "pergamino" } },
    { anim = 75,  nombre = "Arrodillarse",      categoria = "ESTADO",   IDingame = 550, tags = { "rodillas", "arrodillarse", "agacharse", "inclinarse" } },
    { anim = 618,  nombre = "A Cuatro Patas",        categoria = "ESTADO",   IDingame = 557, tags = { "mount", "montura", "a cuatro patas", "agachado", "arrodillado", "cuatro", "cuatro patas", "worgen", "huargen" } },
    { anim = 484,   nombre = "Montura sujetando Volante",     categoria = "SENTADO",   IDingame = 575, tags = { "volante", "montura sujetando volante", "montura", "conducir" } },
    { anim = 500,  nombre = "Sentado Manos en las Piernas",    categoria = "SENTADO",   IDingame = 546, tags = { "sentado con las manos en las piernas", "sentado", "piernas", "sentado manos piernas", "sentado manos en las piernas" } },
    { anim = 460,   nombre = "Correr",        categoria = "ESTADO",   IDingame = 535, tags = { "correr", "run", "corriendo" } },
    { anim = 1306,   nombre = "Halconero",             categoria = "ESTADO",   IDingame = 739, tags = { "falconeer", "halconero", "pajaro", "brazo", "brazo estirado" } },
    { anim = 1178,   nombre = "Colgado",               categoria = "ESTADO",   IDingame = 749, tags = { "hang", "colgado", "atado" } },
    { anim = 325,   nombre = "Sentarse",   categoria = "SENTADO",   IDingame = 447, tags = { "sit", "sentarse", "sentado" } },
    { anim = 327,   nombre = "Levantarse",      categoria = "SENTADO",   IDingame = 448, tags = { "stand", "levantarse", "levantado" } },
    { anim = 94,   nombre = "Especial Montura",      categoria = "ESTADO",   IDingame = 377, tags = { "mount", "especial", "montura" } },
    { anim = 0, nombre = "Sigilo",                 categoria = "ESTADO",  IDingame = 6030, tags = { "sigilo", "stealth", "furtivo", "sneak", "agachado", "crouch", "nuevo", "new" } },

    -- ════════════════════════════════════════════════════════
    -- TRABAJO
    -- ════════════════════════════════════════════════════════
    { anim = 61,  nombre = "Comer",                 categoria = "ESTADO",  IDingame = 7,   tags = { "eat", "comer", "comida", "boca" } },
    { anim = 136,   nombre = "Golpear con Arma",              categoria = "TRABAJO",  IDingame = 173, tags = { "work", "trabajar", "labor", "herrero", "martillo", "golpear" } },
	{ anim = 62,   nombre = "Golpear sin Arma",       categoria = "TRABAJO",  IDingame = 657, tags = { "work", "trabajar", "labor", "herrero", "martillo", "golpear" } },
	{ anim = 136, nombre = "Golpear con Martillo",                categoria = "TRABAJO",  IDingame = 613, tags = { "smith", "forjar", "work", "trabajar", "labor", "herrero", "martillo", "golpear" } },
    { anim = 195, nombre = "Tren",                 categoria = "SOCIALES",  IDingame = 585, tags = { "tren", "train" } },
    { anim = 134,   nombre = "Pescando",              categoria = "TRABAJO",  IDingame = 379, tags = { "fish", "pescar", "pesca", "cana" } },
    { anim = 133,   nombre = "Lanzar Caña",                categoria = "TRABAJO",  IDingame = 380, tags = { "fish", "pescar", "lanzar caña", "caña" } },
    { anim = 50,   nombre = "Saquear",               categoria = "ESTADO",  IDingame = 381, tags = { "loot", "saquear", "robar", "cofre" } },
    { anim = 1272,  nombre = "Fregar Suelo",                categoria = "TRABAJO",  IDingame = 722, tags = { "scrub", "fregar", "limpiar" } },
    { anim = 1220, nombre = "Martillear",             categoria = "TRABAJO",  IDingame = 728, tags = { "hammer", "martillear", "golpear", "martillar", "clavo", "clavar" } },
    { anim = 1316,   nombre = "Atado con Miedo",               categoria = "TRABAJO",  IDingame = 729, tags = { "bound", "atado", "cuerda", "atado manos espalda", "manos espalda", "espalda", "atado con miedo", "miedo", "prisionero" } },
    { anim = 1318,   nombre = "Atado Rendido",               categoria = "TRABAJO",  IDingame = 730, tags = { "bound", "atado", "cuerda", "atado manos espalda", "manos espalda", "espalda", "atado rendido", "rendido", "prisionero" } },
    { anim = 1212,   nombre = "Objeto al Hombro",         categoria = "TRABAJO",  IDingame = 731, tags = { "hold", "saco", "sostener", "carga", "objeto al hombro", "al hombro", "hombro" } },
    { anim = 1234,  nombre = "Firme Izquierda",       categoria = "ERGUIDO",  IDingame = 733, tags = { "firme", "escudo", "preparado", "izquierda", "de pie", "firme izquierda" } },
    { anim = 1232,  nombre = "Firme Derecha",         categoria = "ERGUIDO",  IDingame = 734, tags = { "firme", "escudo", "preparado", "derecha", "de pie", "firme derecha" } },
    { anim = 1300,  nombre = "Firme arma en Mano",        categoria = "ERGUIDO",  IDingame = 761, tags = { "firme", "arma en mano", "firme arma en mano", "preparado" } },
    { anim = 1296,   nombre = "Sostener Objeto",        categoria = "TRABAJO",  IDingame = 880, tags = { "wheel", "timon", "barca", "barco", "sostener", "coger", "llevar", "objeto" } },
    { anim = 1208,   nombre = "Sostener Caja",         categoria = "TRABAJO",  IDingame = 900, tags = { "hold", "caja", "crate", "sostener" } },
    { anim = 1304,   nombre = "Halconero Inicio",      categoria = "TRABAJO",  IDingame = 738, tags = { "falconeer", "halconero", "inicio" } },
    { anim = 1308,   nombre = "Halconero Fin",         categoria = "TRABAJO",  IDingame = 740, tags = { "falconeer", "halconero", "fin" } },
    { anim = 0, nombre = "Cavar",                   categoria = "TRABAJO", IDingame = 6046, tags = { "cavar", "dig", "excavar", "excavate", "pala", "shovel", "cavar tierra", "digging" } },
    { anim = 0, nombre = "Cocinar sobre Hoguera",    categoria = "TRABAJO", IDingame = 5536, tags = { "cocinar", "cook", "cocina", "cooking", "hoguera", "campfire", "fuego", "fire" } },
    { anim = 0, nombre = "Desollar",                 categoria = "TRABAJO", IDingame = 5716, tags = { "desollar", "skin", "desollar animal", "skinning", "cuchillo", "knife", "carne", "meat", "arrodillado", "kneeling" } },

    -- ════════════════════════════════════════════════════════
    -- COMBATE
    -- ════════════════════════════════════════════════════════
    { anim = 74,  nombre = "Rugir",                 categoria = "SOCIALES",  IDingame = 15,  tags = { "roar", "rugir", "gritar", "intimidar" } },
    { anim = 25,  nombre = "Preparado a Puños",        categoria = "COMBATE",  IDingame = 27,  tags = { "ready", "listo", "sin arma", "puños", "preparado", "a puños" } },
    { anim = 9,   nombre = "Recibir Golpe",           categoria = "COMBATE",  IDingame = 33,  tags = { "wound", "herida", "golpe", "leve", "recibir golpe", "recibir", "golpeado" } },
    { anim = 10,   nombre = "Recibir Golpe",        categoria = "COMBATE",  IDingame = 34,  tags = { "wound", "herida", "golpe", "leve", "recibir golpe", "recibir", "golpeado" } },
    { anim = 16,  nombre = "Puñetazo",        categoria = "COMBATE",  IDingame = 35,  tags = { "attack", "golpe", "puños", "sin arma", "puñetazos", "golpear" } },
    { anim = 17,  nombre = "Ataque 1 Mano",         categoria = "COMBATE",  IDingame = 36,  tags = { "attack", "ataque", "espada", "1h" } },
    { anim = 18,  nombre = "Ataque 2 Manos",     categoria = "COMBATE",  IDingame = 37,  tags = { "attack", "ataque", "2h", "mandoble", "dos manos", "ataque 2 manos", "ataque con dos manos", "con dos manos", "espada", "golpear", "atacar", "tajo" } },
    { anim = 19,  nombre = "Ataque 2 Manos",     categoria = "COMBATE",  IDingame = 38,  tags = { "attack", "ataque", "2h", "mandoble", "dos manos", "ataque 2 manos", "ataque con dos manos", "con dos manos", "espada", "golpear", "atacar", "tajo" } },
    { anim = 20,  nombre = "Parada Sin Arma",       categoria = "COMBATE",  IDingame = 39,  tags = { "parry", "parada", "sin arma", "bloqueo" } },
    { anim = 24,  nombre = "Parada Escudo",         categoria = "COMBATE",  IDingame = 43,  tags = { "parry", "escudo", "bloquear", "shield" } },
    { anim = 25,  nombre = "Preparado Sin Arma",    categoria = "COMBATE",  IDingame = 44,  tags = { "ready", "preparado", "sin arma" } },
    { anim = 26,  nombre = "Preparado Manos Abajo",          categoria = "COMBATE",  IDingame = 45,  tags = { "ready", "preparado", "manos abajo", "preparado manos abajo" } },
    { anim = 55,  nombre = "Rugido de Batalla",     categoria = "COMBATE",  IDingame = 53,  tags = { "roar", "batalla", "guerra", "gritar" } },
    { anim = 57,  nombre = "Especial 1M",           categoria = "COMBATE",  IDingame = 54,  tags = { "special", "especial", "ataque", "1h" } },
    { anim = 95,  nombre = "Patada",                categoria = "COMBATE",  IDingame = 60,  tags = { "kick", "patada", "pie", "golpe" } },
    { anim = 107,   nombre = "Golpear",        categoria = "COMBATE",  IDingame = 61,  tags = { "throw", "lanzar", "ataque", "proyectil", "golpear", "lanza" } },
    { anim = 27,  nombre = "Preparado 2M",     categoria = "COMBATE",  IDingame = 375, tags = { "ready", "listo", "2h", "estado", "preparado", "preparado 1 mano", "una mano", "combate" } },
    { anim = 126,   nombre = "Torbellino",            categoria = "COMBATE",  IDingame = 382, tags = { "whirlwind", "torbellino", "giro", "girar", "tornado" } },
    { anim = 181,   nombre = "Pisotón",               categoria = "COMBATE",  IDingame = 388, tags = { "stomp", "pisoton", "golpe", "suelo" } },
    { anim = 87,  nombre = "Ataque Secundario",     categoria = "COMBATE",  IDingame = 389, tags = { "attack", "secundario", "offhand" } },
    { anim = 88,  nombre = "Estocada",   categoria = "COMBATE",  IDingame = 390, tags = { "pierce", "estocada", "perforar" } },
    { anim = 16,  nombre = "Atacar Sin Arma",       categoria = "COMBATE",  IDingame = 438, tags = { "attack", "puños", "sin arma" } },
    { anim = 30,  nombre = "Esquivar",              categoria = "COMBATE",  IDingame = 440, tags = { "dodge", "esquivar", "evitar" } },
    { anim = 21,   nombre = "Bloquear 1M",             categoria = "COMBATE",  IDingame = 441, tags = { "parry", "parada", "1h", "bloquear", "bloqueo", "bloquear 1m", "block" } },
    { anim = 22,   nombre = "Bloquear 2M",             categoria = "COMBATE",  IDingame = 442, tags = { "parry", "parada", "2h", "bloquear", "bloqueo", "bloquear 1m", "block" } },
    { anim = 28,   nombre = "Parada 2M",            categoria = "COMBATE",  IDingame = 443, tags = { "parry", "parada", "2h", "largo" } },
    { anim = 118,   nombre = "Especial Sin Arma",     categoria = "COMBATE",  IDingame = 477, tags = { "special", "especial", "sin arma" } },
    { anim = 181,   nombre = "Pisotón",        categoria = "COMBATE",  IDingame = 480, tags = { "golpe", "pisoton", "pisotón", "stompa", "suelo" } },
    { anim = 121,   nombre = "Derribado",              categoria = "COMBATE",  IDingame = 482, tags = { "knockdown", "derribar", "caer", "derribado" } },
    { anim = 672,   nombre = "Ataque Monje",          categoria = "COMBATE",  IDingame = 507, tags = { "monk", "monje", "puños", "ataque" } },
    { anim = 680,   nombre = "Especial Monje",        categoria = "COMBATE",  IDingame = 508, tags = { "monk", "monje", "especial" } },
    { anim = 676,  nombre = "Parada Monje",          categoria = "COMBATE",  IDingame = 509, tags = { "monk", "monje", "parada" } },
    { anim = 678,  nombre = "Monje Preparado",           categoria = "COMBATE",  IDingame = 510, tags = { "monk", "monje", "listo", "guardia" } },
    { anim = 670,   nombre = "Golpe de Palma",        categoria = "COMBATE",  IDingame = 511, tags = { "palm", "palma", "golpe", "monje" } },
    { anim = 17,  nombre = "Atacar 1M",    categoria = "COMBATE",  IDingame = 567, tags = { "attack", "1h", "estado" } },
    { anim = 10,   nombre = "Recibir Golpe",         categoria = "COMBATE",  IDingame = 584, tags = { "wound", "herida", "golpe", "leve", "recibir golpe", "recibir", "golpeado" } },
    { anim = 58,  nombre = "Especial 2M",           categoria = "COMBATE",  IDingame = 587, tags = { "special", "especial", "2h" } },
    { anim = 0,   nombre = "Muerto",                categoria = "COMBATE",  IDingame = 592, tags = { "death", "muerte", "morir", "caer" } },
    { anim = 18,  nombre = "Atacar 2M",    categoria = "COMBATE",  IDingame = 596, tags = { "attack", "2h", "estado" } },
    { anim = 9,   nombre = "Herida de Combate",     categoria = "COMBATE",  IDingame = 602, tags = { "wound", "herida", "combate" } },
    { anim = 24,  nombre = "Bloquear Escudo",       categoria = "COMBATE",  IDingame = 620, tags = { "block", "bloquear", "escudo" } },
    { anim = 16,  nombre = "Atacar Sin Arma Quieto",categoria = "COMBATE",  IDingame = 638, tags = { "attack", "sin arma", "quieto" } },
    { anim = 654,   nombre = "Golpear",      categoria = "COMBATE",  IDingame = 642, tags = { "slam", "aplastante", "golpe" } },
    { anim = 111,   nombre = "Sostener Arma en Alto",      categoria = "COMBATE",  IDingame = 643, tags = { "grab", "agarrar", "lanzar", "sostener arma en alto" } },
    { anim = 1068,   nombre = "Parada Dos Manos",     categoria = "COMBATE",  IDingame = 667, tags = { "2h", "bloquear", "dos manos", "parada", "parry" } },
    { anim = 728, nombre = "Canalizar",        categoria = "COMBATE",  IDingame = 705, tags = { "heal", "curar", "monje", "canal", "canalizar", "magia" } },
    { anim = 246,  nombre = "Atacar 1M",     categoria = "COMBATE",  IDingame = 458, tags = { "attack", "1h", "vuelo" } },
    { anim = 248,   nombre = "Ataque 2M",    categoria = "COMBATE",  IDingame = 526, tags = { "2h", "2m", "ataque", "attack", "dos manos" } },
    { anim = 336,   nombre = "Lanzar",        categoria = "COMBATE",  IDingame = 527, tags = { "throw", "lanzar", "vuelo" } },
    { anim = 238,   nombre = "Herida Combate", categoria = "COMBATE",  IDingame = 552, tags = { "wound", "herida", "vuelo" } },
    { anim = 16,   nombre = "Sin Arma Ataque Vuelo", categoria = "COMBATE",  IDingame = 554, tags = { "attack", "sin arma", "vuelo", "silencio" } },
    { anim = 107,   nombre = "Atacar Lanzado", categoria = "COMBATE",  IDingame = 537, tags = { "attack", "lanzado", "estado" } },
    { anim = 474,   nombre = "Estrangulándose",           categoria = "COMBATE",  IDingame = 472, tags = { "strangulate", "estrangular", "ahogar", "estrangulándose", "ahogaándose" } },
    { anim = 476,   nombre = "Sentado Arma Arriba",           categoria = "COMBATE",  IDingame = 471, tags = { "joust", "justa", "lanza", "sentado", "sentado arma arriba", "arma arriba", "caballero" } },
    { anim = 478,   nombre = "Sentado Arma al Frente",  categoria = "COMBATE",  IDingame = 475, tags = { "joust", "justa", "lanza", "sentado", "sentado arma al frente", "arma al frente", "caballero" } },
    { anim = 492,   nombre = "Vehículo Agarrar",      categoria = "COMBATE",  IDingame = 874, tags = { "vehicle", "agarrar", "vehiculo" } },
    { anim = 26,  nombre = "Listo 1M Mov.",         categoria = "COMBATE",  IDingame = 505, tags = { "ready", "1h", "movimiento" } },
    { anim = 27,  nombre = "Listo 2M Mov.",         categoria = "COMBATE",  IDingame = 506, tags = { "ready", "2h", "movimiento" } },
    { anim = 28,  nombre = "Preparado Arma Larga",        categoria = "COMBATE",  IDingame = 654, tags = { "ready", "2h", "largo", "arma larga", "preparado arma larga", "lanza", "bastón" } },
    { anim = 111,   nombre = "Lanza Preparada",  categoria = "COMBATE",  IDingame = 658, tags = { "hold", "thrown", "lanza preparada", "lanza", "apuntar" } },

    -- ════════════════════════════════════════════════════════
    -- DISTANCIA
    -- ════════════════════════════════════════════════════════
    { anim = 29,  nombre = "Sostener Arco",         categoria = "DISTANCIA",IDingame = 48,  tags = { "bow", "arco", "preparar", "apuntar", "sostener arco", "arco preparado", "apuntar" } },
    { anim = 48,  nombre = "Sostener Escopeta",        categoria = "DISTANCIA",IDingame = 213, tags = { "rifle", "arma", "preparar", "apuntar", "escopeta", "sostener escopeta", "sostener rifle", "coger" } },
    { anim = 109,  nombre = "Apuntar Arco",         categoria = "DISTANCIA",IDingame = 384, tags = { "hold", "arco", "sostener", "apuntar", "apuntar arco", "arco preparado", "cazar" } },
    { anim = 110,  nombre = "Apuntar Rifle",        categoria = "DISTANCIA",IDingame = 385, tags = { "hold", "rifle", "sostener" } },
    { anim = 46,  nombre = "Disparar Arco",         categoria = "DISTANCIA",IDingame = 435, tags = { "shoot", "arco", "disparar", "flecha" } },
    { anim = 49,  nombre = "Disparar Escopeta",        categoria = "DISTANCIA",IDingame = 436, tags = { "shoot", "rifle", "disparar" } },
    { anim = 54, nombre = "Conjuro",          categoria = "DISTANCIA",IDingame = 463, tags = { "spell", "omni", "canal", "magia", "castear", "canalizar" } },
    { anim = 108,   nombre = "Canalizar",          categoria = "DISTANCIA",IDingame = 465, tags = { "ready", "thrown", "lanzar", "preparado", "magia", "castear", "canalizar" } },
    { anim = 125, nombre = "Canalizar",            categoria = "DISTANCIA",IDingame = 468, tags = { "channel", "canal", "omni", "hechizo","mago", "magia", "castear", "canalizar" } },
    { anim = 124, nombre = "Canalizar",        categoria = "DISTANCIA",IDingame = 469, tags = { "channel", "canal", "dirigido", "hechizo","mago", "magia", "castear", "canalizar" } },
    { anim = 52, nombre = "Canalizar",    categoria = "DISTANCIA",IDingame = 474, tags = { "spell", "omni", "listo","mago", "magia", "castear", "canalizar", "hechizo" } },
    { anim = 280,   nombre = "Canalizar", categoria = "DISTANCIA",IDingame = 528, tags = { "spell", "dirigido", "vuelo","mago", "magia", "castear", "canalizar", "hechizo" } },
    { anim = 734,   nombre = "Aliento de Fuego",      categoria = "DISTANCIA",IDingame = 565, tags = { "fire", "fuego", "aliento", "dragon" } },
    { anim = 52, nombre = "Canalizar con Magia Arcana",   categoria = "DISTANCIA",IDingame = 645, tags = { "spell", "arcano", "magia arcana","mago", "magia", "castear", "canalizar", "hechizo" } },
    { anim = 1288,   nombre = "Lanzar Conjuro",      categoria = "DISTANCIA",IDingame = 894, tags = { "cast", "conjuro", "poderoso", "magia","mago", "magia", "castear", "canalizar", "hechizo"  } },
    { anim = 215,   nombre = "Colgando de Manos",       categoria = "ESTADO",IDingame = 404, tags = { "colgado", "atado", "prisionero", "colgando de manos", "crucificado", "crucifixión" } },
    { anim = 216,   nombre = "Tocar a la Puerta",       categoria = "TRABAJO",IDingame = 405, tags = { "tocar a la puerta", "golpear", "puerta", "llamar" } },

}

-- ============================================================
-- NPCAnimViewer.lua
-- Addon principal
-- ============================================================

local ASSETS = "Interface\\AddOns\\GMTools\\icons\\animviewer\\"

-- Las animaciones viven en este mismo archivo (tabla arriba).
local function getAnimaciones()
    return NPCAnimViewer_Animaciones or {}
end

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
-- CONSTANTES DE LAYOUT
-- ════════════════════════════════════════════════════════════
local NUM_COLS  = 4
local NUM_ROWS  = 2
local NUM_SLOTS = NUM_COLS * NUM_ROWS   -- 8 celdas visibles siempre
local PAD_SIDE  = 8
local PAD_TOP   = 8
local PAD_ROW   = 8
local PAD_BOT   = 10
local SEARCH_H  = 32
local BOTTOM_H  = 36
local LABEL_H   = 44   -- nombre (16) + gap (4) + botones (24)
local WIN_H     = 700
local WIN_W     = 1000
local AVAIL_H   = WIN_H - PAD_SIDE - SEARCH_H - PAD_TOP - PAD_ROW - PAD_BOT
                  - BOTTOM_H - PAD_SIDE - math.floor(BOTTOM_H / 2)
local CELL_H    = math.floor(AVAIL_H / NUM_ROWS)
local MODEL_H   = CELL_H - LABEL_H - 4
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
local mostrarSoloFavs = false
local aplicarFiltros -- se define más abajo; los botones la usan en clic

-- ════════════════════════════════════════════════════════════
-- FAVORITOS (persistentes en SavedVariables GMToolsAnimFavoritos)
-- ════════════════════════════════════════════════════════════
GMToolsAnimFavoritos = GMToolsAnimFavoritos or {}

local FAV_OFF = ASSETS .. "Fav-off"
local FAV_HOV = ASSETS .. "fav-hov"
local FAV_ON  = ASSETS .. "fav-on"

local function claveFav(entrada)
    if entrada.IDingame then
        return "id:" .. tostring(entrada.IDingame)
    end
    return "k:" .. tostring(entrada.categoria) .. "|" .. tostring(entrada.anim) .. "|" .. tostring(entrada.nombre)
end

local function esFavorito(entrada)
    if not entrada then return false end
    return GMToolsAnimFavoritos[claveFav(entrada)] == true
end

local function setFavorito(entrada, on)
    if not entrada then return end
    local k = claveFav(entrada)
    if on then
        GMToolsAnimFavoritos[k] = true
    else
        GMToolsAnimFavoritos[k] = nil
    end
end

local function pintarFav(btn, fav)
    if fav then
        btn.icono:SetTexture(FAV_ON)
    else
        btn.icono:SetTexture(FAV_OFF)
    end
end

-- Constantes de botones de categoría (necesarias también para las flechas)
local CAT_W, CAT_H, CAT_GAP = 90, 34, 6

local function totalPaginas()
    return math.max(1, math.ceil(#listaActiva / NUM_SLOTS))
end

-- ════════════════════════════════════════════════════════════
-- VENTANA PRINCIPAL
-- ════════════════════════════════════════════════════════════
local ventana = CreateFrame("Frame", "NPCAnimViewerFrame", UIParent, "BackdropTemplate")
ventana:SetSize(WIN_W, WIN_H)
local izq = GMToolsFrame
if izq then
    ventana:SetPoint("BOTTOM", izq, "TOP", 0, 5)
else
    ventana:SetPoint("CENTER")
end
ApplyDarkPanel(ventana)
ventana:EnableMouse(true)
ventana:SetMovable(true)
ventana:RegisterForDrag("LeftButton")
ventana:SetScript("OnDragStart", ventana.StartMoving)
ventana:SetScript("OnDragStop",  ventana.StopMovingOrSizing)
ventana:Hide()

-- ════════════════════════════════════════════════════════════
-- BARRA DE BÚSQUEDA
-- ════════════════════════════════════════════════════════════
local searchRow = CreateFrame("Frame", nil, ventana, "BackdropTemplate")
searchRow:SetHeight(SEARCH_H)
searchRow:SetPoint("TOPLEFT",  ventana, "TOPLEFT",   PAD_SIDE, -PAD_SIDE)
searchRow:SetPoint("TOPRIGHT", ventana, "TOPRIGHT", -PAD_SIDE, -PAD_SIDE)
ApplyDarkPanel(searchRow)
searchRow:SetBackdropColor(0.1, 0.11, 0.15, 0.9)

local inputBusqueda = CreateFrame("EditBox", "NPCAnimViewerInput", searchRow, "InputBoxTemplate")
inputBusqueda:SetHeight(22)
inputBusqueda:SetPoint("LEFT",  searchRow, "LEFT",   10,  0)
inputBusqueda:SetPoint("RIGHT", searchRow, "CENTER", -5,  0)
inputBusqueda:SetAutoFocus(false)
inputBusqueda:SetFontObject("GameFontHighlight")

local placeholder = searchRow:CreateFontString(nil, "OVERLAY", "GameFontDisable")
placeholder:SetPoint("LEFT", inputBusqueda, "LEFT", 2, 0)
placeholder:SetText("Buscar animación...")
inputBusqueda:HookScript("OnTextChanged",    function(self) placeholder:SetShown(self:GetText() == "") end)
inputBusqueda:HookScript("OnEditFocusGained",function()     placeholder:Hide() end)
inputBusqueda:HookScript("OnEditFocusLost",  function(self) placeholder:SetShown(self:GetText() == "") end)

local botonBuscar = CreateFrame("Button", nil, searchRow)
botonBuscar:SetSize(30, 30)
botonBuscar:SetPoint("LEFT", searchRow, "CENTER", 4, 0)
local iconSearch = botonBuscar:CreateTexture(nil, "ARTWORK")
iconSearch:SetAllPoints()
iconSearch:SetTexture(ASSETS .. "EpsiIndexSearch")
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
closeButton:SetScript("OnClick", function() ventana:Hide() end)

-- Botón "Editar NPC" — junto a la X
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
labelEditar:SetText("Editar NPC")
labelEditar:SetTextColor(1, 0.85, 0)

botonEditar:SetScript("OnClick", function()
    ventana:Hide()
    if PhaseToolkit and PhaseToolkit.NPCCustomiserMainFrame then
        pcall(function()
            if not PhaseToolkit.NPCCustomiserMainFrame:IsShown() then
                PhaseToolkit.ToggleMainFrame()
            end
            -- Mismo comportamiento que el primer botón de la izquierda
            -- de Phase Toolkit (NPC Forge, que abre la edición de NPCs)
            if PhaseToolkit.context and PhaseToolkit.context.id ~= "NPCFORGE" then
                PhaseToolkit.hideContext()
                PhaseToolkit.DeployingFrame.isDeployed = false
            end
            if PhaseToolkit.OpenNpcForge then
                PhaseToolkit.OpenNpcForge()
            end
        end)
    end
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

-- Botón "Eliminar Animación" — a la izquierda de Editar NPC
local wrapperEliminar = CreateFrame("Frame", nil, searchRow, "BackdropTemplate")
wrapperEliminar:SetSize(110 + 4, SEARCH_H - 6)
wrapperEliminar:SetPoint("RIGHT", wrapperEditar, "LEFT", -6, 0)
wrapperEliminar:SetBackdrop({
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 2,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
wrapperEliminar:SetBackdropBorderColor(0, 0, 0, 0)

local botonEliminar = CreateFrame("Button", nil, wrapperEliminar, "BackdropTemplate")
botonEliminar:SetSize(110, math.floor((SEARCH_H - 10) * 0.9))
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
labelEliminar:SetText("Eliminar Animación")
labelEliminar:SetTextColor(1, 0.85, 0)

botonEliminar:SetScript("OnClick", function()
    SendChatMessage(".npc emote 0 repeat", "SAY")
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

-- Botón "Favoritos" — a la izquierda de Eliminar Animación
-- (igual tamaño y misma separación de 6px que con Editar NPC).
-- Al darle, filtra solo los marcados con la estrella.
local wrapperFavs = CreateFrame("Frame", nil, searchRow, "BackdropTemplate")
wrapperFavs:SetSize(110 + 4, SEARCH_H - 6)
wrapperFavs:SetPoint("RIGHT", wrapperEliminar, "LEFT", -6, 0)
wrapperFavs:SetBackdrop({
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 2,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
wrapperFavs:SetBackdropBorderColor(0, 0, 0, 0)

local botonFavs = CreateFrame("Button", nil, wrapperFavs, "BackdropTemplate")
botonFavs:SetSize(110, math.floor((SEARCH_H - 10) * 0.9))
botonFavs:SetPoint("CENTER", wrapperFavs, "CENTER", 0, 0)
botonFavs:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true, tileSize = 16, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
botonFavs:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
botonFavs:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)

local labelFavs = botonFavs:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
labelFavs:SetPoint("CENTER", botonFavs, "CENTER", 0, 0)
labelFavs:SetText("Favoritos")
labelFavs:SetTextColor(1, 0.85, 0)

local function pintarFiltroFavs()
    if mostrarSoloFavs then
        botonFavs:SetBackdropColor(0.2, 0.3, 0.55, 0.95)
        botonFavs:SetBackdropBorderColor(0.9, 0.75, 0.1, 1)
        wrapperFavs:SetBackdropBorderColor(0.9, 0.75, 0.1, 1)
    else
        botonFavs:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
        botonFavs:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
        wrapperFavs:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

botonFavs:SetScript("OnClick", function()
    mostrarSoloFavs = not mostrarSoloFavs
    pintarFiltroFavs()
    aplicarFiltros()
end)
botonFavs:SetScript("OnEnter", function(self)
    self:SetBackdropColor(0.2, 0.3, 0.55, 0.95)
    self:SetBackdropBorderColor(0.5, 0.75, 1, 1)
end)
botonFavs:SetScript("OnLeave", function(self)
    pintarFiltroFavs()
end)

-- ════════════════════════════════════════════════════════════
-- ANIMACIÓN EN BUCLE
-- ════════════════════════════════════════════════════════════
local function configurarModelo(m, animID)
    m:SetScript("OnAnimFinished", function(self) self:SetAnimation(animID) end)
    m:SetScript("OnModelLoaded",  function(self) self:SetAnimation(animID) end)
    m:SetAnimation(animID)
end

-- ════════════════════════════════════════════════════════════
-- 8 CELDAS FIJAS (slots reutilizables)
-- ════════════════════════════════════════════════════════════
local slots = {}

for i = 1, NUM_SLOTS do
    local col  = ((i - 1) % NUM_COLS) + 1
    local fila = math.floor((i - 1) / NUM_COLS)
    local anchorY = -PAD_TOP - fila * (CELL_H + PAD_ROW)

    local cell = CreateFrame("Frame", nil, ventana)
    cell:SetSize(MODEL_W, CELL_H)
    cell:SetPoint("TOP", searchRow, "BOTTOM", cellX(col), anchorY)
    cell:Hide()

    local m = CreateFrame("PlayerModel", nil, cell)
    m:SetSize(MODEL_W, MODEL_H)
    m:SetPoint("TOP", cell, "TOP", 0, 0)
    m:SetFacing(0)
    m:SetPosition(0, 0, 0)

    -- Nombre en texto plano, sin fondo
    local etiqueta = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    etiqueta:SetPoint("BOTTOM", cell, "BOTTOM", 0, math.floor(((LABEL_H + 6) + 4) * 0.7))
    etiqueta:SetTextColor(1, 1, 1)

    -- Botón NPC (izquierda)
    local BTN_W = math.floor((MODEL_W - 20) / 4 - 3)
    local BTN_H = math.floor((LABEL_H + 2) / 2)
    BTN_W = math.floor(BTN_W * 1.2)
    BTN_H = math.floor(BTN_H * 1.2)
    local BTN_GAP = 4

    -- Botón NPC (izquierda, centrado)
    local btnNPC = CreateFrame("Button", nil, cell, "BackdropTemplate")
    btnNPC:SetSize(BTN_W, BTN_H)
    btnNPC:SetPoint("BOTTOM", cell, "BOTTOM", -(BTN_W / 2 + BTN_GAP / 2), 4)
    btnNPC:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    btnNPC:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
    btnNPC:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    local labelNPC = btnNPC:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    labelNPC:SetPoint("CENTER")
    labelNPC:SetTextColor(1, 1, 1)
    labelNPC:SetText("NPC")
    btnNPC:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.2, 0.3, 0.55, 0.95)
        self:SetBackdropBorderColor(0.5, 0.75, 1, 1)
        labelNPC:SetTextColor(1, 1, 1)
    end)
    btnNPC:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
        self:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
        labelNPC:SetTextColor(1, 1, 1)
    end)

    -- Botón Jugador (derecha, centrado)
    local btnJugador = CreateFrame("Button", nil, cell, "BackdropTemplate")
    btnJugador:SetSize(BTN_W, BTN_H)
    btnJugador:SetPoint("BOTTOM", cell, "BOTTOM", (BTN_W / 2 + BTN_GAP / 2), 4)
    btnJugador:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    btnJugador:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
    btnJugador:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    local labelJugador = btnJugador:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    labelJugador:SetPoint("CENTER")
    labelJugador:SetTextColor(1, 1, 1)
    labelJugador:SetText("Jugador")
    btnJugador:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.2, 0.3, 0.55, 0.95)
        self:SetBackdropBorderColor(0.5, 0.75, 1, 1)
        labelJugador:SetTextColor(1, 1, 1)
    end)
    btnJugador:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.1, 0.11, 0.15, 0.9)
        self:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
        labelJugador:SetTextColor(1, 1, 1)
    end)

    -- Botón favorito: cuadrado de 24x24,
    -- anclado a la esquina superior derecha de Jugador (+5px, -2px).
    local FAV_S = 24
    local btnFav = CreateFrame("Button", nil, cell)
    btnFav:SetSize(FAV_S, FAV_S)
    btnFav:SetPoint("TOPLEFT", btnJugador, "TOPRIGHT", 5, -2)
    local iconFav = btnFav:CreateTexture(nil, "OVERLAY")
    iconFav:SetAllPoints()
    iconFav:SetTexture(FAV_OFF)
    btnFav.icono = iconFav
    btnFav.favMarcado = false
    btnFav:SetScript("OnEnter", function(self)
        if not self.favMarcado then
            iconFav:SetTexture(FAV_HOV)
        end
    end)
    btnFav:SetScript("OnLeave", function(self)
        if self.favMarcado then
            iconFav:SetTexture(FAV_ON)
        else
            iconFav:SetTexture(FAV_OFF)
        end
    end)

    slots[i] = { cell = cell, model = m, etiqueta = etiqueta, btnNPC = btnNPC, btnJugador = btnJugador, btnFav = btnFav }
end

-- ════════════════════════════════════════════════════════════
-- FUNCIÓN PARA POBLAR LOS SLOTS CON UNA PÁGINA
-- ════════════════════════════════════════════════════════════
local function mostrarPagina(lista, pagina)
    paginaActual = pagina
    local inicio = (pagina - 1) * NUM_SLOTS + 1
    for i = 1, NUM_SLOTS do
        local slot    = slots[i]
        local entrada = lista[inicio + i - 1]
        if entrada then
            slot.model:SetUnit("player")
            configurarModelo(slot.model, entrada.anim)
            slot.etiqueta:SetText(entrada.nombre)

            local id = entrada.IDingame
            slot.btnNPC:SetScript("OnClick", function()
                if id then
                    SendChatMessage(".npc emote " .. id .. " repeat", "SAY")
                else
                    print("NPCAnimViewer | IDingame no definida para: " .. entrada.nombre)
                end
            end)
            slot.btnJugador:SetScript("OnClick", function()
                if id then
                    SendChatMessage(".mod stand " .. id, "SAY")
                else
                    print("NPCAnimViewer | IDingame no definida para: " .. entrada.nombre)
                end
            end)

            local fav = esFavorito(entrada)
            slot.btnFav.favMarcado = fav
            pintarFav(slot.btnFav, fav)
            slot.btnFav:SetScript("OnClick", function()
                local ahora = not esFavorito(entrada)
                setFavorito(entrada, ahora)
                slot.btnFav.favMarcado = ahora
                pintarFav(slot.btnFav, ahora)
                if mostrarSoloFavs then
                    aplicarFiltros()
                end
            end)

            slot.cell:Show()
        else
            slot.cell:Hide()
        end
    end
    if labelPagina then
        labelPagina:SetText("Página " .. pagina .. "/" .. totalPaginas())
    end
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

-- Pool base: todas las anims o solo las de categorías activas,
-- y si el filtro de favoritos está activo, solo las marcadas.
local function getPoolBase()
    local todas = getAnimaciones()
    local pool = todas
    if hayCategoriaActiva() then
        local filtradas = {}
        for _, entrada in ipairs(todas) do
            if categoriasActivas[entrada.categoria] then
                table.insert(filtradas, entrada)
            end
        end
        pool = filtradas
    end
    if mostrarSoloFavs then
        local solo = {}
        for _, entrada in ipairs(pool) do
            if esFavorito(entrada) then
                table.insert(solo, entrada)
            end
        end
        pool = solo
    end
    return pool
end

local function ejecutarBusqueda(texto)
    local busqueda = texto:lower():gsub("^%s+", ""):gsub("%s+$", "")
    local pool = getPoolBase()
    if busqueda == "" then
        listaActiva = pool
    else
        local resultados = {}
        for _, entrada in ipairs(pool) do
            if coincideConBusqueda(entrada, busqueda) then
                table.insert(resultados, entrada)
            end
        end
        if #resultados == 0 then
            print("NPCAnimViewer | No encontrado: " .. texto)
            return
        end
        listaActiva = resultados
    end
    mostrarPagina(listaActiva, 1)
end

aplicarFiltros = function()
    ejecutarBusqueda(inputBusqueda:GetText())
end

inputBusqueda:SetScript("OnEnterPressed", function(self)
    ejecutarBusqueda(self:GetText())
    self:ClearFocus()
end)
botonBuscar:SetScript("OnClick", function()
    ejecutarBusqueda(inputBusqueda:GetText())
end)
inputBusqueda:HookScript("OnTextChanged", function(self, userInput)
    if userInput then ejecutarBusqueda(self:GetText()) end
end)

-- ════════════════════════════════════════════════════════════
-- BARRA INFERIOR (transparente) + FLECHAS + CATEGORÍAS
-- ════════════════════════════════════════════════════════════
local bottomBar = CreateFrame("Frame", nil, ventana, "BackdropTemplate")
bottomBar:SetHeight(BOTTOM_H)
bottomBar:SetPoint("BOTTOMLEFT",  ventana, "BOTTOMLEFT",   PAD_SIDE, PAD_SIDE + 10)
bottomBar:SetPoint("BOTTOMRIGHT", ventana, "BOTTOMRIGHT", -PAD_SIDE, PAD_SIDE + 10)
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
end)

-- Etiqueta de página — a la izquierda de la flecha derecha
labelPagina = bottomBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
labelPagina:SetPoint("RIGHT", botonNext, "LEFT", -8, 0)
labelPagina:SetTextColor(0.75, 0.9, 1)
labelPagina:SetText("Página 1/1")

-- Categorías con toggle — mismo estilo que botones de animación
local categoriasBottom = { "Sociales", "Sentado", "Erguido", "Estado", "Trabajo", "Combate", "Distancia" }
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
ventana:SetScript("OnShow", function()
    if #getAnimaciones() == 0 then
        print("NPCAnimViewer | ERROR: NPCAnimViewer_Animaciones está vacío o no cargado.")
        return
    end
    -- Reaplica la búsqueda que siga en la caja (si hay texto, filtra).
    aplicarFiltros()
end)

-- ════════════════════════════════════════════════════════════
-- COMANDOS DE CHAT
-- ════════════════════════════════════════════════════════════
SLASH_NPCANIMVIEWER1 = "/animacion"
SLASH_NPCANIMVIEWER2 = "/anim"

SlashCmdList["NPCANIMVIEWER"] = function()
    if ventana:IsShown() then
        ventana:Hide()
    else
        ventana:Show()
    end
end
