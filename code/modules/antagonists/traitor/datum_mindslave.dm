
// For Mindslaves and Zealots
/datum/antagonist/mindslave
	name = "Mindslave"
	roundend_category = "mindslaves"
	job_rank = SPECIAL_ROLE_TRAITOR
	var/special_role = SPECIAL_ROLE_TRAITOR

/datum/antagonist/mindslave/on_gain()
	owner.special_role = special_role
	// Will print the most recent objective which is probably going the mindslave objective
	to_chat(owner.current, "<b>New Objective:</b> [owner.objectives[owner.objectives.len].explanation_text]")
	update_mindslave_icons_added()

/datum/antagonist/mindslave/on_removal()
	if(owner.som)
		var/datum/mindslaves/slaved = owner.som
		slaved.serv -= owner
		slaved.leave_serv_hud(owner)
	antag_memory = ""
	owner.special_role = null
	update_mindslave_icons_removed()
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
	owner.objectives += O

/datum/antagonist/mindslave/proc/remove_objective(datum/objective/O)
	owner.objectives -= O

/datum/antagonist/mindslave/proc/update_mindslave_icons_added()
	var/datum/atom_hud/antag/traitorhud = huds[ANTAG_HUD_TRAITOR]
	traitorhud.join_hud(owner.current, null)
	set_antag_hud(owner.current, "hudmindslave")

/datum/antagonist/mindslave/proc/update_mindslave_icons_removed()
	var/datum/atom_hud/antag/traitorhud = huds[ANTAG_HUD_TRAITOR]
	traitorhud.leave_hud(owner.current, null)
