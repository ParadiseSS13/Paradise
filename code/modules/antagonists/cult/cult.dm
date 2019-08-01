/datum/antagonist/cult
	name = "Cult"
	roundend_category = "cultists"
	job_rank = ROLE_CULTIST
	var/datum/action/innate/cultcomm/communion = new()
	var/talisman = FALSE // to give starting cultists supply talismans
	var/datum/team/cult/cult_team

/datum/antagonist/cult/get_team()
	return cult_team

/datum/antagonist/cult/create_team(datum/team/cult/new_team)
	if(!new_team)
		for(var/datum/antagonist/cult/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.cult_team)
				cult_team = H.cult_team
				return
		cult_team = new /datum/team/cult
		cult_team.setup_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	cult_team = new_team

/datum/antagonist/cult/proc/add_objectives()
	objectives |= cult_team.objectives
	owner.objectives |= objectives

/datum/antagonist/cult/Destroy()
	QDEL_NULL(communion)
	return ..()

/datum/antagonist/cult/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		. = is_convertable_to_cult(new_owner.current)

/datum/antagonist/cult/greet()
	to_chat(owner.current, "<span class='cultitalic'>You catch a glimpse of the Realm of [SSticker.cultdat.entity_name], [SSticker.cultdat.entity_title3]. You now see how flimsy the world is, you see that it should be open to the knowledge of [SSticker.cultdat.entity_name].</span>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/bloodcult.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	owner.announce_objectives()

/datum/antagonist/cult/proc/equip_cultist()
	if(!istype(owner))
		return

	if(owner)
		if(owner.assigned_role == "Clown")
			to_chat(owner.current, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			owner.current.mutations.Remove(CLUMSY)
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(owner)
	if(talisman)
		var/obj/item/paper/talisman/supply/T = new(owner.current)
		var/list/slots = list (
			"backpack" = slot_in_backpack,
			"left pocket" = slot_l_store,
			"right pocket" = slot_r_store,
			"left hand" = slot_l_hand,
			"right hand" = slot_r_hand,
		)
		var/where = owner.current.equip_in_one_of_slots(T, slots)
		if(!where)
			to_chat(owner.current, "<span class='danger'>Unfortunately, you weren't able to get a talisman. This is very bad and you should adminhelp immediately.</span>")
		else
			to_chat(owner.current, "<span class='cult'>You have a talisman in your [where], one that will help you start the cult on this station. Use it well and remember - there are others.</span>")
			owner.current.update_icons()
			return 1

/datum/antagonist/cult/on_gain()
	. = ..()
	if(SSticker && SSticker.mode && owner)
		add_objectives()
		SSticker.mode.cult += owner
		SSticker.mode.update_cult_icons_added(owner)
		if(jobban_isbanned(owner.current, ROLE_CULTIST))
			addtimer(SSticker.mode, "replace_jobbaned_player", 0, FALSE, owner, ROLE_CULTIST, ROLE_CULTIST)
	equip_cultist(owner)
	owner.current.create_attack_log("<span class='cult'>Has been converted to the cult of Nar'Sie!</span>")

/datum/antagonist/cult/apply_innate_effects()
	. = ..()
	owner.current.faction += "cult"
	communion.Grant(owner.current)

/datum/antagonist/cult/remove_innate_effects()
	. = ..()
	owner.current.faction -= "cult"

/datum/antagonist/cult/on_removal()
	if(SSticker && SSticker.mode && owner)
		SSticker.mode.cult -= owner
		SSticker.mode.update_cult_icons_removed(owner)
		owner.special_role = null
	owner << "<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of the Dark One and all your memories as its servant.</span>"
	owner.current.create_attack_log("<span class='cult'>Has renounced the cult of Nar'Sie!</span>")
	owner.current.visible_message("<span class='big'>[owner] looks like they just reverted to their old faith!</span>")
	. = ..()

/datum/team/cult
	name = "Cult"

/datum/team/cult/proc/setup_objectives()
	var/living_crew = 0

	for(var/mob/living/L in GLOB.player_list)
		if(L.stat != DEAD)
			if(ishuman(L))
				living_crew++

	if(prob(20) && living_crew >= 15)
		var/datum/objective/convert/bookclub_objective = new()
		bookclub_objective.team = src
		objectives += bookclub_objective
	else if(prob(20) && GAMEMODE_IS_CULT)
		var/datum/objective/bloodspill/blood_objective = new()
		blood_objective.team = src
		objectives += blood_objective

	var/datum/objective/sacrifice/sac_objective = new()
	sac_objective.team = src
	objectives += sac_objective

	if(prob(40))
		var/datum/objective/eldergod/summon_objective = new()
		summon_objective.team = src
		objectives += summon_objective
	else
		var/datum/objective/demon/demon_objective = new()
		demon_objective.team = src
		objectives += demon_objective


/datum/team/cult/proc/check_cult_victory()
	for(var/datum/objective/O in objectives)
		if(!O.check_completion())
			return FALSE
	return TRUE 