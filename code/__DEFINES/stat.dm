//mob/var/stat things
#define CONSCIOUS	0
#define UNCONSCIOUS	1
#define DEAD		2

// NanoUI flags
#define STATUS_INTERACTIVE 2 // GREEN Visability
#define STATUS_UPDATE 1 // ORANGE Visability
#define STATUS_DISABLED 0 // RED Visability
#define STATUS_CLOSE -1 // Close the interface

// bitflags for machine stat variable
#define BROKEN		1
#define NOPOWER		2
#define POWEROFF	4		// tbd
#define MAINT		8			// under maintaince
#define EMPED		16		// temporary broken by EMP pulse

/*
	Shuttles
*/

// these define the time taken for the shuttle to get to SS13
// and the time before it leaves again
#define SHUTTLE_PREPTIME 				300	// 5 minutes = 300 seconds - after this time, the shuttle departs centcom and cannot be recalled
#define SHUTTLE_LEAVETIME 				180	// 3 minutes = 180 seconds - the duration for which the shuttle will wait at the station after arriving
#define SHUTTLE_TRANSIT_DURATION		300	// 5 minutes = 300 seconds - how long it takes for the shuttle to get to the station
#define SHUTTLE_TRANSIT_DURATION_RETURN 120	// 2 minutes = 120 seconds - for some reason it takes less time to come back, go figure.

//Ferry shuttle processing status
#define IDLE_STATE		0
#define WAIT_LAUNCH		1
#define WAIT_ARRIVE		2
#define WAIT_FINISH		3

//shuttle mode defines
#define SHUTTLE_IDLE     0
#define SHUTTLE_RECALL   1
#define SHUTTLE_CALL     2
#define SHUTTLE_DOCKED   3
#define SHUTTLE_STRANDED 4
#define SHUTTLE_ESCAPE 5
#define SHUTTLE_ENDGAME 6

// Shuttle return values
#define SHUTTLE_CAN_DOCK "can_dock"
#define SHUTTLE_NOT_A_DOCKING_PORT "not_a_docking_port"
#define SHUTTLE_DWIDTH_TOO_LARGE "docking_width_too_large"
#define SHUTTLE_WIDTH_TOO_LARGE "width_too_large"
#define SHUTTLE_DHEIGHT_TOO_LARGE "docking_height_too_large"
#define SHUTTLE_HEIGHT_TOO_LARGE "height_too_large"
#define SHUTTLE_ALREADY_DOCKED "we_are_already_docked"
#define SHUTTLE_SOMEONE_ELSE_DOCKED "someone_else_docked"

// Ripples, effects that signal a shuttle's arrival
#define SHUTTLE_RIPPLE_TIME 100
#define SHUTTLE_RIPPLE_FADEIN 50

/*
	Logic
*/
//	State						When to Use														Example
#define LOGIC_OFF 0		//Use this for when you want it to stay off						(continuous signal, lever)
#define LOGIC_ON 1		//Use this for when you want it to stay on						(continuous signal, lever)
#define LOGIC_FLICKER 2	//Use this for when you want it to turn on and then turn off	(buttons, clocks)

//Logic-related stuff (Misc. defines for logic things, to keep it organized or something)
#define LOGIC_FLICKER_TIME 10		//number of deciseconds LOGIC_TEMP_ON will remain active before turning off
