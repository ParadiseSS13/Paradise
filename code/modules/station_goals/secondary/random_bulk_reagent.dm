/datum/station_goal/secondary/random_bulk_reagent
	name = "Random Bulk Reagent"
	progress_type = /datum/secondary_goal_progress/random_bulk_reagent
	var/datum/reagent/reagent_type
	var/amount
	var/department_account
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
			reward = SSeconomy.credits_per_easy_reagent_goal
		if(REAGENT_GOAL_NORMAL)
			amount = 300
			reward = SSeconomy.credits_per_normal_reagent_goal
		else  // REAGENT_GOAL_HARD
			amount = 50
			reward = SSeconomy.credits_per_hard_reagent_goal

/datum/secondary_goal_progress/random_bulk_reagent
	var/datum/reagent/reagent_type
	var/needed
	var/sent = 0
	var/department
	var/department_account
	var/reward

/datum/secondary_goal_progress/random_bulk_reagent/configure(datum/station_goal/secondary/random_bulk_reagent/goal)
	..(goal)
	reagent_type = goal.reagent_type
	needed = goal.amount
	department = goal.department
	department_account = goal.department_account
	reward = goal.reward

/datum/secondary_goal_progress/random_bulk_reagent/Copy()
	var/datum/secondary_goal_progress/random_bulk_reagent/copy = new
	copy.reagent_type = reagent_type
	copy.needed = needed
	copy.sent = sent
	// These ones aren't really needed in the intended use case, they're
	// just here in case someone uses this method somewhere else.
	copy.department = department
	copy.department_account = department_account
	copy.personal_account = personal_account
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
	item.account = department_account
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
	supply_item.credits = reward / 3
	supply_item.reason = "Secondary goal complete: [needed] units of [initial(reagent_type.name)]."
	manifest.line_items += supply_item

	var/datum/economy/line_item/department_item = new
	department_item.account = department_account
	department_item.credits = reward / 3
	department_item.reason = "Secondary goal complete: [needed] units of [initial(reagent_type.name)]."
	manifest.line_items += department_item

	var/datum/economy/line_item/personal_item = new
	personal_item.account = personal_account || department_account
	personal_item.credits = reward / 3
	personal_item.reason = "Secondary goal complete: [needed] units of [initial(reagent_type.name)]."
	manifest.line_items += personal_item

	send_requests_console_message(personal_item.reason, "Central Command", department, "Stamped with the Central Command rubber stamp.", null, RQ_NORMALPRIORITY)
	return TRUE
