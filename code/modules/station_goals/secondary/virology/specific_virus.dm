/datum/station_goal/secondary/virology/specific_virus
	name = "Specific Viral Sample Request (Non-Stealth)"
	var/list/goal_symptoms = list() //List of type paths of the symptoms, we could go with a diseaseID here instead a list of symptoms but we need the list to tell the player what symptoms to include
	var/symptoms_amount = 5
	progress_type = /datum/secondary_goal_progress/virology/specific_virus
	abstract = FALSE

/datum/station_goal/secondary/virology/specific_virus/Initialize()
	..()
	report_message = "A specific viral sample is required for confidential reasons. We need you to deliver 15u of viral samples with this exact set of symptoms to us through the cargo shuttle: [symptoms_list2text()]."

/datum/station_goal/secondary/virology/specific_virus/randomize_params()
	goal_symptoms = list()
	var/list/symptoms = subtypesof(/datum/symptom)
	var/stealth = 0
	for(var/i in 1 to symptoms_amount)
		var/list/candidates = list()
		for(var/datum/symptom/S as anything in symptoms)
			if(!meets_stealth_requirement(stealth + initial(S.stealth)))
				continue
			candidates += S
		var/datum/symptom/S2 = pick(candidates)
		goal_symptoms += S2
		stealth += initial(S2.stealth)
		symptoms -= S2

/datum/station_goal/secondary/virology/specific_virus/proc/meets_stealth_requirement(stealth)
	return (stealth < 3)

/datum/station_goal/secondary/virology/specific_virus/proc/symptoms_list2text()
	var/list/msg = list()
	for(var/datum/symptom/S as anything in goal_symptoms)
		msg += initial(S.name)
	return english_list(msg, ", ")

/datum/secondary_goal_progress/virology/specific_virus
	var/reward
	var/list/goal_symptoms

/datum/secondary_goal_progress/virology/specific_virus/configure(datum/station_goal/secondary/virology/specific_virus/goal)
	..()
	reward = SSeconomy.credits_per_specific_virus_goal
	goal_symptoms = goal.goal_symptoms

/datum/secondary_goal_progress/virology/specific_virus/Copy()
	var/datum/secondary_goal_progress/virology/specific_virus/copy = ..()
	// These aren't really needed in the intended use case, they're
	// just here in case someone uses this method somewhere else.
	copy.reward = reward
	copy.goal_symptoms = goal_symptoms
	return copy

/datum/secondary_goal_progress/virology/specific_virus/check_virus(var/datum/disease/advance/D, volume, datum/economy/cargo_shuttle_manifest/manifest, complain = FALSE)
	. = FALSE
	if(length(D.symptoms) != length(goal_symptoms))
		if(!manifest || !complain)
			return
		var/datum/economy/line_item/item = new
		item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
		item.credits = 0
		item.reason = "Virus [D.name] has the wrong number of symptoms for [goal_name] ([length(D.symptoms)] is not [length(goal_symptoms)])."
		manifest.line_items += item
		send_requests_console_message(item.reason, "Central Command", "Virology", "Stamped with the Central Command rubber stamp.", null, RQ_NORMALPRIORITY)
		return
	for(var/S in goal_symptoms)
		var/datum/symptom/SY = locate(S) in D.symptoms
		if(!SY)
			if(!manifest || !complain)
				return
			var/datum/economy/line_item/item = new
			item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
			item.credits = 0
			item.reason = "Virus [D.name] is missing symptom [initial(SY.name)] for [goal_name]."
			manifest.line_items += item
			send_requests_console_message(item.reason, "Central Command", "Virology", "Stamped with the Central Command rubber stamp.", null, RQ_NORMALPRIORITY)
			return
	if(manifest)
		var/datum/economy/line_item/item = new
		item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
		item.credits = 0
		item.zero_is_good = TRUE
		item.reason = "Received [volume] units of usable virus [D.name] for [goal_name]."
		manifest.line_items += item
	delivered_amount += volume
	return TRUE

/datum/secondary_goal_progress/virology/specific_virus/check_complete(datum/economy/cargo_shuttle_manifest/manifest)
	. = ..()
	if(.)
		three_way_reward(manifest, "Virology", GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL), reward, "Secondary goal complete: [goal_name].")

/datum/station_goal/secondary/virology/specific_virus/stealth
	name = "Specific Viral Sample Request (Stealth)"
	symptoms_amount = 4
	progress_type = /datum/secondary_goal_progress/virology/specific_virus/stealth

/datum/station_goal/secondary/virology/specific_virus/stealth/Initialize()
	..()
	report_message += " This combination cannot be detected by the PanD.E.M.I.C 2200."

/datum/station_goal/secondary/virology/specific_virus/stealth/meets_stealth_requirement(stealth)
	return (stealth >= 3)

/datum/secondary_goal_progress/virology/specific_virus/stealth/configure(datum/station_goal/secondary/virology/specific_virus/stealth/goal)
	..()
	reward = SSeconomy.credits_per_specific_stealth_virus_goal
