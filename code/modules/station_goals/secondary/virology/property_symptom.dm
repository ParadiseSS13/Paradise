/datum/station_goal/secondary/virology/property_symptom
	name = "Symptom With Properties Viral Sample Request"
	progress_type = /datum/secondary_goal_progress/virology/property_symptom
	var/datum/symptom/goal_symptom //Type path of the symptom
	var/goal_symptom_name
	var/goal_property
	var/goal_property_value
	abstract = FALSE

/datum/station_goal/secondary/virology/property_symptom/Initialize()
	..()
	report_message = "Viral samples with a specific symptom and properties are required to study the effects of this symptom in various conditions. We need you to deliver 15u of viral samples containing the [goal_symptom_name] symptom and with the [goal_property] property at level [goal_property_value] along with 3 other symptoms to us through the cargo shuttle."

/datum/station_goal/secondary/virology/property_symptom/randomize_params()
	var/datum/symptom/S = pick(subtypesof(/datum/symptom))
	goal_symptom = S
	goal_symptom_name = initial(S.name)
	goal_property_value = rand(-18, 11)
	goal_property = pick("resistance", "stealth", "stage rate", "transmittable")
	switch(goal_property)
		if("resistance")
			goal_property_value += initial(S.resistance)
		if("stealth")
			goal_property_value += initial(S.stealth)
		if("stage rate")
			goal_property_value += initial(S.stage_speed)
		if("transmittable")
			goal_property_value += initial(S.transmittable)


/datum/secondary_goal_progress/virology/property_symptom
	var/goal_name
	var/reward
	var/datum/symptom/goal_symptom //Type path of the symptom
	var/goal_symptom_name
	var/goal_property
	var/goal_property_value

/datum/secondary_goal_progress/virology/property_symptom/configure(datum/station_goal/secondary/virology/property_symptom/goal)
	..()
	goal_name = goal.name
	reward = SSeconomy.credits_per_virus_property_symptom_goal
	goal_symptom = goal.goal_symptom
	goal_symptom_name = goal.goal_symptom_name
	goal_property = goal.goal_property
	goal_property_value = goal.goal_property_value

/datum/secondary_goal_progress/virology/property_symptom/Copy()
	var/datum/secondary_goal_progress/virology/property_symptom/copy = ..()
	// These aren't really needed in the intended use case, they're
	// just here in case someone uses this method somewhere else.
	copy.goal_name = goal_name
	copy.reward = reward
	copy.goal_symptom = goal_symptom
	copy.goal_symptom_name = goal_symptom_name
	copy.goal_property = goal_property
	copy.goal_property_value = goal_property_value
	return copy

/datum/secondary_goal_progress/virology/property_symptom/check_virus(var/datum/disease/advance/D, volume, datum/economy/cargo_shuttle_manifest/manifest, complain = FALSE)
	//We want 3 other symptoms alongside the requested one
	var/required_symptoms = 4
	if(length(D.symptoms) < required_symptoms)
		if(!manifest || !complain)
			return
		var/datum/economy/line_item/item = new
		item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
		item.credits = 0
		item.reason = "Virus [D.name] has too few symptoms for [goal_name] ([length(D.symptoms)] is less than [required_symptoms])."
		manifest.line_items += item
		send_requests_console_message(item.reason, "Central Command", "Virology", "Stamped with the Central Command rubber stamp.", null, RQ_NORMALPRIORITY)
		return
	var/properties = D.GenerateProperties()
	var/property = properties[goal_property]
	if(property != goal_property_value)
		if(!manifest || !complain)
			return
		var/datum/economy/line_item/item = new
		item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
		item.credits = 0
		item.reason = "Virus [D.name] has the wrong [goal_property] for [goal_name] ([property] is not [goal_property_value])."
		manifest.line_items += item
		send_requests_console_message(item.reason, "Central Command", "Virology", "Stamped with the Central Command rubber stamp.", null, RQ_NORMALPRIORITY)
		return
	for(var/datum/symptom/S in D.symptoms)
		if(!goal_symptom)
			return
		if(S.type != goal_symptom)
			continue
		if(manifest)
			var/datum/economy/line_item/item = new
			item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
			item.credits = 0
			item.zero_is_good = TRUE
			item.reason = "Received [volume] units of usable virus [D.name] for [goal_name]."
			manifest.line_items += item
		delivered_amount += volume
		return TRUE
	if(!manifest || !complain)
		return
	var/datum/economy/line_item/item = new
	item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
	item.credits = 0
	item.reason = "Virus [D.name] is missing the required symptom [initial(goal_symptom.name)] for [goal_name]."
	manifest.line_items += item
	send_requests_console_message(item.reason, "Central Command", "Virology", "Stamped with the Central Command rubber stamp.", null, RQ_NORMALPRIORITY)

/datum/secondary_goal_progress/virology/property_symptom/check_complete(datum/economy/cargo_shuttle_manifest/manifest)
	. = ..()
	if(.)
		three_way_reward(manifest, "Virology", GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL), reward, "Secondary goal complete: [goal_name].")
