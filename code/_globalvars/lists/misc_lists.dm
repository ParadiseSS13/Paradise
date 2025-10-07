GLOBAL_LIST_INIT(alphabet, list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"))
GLOBAL_LIST_INIT(alphabet_uppercase, list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"))
GLOBAL_LIST_INIT(html_colors, list("Alice Blue","Antique White","Aqua","Aquamarine","Azure","Beige","Bisque","Black","Blanched Almond","Blue","Blue Violet",
									"Brown","Burly Wood","Cadet Blue","Chartreuse","Chocolate","Coral","Cornflower Blue","Cornsilk","Crimson","Cyan",
									"Dark Blue","Dark Cyan","Dark Golden Rod","Dark Gray","Dark Green","Dark Khaki","Dark Magenta","Dark Olive Green",
									"Dark Orange","Dark Orchid","Dark Red","Dark Salmon","Dark Sea Green","Dark Slate Blue","Dark Slate Gray",
									"Dark Turquoise","Dark Violet","Deep Pink","Deep Sky Blue","Dim Gray","Dodger Blue","Fire Brick","Floral White",
									"Forest Green","Fuchsia","Gainsboro","Ghost White","Gold","Golden Rod","Gray","Grey","Green","Green Yellow","Honey Dew",
									"Hot Pink","Indian Red","Indigo","Ivory","Khaki","Lavender","Lavender Blush","Lawn Green","Lemon Chiffon","Light Blue",
									"Light Coral","Light Cyan","Light Golden Rod Yellow","Light Gray","Light Green","Light Pink","Light Salmon","Light Sea Green",
									"Light Sky Blue","Light Slate Gray","Light Steel Blue","Light Yellow","Lime","Lime Green","Linen","Magenta","Maroon",
									"Medium Aquamarine","Medium Blue","Medium Orchid","Medium Purple","Medium Seagreen","Medium Slate Blue","Medium Spring Green",
									"Medium Turquoise","Medium Violet Red","Midnight Blue","Mint Cream","Misty Rose","Moccasin","Navajo White","Navy","Old Lace",
									"Olive","Olive Drab","Orange","Orange Red","Orchid","Pale Golden Rod","Pale Green","Pale Turquoise","Pale Violet Red",
									"Papaya Whip","Peach Puff","Peru","Pink","Plum","Powder Blue","Purple","Red","Rosy Brown","Royal Blue","Saddle Brown",
									"Salmon","Sandy Brown","Sea Green","Sea Shell","Sienna","Silver","Sky Blue","Slate Blue","Slate Gray","Snow","Spring Green",
									"Steel Blue","Tan","Teal","Thistle","Tomato","Turquoise","Violet","Wheat","White","White Smoke","Yellow","Yellow Green"))

GLOBAL_LIST_INIT(month_names, list("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"))
// keep si_suffixes balanced and with a pivot in the middle!
GLOBAL_LIST_INIT(si_suffixes, list("y", "z", "a", "f", "p", "n", "u", "m", "", "k", "M", "G", "T", "P", "E", "Z", "Y"))

GLOBAL_LIST_INIT(restricted_camera_networks, list(
	"CentComm",
	"ERT",
	"NukeOps",
	"Thunderdome",
	"UO45",
	"UO45R",
	"UO71",
	"Xeno",
	"SyndicateTestLab",
	"SyndicateToxinsTest",
	"SyndicateCaves"
	)) //Those networks can only be accessed by preexisting terminals. AIs and new terminals can't use them.

GLOBAL_LIST_EMPTY(ruin_landmarks)

GLOBAL_LIST_INIT(round_end_sounds, list(
		'sound/AI/newroundsexy.ogg' = 2.3 SECONDS,
		'sound/misc/apcdestroyed.ogg' = 3 SECONDS,
		'sound/misc/bangindonk.ogg' = 1.6 SECONDS,
		'sound/misc/berightback.ogg' = 2.9 SECONDS,
		'sound/goonstation/misc/newround1.ogg' = 6.9 SECONDS,
		'sound/goonstation/misc/newround2.ogg' = 14.8 SECONDS
		))  // Maps available round end sounds to their duration

GLOBAL_LIST_INIT(cooking_recipe_types, list(
	RECIPE_MICROWAVE = /datum/recipe/microwave,
	))
GLOBAL_LIST_INIT(cooking_recipes, list(RECIPE_MICROWAVE = list(), RECIPE_OVEN = list(), RECIPE_GRILL = list(), RECIPE_CANDY = list()))
GLOBAL_LIST_INIT(cooking_ingredients, list(RECIPE_MICROWAVE = list(), RECIPE_OVEN = list(), RECIPE_GRILL = list(), RECIPE_CANDY = list()))
GLOBAL_LIST_INIT(cooking_reagents, list(RECIPE_MICROWAVE = list(), RECIPE_OVEN = list(), RECIPE_GRILL = list(), RECIPE_CANDY = list()))

#define EGG_LAYING_MESSAGES list("lays an egg.", "squats down and croons.", "begins making a huge racket.", "begins clucking raucously.")

GLOBAL_LIST_EMPTY(client_login_processors)

/// List of ckeys that have seen a blurb of a given key.
GLOBAL_LIST_EMPTY(blurb_witnesses)

/// List of looping sounds
GLOBAL_LIST_EMPTY(looping_sounds)

/// List of possible crits from things tipping over
GLOBAL_LIST_EMPTY(tilt_crits)

/// Stores a list of the cached seed icons. Used in the seed extractor and the gene modder
GLOBAL_LIST_EMPTY(seeds_cached_base64_icons)

/// Assoc list of all RND techs with ID to name
GLOBAL_LIST_EMPTY(rnd_tech_id_to_name)

/// List of things that restrain teslas.
GLOBAL_LIST_EMPTY(tesla_containment)

/// Assoc list of admin permission names
GLOBAL_LIST_INIT(admin_permission_names, alist(
	R_BUILDMODE = "BUILDMODE",
	R_ADMIN = "ADMIN",
	R_BAN = "BAN",
	R_EVENT = "EVENT",
	R_SERVER = "SERVER",
	R_DEBUG = "DEBUG",
	R_POSSESS = "POSSESS",
	R_PERMISSIONS = "PERMISSIONS",
	R_STEALTH = "STEALTH",
	R_REJUVINATE = "REJUVINATE",
	R_VAREDIT = "VAREDIT",
	R_SOUNDS = "SOUNDS",
	R_SPAWN = "SPAWN",
	R_MOD = "MOD",
	R_MENTOR = "MENTOR",
	R_PROCCALL = "PROCCALL",
	R_VIEWRUNTIMES = "VIEWRUNTIMES",
	R_MAINTAINER = "MAINTAINER",
	R_DEV_TEAM = "DEV_TEAM",
	R_VIEWLOGS = "VIEWLOGS",
))
GLOBAL_PROTECT(admin_permission_names)
