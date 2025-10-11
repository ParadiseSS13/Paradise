// Symptoms are the effects that engineered advanced diseases do.

GLOBAL_LIST_INIT(list_symptoms, subtypesof(/datum/symptom))

/datum/symptom
	// Buffs/Debuffs the symptom has to the overall engineered disease.
	var/name = ""
	var/stealth = 0
	var/resistance = 0
	var/stage_speed = 0
	var/transmissibility = 0
	/// The type level of the symptom. Higher is harder to generate.
	var/level = 0
	/// The severity level of the symptom. Higher is more dangerous.
	var/severity = 0
	/// The hash tag for our diseases, we will add it up with our other symptoms to get a unique id! ID MUST BE UNIQUE!!!
	var/id = ""
	/// Asoc list of treatment reagents to multiplier and timer. Multiplier multiplies the frequency and strength of the symptom
	var/list/chem_treatments = list()
	/// Asoc list of physical treatments to multiplier and timer. Multiplier multiplies the frequency and strength of the symptom
	var/list/phys_treatments = list()
	/// Amount of treatment reagents the symptom will consume
	var/purge_amount = 0.4
	/// How likely the symptom is to activate each process cycle
	var/activation_prob = SYMPTOM_ACTIVATION_PROB


/datum/symptom/New()
	var/list/S = GLOB.list_symptoms
	for(var/i = 1; i <= length(S); i++)
		if(type == S[i])
			id = "[i]"
			return
	CRASH("We couldn't assign an ID!")

// Called when processing of the advance disease, which holds this symptom, starts.
/datum/symptom/proc/Start(datum/disease/advance/A)
	return

// Called when the advance disease is going to be deleted or when the advance disease stops processing.
/datum/symptom/proc/End(datum/disease/advance/A)
	return

/// Checks the conditions for symptom activation
/datum/symptom/proc/Activate(datum/disease/advance/A)
	var/unmitigated = check_treatment(A)
	if(prob(unmitigated * activation_prob))
		symptom_act(A, unmitigated)
	return

/// Applies the symptom effects
/datum/symptom/proc/symptom_act(datum/disease/advance/A, unmitigated)
	return

/// Checks all forms of treatment and
/datum/symptom/proc/check_treatment(datum/disease/advance/A)
	. = 1
	. *= check_chem_treatment(A)
	. *= check_phys_treatment(A)
	post_treatment(A, .)

/// Actions that are taken after the treatment check like reverting or lessening effects.
/datum/symptom/proc/post_treatment(datum/disease/advance/A, unmitigated)
	return

/// Default behaviour for treatment chems. Mitigate the symptom for a while after being consumed.
/datum/symptom/proc/check_chem_treatment(datum/disease/advance/A)
	. = 1
	// Make an assoc id to volume list we can easily search through and use
	var/list/mob_reagents = list()
	for(var/datum/reagent/chem in A.affected_mob.reagents.reagent_list)
		mob_reagents += list("[chem.id]" = chem.volume)
	// Go over each treatment and apply its mitigation if it still has timer. increase its timer if present in the patient
	for(var/treatment in chem_treatments)
		if(chem_treatments[treatment]["timer"] >= 1)
			. *= chem_treatments[treatment]["multiplier"]
			chem_treatments[treatment]["timer"]--
		if(treatment in mob_reagents)
			// Consume as much as we need but no more than we have
			var/consumption_mod = min(mob_reagents[treatment] / purge_amount, (VIRUS_MAX_CHEM_TREATMENT_TIMER - chem_treatments[treatment]["timer"]) / VIRUS_CHEM_TREATMENT_TIMER_MOD, 1)
			A.affected_mob.reagents.remove_reagent(treatment, purge_amount * consumption_mod)
			// Add to timer according to the amount consumed
			chem_treatments[treatment]["timer"] += VIRUS_CHEM_TREATMENT_TIMER_MOD * consumption_mod

/// Default behaviour for physical treatments. Mitigate the symptoms while effects remain
/datum/symptom/proc/check_phys_treatment(datum/disease/advance/A)
	. = 1
	for(var/treatment in phys_treatments)
		if(phys_treatments[treatment]["timer"] >= 1)
			. *= phys_treatments[treatment]["multiplier"]
			phys_treatments[treatment]["timer"]--

/datum/symptom/proc/increase_phys_treatment_timer(treatment, time = VIRUS_PHYS_TREATMENT_TIMER_MOD)
	if(!phys_treatments[treatment])
		return
	phys_treatments[treatment]["timer"] = min(phys_treatments[treatment]["timer"] + time, phys_treatments[treatment]["max_timer"])
