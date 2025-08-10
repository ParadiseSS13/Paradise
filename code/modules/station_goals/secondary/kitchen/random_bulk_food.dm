/datum/station_goal/secondary/random_bulk_food
	name = "Random Bulk Food"
	department = "Kitchen"
	progress_type = /datum/secondary_goal_progress/random_bulk_food
	weight = 8
	var/obj/item/food/food_type
	var/amount
	var/reward

/datum/station_goal/secondary/random_bulk_food/randomize_params()
	var/list/valid_food = list()
	for(var/S in subtypesof(/obj/item/food))
		var/obj/item/food/candidate = S
		if(initial(candidate.goal_difficulty) == FOOD_GOAL_SKIP)
			continue
		if(initial(candidate.goal_difficulty) == FOOD_GOAL_EXCESSIVE)
			continue
		valid_food += candidate

	if(!valid_food)
		food_type = /obj/item/food/sliced/cheesewedge
		amount = 50
		return

	food_type = pick(valid_food)
	switch(initial(food_type.goal_difficulty))
		if(FOOD_GOAL_EASY)
			amount = 35
			reward = SSeconomy.credits_per_easy_food_goal
		if(FOOD_GOAL_NORMAL)
			amount = 15
			reward = SSeconomy.credits_per_normal_food_goal
		else  // FOOD_GOAL_HARD
			amount = 5
			reward = SSeconomy.credits_per_hard_food_goal

	report_message = "Someone spiked the water cooler at CC with Space Drugs again, and we all have a craving for [initial(food_type.name)]. Please send us [amount] servings of it."
	admin_desc = "[amount] servings of [initial(food_type.name)]"


/datum/secondary_goal_progress/random_bulk_food
	var/obj/item/food/food_type
	var/needed
	var/sent = 0
	var/sent_this_shipment = 0
	var/reward

/datum/secondary_goal_progress/random_bulk_food/configure(datum/station_goal/secondary/random_bulk_food/goal)
	..()
	food_type = goal.food_type
	needed = goal.amount
	reward = goal.reward

/datum/secondary_goal_progress/random_bulk_food/Copy()
	var/datum/secondary_goal_progress/random_bulk_food/copy = ..()
	copy.food_type = food_type
	copy.needed = needed
	copy.sent = sent
	// These ones aren't really needed in the intended use case, they're
	// just here in case someone uses this method somewhere else.
	copy.reward = reward
	return copy

/datum/secondary_goal_progress/random_bulk_food/start_shipment()
	sent_this_shipment = 0

/datum/secondary_goal_progress/random_bulk_food/update(atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest = null)
	// Not properly labeled for this goal? Ignore.
	if(!check_goal_label(AM))
		return

	if(!istype(AM, food_type))
		return

	sent++
	sent_this_shipment++
	return COMSIG_CARGO_SELL_PRIORITY

/datum/secondary_goal_progress/random_bulk_food/check_complete(datum/economy/cargo_shuttle_manifest/manifest)
	if(sent_this_shipment > 0)
		SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "food shipments", initial(food_type.name)))
		SSblackbox.record_feedback("nested tally", "secondary goals", sent_this_shipment, list(goal_name, "food servings", initial(food_type.name)))
		var/datum/economy/line_item/update_item = new
		update_item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE)
		update_item.credits = 0
		update_item.zero_is_good = TRUE
		update_item.reason = "Received [sent_this_shipment] servings of [initial(food_type.name)]."
		update_item.requests_console_department = "Kitchen"
		manifest.line_items += update_item

	if(sent < needed)
		return

	three_way_reward(manifest, "Kitchen", GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE), reward, "Secondary goal complete: [needed] units of [initial(food_type.name)].")
	return TRUE
