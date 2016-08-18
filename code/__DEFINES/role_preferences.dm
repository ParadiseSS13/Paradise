

//Values for antag preferences, event roles, etc. unified here



//These are synced with the Database, if you change the values of the defines
//then you MUST update the database!
// If you're adding a new role, remember to update modules/admin/topic.dm, so admins can dish out
// justice if someone's abusing your role
#define ROLE_TRAITOR			"traitor"
#define ROLE_OPERATIVE			"operative"
#define ROLE_CHANGELING			"changeling"
#define ROLE_WIZARD				"wizard"
#define ROLE_REV				"revolutionary"
#define ROLE_ALIEN				"xenomorph"
#define ROLE_PAI				"pAI"
#define ROLE_CULTIST			"cultist"
#define ROLE_BLOB				"blob"
#define ROLE_NINJA				"space ninja"
#define ROLE_MONKEY				"monkey"
#define ROLE_GANG				"gangster"
#define ROLE_SHADOWLING			"shadowling"
#define ROLE_ABDUCTOR			"abductor"
#define ROLE_REVENANT			"revenant"
#define ROLE_HOG_GOD			"hand of god: god" // We're prolly gonna port this one day or another
#define ROLE_HOG_CULTIST		"hand of god: cultist"
#define ROLE_RAIDER				"vox raider"
#define ROLE_TRADER				"trader"
#define ROLE_VAMPIRE			"vampire"
// Role tags for EVERYONE!
#define ROLE_BORER				"cortical borer"
#define ROLE_DEMON				"slaughter demon"
#define ROLE_SENTIENT			"sentient animal"
#define ROLE_POSIBRAIN			"positronic brain"
#define ROLE_GUARDIAN			"guardian"
#define ROLE_MORPH				"morph"
#define ROLE_ERT				"emergency response team"
#define ROLE_NYMPH				"Dionaea"


//Missing assignment means it's not a gamemode specific role, IT'S NOT A BUG OR ERROR.
//The gamemode specific ones are just so the gamemodes can query whether a player is old enough
//(in game days played) to play that role
var/global/list/special_roles = list(
	ROLE_TRAITOR = /datum/game_mode/traitor,
	ROLE_OPERATIVE = /datum/game_mode/nuclear,
	ROLE_CHANGELING = /datum/game_mode/changeling,
	ROLE_WIZARD = /datum/game_mode/wizard,
	ROLE_REV = /datum/game_mode/revolution,
	ROLE_ALIEN,
	ROLE_PAI,
	ROLE_CULTIST = /datum/game_mode/cult,
	ROLE_BLOB = /datum/game_mode/blob,
	ROLE_NINJA,
//	ROLE_MONKEY = /datum/game_mode/monkey, Sooner or later these are going to get ported
//	ROLE_GANG = /datum/game_mode/gang,
	ROLE_SHADOWLING = /datum/game_mode/shadowling,
	ROLE_ABDUCTOR = /datum/game_mode/abduction,
//	ROLE_HOG_GOD = /datum/game_mode/hand_of_god,
//	ROLE_HOG_CULTIST = /datum/game_mode/hand_of_god,
	ROLE_RAIDER = /datum/game_mode/heist,
	ROLE_VAMPIRE = /datum/game_mode/vampire,
	ROLE_BORER,
	ROLE_DEMON,
	ROLE_SENTIENT,
	ROLE_POSIBRAIN,
	ROLE_REVENANT,
	ROLE_GUARDIAN,
	ROLE_MORPH,
	ROLE_TRADER,
)
