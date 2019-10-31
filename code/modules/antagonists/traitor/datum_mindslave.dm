
// For Mindslaves and Zealots
/datum/antagonist/mindslave
	name = "Mindslave"
	roundend_category = "mindslaves"
	job_rank = ROLE_MINDSLAVE
	var/special_role = ROLE_MINDSLAVE

/datum/antagonist/mindslave/on_gain()
	owner.special_role = special_role
	// Will print the most recent objective which is probably going to be the mindslave objective
	to_chat(owner.current, "<b>New Objective:</b> [owner.objectives[owner.objectives.len].explanation_text]")
	update_mindslave_icons_added()

/datum/antagonist/mindslave/on_removal()
	SSticker.mode.implanted.Remove(owner.current)
	if(owner.som)
		var/datum/mindslaves/slaved = owner.som
		slaved.serv -= owner
		slaved.leave_serv_hud(owner)
	if(LAZYLEN(owner.antag_datums) > 1) // If it was an antag who was mindslaved, they'll have more than 1 antag datum. We don't want this to be null
		owner.special_role = owner.antag_datums[1].special_role // Set their special role to the role it was before they got mindslaved
	else
		owner.special_role = null
	for(var/objective in owner.objectives) // Remove their mindslave objective while keeping others intact
		if(istype(objective, /datum/objective/protect/mindslave))
			remove_objective(objective)
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
