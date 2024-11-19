// Defines below to be used with the `power_type` var.
/// Denotes that this power is free and should be given to all mindflayers by default.
#define FLAYER_INNATE_POWER			1
/// Denotes that this power can only be obtained by purchasing it.
#define FLAYER_PURCHASABLE_POWER	2
/// Denotes that this power can not be obtained normally. Primarily used for base types such as [/datum/spell/flayer/weapon].
#define FLAYER_UNOBTAINABLE_POWER	3

/// How many swarms can you drain per person?
#define BRAIN_DRAIN_LIMIT 120
/// The time per harvesting tick
#define DRAIN_TIME 0.25 SECONDS
/// If we want to keep draining someone but we don't have any swarms to gain
#define DRAIN_BUT_NO_SWARMS 2

#define isflayerpassive(A)		(istype(A, /datum/mindflayer_passive))

// For organizing what spells are available for what trees
#define FLAYER_CATEGORY_GENERAL "general"
#define FLAYER_CATEGORY_DESTROYER "destroyer"
#define FLAYER_CATEGORY_INTRUDER "intruder"
#define FLAYER_CATEGORY_SWARMER "swarmer"

#define FLAYER_POWER_LEVEL_ZERO		0
#define FLAYER_POWER_LEVEL_ONE		1
#define FLAYER_POWER_LEVEL_TWO		2
#define FLAYER_POWER_LEVEL_THREE	3
#define FLAYER_POWER_LEVEL_FOUR		4

#define FLAYER_CAPSTONE_STAGE 		4
