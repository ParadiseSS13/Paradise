// Cold
/datum/disease/advance/preset/cold
	name = "Cold"
	symptoms = list(new/datum/symptom/sneeze)

// Flu
/datum/disease/advance/preset/flu
	name = "Flu"
	symptoms = list(new/datum/symptom/cough)

// Voice Changing
/datum/disease/advance/preset/voice_change
	name = "Epiglottis Mutation"
	symptoms = list(new/datum/symptom/voice_change)

// Toxin Filter
/datum/disease/advance/preset/heal
	name = "Liver Enhancer"
	symptoms = list(new/datum/symptom/heal)
	possible_mutations = list(/datum/disease/advance/preset/advanced_regeneration, /datum/disease/advance/preset/cold/)

// Hullucigen
/datum/disease/advance/preset/hullucigen
	name = "Reality Impairment"
	symptoms = list(new/datum/symptom/hallucigen)
	possible_mutations = list(/datum/disease/brainrot, /datum/disease/advance/preset/sensory_restoration)

// Sensory Restoration
/datum/disease/advance/preset/sensory_restoration
	name = "Reality Enhancer"
	symptoms = list(new/datum/symptom/sensory_restoration)

// Mind Restoration
/datum/disease/advance/preset/mind_restoration
	name = "Reality Purifier"
	symptoms = list(new/datum/symptom/mind_restoration)

// Toxic Filter + Toxic Compensation + Viral Evolutionary Acceleration
/datum/disease/advance/preset/advanced_regeneration
	name = "Advanced Neogenesis"
	symptoms = list(new/datum/symptom/heal, new/datum/symptom/damage_converter, new/datum/symptom/viralevolution)

// Necrotizing Fasciitis + Viral Self-Adaptation + Eternal Youth + Dizziness
/datum/disease/advance/preset/stealth_necrosis
	name = "Necroeyrosis"
	symptoms = list(new/datum/symptom/flesh_eating, new/datum/symptom/viraladaptation, new/datum/symptom/youth, new/datum/symptom/dizzy)
	mutation_reagents = list("mutagen", "histamine")
	possible_mutations = list(/datum/disease/transformation/xeno)

//Facial Hypertrichosis + Voice Change + Itching
/datum/disease/advance/preset/pre_kingstons
	name = "Neverlasting Stranger"
	symptoms = list(new/datum/symptom/beard, new/datum/symptom/voice_change, new/datum/symptom/itching)
	mutation_reagents = list("mutagen", "radium")
	possible_mutations = list(/datum/disease/kingstons)
