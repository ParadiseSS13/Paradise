
/*

	Advance Disease is a system for Virologist to Engineer their own disease with symptoms that have effects and properties
	which add onto the overall disease.

	If you need help with creating new symptoms or expanding the advance disease, ask for Giacom on #coderbus.

*/
GLOBAL_VAR_INIT(next_unique_strain, 1)

GLOBAL_LIST_EMPTY(archive_diseases)

// The order goes from easy to cure to hard to cure.
GLOBAL_LIST_INIT(standard_cures, list(
									"sodiumchloride", "sugar", "orangejuice",
									"spaceacillin", "salglu_solution", "ethanol",
									"teporone", "diphenhydramine", "lipolicide",
									"silver", "gold"
))

GLOBAL_LIST_INIT(advanced_cures, list(
									"atropine", "mitocholide", "acetic_acid",
									"cryoxadone", "hydrocodone", "haloperidol",
									"degreaser", "perfluorodecalin"
))

GLOBAL_LIST_INIT(plant_cures,list(
								"bicaridine", "kelotane", "omnizine",
								"synaptizine", "weak_omnizine", "morphine",
								"cbd", "thc", "nicotine" , "psilocybin"
))

/*

	PROPERTIES

 */

/datum/disease/advance

	name = "Unknown" // We will always let our Virologist name our disease.
	desc = "An engineered disease which can contain a multitude of symptoms."
	form = "Advance Disease" // Will let med-scanners know that this disease was engineered.
	agent = "advance microbes"
	max_stages = 5
	spread_text = "Unknown"
	viable_mobtypes = list(/mob/living/carbon/human)
	incubation = 60

	// NEW VARS

	/// The base properties of the virus. retained between strains
	var/list/base_properties = list("resistance" = 1, "stealth" = 0, "stage rate" = 1, "transmissibility" = 1)
	/// Chance of the virus evolving on spread
	var/evolution_chance = VIRUS_EVOLUTION_CHANCE
	/// The symptoms of the disease.
	var/list/symptoms = list()
	/// A unique ID for the strain and symptoms.
	var/id = ""
	/// Saves an ID. If that ID is analyzed the virus will be automatically analyzed when inserted into the PANDEMIC
	var/tracker = ""
	var/processing = FALSE
	/// A unique ID for the strain. Uses the unique_datum_id of the first virus datum that is of that strain.
	var/strain = ""
	/// The event the virus came from, if it did
	var/event
	/// How far along the disease has progressed? This is tied with stage but is separate to give more granularity to symptom effects
	var/progress = 0
	/// The time at which the disease last advanced
	var/last_advancement = 0
	/// The number of cures from the cure list required to cure a patient
	var/cures_required = 1

/*

	OLD PROCS

 */

/datum/disease/advance/New(datum/disease/advance/to_copy, _event = NONE, copy_stage = TRUE)
	if(!istype(to_copy))
		to_copy = null
	strain = "origin"
	event = _event
	last_advancement = world.time
	// whether to generate a new cure or not
	var/new_cure = TRUE
	// Generate symptoms if we weren't given any.
	if(!symptoms || !length(symptoms))
		if(!to_copy || !to_copy.symptoms || !length(to_copy.symptoms))
			symptoms = GenerateSymptoms(0, 2)
		else
			for(var/datum/symptom/S in to_copy.symptoms)
				symptoms += new S.type
	// Copy cure, evolution ability and strain if we are copying an existing disease
	if(to_copy)
		name = to_copy.name
		base_properties = to_copy.base_properties.Copy()
		evolution_chance = to_copy.evolution_chance
		tracker = to_copy.tracker
		for(var/cure_reagent in to_copy.cures)
			cures += cure_reagent
		cure_text = to_copy.cure_text
		strain = to_copy.strain
		if(copy_stage)
			stage = to_copy.stage
		event = to_copy.event
		new_cure = FALSE

	Refresh(FALSE, FALSE , new_cure, FALSE)

	return

/datum/disease/advance/Destroy()
	if(processing)
		for(var/datum/symptom/S in symptoms)
			S.End(src)
	if(event)
		var/datum/event/disease_outbreak/outbreak = locateUID(event)
		if(istype(outbreak) && !QDELETED(outbreak))
			outbreak.infected_players -= src
	return ..()

/// Randomly mutate the disease
/datum/disease/advance/after_infect()
	if(event && affected_mob.mind)
		var/datum/event/disease_outbreak/outbreak = locateUID(event)
		if(istype(outbreak) && !QDELETED(outbreak))
			outbreak.infected_players |= src
	if(prob(evolution_chance))
		if(affected_mob.mind)
			SSblackbox.record_feedback("tally", "Advanced Disease", 1, "Spontanous Evolution")
		var/min = rand(1, 6)
		var/max = rand(min, 6)
		var/last_strain = strain
		// In most cases we try to gain a symptom, rarely we lose one
		if(prob(95))
			Evolve(min, max)
		else
			Devolve()
		// Create a new strain even if we didn't gain or lose symptoms
		if(last_strain == strain)
			Refresh()

// Randomly pick a symptom to activate.
/datum/disease/advance/stage_act()
	if(!..())
		return FALSE
	if(symptoms && length(symptoms))
		var/list/mob_reagents = list()
		for(var/datum/reagent/chem in affected_mob.reagents.reagent_list)
			mob_reagents += list("[chem.id]" = chem.volume)
		if(!processing)
			processing = TRUE
			for(var/datum/symptom/S in symptoms)
				S.Start(src)
		for(var/datum/symptom/S in symptoms)
			S.Activate(src)
	else
		CRASH("We do not have any symptoms during stage_act()!")
	return TRUE

/datum/disease/advance/spread(force_spread)
	if(carrier || force_spread || prob(40 + progress))
		return ..()

/datum/disease/advance/handle_stage_advance(has_cure = FALSE)
	if(!has_cure && (prob(stage_prob) || world.time > last_advancement + 1000))
		last_advancement = world.time
		progress = min(progress + 6, 100)
		stage = min(ceil(progress / 20), max_stages)
		if(!discovered && stage >= CEILING(max_stages * discovery_threshold, 1)) // Once we reach a late enough stage, medical HUDs can pick us up even if we regress
			discovered = TRUE
			affected_mob.med_hud_set_status()

// Compares type then ID.
/datum/disease/advance/IsSame(datum/disease/advance/D)
	if(ispath(D))
		return FALSE

	if(!istype(D, /datum/disease/advance))
		return FALSE

	if(GetDiseaseID() != D.GetDiseaseID())
		return FALSE

	return TRUE

/datum/disease/advance/handle_cure_testing(has_cure = FALSE)
	. = ..()
	if(has_cure)
		progress = min(progress, stage * 20)

// To add special resistances.
/datum/disease/advance/cure(resistance=1)
	if(affected_mob)
		var/id = "[GetDiseaseID()]"
		if(resistance && !(id in affected_mob.resistances))
			affected_mob.resistances[id] = id
		remove_virus()
	qdel(src)	//delete the datum to stop it processing

// Gives the mob a resistance to this disease. Does not cure it if they are already infected
/datum/disease/advance/make_resistant(mob/living/target)
	if(target)
		var/id = "[GetDiseaseID()]"
		if(!(id in target.resistances))
			target.resistances[id] = id

// Returns the advance disease with a different reference memory.
/datum/disease/advance/Copy(copy_stage = TRUE)
	return new /datum/disease/advance(to_copy = src, copy_stage = copy_stage)

/datum/disease/advance/record_infection()
	SSblackbox.record_feedback("tally", "Advanced Disease", 1, "[name]_[strain] Infection")

/*

	NEW PROCS

 */

// Mix the symptoms of two diseases (the src and the argument)
/datum/disease/advance/proc/Mix(datum/disease/advance/D)
	if(!(IsSame(D)))
		var/list/possible_symptoms = list()
		// Wild viruses are less predictable when mixed
		if(D.event || event)
			possible_symptoms = shuffle(D.symptoms + D.GenerateSymptoms(1, 6, 3))
		else
			possible_symptoms = shuffle(D.symptoms)
		for(var/datum/symptom/S in possible_symptoms)
			AddSymptom(new S.type)

/datum/disease/advance/proc/HasSymptom(datum/symptom/S)
	for(var/datum/symptom/symp in symptoms)
		if(symp.id == S.id)
			return 1
	return 0

/datum/disease/advance/proc/GenerateSymptomsBySeverity(sev_min, sev_max, amount = 1)

	var/list/generated = list() // Symptoms we generated.

	var/list/possible_symptoms = list()
	for(var/symp in GLOB.list_symptoms)
		var/datum/symptom/S = new symp
		if(S.severity >= sev_min && S.severity <= sev_max)
			if(!HasSymptom(S))
				possible_symptoms += S

	if(!length(possible_symptoms))
		return generated

	for(var/i = 1 to amount)
		generated += pick_n_take(possible_symptoms)

	return generated


// Will generate new unique symptoms, use this if there are none. Returns a list of symptoms that were generated.
/datum/disease/advance/proc/GenerateSymptoms(level_min, level_max, amount_get = 0)

	var/list/generated = list() // Symptoms we generated.

	// Generate symptoms. By default, we only choose non-deadly symptoms.
	var/list/possible_symptoms = list()
	for(var/symp in GLOB.list_symptoms)
		var/datum/symptom/S = new symp
		if(S.level >= level_min && S.level <= level_max)
			if(!HasSymptom(S))
				possible_symptoms += S

	if(!length(possible_symptoms))
		return generated

	// Random chance to get more than one symptom
	var/number_of = amount_get
	if(!amount_get)
		number_of = 1
		while(prob(20))
			number_of += 1

	for(var/i = 1; number_of >= i && length(possible_symptoms); i++)
		generated += pick_n_take(possible_symptoms)

	return generated

/// Called after changes are made to a disease to apply them properly
/datum/disease/advance/proc/Refresh(new_name = FALSE, archive = FALSE, new_cure = TRUE, new_strain = TRUE)
	if(new_strain)
		strain = "adv_[num2text(GLOB.next_unique_strain++, 8)]"
		evolution_chance = VIRUS_EVOLUTION_CHANCE
	var/list/properties = GenerateProperties()
	AssignProperties(properties, new_cure)
	id = null

	if(!GLOB.archive_diseases[GetDiseaseID()])
		if(new_name)
			AssignName()
		GLOB.archive_diseases[GetDiseaseID()] = src // So we don't infinite loop
		GLOB.archive_diseases[GetDiseaseID()] = new /datum/disease/advance(src)

	var/datum/disease/advance/A = GLOB.archive_diseases[GetDiseaseID()]
	AssignName(A.name)

/// Generate disease properties based on the symptoms and base properties. Returns an associated list.
/datum/disease/advance/proc/GenerateProperties()

	if(!symptoms || !length(symptoms))
		CRASH("We did not have any symptoms before generating properties.")

	var/list/properties = base_properties.Copy()
	for(var/datum/symptom/S in symptoms)
		properties["resistance"] += S.resistance
		properties["stealth"] += S.stealth
		properties["stage rate"] += S.stage_speed
		properties["transmissibility"] += S.transmissibility
		properties["severity"] = max(properties["severity"], S.severity) // severity is based on the highest severity symptom

	return properties

/// Set the characteristics of the disease depending on the received properties
/datum/disease/advance/proc/AssignProperties(list/properties = list(), new_cure = TRUE)
	if(properties && length(properties))
		switch(properties["stealth"])
			if(0 to 2)
				visibility_flags = 0
			if(2 to INFINITY)
				visibility_flags = VIRUS_HIDDEN_SCANNER

		// The more symptoms we have, the less transmissibility it is but some symptoms can make up for it.
		SetSpread(clamp(2 ** (properties["transmissibility"] - length(symptoms)), SPREAD_BLOOD, SPREAD_AIRBORNE))
		permeability_mod = max(CEILING(0.4 * properties["transmissibility"], 1), 1)
		cure_chance = 20 - clamp(properties["resistance"], -5, 5) // can be between 10 and 20
		// The amount of cures needed to cure the disease. clamped between 1 and 6 because we generate 6 possible cures
		cures_required = round(max(2.2 * (1.1 ** properties["resistance"]), 1))
		// 9 stage rate is twice as fast as 0 stage rate, -9 stage rate is half as fast as 0.
		stage_prob = 4 * (1.08 ** properties["stage rate"])
		SetSeverity(properties["severity"])
		// Calculate evolution chance, unless stabilized with stabilizing agar
		if(evolution_chance)
			evolution_chance = VIRUS_EVOLUTION_CHANCE * (1 + sqrtor0(properties["stage rate"]) / 6)
		if(new_cure)
			GenerateCure(properties)
	else
		CRASH("Our properties were empty or null!")


// Assign the spread type and give it the correct description.
/datum/disease/advance/proc/SetSpread(spread_id)
	switch(spread_id)
		if(SPREAD_NON_CONTAGIOUS, SPREAD_SPECIAL)
			spread_text = "Non-contagious"
		if(SPREAD_CONTACT_GENERAL, SPREAD_CONTACT_HANDS, SPREAD_CONTACT_FEET)
			spread_text = "On contact"
		if(SPREAD_AIRBORNE)
			spread_text = "Airborne"
		if(SPREAD_BLOOD)
			spread_text = "Blood"

	spread_flags = spread_id

/datum/disease/advance/proc/SetSeverity(level_sev)

	switch(level_sev)

		if(-INFINITY to 0)
			severity = VIRUS_NONTHREAT
		if(1)
			severity = VIRUS_MINOR
		if(2)
			severity = VIRUS_MEDIUM
		if(3)
			severity = VIRUS_HARMFUL
		if(4)
			severity = VIRUS_DANGEROUS
		if(5 to INFINITY)
			severity = VIRUS_BIOHAZARD
		else
			severity = "Unknown"

/datum/disease/advance/has_cure()
	if(!(disease_flags & VIRUS_CURABLE))
		return 0

	var/cures_found = 0
	for(var/C_id in cures)
		if(C_id == "ethanol")
			for(var/datum/reagent/consumable/ethanol/booze in affected_mob.reagents.reagent_list)
				cures_found++
				break
		else if(affected_mob.reagents.has_reagent(C_id))
			cures_found++

	return cures_found >= cures_required

/datum/disease/advance/proc/cure_pick(list/curelist = list())
	var/list/options = curelist - cures
	return pick(options)

// Will generate a random cure, the less resistance the symptoms have, the harder the cure.
/datum/disease/advance/proc/GenerateCure(list/properties = list())
	if(properties && length(properties))
		cures = list()
		cure_text = ""
		cures += pick(GLOB.standard_cures)
		for(var/i in 1 to cures_required + 2)
			switch(pick(40;1, 40;2, 20;3))
				if(1)
					cures += cure_pick(GLOB.advanced_cures)
				if(2)
					cures += cure_pick(GLOB.plant_cures)
				if(3)
					cures += cure_pick(GLOB.drinks)
		for(var/cure in cures)
			// Get the cure name from the cure_id
			var/datum/reagent/D = GLOB.chemical_reagents_list[cure]
			cure_text += cure_text == "" ? "[D.name]" : ", [D.name]"
	return

// Randomly generate a symptom, has a chance to lose or gain a symptom.
/datum/disease/advance/proc/Evolve(min_level, max_level)
	var/s = safepick(GenerateSymptoms(min_level, max_level, 1))
	if(s)
		AddSymptom(s)
		Refresh(1)
	return

// Randomly remove a symptom.
/datum/disease/advance/proc/Devolve()
	if(length(symptoms) > 1)
		var/s = safepick(symptoms)
		if(s)
			RemoveSymptom(s)
			Refresh(1)
	return

// Name the disease.
/datum/disease/advance/proc/AssignName(_name = "Unknown")
	name = _name
	if(GLOB.archive_diseases[GetDiseaseID()])
		var/datum/disease/advance/virus = GLOB.archive_diseases[GetDiseaseID()]
		virus.name = _name
	return

// Return a unique ID of the disease.
/datum/disease/advance/GetDiseaseID()
	if(!id)
		var/list/L = list()
		for(var/datum/symptom/S in symptoms)
			L += S.id
		L = sortList(L) // Sort the list so it doesn't matter which order the symptoms are in and add the strain to the end
		L += strain
		var/result = jointext(L, ":")
		id = result
	return id


// Add a symptom, if it is over the limit (with a small chance to be able to go over)
// we take a random symptom away and add the new one.
/datum/disease/advance/proc/AddSymptom(datum/symptom/S)

	if(HasSymptom(S))
		return

	if(length(symptoms) < (VIRUS_SYMPTOM_LIMIT - 1) + rand(-1, 1))
		symptoms += S
	else
		RemoveSymptom(pick(symptoms))
		symptoms += S
	return

/datum/disease/advance/proc/has_symptom_path(symptom_path)
	for(var/datum/symptom/current_symptom in symptoms)
		if(current_symptom.type == symptom_path)
			return TRUE
	return FALSE

/datum/disease/advance/proc/add_symptom_path(symptom_path)
	if(has_symptom_path(symptom_path))
		return
	if(length(symptoms) < VIRUS_SYMPTOM_LIMIT)
		symptoms += new symptom_path

// Simply removes the symptom.
/datum/disease/advance/proc/RemoveSymptom(datum/symptom/S)
	symptoms -= S
	return

/datum/disease/advance/proc/clear_symptoms()
	for(var/datum/symptom/current_symptom in symptoms)
		symptoms -= current_symptom
		qdel(current_symptom)


/*

	Static Procs

*/

// Mix a list of advance diseases and return the mixed result.
/proc/Advance_Mix(list/D_list)

//	to_chat(world, "Mixing!!!!")

	var/list/diseases = list()

	for(var/datum/disease/advance/A in D_list)
		diseases += A.Copy()

	if(!length(diseases))
		return null
	if(length(diseases) <= 1)
		return pick(diseases) // Just return the only entry.

	var/i = 0
	// Mix our diseases until we are left with only one result.
	while(i < 20 && length(diseases) > 1)

		i++

		var/datum/disease/advance/D1 = pick(diseases)
		diseases -= D1

		var/datum/disease/advance/D2 = pick(diseases)
		// So that we don't mix a virus with itself
		if(D2.GetDiseaseID() != D1.GetDiseaseID())
			D2.Mix(D1)

	// Should be only 1 entry left, but if not let's only return a single entry
	// to_chat(world, "END MIXING!!!!!")
	var/datum/disease/advance/to_return = pick(diseases)
	to_return.Refresh(1)
	return to_return

/proc/SetViruses(datum/reagent/R, list/data)
	if(data)
		var/list/preserve = list()
		if(istype(data) && data["viruses"])
			for(var/datum/disease/A in data["viruses"])
				preserve += A.Copy()
			R.data = data.Copy()
		if(length(preserve))
			R.data["viruses"] = preserve

/proc/AdminCreateVirus(client/user)

	if(!user)
		return

	var/datum/disease/advance/admin_disease = new(_event = TRUE)

	var/base_props = list("resistance" = 1, "stealth" = 0, "stage rate" = 1, "transmissibility" = 1)

	for(var/prop in base_props)
		var/current_prop = input(user, "Enter base [prop]", "Base Stats", null)
		if(current_prop)
			admin_disease.base_properties[prop] = text2num(current_prop)

	var/i = VIRUS_SYMPTOM_LIMIT

	admin_disease.symptoms = list()

	var/list/symptoms = list()
	symptoms += "Done"
	symptoms += GLOB.list_symptoms.Copy()
	do
		if(user)
			var/symptom = tgui_input_list(user, "Choose a Symptom", "Choose a symptom to add ([i] remaining)", symptoms)
			if(isnull(symptom))
				return
			else if(istext(symptom))
				i = 0
			else if(ispath(symptom))
				var/datum/symptom/S = new symptom
				if(!admin_disease.HasSymptom(S))
					admin_disease.symptoms += S
					i -= 1
	while(i > 0)

	if(length(admin_disease.symptoms) > 0)

		var/new_name = stripped_input(user, "Name your new disease.", "New Name")
		if(!new_name)
			return
		admin_disease.AssignName(new_name)
		admin_disease.Refresh(FALSE, TRUE, TRUE, TRUE)
		return admin_disease


/datum/disease/advance/proc/totalStageSpeed()
	var/total_stage_speed = base_properties["stage rate"]
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_stage_speed += S.stage_speed
	return total_stage_speed

/datum/disease/advance/proc/totalStealth()
	var/total_stealth = base_properties["stealth"]
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_stealth += S.stealth
	return total_stealth

/datum/disease/advance/proc/totalResistance()
	var/total_resistance = base_properties["resistance"]
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_resistance += S.resistance
	return total_resistance

/datum/disease/advance/proc/totaltransmissibility()
	var/total_transmissibility = base_properties["transmissibility"]
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_transmissibility += S.transmissibility
	return total_transmissibility

/datum/disease/advance/get_required_cures()
	return cures_required

/datum/disease/advance/is_stabilized()
	return !evolution_chance

/datum/disease/advance/get_tracker()
	return tracker

/datum/disease/advance/get_ui_id()
	return id

/datum/disease/advance/get_strain_id()
	return strain

/datum/disease/advance/get_full_strain_id()
	return GetDiseaseID()

/datum/disease/advance/is_known(z)
	return (GetDiseaseID() in GLOB.known_advanced_diseases["[z]"])

/datum/disease/advance/get_pandemic_symptoms(z)
	. = list()
	var/disease_known = is_known(z)
	for(var/datum/symptom/virus_symptom in symptoms)
		var/known = disease_known || (virus_symptom.name in GLOB.detected_advanced_diseases["[z]"][GetDiseaseID()]["known_symptoms"])
		. += list(list(
			"name" = known ? virus_symptom.name : "UNKNOWN",
			"stealth" = known ? virus_symptom.stealth : "UNKNOWN",
			"resistance" = known ? virus_symptom.resistance : "UNKNOWN",
			"stageSpeed" = known ? virus_symptom.stage_speed : "UNKNOWN",
			"transmissibility" = known ? virus_symptom.transmissibility : "UNKNOWN",
			"complexity" = known ? virus_symptom.level : "UNKNOWN",
		))

/datum/disease/advance/get_pandemic_base_stats()
	return list(
		"resistance" = base_properties["resistance"],
		"stageSpeed" = base_properties["stage rate"],
		"stealth" = base_properties["stealth"],
		"transmissibility" = base_properties["transmissibility"],
		)
