GLOBAL_LIST_INIT(virology_goals, list(new/datum/virology_goal/propertysymptom, new/datum/virology_goal/virus, new/datum/virology_goal/virus))

/datum/virology_goal
	var/name = "Generic Virology Goal"
	var/delivered_amount = 0
	var/delivery_goal = 100
	var/completed = FALSE

/datum/virology_goal/proc/get_report()
	return "Complete this goal."

/datum/virology_goal/proc/get_ui_report()
	return "Complete this goal."

/datum/virology_goal/proc/check_completion(list/datum/reagent/reagent_list)
	return TRUE

/datum/virology_goal/Destroy()
	LAZYREMOVE(GLOB.virology_goals, src)
	. = ..()

/datum/virology_goal/Topic(href, href_list)
	..()

	if(!check_rights(R_EVENT))
		return

	if(href_list["remove"])
		qdel(src)

/datum/virology_goal/propertysymptom
	name = "Symptom With Properties Viral Sample Request"
	var/datum/symptom/goal_symptom
	var/goal_property
	var/goal_property_text
	var/goal_property_value

/datum/virology_goal/propertysymptom/New()
	var/datum/symptom/S = pick(GLOB.list_symptoms)
	goal_symptom = new S
	goal_property = pick("resistance", "stealth", "stage_rate", "transmittable")
	if(goal_property == "stage_rate")
		goal_property_text = "stage rate"
	else
		goal_property_text = goal_property
	goal_property_value = rand(-18,11)
	if(goal_property == "resistance" && S.resistance)
		goal_property_value += S.resistance
	else if(goal_property == "stealth" && S.stealth)
		goal_property_value += S.stealth
	else if(goal_property == "stage_rate" && S.stage_speed)
		goal_property_value += S.stage_speed
	else if(S.transmittable)
		goal_property_value += S.transmittable

/datum/virology_goal/propertysymptom/get_report()
	return {"<b>Effects of [goal_symptom] symptom and level [goal_property_value] [goal_property_text]</b><br>
	Viral samples with a specific symptom and properties are required to study the effects of this symptom in various conditions. We need you to deliver [delivery_goal]u of viral samples containing the [goal_symptom] symptom and with the [goal_property_text] property at level [goal_property_value] along with 3 other symptoms to us through the cargo shuttle.
	<br>
	-Nanotrasen Virology Research"}

/datum/virology_goal/propertysymptom/get_ui_report()
	return {"Viral samples with a specific symptom and properties are required to study the effects of this symptom in various conditions. We need you to deliver [delivery_goal]u of viral samples containing the [goal_symptom] symptom and with the [goal_property_text] property at level [goal_property_value] along with 3 other symptoms to us through the cargo shuttle."}

/datum/virology_goal/propertysymptom/check_completion(list/datum/reagent/reagent_list)
	. = FALSE
	var/datum/reagent/blood/BL = locate() in reagent_list
	if(BL)
		if(BL.data && BL.data["viruses"])
			for(var/datum/disease/advance/D in BL.data["viruses"])
				if(D.symptoms.len < 4) //We want 3 other symptoms alongside the requested one
					return
				var/list/properties = D.GenerateProperties() += list("resistance" = 1, "stealth" = 0, "stage_rate" = 1, "transmittable" = 1, "severity" = 0)
				if(!D.GenerateProperties()[goal_property] == goal_property_value)
					return
				for(var/datum/symptom/S in D.symptoms)
					if(S == goal_symptom)
						delivered_amount += BL.volume
						if(delivered_amount >= delivery_goal)
							delivered_amount = delivery_goal
							completed = TRUE
							return TRUE
					else
						continue

/datum/virology_goal/virus
	name = "Specific Viral Sample Request"
	var/list/datum/symptom/goal_symptoms = list() //We could go with a diseaseID here instead a list of symptoms but we need the list to tell the player what symptoms to included

/datum/virology_goal/virus/New()
	var/list/datum/symptom/symptoms = GLOB.list_symptoms
	for(var/i=0, i<4, i++)
		var/datum/symptom/S = pick(symptoms)
		goal_symptoms += S
		symptoms -= S


/datum/virology_goal/virus/get_report()
	return {"<b>Specific Viral Sample Request</b><br>
	A specific viral sample is required for confidential reasons. We need you to deliver [delivery_goal]u of viral samples with the following symptoms: [symptoms_list2text()] to us through the cargo shuttle.
	<br>
	-Nanotrasen Virology Research"}

/datum/virology_goal/virus/get_ui_report()
	return {"A specific viral sample is required for confidential reasons. We need you to deliver [delivery_goal]u of viral samples with the following symptoms: [symptoms_list2text()] to us through the cargo shuttle."}

/datum/virology_goal/virus/proc/symptoms_list2text()
	var/msg = ""
	var/index = 1
	for(var/datum/symptom/S in goal_symptoms)
		if(index == goal_symptoms.len)
			msg += "[S]"
		else
			msg += "[S], "
		index += 1
	return msg

/datum/virology_goal/virus/check_completion(list/datum/reagent/reagent_list)
	. = FALSE
	var/datum/reagent/blood/BL = locate() in reagent_list
	if(BL)
		if(BL.data && BL.data["viruses"])
			for(var/datum/disease/advance/D in BL.data["viruses"])
				var/index = 1
				for(var/datum/symptom/S in goal_symptoms)
					if(!S == D.symptoms[index])
						return
					index += 1
				delivered_amount += BL.volume
				if(delivered_amount >= delivery_goal)
					delivered_amount = delivery_goal
					completed = TRUE
					return TRUE
