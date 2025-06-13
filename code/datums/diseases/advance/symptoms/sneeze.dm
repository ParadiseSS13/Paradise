/*
//////////////////////////////////////

Sneezing

	Very Noticable.
	Increases resistance.
	Doesn't increase stage speed.
	Very transmittable.
	Low Level.

Bonus
	Forces a spread type of SPREAD_AIRBORNE
	with extra range!

//////////////////////////////////////
*/

/datum/symptom/sneeze

	name = "Sneezing"
	stealth = -2
	resistance = 0
	stage_speed = 2
	transmittable = 5
	level = 1
	severity = 1
	treatments = list("salbutamol", "perfluorodecalin")

/datum/symptom/sneeze/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		if(prob(A.progress + 20))
			M.emote("sneeze")
			A.spread(5)
		else
			M.emote("sniff")
	return
