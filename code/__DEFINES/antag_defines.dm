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
