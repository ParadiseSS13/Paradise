/*
//////////////////////////////////////

Alcochlorians

	Decreases Stealth
	Improves resistance significantly.
	Improves stage speed significantly.
	Decreases transmittablity.

Bonus
	The body generates alcohol.
	From Bacchus with love
//////////////////////////////////////
*/

/datum/symptom/booze

	name = "Alco-chlorians"
	id = "booze"
	stealth = -4
	resistance = 4
	stage_speed = 3
	transmittable = -2
	level = 3

/datum/symptom/booze/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 2))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				M.reagents.add_reagent(pick("rum", "vodka", "whiskey", "ale", "cider", "mead", "tequila", "wine", "beer"), 5) //somewhat safe drinks
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					to_chat(M, "<span class='notice'>[pick("You feel warmth.", "You feel joyful.", "You relax for a moment")]</span>") //span class notice because this is a drunkeness. Epic mind games ensues
	return
