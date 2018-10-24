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

GLOBAL_LIST_INIT(space_laws ,list("100, Damage to Station Assets" = "To deliberately damage the station or station property to a minor degree with malicious intent.",
			"102, Battery" = "To use minor physical force against someone without intent to seriously injure them.",
			"103, Drug Possession" = "To possess space drugs, ambrosia, krokodil, crank, meth, aranesp, bath salts, THC, or other narcotics, by unauthorized personnel.",
			"105, Indecent Exposure" = "To be intentionally and publicly unclothed.",
			"106, Abuse of Equipment" = "To utilize security/non-lethal equipment in an illegitimate fashion.",
			"107, Petty Theft" = "To take items from areas one lacks access to, or to take items belonging to others or the station as a whole.",
			"108, Trespass" = "To be in an area which a person lacks authorized ID access for. This counts for general areas of the station.",
			"109, Resisting Arrest" = "To resist an officer who attempts a proper arrest.",
			"200, Creating a Workplace Hazard" = "To endanger the crew or station through negligent but not deliberately malicious actions.",
			"201, Kidnapping" = "To hold a crewmember under duress or against their will.",
			"202, Assault" = "To use excessive physical force against someone without the apparent intent to kill them.",
			"203, Narcotics Distribution" = "To distribute narcotics and other controlled substances. This includes ambrosia and space drugs. It is not illegal for them to be grown.",
			"204, Possession of a Weapon" = "To be in possession of a dangerous item that is not part of one's job.",
			"205, Rioting" = "To partake in an unauthorized and disruptive assembly of crewmen.",
			"206, Abuse of Confiscated Equipment" = "To take and use equipment confiscated as evidence.",
			"207, Robbery" = "To steal items from another's person.",
			"208, Breaking and Entering" = "Forced entry to areas where the subject does not have access to. This counts for general areas.",
			"300, Sabotage" = "To hinder the work of the crew or station through malicious actions.",
			"301, Kidnapping of an Officer" = "To hold a member of Command, Security, or any Central Command VIP under duress or against their will.",
			"302, Aggravated Assault" = "To use excessive physical force resulting in severe or life-threatening harm.",
			"304, Possession of a Restricted Weapon" = "To be in possession of a restricted weapon without authorization such as: Guns, Batons, Non-Beneficial Grenades/Explosives, etc.",
			"305, Inciting a Riot" = "To attempt to stir the crew into a riot.",
			"306, Possession of Contraband" = "To be in the possession of contraband items. Being in possession of S-grade contraband, or committing a major crime with contraband, makes you an Enemy of the Corporation.",
			"307, Theft" = "To steal restricted or dangerous items from either an area or one's person.",
			"308, Major Trespass" = "Being in a restricted area without prior authorization. This includes Security areas, Command areas (including EVA), the Engine Room, Atmos, or Toxins Research.",
			"309, Assault of an Officer" = "To use excessive physical force against a member of Command or Security without the apparent intent to kill them.",
			"400, Grand Sabotage" = "To engage in maliciously destructive actions which endanger the crew or station.",
			"401, Manslaughter" = "To cause death to a person via negligence or injury without apparent intent to kill.",
			"402, Attempted Murder" = "To use excessive physical force with intention to cause death.",
			"407, Grand Theft" = "To steal items of high value or sensitive nature from either an area or one's person.",
			"502, Murder" = "To deliberately and maliciously cause the death of another crewmember via direct or indirect means.",
			"505, Mutiny" = "To act individually, or as a group, to overthrow or subvert the established Chain of Command without lawful and legitimate cause."
		))

GLOBAL_LIST(station_level_space_turfs)

#define EGG_LAYING_MESSAGES list("lays an egg.", "squats down and croons.", "begins making a huge racket.", "begins clucking raucously.")
