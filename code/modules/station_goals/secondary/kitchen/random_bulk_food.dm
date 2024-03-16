/datum/station_goal/secondary/random_bulk_food
	name = "Random Bulk Food"
	department = "Kitchen"
	progress_type = /datum/secondary_goal_progress/random_bulk_food
	abstract = FALSE
	var/obj/item/food/snacks/food_type
	var/amount

/datum/station_goal/secondary/random_bulk_food/randomize_params()
	var/list/valid_food = list()
	for(var/S in subtypesof(/obj/item/food/snacks))
		var/obj/item/food/snacks/candidate = S
		if(initial(candidate.goal_difficulty) == FOOD_GOAL_SKIP)
			continue
		valid_food += candidate

	if(!valid_food)
		food_type = /obj/item/food/snacks/cheesewedge
		amount = 50
		return

	food_type = pick(valid_food)
	switch(initial(food_type.goal_difficulty))
		if(FOOD_GOAL_EASY)
			amount = 50
		if(FOOD_GOAL_NORMAL)
			amount = 20
		else  // FOOD_GOAL_HARD
			amount = 5

	report_message = "Someone spiked the water cooler at CC with Space Drugs again, and we all have a craving for [initial(food_type.name)]. Please send us [amount] servings of it."

/datum/secondary_goal_progress/random_bulk_food
	var/obj/item/food/snacks/food_type
	var/needed
	var/sent = 0
	var/sent_this_shipment = 0

/datum/secondary_goal_progress/random_bulk_food/configure(datum/station_goal/secondary/random_bulk_food/goal)
	food_type = goal.food_type
	needed = goal.amount

/datum/secondary_goal_progress/random_bulk_food/Copy()
	var/datum/secondary_goal_progress/random_bulk_food/copy = new
	copy.food_type = food_type
	copy.needed = needed
	copy.sent = sent
	return copy

/datum/secondary_goal_progress/random_bulk_food/start_shipment()
	sent_this_shipment = 0

/datum/secondary_goal_progress/random_bulk_food/update(atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest = null)
	if(!istype(AM, food_type))
		return

	sent++
	sent_this_shipment++
	return COMSIG_CARGO_SELL_PRIORITY

/datum/secondary_goal_progress/random_bulk_food/check_complete(datum/economy/cargo_shuttle_manifest/manifest)
	if(sent_this_shipment > 0)
		var/datum/economy/line_item/update_item = new
		update_item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE)
		update_item.credits = 0
		update_item.zero_is_good = TRUE
		update_item.reason = "Received [sent_this_shipment] servings of [initial(food_type.name)]."
		manifest.line_items += update_item

	if(sent < needed)
		return

	var/datum/economy/line_item/supply_item = new
	supply_item.account = SSeconomy.cargo_account
	supply_item.credits = 50
	supply_item.reason = "Secondary goal complete: [needed] servings of [initial(food_type.name)]."
	manifest.line_items += supply_item

	var/datum/economy/line_item/department_item = new
	department_item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE)
	department_item.credits = 50
	department_item.reason = "Secondary goal complete: [needed] servings of [initial(food_type.name)]."
	manifest.line_items += department_item

	return TRUE
