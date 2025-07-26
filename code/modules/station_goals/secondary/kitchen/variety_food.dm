/datum/station_goal/secondary/variety_food
	name = "Variety of Food"
	progress_type = /datum/secondary_goal_progress/variety_food
	department = "Kitchen"
	weight = 1
	/// How many different types of food are needed.
	var/different_types = 10
	/// How many of each food type are needed.
	var/amount_per = 3
	var/department_account
	var/generic_name_plural = "dishes"
	var/reward

/datum/station_goal/secondary/variety_food/randomize_params()
	..()
	department_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE)
	report_message = "We're holding a fundraising banquet, and we need a suitable spread of food for it. Send us at least [amount_per] servings of [different_types] different dishes."

/datum/station_goal/secondary/variety_food/Initialize(requester_account)
	reward = SSeconomy.credits_per_variety_food_goal
	..()
	admin_desc = "[amount_per] units of [different_types] [generic_name_plural]"

/datum/secondary_goal_progress/variety_food
	var/list/foods_sent = list()
	var/department
	var/needed
	var/amount_per
	var/department_account
	var/reward
	var/generic_name_plural

/datum/secondary_goal_progress/variety_food/configure(datum/station_goal/secondary/variety_food/goal)
	..()
	department = goal.department
	needed = goal.different_types
	amount_per = goal.amount_per
	department_account = goal.department_account
	reward = goal.reward
	generic_name_plural = goal.generic_name_plural

/datum/secondary_goal_progress/variety_food/Copy()
	var/datum/secondary_goal_progress/variety_food/copy = ..()
	copy.foods_sent = foods_sent.Copy()
	copy.department = department
	copy.needed = needed
	copy.amount_per = amount_per
	// These ones aren't really needed in the intended use case, they're
	// just here in case someone uses this method somewhere else.
	copy.department_account = department_account
	copy.reward = reward
	copy.generic_name_plural = generic_name_plural
	return copy

/datum/secondary_goal_progress/variety_food/update(obj/item/food/food, datum/economy/cargo_shuttle_manifest/manifest = null)
	// Not properly labeled for this goal? Ignore.
	if(!check_goal_label(food))
		return

	// Not food? Ignore.
	if(!istype(food))
		return

	// No easy foods allowed.
	if(food.goal_difficulty == FOOD_GOAL_SKIP)
		if(!manifest)
			return COMSIG_CARGO_SELL_WRONG
		SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "boring foods"))
		var/datum/economy/line_item/item = new
		item.account = department_account
		item.credits = 0
		item.reason = "We don't need [food.name]. Send something better."
		item.requests_console_department = "Kitchen"
		manifest.line_items += item
		return COMSIG_CARGO_SELL_WRONG

	if(foods_sent[food.type] >= amount_per)
		if(!manifest)
			return COMSIG_CARGO_SELL_WRONG
		SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "repeat foods"))
		var/datum/economy/line_item/item = new
		item.account = department_account
		item.credits = 0
		item.reason = "You already sent us enough [food.name]."
		item.requests_console_department = "Kitchen"
		manifest.line_items += item
		return COMSIG_CARGO_SELL_WRONG

	if(!foods_sent[food.type])
		foods_sent[food.type] = 0
	foods_sent[food.type]++

	if(!manifest)
		return COMSIG_CARGO_SELL_PRIORITY
	SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "valid foods"))
	SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "foods", initial(food.name)))
	var/datum/economy/line_item/item = new()
	item.account = department_account
	item.credits = 0
	item.reason = "Received [initial(food.name)]."
	item.zero_is_good = TRUE
	item.requests_console_department = "Kitchen"
	manifest.line_items += item
	return COMSIG_CARGO_SELL_PRIORITY

/datum/secondary_goal_progress/variety_food/check_complete(datum/economy/cargo_shuttle_manifest/manifest)
	var/complete_foods = 0
	for(var/food_type in foods_sent)
		if(foods_sent[food_type] >= amount_per)
			complete_foods++
			SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "complete foods"))

	if(complete_foods < needed)
		return FALSE

	three_way_reward(manifest, department, department_account, reward, "Secondary goal complete: [needed] different [generic_name_plural].")
	return TRUE
