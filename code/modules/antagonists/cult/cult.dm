#define SUMMON_POSSIBILITIES 3

/datum/antagonist/cult
	name = "Cultist"
	roundend_category = "cultists"
	var/datum/action/innate/cultcomm/communion = new
	job_rank = ROLE_CULTIST
	var/ignore_implant = FALSE
	var/give_equipment = FALSE

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
	if(. && !ignore_implant)
		. = is_convertable_to_cult(new_owner.current,cult_team)

/datum/antagonist/cult/greet()
	to_chat(owner, "<span class='cultitalic'>You catch a glimpse of the Realm of [ticker.cultdat.entity_name], [ticker.cultdat.entity_title3]. You now see how flimsy the world is, you see that it should be open to the knowledge of [ticker.cultdat.entity_name].</span>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/bloodcult.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	owner.announce_objectives()

/datum/antagonist/cult/on_gain()
	. = ..()
	add_objectives()
	if(give_equipment)
		equip_cultist(TRUE)
	ticker.mode.cult += owner // Only add after they've been given objectives
	ticker.mode.update_cult_icons_added(owner)



/datum/antagonist/cult/proc/equip_cultist()
	var/mob/living/carbon/human/mob = owner.current
	if(mob.mind)
		if(mob.mind.assigned_role == "Clown")
			to_chat(mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			mob.mutations.Remove(CLUMSY)

	var/obj/item/paper/talisman/supply/T = new(mob)
	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if(!where)
		to_chat(mob, "<span class='danger'>Unfortunately, you weren't able to get a talisman. This is very bad and you should adminhelp immediately.</span>")
	else
		to_chat(mob, "<span class='cult'>You have a talisman in your [where], one that will help you start the cult on this station. Use it well and remember - there are others.</span>")
		mob.update_icons()

/datum/antagonist/cult/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	current.faction |= "cult"
	communion.Grant(current)

/datum/antagonist/cult/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	current.faction -= "cult"
	communion.Remove(current)

/datum/antagonist/cult/on_removal()
	ticker.mode.cult -= owner
	ticker.mode.update_cult_icons_removed(owner)
	if(!silent)
		owner.current.visible_message("<FONT size = 3>[owner.current] looks like [owner.current.p_theyve()] just reverted to [owner.current.p_their()] old faith!</FONT>")
		to_chat(owner.current, "<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of the dark one and all your memories of it.</span>")
	. = ..()

/datum/team/cult
	name = "Cult"

/datum/team/cult/proc/setup_objectives()

	var/datum/objective/sacrifice/sac_objective = new
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