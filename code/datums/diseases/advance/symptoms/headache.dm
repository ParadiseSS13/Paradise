/*
//////////////////////////////////////

Headache

	Noticable.
	Highly resistant.
	Increases stage speed.
	Not transmittable.
	Low Level.

BONUS
	Displays an annoying message!
	Should be used for buffing your disease.

//////////////////////////////////////
*/

/datum/symptom/headache

	name = "Headache"
	stealth = 2
	resistance = 0
	stage_speed = 0
	transmittable = 3
	level = 1
	severity = 1
	treatments = list("hydrocodone", "morphine", "sal_acid")

/datum/symptom/headache/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		to_chat(M, "<span class='warning'>[pick("Your head hurts.", "Your head starts pounding.")]</span>")
	return
