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
	stealth = -4
	resistance = 3
	transmissibility = -3
	level = 6
	severity = 6
	chem_treatments = list(
		"synthflesh" = list("multiplier" = 0, "timer" = 0),
		"lazarus_reagent" = list("multiplier" = 0, "timer" = 0))

/datum/symptom/flesh_eating/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	if(A.stage > 1)
		if(prob(A.progress))
			to_chat(M, "<span class='userdanger'>[pick("You cringe as a violent pain takes over your body.", "It feels like your body is eating itself inside out.", "IT HURTS.")]</span>")
			Flesheat(M, A)
		else
			to_chat(M, "<span class='warning'>[pick("You feel a sudden pain across your body.", "Drops of blood appear suddenly on your skin.")]</span>")

	return

/datum/symptom/flesh_eating/proc/Flesheat(mob/living/M, datum/disease/advance/A)
	var/get_damage = (A.progress / 100) * ((sqrtor0(49 + 2 * A.totalStageSpeed()))*5)
	M.adjustBruteLoss(get_damage)
	return 1
