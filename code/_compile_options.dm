#define DEBUG
//#define TESTING

#define IS_MODE_COMPILED(MODE) (ispath(text2path("/datum/game_mode/"+(MODE))))

#define BACKGROUND_ENABLED 0 // The default value for all uses of set background. Set background can cause gradual lag and is recommended you only turn this on if necessary.

//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN 1024
#define MAX_PAPER_MESSAGE_LEN 3072
#define MAX_BOOK_MESSAGE_LEN 9216
#define MAX_NAME_LEN 26

// Version check, terminates compilation if someone is using a version of BYOND that's too old
#if DM_VERSION < 508
#error OUTDATED VERSION ERROR - \
Due to BYOND features used in this codebase, you must update to version 508 or later to compile. \
This may require updating to a beta release.
#endif

var/global/list/processing_objects = list() //This has to be initialized BEFORE world

#define USE_BYGEX 