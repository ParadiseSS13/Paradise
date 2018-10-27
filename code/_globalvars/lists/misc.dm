GLOBAL_LIST_INIT(alphabet, list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"))
GLOBAL_LIST_INIT(alphabet_uppercase, list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"))
GLOBAL_LIST_INIT(zero_character_only, list("0"))
GLOBAL_LIST_INIT(hex_characters, list("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"))
GLOBAL_LIST_INIT(binary, list("0","1"))

GLOBAL_LIST_INIT(day_names, list("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))
GLOBAL_LIST_INIT(month_names, list("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"))

GLOBAL_LIST_INIT(restricted_camera_networks, list(
	"CentComm",
	"ERT",
	"NukeOps",
	"Thunderdome",
	"UO45",
	"UO45R",
	"UO71",
	"Xeno",
	"Hotel"
	)) //Those networks can only be accessed by preexisting terminals. AIs and new terminals can't use them.

GLOBAL_LIST_INIT(mineral_turfs, list())

GLOBAL_LIST_INIT(ruin_landmarks, list())

GLOBAL_LIST_INIT(round_end_sounds, list(
		'sound/AI/newroundsexy.ogg' = 2.3 SECONDS,
		'sound/misc/apcdestroyed.ogg' = 3 SECONDS,
		'sound/misc/bangindonk.ogg' = 1.6 SECONDS,
		'sound/goonstation/misc/newround1.ogg' = 6.9 SECONDS,
		'sound/goonstation/misc/newround2.ogg' = 14.8 SECONDS
		))  // Maps available round end sounds to their duration

GLOBAL_LIST_INIT(cooking_recipe_types, list(
	RECIPE_MICROWAVE = /datum/recipe/microwave,
	RECIPE_OVEN = /datum/recipe/oven,
	RECIPE_GRILL = /datum/recipe/grill,
	RECIPE_CANDY = /datum/recipe/candy
	))
GLOBAL_LIST_INIT(cooking_recipes, list(RECIPE_MICROWAVE = list(), RECIPE_OVEN = list(), RECIPE_GRILL = list(), RECIPE_CANDY = list()))
GLOBAL_LIST_INIT(cooking_ingredients, list(RECIPE_MICROWAVE = list(), RECIPE_OVEN = list(), RECIPE_GRILL = list(), RECIPE_CANDY = list()))
GLOBAL_LIST_INIT(cooking_reagents, list(RECIPE_MICROWAVE = list(), RECIPE_OVEN = list(), RECIPE_GRILL = list(), RECIPE_CANDY = list()))

GLOBAL_LIST(space_laws)

GLOBAL_LIST(station_level_space_turfs)

#define EGG_LAYING_MESSAGES list("lays an egg.", "squats down and croons.", "begins making a huge racket.", "begins clucking raucously.")
