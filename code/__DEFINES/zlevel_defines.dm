#define Z_LEVEL_NORTH 		"1"
#define Z_LEVEL_SOUTH 		"2"
#define Z_LEVEL_EAST 		"4"
#define Z_LEVEL_WEST 		"8"

#define TRANSITIONEDGE	7 //Distance from edge to move to another z-level

// Defining these here so everything is consistent
#define TRANSITION_BORDER_NORTH		(world.maxy - TRANSITIONEDGE - 1)
#define TRANSITION_BORDER_SOUTH		TRANSITIONEDGE
#define TRANSITION_BORDER_EAST		(world.maxx - TRANSITIONEDGE - 1)
#define TRANSITION_BORDER_WEST		TRANSITIONEDGE
