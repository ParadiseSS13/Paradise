// ADDING A NEW BOUNTY
// new /datum/supply_bounty(TYPE, IS_EXACT, QUANTITY, REWARD, EXTRA REWARD)
/// List of all bounty datums.
GLOBAL_LIST_INIT(supply_bounties, alist(
	/// GENERAL
	new /datum/supply_bounty(/obj/item/folder, 				FALSE, 			SUPPLY_BOUNTY_QUANTITY_MEDIUM, 		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/pen, 				FALSE, 			SUPPLY_BOUNTY_QUANTITY_MEDIUM, 		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/paper_bin, 			FALSE, 			SUPPLY_BOUNTY_QUANTITY_LOW, 		SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/stamp/granted, 		FALSE, 			SUPPLY_BOUNTY_ONE, 					SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/stamp/denied, 		FALSE, 			SUPPLY_BOUNTY_ONE, 					SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/toner, 				FALSE, 			SUPPLY_BOUNTY_QUANTITY_LOW, 		SUPPLY_BOUNTY_REWARD_MEDIUM),

	// SUPPLY
	new /datum/supply_bounty(/obj/item/wrench, 				TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH, 		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/crowbar, 			TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH, 		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/screwdriver, 		TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH, 		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/wirecutters, 		TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH, 		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/multitool, 			TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH, 		SUPPLY_BOUNTY_REWARD_LOW),

	// SERVICE


	// SCIENCE


	// MEDICAL


	// SECURITY


	)
)
