/*
//////////////////////////////////////

Sneezing

	Very Noticable.
	Increases resistance.
	Doesn't increase stage speed.
	Very transmittable.
	Low Level.

Bonus
	Forces a spread type of AIRBORNE
	with extra range!

//////////////////////////////////////
*/

/datum/symptom/sneeze

	name = "Sneezing"
	stealth = -2
	resistance = 3
	stage_speed = 0
	transmittable = 4
	level = 1
	severity = 1

/datum/symptom/sneeze/Activate()
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = virus.affected_mob
		switch(virus.stage)
			if(1, 2, 3)
				M.emote("sniff")
			else
				M.emote("sneeze")
				virus.spread(5)
	return

/datum/symptom/sneeze/GetEfficiency()
	if(virus.stage > 3)
		return rand(1, 5) //If more viruses have sneezing you want to rotate the virus spread
	return 0