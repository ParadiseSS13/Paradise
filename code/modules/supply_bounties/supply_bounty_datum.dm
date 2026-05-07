/datum/supply_bounty
	/// Bounty name as it shows on the console.
	var/name = "supply bounty"
	/// Type of object demanded by the bounty
	var/bounty_target_type
	/// Does it need to be the exact item type?
	var/exact_type = FALSE
	/// How much of the item is needed for the bounty
	var/quantity = 1
	/// How much is rewarded for supplying the bounty item
	var/reward = 25
	/// How much have been supplied
	var/amount_supplied = 0
	/// If there is a special reward, what is it?
	var/special_reward_type
	/// Flavor reason for the bounty
	var/reason = "Central Command says so."

/datum/supply_bounty/New(type_input, exact_input = FALSE, quantity_input = 1, reward_input = 25, special_reward_type_input = null)
	. = ..()
	bounty_target_type = type_input
	exact_type = exact_input
	quantity = quantity_input
	reward = reward_input
	special_reward_type = special_reward_type_input

/datum/supply_bounty/proc/GenerateName()
	var/first = pick("Urgent ", "Standard ", "General ", "Routine ", "Priority ", "Basic ", "Immediate ", "Regular ", "")
	var/second = pick("Supply", "Item", "Resource", "Product", "Asset", "Package", "Stock", "Unit", "Cache")
	var/third = pick("Request", "Order", "Inquiry", "Submission", "Ticket", "Entry", "Bounty", "Form", "Notice", "Demand")
	return "[first][second] [third]"

/datum/supply_bounty/proc/GenerateReason()
	var/faction = pick("Central Command", "The Trans-Solar Federation", "The USSP", "The Royal Domain of Qerballak", "The Hoorlm Coalition", "The Technocracy", "A Diona gestalt", "The Coalition for Progress of IPC Society ", "A Kidan Clan", "A community from Boron", "The Assembly", "The Nionic Trade League")
	return pick(list("[faction] has made an urgent request for [bounty_target_type]. Payment guaranteed.",
		"[faction] has experienced a recent disaster and needs [bounty_target_type] in order to re-establish order.",
		"[faction] has offered to pay a decent sum of credits if we can supply them with [bounty_target_type].",
		"An anonymous buyer has placed a bid on [bounty_target_type].",
		"[faction] is offering a reward for [bounty_target_type].",
		"A research team of [faction] has problems confirming our latest discovery, and require the same model of [bounty_target_type] we used.",
		">*AUTOMATED WAREHOUSE REQUEST* - ITEM(S):[bounty_target_type] - SEND TO:[faction] - REASON: Confidential - PAYMENT: Approved",
		"A clown troupe is performing its final act at an outpost of [faction]. They insist a mime agent has stolen their [bounty_target_type], the central piece of the show.",
		"A shipping carrier heading to [faction] is short on [bounty_target_type]. They have offered ample payment to \"fix\" their cargo manifest.",
		"A shortage of [bounty_target_type] at [faction] presents the perfect oportunity to sell at a markup."
		"The Captain of a fellow Nanotrasen Science Station in this sector has asked if your station has spare [bounty_target_type]."
		"A medical ship has sent out several requests for [bounty_target_type]. A plasma leak in a refueling station requires their servives, and have no time to dock at a supply outpost."
	))
