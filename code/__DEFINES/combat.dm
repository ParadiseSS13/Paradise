//Damage things	//TODO: merge these down to reduce on defines
//Way to waste perfectly good damagetype names (BRUTE) on this... If you were really worried about case sensitivity, you could have just used lowertext(damagetype) in the proc...
#define CUT 		"cut"
#define BRUISE		"bruise"
#define BRUTE		"brute"
#define BURN		"fire"
#define TOX			"tox"
#define OXY			"oxy"
#define CLONE		"clone"
#define HALLOSS		"halloss"
#define STAMINA 	"stamina"

#define STUN		"stun"
#define WEAKEN		"weaken"
#define PARALYZE	"paralize"
#define IRRADIATE	"irradiate"
#define AGONY		"agony" // Added in PAIN!
#define STUTTER		"stutter"
#define SLUR		"slur"
#define EYE_BLUR	"eye_blur"
#define DROWSY		"drowsy"
#define JITTER		"jitter"

//I hate adding defines like this but I'd much rather deal with bitflags than lists and string searches
#define BRUTELOSS 1
#define FIRELOSS 2
#define TOXLOSS 4
#define OXYLOSS 8

//Bitflags defining which status effects could be or are inflicted on a mob
#define CANSTUN		1
#define CANWEAKEN	2
#define CANPARALYSE	4
#define CANPUSH		8
#define LEAPING		16
#define PASSEMOTES	32      //Mob has a cortical borer or holders inside of it that need to see emotes.
#define GOTTAGOFAST	64
#define GOTTAGOREALLYFAST	128
#define IGNORESLOWDOWN	256
#define GODMODE		4096
#define FAKEDEATH	8192	//Replaces stuff like changeling.changeling_fakedeath
#define DISFIGURED	16384	//I'll probably move this elsewhere if I ever get wround to writing a bitflag mob-damage system
#define XENO_HOST	32768	//Tracks whether we're gonna be a baby alien's mummy.


//Grab levels
#define GRAB_PASSIVE  1
#define GRAB_AGGRESSIVE  2
#define GRAB_NECK    3
#define GRAB_UPGRADING  4
#define GRAB_KILL    5

//Hostile Mob Stances
#define HOSTILE_STANCE_IDLE 1
#define HOSTILE_STANCE_ALERT 2
#define HOSTILE_STANCE_ATTACK 3
#define HOSTILE_STANCE_ATTACKING 4
#define HOSTILE_STANCE_TIRED 5

//Hostile Mob AI Status
#define AI_ON		1
#define AI_SLEEP	2
#define AI_OFF		3
