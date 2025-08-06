/*
//////////////////////////////////////

Fever

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmissibility.
	Low level.

Bonus
	Heats up your body.

//////////////////////////////////////
*/

/datum/symptom/fever

	name = "Fever"
	stealth = 2
	resistance = 1
	stage_speed = 3
	transmissibility = 2
	level = 2
	severity = 2

/datum/symptom/fever/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/carbon/M = A.affected_mob
	to_chat(M, "<span class='warning'>[pick("You feel hot.", "You feel like you're burning.")]</span>")
	if(M.bodytemperature < BODYTEMP_HEAT_DAMAGE_LIMIT)
		Heat(M, A, unmitigated)
	return

/datum/symptom/fever/proc/Heat(mob/living/M, datum/disease/advance/A, unmitigated)
	var/get_heat = unmitigated * ((sqrtor0(21 + A.totaltransmissibility() * 2)) + (sqrtor0(20 + A.totalStageSpeed() * 3)))
	M.bodytemperature = min(M.bodytemperature + (get_heat * A.stage), BODYTEMP_HEAT_DAMAGE_LIMIT - 1)
	return 1
