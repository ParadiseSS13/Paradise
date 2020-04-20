/*
//////////////////////////////////////

Deafness

	Slightly noticable.
	Lowers resistance.
	Decreases stage speed slightly.
	Decreases transmittablity.
	Intense Level.

Bonus
	Causes intermittent loss of hearing.

//////////////////////////////////////
*/

/datum/symptom/deafness

	name = "Deafness"
	stealth = -1
	resistance = -2
	stage_speed = -1
	transmittable = -3
	level = 4
	severity = 3

/datum/symptom/deafness/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(3, 4)
				to_chat(M, "<span class='warning'>[pick("Escuchas un zumbido en tu oido.", "Tus oidos explotan.")]</span>")
			if(5)
				if(!(M.disabilities & DEAF))
					to_chat(M, "<span class='userdanger'>Tus odios explotan y empiezan a sonar!</span>")
					M.BecomeDeaf()
					spawn(200)
						if(M)
							to_chat(M, "<span class='warning'>El zumbido en tus oidos se desvanece...</span>")
							M.CureDeaf()
	return
