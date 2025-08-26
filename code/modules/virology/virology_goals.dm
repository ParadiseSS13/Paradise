GLOBAL_LIST_EMPTY(virology_goals)
GLOBAL_LIST_EMPTY(archived_virology_goals)
#define MAX_LOOPS 30

/datum/virology_goal
	var/name = "Generic Virology Goal"
	/// The amount of units currently already delivered
	var/delivered_amount = 0
	/// The amount of units of the required virus that must be delivered for the completion of this goal
	var/delivery_goal = 15
	var/completed = FALSE

/datum/virology_goal/proc/register()
	RegisterSignal(SSshuttle.supply, COMSIG_CARGO_CHECK_SELL, PROC_REF(check_for_virus))
	RegisterSignal(SSshuttle.supply, COMSIG_CARGO_DO_PRIORITY_SELL, PROC_REF(sell_virus))
	RegisterSignal(SSshuttle.supply, COMSIG_CARGO_SEND_ERROR, PROC_REF(complain_about_virus))

/datum/virology_goal/proc/unregister()
	UnregisterSignal(SSshuttle.supply, COMSIG_CARGO_CHECK_SELL)
	UnregisterSignal(SSshuttle.supply, COMSIG_CARGO_DO_PRIORITY_SELL)
	UnregisterSignal(SSshuttle.supply, COMSIG_CARGO_SEND_ERROR)

/datum/virology_goal/proc/check_for_virus(shuttle, atom/movable/thing)
	SIGNAL_HANDLER  // COMSIG_CARGO_CHECK_SELL
	if(istype(thing, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/C = thing
		if(!thing.reagents?.has_reagent("blood"))
			return
		if(check_viruses(C.reagents.reagent_list))
			return COMSIG_CARGO_SELL_PRIORITY
		return COMSIG_CARGO_SELL_WRONG

/datum/virology_goal/proc/sell_virus(shuttle, atom/movable/thing, datum/economy/cargo_shuttle_manifest/manifest, complain = FALSE)
	SIGNAL_HANDLER  // COMSIG_CARGO_DO_PRIORITY_SELL
	// Ignore everything after we're done.
	if(completed)
		return

	// Look for reagent containers, those in vial lockboxes included
	if(!istype(thing, /obj/item/reagent_containers))
		return

	var/obj/item/reagent_containers/C = thing
	if(!length(C.reagents?.reagent_list))
		// Nothing to look at.
		return

	check_viruses(C.reagents.reagent_list, manifest, complain, complain)

	if(!completed)
		// Didn't finish yet.
		return

	// Report and give credits for the goal.
	var/datum/economy/line_item/item = new
	item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
	item.credits = SSeconomy.credits_per_virology_goal
	item.reason = "[name] completed."
	manifest.line_items += item

	// Stop listening.
	unregister()

/datum/virology_goal/proc/complain_about_virus(shuttle, atom/movable/thing, datum/economy/cargo_shuttle_manifest/manifest)
	sell_virus(shuttle, thing, manifest, TRUE)

/datum/virology_goal/proc/get_report()
	return "Complete this goal."

/datum/virology_goal/proc/check_viruses(list/reagent_list)
	check_total_virology_goals_completion()
	return TRUE

/datum/virology_goal/proc/check_for_duplicate()
	return TRUE

/proc/check_total_virology_goals_completion()
	for(var/datum/virology_goal/V as anything in GLOB.virology_goals)
		if(!V.completed)
			return
	GLOB.archived_virology_goals += GLOB.virology_goals
	GLOB.virology_goals = list(new /datum/virology_goal/property_symptom, new /datum/virology_goal/virus, new /datum/virology_goal/virus/stealth)
	for(var/obj/machinery/pandemic/P in GLOB.pandemics)
		P.print_goal_orders()

/datum/virology_goal/Destroy()
	GLOB.virology_goals -= src
	GLOB.archived_virology_goals -= src
	. = ..()

/datum/virology_goal/Topic(href, href_list)
	..()

	if(!check_rights(R_EVENT))
		return

	if(href_list["remove"])
		qdel(src)

/datum/virology_goal/property_symptom
	name = "Symptom With Properties Viral Sample Request"
	var/datum/symptom/goal_symptom //Type path of the symptom
	var/goal_symptom_name
	var/goal_property
	var/goal_property_value

/datum/virology_goal/property_symptom/New()
	register()
	var/times_looped = 0 //The chance for this to make a infinite loop that lags the server is astronomically small but its still a chance
	do
		var/type = pick(subtypesof(/datum/symptom))
		var/datum/symptom/S = new type()
		goal_symptom = S.type
		goal_symptom_name = S.name
		goal_property = pick("resistance", "stealth", "stage rate", "transmissibility")
		goal_property_value = rand(-8, 6)
		switch(goal_property)
			if("resistance")
				goal_property_value += S.resistance
			if("stealth")
				goal_property_value += S.stealth
			if("stage rate")
				goal_property_value += S.stage_speed
			if("transmissibility")
				goal_property_value += S.transmissibility
		qdel(S)
		times_looped++
	while(check_for_duplicate() && times_looped < MAX_LOOPS)

/datum/virology_goal/property_symptom/check_for_duplicate()
	. = FALSE
	if(!goal_symptom || !goal_property || !goal_property_value)
		return
	for(var/datum/virology_goal/property_symptom/V in (GLOB.archived_virology_goals + GLOB.virology_goals))
		if(goal_symptom == V.goal_symptom && goal_property == V.goal_property && goal_property_value == V.goal_property_value)
			return TRUE

/datum/virology_goal/property_symptom/get_report(is_ui = FALSE)
	var/return_text
	if(!is_ui)
		return_text += "<b>Effects of [goal_symptom_name] symptom and level [goal_property_value] [goal_property]</b><br>"
	return_text += "Viral samples with a specific symptom and properties are required to study the effects of this symptom in various conditions. We need you to deliver [delivery_goal]u of viral samples containing the [goal_symptom_name] symptom and with the [goal_property] property at level [goal_property_value] along with 3 other symptoms to us through the cargo shuttle."
	return return_text

/datum/virology_goal/property_symptom/check_viruses(list/datum/reagent/reagent_list, datum/economy/cargo_shuttle_manifest/manifest, simulate = TRUE, complain = FALSE)
	. = FALSE
	var/datum/reagent/blood/BL = locate() in reagent_list
	if(!BL)
		return
	if(!BL.data || !BL.data["viruses"])
		return
	for(var/datum/disease/advance/D in BL.data["viruses"])
		//We want 3 other symptoms alongside the requested one
		var/required_symptoms = 4
		if(length(D.symptoms) < required_symptoms)
			if(simulate || !manifest || !complain)
				continue
			var/datum/economy/line_item/item = new
			item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
			item.credits = 0
			item.reason = "Virus [D.name] has too few symptoms for [name] ([length(D.symptoms)] is less than [required_symptoms])."
			manifest.line_items += item
			continue
		var/properties = D.GenerateProperties()
		var/property = properties[goal_property]
		if(property != goal_property_value)
			if(simulate || !manifest || !complain)
				continue
			var/datum/economy/line_item/item = new
			item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
			item.credits = 0
			item.reason = "Virus [D.name] has the wrong [goal_property] for [name] ([property] is not [goal_property_value])."
			manifest.line_items += item
			continue
		for(var/datum/symptom/S in D.symptoms)
			if(!goal_symptom)
				return
			if(S.type != goal_symptom)
				continue
			if(simulate)
				return TRUE
			if(manifest)
				var/datum/economy/line_item/item = new
				item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
				item.credits = 0
				item.zero_is_good = TRUE
				item.reason = "Received [BL.volume] units of usable virus [D.name] for [name]."
				manifest.line_items += item
			delivered_amount += BL.volume
			if(delivered_amount >= delivery_goal)
				completed = TRUE
				check_total_virology_goals_completion()
				return TRUE
		if(simulate || !manifest || !complain)
			continue
		var/datum/economy/line_item/item = new
		item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
		item.credits = 0
		item.reason = "Virus [D.name] is missing the required symptom [initial(goal_symptom.name)] for [name]."
		manifest.line_items += item

/datum/virology_goal/virus
	name = "Specific Viral Sample Request (Non-Stealth)"
	var/list/goal_symptoms = list() //List of type paths of the symptoms, we could go with a diseaseID here instead a list of symptoms but we need the list to tell the player what symptoms to include
	var/symptoms_amount = 5

/datum/virology_goal/virus/New()
	register()
	var/times_looped = 0 //The chance for this to make a infinite loop that lags the server is astronomically small but its still a chance
	do
		goal_symptoms = list()
		var/list/symptoms = subtypesof(/datum/symptom)
		var/stealth = 0
		for(var/i in 1 to symptoms_amount)
			var/list/candidates = list()
			for(var/datum/symptom/S as anything in symptoms)
				if(!meets_stealth_requirement(stealth + S.stealth))
					continue
				candidates += S
			var/datum/symptom/S2 = pick(candidates)
			goal_symptoms += S2
			stealth += S2.stealth
			symptoms -= S2
		times_looped++
	while(check_for_duplicate() && times_looped < MAX_LOOPS)

/datum/virology_goal/virus/check_for_duplicate()
	. = FALSE
	if(!length(goal_symptoms))
		return
	for(var/datum/virology_goal/virus/V in (GLOB.archived_virology_goals + GLOB.virology_goals))
		if(goal_symptoms == V.goal_symptoms)
			return TRUE

/datum/virology_goal/virus/proc/meets_stealth_requirement(stealth)
	return (stealth < 3)

/datum/virology_goal/virus/get_report(is_ui = FALSE)
	var/return_text
	if(!is_ui)
		return_text += "<b>[name]</b><br>"
	return_text += "A specific viral sample is required for confidential reasons. We need you to deliver [delivery_goal]u of viral samples with this exact set of symptoms to us through the cargo shuttle: [symptoms_list2text()]"
	return return_text

/datum/virology_goal/virus/proc/symptoms_list2text()
	var/list/msg = list()
	for(var/datum/symptom/S as anything in goal_symptoms)
		msg += initial(S.name)
	return english_list(msg, ", ")

/datum/virology_goal/virus/check_viruses(list/datum/reagent/reagent_list, datum/economy/cargo_shuttle_manifest/manifest, simulate = TRUE, complain = FALSE)
	. = FALSE
	var/datum/reagent/blood/BL = locate() in reagent_list
	if(!BL)
		return
	if(!BL.data || !BL.data["viruses"])
		return
	for(var/datum/disease/advance/D in BL.data["viruses"])
		// Assume we succeed for each virus and change that if we found out it's wrong
		var/valid = TRUE
		var/missing_symptoms = list()
		// We have the wrong numnber of symptoms. Complain about it if possible and required, then go to next virus.
		if(length(D.symptoms) != length(goal_symptoms))
			valid = FALSE
			if(!simulate && manifest && complain)
				var/datum/economy/line_item/item = new
				item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
				item.credits = 0
				item.reason = "Virus [D.name] has the wrong number of symptoms for [name] ([length(D.symptoms)] is not [length(goal_symptoms)])."
			continue

		// Check if we have all symptoms we need, and list the ones we don't.
		for(var/S in goal_symptoms)
			var/datum/symptom/SY = locate(S) in D.symptoms
			if(!SY)
				valid = FALSE
				missing_symptoms += initial(SY.name)


		// We are missing some symptoms we need. Complain about it if possible and required, then go to next virus.
		if(!valid)
			if(!simulate && manifest && complain)
				var/datum/economy/line_item/item = new
				item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
				item.credits = 0
				item.reason = "Virus [D.name] is missing symptoms [english_list(missing_symptoms)] for [name]."
				manifest.line_items += item
			continue

		if(simulate)
			return TRUE
		if(manifest)
			var/datum/economy/line_item/item = new
			item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
			item.credits = 0
			item.zero_is_good = TRUE
			item.reason = "Received [BL.volume] units of usable virus [D.name] for [name]."
			manifest.line_items += item
		delivered_amount += BL.volume
		if(delivered_amount >= delivery_goal)
			completed = TRUE
			check_total_virology_goals_completion()
			return TRUE

/datum/virology_goal/virus/stealth
	name = "Specific Viral Sample Request (Stealth)"
	symptoms_amount = 4

/datum/virology_goal/virus/stealth/meets_stealth_requirement(stealth)
	return (stealth >= 3)

#undef MAX_LOOPS
