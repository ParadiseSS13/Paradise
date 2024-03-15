/datum/station_goal/secondary/random_bulk_drink
	name = "Random Bulk Drink"
	department = "Bar"
	progress_type = /datum/secondary_goal_progress/random_bulk_drink
	var/datum/reagent/drink_type = /datum/reagent/consumable/ethanol/bilk
	var/amount = 300

/datum/station_goal/secondary/random_bulk_drink/randomize_params()
	drink_type = pick(subtypesof(/datum/reagent/consumable/ethanol))
	report_message = "A visiting dignitary loves [initial(drink_type.name)]. Please send us at least [amount] units of it."


/datum/secondary_goal_progress/random_bulk_drink
	var/datum/reagent/drink_type
	var/needed
	var/sent = 0

/datum/secondary_goal_progress/random_bulk_drink/configure(datum/station_goal/secondary/random_bulk_drink/goal)
	drink_type = goal.drink_type
	needed = goal.amount

/datum/secondary_goal_progress/random_bulk_drink/Copy()
	var/datum/secondary_goal_progress/random_bulk_drink/copy = new
	copy.drink_type = drink_type
	copy.needed = needed
	copy.sent = sent
	return copy

/datum/secondary_goal_progress/random_bulk_drink/update(atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest = null)
	if(!istype(AM, /obj/item/reagent_containers))
		return

	var/obj/item/reagent_containers/container = AM
	var/amount = container.reagents.get_reagent_amount(initial(drink_type.id))
	if(!amount)
		return
	sent += amount
	if(!manifest)
		return COMSIG_CARGO_SELL_PRIORITY

	var/datum/economy/line_item/item = new
	item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE)
	item.credits = 0
	item.reason = "Received [amount] units of [initial(drink_type.name)]."
	item.zero_is_good = TRUE
	manifest.line_items += item

	return COMSIG_CARGO_SELL_PRIORITY

/datum/secondary_goal_progress/random_bulk_drink/check_complete(datum/economy/cargo_shuttle_manifest/manifest)
	if(sent < needed)
		return

	var/datum/economy/line_item/supply_item = new
	supply_item.account = SSeconomy.cargo_account
	supply_item.credits = 50
	supply_item.reason = "Secondary goal complete: [needed] units of [initial(drink_type.name)]."
	manifest.line_items += supply_item

	var/datum/economy/line_item/service_item = new
	service_item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE)
	service_item.credits = 50
	service_item.reason = "Secondary goal complete: [needed] units of [initial(drink_type.name)]."
	manifest.line_items += service_item

	return TRUE
