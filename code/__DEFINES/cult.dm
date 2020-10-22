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

#define is_sacrifice_target(A) SSticker.mode && SSticker.mode.cult_objs.is_sac_target(A)

// Blood magic
#define MAX_BLOODCHARGE 4
#define RUNELESS_MAX_BLOODCHARGE 1

/// Percent before rise
#define CULT_RISEN 0.2
/// Percent before ascend
#define CULT_ASCENDANT 0.4

#define BLOOD_SPEAR_COST 150
#define BLOOD_BARRAGE_COST 300
#define BLOOD_BEAM_COST 500
#define METAL_TO_CONSTRUCT_SHELL_CONVERSION 50

// Screen locations
#define DEFAULT_BLOODSPELLS "6:-29,4:-2"
#define DEFAULT_BLOODTIP "14:6,14:27"
#define DEFAULT_TOOLTIP "6:-29,5:-2"

// Text
#define CULT_GREETING "<span class='cultlarge'>You catch a glimpse of the Realm of [SSticker.cultdat.entity_name], [SSticker.cultdat.entity_title3]. You now see how flimsy the world is, you see that it should be open to the knowledge of [SSticker.cultdat.entity_name].</span>"

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

// Cult objective status
#define NARSIE_IS_ASLEEP 0
#define NARSIE_DEMANDS_SACRIFICE 1
#define NARSIE_NEEDS_SUMMONING 2
#define NARSIE_HAS_RISEN 3
#define NARSIE_HAS_FALLEN -1
