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

GLOBAL_LIST_INIT(blacklisted_heretic_areas, list(
	/area/station/turret_protected,
	/area/station/aisat,
	/area/station/science/toxins/test,
	))

/// List of all crimes and their data
GLOBAL_LIST_INIT(all_crimes, list(
	/datum/law/crime/minor/damage_station_assets,
	/datum/law/crime/minor/battery,
	/datum/law/crime/minor/drug_possession,
	/datum/law/crime/minor/indecent_exposure,
	/datum/law/crime/minor/abuse_equipment,
	/datum/law/crime/minor/petty_theft,
	/datum/law/crime/minor/trespass,
	/datum/law/crime/medium/robbery,
	/datum/law/crime/medium/abuse_confiscated,
	/datum/law/crime/medium/rioting,
	/datum/law/crime/medium/weapon_possession,
	/datum/law/crime/medium/narcotics_distribution,
	/datum/law/crime/medium/assault,
	/datum/law/crime/medium/kidnapping,
	/datum/law/crime/medium/workplace_hazard,
	/datum/law/crime/major/sabotage,
	/datum/law/crime/major/aggravated_assault,
	/datum/law/crime/major/restricted_weapon,
	/datum/law/crime/major/inciting_riot,
	/datum/law/crime/major/contraband_possession,
	/datum/law/crime/major/theft,
	/datum/law/crime/major/major_trespass,
))

/// List of all crime modifiers
GLOBAL_LIST_INIT(all_crime_modifiers, list(
	/datum/law/modifier/cooperate,
	/datum/law/modifier/refuse_cooperate,
	/datum/law/modifier/resisting_arrest,
	/datum/law/modifier/surrender,
	/datum/law/modifier/aiding_abetting,
	/datum/law/modifier/against_an_officer,
	/datum/law/modifier/repeat_offender_first,
	/datum/law/modifier/repeat_offender_second
))
