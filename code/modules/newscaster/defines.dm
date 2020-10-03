// Globals
/// The feed network singleton. Contains all channels (which contain all stories).
GLOBAL_DATUM_INIT(news_network, /datum/feed_network, new)
/// Global list that contains all existing newscasters in the world.
GLOBAL_LIST_EMPTY(allNewscasters)

// Screen indexes
/// Main Menu screen index.
#define NEWSCASTER_MAIN			0
/// Feed Channel List screen index.
#define NEWSCASTER_FC_LIST		1
/// Create Feed Channel screen index.
#define NEWSCASTER_CREATE_FC	2
/// Create Feed Message screen index.
#define NEWSCASTER_CREATE_FM	3
/// Print Newspaper screen index.
#define NEWSCASTER_PRINT		4
/// Read Feed Channel screen index.
#define NEWSCASTER_VIEW_FC		5
/// Nanotrasen Feed Censorship Tool screen index.
#define NEWSCASTER_NT_CENSOR	6
/// Nanotrasen D-Notice Handler screen index.
#define NEWSCASTER_D_NOTICE		7
/// Censor Feed Channel screen index.
#define NEWSCASTER_CENSOR_FC	8
/// D-Notice Feed Channel screen index.
#define NEWSCASTER_D_NOTICE_FC	9
/// Wanted Issue Handler screen index.
#define NEWSCASTER_W_ISSUE_H	10
/// Stationwide Wanted Issue screen index.
#define NEWSCASTER_W_ISSUE		11
/// Available Jobs screen index.
#define NEWSCASTER_JOBS			12
/// Headlines screen index.
#define NEWSCASTER_HEADLINES	13
/// View Channel screen index.
#define NEWSCASTER_CHANNEL		14

// Censor flags
/// Censor author name.
#define CENSOR_AUTHOR (1 << 0)
/// Censor story title, body and image.
#define CENSOR_STORY (1 << 1)
