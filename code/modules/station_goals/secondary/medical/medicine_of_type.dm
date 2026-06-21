/datum/station_goal/secondary/medicine_of_type
	name = "Specific Treatments"
	department = "Chemistry"
	weight = 1
	progress_type = /datum/secondary_goal_progress/medicine_of_type
	var/department_account
	var/generic_name_plural = "medicines"
	var/reward
	var/specific_type = "burn"
	/// Medicine that will count 1:1 towards the goal amount.
	var/list/datum/reagent/preferred_meds = list()
	/// Medicine that will count 2:1 towards the goal amount.
	var/list/datum/reagent/adequate_meds = list()
	var/amount_needed = 300
	var/alist/med_lookup = alist(
		"burn" = alist(
			"preferred" = list(
				/datum/reagent/medicine/heal_on_apply/silver_sulfadiazine,
				/datum/reagent/medicine/heal_on_apply/synthflesh,
			),
			"adequate" = list(
				/datum/reagent/medicine/omnizine_diluted,
				/datum/reagent/medicine/omnizine,
				/datum/reagent/medicine/menthol,
				/datum/reagent/medicine/salglu_solution,
				/datum/reagent/medicine/cryoxadone,
			),
		),
		"brute" = alist(
			"preferred" = list(
				/datum/reagent/medicine/heal_on_apply/styptic_powder,
				/datum/reagent/medicine/heal_on_apply/synthflesh,
			),
			"adequate" = list(
				/datum/reagent/medicine/omnizine_diluted,
				/datum/reagent/medicine/omnizine,
				/datum/reagent/medicine/sal_acid,
				/datum/reagent/medicine/salglu_solution,
				/datum/reagent/medicine/cryoxadone,
			),
		),
		"antitoxin" = alist(
			"preferred" = list(
				/datum/reagent/medicine/charcoal,
				/datum/reagent/medicine/pen_acid,
			),
			"adequate" = list(
				/datum/reagent/medicine/omnizine_diluted,
				/datum/reagent/medicine/omnizine,
				/datum/reagent/medicine/potass_iodide,
				/datum/reagent/medicine/cryoxadone,
				/datum/reagent/medicine/calomel,
			),
		),
		"respiratory" = alist(
			"preferred" = list(
				/datum/reagent/medicine/perfluorodecalin,
				/datum/reagent/medicine/salbutamol,
			),
			"adequate" = list(
				/datum/reagent/medicine/omnizine_diluted,
				/datum/reagent/medicine/omnizine,
				/datum/reagent/medicine/cryoxadone,
				/datum/reagent/medicine/ephedrine,
			),
		),
		"cloning" = alist(
			"preferred" = list(
				/datum/reagent/medicine/sanguine_reagent,
				/datum/reagent/medicine/osseous_reagent,
			),
			"adequate" = list(
				/datum/reagent/blood,
				/datum/reagent/medicine/cryoxadone,
				/datum/reagent/medicine/mitocholide,
			),
		),
		"neurological" = alist(
			"preferred" = list(
				/datum/reagent/medicine/haloperidol,
				/datum/reagent/methamphetamine,
				/datum/reagent/medicine/mannitol,
			),
			"adequate" = list(
				/datum/reagent/medicine/ether,
				/datum/reagent/lithium,
			),
		),
		"cardiac" = alist(
			"preferred" = list(
				/datum/reagent/medicine/atropine,
				/datum/reagent/medicine/epinephrine,
			),
			"adequate" = list(
				/datum/reagent/heparin,
			),
		),
		"pain management" = alist(
			"preferred" = list(
				/datum/reagent/medicine/hydrocodone,
				/datum/reagent/medicine/sal_acid,
			),
			"adequate" = list(
				/datum/reagent/medicine/morphine,
			),
		),
		"cellular" = alist(
			"preferred" = list(
				/datum/reagent/medicine/mutadone,
				/datum/reagent/medicine/rezadone,
			),
			"adequate" = list(
				/datum/reagent/medicine/cryoxadone,
			),
		),
		"temperature-stabilizing" = alist(
			"preferred" = list(
				/datum/reagent/medicine/teporone,
			),
			"adequate" = list(
				/datum/reagent/medicine/menthol,
				/datum/reagent/medicine/sal_acid,
			),
		),
		"blood loss" = alist(
			"preferred" = list(
				/datum/reagent/medicine/sanguine_reagent,
			),
			"adequate" = list(
				/datum/reagent/blood,
				/datum/reagent/medicine/salglu_solution,
				/datum/reagent/iron,
			),
		),
		"specific purgative" = alist(
			"preferred" = list(
				/datum/reagent/medicine/atropine,
				/datum/reagent/medicine/potass_iodide,
				/datum/reagent/medicine/antihol,
				/datum/reagent/medicine/diphenhydramine,
				/datum/reagent/medicine/haloperidol,
			),
			"adequate" = list(
				/datum/reagent/medicine/mutadone,
				/datum/reagent/medicine/epinephrine,
			),
		),
		"antibiotic" = alist(
			"preferred" = list(
				/datum/reagent/medicine/spaceacillin,
				/datum/reagent/medicine/sterilizine,
			),
			"adequate" = list(
				/datum/reagent/medicine/mitocholide,
			),
		),
	)

/datum/station_goal/secondary/medicine_of_type/Initialize(requester_account)
	reward = SSeconomy.credits_per_variety_reagent_goal
	..()
	admin_desc = "[amount_needed] units of [specific_type] [generic_name_plural]"

/datum/station_goal/secondary/medicine_of_type/proc/list_med_names(list/datum/reagent/reagent_list)
	var/list/name_list = list()
	for(var/i in 1 to length(reagent_list))
		name_list.Add(reagent_list[i].name)
	return name_list

/datum/station_goal/secondary/medicine_of_type/randomize_params()
	department_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
	specific_type = pick("burn", "brute", "antitoxin", "respiratory", "cloning", "neurological", "cardiac", "pain management", "cellular", "temperature-stabilizing", "blood loss", "specific purgative", "antibiotic")
	preferred_meds = med_lookup[specific_type]["preferred"]
	adequate_meds = med_lookup[specific_type]["adequate"]
	var/preferred_meds_string = english_list(list_med_names(preferred_meds), "nothing", " and/or ")
	var/adequate_meds_string = english_list(list_med_names(adequate_meds), "nothing", " and/or ")
	report_message = "One of our outposts is in desperate need of more [specific_type] [generic_name_plural]. Please provide at least [amount_needed]u, in whatever form you can, in any combination of medicines. "
	report_message += "Preferably, send [preferred_meds_string]. "
	report_message += "They will also take [adequate_meds_string], but they will need twice as much."
	return ..()

/datum/secondary_goal_progress/medicine_of_type
	var/list/reagents_sent = list()
	var/department
	var/specific_type
	var/list/datum/reagent/preferred_meds = list()
	var/list/datum/reagent/adequate_meds = list()
	var/amount_needed
	var/department_account
	var/reward
	var/generic_name_plural

/datum/secondary_goal_progress/medicine_of_type/configure(datum/station_goal/secondary/medicine_of_type/goal)
	..()
	department = goal.department
	specific_type = goal.specific_type
	preferred_meds = goal.preferred_meds
	adequate_meds = goal.adequate_meds
	amount_needed = goal.amount_needed
	department_account = goal.department_account
	reward = goal.reward
	generic_name_plural = goal.generic_name_plural

/datum/secondary_goal_progress/medicine_of_type/Copy()
	var/datum/secondary_goal_progress/medicine_of_type/copy = ..()
	copy.reagents_sent = reagents_sent.Copy()
	copy.department = department
	copy.amount_needed = amount_needed
	copy.specific_type = specific_type
	copy.preferred_meds = preferred_meds
	copy.adequate_meds = adequate_meds
	// These ones aren't really needed in the intended use case, they're
	// just here in case someone uses this method somewhere else.
	copy.department_account = department_account
	copy.reward = reward
	copy.generic_name_plural = generic_name_plural
	return copy

/datum/secondary_goal_progress/medicine_of_type/update(atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest = null)
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

	// Must be reagents of the type we requested.
	var/is_needed = FALSE
	for(var/reagent_type in preferred_meds)
		is_needed = istype(reagent, reagent_type)
		if(is_needed)
			break
	for(var/reagent_type in adequate_meds)
		if(is_needed)
			break
		is_needed = istype(reagent, reagent_type)

	if(!is_needed)
		if(!manifest)
			return COMSIG_CARGO_SELL_WRONG
		SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "inapplicable reagents"))
		var/datum/economy/line_item/item = new
		item.account = department_account
		item.credits = 0
		item.reason = "[reagent.name] won't help us with this issue."
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

/datum/secondary_goal_progress/medicine_of_type/check_complete(datum/economy/cargo_shuttle_manifest/manifest)
	if(!length(reagents_sent))
		return
	var/single_reagent
	var/reagents_tally = 0
	for(single_reagent in reagents_sent)
		var/is_preferred = FALSE
		for(var/i in 1 to length(preferred_meds))
			if(single_reagent == preferred_meds[i].id)
				reagents_tally += reagents_sent[single_reagent]
				is_preferred = TRUE
				continue
		reagents_tally += is_preferred ? 0 : (reagents_sent[single_reagent] / 2)
	if(reagents_tally < amount_needed)
		return

	three_way_reward(manifest, department, department_account, reward, "Secondary goal complete: At least [amount_needed]u [specific_type] [generic_name_plural].")
	return TRUE
