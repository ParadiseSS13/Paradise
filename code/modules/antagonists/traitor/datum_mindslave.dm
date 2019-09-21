
// For Mindslaves and Zealots
/datum/antagonist/mindslave
	name = "Mindslave"
	roundend_category = "mindslaves"
	job_rank = ROLE_MINDSLAVE
	var/special_role = ROLE_MINDSLAVE

/datum/antagonist/mindslave/on_gain()
	// Handling mindslave objectives on top of other antag objective sucks, so Im just gonna do it like this
	to_chat(owner.current, "<b>New Objective:</b> [objectives[objectives.len].explanation_text]")


/datum/antagonist/mindslave/on_removal()
	if(owner.som)
		var/datum/mindslaves/slaved = owner.som
		slaved.serv -= owner
		slaved.leave_serv_hud(owner)
	antag_memory = ""
	owner.special_role = null
	..()


/datum/antagonist/mindslave/apply_innate_effects()
	. = ..()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/slave_mob = owner.current
		if(slave_mob && istype(slave_mob))
			to_chat(slave_mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			slave_mob.mutations.Remove(CLUMSY)


/datum/antagonist/mindslave/remove_innate_effects()
	. = ..()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/slave_mob = owner.current
		if(slave_mob && istype(slave_mob))
			slave_mob.mutations.Add(CLUMSY)


/datum/antagonist/mindslave/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/mindslave/proc/remove_objective(datum/objective/O)
	objectives -= O
