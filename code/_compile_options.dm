#define DEBUG
//#define TESTING

#ifdef TESTING
//#define GC_FAILURE_HARD_LOOKUP	//makes paths that fail to GC call find_references before del'ing.
									//implies FIND_REF_NO_CHECK_TICK

//#define FIND_REF_NO_CHECK_TICK	//Sets world.loop_checks to false and prevents find references from sleeping

#endif

#define IS_MODE_COMPILED(MODE) (ispath(text2path("/datum/game_mode/"+(MODE))))

#define BACKGROUND_ENABLED 0 // The default value for all uses of set background. Set background can cause gradual lag and is recommended you only turn this on if necessary.

//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN 1024
#define MAX_PAPER_MESSAGE_LEN 3072
#define MAX_PAPER_FIELDS 50
#define MAX_BOOK_MESSAGE_LEN 9216
#define MAX_NAME_LEN 50 	//diona names can get loooooooong

// Version check, terminates compilation if someone is using a version of BYOND that's too old
#if DM_VERSION < 510
#error OUTDATED VERSION ERROR - \
Due to BYOND features used in this codebase, you must update to version 510 or later to compile. \
This may require updating to a beta release.
#endif

// Macros that must exist before world.dm
#define to_chat to_chat_filename=__FILE__;to_chat_line=__LINE__;to_chat_src=src;__to_chat