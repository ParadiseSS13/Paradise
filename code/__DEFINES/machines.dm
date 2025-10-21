#define	IMPRINTER		(1<<0)	//For circuits. Uses glass/chemicals.
#define PROTOLATHE		(1<<1)	//New stuff. Uses glass/metal/chemicals
#define	AUTOLATHE		(1<<2)	//Uses glass/metal only.
#define CRAFTLATHE		(1<<3)	//Uses fuck if I know. For use eventually.
#define MECHFAB			(1<<4) 	//Remember, objects utilising this flag should have construction_time and construction_cost vars.
// #define PODFAB			(1<<5) 	//Used by the spacepod part fabricator. Same idea as the mechfab // AA 2021-10-02 - Removed. Kept for flag consistency.
#define BIOGENERATOR	(1<<6) 	//Uses biomass
#define SMELTER			(1<<7) //uses various minerals
/// Used for gamma armoury lathe designs
#define GAMMALATHE		(1<<8)
//Note: More then one of these can be added to a design but imprinter and lathe designs are incompatable.


// Demotion Console (card/minor/*) departments
#define TARGET_DEPT_GENERIC 1
#define TARGET_DEPT_SEC 2
#define TARGET_DEPT_MED 3
#define TARGET_DEPT_SCI 4
#define TARGET_DEPT_ENG 5
#define TARGET_DEPT_SUP 6

// These are used by supermatter and supermatter monitor program, mostly for UI updating purposes. Higher should always be worse!
// These are warning defines, they should trigger before the state, not after.
#define SUPERMATTER_ERROR -1		// Unknown status, shouldn't happen but just in case.
#define SUPERMATTER_INACTIVE 0		// No or minimal energy
#define SUPERMATTER_NORMAL 1		// Normal operation
#define SUPERMATTER_NOTIFY 2		// Ambient temp > 80% of CRITICAL_TEMPERATURE
#define SUPERMATTER_WARNING 3		// Ambient temp > CRITICAL_TEMPERATURE OR integrity damaged
#define SUPERMATTER_DANGER 4		// Integrity < 75%
#define SUPERMATTER_EMERGENCY 5		// Integrity < 50%
#define SUPERMATTER_DELAMINATING 6	// Pretty obvious, Integrity < 25%

// More defines for the suppermatter
/// Higher == Crystal safe operational temperature is higher.
#define SUPERMATTER_HEAT_PENALTY_THRESHOLD 40

// Firelock states
#define FD_OPEN 1
#define FD_CLOSED 2

// Computer login types
#define LOGIN_TYPE_NORMAL 1
#define LOGIN_TYPE_AI 2
#define LOGIN_TYPE_ROBOT 3
#define LOGIN_TYPE_ADMIN 4

// Status display maptext stuff
#define DISPLAY_CHARS_PER_LINE 5
#define DISPLAY_FONT_SIZE "5pt"
#define DISPLAY_FONT_COLOR "#09f"
#define DISPLAY_WARNING_FONT_COLOR "#f90"
#define DISPLAY_FONT_STYLE "Small Fonts"
#define DISPLAY_SCROLL_SPEED 2

// Status display mode types
#define STATUS_DISPLAY_BLANK 0
#define STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME 1
#define STATUS_DISPLAY_MESSAGE 2
#define STATUS_DISPLAY_ALERT 3
#define STATUS_DISPLAY_TIME 4
#define STATUS_DISPLAY_CUSTOM 5

// AI display mode types
#define AI_DISPLAY_MODE_BLANK 0
#define AI_DISPLAY_MODE_EMOTE 1
#define AI_DISPLAY_MODE_BSOD 2

// Door operations
#define DOOR_OPENING 1
#define DOOR_CLOSING 2
#define DOOR_MALF 3

#define TURRET_PRIORITY_TARGET 2
#define TURRET_SECONDARY_TARGET 1
#define TURRET_NOT_TARGET 0

#define TURRET_PREASSESS_VALID 1
#define TURRET_PREASSESS_INVALID 0

#define AIR_ALARM_FRAME		0
#define AIR_ALARM_UNWIRED	1
#define AIR_ALARM_READY		2

/**
 * Air alarm modes
 */
#define AALARM_MODE_FILTERING 1
#define AALARM_MODE_DRAUGHT 2 //makes draught
#define AALARM_MODE_PANIC 3 //like siphon, but stronger (enables widenet)
#define AALARM_MODE_CYCLE 4 //sucks off all air, then refill and swithes to scrubbing
#define AALARM_MODE_SIPHON 5 //Scrubbers suck air
#define AALARM_MODE_CONTAMINATED 6 //Turns on all filtering and widenet scrubbing.
#define AALARM_MODE_REFILL 7 //just like normal, but disables low pressure check until normalized, then switches to normal
#define AALARM_MODE_OFF 8
#define AALARM_MODE_FLOOD 9 //Emagged mode; turns off scrubbers and pressure checks on vents
#define AALARM_MODE_CUSTOM 10

#define NUKE_STATUS_INTACT 0
#define NUKE_CORE_MISSING 1
#define NUKE_MISSING 2

#define CIRCULATOR_SIDE_LEFT WEST
#define CIRCULATOR_SIDE_RIGHT EAST

// Request Console configuration bitmask.
/// [/obj/machinery/requests_console] can request assistance.
#define RC_ASSIST (1<<0)
/// [/obj/machinery/requests_console] can request supplies.
#define RC_SUPPLY (1<<1)
/// [/obj/machinery/requests_console] can relay anonymous information.
#define RC_INFO   (1<<2)

/// ORM point defines
#define ORM_BASE_POINT_MULT 0.90
#define ORM_BASE_SHEET_MULT 0.90
#define ORM_POINT_MULT_ADD_PER_RATING 0.10
#define ORM_SHEET_MULT_ADD_PER_RATING 0.10

/// Salvage machine point defines
#define SALVAGE_REDEMPTION_BASE_POINT_MULT 0.6
#define SALVAGE_REDEMPTION_POINT_MULT_ADD_PER_RATING 0.1
