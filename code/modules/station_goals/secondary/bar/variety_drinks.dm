/datum/station_goal/secondary/variety_reagent/bar
	name = "Variety of Drinks"
	department = "Bar"
	generic_name_plural = "alcoholic drinks"
	progress_type = /datum/secondary_goal_progress/variety_reagent/bar
	weight = 1

/datum/station_goal/secondary/variety_reagent/bar/randomize_params()
	..()
	generic_name_plural = pick("soft drinks", "alcoholic drinks")
	department_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE)
	report_message = "We're hosting a party, and need a variety of [generic_name_plural]. Send us at least [amount_per] units each of [different_types] different ones. Keep them separate, and don't include anything too simple; we have our own dispensers."

/datum/secondary_goal_progress/variety_reagent/bar/update(atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest = null)
	// Not properly labeled for this goal? Ignore.
	if(!check_goal_label(AM))
		return

	// No reagents? Ignore.
	if(!length(AM.reagents?.reagent_list))
		return

	var/datum/reagent/reagent = AM.reagents.get_master_reagent()

	// Make sure it's for our department.
	if(!reagent || reagent.goal_department != department)
		return

	// Isolated reagents only, please.
	// This goes here because I want it checked before alcoholic drinks, to head off people adding alcohol to soft drinks.
	if(length(AM.reagents.reagent_list) != 1)
		return ..()

	// Make sure it's the right kind
	if(istype(reagent, /datum/reagent/consumable/ethanol/) && generic_name_plural == "soft drinks")
		if(!manifest)
			return COMSIG_CARGO_SELL_WRONG
		SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "wrong reagents type"))
		var/datum/economy/line_item/item = new
		item.account = department_account
		item.credits = 0
		item.reason = "That [reagent.name] seems to be alcoholic. Send soft drinks only, please!"
		item.requests_console_department = department
		manifest.line_items += item
		return COMSIG_CARGO_SELL_WRONG

	if(!istype(reagent, /datum/reagent/consumable/ethanol/) && generic_name_plural == "alcoholic drinks")
		if(!manifest)
			return COMSIG_CARGO_SELL_WRONG
		SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "wrong reagents type"))
		var/datum/economy/line_item/item = new
		item.account = department_account
		item.credits = 0
		item.reason = "That [reagent.name] isn't any alcoholic drink I've heard of. Send hard drinks only, please!"
		item.requests_console_department = department
		manifest.line_items += item
		return COMSIG_CARGO_SELL_WRONG

	return ..()
