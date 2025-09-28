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
	phys_treatments = list(
		"body_temp" = list("multiplier" = 0.6, "timer" = 0, "max_timer" = VIRUS_MAX_PHYS_TREATMENT_TIMER * 6),
		)

/datum/symptom/flesh_eating/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	if(A.stage > 1)
		if(prob(A.progress))
			to_chat(M, "<span class='userdanger'>[pick("You cringe as a violent pain takes over your body.", "It feels like your body is eating itself inside out.", "IT HURTS.")]</span>")
			Flesheat(M, A, unmitigated)
		else
			to_chat(M, "<span class='warning'>[pick("You feel a sudden pain across your body.", "Drops of blood appear suddenly on your skin.")]</span>")

	return

/datum/symptom/flesh_eating/proc/Flesheat(mob/living/M, datum/disease/advance/A, unmitigated)
	var/get_damage = unmitigated * sqrtor0(49 + 2 * A.totalStageSpeed()) * A.progress / 20
	M.adjustBruteLoss(get_damage)
	return 1

/datum/symptom/flesh_eating/check_phys_treatment(datum/disease/advance/A)
	. = ..()
	if(!A.affected_mob)
		return
	var/temp_dist = max(A.affected_mob.bodytemperature - 313.15, 305.15 - A.affected_mob.bodytemperature)
	if(temp_dist > 0)
		increase_phys_treatment_timer("body_temp", min(temp_dist * 2, VIRUS_PHYS_TREATMENT_TIMER_MOD))


