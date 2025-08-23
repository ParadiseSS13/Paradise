/*
//////////////////////////////////////

Shivering

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmissibility.
	Low level.

Bonus
	Cools down your body.

//////////////////////////////////////
*/

/datum/symptom/shivering

	name = "Shivering"
	stealth = 1
	stage_speed = 2
	transmissibility = 3
	level = 2
	severity = 2

/datum/symptom/shivering/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/carbon/M = A.affected_mob
	to_chat(M, "<span class='warning'>[pick("You feel cold.", "You start shivering.")]</span>")
	M.emote("shiver")
	if(M.bodytemperature > BODYTEMP_COLD_DAMAGE_LIMIT)
		Chill(M, A)
	return

/datum/symptom/shivering/proc/Chill(mob/living/M, datum/disease/advance/A)
	var/get_cold = (sqrtor0(16+A.totalStealth()*2))+(sqrtor0(21+A.totalResistance()*2))
	M.bodytemperature = max(M.bodytemperature - (get_cold * A.stage), BODYTEMP_COLD_DAMAGE_LIMIT + 1)
	return 1
