/*
//////////////////////////////////////

Self-Respiration

	Lowers resistance.
	Decreases stage speed slightly.
	Decreases transmittablity.
	Fatal Level.

Bonus
	The body generates hydrocodone

//////////////////////////////////////
*/

/datum/symptom/painkiller

	name = "Neural Blockade"
	stealth = -3
	resistance = -2
	stage_speed = -1
	transmittable = -2
	level = 6

/datum/symptom/painkiller/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				if(M.reagents.get_reagent_amount("hydrocodone") < 8 && M.getToxLoss() < 13)
					M.reagents.add_reagent("hydrocodone", 2)
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					to_chat(M, "<span class='notice'>[pick("Your body feels numb.", "You realize you feel nothing.", "You can't feel your body.")]</span>")
	return
