// channel numbers for power
#define EQUIP           1
#define LIGHT           2
#define ENVIRON         3
#define TOTAL           4	//for total power used only
#define STATIC_EQUIP    5
#define STATIC_LIGHT    6
#define STATIC_ENVIRON  7

//Power use
#define NO_POWER_USE 0
#define IDLE_POWER_USE 1
#define ACTIVE_POWER_USE 2

//computer3 error codes, move lower in the file when it passes dev -Sayu
 #define PROG_CRASH      1  // Generic crash
 #define MISSING_PERIPHERAL  2  // Missing hardware
 #define BUSTED_ASS_COMPUTER  4  // Self-perpetuating error.  BAC will continue to crash forever.
 #define MISSING_PROGRAM    8  // Some files try to automatically launch a program.  This is that failing.
 #define FILE_DRM      16  // Some files want to not be copied/moved.  This is them complaining that you tried.
 #define NETWORK_FAILURE  32

#define	IMPRINTER		1	//For circuits. Uses glass/chemicals.
#define PROTOLATHE		2	//New stuff. Uses glass/metal/chemicals
#define	AUTOLATHE		4	//Uses glass/metal only.
#define CRAFTLATHE		8	//Uses fuck if I know. For use eventually.
#define MECHFAB			16 	//Remember, objects utilising this flag should have construction_time and construction_cost vars.
#define PODFAB			32 	//Used by the spacepod part fabricator. Same idea as the mechfab
#define BIOGENERATOR	64 	//Uses biomass
#define SMELTER			128 //uses various minerals
//Note: More then one of these can be added to a design but imprinter and lathe designs are incompatable.

#define HYDRO_SPEED_MULTIPLIER 1

//Modular computer/NTNet defines

//Modular computer part defines
#define MC_CPU "CPU"
#define MC_HDD "HDD"
#define MC_SDD "SDD"
#define MC_CARD "CARD"
#define MC_NET "NET"
#define MC_PRINT "PRINT"
#define MC_CELL "CELL"
#define MC_CHARGE "CHARGE"
#define MC_AI "AI"

//NTNet stuff, for modular computers
									// NTNet module-configuration values. Do not change these. If you need to add another use larger number (5..6..7 etc)
#define NTNET_SOFTWAREDOWNLOAD 1 	// Downloads of software from NTNet
#define NTNET_PEERTOPEER 2			// P2P transfers of files between devices
#define NTNET_COMMUNICATION 3		// Communication (messaging)
#define NTNET_SYSTEMCONTROL 4		// Control of various systems, RCon, air alarm control, etc.

//NTNet transfer speeds, used when downloading/uploading a file/program.
#define NTNETSPEED_LOWSIGNAL 0.5	// GQ/s transfer speed when the device is wirelessly connected and on Low signal
#define NTNETSPEED_HIGHSIGNAL 1	// GQ/s transfer speed when the device is wirelessly connected and on High signal
#define NTNETSPEED_ETHERNET 2		// GQ/s transfer speed when the device is using wired connection

//Caps for NTNet logging. Less than 10 would make logging useless anyway, more than 500 may make the log browser too laggy. Defaults to 100 unless user changes it.
#define MAX_NTNET_LOGS 300
#define MIN_NTNET_LOGS 10

//Program bitflags
#define PROGRAM_ALL 7
#define PROGRAM_CONSOLE 1
#define PROGRAM_LAPTOP 2
#define PROGRAM_TABLET 4
//Program states
#define PROGRAM_STATE_KILLED 0
#define PROGRAM_STATE_BACKGROUND 1
#define PROGRAM_STATE_ACTIVE 2

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
