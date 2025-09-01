/*
//////////////////////////////////////

Itching

	Not noticable or unnoticable.
	Resistant.
	Increases stage speed.
	Little transmissibility.
	Low Level.

BONUS
	Displays an annoying message!
	Should be used for buffing your disease.

//////////////////////////////////////
*/

/datum/symptom/itching

	name = "Itching"
	stealth = 2
	resistance = -1
	stage_speed = 3
	transmissibility = 1
	level = 1
	severity = 1
	chem_treatments = list(
		"silver_sulfadiazine" = list("multiplier" = 0, "timer" = 0))

/datum/symptom/itching/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	to_chat(M, "<span class='warning'>Your [pick("back", "arm", "leg", "elbow", "head")] itches.</span>")
	return
