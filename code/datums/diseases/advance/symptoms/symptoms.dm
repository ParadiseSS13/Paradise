// Symptoms are the effects that engineered advanced diseases do.

GLOBAL_LIST_INIT(list_symptoms, subtypesof(/datum/symptom))


/datum/symptom
	// Buffs/Debuffs the symptom has to the overall engineered disease.
	var/name = ""
	var/stealth = 0
	var/resistance = 0
	var/stage_speed = 0
	var/transmittable = 0
	// The type level of the symptom. Higher is harder to generate.
	var/level = 0
	// The severity level of the symptom. Higher is more dangerous.
	var/severity = 0
	// The hash tag for our diseases, we will add it up with our other symptoms to get a unique id! ID MUST BE UNIQUE!!!
	var/id = ""

// Called when processing of the advance disease, which holds this symptom, starts.
/datum/symptom/proc/Start(datum/disease/advance/A)
	return

// Called when the advance disease is going to be deleted or when the advance disease stops processing.
/datum/symptom/proc/End(datum/disease/advance/A)
	return

/datum/symptom/proc/Activate(datum/disease/advance/A)
	return

