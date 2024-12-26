//Bot defines, placed here so they can be read by other things!

#define BOT_STEP_DELAY 4 //Delay between movemements
#define BOT_STEP_MAX_RETRIES 5 //Maximum times a bot will retry to step from its position

#define DEFAULT_SCAN_RANGE		7	//default view range for finding targets.

//Mode defines
#define BOT_IDLE 			0	// idle
#define BOT_HUNT 			1	// found target, hunting
#define BOT_PREP_ARREST 	2	// at target, preparing to arrest
#define BOT_ARREST			3	// arresting target
#define BOT_START_PATROL	4	// start patrol
#define BOT_PATROL			5	// patrolling
#define BOT_SUMMON			6	// summoned by PDA
#define BOT_CLEANING 		7	// cleaning (cleanbots)
#define BOT_REPAIRING		8	// repairing hull breaches (floorbots)
#define BOT_MOVING			9	// for clean/floor/med bots, when moving.
#define BOT_HEALING			10	// healing people (medbots)
#define BOT_RESPONDING		11	// responding to a call from the AI
#define BOT_DELIVER			12	// moving to deliver
#define BOT_GO_HOME			13	// returning to home
#define BOT_BLOCKED			14	// blocked
#define BOT_NAV				15	// computing navigation
#define BOT_WAIT_FOR_NAV	16	// waiting for nav computation
#define BOT_NO_ROUTE		17	// no destination beacon found (or no route)
#define BOT_MAKE_TILE		18	// converting metal into tiles (floorbots)
#define BOT_EAT_TILE		19	// adding said tiles to inventory (floorbots)
#define BOT_PATHING			20	// Actively pathfinding.

//Bot types
#define SEC_BOT				"Security"	// Secutritrons (Beepsky) and ED-209s
#define MULE_BOT			"Mule"	// MULEbots
#define FLOOR_BOT			"Floorbot"	// Floorbots
#define CLEAN_BOT			"Cleanbot"	// Cleanbots
#define MED_BOT				"Medibot"	// Medibots
#define HONK_BOT			"Honkbot"	// Honkbots
#define GRIEF_BOT			"Grief"	// Griefsky

//Sentience types
#define SENTIENCE_ORGANIC 1
#define SENTIENCE_ARTIFICIAL 2
#define SENTIENCE_OTHER 3
#define SENTIENCE_MINEBOT 4
#define SENTIENCE_BOSS 5

// Medbot voice keys
#define MEDIBOT_VOICED_HOLD_ON "Hey, %TARGET%! Hold on, I'm coming."
#define MEDIBOT_VOICED_WANT_TO_HELP "Wait, %TARGET%! I want to help!"
#define MEDIBOT_VOICED_YOU_ARE_INJURED "%TARGET%, you appear to be injured!"

#define MEDIBOT_VOICED_ALL_PATCHED_UP "All patched up!"
#define MEDIBOT_VOICED_APPLE_A_DAY "An apple a day keeps me away."
#define MEDIBOT_VOICED_FEEL_BETTER "Feel better soon!"

#define MEDIBOT_VOICED_STAY_WITH_ME	"No! Stay with me!"
#define MEDIBOT_VOICED_LIVE	"Live, damnit! LIVE!"
#define MEDIBOT_VOICED_NEVER_LOST "I...I've never lost a patient before. Not today, I mean."

#define MEDIBOT_VOICED_DELICIOUS "Delicious!"
#define MEDIBOT_VOICED_PLASTIC_SURGEON "I knew it, I should've been a plastic surgeon."
#define MEDIBOT_VOICED_MASK_ON "Radar, put a mask on!"
#define MEDIBOT_VOICED_ALWAYS_A_CATCH "There's always a catch, and I'm the best there is."
#define MEDIBOT_VOICED_LIKE_FLIES "What kind of medbay is this? Everyone's dropping like flies."

#define MEDIBOT_VOICED_FUCK_YOU	"Fuck you."
