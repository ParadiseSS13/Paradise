//mob/var/stat things
#define CONSCIOUS	0
#define UNCONSCIOUS	1
#define DEAD		2

/*
	Shuttles
*/

// these define the time taken for the shuttle to get to SS13
// and the time before it leaves again
#define SHUTTLE_CALLTIME 	6000	//10 minutes = 6000 deciseconds - time taken for emergency shuttle to reach the station when called (in deciseconds)
#define SHUTTLE_DOCKTIME 	1800	//3 minutes = 1800 deciseconds - time taken for emergency shuttle to leave again once it has docked (in deciseconds)
#define SHUTTLE_ESCAPETIME	1200	//2 minutes = 1200 deciseconds - time taken for emergency shuttle to reach a safe distance after leaving station (in deciseconds)

//shuttle mode defines
#define SHUTTLE_IGNITING 0
#define SHUTTLE_IDLE     1
#define SHUTTLE_RECALL   2
#define SHUTTLE_CALL     3
#define SHUTTLE_DOCKED   4
#define SHUTTLE_STRANDED 5
#define SHUTTLE_ESCAPE 6
#define SHUTTLE_ENDGAME 7

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
