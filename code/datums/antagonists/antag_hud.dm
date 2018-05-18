/datum/atom_hud/antag
	hud_icons = list(SPECIALROLE_HUD,NATIONS_HUD)
	var/self_visible = TRUE

/datum/atom_hud/antag/hidden
	self_visible = FALSE

/datum/atom_hud/antag/proc/join_hud(mob/M, slave)
	//sees_hud should be set to 0 if the mob does not get to see it's own hud type.
	if(!istype(M))
		CRASH("join_hud(): [M] ([M.type]) is not a mob!")
	if(M.mind.antag_hud && !slave) //note: please let this runtime if a mob has no mind, as mindless mobs shouldn't be getting antagged
		M.mind.antag_hud.leave_hud(M)
	add_to_hud(M)
	if(self_visible)
		add_hud_to(M)
	M.mind.antag_hud = src

/datum/atom_hud/antag/proc/leave_hud(mob/M)
	if(!M)
		return
	if(!istype(M))
		CRASH("leave_hud(): [M] ([M.type]) is not a mob!")
	remove_from_hud(M)
	remove_hud_from(M)
	if(M.mind)
		M.mind.antag_hud = null


//GAME_MODE PROCS
//called to set a mob's antag icon state
/proc/set_antag_hud(mob/M, new_icon_state)
	if(!istype(M))
		CRASH("set_antag_hud(): [M] ([M.type]) is not a mob!")
	var/image/holder = M.hud_list[SPECIALROLE_HUD]
	if(holder)
		holder.icon_state = new_icon_state
	if(M.mind || new_icon_state) //in mindless mobs, only null is acceptable, otherwise we're antagging a mindless mob, meaning we should runtime
		M.mind.antag_hud_icon_state = new_icon_state

//Nations Icons
/proc/set_nations_hud(mob/M, new_icon_state)
	if(!istype(M))
		CRASH("set_antag_hud(): [M] ([M.type]) is not a mob!")
	var/image/holder = M.hud_list[NATIONS_HUD]
	if(holder)
		holder.icon_state = new_icon_state
	if(M.mind || new_icon_state) //in mindless mobs, only null is acceptable, otherwise we're antagging a mindless mob, meaning we should runtime
		M.mind.antag_hud_icon_state = new_icon_state

//MIND PROCS
//these are called by mind.transfer_to()
/datum/mind/proc/transfer_antag_huds(datum/atom_hud/antag/newhud)
	leave_all_huds()
	set_antag_hud(current, antag_hud_icon_state)
	if(newhud)
		newhud.join_hud(current)

/datum/mind/proc/leave_all_huds()
	for(var/datum/atom_hud/antag/hud in huds)
		if(current in hud.hudusers)
			hud.leave_hud(current)

	for(var/datum/atom_hud/data/hud in huds)
		if(current in hud.hudusers)
			hud.remove_hud_from(current)


///Master Servent Datum Sytems,Based on TG Gang system//

/datum/mindslaves
	var/name = "ERROR"
	var/list/datum/mind/masters = list()
	var/list/datum/mind/serv = list()
	var/datum/atom_hud/antag/thrallhud
	var/icontype

/datum/mindslaves/New(loc,mastername)

	name = mastername
	thrallhud = new()

/datum/mindslaves/proc/add_serv_hud(datum/mind/serv_mind, icon)
	thrallhud.join_hud(serv_mind.current, 1)
	icontype = "hud[icon]"
	set_antag_hud(serv_mind.current, icontype)

/datum/mindslaves/proc/leave_serv_hud(datum/mind/free_mind)
	thrallhud.leave_hud(free_mind.current)
	set_antag_hud(free_mind.current, null)