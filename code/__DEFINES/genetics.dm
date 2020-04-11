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
#define	TK				1
#define COLDRES			2
#define XRAY			3
#define HULK			4
#define CLUMSY			5
#define FAT				6
#define HUSK			7
#define NOCLONE			8

// Extra powers:
#define LASER			9 	// harm intent - click anywhere to shoot lasers from eyes

//species mutation
#define WINGDINGS		10	// Ayy lmao

//2spooky
#define SKELETON 29
#define PLANT 30

// Other Mutations:
#define BREATHLESS		100		// no breathing
#define REMOTE_VIEW		101 	// remote viewing
#define REGEN			102 	// health regen
#define RUN				103 	// no slowdown
#define REMOTE_TALK		104 	// remote talking
#define MORPH			105 	// changing appearance
#define HEATRES			106 	// heat resistance
#define HALLUCINATE		107 	// hallucinations
#define FINGERPRINTS	108 	// no fingerprints
#define NO_SHOCK		109 	// insulated hands
#define DWARF			110 	// table climbing

// Goon muts
#define OBESITY       	200		// Decreased metabolism
// 201 undefined
#define STRONG        	202		// (Nothing)
#define SOBER         	203		// Increased alcohol metabolism
#define PSY_RESIST    	204		// Block remoteview
// 205 undefined
#define EMPATH			206		//Read minds
#define COMIC			207		//Comic Sans

// /vg/ muts
#define LOUD			208		// CAUSES INTENSE YELLING
#define DIZZY			210		// Trippy.

#define LISP			300
#define RADIOACTIVE 	301
#define CHAV			302
#define SWEDISH			303
#define SCRAMBLED		304
#define HORNS			305
#define IMMOLATE		306
#define CLOAK			307
#define CHAMELEON		308
#define CRYO			309
#define EATER			310

#define JUMPY			400
#define POLYMORPH		401

//disabilities
#define NEARSIGHTED		1
#define EPILEPSY		2
#define COUGHING		4
#define TOURETTES		8
#define NERVOUS			16
#define BLIND			32
#define COLOURBLIND		64
#define MUTE			128
#define DEAF			256

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
#define CAN_BE_FAT 		"can_be_fat"
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
#define NOZOMBIE 		"no_zombie"
#define NO_GERMS		"no_germs"
#define NO_DECAY		"no_decay"
#define PIERCEIMMUNE	"pierce_immunity"
#define NO_HUNGER		"no_hunger"
