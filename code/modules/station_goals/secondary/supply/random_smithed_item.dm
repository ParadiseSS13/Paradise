/datum/station_goal/secondary/random_smithed_item
	name = "Random Smithed Item"
	department = "Smith"
	progress_type = /datum/secondary_goal_progress/random_smithed_item
	weight = 10
	var/obj/item/smithed_item/product_type
	/// What quality should the product be?
	var/datum/smith_quality/quality
	/// What should the material type be?
	var/datum/smith_material/material
	/// What do you get for accomplishing this goal (in credits)
	var/reward

/datum/station_goal/secondary/random_smithed_item/randomize_params()
	var/list/valid_types = list()
	for(var/S in subtypesof(/obj/item/smithed_item))
		var/obj/item/smithed_item/possible_item_type = S
		if(!possible_item_type.secondary_goal_candidate)
			continue
		valid_types += possible_item_type

	var/valid_qualities = list()
	for(var/Q in subtypesof(/datum/smith_quality))
		var/datum/smith_quality/possible_quality = Q
		if(!possible_quality.secondary_goal_candidate)
			continue
		valid_qualities += possible_quality

	var/valid_materials = list()
	for(var/M in subtypesof(/datum/smith_material))
		var/datum/smith_material/possible_material = M
		if(!possible_material.secondary_goal_candidate)
			continue
		valid_materials += possible_material

	if(!valid_types)
		product_type = /obj/item/smithed_item/insert/ballistic
	else
		product_type = pick(valid_types)

	if(!valid_qualities)
		quality = /datum/smith_quality
	else
		quality = pick(valid_qualities)

	if(!valid_materials)
		material = /datum/smith_material/metal
	else
		material = pick(valid_materials)

	switch(quality.secondary_goal_difficulty)
		if(SMITH_GOAL_EASY)
			reward += SSeconomy.credits_per_easy_smith_goal
		if(SMITH_GOAL_MEDIUM)
			reward += SSeconomy.credits_per_normal_smith_goal
		if(SMITH_GOAL_HARD)
			reward += SSeconomy.credits_per_hard_smith_goal
		else
			reward += SSeconomy.credits_per_easy_smith_goal
			log_debug("No valid quality reward selected for smith secondary goal.")

	switch(material.secondary_goal_difficulty)
		if(SMITH_GOAL_EASY)
			reward += SSeconomy.credits_per_easy_smith_goal
		if(SMITH_GOAL_MEDIUM)
			reward += SSeconomy.credits_per_normal_smith_goal
		if(SMITH_GOAL_HARD)
			reward += SSeconomy.credits_per_hard_smith_goal
		else
			reward += SSeconomy.credits_per_easy_smith_goal
			log_debug("No valid material reward selected for smith secondary goal.")

	report_message = "A situation came up that needs specialized equipment. We're going to need \a [quality.name] [material.name] [product_type.name]. You'll be rewarded handsomely for your work."
	admin_desc = "\A [quality.name] [material.name] [product_type.name] request."

/datum/secondary_goal_progress/random_smithed_item
	/// What item type is it?
	var/obj/item/smithed_item/product_type
	/// What quality should the product be?
	var/datum/smith_quality/quality
	/// What should the material type be?
	var/datum/smith_material/material
	/// What's the payout?
	var/reward
	var/sent = FALSE

/datum/secondary_goal_progress/random_smithed_item/configure(datum/station_goal/secondary/random_smithed_item/goal)
	..()
	product_type = goal.product_type
	quality = goal.quality
	material = goal.material
	reward = goal.reward

/datum/secondary_goal_progress/random_smithed_item/Copy()
	var/datum/secondary_goal_progress/random_smithed_item/copy = ..()
	copy.product_type = product_type
	copy.quality = quality
	copy.material = material
	copy.sent = sent
	copy.reward = reward
	return copy

/datum/secondary_goal_progress/random_smithed_item/proc/check_parameters(obj/item/smithed_item/product)
	// Type doesn't match
	if(!istype(product, product_type))
		return FALSE
	// Quality doesn't match
	if(!istype(product.quality, quality))
		return FALSE
	// Material doesn't match
	if(product.material != material)
		return FALSE
	return TRUE

/datum/secondary_goal_progress/random_smithed_item/update(atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest = null)
	// Not properly labeled for this goal? Ignore.
	if(!check_goal_label(AM))
		return

	if(!istype(AM, /obj/item/smithed_item))
		return

	if(!check_parameters(AM))
		if(!manifest)
			return COMSIG_CARGO_SELL_WRONG
		var/datum/economy/line_item/item = new
		item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SUPPLY)
		item.credits = 0
		item.reason = "[AM] does not have the right parameters."
		item.requests_console_department = "Smith"
		manifest.line_items += item
		return COMSIG_CARGO_SELL_WRONG

	sent = TRUE
	return COMSIG_CARGO_SELL_PRIORITY

/datum/secondary_goal_progress/random_smithed_item/check_complete(datum/economy/cargo_shuttle_manifest/manifest)
	if(sent)
		SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "correct smithed item"))
		three_way_reward(manifest, "Smith", GLOB.station_money_database.get_account_by_department(DEPARTMENT_SUPPLY), reward, "Secondary goal complete: [quality.name] [material.name] [product_type.name].")
	return sent
