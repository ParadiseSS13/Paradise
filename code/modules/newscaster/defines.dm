// Globals
/// The feed network singleton. Contains all channels (which contain all stories).
GLOBAL_DATUM_INIT(news_network, /datum/feed_network, new)
/// Global list that contains all existing newscasters in the world.
GLOBAL_LIST_EMPTY(allNewscasters)

// Screen indexes
/// Headlines screen index.
#define NEWSCASTER_HEADLINES	0
/// Available Jobs screen index.
#define NEWSCASTER_JOBS			1
/// View Channel screen index.
#define NEWSCASTER_CHANNEL		2

// Censor flags
/// Censor author name.
#define CENSOR_AUTHOR (1 << 0)
/// Censor story title, body and image.
#define CENSOR_STORY (1 << 1)
