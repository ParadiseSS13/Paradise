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
	var/goal_symptom //Type path of the symptom
	var/goal_symptom_name
	var/goal_property
	var/goal_property_text
	var/goal_property_value

/datum/virology_goal/propertysymptom/New()
	var/type = pick(GLOB.list_symptoms)
	var/datum/symptom/S = new type()
	goal_symptom = S.type
	var/datum/symptom/SY = new goal_symptom()
	goal_symptom_name = SY.name
	qdel(SY)
	goal_property = pick("resistance", "stealth", "stage_rate", "transmittable")
	if(goal_property == "stage_rate")
		goal_property_text = "stage rate"
	else
		goal_property_text = goal_property
	goal_property_value = rand(-18,11)
	if(goal_property == "resistance")
		goal_property_value += S.resistance
	else if(goal_property == "stealth")
		goal_property_value += S.stealth
	else if(goal_property == "stage_rate")
		goal_property_value += S.stage_speed
	else
		goal_property_value += S.transmittable

/datum/virology_goal/propertysymptom/get_report()
	return {"<b>Effects of [goal_symptom_name] symptom and level [goal_property_value] [goal_property_text]</b><br>
	Viral samples with a specific symptom and properties are required to study the effects of this symptom in various conditions. We need you to deliver [delivery_goal]u of viral samples containing the [goal_symptom_name] symptom and with the [goal_property_text] property at level [goal_property_value] along with 3 other symptoms to us through the cargo shuttle.
	<br>
	-Nanotrasen Virology Research"}

/datum/virology_goal/propertysymptom/get_ui_report()
	return {"Viral samples with a specific symptom and properties are required to study the effects of this symptom in various conditions. We need you to deliver [delivery_goal]u of viral samples containing the [goal_symptom_name] symptom and with the [goal_property_text] property at level [goal_property_value] along with 3 other symptoms to us through the cargo shuttle."}

/datum/virology_goal/propertysymptom/check_completion(list/datum/reagent/reagent_list)
	. = FALSE
	var/datum/reagent/blood/BL = locate() in reagent_list
	if(BL)
		if(BL.data && BL.data["viruses"])
			for(var/datum/disease/advance/D in BL.data["viruses"])
				if(D.symptoms.len < 4) //We want 3 other symptoms alongside the requested one
					continue
				var/properties = D.GenerateProperties()
				var/property = properties[goal_property]
				if(!(property == goal_property_value))
					continue
				for(var/datum/symptom/S in D.symptoms)
					if(S.type == goal_symptom)
						delivered_amount += BL.volume
						if(delivered_amount >= delivery_goal)
							delivered_amount = delivery_goal
							completed = TRUE
							return TRUE
					else
						continue

/datum/virology_goal/virus
	name = "Specific Viral Sample Request"
	var/list/goal_symptoms = list() //List of type paths of the symptoms, we could go with a diseaseID here instead a list of symptoms but we need the list to tell the player what symptoms to include

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
	for(var/S in goal_symptoms)
		var/datum/symptom/SY = new S()
		if(index == goal_symptoms.len)
			msg += "[SY]"
		else
			msg += "[SY], "
		qdel(SY)
		index += 1
	return msg

/datum/virology_goal/virus/check_completion(list/datum/reagent/reagent_list)
	. = FALSE
	var/datum/reagent/blood/BL = locate() in reagent_list
	if(BL)
		if(BL.data && BL.data["viruses"])
			for(var/datum/disease/advance/D in BL.data["viruses"])
				var/skip = FALSE
				for(var/S in goal_symptoms)
					var/datum/symptom/SY = locate(S) in D.symptoms
					if(!SY)
						skip = TRUE
						break
				if(!skip)
					delivered_amount += BL.volume
					if(delivered_amount >= delivery_goal)
						delivered_amount = delivery_goal
						completed = TRUE
						return TRUE
