/*
	* Dye Registry
	*
	* This is the easiest way to expand the range of dyeable clothes in-game.
	* Adding an entry to one of the registry lists allows all types with that dyeing_key to
	* be dyed to one of the included paths (given a specific dye key) unless otherwise precluded
	* by setting dyeable to FALSE
	*
	* For example, /obj/item/clothing/under dyeing_key is set to
*/


//dye registry, add dye colors and their resulting output here if you want the sprite to change
GLOBAL_LIST_INIT(dye_registry, list(
	DYE_REGISTRY_UNDER = list(
		DYE_RED = /obj/item/clothing/under/color/red,
		DYE_ORANGE = /obj/item/clothing/under/color/orange,
		DYE_YELLOW = /obj/item/clothing/under/color/yellow,
		DYE_GREEN = /obj/item/clothing/under/color/green,
		DYE_BLUE = /obj/item/clothing/under/color/blue,
		DYE_PURPLE = /obj/item/clothing/under/color/lightpurple,
		DYE_BLACK = /obj/item/clothing/under/color/black,
		DYE_WHITE = /obj/item/clothing/under/color/white,
		DYE_RAINBOW = /obj/item/clothing/under/color/rainbow,
		DYE_MIME = /obj/item/clothing/under/rank/civilian/mime,
		DYE_CLOWN = /obj/item/clothing/under/rank/civilian/clown,
		DYE_QM = /obj/item/clothing/under/rank/cargo/qm,
		DYE_LAW = /obj/item/clothing/under/suit/black,
		DYE_CAPTAIN = /obj/item/clothing/under/rank/captain,
		DYE_HOP = /obj/item/clothing/under/rank/civilian/hop,
		DYE_HOS = /obj/item/clothing/under/rank/security/head_of_security,
		DYE_CE = /obj/item/clothing/under/rank/engineering/chief_engineer,
		DYE_RD = /obj/item/clothing/under/rank/rnd/rd,
		DYE_CMO = /obj/item/clothing/under/rank/medical/cmo,
		DYE_SYNDICATE = /obj/item/clothing/under/syndicate,
		DYE_CENTCOM = /obj/item/clothing/under/rank/centcom/commander,
	),
	DYE_REGISTRY_JUMPSKIRT = list(
		DYE_RED = /obj/item/clothing/under/color/jumpskirt/red,
		DYE_ORANGE = /obj/item/clothing/under/color/jumpskirt/orange,
		DYE_YELLOW = /obj/item/clothing/under/color/jumpskirt/yellow,
		DYE_GREEN = /obj/item/clothing/under/color/jumpskirt/green,
		DYE_BLUE = /obj/item/clothing/under/color/jumpskirt/blue,
		DYE_PURPLE = /obj/item/clothing/under/color/jumpskirt/lightpurple,
		DYE_BLACK = /obj/item/clothing/under/color/jumpskirt/black,
		DYE_WHITE = /obj/item/clothing/under/color/jumpskirt/white,
		DYE_RAINBOW = /obj/item/clothing/under/color/jumpskirt/rainbow,
		DYE_MIME = /obj/item/clothing/under/rank/civilian/mime/skirt,
		DYE_QM = /obj/item/clothing/under/rank/cargo/qm/skirt,
		DYE_CAPTAIN = /obj/item/clothing/under/rank/captain/skirt,
		DYE_HOP = /obj/item/clothing/under/rank/civilian/hop/skirt,
		DYE_HOS = /obj/item/clothing/under/rank/security/head_of_security/skirt,
		DYE_CE = /obj/item/clothing/under/rank/engineering/chief_engineer/skirt,
		DYE_RD = /obj/item/clothing/under/rank/rnd/rd/skirt,
		DYE_CMO = /obj/item/clothing/under/rank/medical/cmo/skirt,
	),
	DYE_REGISTRY_GLOVES = list(
		DYE_RED = /obj/item/clothing/gloves/color/red,
		DYE_ORANGE = /obj/item/clothing/gloves/color/orange,
		DYE_YELLOW = /obj/item/clothing/gloves/color/yellow,
		DYE_GREEN = /obj/item/clothing/gloves/color/green,
		DYE_BLUE = /obj/item/clothing/gloves/color/blue,
		DYE_PURPLE = /obj/item/clothing/gloves/color/purple,
		DYE_BLACK = /obj/item/clothing/gloves/color/black,
		DYE_WHITE = /obj/item/clothing/gloves/color/white,
		DYE_RAINBOW = /obj/item/clothing/gloves/color/rainbow,
		DYE_MIME = /obj/item/clothing/gloves/color/white,
		DYE_CLOWN = /obj/item/clothing/gloves/color/rainbow,
		DYE_QM = /obj/item/clothing/gloves/color/brown,
		DYE_CAPTAIN = /obj/item/clothing/gloves/color/blue,
		DYE_HOP = /obj/item/clothing/gloves/color/grey,
		DYE_HOS = /obj/item/clothing/gloves/color/black,
		DYE_CE = /obj/item/clothing/gloves/color/yellow,
		DYE_RD = /obj/item/clothing/gloves/color/grey,
		DYE_CMO = /obj/item/clothing/gloves/color/blue,
		DYE_SYNDICATE = /obj/item/clothing/gloves/combat,
		DYE_CENTCOM = /obj/item/clothing/gloves/combat
	),
	DYE_REGISTRY_BANDANA = list(
		DYE_RED = /obj/item/clothing/mask/bandana/red,
		DYE_ORANGE = /obj/item/clothing/mask/bandana/orange,
		DYE_YELLOW = /obj/item/clothing/mask/bandana/gold,
		DYE_GREEN = /obj/item/clothing/mask/bandana/green,
		DYE_BLUE = /obj/item/clothing/mask/bandana/blue,
		DYE_PURPLE = /obj/item/clothing/mask/bandana/purple,
		DYE_BLACK = /obj/item/clothing/mask/bandana/black,
	),
	DYE_REGISTRY_BEANIE = list(
		DYE_BLACK = /obj/item/clothing/head/beanie/black,
		DYE_WHITE = /obj/item/clothing/head/beanie,
		DYE_RED = /obj/item/clothing/head/beanie/red,
		DYE_GREEN = /obj/item/clothing/head/beanie/green,
		DYE_CAPTAIN = /obj/item/clothing/head/beanie/darkblue,
		DYE_NTREP = /obj/item/clothing/head/beanie/darkblue,
		DYE_PURPLE = /obj/item/clothing/head/beanie/purple,
		DYE_RD = /obj/item/clothing/head/beanie/purple,
		DYE_YELLOW = /obj/item/clothing/head/beanie/yellow,
		DYE_CE = /obj/item/clothing/head/beanie/orange,
		DYE_ORANGE = /obj/item/clothing/head/beanie/orange,
		DYE_CMO = /obj/item/clothing/head/beanie/cyan,
		DYE_BLUE = /obj/item/clothing/head/beanie/cyan,


	),
	DYE_REGISTRY_SHOES = list(
		DYE_RED = /obj/item/clothing/shoes/red,
		DYE_ORANGE = /obj/item/clothing/shoes/orange,
		DYE_YELLOW = /obj/item/clothing/shoes/yellow,
		DYE_GREEN = /obj/item/clothing/shoes/green,
		DYE_BLUE = /obj/item/clothing/shoes/blue,
		DYE_PURPLE = /obj/item/clothing/shoes/purple,
		DYE_BLACK = /obj/item/clothing/shoes/black,
		DYE_WHITE = /obj/item/clothing/shoes/white,
		DYE_RAINBOW = /obj/item/clothing/shoes/rainbow,
		DYE_MIME = /obj/item/clothing/shoes/black,
		DYE_CLOWN = /obj/item/clothing/shoes/rainbow,
		DYE_QM = /obj/item/clothing/shoes/brown,
		DYE_CAPTAIN = /obj/item/clothing/shoes/brown,
		DYE_HOP = /obj/item/clothing/shoes/brown,
		DYE_CE = /obj/item/clothing/shoes/brown,
		DYE_RD = /obj/item/clothing/shoes/brown,
		DYE_CMO = /obj/item/clothing/shoes/brown,
		DYE_SYNDICATE = /obj/item/clothing/shoes/combat,
		DYE_CENTCOM = /obj/item/clothing/shoes/combat
	),
	DYE_REGISTRY_FANNYPACK = list(
		DYE_RED = /obj/item/storage/belt/fannypack/red,
		DYE_ORANGE = /obj/item/storage/belt/fannypack/orange,
		DYE_YELLOW = /obj/item/storage/belt/fannypack/yellow,
		DYE_GREEN = /obj/item/storage/belt/fannypack/green,
		DYE_BLUE = /obj/item/storage/belt/fannypack/blue,
		DYE_PURPLE = /obj/item/storage/belt/fannypack/purple,
		DYE_BLACK = /obj/item/storage/belt/fannypack/black,
		DYE_WHITE = /obj/item/storage/belt/fannypack/white,
		DYE_SYNDICATE = /obj/item/storage/belt/military
	),
	DYE_REGISTRY_BEDSHEET = list(
		DYE_RED = /obj/item/bedsheet/red,
		DYE_ORANGE = /obj/item/bedsheet/orange,
		DYE_YELLOW = /obj/item/bedsheet/yellow,
		DYE_GREEN = /obj/item/bedsheet/green,
		DYE_BLUE = /obj/item/bedsheet/blue,
		DYE_PURPLE = /obj/item/bedsheet/purple,
		DYE_BLACK = /obj/item/bedsheet/black,
		DYE_WHITE = /obj/item/bedsheet,
		DYE_RAINBOW = /obj/item/bedsheet/rainbow,
		DYE_MIME = /obj/item/bedsheet/mime,
		DYE_CLOWN = /obj/item/bedsheet/clown,
		DYE_QM = /obj/item/bedsheet/qm,
		DYE_LAW = /obj/item/bedsheet/black,
		DYE_CAPTAIN = /obj/item/bedsheet/captain,
		DYE_HOP = /obj/item/bedsheet/hop,
		DYE_HOS = /obj/item/bedsheet/hos,
		DYE_CE = /obj/item/bedsheet/ce,
		DYE_RD = /obj/item/bedsheet/rd,
		DYE_CMO = /obj/item/bedsheet/cmo,
		DYE_SYNDICATE = /obj/item/bedsheet/syndie,
		DYE_CENTCOM = /obj/item/bedsheet/centcom
	),
	DYE_REGISTRY_BOMBER = list(
		DYE_RED = /obj/item/clothing/suit/jacket/bomber/sec,
		DYE_ORANGE = /obj/item/clothing/suit/jacket/bomber/chem,
		DYE_YELLOW = /obj/item/clothing/suit/jacket/bomber/engi,
		DYE_GREEN = /obj/item/clothing/suit/jacket/bomber/hydro,
		DYE_BLUE = /obj/item/clothing/suit/jacket/bomber/atmos,
		DYE_PURPLE = /obj/item/clothing/suit/jacket/bomber/sci,
		DYE_BLACK = /obj/item/clothing/suit/jacket/bomber/coroner,
		DYE_WHITE = /obj/item/clothing/suit/jacket/bomber/med,
		DYE_SYNDICATE = /obj/item/clothing/suit/jacket/bomber/syndicate
	),
	DYE_REGISTRY_PLASMAMEN = list(
		DYE_RED = /obj/item/clothing/under/plasmaman/security,
		DYE_ORANGE = /obj/item/clothing/under/plasmaman,
		DYE_YELLOW = /obj/item/clothing/under/plasmaman/engineering,
		DYE_GREEN = /obj/item/clothing/under/plasmaman/botany,
		DYE_BLUE = /obj/item/clothing/under/plasmaman/atmospherics,
		DYE_PURPLE = /obj/item/clothing/under/plasmaman/janitor,
		DYE_BLACK = /obj/item/clothing/under/plasmaman/robotics,
		DYE_WHITE = /obj/item/clothing/under/plasmaman/chef,
		DYE_MIME = /obj/item/clothing/under/plasmaman/mime,
		DYE_CLOWN = /obj/item/clothing/under/plasmaman/clown,
		DYE_QM = /obj/item/clothing/under/plasmaman/cargo,
		DYE_LAW = /obj/item/clothing/under/plasmaman/security/warden,
		DYE_CAPTAIN = /obj/item/clothing/under/plasmaman/captain,
		DYE_HOP = /obj/item/clothing/under/plasmaman/hop,
		DYE_HOS =/obj/item/clothing/under/plasmaman/security/hos,
		DYE_CE = /obj/item/clothing/under/plasmaman/engineering/ce,
		DYE_RD = /obj/item/clothing/under/plasmaman/rd,
		DYE_CMO = /obj/item/clothing/under/plasmaman/cmo,
	),
	DYE_REGISTRY_PLASMAMEN_HELMET = list(
		DYE_RED = /obj/item/clothing/head/helmet/space/plasmaman/security,
		DYE_ORANGE = /obj/item/clothing/head/helmet/space/plasmaman,
		DYE_YELLOW = /obj/item/clothing/head/helmet/space/plasmaman/engineering,
		DYE_GREEN = /obj/item/clothing/head/helmet/space/plasmaman/botany,
		DYE_BLUE = /obj/item/clothing/head/helmet/space/plasmaman/atmospherics,
		DYE_PURPLE = /obj/item/clothing/head/helmet/space/plasmaman/janitor,
		DYE_BLACK = /obj/item/clothing/head/helmet/space/plasmaman/robotics,
		DYE_WHITE = /obj/item/clothing/head/helmet/space/plasmaman/chef,
		DYE_MIME = /obj/item/clothing/head/helmet/space/plasmaman/mime,
		DYE_CLOWN = /obj/item/clothing/head/helmet/space/plasmaman/clown,
		DYE_QM = /obj/item/clothing/head/helmet/space/plasmaman/cargo,
		DYE_LAW = /obj/item/clothing/head/helmet/space/plasmaman/security/warden,
		DYE_CAPTAIN = /obj/item/clothing/head/helmet/space/plasmaman/captain,
		DYE_HOP = /obj/item/clothing/head/helmet/space/plasmaman/hop,
		DYE_HOS =/obj/item/clothing/head/helmet/space/plasmaman/security/hos,
		DYE_CE = /obj/item/clothing/head/helmet/space/plasmaman/engineering/ce,
		DYE_RD = /obj/item/clothing/head/helmet/space/plasmaman/rd,
		DYE_CMO = /obj/item/clothing/head/helmet/space/plasmaman/cmo,
	),
	DYE_REGISTRY_VOID_SUIT = list(
		DYE_RED = /obj/item/clothing/suit/space/void,
		DYE_GREEN = /obj/item/clothing/suit/space/void/green,
		DYE_BLUE = /obj/item/clothing/suit/space/void/ltblue,
		DYE_PURPLE = /obj/item/clothing/suit/space/void/purple,
		DYE_YELLOW = /obj/item/clothing/suit/space/void/yellow,
		DYE_CAPTAIN = /obj/item/clothing/suit/space/void/captain,
		DYE_SYNDICATE = /obj/item/clothing/suit/space/void/syndi,
		DYE_HOP = /obj/item/clothing/suit/space/void/ntblue,
		DYE_NTREP = /obj/item/clothing/suit/space/void/ntblue,
	),
	DYE_REGISTRY_VOID_HELMET = list(
		DYE_RED = /obj/item/clothing/head/helmet/space/void,
		DYE_GREEN = /obj/item/clothing/head/helmet/space/void/green,
		DYE_BLUE = /obj/item/clothing/head/helmet/space/void/ltblue,
		DYE_PURPLE = /obj/item/clothing/head/helmet/space/void/purple,
		DYE_YELLOW = /obj/item/clothing/head/helmet/space/void/yellow,
		DYE_CAPTAIN = /obj/item/clothing/head/helmet/space/void/captain,
		DYE_SYNDICATE = /obj/item/clothing/head/helmet/space/void/syndi,
		DYE_HOP = /obj/item/clothing/head/helmet/space/void/ntblue,
		DYE_NTREP = /obj/item/clothing/head/helmet/space/void/ntblue,
	),
	DYE_REGISTRY_SYNDICATE_SUIT = list(
		DYE_RED = /obj/item/clothing/suit/space/syndicate,
		DYE_GREEN = /obj/item/clothing/suit/space/syndicate/green,
		DYE_ORANGE = /obj/item/clothing/suit/space/syndicate/orange,
		DYE_BLUE = /obj/item/clothing/suit/space/syndicate/blue,
		DYE_YELLOW = /obj/item/clothing/suit/space/syndicate/black/engie,
		DYE_BLACK = /obj/item/clothing/suit/space/syndicate/black,
		DYE_CMO = /obj/item/clothing/suit/space/syndicate/black/med,
		DYE_CE = /obj/item/clothing/suit/space/syndicate/black/engie,
		DYE_NTREP = /obj/item/clothing/suit/space/syndicate/blue,
	),
	DYE_REGISTRY_SYNDICATE_HELMET = list(
		DYE_RED = /obj/item/clothing/head/helmet/space/syndicate,
		DYE_GREEN = /obj/item/clothing/head/helmet/space/syndicate/green,
		DYE_ORANGE = /obj/item/clothing/head/helmet/space/syndicate/orange,
		DYE_BLUE = /obj/item/clothing/head/helmet/space/syndicate/blue,
		DYE_YELLOW = /obj/item/clothing/head/helmet/space/syndicate/black/engie,
		DYE_BLACK = /obj/item/clothing/head/helmet/space/syndicate/black,
		DYE_CMO = /obj/item/clothing/head/helmet/space/syndicate/black/med,
		DYE_CE = /obj/item/clothing/head/helmet/space/syndicate/black/engie,
		DYE_NTREP = /obj/item/clothing/head/helmet/space/syndicate/blue,
	),
))

// Palettes for clothing
#define PALETTE_JS_RED list("#570a2c", "#9a162f", "#cb2831", "#ee493e")
#define PALETTE_JS_ORANGE list("#88141b", "#c03622", "#dc6720", "#f58c30")
#define PALETTE_JS_YELLOW list("#a15426", "#ce872d", "#eeb539", "#f5da68")
#define PALETTE_JS_GREEN list("#1c3b36", "#206937", "#398f21", "#64b236")
#define PALETTE_JS_BLUE list("#1c1f62", "#21438f", "#225fb6", "#287fd5")
#define PALETTE_JS_PURPLE list("#281e54", "#4c3088", "#7f3fc4", "#a25ace")
#define PALETTE_JS_BLACK list("#171516", "#20232d", "#303546", "#505564")
#define PALETTE_JS_WHITE list("#6f6f75", "#9da3a3", "#caccca", "#f0efed")
#define PALETTE_JS_DARKBLUE list("#181934", "#24305c", "#284671", "#346b8d")
#define PALETTE_JS_LIGHTBLUE list("#354477", "#4275bd", "#5c9bd9", "#7fc1ea")
#define PALETTE_JS_AQUA list("#0f5077", "#1689a4", "#2ec0c0", "#5aead8")
#define PALETTE_JS_BROWN list("#341515", "#5e2f18", "#824927", "#a8703f")
#define PALETTE_JS_LIGHTBROWN list("#763d20", "#9d643d", "#c48a4f", "#e0b57e")
#define PALETTE_JS_DARKRED list("#2a1022", "#571928", "#8f1c26", "#b6332a")
#define PALETTE_JS_LIGHTRED list("#9d2433", "#d2464f", "#ee726a", "#f19d8a")
#define PALETTE_JS_LIGHTGREEN list("#20693c", "#3a9345", "#63c05e", "#92dc70")
#define PALETTE_JS_YELLOWGREEN list("#7a6921", "#9d9d1c", "#b6cb22", "#caf155")
#define PALETTE_JS_LIGHTPURPLE list("#473593", "#7350c0", "#9e65dc", "#c890ea")
#define PALETTE_JS_PINK list("#881f82", "#c43d89", "#e0649a", "#f896a2")
#define PALETTE_JS_GREY list("#3b3334", "#625f5f", "#888281", "#b0a6a0")

GLOBAL_LIST_INIT(palette_registry, list(
	DYE_REGISTRY_UNDER = list(
		DYE_RED = PALETTE_JS_RED,
		DYE_ORANGE = PALETTE_JS_ORANGE,
		DYE_YELLOW = PALETTE_JS_YELLOW,
		DYE_GREEN = PALETTE_JS_GREEN,
		DYE_BLUE = PALETTE_JS_BLUE,
		DYE_PURPLE = PALETTE_JS_PURPLE,
		DYE_BLACK = PALETTE_JS_BLACK,
		DYE_WHITE = PALETTE_JS_WHITE,
		DYE_DARKBLUE = PALETTE_JS_DARKBLUE,
		DYE_LIGHTBLUE = PALETTE_JS_LIGHTBLUE,
		DYE_AQUA = PALETTE_JS_AQUA,
		DYE_BROWN = PALETTE_JS_BROWN,
		DYE_LIGHTBROWN = PALETTE_JS_LIGHTBROWN,
		DYE_DARKRED = PALETTE_JS_DARKRED,
		DYE_LIGHTRED = PALETTE_JS_LIGHTRED,
		DYE_LIGHTGREEN = PALETTE_JS_LIGHTGREEN,
		DYE_YELLOWGREEN = PALETTE_JS_YELLOWGREEN,
		DYE_LIGHTPURPLE = PALETTE_JS_LIGHTPURPLE,
		DYE_PINK = PALETTE_JS_PINK,
		DYE_GREY = PALETTE_JS_GREY,
	),
	DYE_REGISTRY_JUMPSKIRT = list(
		DYE_RED = PALETTE_JS_RED,
		DYE_ORANGE = PALETTE_JS_ORANGE,
		DYE_YELLOW = PALETTE_JS_YELLOW,
		DYE_GREEN = PALETTE_JS_GREEN,
		DYE_BLUE = PALETTE_JS_BLUE,
		DYE_PURPLE = PALETTE_JS_PURPLE,
		DYE_BLACK = PALETTE_JS_BLACK,
		DYE_WHITE = PALETTE_JS_WHITE,
		DYE_DARKBLUE = PALETTE_JS_DARKBLUE,
		DYE_LIGHTBLUE = PALETTE_JS_LIGHTBLUE,
		DYE_AQUA = PALETTE_JS_AQUA,
		DYE_BROWN = PALETTE_JS_BROWN,
		DYE_LIGHTBROWN = PALETTE_JS_LIGHTBROWN,
		DYE_DARKRED = PALETTE_JS_DARKRED,
		DYE_LIGHTRED = PALETTE_JS_LIGHTRED,
		DYE_LIGHTGREEN = PALETTE_JS_LIGHTGREEN,
		DYE_YELLOWGREEN = PALETTE_JS_YELLOWGREEN,
		DYE_LIGHTPURPLE = PALETTE_JS_LIGHTPURPLE,
		DYE_PINK = PALETTE_JS_PINK,
		DYE_GREY = PALETTE_JS_GREY,
	),
))
