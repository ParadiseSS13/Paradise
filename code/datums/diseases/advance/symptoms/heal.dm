/*
//////////////////////////////////////

Healing

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals toxins in the affected mob's blood stream.

//////////////////////////////////////
*/

/datum/symptom/heal

	name = "Toxic Filter"
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6

/datum/symptom/heal/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				Heal(M, A)
	return

/datum/symptom/heal/proc/Heal(mob/living/M, datum/disease/advance/A)
	var/get_damage = (sqrtor0(20+A.totalStageSpeed())*(1+rand()))
	M.adjustToxLoss(-get_damage)
	return 1

/*
//////////////////////////////////////

Metabolism

	Little bit hidden.
	Lowers resistance.
	Decreases stage speed.
	Decreases transmittablity temrendously.
	High Level.

Bonus
	Cures all diseases (except itself) and creates anti-bodies for them until the symptom dies.

//////////////////////////////////////
*/

/datum/symptom/heal/metabolism

	name = "Anti-Bodies Metabolism"
	stealth = -1
	resistance = -1
	stage_speed = -1
	transmittable = -4
	level = 3
	var/list/cured_diseases = list()

/datum/symptom/heal/metabolism/Heal(mob/living/M, datum/disease/advance/A)
	var/cured = 0
	for(var/thing in M.viruses)
		var/datum/disease/D = thing
		if(D != A)
			cured = 1
			cured_diseases += D.GetDiseaseID()
			D.cure()
	if(cured)
		to_chat(M, "<span class='notice'>You feel much better.</span>")

/datum/symptom/heal/metabolism/End(datum/disease/advance/A)
	// Remove all the diseases we cured.
	var/mob/living/M = A.affected_mob
	if(istype(M))
		if(cured_diseases.len)
			for(var/res in M.resistances)
				if(res in cured_diseases)
					M.resistances -= res
		to_chat(M, "<span class='warning'>You feel weaker.</span>")

/*
//////////////////////////////////////

Longevity

	Medium hidden boost.
	Large resistance boost.
	Large stage speed boost.
	Large transmittablity boost.
	High Level.

Bonus
	After a certain amount of time the symptom will cure itself.

//////////////////////////////////////
*/

/datum/symptom/heal/longevity

	name = "Longevity"
	stealth = 3
	resistance = 4
	stage_speed = 4
	transmittable = 4
	level = 3
	var/longevity = 30

/datum/symptom/heal/longevity/Heal(mob/living/M, datum/disease/advance/A)
	longevity -= 1
	if(!longevity)
		A.cure()

/datum/symptom/heal/longevity/Start(datum/disease/advance/A)
	longevity = rand(initial(longevity) - 5, initial(longevity) + 5)

/*
/*
//////////////////////////////////////

	DNA Restoration

	Not well hidden.
	Lowers resistance minorly.
	Does not affect stage speed.
	Decreases transmittablity greatly.
	Very high level.

Bonus
	Heals brain damage, treats radiation, cleans SE of non-power mutations.

//////////////////////////////////////
*/

/datum/symptom/heal/dna

	name = "Deoxyribonucleic Acid Restoration"
	stealth = -1
	resistance = -1
	stage_speed = 0
	transmittable = -3
	level = 5

/datum/symptom/heal/dna/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/amt_healed = (sqrtor0(20+A.totalStageSpeed()*(3+rand())))-(sqrtor0(16+A.totalStealth()*rand()))
	M.adjustBrainLoss(-amt_healed)
	//Non-power mutations, excluding race, so the virus does not force monkey -> human transformations.
	var/list/unclean_mutations = (not_good_mutations|bad_mutations) - mutations_list[RACEMUT]
	M.dna.remove_mutation_group(unclean_mutations)
	M.radiation = max(M.radiation - 3, 0)
	return 1
*/
