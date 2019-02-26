/*
//////////////////////////////////////

Choking

	Very very noticable.
	Lowers resistance.
	Decreases stage speed.
	Decreases transmittablity tremendously.
	Moderate Level.

Bonus
	Inflicts spikes of oxyloss

//////////////////////////////////////
*/

/datum/symptom/choking

	name = "Choking"
	stealth = -3
	resistance = -2
	stage_speed = -2
	transmittable = -4
	level = 3
	severity = 3

/datum/symptom/choking/Activate()
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = virus.affected_mob
		switch(virus.stage)
			if(1, 2)
				to_chat(M, "<span class='warning'>[pick("You're having difficulty breathing.", "Your breathing becomes heavy.")]</span>")
			if(3, 4)
				to_chat(M, "<span class='warning'><b>[pick("Your windpipe feels like a straw.", "Your breathing becomes tremendously difficult.")]</span>")
				Choke(M)
				M.emote("gasp")
			else
				to_chat(M, "<span class='userdanger'>[pick("You're choking!", "You can't breathe!")]</span>")
				Choke(M)
				M.emote("gasp")
	return

/datum/symptom/choking/proc/Choke(mob/living/M)
	var/get_damage = GetEfficiency()
	M.adjustOxyLoss(get_damage)
	return 1

/datum/symptom/choking/GetEfficiency()
	switch(virus.stage)
		if(3, 4)
			return sqrtor0(21+virus.totalStageSpeed()*0.5)+sqrtor0(16+virus.totalStealth())
		else
			return sqrtor0(21+virus.totalStageSpeed()*0.5)+sqrtor0(16+virus.totalStealth()*5)