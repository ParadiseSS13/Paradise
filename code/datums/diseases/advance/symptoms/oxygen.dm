/*
//////////////////////////////////////

Self-Respiration

	Slightly hidden.
	Lowers resistance significantly.
	Decreases stage speed significantly.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	The body generates salbutamol.

//////////////////////////////////////
*/

/datum/symptom/oxygen

	name = "Self-Respiration"
	stealth = 1
	resistance = -3
	stage_speed = -3
	transmissibility = -4
	level = 6
	chem_treatments = list(
		"cyanide" = list("multiplier" = 0, "timer" = 0))
	activation_prob = SYMPTOM_ACTIVATION_PROB * 5

/datum/symptom/oxygen/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			if(M.reagents.get_reagent_amount("salbutamol") < 20)
				M.reagents.add_reagent("salbutamol", 20)
		else
			to_chat(M, "<span class='notice'>[pick("Your lungs feel great.", "You realize you haven't been breathing.", "You don't feel the need to breathe.")]</span>")
	return
