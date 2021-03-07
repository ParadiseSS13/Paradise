//Languages!
#define LANGUAGE_HUMAN		1
#define LANGUAGE_ALIEN		2
#define LANGUAGE_DOG		4
#define LANGUAGE_CAT		8
#define LANGUAGE_BINARY		16
#define LANGUAGE_OTHER		32768

#define LANGUAGE_UNIVERSAL	65535

//Language flags.
#define WHITELISTED 1  		// Language is available if the speaker is whitelisted.
#define RESTRICTED 2   		// Language can only be accquired by spawning or an admin.
#define HIVEMIND 16         // Broadcast to all mobs with this language.
#define NONGLOBAL 32		// Do not add to general languages list
#define INNATE 64			// All mobs can be assumed to speak and understand this language (audible emotes)
#define NO_TALK_MSG 128		// Do not show the "\The [speaker] talks into \the [radio]" message
#define NO_STUTTER 256		// No stuttering, slurring, or other speech problems
#define NOBABEL 512			// Not granted by book of babel. Typically antag languages.

//Auto-accent level defines.
#define AUTOHISS_OFF 0
#define AUTOHISS_BASIC 1
#define AUTOHISS_FULL 2
#define AUTOHISS_NUM 3 //Number of auto-accent options.
