/**
 * Contractors
 */
// Contract Statuses
/// The contract is invalid for some reason and cannot be taken. It may be made valid later.
#define CONTRACT_STATUS_INVALID -1
/// The contract hasn't been started yet.
#define CONTRACT_STATUS_INACTIVE 0
/// The contract is in progress.
#define CONTRACT_STATUS_ACTIVE 1
/// The contract has been completed successfully.
#define CONTRACT_STATUS_COMPLETED 2
/// The contract failed for some reason.
#define CONTRACT_STATUS_FAILED 3

// Difficulties. Note that they follow each other numerically and should stay that way as some code relies on that.
/// Easy difficulty area to extract the kidnapee. Low rewards.
#define EXTRACTION_DIFFICULTY_EASY 1
/// Medium difficulty area to extract the kidnapee. Moderate rewards.
#define EXTRACTION_DIFFICULTY_MEDIUM 2
/// Hard difficulty area to extract the kidnapee. High rewards.
#define EXTRACTION_DIFFICULTY_HARD 3

/// The name of the strings file containing data to use for contract fluff texts.
#define CONTRACT_STRINGS_WANTED "syndicate_wanted_messages.json"
/// JSON string file for all of our heretic influence flavors
#define HERETIC_INFLUENCE_FILE "heretic_influences.json"

// UI page numbers.
#define HUB_PAGE_CONTRACTS 1
#define HUB_PAGE_SHOP 2

GLOBAL_DATUM(prisoner_belongings, /obj/structure/closet/secure_closet/contractor)
GLOBAL_LIST(contractors)

/**
 * Traitors
 */
#define UPLINK_SPECIAL_SPAWNING "ONE PINK CHAINSAW PLEASE"

/**
 * Changelings
 */
// Defines below to be used with the changeling action's `power_type` var.
/// Denotes that this power is free and should be given to all changelings by default.
#define CHANGELING_INNATE_POWER			1
/// Denotes that this power can only be obtained by purchasing it.
#define CHANGELING_PURCHASABLE_POWER	2
/// Denotes that this power can not be obtained normally. Primarily used for base types such as [/datum/action/changeling/weapon].
#define CHANGELING_UNOBTAINABLE_POWER	3

#define CHANGELING_FAKEDEATH_TIME				50 SECONDS
#define CHANGELING_ABSORB_RECENT_SPEECH			8	//The amount of recent spoken lines to gain on absorbing a mob

/**
 * Abductors
 */

#define ABDUCTOR_VEST_STEALTH 1
#define ABDUCTOR_VEST_COMBAT 2

/**
 * Pulse Demon
 */
#define PULSEDEMON_SOURCE_DRAIN_INVALID (-1)

/**
 * Objectives
 */
#define THEFT_FLAG_SPECIAL 1 // Unused, maybe someone will use it some day, I'll leave it here for the children
#define THEFT_FLAG_UNIQUE 2

/**
 * IS_ANTAG defines
 */
#define IS_CHANGELING(mob) (isliving(mob) && mob?:mind?:has_antag_datum(/datum/antagonist/changeling))

#define IS_MINDFLAYER(mob) (isliving(mob) && mob?:mind?:has_antag_datum(/datum/antagonist/mindflayer))

#define IS_MINDSLAVE(mob) (ishuman(mob) && mob?:mind?:has_antag_datum(/datum/antagonist/mindslave, FALSE))

/**
 * Heretic checks
 */

/// Checks if the given mob is a heretic.
#define IS_HERETIC(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic))

/// Check if the given mob is a heretic monster.
#define IS_HERETIC_MONSTER(mob) (mob.mind?.has_antag_datum(/datum/antagonist/mindslave/heretic_monster))
/// Checks if the given mob is either a heretic, heretic monster.
#define IS_HERETIC_OR_MONSTER(mob) (IS_HERETIC(mob) || IS_HERETIC_MONSTER(mob))
/// CHecks if the given mob is in the mansus realm
#define IS_IN_MANSUS(mob) (istype(get_area(mob), /area/centcom/heretic_sacrifice))


// Heretic path defines.
#define PATH_START "Start Path"
#define PATH_SIDE "Side Path"
#define PATH_ASH "Ash Path"
#define PATH_RUST "Rust Path"
#define PATH_FLESH "Flesh Path"
#define PATH_VOID "Void Path"
#define PATH_BLADE "Blade Path"
#define PATH_COSMIC "Cosmic Path"
#define PATH_LOCK "Lock Path"
#define PATH_MOON "Moon Path"

//Heretic knowledge tree defines
#define HKT_NEXT "next"
#define HKT_BAN "ban"
#define HKT_DEPTH "depth"
#define HKT_ROUTE "route"
#define HKT_UI_BGR "ui_bgr"


/// Defines are used in /proc/has_living_heart() to report if the heretic has no heart period, no living heart, or has a living heart.
#define HERETIC_NO_HEART_ORGAN (-1)
#define HERETIC_NO_LIVING_HEART 0
#define HERETIC_HAS_LIVING_HEART 1

/// A define used in ritual priority for heretics.
#define MAX_KNOWLEDGE_PRIORITY 100

/// Checks if the passed mob can become a heretic ghoul.
/// - Must be a human (type, not species)
/// - Skeletons cannot be husked (they are snowflaked instead of having a trait)
/// - Monkeys are monkeys, not quite human (balance reasons)
#define IS_VALID_GHOUL_MOB(mob) (ishuman(mob) && !isskeleton(mob) && !ismonkeybasic(mob))

/**
 * Objective targeting flags
 */

/// Objective target must be mindshielded if possible
#define MINDSHIELDED_TARGET		(1<<0)
/// Objective target must be non-mindshielded if possible
#define UNMINDSHIELDED_TARGET	(1<<1)
/// Objective target must be a syndicate agent if possible
#define SYNDICATE_TARGET		(1<<2)

/**
 * Antag organizations
 */

/// Antag hunting antag. Might help security overall.
#define ORG_CHAOS_HUNTER "chaos_hunter"
/// Will steal items/kill low importance crew, usually not much trouble
#define ORG_CHAOS_MILD "chaos_mild"
/// Your average tator, will be an issue
#define ORG_CHAOS_AVERAGE "chaos_average"
/// Hijack or hijack-tier antagonists.
#define ORG_CHAOS_HIJACK "chaos_hijack"

#define ORG_PROB_HUNTER 10
#define ORG_PROB_MILD 20
#define ORG_PROB_AVERAGE 65
#define ORG_PROB_HIJACK 5

// Chance that a traitor will receive a 'You are being targeted by another syndicate agent' notification regardless of being an actual target
#define ORG_PROB_PARANOIA 5

/// How often a biohazard's population is recorded after the event fires.
#define BIOHAZARD_POP_INTERVAL 5 MINUTES
/// The string version of the interval for use in blackbox key names.
#define BIOHAZARD_POP_INTERVAL_STR "5min"

// Chance that any one traitor gets an extra exchange objective, will automatically pair with another tot
#define EXCHANGE_PROBABILITY 5
#define EXCHANGE_TEAM_RED "red"
#define EXCHANGE_TEAM_BLUE "blue"
