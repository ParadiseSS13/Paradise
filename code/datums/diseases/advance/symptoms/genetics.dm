/*
//////////////////////////////////////

DNA Saboteur

	Very noticable.
	Lowers resistance tremendously.
	No changes to stage speed.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	Cleans the DNA of a person and then randomly gives them a disability.

//////////////////////////////////////
*/

/datum/symptom/genetic_mutation

	name = "Deoxyribonucleic Acid Saboteur"
	stealth = -2
	resistance = -3
	stage_speed = 0
	transmittable = -3
	level = 6
	severity = 3
	var/list/possible_mutations
	var/archived_dna = null

/datum/symptom/genetic_mutation/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 5)) // 15% chance
		var/mob/living/carbon/M = A.affected_mob
		if(!M.has_dna())
			return
		switch(A.stage)
			if(4, 5)
				to_chat(M, "<span class='warning'>[pick("Your skin feels itchy.", "You feel light headed.")]</span>")
				M.dna.remove_mutation_group(possible_mutations)
				randmut(M, possible_mutations)
	return

// Archive their DNA before they were infected.
/datum/symptom/genetic_mutation/Start(datum/disease/advance/A)
	possible_mutations = (bad_mutations | not_good_mutations) - mutations_list[RACEMUT]
	var/mob/living/carbon/M = A.affected_mob
	if(M)
		if(!M.has_dna())
			return
		archived_dna = M.dna.struc_enzymes

// Give them back their old DNA when cured.
/datum/symptom/genetic_mutation/End(datum/disease/advance/A)
	var/mob/living/carbon/M = A.affected_mob
	if(M && archived_dna)
		if(!M.has_dna())
			return
		M.dna.struc_enzymes = archived_dna
		M.domutcheck()
