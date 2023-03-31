#define DEBUG
//#define TESTING

// Uncomment the following line to compile unit tests.
// #define UNIT_TESTS

// Uncomment the following line to enable Tracy profiling.
// DO NOT DO THIS UNLESS YOU UNDERSTAND THE IMPLICATIONS
// Your data directory will grow by about a gigabyte every time you launch the server, as well as introducing potential instabilities over multiple BYOND versions.
// #define ENABLE_BYOND_TRACY


#ifdef CIBUILDING
#define UNIT_TESTS
#endif

/***** All toggles for the GC ref finder *****/

// #define REFERENCE_TRACKING		// Uncomment to enable ref finding

// #define GC_FAILURE_HARD_LOOKUP	//makes paths that fail to GC call find_references before del'ing.

// #define FIND_REF_NO_CHECK_TICK	//Sets world.loop_checks to false and prevents find references from sleeping

// #define FIND_REF_NOTIFY_ON_COMPLETE	// Throw a windows notification toast when the ref finding process is done

/***** End toggles for the GC ref finder *****/

#define IS_MODE_COMPILED(MODE) (ispath(text2path("/datum/game_mode/"+(MODE))))

//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 514
#define MIN_COMPILER_BUILD 1554
#if DM_VERSION < MIN_COMPILER_VERSION || DM_BUILD < MIN_COMPILER_BUILD
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
#error You need version 514.1554 or higher
#endif
