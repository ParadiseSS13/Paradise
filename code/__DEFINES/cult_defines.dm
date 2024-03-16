// Rune colors, for easy reference
#define RUNE_COLOR_TALISMAN "#0000FF"
#define RUNE_COLOR_TELEPORT "#551A8B"
#define RUNE_COLOR_OFFER "#FFFFFF"
#define RUNE_COLOR_DARKRED "#7D1717"
#define RUNE_COLOR_MEDIUMRED "#C80000"
#define RUNE_COLOR_BURNTORANGE "#CC5500"
#define RUNE_COLOR_RED "#FF0000"
#define RUNE_COLOR_LIGHTRED "#FF726F"
#define RUNE_COLOR_EMP "#4D94FF"
#define RUNE_COLOR_SUMMON "#00FF00"

#define IS_SACRIFICE_TARGET(A) SSticker?.mode?.cult_team?.is_sac_target(A)

// Blood magic
/// Maximum number of spells with an empowering rune
#define MAX_BLOODCHARGE 4
/// Maximum number of spells without an empowering rune
#define RUNELESS_MAX_BLOODCHARGE 1
#define BLOOD_SPEAR_COST 150
#define BLOOD_BARRAGE_COST 300
#define BLOOD_ORB_COST 50
#define BLOOD_RECHARGE_COST 75
#define BLOOD_BEAM_COST 500
#define METAL_TO_CONSTRUCT_SHELL_CONVERSION 50

// Cult Status
/// At what population does it switch to highpop values
#define CULT_POPULATION_THRESHOLD 100
/// Percent before rise (Lowpop)
#define CULT_RISEN_LOW 0.2
/// Percent before ascend (Lowpop)
#define CULT_ASCENDANT_LOW 0.3
/// Percent before rise (Highpop)
#define CULT_RISEN_HIGH 0.1
/// Percent before ascend (Highpop)
#define CULT_ASCENDANT_HIGH 0.2

// Screen locations
#define DEFAULT_BLOODSPELLS "6:-29,4:-2"
#define DEFAULT_BLOODTIP "14:6,14:27"
#define DEFAULT_TOOLTIP "6:-29,5:-2"

// Text
#define CULT_CURSES list("A fuel technician just slit his own throat and begged for death.",                                           \
			"The shuttle's navigation programming was replaced by a file containing two words, IT COMES.",                             \
			"The shuttle's custodian tore out his guts and began painting strange shapes on the floor.",                               \
			"A shuttle engineer began screaming 'DEATH IS NOT THE END' and ripped out wires until an arc flash seared off her flesh.", \
			"A shuttle inspector started laughing madly over the radio and then threw herself into an engine turbine.",                \
			"The shuttle dispatcher was found dead with bloody symbols carved into their flesh.",                                      \
			"Steve repeatedly touched a lightbulb until his hands fell off.")

// Misc
#define SOULS_TO_REVIVE 3
#define BLOODCULT_EYE "#FF0000"
#define SUMMON_POSSIBILITIES 3
#define CULT_CLOTHING list(/obj/item/clothing/suit/hooded/cultrobes, /obj/item/clothing/suit/space/cult, /obj/item/clothing/suit/hooded/cultrobes/cult_shield, \
						/obj/item/clothing/suit/hooded/cultrobes/flagellant_robe, /obj/item/clothing/glasses/hud/health/night/cultblind)

// Cult objective status
#define NARSIE_IS_ASLEEP 0
#define NARSIE_DEMANDS_SACRIFICE 1
#define NARSIE_NEEDS_SUMMONING 2
#define NARSIE_HAS_RISEN 3
#define NARSIE_HAS_FALLEN -1

/// Safely accesses SSticker.cult_data, returns the default if cult data is not set up yet. Allows for both variable and proc call access.
#define GET_CULT_DATA(var_or_proc, default) (SSticker.cult_data ? SSticker.cult_data.var_or_proc : default)

/// Checks that the given element is living an has a cult antag datum
#define IS_CULTIST(mob) (isliving(mob) && mob?:mind?:has_antag_datum(/datum/antagonist/cultist)) // for someone TODO, move all antag checks over to TG's `IS_TRAITOR` defines. Also remove `isliving()` from this call someday
