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
	stage_speed = -2
	transmissibility = -4
	level = 3
	severity = 3
	chem_treatments = list(
		"perfluorodecalin" = list("multiplier" = 0, "timer" = 0))

/datum/symptom/choking/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2)
			to_chat(M, "<span class='warning'>[pick("You're having difficulty breathing.", "Your breathing becomes heavy.")]</span>")
		if(3, 4)
			to_chat(M, "<span class='warning'><b>[pick("Your windpipe feels like a straw.", "Your breathing becomes tremendously difficult.")]</span>")
			Choke(M, A, unmitigated)
			M.emote("gasp")
		else
			to_chat(M, "<span class='userdanger'>[pick("You're choking!", "You can't breathe!")]</span>")
			Choke(M, A)
			M.emote("gasp")
	return

/datum/symptom/choking/proc/Choke(mob/living/M, datum/disease/advance/A, unmitigated)
	var/get_damage = unmitigated
	if(A.stage < 5)
		get_damage *= sqrtor0(21 + A.totalStageSpeed() * 0.5)+sqrtor0(16+A.totalStealth())
	else
		get_damage *= sqrtor0(21 + A.totalStageSpeed() * 0.5)+sqrtor0(16+A.totalStealth() * 5)
	M.adjustOxyLoss(get_damage)
	return 1
