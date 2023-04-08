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
	id = "painkiller"
	stealth = -3
	resistance = -2
	stage_speed = -1
	transmittable = -2
	level = 6

/datum/symptom/painkiller/Activate(datum/disease/advance/A)
	..()
	var/mob/living/M = A.affected_mob
	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		switch(A.stage)
			if(1)
				M.Confused(20)
			if(2, 3)
				M.Slowed(20)
				M.Confused(40)
				to_chat(M, "<span class='danger'>[pick("Something feels very wrong about your body.", "You have hard time controlling own body", "You can't feel your body.")]</span>")
			if(4, 5)
				if(prob(10))
					to_chat(M, "<span class='notice'>[pick("Your body feels numb.", "You realize you feel nothing.", "You can't feel your body.")]</span>")
	if(M.reagents.get_reagent_amount("hydrocodone") < 2 && M.getToxLoss() < 13 && A.stage > 4)
		M.reagents.add_reagent("hydrocodone", 0.5)
	return
