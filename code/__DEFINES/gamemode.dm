//objective defines
#define TARGET_INVALID_IS_OWNER		1
#define TARGET_INVALID_NOT_HUMAN	2
#define TARGET_INVALID_DEAD			3
#define TARGET_INVALID_NOCKEY		4
#define TARGET_INVALID_UNREACHABLE	5
#define TARGET_INVALID_GOLEM		6
#define TARGET_INVALID_EVENT		7

//gamemode istype helpers
#define GAMEMODE_IS_BLOB		(ticker && istype(ticker.mode, /datum/game_mode/blob))
#define GAMEMODE_IS_CULT		(ticker && istype(ticker.mode, /datum/game_mode/cult))
#define GAMEMODE_IS_HEIST		(ticker && istype(ticker.mode, /datum/game_mode/heist))
#define GAMEMODE_IS_NATIONS		(ticker && istype(ticker.mode, /datum/game_mode/nations))
#define GAMEMODE_IS_NUCLEAR		(ticker && istype(ticker.mode, /datum/game_mode/nuclear))
#define GAMEMODE_IS_REVOLUTION	(ticker && istype(ticker.mode, /datum/game_mode/revolution))
#define GAMEMODE_IS_WIZARD		(ticker && istype(ticker.mode, /datum/game_mode/wizard))

//special roles
// Distinct from the ROLE_X defines because some antags have multiple special roles but only one ban type
#define SPECIAL_ROLE_ABDUCTOR_AGENT "Abductor Agent"
#define SPECIAL_ROLE_ABDUCTOR_SCIENTIST "Abductor Scientist"
#define SPECIAL_ROLE_BLOB "Blob"
#define SPECIAL_ROLE_BLOB_OVERMIND "Blob Overmind"
#define SPECIAL_ROLE_BORER "Borer"
#define SPECIAL_ROLE_CHANGELING "Changeling"
#define SPECIAL_ROLE_CULTIST "Cultist"
#define SPECIAL_ROLE_DEATHSQUAD "Death Commando"
#define SPECIAL_ROLE_ERT "Response Team"
#define SPECIAL_ROLE_FREE_GOLEM "Free Golem"
#define SPECIAL_ROLE_GOLEM "Golem"
#define SPECIAL_ROLE_HEAD_REV "Head Revolutionary"
#define SPECIAL_ROLE_HONKSQUAD "Honksquad"
#define SPECIAL_ROLE_REV "Revolutionary"
#define SPECIAL_ROLE_MORPH "Morph"
#define SPECIAL_ROLE_MULTIVERSE "Multiverse Traveller"
#define SPECIAL_ROLE_NUKEOPS "Syndicate"
#define SPECIAL_ROLE_RAIDER "Vox Raider"
#define SPECIAL_ROLE_REVENANT "Revenant"
#define SPECIAL_ROLE_SHADOWLING "Shadowling"
#define SPECIAL_ROLE_SHADOWLING_THRALL "Shadowling Thrall"
#define SPECIAL_ROLE_SLAUGHTER_DEMON "Slaughter Demon"
#define SPECIAL_ROLE_SUPER "Super"
#define SPECIAL_ROLE_SYNDICATE_DEATHSQUAD "Syndicate Commando"
#define SPECIAL_ROLE_TRAITOR "Traitor"
#define SPECIAL_ROLE_VAMPIRE "Vampire"
#define SPECIAL_ROLE_VAMPIRE_THRALL "Vampire Thrall"
#define SPECIAL_ROLE_WIZARD "Wizard"
#define SPECIAL_ROLE_WIZARD_APPRENTICE "Wizard Apprentice"
#define SPECIAL_ROLE_XENOMORPH "Xenomorph"
#define SPECIAL_ROLE_XENOMORPH_QUEEN "Xenomorph Queen"
#define SPECIAL_ROLE_XENOMORPH_HUNTER "Xenomorph Hunter"
#define SPECIAL_ROLE_XENOMORPH_DRONE "Xenomorph Drone"
#define SPECIAL_ROLE_XENOMORPH_SENTINEL "Xenomorph Sentinel"
#define SPECIAL_ROLE_XENOMORPH_LARVA "Xenomorph Larva"
#define SPECIAL_ROLE_EVENTMISC "Event Role"