/// Evoltion chance each cycle in percents.
/// a value of 0.0057% corresponds to a 1 in 30 chance of new strain every 600 cycles or 20 minutes.
#define EVOLUTION_CHANCE 0.0057

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
									"atropine", "mitocholide", "lazarus_reagent",
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

	// NEW VARS

	/// The base properties of the virus. retained between strains
	var/list/base_properties = list("resistance" = 1, "stealth" = 0, "stage rate" = 1, "transmittable" = 1, "severity" = 0)
	/// Can the virus spotaneously evolve?
	var/evolution_chance = EVOLUTION_CHANCE
	/// The symptoms of the disease.
	var/list/symptoms = list()
	/// A unique ID for the strain and symptoms.
	var/id = ""
	/// Saves an ID. If that ID is analyzed the virus will be automatically analyzed when inserted into the PANDEMIC
	var/tracker = ""
	var/processing = FALSE
	/// A unique ID for the strain. Uses the unique_datum_id of the first virus datum that is of that strain.
	var/strain = ""

/*

	OLD PROCS

 */

/datum/disease/advance/New(process = 1, datum/disease/advance/D)
	if(!istype(D))
		D = null
	strain = "origin"
	// whether to generate a new cure or not
	var/new_cure = TRUE
	// Generate symptoms if we weren't given any.
	if(!symptoms || !length(symptoms))
		if(!D || !D.symptoms || !length(D.symptoms))
			symptoms = GenerateSymptoms(0, 2)
		else
			for(var/datum/symptom/S in D.symptoms)
				symptoms += new S.type
	// Copy cure, evolution ability and strain if we are copying an existing disease
	if(D)
		base_properties = D.base_properties
		stage = D.stage
		evolution_chance = D.evolution_chance
		tracker = D.tracker
		for(var/r in D.cures)
			cures += r
		cure_text = D.cure_text
		strain = D.strain
		new_cure = FALSE

	Refresh(FALSE, FALSE , new_cure, FALSE)

	..(process, D)
	return

/datum/disease/advance/Destroy()
	if(processing)
		for(var/datum/symptom/S in symptoms)
			S.End(src)
	return ..()

// Randomly pick a symptom to activate.
/datum/disease/advance/stage_act()
	if(!..())
		return FALSE
	if(prob(evolution_chance))
		var/min = rand(1,6)
		var/max = rand(min,6)
		var/lastStrain = strain
		if(prob(95))
			Evolve(min, max)
		else
			Devolve()
		//create a new strain even if we didn't gain or lose symptoms
		if(lastStrain == strain)
			Refresh()
	if(symptoms && length(symptoms))
		var/list/mob_reagents = list()
		for(var/datum/reagent/chem in affected_mob.reagents.reagent_list)
			mob_reagents += chem.id
		if(!processing)
			processing = TRUE
			for(var/datum/symptom/S in symptoms)
				S.Start(src)
		var/treated = FALSE
		for(var/datum/symptom/S in symptoms)
			treated = FALSE
			for(var/treatment in S.treatments)
				if(treatment in mob_reagents)
					treated = TRUE
					affected_mob.reagents.remove_reagent(treatment, S.purge_amount)
			if(!treated)
				S.Activate(src)
	else
		CRASH("We do not have any symptoms during stage_act()!")
	return TRUE

// Compares type then ID.
/datum/disease/advance/IsSame(datum/disease/advance/D)
	if(ispath(D))
		return FALSE

	if(!istype(D, /datum/disease/advance))
		return FALSE

	if(GetDiseaseID() != D.GetDiseaseID())
		return FALSE

	return TRUE

// To add special resistances.
/datum/disease/advance/cure(resistance=1)
	if(affected_mob)
		var/id = "[GetDiseaseID()]"
		if(resistance && !(id in affected_mob.resistances))
			affected_mob.resistances[id] = id
		remove_virus()
	qdel(src)	//delete the datum to stop it processing

// Returns the advance disease with a different reference memory.
/datum/disease/advance/Copy(process = 0)
	return new /datum/disease/advance(process, src, 1)

/*

	NEW PROCS

 */

// Mix the symptoms of two diseases (the src and the argument)
/datum/disease/advance/proc/Mix(datum/disease/advance/D)
	if(!(IsSame(D)))
		var/list/possible_symptoms = shuffle(D.symptoms)
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

/datum/disease/advance/proc/Refresh(new_name = FALSE, archive = FALSE, new_cure = TRUE, new_strain = TRUE)
	if(new_strain)
		strain = "adv_[num2text(GLOB.next_unique_strain++, 8)]"
		evolution_chance = EVOLUTION_CHANCE

	if(evolution_chance)
		evolution_chance = EVOLUTION_CHANCE
	var/list/properties = GenerateProperties()
	AssignProperties(properties, new_cure)
	id = null

	if(!GLOB.archive_diseases[GetDiseaseID()])
		if(new_name)
			AssignName()
		GLOB.archive_diseases[GetDiseaseID()] = src // So we don't infinite loop
		GLOB.archive_diseases[GetDiseaseID()] = new /datum/disease/advance(0, src, 1)

	var/datum/disease/advance/A = GLOB.archive_diseases[GetDiseaseID()]
	AssignName(A.name)

//Generate disease properties based on the effects. Returns an associated list.
/datum/disease/advance/proc/GenerateProperties()

	if(!symptoms || !length(symptoms))
		CRASH("We did not have any symptoms before generating properties.")

	var/list/properties = base_properties.Copy()

	for(var/datum/symptom/S in symptoms)
		if(istype(S, /datum/symptom/viralevolution))
			evolution_chance *= 1.5
		properties["resistance"] += S.resistance
		properties["stealth"] += S.stealth
		properties["stage rate"] += S.stage_speed
		properties["transmittable"] += S.transmittable
		properties["severity"] = max(properties["severity"], S.severity) // severity is based on the highest severity symptom

	return properties

// Assign the properties that are in the list.
/datum/disease/advance/proc/AssignProperties(list/properties = list(), new_cure = TRUE)
	if(properties && length(properties))
		switch(properties["stealth"])
			if(0 to 2)
				visibility_flags = 0
			if(2 to INFINITY)
				visibility_flags = HIDDEN_SCANNER

		// The more symptoms we have, the less transmittable it is but some symptoms can make up for it.
		SetSpread(clamp(2 ** (properties["transmittable"] - length(symptoms)), BLOOD, AIRBORNE))
		permeability_mod = max(CEILING(0.4 * properties["transmittable"], 1), 1)
		cure_chance = 15 - clamp(properties["resistance"], -5, 5) // can be between 10 and 20
		stage_prob = max(properties["stage rate"], 2)
		SetSeverity(properties["severity"])
		evolution_chance *= (1 + sqrtor0(properties["stage rate"]) / 3)
		if(new_cure)
			GenerateCure(properties)
	else
		CRASH("Our properties were empty or null!")


// Assign the spread type and give it the correct description.
/datum/disease/advance/proc/SetSpread(spread_id)
	switch(spread_id)
		if(NON_CONTAGIOUS, SPECIAL)
			spread_text = "Non-contagious"
		if(CONTACT_GENERAL, CONTACT_HANDS, CONTACT_FEET)
			spread_text = "On contact"
		if(AIRBORNE)
			spread_text = "Airborne"
		if(BLOOD)
			spread_text = "Blood"

	spread_flags = spread_id

/datum/disease/advance/proc/SetSeverity(level_sev)

	switch(level_sev)

		if(-INFINITY to 0)
			severity = NONTHREAT
		if(1)
			severity = MINOR
		if(2)
			severity = MEDIUM
		if(3)
			severity = HARMFUL
		if(4)
			severity = DANGEROUS
		if(5 to INFINITY)
			severity = BIOHAZARD
		else
			severity = "Unknown"


/datum/disease/advance/proc/CurePick(list/curelist = list())
	var/list/options = curelist - cures
	return pick(options)

// Will generate a random cure, the less resistance the symptoms have, the harder the cure.
/datum/disease/advance/proc/GenerateCure(list/properties = list())
	if(properties && length(properties))
		var/res = clamp((properties["resistance"] - length(symptoms) / 2) / 2 , 1 , length(GLOB.advanced_cures))
		cures = list()
		cure_text = ""
		cures += pick(GLOB.standard_cures)
		if(res > 1)
			cures += prob(50) ? CurePick(GLOB.advanced_cures) : CurePick(GLOB.plant_cures)
		if(res > 2)
			cures += prob(50) ? CurePick(GLOB.plant_cures) : CurePick(GLOB.drinks)
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

// Simply removes the symptom.
/datum/disease/advance/proc/RemoveSymptom(datum/symptom/S)
	symptoms -= S
	return

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

	var/datum/disease/advance/D = new(0, null)

	var/base_props = list("resistance" = 1, "stealth" = 0, "stage rate" = 1, "transmittable" = 1, "severity" = 0)

	for(var/prop in base_props)
		var/current_prop = input(user, "Enter base [prop]", "Base Stats", null)
		if(current_prop)
			D.base_properties[prop] = text2num(current_prop)

	var/i = VIRUS_SYMPTOM_LIMIT

	D.symptoms = list()

	var/list/symptoms = list()
	symptoms += "Done"
	symptoms += GLOB.list_symptoms.Copy()
	do
		if(user)
			var/symptom = input(user, "Choose a symptom to add ([i] remaining)", "Choose a Symptom") in symptoms
			if(isnull(symptom))
				return
			else if(istext(symptom))
				i = 0
			else if(ispath(symptom))
				var/datum/symptom/S = new symptom
				if(!D.HasSymptom(S))
					D.symptoms += S
					i -= 1
	while(i > 0)

	if(length(D.symptoms) > 0)

		var/new_name = stripped_input(user, "Name your new disease.", "New Name")
		if(!new_name)
			return
		D.AssignName(new_name)
		D.Refresh()
		return D



/datum/disease/advance/proc/totalStageSpeed()
	var/total_stage_speed = 0
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_stage_speed += S.stage_speed
	return total_stage_speed

/datum/disease/advance/proc/totalStealth()
	var/total_stealth = 0
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_stealth += S.stealth
	return total_stealth

/datum/disease/advance/proc/totalResistance()
	var/total_resistance = 0
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_resistance += S.resistance
	return total_resistance

/datum/disease/advance/proc/totalTransmittable()
	var/total_transmittable = 0
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_transmittable += S.transmittable
	return total_transmittable

#undef EVOLUTION_CHANCE
