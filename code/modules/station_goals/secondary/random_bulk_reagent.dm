/datum/station_goal/secondary/random_bulk_reagent
	name = "Random Bulk Reagent"
	progress_type = /datum/secondary_goal_progress/random_bulk_reagent
	var/datum/reagent/reagent_type
	var/amount
	var/account
	var/reward

/datum/station_goal/secondary/random_bulk_reagent/randomize_params()
	var/list/valid_reagents = list()
	for(var/R in subtypesof(/datum/reagent))
		var/datum/reagent/candidate = R
		if(initial(candidate.goal_department) != department)
			continue
		if(initial(candidate.goal_difficulty) == REAGENT_GOAL_SKIP)
			continue
		valid_reagents += candidate

	if(!valid_reagents)
		reagent_type = /datum/reagent/water
		amount = 100
		return

	reagent_type = pick(valid_reagents)
	switch(initial(reagent_type.goal_difficulty))
		if(REAGENT_GOAL_EASY)
			amount = 1000
		if(REAGENT_GOAL_NORMAL)
			amount = 300
		else  // REAGENT_GOAL_HARD
			amount = 50

/datum/secondary_goal_progress/random_bulk_reagent
	var/datum/reagent/reagent_type
	var/needed
	var/sent = 0
	var/account
	var/reward

/datum/secondary_goal_progress/random_bulk_reagent/configure(datum/station_goal/secondary/random_bulk_reagent/goal)
	reagent_type = goal.reagent_type
	needed = goal.amount
	account = goal.account
	reward = goal.reward

/datum/secondary_goal_progress/random_bulk_reagent/Copy()
	var/datum/secondary_goal_progress/random_bulk_reagent/copy = new
	copy.reagent_type = reagent_type
	copy.needed = needed
	copy.sent = sent
	copy.account = account
	copy.reward = reward
	return copy

/datum/secondary_goal_progress/random_bulk_reagent/update(atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest = null)
	if(!istype(AM, /obj/item/reagent_containers))
		return

	var/obj/item/reagent_containers/container = AM
	var/amount = container.reagents.get_reagent_amount(initial(reagent_type.id))
	if(!amount)
		return
	sent += amount
	if(!manifest)
		return COMSIG_CARGO_SELL_PRIORITY

	var/datum/economy/line_item/item = new
	item.account = account
	item.credits = 0
	item.reason = "Received [amount] units of [initial(reagent_type.name)]."
	item.zero_is_good = TRUE
	manifest.line_items += item

	return COMSIG_CARGO_SELL_PRIORITY

/datum/secondary_goal_progress/random_bulk_reagent/check_complete(datum/economy/cargo_shuttle_manifest/manifest)
	if(sent < needed)
		return

	var/datum/economy/line_item/supply_item = new
	supply_item.account = SSeconomy.cargo_account
	supply_item.credits = reward / 2
	supply_item.reason = "Secondary goal complete: [needed] units of [initial(reagent_type.name)]."
	manifest.line_items += supply_item

	var/datum/economy/line_item/department_item = new
	department_item.account = account
	department_item.credits = reward / 2
	department_item.reason = "Secondary goal complete: [needed] units of [initial(reagent_type.name)]."
	manifest.line_items += department_item

	return TRUE
