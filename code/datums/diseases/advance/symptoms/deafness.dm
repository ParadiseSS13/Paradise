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
				M << "<span class='warning'>[pick("You hear a ringing in your ear.", "Your ears pop.")]</span>"
			if(5)
				if(!(M.ear_deaf))
					M << "<span class='userdanger'>Your ears pop and begin ringing loudly!</span>"
					M.setEarDamage(-1,INFINITY) //Shall be enough
					spawn(200)
						if(M)
							M << "<span class='warning'>The ringing in your ears fades...</span>"
							M.setEarDamage(-1,0)
	return