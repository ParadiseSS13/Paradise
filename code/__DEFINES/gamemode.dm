//objective defines
#define TARGET_INVALID_IS_OWNER			1
#define TARGET_INVALID_NOT_HUMAN		2
#define TARGET_INVALID_DEAD				3
#define TARGET_INVALID_NOCKEY			4
#define TARGET_INVALID_UNREACHABLE		5
#define TARGET_INVALID_GOLEM			6
#define TARGET_INVALID_EVENT			7
#define TARGET_INVALID_IS_TARGET		8
#define TARGET_INVALID_BLACKLISTED		9
#define TARGET_INVALID_CHANGELING		10
#define TARGET_INVALID_NOTHEAD			11
#define TARGET_INVALID_CULTIST			12
#define TARGET_INVALID_CULT_CONVERTABLE	13
#define TARGET_CRYOING					14
#define TARGET_INVALID_HEAD				15
#define TARGET_INVALID_ANTAG			16

//gamemode istype helpers
#define GAMEMODE_IS_CULT		(SSticker && istype(SSticker.mode, /datum/game_mode/cult))
#define GAMEMODE_IS_HEIST		(SSticker && istype(SSticker.mode, /datum/game_mode/heist))
#define GAMEMODE_IS_NUCLEAR		(SSticker && istype(SSticker.mode, /datum/game_mode/nuclear))
#define GAMEMODE_IS_REVOLUTION	(SSticker && istype(SSticker.mode, /datum/game_mode/revolution))
#define GAMEMODE_IS_WIZARD		(SSticker && istype(SSticker.mode, /datum/game_mode/wizard))
#define GAMEMODE_IS_RAGIN_MAGES (SSticker && istype(SSticker.mode, /datum/game_mode/wizard/raginmages))

//special roles
// Distinct from the ROLE_X defines because some antags have multiple special roles but only one ban type
#define SPECIAL_ROLE_ABDUCTOR_AGENT "Abductor Agent"
#define SPECIAL_ROLE_ABDUCTOR_SCIENTIST "Abductor Scientist"
#define SPECIAL_ROLE_BLOB "Blob"
#define SPECIAL_ROLE_BLOB_OVERMIND "Blob Overmind"
#define SPECIAL_ROLE_CHANGELING "Changeling"
#define SPECIAL_ROLE_CULTIST "Cultist"
#define SPECIAL_ROLE_DEATHSQUAD "Deathsquad Commando"
#define SPECIAL_ROLE_ERT "Response Team"
#define SPECIAL_ROLE_FREE_GOLEM "Free Golem"
#define SPECIAL_ROLE_GOLEM "Golem"
#define SPECIAL_ROLE_HEAD_REV "Head Revolutionary"
#define SPECIAL_ROLE_REV "Revolutionary"
#define SPECIAL_ROLE_MORPH "Morph"
#define SPECIAL_ROLE_MULTIVERSE "Multiverse Traveller"
#define SPECIAL_ROLE_NUKEOPS "Syndicate"
#define SPECIAL_ROLE_PYROCLASTIC_SLIME 	"Pyroclastic Anomaly Slime"
#define SPECIAL_ROLE_REVENANT "Revenant"
#define SPECIAL_ROLE_DEMON "Demon"
#define SPECIAL_ROLE_SUPER "Super"
#define SPECIAL_ROLE_SYNDICATE_DEATHSQUAD "Syndicate Commando"
#define SPECIAL_ROLE_TRAITOR "Traitor"
#define SPECIAL_ROLE_VAMPIRE "Vampire"
#define SPECIAL_ROLE_MIND_FLAYER "Mind Flayer"
#define SPECIAL_ROLE_VAMPIRE_THRALL "Vampire Thrall"
#define SPECIAL_ROLE_WIZARD "Wizard"
#define SPECIAL_ROLE_WIZARD_APPRENTICE "Wizard Apprentice"
#define SPECIAL_ROLE_XENOMORPH "Xenomorph"
#define SPECIAL_ROLE_XENOMORPH_QUEEN "Xenomorph Queen"
#define SPECIAL_ROLE_XENOMORPH_HUNTER "Xenomorph Hunter"
#define SPECIAL_ROLE_XENOMORPH_DRONE "Xenomorph Drone"
#define SPECIAL_ROLE_XENOMORPH_SENTINEL "Xenomorph Sentinel"
#define SPECIAL_ROLE_XENOMORPH_LARVA "Xenomorph Larva"
#define SPECIAL_ROLE_ZOMBIE "Zombie"
#define SPECIAL_ROLE_TOURIST "Tourist"
#define SPECIAL_ROLE_EVENTMISC "Event Role"

// Constants used by code which checks the status of nuclear blasts during a
// round, regardless of original game mode, e.g. setting the ending cinematic.

/// The bomb is on-station.
#define NUKE_SITE_ON_STATION 0
/// The bomb is on station z-level, but not a station tile.
#define NUKE_SITE_ON_STATION_ZLEVEL 1
/// The bomb is off station z-level.
#define NUKE_SITE_OFF_STATION_ZLEVEL 2
/// The bomb's location cannot be found.
#define NUKE_SITE_INVALID 3

/**
 * Dynamic Gamemode Defines
 */
#define DYNAMIC_RULESET_NORMAL "Normal"
#define DYNAMIC_RULESET_FORCED "<b>Forced</b>"
#define DYNAMIC_RULESET_BANNED "<b>Banned</b>"

#define RULESET_FAILURE_BUDGET "Not enough budget"
#define RULESET_FAILURE_ANTAG_BUDGET "Not enough antag budget"
#define RULESET_FAILURE_NO_PLAYERS "No drafted players"
#define RULESET_FAILURE_MUTUAL_RULESET "No banned mutual rulesets"
#define RULESET_FAILURE_CHANGELING_SECONDARY_RULESET "Needs a secondary ruleset in rotation"
