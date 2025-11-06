/datum/station_goal/secondary/random_kudzu
	name = "Random Kudzu"
	department = "Hydroponics"
	progress_type = /datum/secondary_goal_progress/random_kudzu
	weight = 1
	var/list/traits = list()
	var/amount = 5

/datum/station_goal/secondary/random_kudzu/randomize_params()
	var/list/valid_traits = subtypesof(/datum/spacevine_mutation)
	
	traits += pick(valid_traits)

	var/list/trait_names = list()
	for(var/dumb_trait in traits)
		var/datum/spacevine_mutation/trait = dumb_trait
		trait_names += initial(trait.name)

	report_message = "The NSV Watney is studying kudzu, and needs some samples with [english_list(trait_names)], but no other mutations. [amount] packs of seeds should do."
	admin_desc = "Kudzu with [trait_names.Join(",")]"

/datum/secondary_goal_progress/random_kudzu
	var/list/traits
	var/needed
	var/sent = 0
	var/sent_this_shipment = 0

/datum/secondary_goal_progress/random_kudzu/configure(datum/station_goal/secondary/random_kudzu/goal)
	..()
	traits = goal.traits
	needed = goal.amount

/datum/secondary_goal_progress/random_kudzu/Copy()
	var/datum/secondary_goal_progress/random_kudzu/copy = ..()
	copy.traits = traits
	copy.needed = needed
	copy.sent = sent
	return copy

/datum/secondary_goal_progress/random_kudzu/start_shipment()
	sent_this_shipment = 0

/datum/secondary_goal_progress/random_kudzu/proc/check_mutations(obj/item/seeds/kudzu/seed)
	if(length(seed.mutations) != length(traits))
		// Wrong number of traits.
		return FALSE
	if(length(seed.mutations - traits))
		// Different traits.
		return FALSE
	return TRUE


/datum/secondary_goal_progress/random_kudzu/update(atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest = null)
	// Not properly labeled for this goal? Ignore.
	if(!check_goal_label(AM))
		return

	if(!istype(AM, /obj/item/seeds/kudzu))
		return

	if(!check_mutations(AM))
		if(!manifest)
			return COMSIG_CARGO_SELL_WRONG
		var/datum/economy/line_item/item = new
		item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE)
		item.credits = 0
		item.reason = "[AM] does not have the right traits."
		item.requests_console_department = "Hydroponics"
		manifest.line_items += item
		return COMSIG_CARGO_SELL_WRONG

	sent++
	sent_this_shipment++
	return COMSIG_CARGO_SELL_PRIORITY

/datum/secondary_goal_progress/random_kudzu/check_complete(datum/economy/cargo_shuttle_manifest/manifest)
	if(sent_this_shipment > 0)
		var/datum/economy/line_item/update_item = new
		update_item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE)
		update_item.credits = 0
		update_item.zero_is_good = TRUE
		update_item.reason = "Received [sent_this_shipment] useful samples of kudzu seeds."
		update_item.requests_console_department = "Hydroponics"
		manifest.line_items += update_item

	if(sent < needed)
		return

	three_way_reward(manifest, "Hydroponics", GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE), SSeconomy.credits_per_kudzu_goal, "Secondary goal complete: [needed] samples of kudzu seeds.")

	return TRUE
