/datum/atom_hud/antag
	hud_icons = list(SPECIALROLE_HUD)
	var/self_visible = TRUE
	var/key

/datum/atom_hud/antag/hidden
	self_visible = FALSE

/datum/atom_hud/antag/New(_key)
	. = ..()
	key = "[_key]"

/datum/atom_hud/antag/proc/join_hud(mob/M)
	//sees_hud should be set to 0 if the mob does not get to see it's own hud type.
	if(!istype(M))
		CRASH("join_hud(): [M] ([M.type]) is not a mob!")
	add_to_hud(M)
	if(self_visible)
		add_hud_to(M)
	M.mind.antag_hud.antag_huds |= src

/datum/atom_hud/antag/proc/leave_hud(mob/M)
	if(!M)
		return
	if(!istype(M))
		CRASH("leave_hud(): [M] ([M.type]) is not a mob!")
	remove_from_hud(M)
	remove_hud_from(M)
	M.mind.antag_hud.antag_huds -= src

/datum/atom_hud/antag/add_to_single_hud(mob/M, atom/A) //unsafe, no sanity apart from client
	if(!M || !M.client || !A)
		return
	if(A.invisibility > M.see_invisible) // yee yee ass snowflake check for our yee yee ass snowflake huds
		return
	if(A.hud_list[SPECIALROLE_HUD] && A.hud_list[SPECIALROLE_HUD][key])
		M.client.images |= A.hud_list[SPECIALROLE_HUD][key] // had to be copied to include `key`

/datum/atom_hud/antag/remove_from_single_hud(mob/M, atom/A) //unsafe, no sanity apart from client
	if(!M || !M.client || !A)
		return
	M.client.images -= A.hud_list[SPECIALROLE_HUD][key] // had to be copied to include `key`

/datum/mind/proc/add_antag_hud(mob/M, hud_index, new_icon_state)
	if(!antag_hud)
		antag_hud = new(src)
	var/datum/atom_hud/antag/hud = hud_index
	if(!istype(hud, /datum/atom_hud/antag)) // I hate this but its required for mindslaves. Don't use this outside of mindslaves, always pass in the index.
		hud = GLOB.huds[hud_index]
	antag_hud.add_antag_hud(M, hud, new_icon_state)
	hud.join_hud(M)

/datum/mind/proc/remove_antag_hud(mob/M, hud_index, new_icon_state)
	var/datum/atom_hud/antag/hud = GLOB.huds[hud_index]
	antag_hud.remove_antag_hud(M, hud, new_icon_state)
	hud.leave_hud(M)
	if(!antag_hud.is_active())
		qdel(antag_hud)

/datum/mind/proc/leave_all_huds()
	for(var/datum/atom_hud/antag/hud in GLOB.huds)
		if(current in hud.hudusers)
			hud.leave_hud(current)

	for(var/datum/atom_hud/data/hud in GLOB.huds)
		if(current in hud.hudusers)
			hud.remove_hud_from(current)


/datum/mindslaves
	var/name = "ERROR"
	var/list/datum/mind/masters = list()
	var/list/datum/mind/serv = list()
	var/datum/atom_hud/antag/thrallhud
	var/master_icon_state = "hudmaster"

/datum/mindslaves/New()
	..()
	thrallhud = new(src.UID())

/datum/mindslaves/Destroy(force, ...)
	qdel(thrallhud)
	return ..()

/datum/mindslaves/proc/add_master(datum/mind/_mind)
	if(_mind.mindslave_master)
		return FALSE
	masters |= _mind
	_mind.mindslave_master = src
	_mind.add_antag_hud(_mind.current, thrallhud, master_icon_state)
	return TRUE

/datum/mindslaves/proc/remove_master(datum/mind/_mind)
	if(_mind.mindslave_master != src)
		return FALSE
	masters -= _mind
	_mind.mindslave_master = null
	_mind.remove_antag_hud(_mind.current, thrallhud, master_icon_state)
	return TRUE


/datum/mindslaves/proc/add_servant(datum/mind/_mind, icon_state)
	if(_mind.mindslave_slave)
		return FALSE
	serv[_mind] = icon_state
	_mind.mindslave_slave = src
	_mind.add_antag_hud(_mind.current, thrallhud, icon_state)
	return TRUE

/datum/mindslaves/proc/remove_servant(datum/mind/_mind)
	if(_mind.mindslave_slave != src)
		return FALSE
	_mind.remove_antag_hud(_mind.current, thrallhud, serv[_mind])
	serv -= _mind
	_mind.mindslave_slave = null
	return TRUE


#define ANTAG_HUD_HEIGHT_OFFSET -8

/datum/antag_hud_helper
	var/list/team_icon_states = list()
	var/list/solo_icon_states = list()
	var/list/icon_state_to_image = list()
	var/list/datum/atom_hud/antag/antag_huds = list()
	var/datum/mind/our_mind

/datum/antag_hud_helper/New(datum/mind/mind)
	. = ..()
	our_mind = mind

/datum/antag_hud_helper/proc/add_antag_hud(mob/M, datum/atom_hud/antag/hud, new_icon_state)
	if(!istype(M))
		CRASH("add_antag_hud(): [M] ([M.type]) is not a mob!")
	if(hud.self_visible)
		team_icon_states |= new_icon_state
	else
		solo_icon_states |= new_icon_state

	var/image/I = image('icons/mob/hud/antaghud.dmi', M, new_icon_state)
	I.appearance_flags = RESET_COLOR | RESET_TRANSFORM

	M.hud_list[SPECIALROLE_HUD][hud.key] = I
	icon_state_to_image[new_icon_state] = I
	recalculate_images()

/datum/antag_hud_helper/proc/remove_antag_hud(mob/M, datum/atom_hud/antag/hud, old_icon_state)
	if(!istype(M))
		CRASH("add_antag_hud(): [M] ([M.type]) is not a mob!")

	M.hud_list[SPECIALROLE_HUD] -= hud.key
	icon_state_to_image -= old_icon_state
	team_icon_states -= old_icon_state
	solo_icon_states -= old_icon_state
	if(!length(solo_icon_states))
		return
	recalculate_images()

/datum/antag_hud_helper/proc/transfer_antag_huds(mob/old_mob, mob/new_mob)
	if(!istype(old_mob))
		CRASH("transfer_antag_huds()'s old_mob: [old_mob] ([old_mob.type]) is not a mob!")
	if(!istype(new_mob))
		CRASH("transfer_antag_huds()'s new_mob: [new_mob] ([new_mob.type]) is not a mob!")
	new_mob.hud_list[SPECIALROLE_HUD] = old_mob.hud_list[SPECIALROLE_HUD]
	old_mob.hud_list[SPECIALROLE_HUD] = list()
	var/list/temp_huds = antag_huds.Copy()
	our_mind.leave_all_huds()
	for(var/key as anything in new_mob.hud_list[SPECIALROLE_HUD])
		var/image/I = new_mob.hud_list[SPECIALROLE_HUD][key]
		I.loc = new_mob
	for(var/datum/atom_hud/antag/swaphud in temp_huds)
		swaphud.join_hud(new_mob)

/datum/antag_hud_helper/proc/recalculate_images()
	var/next_y = length(team_icon_states) ? ANTAG_HUD_HEIGHT_OFFSET : 0
	for(var/icon_state in solo_icon_states)
		var/image/I = icon_state_to_image[icon_state]
		I.pixel_y = next_y
		next_y += ANTAG_HUD_HEIGHT_OFFSET

/datum/antag_hud_helper/proc/is_active()
	return length(solo_icon_states) || length(team_icon_states)

#undef ANTAG_HUD_HEIGHT_OFFSET
