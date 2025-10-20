/datum/station_goal/secondary/variety_reagent
	name = "Variety of Reagent"
	progress_type = /datum/secondary_goal_progress/variety_reagent
	var/different_types = 10
	var/amount_per = 50
	var/department_account
	var/generic_name_plural = "reagents"
	var/reward

/datum/station_goal/secondary/variety_reagent/Initialize(requester_account)
	reward = SSeconomy.credits_per_variety_reagent_goal
	..()
	admin_desc = "[amount_per] units of [different_types] [generic_name_plural]"


/datum/secondary_goal_progress/variety_reagent
	var/list/reagents_sent = list()
	var/department
	var/needed
	var/amount_per
	var/department_account
	var/reward
	var/generic_name_plural

/datum/secondary_goal_progress/variety_reagent/configure(datum/station_goal/secondary/variety_reagent/goal)
	..()
	department = goal.department
	needed = goal.different_types
	amount_per = goal.amount_per
	department_account = goal.department_account
	reward = goal.reward
	generic_name_plural = goal.generic_name_plural

/datum/secondary_goal_progress/variety_reagent/Copy()
	var/datum/secondary_goal_progress/variety_reagent/copy = ..()
	copy.reagents_sent = reagents_sent.Copy()
	copy.department = department
	copy.needed = needed
	copy.amount_per = amount_per
	// These ones aren't really needed in the intended use case, they're
	// just here in case someone uses this method somewhere else.
	copy.department_account = department_account
	copy.reward = reward
	copy.generic_name_plural = generic_name_plural
	return copy

/datum/secondary_goal_progress/variety_reagent/update(atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest = null)
	// Not properly labeled for this goal? Ignore.
	if(!check_goal_label(AM))
		return

	// No reagents? Ignore.
	if(!AM.reagents?.reagent_list)
		return

	var/datum/reagent/reagent = AM.reagents.get_master_reagent()

	// Make sure it's for our department.
	if(!reagent || reagent.goal_department != department)
		return

	// Isolated reagents only, please.
	if(length(AM.reagents.reagent_list) != 1)
		if(!manifest)
			return COMSIG_CARGO_SELL_WRONG
		SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "mixed reagents"))
		var/datum/economy/line_item/item = new
		item.account = department_account
		item.credits = 0
		item.reason = "That [reagent.name] seems to be mixed with something else. Send it by itself, please."
		item.requests_console_department = department
		manifest.line_items += item
		return COMSIG_CARGO_SELL_WRONG

	// No easy reagents allowed.
	if(reagent.goal_difficulty == REAGENT_GOAL_SKIP)
		if(!manifest)
			return COMSIG_CARGO_SELL_WRONG
		SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "boring reagents"))
		var/datum/economy/line_item/item = new
		item.account = department_account
		item.credits = 0
		item.reason = "We don't need [reagent.name]. Send something better."
		item.requests_console_department = department
		manifest.line_items += item
		return COMSIG_CARGO_SELL_WRONG

	if(reagents_sent[reagent.id] >= amount_per)
		if(!manifest)
			return COMSIG_CARGO_SELL_WRONG
		SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "repeat reagents"))
		var/datum/economy/line_item/item = new
		item.account = department_account
		item.credits = 0
		item.reason = "You already sent us enough [reagent.name]."
		item.requests_console_department = department
		manifest.line_items += item
		return COMSIG_CARGO_SELL_WRONG

	reagents_sent[reagent.id] = (reagents_sent[reagent.id] ? reagents_sent[reagent.id] + reagent.volume : reagent.volume)

	if(!manifest)
		return COMSIG_CARGO_SELL_PRIORITY
	SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "valid reagents"))
	SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "reagents", reagent.id))
	var/datum/economy/line_item/item = new
	item.account = department_account
	item.credits = 0
	item.reason = "Received [reagent.volume]u of [initial(reagent.name)]."
	item.requests_console_department = department
	item.zero_is_good = TRUE
	manifest.line_items += item
	return COMSIG_CARGO_SELL_PRIORITY

/datum/secondary_goal_progress/variety_reagent/check_complete(datum/economy/cargo_shuttle_manifest/manifest)
	if(length(reagents_sent) < needed)
		return
	var/single_reagent
	var/reagents_tally = 0
	for(single_reagent in reagents_sent)
		reagents_tally += (reagents_sent[single_reagent] >= amount_per ? 1 : 0)
	if(reagents_tally < needed)
		return

	three_way_reward(manifest, department, department_account, reward, "Secondary goal complete: [needed] different [generic_name_plural].")
	return TRUE
