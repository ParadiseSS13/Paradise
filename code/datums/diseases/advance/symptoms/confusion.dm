/*
//////////////////////////////////////

Confusion

	Little bit hidden.
	Lowers resistance.
	Decreases stage speed.
	Not very transmittable.
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
	transmittable = 0
	level = 4
	severity = 2
	treatments = list("synaptazine", "ephedrine",  "coffee" , "tea")


/datum/symptom/confusion/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		if(prob(A.progress ** 2))
			to_chat(M, "<span class='userdanger'>You can't think straight!</span>")
			M.AdjustConfused(16 SECONDS, bound_lower = 0, bound_upper = 200 SECONDS)

		else
			to_chat(M, "<span class='warning'>[pick("Your head hurts.", "Your mind blanks for a moment.")]</span>")


	return
