/*
//////////////////////////////////////

Spontaneous Combustion

	Slightly hidden.
	Lowers resistance tremendously.
	Decreases stage tremendously.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	Ignites infected mob.

//////////////////////////////////////
*/

/datum/symptom/fire

	name = "Spontaneous Combustion"
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6
	severity = 5

/datum/symptom/fire/Activate()
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = virus.affected_mob
		switch(virus.stage)
			if(3)
				to_chat(M, "<span class='warning'>[pick("You feel hot.", "You hear a crackling noise.", "You smell smoke.")]</span>")
			if(4)
				Firestacks(M)
				M.IgniteMob()
				to_chat(M, "<span class='userdanger'>Your skin bursts into flames!</span>")
				M.emote("scream")
			if(5)
				Firestacks(M)
				M.IgniteMob()
				to_chat(M, "<span class='userdanger'>Your skin erupts into an inferno!</span>")
				M.emote("scream")
	return

/datum/symptom/fire/proc/Firestacks(mob/living/M)
	var/get_stacks = GetEfficiency()
	M.adjust_fire_stacks(get_stacks)
	M.adjustFireLoss(virus.stage == 4 ? get_stacks/2 : get_stacks)
	return 1

/datum/symptom/fire/GetEfficiency()
	if(virus.stage == 4)
		return (sqrtor0(20+virus.totalStageSpeed()*2))-(sqrtor0(16+virus.totalStealth()))
	else
		return (sqrtor0(20+virus.totalStageSpeed()*3))-(sqrtor0(16+virus.totalStealth()))