/*
//////////////////////////////////////

Shivering

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmittable.
	Low level.

Bonus
	Cools down your body.

//////////////////////////////////////
*/

/datum/symptom/shivering

	name = "Shivering"
	stealth = 0
	resistance = 2
	stage_speed = 2
	transmittable = 2
	level = 2
	severity = 2

/datum/symptom/shivering/Activate()
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = virus.affected_mob
		to_chat(M, "<span class='warning'>[pick("You feel cold.", "You start shivering.")]</span>")
		if(M.bodytemperature > BODYTEMP_COLD_DAMAGE_LIMIT)
			Chill(M)
	return

/datum/symptom/shivering/proc/Chill(mob/living/M)
	var/get_cold = GetEfficiency()
	M.bodytemperature = max(M.bodytemperature - get_cold, BODYTEMP_COLD_DAMAGE_LIMIT + 1)
	return 1

/datum/symptom/shivering/GetEfficiency()
	return (sqrtor0(16+virus.totalStealth()*2))+(sqrtor0(21+virus.totalResistance()*2)) * virus.stage