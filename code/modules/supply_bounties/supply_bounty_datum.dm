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
	var/obj/bounty_target_type
	/// How much of the item is needed for the bounty
	var/quantity = SUPPLY_BOUNTY_QUANTITY_ONE
	/// How much is rewarded for supplying the bounty item
	var/reward = SUPPLY_BOUNTY_REWARD_CHEAP
	/// How much have been supplied
	var/amount_supplied = 0
	/// If there is a special reward, what is it?
	var/special_reward_type

