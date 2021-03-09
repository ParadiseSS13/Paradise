// String identifiers for associative list lookup


#define CHECK_DNA_AND_SPECIES(C) if((!(C.dna)) || (!(C.dna.species))) return

#define MUTCHK_FORCED        1

// mob/var/list/mutations

// Used in preferences.
#define DISABILITY_FLAG_NEARSIGHTED 1
#define DISABILITY_FLAG_FAT         2
#define DISABILITY_FLAG_BLIND       4
#define DISABILITY_FLAG_MUTE        8
#define DISABILITY_FLAG_COLOURBLIND 16
#define DISABILITY_FLAG_WINGDINGS   32
#define DISABILITY_FLAG_NERVOUS     64
#define DISABILITY_FLAG_SWEDISH     128
#define DISABILITY_FLAG_LISP        256
#define DISABILITY_FLAG_DIZZY       512
#define DISABILITY_FLAG_CHAV        1024
#define DISABILITY_FLAG_DEAF        2048

///////////////////////////////////////
// MUTATIONS
///////////////////////////////////////

// Generic mutations:
#define	TK				"telekenesis"
#define COLDRES			"cold_resistance"
#define XRAY			"xray"
#define HULK			"hulk"
#define CLUMSY			"clumsy"
#define FAT				"fat"
#define HUSK			"husk"
#define NOCLONE			"noclone"
#define LASER			"eyelaser" 			// harm intent - click anywhere to shoot lasers from eyes
#define WINGDINGS		"wingdings"			// Ayy lmao
#define SKELETON 		"skeleton"
#define BREATHLESS		"breathless"		// no breathing
#define REMOTE_VIEW		"remove_view" 		// remote viewing
#define REGEN			"regeneration"		// health regen
#define RUN				"increased_run" 	// no slowdown
#define REMOTE_TALK		"remote_talk" 		// remote talking
#define MORPH			"morph" 			// changing appearance
#define HEATRES			"heat_resistance" 	// heat resistance
#define HALLUCINATE		"hallucinate" 		// hallucinations
#define FINGERPRINTS	"no_prints" 		// no fingerprints
#define NO_SHOCK		"no_shock" 			// insulated hands
#define DWARF			"dwarf"				// table climbing
#define OBESITY       	"obesity"			// Decreased metabolism
#define STRONG        	"strong"			// (Nothing)
#define SOBER         	"sober"				// Increased alcohol metabolism
#define PSY_RESIST    	"psy_resist"		// Block remoteview
#define EMPATH			"empathy"			//Read minds
#define COMIC			"comic_sans"		//Comic Sans
#define LOUD			"loudness"			// CAUSES INTENSE YELLING
#define DIZZY			"dizzy"				// Trippy.
#define LISP			"lisp"
#define RADIOACTIVE 	"radioactive"
#define CHAV			"chav"
#define SWEDISH			"swedish"
#define SCRAMBLED		"scrambled"
#define HORNS			"horns"
#define IMMOLATE		"immolate"
#define CLOAK			"cloak"
#define CHAMELEON		"chameleon"
#define CRYO			"cryokinesis"
#define EATER			"matter_eater"
#define JUMPY			"jumpy"
#define POLYMORPH		"polymorph"
//disabilities
#define NEARSIGHTED		"nearsighted"
#define EPILEPSY		"epilepsy"
#define COUGHING		"coughing"
#define TOURETTES		"tourettes"
#define NERVOUS			"nervous"
#define BLINDNESS		"blind"
#define COLOURBLIND		"colorblind"
#define MUTE			"mute"
#define DEAF			"deaf"

//Nutrition levels for humans. No idea where else to put it
#define NUTRITION_LEVEL_FAT 600
#define NUTRITION_LEVEL_FULL 550
#define NUTRITION_LEVEL_WELL_FED 450
#define NUTRITION_LEVEL_FED 350
#define NUTRITION_LEVEL_HUNGRY 250
#define NUTRITION_LEVEL_STARVING 150
#define NUTRITION_LEVEL_HYPOGLYCEMIA 100
#define NUTRITION_LEVEL_CURSED 0

//Used as an upper limit for species that continuously gain nutriment
#define NUTRITION_LEVEL_ALMOST_FULL 535

//Blood levels
#define BLOOD_VOLUME_MAXIMUM		2000
#define BLOOD_VOLUME_NORMAL			560
#define BLOOD_VOLUME_SAFE			501
#define BLOOD_VOLUME_OKAY			336
#define BLOOD_VOLUME_BAD			224
#define BLOOD_VOLUME_SURVIVE		122

//Sizes of mobs, used by mob/living/var/mob_size
#define MOB_SIZE_TINY 0
#define MOB_SIZE_SMALL 1
#define MOB_SIZE_HUMAN 2
#define MOB_SIZE_LARGE 3

//Ventcrawling defines
#define VENTCRAWLER_NONE   0
#define VENTCRAWLER_NUDE   1
#define VENTCRAWLER_ALWAYS 2

//Used for calculations for negative effects of having genetics powers
#define DEFAULT_GENE_STABILITY 100
#define GENE_INSTABILITY_MINOR 5
#define GENE_INSTABILITY_MODERATE 10
#define GENE_INSTABILITY_MAJOR 15

#define GENETIC_DAMAGE_STAGE_1 80
#define GENETIC_DAMAGE_STAGE_2 65
#define GENETIC_DAMAGE_STAGE_3 35

#define CLONER_FRESH_CLONE "fresh"
#define CLONER_MATURE_CLONE "mature"

//Species traits.

#define IS_WHITELISTED 	"whitelisted"
#define LIPS			"lips"
#define NO_BLOOD		"no_blood"
#define NO_BREATHE 		"no_breathe"
#define NO_DNA			"no_dna"
#define NO_SCAN 		"no_scan"
#define NO_PAIN 		"no_pain"
#define IS_PLANT 		"is_plant"
#define NO_INTORGANS	"no_internal_organs"
#define RADIMMUNE		"rad_immunity"
#define NOGUNS			"no_guns"
#define NOTRANSSTING	"no_trans_sting"
#define VIRUSIMMUNE		"virus_immunity"
#define NOCRITDAMAGE	"no_crit"
#define RESISTHOT		"resist_heat"
#define RESISTCOLD		"resist_cold"
#define NO_EXAMINE		"no_examine"
#define CAN_WINGDINGS	"can_wingdings"
#define NO_GERMS		"no_germs"
#define NO_DECAY		"no_decay"
#define PIERCEIMMUNE	"pierce_immunity"
#define NO_HUNGER		"no_hunger"
#define EXOTIC_COLOR	"exotic_blood_colour"
#define NO_OBESITY		"no_obesity"
