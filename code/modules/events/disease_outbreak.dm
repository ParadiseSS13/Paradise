GLOBAL_VAR(current_pending_disease)
/datum/event/disease_outbreak
	/// The type of disease that patient zero will be infected with.
	var/datum/disease/D

	var/list/disease_blacklist = list(/datum/disease/advance, /datum/disease/appendicitis, /datum/disease/kuru, /datum/disease/critical, /datum/disease/rhumba_beat, /datum/disease/fake_gbs,
										/datum/disease/gbs, /datum/disease/transformation, /datum/disease/food_poisoning, /datum/disease/advance/cold, /datum/disease/advance/flu, /datum/disease/advance/heal,
										/datum/disease/advance/hullucigen, /datum/disease/advance/sensory_restoration, /datum/disease/advance/voice_change)
	var/static/list/transmissable_symptoms = list()
	var/static/list/diseases_minor = list()
	var/static/list/diseases_moderate = list()
	var/static/list/diseases_major = list()

/datum/event/disease_outbreak/setup()
	if(isemptylist(diseases_minor) && isemptylist(diseases_moderate) && isemptylist(diseases_major))
		populate_diseases()
	if(isemptylist(transmissable_symptoms))
		populate_symptoms()
	var/datum/disease/virus
	if(prob(25))
		switch(severity)
			if(EVENT_LEVEL_MUNDANE) virus = pick(diseases_minor)
			if(EVENT_LEVEL_MODERATE) virus = pick(diseases_moderate)
			if(EVENT_LEVEL_MAJOR) virus = pick(diseases_major)
		D = new virus()
	else
		D = create_virus(severity * 2)	//Severity of the virus depends on the event severity level
	D.carrier = TRUE

/datum/event/disease_outbreak/start()
	GLOB.current_pending_disease = D
	var/severity_text = "undefined (contact a coder)"
	switch(severity)
		if(EVENT_LEVEL_MUNDANE) severity_text = "mundane"
		if(EVENT_LEVEL_MODERATE) severity_text = "moderate"
		if(EVENT_LEVEL_MAJOR) severity_text = "major"


	for(var/mob/M as anything in GLOB.dead_mob_list) //Announce outbreak to dchat
		to_chat(M, "<span class='deadsay'><b>Disease outbreak:</b> The next new arrival is a carrier of a [severity_text] disease!</span>")

//Creates a virus with a harmful effect, guaranteed to be spreadable by contact or airborne
/datum/event/disease_outbreak/proc/create_virus(max_severity = 6)
	var/datum/disease/advance/A = new /datum/disease/advance
	A.symptoms = A.GenerateSymptomsBySeverity(max_severity - 1, max_severity, 2) //Choose "Payload" symptoms
	A.AssignProperties(A.GenerateProperties())
	var/list/symptoms_to_try = deepCopyList(transmissable_symptoms)
	for(var/sanity=0, sanity<25, sanity++)
		if(A.spread_text != "Blood")
			break
		if(A.symptoms.len < VIRUS_SYMPTOM_LIMIT)	//Ensure the virus is spreadable by adding symptoms that boost transmission
			var/datum/symptom/TS = pick_n_take(symptoms_to_try)
			A.AddSymptom(new TS)
		else
			popleft(A.symptoms)	//We have a full symptom list but are still not transmittable. Try removing one of the "payloads"

		A.AssignProperties(A.GenerateProperties())
	A.Refresh()
	return A

/datum/event/disease_outbreak/proc/populate_diseases()
	for(var/candidate in subtypesof(/datum/disease))
		var/datum/disease/CD = candidate
		if(candidate in disease_blacklist)
			continue
		switch(initial(CD.severity))
			if(NONTHREAT, MINOR) diseases_minor += candidate
			if(MEDIUM, HARMFUL) diseases_moderate += candidate
			if(DANGEROUS, BIOHAZARD) diseases_major += candidate

/datum/event/disease_outbreak/proc/populate_symptoms()
	for(var/candidate in subtypesof(/datum/symptom))
		var/datum/symptom/CS = candidate
		if(initial(CS.transmittable) > 1)
			transmissable_symptoms += candidate
