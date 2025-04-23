GLOBAL_LIST_EMPTY(current_pending_diseases)
/datum/event/disease_outbreak
	/// The type of disease that patient zero will be infected with.
	var/datum/disease/chosen_disease

	var/list/disease_blacklist = list(/datum/disease/advance, /datum/disease/appendicitis, /datum/disease/kuru, /datum/disease/critical, /datum/disease/rhumba_beat, /datum/disease/fake_gbs,
										/datum/disease/gbs, /datum/disease/transformation, /datum/disease/food_poisoning, /datum/disease/berserker, /datum/disease/zombie)
	var/static/list/transmissable_symptoms = list()
	var/static/list/diseases_minor = list()
	var/static/list/diseases_moderate_major = list()

/datum/event/disease_outbreak/setup()
	if(isemptylist(diseases_minor) && isemptylist(diseases_moderate_major))
		populate_diseases()
	if(isemptylist(transmissable_symptoms))
		populate_symptoms()
	var/datum/disease/virus
	if(prob(50) && severity < EVENT_LEVEL_MAJOR)
		switch(severity)
			if(EVENT_LEVEL_MUNDANE)
				virus = pick(diseases_minor)
			if(EVENT_LEVEL_MODERATE)
				virus = pick(diseases_moderate_major)
		chosen_disease = new virus()
	else
		chosen_disease = create_virus(severity * 2)

	chosen_disease.carrier = TRUE

/datum/event/disease_outbreak/start()
	GLOB.current_pending_diseases += chosen_disease
	for(var/mob/M as anything in GLOB.dead_mob_list) //Announce outbreak to dchat
		if(istype(chosen_disease, /datum/disease/advance))
			var/datum/disease/advance/temp_disease = chosen_disease.Copy()
			to_chat(M, "<span class='deadsay'><b>Disease outbreak:</b> The next new arrival is a carrier of [chosen_disease.name]! A \"[chosen_disease.severity]\" disease with the following symptoms: [english_list(temp_disease.symptoms)] and the following base stats:[english_map(temp_disease.base_properties)]</span>")
		else
			to_chat(M, "<span class='deadsay'><b>Disease outbreak:</b> The next new arrival is a carrier of a \"[chosen_disease.severity]\" disease: [chosen_disease.name]!</span>")

//Creates a virus with a harmful effect, guaranteed to be spreadable by contact or airborne
/datum/event/disease_outbreak/proc/create_virus(max_severity = 6)
	var/datum/disease/advance/A = new /datum/disease/advance(_event = TRUE)
	// Give a random stat boost equal to severity
	var/list/properties_to_buff = A.base_properties.Copy()
	for(var/i = 0, i < max_severity, i++)
		A.base_properties[pick(properties_to_buff)]++
	A.base_properties["stealth"] += max_severity // Stealth gets an additional bonus since most symptoms reduce it a fair bit.
	A.symptoms = A.GenerateSymptomsBySeverity(max_severity - 1, max_severity, 2) // Choose "Payload" symptoms. Longevity is excluded
	A.AssignProperties(A.GenerateProperties())
	var/list/symptoms_to_try = transmissable_symptoms.Copy()
	while(length(symptoms_to_try))
		if(A.spread_text != "Blood")
			break
		if(length(A.symptoms) < VIRUS_SYMPTOM_LIMIT)	//Ensure the virus is spreadable by adding symptoms that boost transmission
			var/datum/symptom/TS = pick_n_take(symptoms_to_try)
			A.AddSymptom(new TS)
		else
			popleft(A.symptoms)	//We have a full symptom list but are still not transmittable. Try removing one of the "payloads"

		A.AssignProperties(A.GenerateProperties())
	A.name = pick(GLOB.alphabet_uppercase) + num2text(rand(1,9)) + pick(GLOB.alphabet_uppercase) + num2text(rand(1,9)) + pick("v", "V", "-" + num2text(GLOB.game_year), "")
	A.Refresh()
	return A

/datum/event/disease_outbreak/proc/populate_diseases()
	for(var/candidate in subtypesof(/datum/disease))
		var/datum/disease/CD = new candidate
		if(is_type_in_list(CD, disease_blacklist))
			continue
		switch(CD.severity)
			if(NONTHREAT, MINOR)
				diseases_minor += candidate
			if(MEDIUM, HARMFUL, DANGEROUS, BIOHAZARD)
				diseases_moderate_major += candidate

/datum/event/disease_outbreak/proc/populate_symptoms()
	// Disease events shouldn't just resolve themselves
	var/list/candidate_list = subtypesof(/datum/symptom) - /datum/symptom/heal/longevity
	for(var/candidate in candidate_list)
		var/datum/symptom/CS = candidate
		if(initial(CS.transmittable) > 1)
			transmissable_symptoms += candidate
