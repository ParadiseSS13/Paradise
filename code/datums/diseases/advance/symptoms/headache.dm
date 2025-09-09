/*
//////////////////////////////////////

Headache

	Noticable.
	Highly resistant.
	Increases stage speed.
	Not transmissibility.
	Low Level.

BONUS
	Displays an annoying message!
	Should be used for buffing your disease.

//////////////////////////////////////
*/

/datum/symptom/headache

	name = "Headache"
	stealth = 2
	transmissibility = 3
	level = 1
	severity = 1
	chem_treatments = list(
		"hydrocodone" = list("multiplier" = 0, "timer" = 0),
		"morphine" = list("multiplier" = 0, "timer" = 0),
		"sal_acid" = list("multiplier" = 0, "timer" = 0),
		"tea" = list("multiplier" = 0.5, "timer" = 0))

/datum/symptom/headache/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	to_chat(M, "<span class='warning'>[pick("Your head hurts.", "Your head starts pounding.")]</span>")
	return
