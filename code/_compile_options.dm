#define DEBUG

#define IS_MODE_COMPILED(MODE) (ispath(text2path("/datum/game_mode/"+(MODE))))

#define BACKGROUND_ENABLED 0 // The default value for all uses of set background. Set background can cause gradual lag and is recommended you only turn this on if necessary.

	//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN 1024
#define MAX_PAPER_MESSAGE_LEN 3072
#define MAX_BOOK_MESSAGE_LEN 9216
#define MAX_NAME_LEN 26

var/global/list/processing_objects = list() //This has to be initialized BEFORE world