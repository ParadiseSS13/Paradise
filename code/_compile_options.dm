#define DEBUG
//#define TESTING

// Uncomment the following line to enable debug logging for cooking recipes.
// #define PCWJ_DEBUG

// Uncomment the following line to compile unit tests on a local server. The output will be in a test_run-[DATE].log file in the ./data folder.
// #define LOCAL_GAME_TESTS

// Uncomment the following line to enable Tracy profiling.
// DO NOT DO THIS UNLESS YOU UNDERSTAND THE IMPLICATIONS
// Your data directory will grow by about a gigabyte every time you launch the server, as well as introducing potential instabilities over multiple BYOND versions.
// #define ENABLE_BYOND_TRACY

// Uncomment this to enable support for multiple instances
// #define MULTIINSTANCE

#ifdef LOCAL_GAME_TESTS
#define GAME_TESTS
#define MAP_TESTS
#endif

#if defined(CIBUILDING) && defined(LOCAL_GAME_TESTS)
#error CIBUILDING and LOCAL_GAME_TESTS should not be enabled at the same time!
#endif

#if defined(GAME_TESTS) || defined(MAP_TESTS)
#define TEST_RUNNER
#endif

/***** All toggles for the GC ref finder *****/

// #define REFERENCE_TRACKING		// Uncomment to enable ref finding

// #define GC_FAILURE_HARD_LOOKUP	//makes paths that fail to GC call find_references before del'ing.

// #define FIND_REF_NO_CHECK_TICK	//Sets world.loop_checks to false and prevents find references from sleeping

// #define FIND_REF_NOTIFY_ON_COMPLETE	// Throw a windows notification toast when the ref finding process is done

/***** End toggles for the GC ref finder *****/

#define IS_MODE_COMPILED(MODE) (ispath(text2path("/datum/game_mode/"+(MODE))))

//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 516
// Yes I know 1648 was the earliest 516 but BYONDapi changes were made that we need
// Expect more frequent bumps on this in the future
#define MIN_COMPILER_BUILD 1651
#if(DM_VERSION < MIN_COMPILER_VERSION || DM_BUILD < MIN_COMPILER_BUILD) && !defined(SPACEMAN_DMM)
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to secure.byond.com/download and update.
#error You need version 516.1651 or higher
#endif
