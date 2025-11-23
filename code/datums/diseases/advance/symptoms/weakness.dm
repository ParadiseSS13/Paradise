/*
//////////////////////////////////////

Weakness

	Slightly noticeable.
	Lowers resistance slightly.
	Decreases stage speed moderately.
	Decreases transmittablity moderately.
	Moderate Level.

Bonus
	Deals stamina damage to the host

//////////////////////////////////////
*/

/datum/symptom/weakness

	name = "Weakness"
	stealth = -2
	resistance = 1
	stage_speed = -2
	transmissibility = -1
	level = 3
	severity = 4
	chem_treatments = list(
		"synaptizine" = list("multiplier" = 0, "timer" = 0),
		"ephedrine" = list("multiplier" = 0, "timer" = 0),
		"coffee" = list("multiplier" = 0.6, "timer" = 0),
		"tea" = list("multiplier" = 0.6, "timer" = 0))

/datum/symptom/weakness/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2)
			to_chat(M, SPAN_WARNING("[pick("You feel weak.", "You feel lazy.")]"))
		if(3, 4)
			to_chat(M, SPAN_WARNING("<b>[pick("You feel very frail.", "You think you might faint.")]"))
			M.adjustStaminaLoss(15 * unmitigated)
		else
			to_chat(M, SPAN_USERDANGER("[pick("You feel tremendously weak!", "Your body trembles as exhaustion creeps over you.")]"))
			M.adjustStaminaLoss(30 * unmitigated)
			if(M.getStaminaLoss() > 60 && !M.stat)
				M.visible_message(SPAN_WARNING("[M] faints!"), SPAN_USERDANGER("You swoon and faint..."))
				M.AdjustSleeping(10 SECONDS * unmitigated)
	return
