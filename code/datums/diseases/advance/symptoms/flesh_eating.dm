/*
//////////////////////////////////////

Necrotizing Fasciitis (AKA Flesh-Eating Disease)

	Very very noticable.
	Lowers resistance tremendously.
	No changes to stage speed.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Deals brute damage over time.

//////////////////////////////////////
*/

/datum/symptom/flesh_eating

	name = "Necrotizing Fasciitis"
	stealth = -3
	resistance = -3
	stage_speed = 0
	transmittable = -2
	level = 6
	severity = 6
	treatments = list("synthflesh", "lazarus_reagent")

/datum/symptom/flesh_eating/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.progress)
			if(30 to 59)
				to_chat(M, "<span class='warning'>[pick("You feel a sudden pain across your body.", "Drops of blood appear suddenly on your skin.")]</span>")
			if(60 to INFINITY)
				to_chat(M, "<span class='userdanger'>[pick("You cringe as a violent pain takes over your body.", "It feels like your body is eating itself inside out.", "IT HURTS.")]</span>")
				Flesheat(M, A)
	return

/datum/symptom/flesh_eating/proc/Flesheat(mob/living/M, datum/disease/advance/A)
	var/get_damage = ((A.progress / 100) ** 2) * ((sqrtor0(16 + A.totalStageSpeed()))*5)
	M.adjustBruteLoss(get_damage)
	return 1
