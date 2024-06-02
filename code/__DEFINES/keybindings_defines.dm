#define KB_CATEGORY_MOVEMENT		1
#define KB_CATEGORY_MOB				2
#define KB_CATEGORY_LIVING			3
#define KB_CATEGORY_CARBON			4
#define KB_CATEGORY_HUMAN			5
#define KB_CATEGORY_AI				6
#define KB_CATEGORY_ROBOT			7
#define KB_CATEGORY_ADMIN			8
#define KB_CATEGORY_EMOTE_GENERIC	9
#define KB_CATEGORY_EMOTE_CARBON	10
#define	KB_CATEGORY_EMOTE_ALIEN		11
#define KB_CATEGORY_EMOTE_BRAIN 	12
#define KB_CATEGORY_EMOTE_HUMAN		13
#define KB_CATEGORY_EMOTE_SILICON	14
#define KB_CATEGORY_EMOTE_ANIMAL	15
#define KB_CATEGORY_EMOTE_CUSTOM	16
#define KB_CATEGORY_CLICK			17
#define KB_CATEGORY_COMMUNICATION	18
#define KB_CATEGORY_UNSORTED		1000

///Max length of a keypress command before it's considered to be a forged packet/bogus command
#define MAX_KEYPRESS_COMMANDLENGTH 16
///Max amount of keypress messages per second over two seconds before client is autokicked
#define MAX_KEYPRESS_AUTOKICK 50
///Length of held key rolling buffer
#define HELD_KEY_BUFFER_LENGTH 15
///Maximum keys that can be bound to one button
#define MAX_COMMANDS_PER_KEY 5
