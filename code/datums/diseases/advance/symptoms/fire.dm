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
	transmissibility = -4
	level = 6
	severity = 6
	chem_treatments = list(
		"frostoil" = list("multiplier" = 0, "timer" = 0),
		"menthol" = list("multiplier" = 0, "timer" = 0),
		"water" = list("multiplier" = 0.82, "timer" = 0))

/datum/symptom/fire/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	if(evaporate_wetness(A, unmitigated * A.progress / 100))
		return
	switch(A.progress)
		if(30 to 59)
			to_chat(M, "<span class='warning'>[pick("You feel hot.", "You hear a crackling noise.", "You smell smoke.")]</span>")
		if(60 to 79)
			Firestacks(M, A, unmitigated)
			M.IgniteMob()
			to_chat(M, "<span class='userdanger'>Your skin bursts into flames!</span>")
			M.emote("scream")
		if(80 to INFINITY)
			Firestacks(M, A, unmitigated)
			M.IgniteMob()
			to_chat(M, "<span class='userdanger'>Your skin erupts into an inferno!</span>")
			M.emote("scream")
	return

/datum/symptom/fire/proc/Firestacks(mob/living/M, datum/disease/advance/A, unmitigated)
	var/get_stacks = unmitigated
	if(A.stage < 5)
		get_stacks *= ((A.progress / 100) ** 2) * max(sqrtor0(5 + A.totalStageSpeed() * 2), 1)
		M.adjustFireLoss(get_stacks * 2)
	else
		get_stacks *= ((A.progress / 100) ** 2) * max(sqrtor0(10 + A.totalStageSpeed() * 3), 1)
		M.adjustFireLoss(get_stacks * 4)

	M.adjust_fire_stacks(get_stacks)
	return 1

/datum/symptom/fire/proc/evaporate_wetness(datum/disease/advance/A, heat_mod)
	. = TRUE
	var/mob/living/carbon/target = A.affected_mob
	if(target.wetlevel < 3 * heat_mod)
		. = FALSE
	target.wetlevel = max(round(target.wetlevel - 3 * heat_mod), 0)
	if(target.wetlevel)
		to_chat(target, "<span class='userdanger'>Some water steams off your body</span>")
	else
		to_chat(target, "<span class='userdanger'>All of the water steams off your body!</span>")
