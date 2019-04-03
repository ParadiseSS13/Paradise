GLOBAL_LIST_INIT(ai_names, file2list("config/names/ai.txt"))
GLOBAL_LIST_INIT(wizard_first, file2list("config/names/wizardfirst.txt"))
GLOBAL_LIST_INIT(wizard_second, file2list("config/names/wizardsecond.txt"))
GLOBAL_LIST_INIT(ninja_titles, file2list("config/names/ninjatitle.txt"))
GLOBAL_LIST_INIT(ninja_names, file2list("config/names/ninjaname.txt"))
GLOBAL_LIST_INIT(commando_names, file2list("config/names/death_commando.txt"))
GLOBAL_LIST_INIT(first_names_male, file2list("config/names/first_male.txt"))
GLOBAL_LIST_INIT(first_names_female, file2list("config/names/first_female.txt"))
GLOBAL_LIST_INIT(last_names, file2list("config/names/last.txt"))
GLOBAL_LIST_INIT(clown_names, file2list("config/names/clown.txt"))
GLOBAL_LIST_INIT(mime_names, file2list("config/names/mime.txt"))
GLOBAL_LIST_INIT(golem_names, file2list("config/names/golem.txt"))

GLOBAL_LIST_INIT(verbs, file2list("config/names/verbs.txt"))
GLOBAL_LIST_INIT(adjectives, file2list("config/names/adjectives.txt"))
GLOBAL_LIST_INIT(dream_strings, file2list("config/names/dreams.txt"))
GLOBAL_LIST_INIT(nightmare_strings, file2list("config/names/nightmares.txt"))
//loaded on startup because of "
//would include in rsc if ' was used

GLOBAL_LIST_INIT(vox_name_syllables, list("ti","hi","ki","ya","ta","ha","ka","ya","chi","cha","kah"))


/*
List of configurable names in preferences and their metadata
"id" = list(
	"pref_name" = "name", //pref label
	"qdesc" =  "name", //popup question text
	"allow_numbers" = FALSE, // numbers allowed in the name
	"group" = "whatever", // group (these will be grouped together on pref ui ,order still follows the list so they need to be concurrent to be grouped)
	"allow_null" = FALSE // if empty name is entered it's replaced with default value
	),
*/

GLOBAL_LIST_INIT(preferences_custom_names, list(
	"human" = list("pref_name" = "Backup Human", "qdesc" = "backup name, used in the event you are assigned event role that needs it", "allow_numbers" = FALSE , "group" = "backup_human", "allow_null" = FALSE),
	"clown" = list("pref_name" = "Clown" , "qdesc" = "clown name", "allow_numbers" = FALSE , "group" = "fun", "allow_null" = FALSE),
	"mime" = list("pref_name" = "Mime", "qdesc" = "mime name" , "allow_numbers" = FALSE , "group" = "fun", "allow_null" = FALSE),
	"cyborg" = list("pref_name" = "Cyborg", "qdesc" = "cyborg name (Leave empty to use default naming scheme)", "allow_numbers" = TRUE , "group" = "silicons", "allow_null" = TRUE),
	"ai" = list("pref_name" = "AI", "qdesc" = "ai name", "allow_numbers" = TRUE , "group" = "silicons", "allow_null" = FALSE),
	"religion" = list("pref_name" = "Chaplain religion", "qdesc" = "religion" , "allow_numbers" = TRUE , "group" = "chaplain", "allow_null" = FALSE),
	"deity" = list("pref_name" = "Chaplain deity", "qdesc" = "deity", "allow_numbers" = TRUE , "group" = "chaplain", "allow_null" = FALSE)
	))