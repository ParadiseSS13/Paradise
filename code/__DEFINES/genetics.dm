// String identifiers for associative list lookup

#define MUTCHK_FORCED        1

// mob/var/list/mutations

// Used in preferences.
#define DISABILITY_FLAG_NEARSIGHTED 1
#define DISABILITY_FLAG_FAT         2
#define DISABILITY_FLAG_EPILEPTIC   4
#define DISABILITY_FLAG_DEAF        8
#define DISABILITY_FLAG_BLIND       16
#define DISABILITY_FLAG_MUTE        32
#define DISABILITY_FLAG_COLOURBLIND 64
#define DISABILITY_FLAG_TOURETTES   512
#define DISABILITY_FLAG_NERVOUS     1024
#define DISABILITY_FLAG_SWEDISH     2048
#define DISABILITY_FLAG_SCRAMBLED   4096 // incoherent speech
#define DISABILITY_FLAG_LISP        8192
#define DISABILITY_FLAG_DIZZY       16384

//Nutrition levels for humans. No idea where else to put it
#define NUTRITION_LEVEL_FAT 600
#define NUTRITION_LEVEL_FULL 550
#define NUTRITION_LEVEL_WELL_FED 450
#define NUTRITION_LEVEL_FED 350
#define NUTRITION_LEVEL_HUNGRY 250
#define NUTRITION_LEVEL_STARVING 150
#define NUTRITION_LEVEL_CURSED 0

//Blood levels
#define BLOOD_VOLUME_MAXIMUM		2000
#define BLOOD_VOLUME_NORMAL			560
#define BLOOD_VOLUME_SAFE			501
#define BLOOD_VOLUME_OKAY			336
#define BLOOD_VOLUME_BAD			224
#define BLOOD_VOLUME_SURVIVE		122

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

#define IS_WHITELISTED 	1
#define LIPS			2
#define NO_BLOOD		3
#define NO_BREATHE 		4
#define NO_DNA			5
#define NO_SCAN 		6
#define NO_PAIN 		7
#define IS_PLANT 		8
#define CAN_BE_FAT 		9
#define NO_INTORGANS	10
#define RADIMMUNE		11
#define NOGUNS			12
#define NOTRANSSTING	13
#define VIRUSIMMUNE		14
#define NOCRITDAMAGE	15
#define RESISTHOT		16
#define RESISTCOLD		17
#define NO_EXAMINE		18