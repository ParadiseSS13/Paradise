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
	stealth = -3
	resistance = 3
	stage_speed = 1
	transmittable = -4
	level = 6
	severity = 6
	treatments = list("frostoil", "menthol")

/datum/symptom/fire/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.progress)
			if(30 to 59)
				to_chat(M, "<span class='warning'>[pick("You feel hot.", "You hear a crackling noise.", "You smell smoke.")]</span>")
			if(60 to 79)
				Firestacks_stage_4(M, A)
				M.IgniteMob()
				to_chat(M, "<span class='userdanger'>Your skin bursts into flames!</span>")
				M.emote("scream")
			if(80 to INFINITY)
				Firestacks_stage_5(M, A)
				M.IgniteMob()
				to_chat(M, "<span class='userdanger'>Your skin erupts into an inferno!</span>")
				M.emote("scream")
	return

/datum/symptom/fire/proc/Firestacks_stage_4(mob/living/M, datum/disease/advance/A)
	var/get_stacks = ((A.progress / 100) ** 2) * max(sqrtor0(5 + A.totalStageSpeed() * 2), 1)
	M.adjust_fire_stacks(get_stacks)
	M.adjustFireLoss(get_stacks * 2)
	return 1

/datum/symptom/fire/proc/Firestacks_stage_5(mob/living/M, datum/disease/advance/A)
	var/get_stacks = ((A.progress / 100) ** 2) * max(sqrtor0(10 + A.totalStageSpeed() * 3), 1)
	M.adjust_fire_stacks(get_stacks)
	M.adjustFireLoss(get_stacks * 4)
	return 1
