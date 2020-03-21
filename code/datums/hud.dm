/* HUD DATUMS */
GLOBAL_LIST_EMPTY(all_huds)

///GLOBAL HUD LIST
GLOBAL_LIST_INIT(huds, list( \
	DATA_HUD_SECURITY_BASIC = new/datum/atom_hud/data/human/security/basic(), \
	DATA_HUD_SECURITY_ADVANCED = new/datum/atom_hud/data/human/security/advanced(), \
	DATA_HUD_MEDICAL_BASIC = new/datum/atom_hud/data/human/medical/basic(), \
	DATA_HUD_MEDICAL_ADVANCED = new/datum/atom_hud/data/human/medical/advanced(), \
	DATA_HUD_DIAGNOSTIC = new/datum/atom_hud/data/diagnostic(), \
	DATA_HUD_DIAGNOSTIC_ADVANCED = new/datum/atom_hud/data/diagnostic/advanced(), \
	DATA_HUD_HYDROPONIC = new/datum/atom_hud/data/hydroponic(), \
	ANTAG_HUD_CULT = new/datum/atom_hud/antag(), \
	ANTAG_HUD_REV = new/datum/atom_hud/antag(), \
	ANTAG_HUD_OPS = new/datum/atom_hud/antag(), \
	ANTAG_HUD_WIZ  = new/datum/atom_hud/antag(), \
	ANTAG_HUD_SHADOW  = new/datum/atom_hud/antag(), \
	ANTAG_HUD_TRAITOR = new/datum/atom_hud/antag/hidden(),\
	ANTAG_HUD_NINJA = new/datum/atom_hud/antag/hidden(),\
	ANTAG_HUD_CHANGELING = new/datum/atom_hud/antag/hidden(),\
	ANTAG_HUD_VAMPIRE = new/datum/atom_hud/antag/hidden(),\
	ANTAG_HUD_ABDUCTOR = new/datum/atom_hud/antag/hidden(),\
	DATA_HUD_ABDUCTOR = new/datum/atom_hud/abductor(),\
	ANTAG_HUD_DEVIL = new/datum/atom_hud/antag/hidden(),\
	ANTAG_HUD_EVENTMISC = new/datum/atom_hud/antag/hidden(),\
	ANTAG_HUD_BLOB = new/datum/atom_hud/antag/hidden()\
))

/datum/atom_hud
	var/list/atom/hudatoms = list() //list of all atoms which display this hud
	var/list/mob/hudusers = list() //list with all mobs who can see the hud
	var/list/hud_icons = list() //these will be the indexes for the atom's hud_list


/datum/atom_hud/New()
	GLOB.all_huds += src

/datum/atom_hud/Destroy()
	for(var/v in hudusers)
		remove_hud_from(v)
	for(var/v in hudatoms)
		remove_from_hud(v)
	GLOB.all_huds -= src
	return ..()

/datum/atom_hud/proc/remove_hud_from(mob/M)
	if(!M)
		return
	if(src in M.permanent_huds)
		return
	for(var/atom/A in hudatoms)
		remove_from_single_hud(M, A)
	hudusers -= M

/datum/atom_hud/proc/remove_from_hud(atom/A)
	if(!A)
		return
	for(var/mob/M in hudusers)
		remove_from_single_hud(M, A)
	hudatoms -= A

/datum/atom_hud/proc/remove_from_single_hud(mob/M, atom/A) //unsafe, no sanity apart from client
	if(!M || !M.client || !A)
		return
	for(var/i in hud_icons)
		M.client.images -= A.hud_list[i]

/datum/atom_hud/proc/add_hud_to(mob/M)
	if(!M)
		return
	hudusers |= M
	for(var/atom/A in hudatoms)
		add_to_single_hud(M, A)

/datum/atom_hud/proc/add_to_hud(atom/A)
	if(!A)
		return
	hudatoms |= A
	for(var/mob/M in hudusers)
		add_to_single_hud(M, A)

/datum/atom_hud/proc/add_to_single_hud(mob/M, atom/A) //unsafe, no sanity apart from client
	if(!M || !M.client || !A)
		return
	for(var/i in hud_icons)
		if(A.hud_list[i])
			M.client.images |= A.hud_list[i]

//MOB PROCS
/mob/proc/reload_huds()
	//var/gang_huds = list()
	//if(ticker.mode)
	//	for(var/datum/gang/G in ticker.mode.gangs)
	//		gang_huds += G.ganghud

	var/serv_huds = list()//mindslaves and/or vampire thralls
	if(SSticker.mode)
		for(var/datum/mindslaves/serv in (SSticker.mode.vampires | SSticker.mode.traitors))
			serv_huds += serv.thrallhud


	for(var/datum/atom_hud/hud in (GLOB.all_huds|serv_huds))//|gang_huds))
		if(src in hud.hudusers)
			hud.add_hud_to(src)

/mob/new_player/reload_huds()
	return

/mob/proc/add_click_catcher()
	client.screen += client.void

/mob/new_player/add_click_catcher()
	return
