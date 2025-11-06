//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN 1024
#define MAX_PAPER_MESSAGE_LEN 3072
#define MAX_PAPER_FIELDS 50
///Max Characters that can be on a single book page, this will give players an average of 5000 words worth of writing space (1000 per page)
#define MAX_CHARACTERS_PER_BOOKPAGE 5000
#define MAX_SUMMARY_LEN 1500
#define MAX_NAME_LEN 50 	//diona names can get loooooooong
#define MAX_FLAVORTEXT_PRINT 400 //Amount of flavor text characters to print before cutting off.

/// Removes characters incompatible with file names.
#define SANITIZE_FILENAME(text) (GLOB.filename_forbidden_chars.Replace(text, ""))
