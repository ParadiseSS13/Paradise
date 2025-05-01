// Cold

/datum/disease/advance/cold/New(datum/disease/advance/to_copy, _event = FALSE, copy_stage = FALSE)
	if(!to_copy)
		name = "Cold"
		symptoms = list(new/datum/symptom/sneeze)
	..()


// Flu

/datum/disease/advance/flu/New(datum/disease/advance/to_copy, _event = FALSE, copy_stage = FALSE)
	if(!to_copy)
		name = "Flu"
		symptoms = list(new/datum/symptom/cough)
	..()


// Voice Changing

/datum/disease/advance/voice_change/New(datum/disease/advance/to_copy, _event = FALSE, copy_stage = FALSE)
	if(!to_copy)
		name = "Epiglottis Mutation"
		symptoms = list(new/datum/symptom/voice_change)
	..()


// Toxin Filter

/datum/disease/advance/heal/New(datum/disease/advance/to_copy, _event = FALSE, copy_stage = FALSE)
	if(!to_copy)
		name = "Liver Enhancer"
		symptoms = list(new/datum/symptom/heal)
	..()


// Hullucigen

/datum/disease/advance/hullucigen/New(datum/disease/advance/to_copy, _event = FALSE, copy_stage = FALSE)
	if(!to_copy)
		name = "Reality Impairment"
		symptoms = list(new/datum/symptom/hallucigen)
	..()

// Sensory Restoration

/datum/disease/advance/sensory_restoration/New(datum/disease/advance/to_copy, _event = FALSE, copy_stage = FALSE)
	if(!to_copy)
		name = "Reality Enhancer"
		symptoms = list(new/datum/symptom/sensory_restoration)
	..()
