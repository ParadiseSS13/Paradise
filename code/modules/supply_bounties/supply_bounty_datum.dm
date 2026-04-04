#define SUPPLY_BOUNTY_QUANTITY_ONE 1
#define SUPPLY_BOUNTY_QUANTITY_LOW 3
#define SUPPLY_BOUNTY_QUANTITY_MEDIUM 5
#define SUPPLY_BOUNTY_QUANTITY_HIGH 10
#define SUPPLY_BOUNTY_QUANTITY_BULK 25

#define SUPPLY_BOUNTY_REWARD_CHEAP 25
#define SUPPLY_BOUNTY_REWARD_LOW 50
#define SUPPLY_BOUNTY_REWARD_MEDIUM 75
#define SUPPLY_BOUNTY_REWARD_HIGH 100
#define SUPPLY_BOUNTY_REWARD_GRAND 200

/datum/supply_bounty
	/// Bounty name as it shows on the console.
	var/name = "supply bounty"
	/// Type of object demanded by the bounty
	var/bounty_target_type
	/// Does it need to be the exact item type?
	var/exact_type = FALSE
	/// How much of the item is needed for the bounty
	var/quantity = SUPPLY_BOUNTY_QUANTITY_ONE
	/// How much is rewarded for supplying the bounty item
	var/reward = SUPPLY_BOUNTY_REWARD_CHEAP
	/// How much have been supplied
	var/amount_supplied = 0
	/// If there is a special reward, what is it?
	var/special_reward_type
	/// Flavor reason for the bounty
	var/reason = "Central Command says so."

/datum/supply_bounty/New(type_input, exact_input = FALSE, quantity_input = SUPPLY_BOUNTY_QUANTITY_ONE, reward_input = SUPPLY_BOUNTY_REWARD_CHEAP, special_reward_type_input = null)
	. = ..()
	reason = GenerateReason()
	bounty_target_type = type_input
	exact_type = exact_input
	quantity = quantity_input
	reward = reward_input
	special_reward_type = special_reward_type_input

/datum/supply_bounty/proc/GenerateReason()
	var/faction = pick("Central Command", "The Trans-Solar Federation", "The USSP")
	return pick("[faction] has made an urgent request for [bounty_target_type.name]. Payment guaranteed.",
		"[faction] has experienced a recent disaster and needs [bounty_target_type.name] in order to re-establish order.",
		"[faction] has offered to pay a decent sum of credits if we can supply them with [bounty_target_type.name].",
		"An anonymous buyer has placed a bid on [bounty_target_type.name].",
		"[faction] is offering a reward for [bounty_target_type.name]."
	)
