/*
//////////////////////////////////////

Sneezing

	Very Noticable.
	Increases resistance.
	Doesn't increase stage speed.
	Very transmissibility.
	Low Level.

Bonus
	Forces a spread type of SPREAD_AIRBORNE
	with extra range!

//////////////////////////////////////
*/

/datum/symptom/sneeze

	name = "Sneezing"
	stealth = -2
	stage_speed = 2
	transmissibility = 5
	level = 1
	severity = 1
	chem_treatments = list(
		"salbutamol" = list("multiplier" = 0, "timer" = 0),
		"perfluorodecalin" = list("multiplier" = 0, "timer" = 0))

/datum/symptom/sneeze/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	if(prob(A.progress + 20))
		M.emote("sneeze")
		A.spread(5 * unmitigated)
	else
		M.emote("sniff")
	return
