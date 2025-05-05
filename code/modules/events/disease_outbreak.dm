GLOBAL_LIST_EMPTY(current_pending_diseases)
/datum/event/disease_outbreak
	// We only want the announcement to happen after the virus has spawned on station
	announceWhen = -1
	// Keep the event running until we announce it
	noAutoEnd = TRUE
	/// The type of disease that patient zero will be infected with.
	var/datum/disease/chosen_disease

	var/list/disease_blacklist = list(/datum/disease/advance, /datum/disease/appendicitis, /datum/disease/kuru, /datum/disease/critical, /datum/disease/rhumba_beat, /datum/disease/fake_gbs,
										/datum/disease/gbs, /datum/disease/transformation, /datum/disease/food_poisoning, /datum/disease/berserker, /datum/disease/zombie)
	var/static/list/transmissable_symptoms = list()
	var/static/list/diseases_minor = list()
	var/static/list/diseases_moderate_major = list()
	var/force_disease_time = 300

/datum/event/disease_outbreak/setup()
	if(isemptylist(diseases_minor) && isemptylist(diseases_moderate_major))
		populate_diseases()
	if(isemptylist(transmissable_symptoms))
		populate_symptoms()
	var/datum/disease/virus
	// Either choose a type to create a normal disease from or create an advanced disease
	switch(severity)
		if(EVENT_LEVEL_MUNDANE)
			virus = pick(diseases_minor)
		if(EVENT_LEVEL_MODERATE)
			if(prob(50))
				virus = pick(diseases_moderate_major)
			else
				chosen_disease = create_virus(severity * 2)
		if(EVENT_LEVEL_MAJOR)
			chosen_disease = create_virus(severity * 2)
	if(virus)
		chosen_disease = new virus

	chosen_disease.carrier = TRUE

/datum/event/disease_outbreak/start()
	GLOB.current_pending_diseases += list(list("disease" = chosen_disease, "event" = src))
	for(var/mob/M as anything in GLOB.dead_mob_list) //Announce outbreak to dchat
		if(istype(chosen_disease, /datum/disease/advance))
			var/datum/disease/advance/temp_disease = chosen_disease
			to_chat(M, chat_box_examine("<span class='deadsay'><b>Disease outbreak:</b> The next new arrival is a carrier of [chosen_disease.name]! A \"[chosen_disease.severity]\" disease with the following symptoms:\n[english_list(temp_disease.symptoms)]\nand the following stats:\n[english_map(temp_disease.GenerateProperties())]</span>"))
		else
			to_chat(M, chat_box_examine("<span class='deadsay'><b>Disease outbreak:</b> The next new arrival is a carrier of a \"[chosen_disease.severity]\" disease: [chosen_disease.name]!</span>"))

/datum/event/disease_outbreak/announce()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			GLOB.major_announcement.Announce("Lethal viral pathogen detected aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/effects/siren-spooky.ogg', new_sound2 = 'sound/AI/outbreak_virus.ogg')
		if(EVENT_LEVEL_MODERATE)
			GLOB.minor_announcement.Announce("Moderate contagion detected aboard [station_name()].", new_sound = 'sound/misc/notice2.ogg', new_title = "Contagion Alert")
		if(EVENT_LEVEL_MUNDANE)
			GLOB.minor_announcement.Announce("Minor contagion detected aboard [station_name()].", new_sound = 'sound/misc/notice2.ogg', new_title = "Contagion Alert")
	// We did our announcement, the event no longer needs to run
	kill()

/datum/event/disease_outbreak/process()
	if(activeFor == force_disease_time)
		for(var/list/disease_event in GLOB.current_pending_diseases)
			if(chosen_disease == disease_event["disease"])
				for(var/mob/living/carbon/human/player in GLOB.player_list)
					if(player.ForceContractDisease(chosen_disease, TRUE, TRUE))
						GLOB.current_pending_diseases -= list(disease_event)
						break
				announceWhen = activeFor + 150
				break
	. = ..()

//Creates a virus with a harmful effect, guaranteed to be spreadable by contact or airborne
/datum/event/disease_outbreak/proc/create_virus(max_severity = 6)
	var/datum/disease/advance/A = new /datum/disease/advance(_event = TRUE)
	// Base properties get buffs depending on severity
	var/list/properties_to_buff = A.base_properties.Copy()
	for(var/i = 0, i < max_severity / 2, i++)
		A.base_properties[pick(properties_to_buff)]++
	A.base_properties["transmittable"] += round(max_severity / 2)
	A.base_properties["stealth"] += max_severity // Stealth gets an additional bonus since most symptoms reduce it a fair bit.
	// Generate a 6 symptom disease, with some guaranteed to be close to the maximum severity
	A.symptoms += A.GenerateSymptomsBySeverity(1, max_severity, 3)
	A.symptoms += A.GenerateSymptomsBySeverity(max_severity - 2, max_severity, 2)
	A.symptoms += A.GenerateSymptomsBySeverity(max_severity - 1, max_severity, 1)
	A.AssignProperties(A.GenerateProperties())
	var/list/symptoms_to_try = transmissable_symptoms.Copy()
	var/spread_threhsold = SPREAD_CONTACT_HANDS
	// Chance for it to be extra spready, scales quadratically with severity
	if(prob((max_severity ** 2) * 3))
		spread_threhsold = SPREAD_CONTACT_GENERAL
	if(prob((max_severity ** 2) * 1.5))
		spread_threhsold = SPREAD_AIRBORNE
		A.base_properties["transmittable"]++
	while(length(symptoms_to_try))
		if(A.spread_flags & spread_threhsold)
			break
		if(length(A.symptoms) < VIRUS_SYMPTOM_LIMIT)	//Ensure the virus is spreadable by adding symptoms that boost transmission
			var/datum/symptom/TS = pick_n_take(symptoms_to_try)
			A.AddSymptom(new TS)
		else
			var/datum/symptom/removed = popleft(A.symptoms)	//We have a full symptom list but are still not transmittable. Try removing one of the "payloads"
			if(removed.transmittable > 0)
				symptoms_to_try |= removed.type

		A.AssignProperties(A.GenerateProperties())
		// If we ended up losing too much of the payload add another payload
		if(A.GenerateProperties()["severity"] < max_severity - 1)
			A.symptoms += A.GenerateSymptomsBySeverity(max_severity - 1, max_severity, 1)

	A.name = pick(GLOB.alphabet_uppercase) + num2text(rand(1,9)) + pick(GLOB.alphabet_uppercase) + num2text(rand(1,9)) + pick("v", "V", "-" + num2text(GLOB.game_year), "")
	A.Refresh()
	return A

/datum/event/disease_outbreak/proc/populate_diseases()
	for(var/candidate in subtypesof(/datum/disease))
		var/datum/disease/CD = new candidate
		if(is_type_in_list(CD, disease_blacklist))
			continue
		switch(CD.severity)
			if(VIRUS_NONTHREAT, VIRUS_MINOR)
				diseases_minor += candidate
			if(VIRUS_MEDIUM, VIRUS_HARMFUL, VIRUS_DANGEROUS, VIRUS_BIOHAZARD)
				diseases_moderate_major += candidate

/datum/event/disease_outbreak/proc/populate_symptoms()
	// Disease events shouldn't just resolve themselves
	var/list/candidate_list = subtypesof(/datum/symptom) - /datum/symptom/heal/longevity
	for(var/candidate in candidate_list)
		var/datum/symptom/CS = candidate
		if(initial(CS.transmittable) > 0)
			transmissable_symptoms += candidate
