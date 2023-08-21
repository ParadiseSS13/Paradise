#define	IMPRINTER		1	//For circuits. Uses glass/chemicals.
#define PROTOLATHE		2	//New stuff. Uses glass/metal/chemicals
#define	AUTOLATHE		4	//Uses glass/metal only.
#define CRAFTLATHE		8	//Uses fuck if I know. For use eventually.
#define MECHFAB			16 	//Remember, objects utilising this flag should have construction_time and construction_cost vars.
// #define PODFAB			32 	//Used by the spacepod part fabricator. Same idea as the mechfab // AA 2021-10-02 - Removed. Kept for flag consistency.
#define BIOGENERATOR	64 	//Uses biomass
#define SMELTER			128 //uses various minerals
/// Used for gamma armoury lathe designs
#define GAMMALATHE		256
//Note: More then one of these can be added to a design but imprinter and lathe designs are incompatable.


// Demotion Console (card/minor/*) departments
#define TARGET_DEPT_GENERIC 1
#define TARGET_DEPT_SEC 2
#define TARGET_DEPT_MED 3
#define TARGET_DEPT_SCI 4
#define TARGET_DEPT_ENG 5

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
