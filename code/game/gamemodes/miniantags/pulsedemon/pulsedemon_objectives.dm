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
		var/mob/living/simple_animal/demon/pulse_demon/demon = M.current
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
		var/mob/living/simple_animal/demon/pulse_demon/demon = M.current
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
		var/mob/living/simple_animal/demon/pulse_demon/demon = M.current
		if(!length(demon.hijacked_apcs) || !M.active || demon.stat == DEAD)
			return FALSE
	return TRUE
