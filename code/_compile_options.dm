#define DEBUG
//#define TESTING

// Uncomment the following line to compile unit tests.
// #define UNIT_TESTS


#ifdef CIBUILDING
#define UNIT_TESTS
#endif

#ifdef TESTING
//#define GC_FAILURE_HARD_LOOKUP	//makes paths that fail to GC call find_references before del'ing.
									//implies FIND_REF_NO_CHECK_TICK

//#define FIND_REF_NO_CHECK_TICK	//Sets world.loop_checks to false and prevents find references from sleeping

#endif

#define IS_MODE_COMPILED(MODE) (ispath(text2path("/datum/game_mode/"+(MODE))))

//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN 1024
#define MAX_PAPER_MESSAGE_LEN 4096
#define MAX_PAPER_FIELDS 50
#define MAX_BOOK_MESSAGE_LEN 9216
#define MAX_NAME_LEN 50 	//diona names can get loooooooong

//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 513
#define MIN_COMPILER_BUILD 1514
#if DM_VERSION < MIN_COMPILER_VERSION || DM_BUILD < MIN_COMPILER_BUILD
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
#error You need version 513.1514 or higher
#endif

// Macros that must exist before world.dm
// #define to_chat to_chat_filename=__FILE__;to_chat_line=__LINE__;to_chat_src=src;__to_chat

// If this is uncommented, will attempt to load and initialize prof.dll/libprof.so.
// We do not ship byond-tracy. Build it yourself here: https://github.com/mafemergency/byond-tracy/
// #define USE_BYOND_TRACY
