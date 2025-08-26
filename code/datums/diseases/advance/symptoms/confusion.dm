/*
//////////////////////////////////////

Confusion

	Little bit hidden.
	Lowers resistance.
	Decreases stage speed.
	Not very transmissibility.
	Intense Level.

Bonus
	Makes the affected mob be confused for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/confusion

	name = "Confusion"
	stealth = 1
	resistance = 1
	stage_speed = -3
	level = 4
	severity = 2
	chem_treatments = list(
		"synaptizine" = list("multiplier" = 0, "timer" = 0),
		"ephedrine" = list("multiplier" = 0, "timer" = 0),
		"methamphetamine" = list("multiplier" = 0, "timer" = 0),
		"coffee" = list("multiplier" = 0.7, "timer" = 0),
		"tea"= list("multiplier" = 0.7, "timer" = 0))


/datum/symptom/confusion/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/carbon/M = A.affected_mob
	if(prob(A.progress ** 2))
		to_chat(M, "<span class='userdanger'>You can't think straight!</span>")
		M.AdjustConfused(16 SECONDS * unmitigated, bound_lower = 0, bound_upper = 200 SECONDS)

	else
		to_chat(M, "<span class='warning'>[pick("Your head hurts.", "Your mind blanks for a moment.")]</span>")

	return
