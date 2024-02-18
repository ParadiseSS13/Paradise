GLOBAL_LIST_INIT(virology_goals, list(new /datum/virology_goal/property_symptom, new /datum/virology_goal/virus, new /datum/virology_goal/virus/stealth))
GLOBAL_LIST_EMPTY(archived_virology_goals)

/datum/virology_goal
	var/name = "Generic Virology Goal"
	/// The amount of units currently already delivered  
	var/delivered_amount = 0  
	/// The amount of units of the required virus that must be delivered for the completion of this goal  
	var/delivery_goal = 15
	var/completed = FALSE

/datum/virology_goal/proc/get_report()
	return "Complete this goal."

/datum/virology_goal/proc/get_ui_report()
	return "Complete this goal."

/datum/virology_goal/proc/check_completion(list/reagent_list)
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
	for(var/obj/machinery/computer/pandemic/P in GLOB.pandemics)
		P.print_goal_orders()

/datum/virology_goal/Destroy()
	LAZYREMOVE(GLOB.virology_goals, src)
	. = ..()

/datum/virology_goal/Topic(href, href_list)
	..()

	if(!check_rights(R_EVENT))
		return

	if(href_list["remove"])
		qdel(src)

/datum/virology_goal/property_symptom
	name = "Symptom With Properties Viral Sample Request"
	var/goal_symptom //Type path of the symptom
	var/goal_symptom_name
	var/goal_property
	var/goal_property_value

/datum/virology_goal/property_symptom/New()
	do
		var/type = pick(subtypesof(/datum/symptom))
		var/datum/symptom/S = new type()
		goal_symptom = S.type
		goal_symptom_name = S.name
		goal_property = pick("resistance", "stealth", "stage rate", "transmittable")  
		goal_property_value = rand(-18 , 11)
		switch(goal_property)
			if("resistance")
				goal_property_value += S.resistance
			if("stealth")
				goal_property_value += S.stealth
			if("stage rate")
				goal_property_value += S.stage_speed
			if("transmittable")
				goal_property_value += S.transmittable
		qdel(S)
	while(check_for_duplicate())

/datum/virology_goal/property_symptom/check_for_duplicate()
	. = FALSE
	if(!goal_symptom || !goal_property || !goal_property_value)
		return
	for(var/datum/virology_goal/property_symptom/V in (GLOB.archived_virology_goals + GLOB.virology_goals))
		if(goal_symptom == V.goal_symptom && goal_property == V.goal_property && goal_property_value == V.goal_property_value)
			return TRUE

/datum/virology_goal/property_symptom/get_report()
	return {"<b>Effects of [goal_symptom_name] symptom and level [goal_property_value] [goal_property]</b><br>
	Viral samples with a specific symptom and properties are required to study the effects of this symptom in various conditions. We need you to deliver [delivery_goal]u of viral samples containing the [goal_symptom_name] symptom and with the [goal_property] property at level [goal_property_value] along with 3 other symptoms to us through the cargo shuttle.
	<br>
	-Nanotrasen Virology Research"}

/datum/virology_goal/property_symptom/get_ui_report()
	return {"Viral samples with a specific symptom and properties are required to study the effects of this symptom in various conditions. We need you to deliver [delivery_goal]u of viral samples containing the [goal_symptom_name] symptom and with the [goal_property] property at level [goal_property_value] along with 3 other symptoms to us through the cargo shuttle."}

/datum/virology_goal/property_symptom/check_completion(list/datum/reagent/reagent_list)
	. = FALSE
	var/datum/reagent/blood/BL = locate() in reagent_list
	if(BL && BL.data && BL.data["viruses"])
		for(var/datum/disease/advance/D in BL.data["viruses"])
			if(length(D.symptoms) < 4) //We want 3 other symptoms alongside the requested one
				continue
			var/properties = D.GenerateProperties()
			var/property = properties[goal_property]
			if(property != goal_property_value)
				continue
			for(var/datum/symptom/S in D.symptoms)
				if(!goal_symptom)
					return
				if(S.type != goal_symptom)
					continue
				delivered_amount = clamp(delivered_amount + BL.volume, 0, delivery_goal)
				if(delivered_amount >= delivery_goal)
					completed = TRUE
					check_total_virology_goals_completion()
					return TRUE

/datum/virology_goal/virus
	name = "Specific Viral Sample Request (Non-Stealth)"
	var/list/goal_symptoms = list() //List of type paths of the symptoms, we could go with a diseaseID here instead a list of symptoms but we need the list to tell the player what symptoms to include

/datum/virology_goal/virus/New()
	do
		goal_symptoms = list()
		var/list/datum/symptom/symptoms = subtypesof(/datum/symptom)
		var/stealth = 0
		for(var/i in 1 to 5)
			var/list/datum/symptom/candidates = list()
			for(var/datum/symptom/V as anything in symptoms) //There is a "as anything" added because for some mystery reason it doesnt work without it
				var/datum/symptom/S = V
				if(stealth + S.stealth >= 3) //The Pandemic cant detect a virus with stealth 3 or higher and we dont want that, this isnt a stealth virus
					continue
				candidates += S
			var/datum/symptom/S2 = pick(candidates)
			goal_symptoms += S2
			stealth += S2.stealth
			symptoms -= S2
	while(check_for_duplicate())

/datum/virology_goal/virus/check_for_duplicate()
	. = FALSE
	if(!length(goal_symptoms))
		return
	var/goals = GLOB.archived_virology_goals + GLOB.virology_goals
	for(var/datum/virology_goal/virus/V in goals)
		if(goal_symptoms == V.goal_symptoms)
			return TRUE

/datum/virology_goal/virus/get_report()
	return {"<b>[name]</b><br>
	A specific viral sample is required for confidential reasons. We need you to deliver [delivery_goal]u of viral samples with this exact set of symptoms to us through the cargo shuttle:<br>[symptoms_list2text()]
	<br>
	-Nanotrasen Virology Research"}

/datum/virology_goal/virus/get_ui_report()
	return {"A specific viral sample is required for confidential reasons. We need you to deliver [delivery_goal]u of viral samples with this exact set of symptoms to us through the cargo shuttle: [symptoms_list2text()]"}

/datum/virology_goal/virus/proc/symptoms_list2text()
	var/list/msg = list()
	for(var/datum/symptom/S as anything in goal_symptoms)
		msg += initial(S.name)
	return english_list(msg, ", ")

/datum/virology_goal/virus/check_completion(list/datum/reagent/reagent_list)
	. = FALSE
	var/datum/reagent/blood/BL = locate() in reagent_list
	if(BL && BL.data && BL.data["viruses"])
		for(var/datum/disease/advance/D in BL.data["viruses"])
			if(length(D.symptoms) != length(goal_symptoms)) //This is here so viruses with extra symptoms dont get approved
				return
			for(var/S in goal_symptoms)
				var/datum/symptom/SY = locate(S) in D.symptoms
				if(!SY)
					return
				delivered_amount = clamp(delivered_amount + BL.volume, 0, delivery_goal)
				if(delivered_amount >= delivery_goal)
					completed = TRUE
					check_total_virology_goals_completion()
					return TRUE

/datum/virology_goal/virus/stealth
	name = "Specific Viral Sample Request (Stealth)"

/datum/virology_goal/virus/stealth/New()
	var/first_loop = TRUE
	do
		first_loop = FALSE
		goal_symptoms = list()
		var/list/symptoms = subtypesof(/datum/symptom)
		var/stealth = 0
		for(var/i in 1 to 5)
			var/list/candidates = list()
			for(var/datum/symptom/V as anything in symptoms) //There is a "as anything" added because for some mystery reason it doesnt work without it
				var/datum/symptom/S = V
				if(stealth + S.stealth < 3) //The Pandemic cant detect a virus with stealth 3 or higher and we want that, this is a stealth virus
					continue
				candidates += S
			var/datum/symptom/S2 = pick(candidates)
			goal_symptoms += S2
			stealth += S2.stealth
			symptoms -= S2
	while(check_for_duplicate() || first_loop)
