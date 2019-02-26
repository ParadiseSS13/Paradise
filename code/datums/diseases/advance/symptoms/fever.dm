/*
//////////////////////////////////////

Fever

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmittable.
	Low level.

Bonus
	Heats up your body.

//////////////////////////////////////
*/

/datum/symptom/fever

	name = "Fever"
	stealth = 0
	resistance = 3
	stage_speed = 3
	transmittable = 2
	level = 2
	severity = 2

/datum/symptom/fever/Activate()
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = virus.affected_mob
		to_chat(M, "<span class='warning'>[pick("You feel hot.", "You feel like you're burning.")]</span>")
		if(M.bodytemperature < BODYTEMP_HEAT_DAMAGE_LIMIT)
			Heat(M)

	return

/datum/symptom/fever/proc/Heat(mob/living/M)
	var/get_heat = GetEfficiency()
	M.bodytemperature = min(M.bodytemperature + get_heat, BODYTEMP_HEAT_DAMAGE_LIMIT - 1)
	return 1

/datum/symptom/fever/GetEfficiency()
	return (sqrtor0(21+virus.totalTransmittable()*2))+(sqrtor0(20+virus.totalStageSpeed()*3)) * virus.stage