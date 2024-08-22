// Defines below to be used with the `power_type` var.
/// Denotes that this power is free and should be given to all mindflayers by default.
#define FLAYER_INNATE_POWER			1
/// Denotes that this power can only be obtained by purchasing it.
#define FLAYER_PURCHASABLE_POWER	2
/// Denotes that this power can not be obtained normally. Primarily used for base types such as [/datum/spell/flayer/weapon].
#define FLAYER_UNOBTAINABLE_POWER	3

#define BRAIN_DRAIN_LIMIT 120
#define DRAIN_TIME 1/4 SECONDS

#define isspell(A)			(istype(A, /datum/spell))
#define ispassive(A)		(istype(A, /datum/mindflayer_passive))

//For organizing what spells are available for what trees
#define CATEGORY_GENERAL "general"
#define CATEGORY_DESTROYER "destroyer"
#define CATEGORY_INTRUDER "intruder"
#define CATEGORY_SWARMER "swarmer"

#define POWER_LEVEL_ZERO	0
#define POWER_LEVEL_ONE		1
#define POWER_LEVEL_TWO		2
#define POWER_LEVEL_THREE	3
#define POWER_LEVEL_FOUR	4

#define CAPSTONE_STAGE 4

#define RANGED_ATTACK_BASE "base ranged attack"
#define MELEE_ATTACK_BASE "base melee attack"
