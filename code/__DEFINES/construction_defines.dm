/*ALL DEFINES RELATED TO CONSTRUCTION, CONSTRUCTING THINGS, OR CONSTRUCTED OBJECTS GO HERE*/

//Defines for construction states

/// girder construction states
#define GIRDER_NORMAL 0
#define GIRDER_REINF_STRUTS 1
#define GIRDER_REINF 2
#define GIRDER_DISPLACED 3
#define GIRDER_DISASSEMBLED 4

/// rwall construction states
#define RWALL_INTACT 0
#define RWALL_SUPPORT_LINES 1
#define RWALL_COVER 2
#define RWALL_CUT_COVER 3
#define RWALL_BOLTS 4
#define RWALL_SUPPORT_RODS 5
#define RWALL_SHEATH 6

/// window construction states
#define WINDOW_OUT_OF_FRAME 0
#define WINDOW_IN_FRAME 1
#define WINDOW_SCREWED_TO_FRAME 2

/// airlock assembly construction states
#define AIRLOCK_ASSEMBLY_NEEDS_WIRES 0
#define AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS 1
#define AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER 2

/// used by airlocks and airlock wires.
#define AICONTROLDISABLED_OFF 0 // Silicons can control the airlock normally.
#define AICONTROLDISABLED_ON 1 // Silicons cannot control the airlock, but can hack the airlock.
#define AICONTROLDISABLED_BYPASS 2 // Silicons can control the airlock because they succeeded on the hack
#define AICONTROLDISABLED_PERMA 3 // Wire cutting an airlock on AICONTROLDISABLED_BYPASS toggles it between AICONTROLDISABLED_BYPASS and this.

/// plastic flaps construction states
#define PLASTIC_FLAPS_NORMAL 0
#define PLASTIC_FLAPS_DETACHED 1

/// Mounted Frames BITMASK
#define MOUNTED_FRAME_SIMFLOOR	(1 << 0)
#define MOUNTED_FRAME_NOSPACE	(1 << 1)

/// ai core defines
#define EMPTY_CORE 0
#define CIRCUIT_CORE 1
#define SCREWED_CORE 2
#define CABLED_CORE 3
#define GLASS_CORE 4
#define AI_READY_CORE 5

/// other construction-related things

/// windows affected by nar'sie turn this color.
#define NARSIE_WINDOW_COLOUR "#7D1919"

/// let's just pretend fulltile windows being children of border windows is fine
#define FULLTILE_WINDOW_DIR NORTHEAST

/// Range of a tint control button, that works only in its area.
#define TINT_CONTROL_RANGE_AREA 0

/// ID of a tint control button with no group specified, so it controls only windows also with no group specified ('null-like' id).
#define TINT_CONTROL_GROUP_NONE 0

/// Material defines, for determining how much of a given material an item contains
#define MAT_WOOD			"wood"
#define MAT_METAL			"metal"
#define MAT_GLASS			"glass"
#define MAT_SILVER			"silver"
#define MAT_GOLD			"gold"
#define MAT_DIAMOND			"diamond"
#define MAT_URANIUM			"uranium"
#define MAT_PLASMA			"plasma"
#define MAT_BLUESPACE		"bluespace"
#define MAT_BANANIUM		"bananium"
#define MAT_TRANQUILLITE	"tranquillite"
#define MAT_TITANIUM		"titanium"
#define MAT_BIOMASS			"biomass"
#define MAT_PLASTIC			"plastic"
#define MAT_BRASS			"brass"
#define MAT_PALLADIUM		"palladium"
#define MAT_PLATINUM		"platinum"
#define MAT_IRIDIUM			"iridium"

/// The amount of materials you get from a sheet of mineral like iron/diamond/glass etc
#define MINERAL_MATERIAL_AMOUNT 2000
/// The maximum size of a stack object.
#define MAX_STACK_SIZE 50
/// maximum amount of cable in a coil
#define MAXCOIL 30
