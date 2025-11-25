// Objective info, Based on Reverent mini Atang
/datum/objective/slaughter
	needs_target = FALSE
	var/targetKill = 10

/datum/objective/slaughter/New()
	targetKill = rand(10,20)
	explanation_text = "Devour [targetKill] mortals."
	..()

/datum/objective/slaughter/check_completion()
	var/kill_count = 0
	for(var/datum/mind/M in get_owners())
		if(!isslaughterdemon(M.current) || QDELETED(M.current))
			continue
		var/mob/living/basic/demon/slaughter/R = M.current
		kill_count += R.devoured
	if(kill_count >= targetKill)
		return TRUE
	return FALSE

/datum/objective/demon_fluff
	name = "Spread blood"
	needs_target = FALSE

/datum/objective/demon_fluff/New()
	find_target()
	var/targetname = "someone"
	if(target && target.current)
		targetname = target.current.real_name
	var/list/explanation_texts = list(
		"Spread blood all over the bridge.",
		"Spread blood all over the brig.",
		"Spread blood all over the chapel.",
		"Kill or Destroy all Janitors or Sanitation bots.",
		"Spare a few after striking them... make them bleed before the harvest.",
		"Hunt those that try to hunt you first.",
		"Hunt those that run away from you in fear",
		"Show [targetname] the power of blood.",
		"Drive [targetname] insane with demonic whispering."
	)
	// As this is a fluff objective, we don't need a target, so we want to null it out.
	// We don't want the demon getting a "Time for Plan B" message if the target cryos.
	target = null
	explanation_text = pick(explanation_texts)
	..()

/datum/objective/demon_fluff/check_completion()
	return TRUE

/datum/objective/cult_slaughter
	explanation_text = "Bring forth the Slaughter to the nonbelievers."
	needs_target = FALSE

/datum/objective/pulse_demon/infest
	name = "Hijack APCs"
	/// Amount of APCs we need to hijack, can be 15, 20, or 25
	var/amount = 0

/datum/objective/pulse_demon/infest/New()
	. = ..()
	amount = rand(3, 5) * 5
	explanation_text = "Hijack [amount] APCs."

/datum/objective/pulse_demon/infest/check_completion()
	if(..())
		return TRUE
	var/hijacked = 0
	for(var/datum/mind/M in get_owners())
		if(!ispulsedemon(M.current) || QDELETED(M.current))
			continue
		var/mob/living/basic/demon/pulse_demon/demon = M.current
		hijacked += length(demon.hijacked_apcs)
	return hijacked >= amount

/datum/objective/pulse_demon/drain
	name = "Drain Power"
	/// Amount of power we need to drain, ranges from 500 KW to 5 MW
	var/amount = 0

/datum/objective/pulse_demon/drain/New()
	. = ..()
	amount = rand(1, 10) * 500000
	explanation_text = "Drain [format_si_suffix(amount)]W of power."

/datum/objective/pulse_demon/drain/check_completion()
	if(..())
		return TRUE
	var/drained = 0
	for(var/datum/mind/M in get_owners())
		if(!ispulsedemon(M.current) || QDELETED(M.current))
			continue
		var/mob/living/basic/demon/pulse_demon/demon = M.current
		drained += demon.charge_drained
	return drained >= amount

// Requires 1 APC to be hacked and not destroyed to complete
/datum/objective/pulse_demon/tamper
	name = "Tamper Machinery"
	explanation_text = "Cause mischief amongst the machines in rooms with APCs you've hijacked, and defend yourself from anyone trying to stop you."

/datum/objective/pulse_demon/tamper/check_completion()
	if(..())
		return TRUE
	for(var/datum/mind/M in get_owners())
		if(!ispulsedemon(M.current) || QDELETED(M.current))
			continue
		var/mob/living/basic/demon/pulse_demon/demon = M.current
		if(!length(demon.hijacked_apcs) || !M.active || demon.stat == DEAD)
			return FALSE
	return TRUE
