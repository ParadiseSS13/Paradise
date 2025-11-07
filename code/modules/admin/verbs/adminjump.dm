USER_VERB(jump_to, R_ADMIN, "Jump to...", "Area, Mob, Key or Coordinate", VERB_CATEGORY_ADMIN)
	var/list/choices = list("Area", "Mob", "Key", "Coordinates")

	var/chosen = input(client, null, "Jump to...") as null|anything in choices
	if(!chosen)
		return

	var/jumping // Thing to jump to
	switch(chosen)
		if("Area")
			jumping = input(client, "Area to jump to", "Jump to Area") as null|anything in return_sorted_areas()
			if(jumping)
				return client.jumptoarea(jumping)
		if("Mob")
			jumping = input(client, "Mob to jump to", "Jump to Mob") as null|anything in GLOB.mob_list
			if(jumping)
				return client.jumptomob(jumping)
		if("Key")
			jumping = input(client, "Key to jump to", "Jump to Key") as null|anything in sortKey(GLOB.clients)
			if(jumping)
				return client.jumptokey(jumping)
		if("Coordinates")
			var/x = input(client, "X Coordinate", "Jump to Coordinates") as null|num
			if(!x)
				return
			var/y = input(client, "Y Coordinate", "Jump to Coordinates") as null|num
			if(!y)
				return
			var/z = input(client, "Z Coordinate", "Jump to Coordinates") as null|num
			if(!z)
				return
			return client.jumptocoord(x, y, z)

/client/proc/jumptoarea(area/A)
	if(!A || !check_rights(R_ADMIN))
		return

	var/list/turfs = list()
	for(var/turf/T in A)
		if(T.density)
			continue
		if(locate(/obj/structure/grille) in T) // Quick check to not spawn in windows
			continue
		turfs += T

	var/turf/T = safepick(turfs)
	if(!T)
		to_chat(src, "Nowhere to jump to!")
		return

	if(isobj(usr.loc))
		var/obj/O = usr.loc
		O.force_eject_occupant(usr)

	admin_forcemove(usr, T)
	log_admin("[key_name(usr)] jumped to [A]")
	if(!isobserver(usr))
		message_admins("[key_name_admin(usr)] jumped to [A]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Area") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_CONTEXT_MENU(jump_to_turf, R_ADMIN, "\[Admin\] Jump to Turf", turf/T in world)
	if(isobj(client.mob.loc))
		var/obj/O = client.mob.loc
		O.force_eject_occupant(client.mob)
	log_admin("[key_name(client)] jumped to [T.x], [T.y], [T.z] in [T.loc]")
	if(!isobserver(client.mob))
		message_admins("[key_name_admin(client.mob)] jumped to [T.x], [T.y], [T.z] in [T.loc]", 1)
	admin_forcemove(client.mob, T)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Turf") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/jumptomob(mob/M)
	set name = "Jump to Mob"
	if(!M || !check_rights(R_ADMIN))
		return

	log_admin("[key_name(usr)] jumped to [key_name(M)]")
	if(!isobserver(usr))
		message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]", 1)
	if(isobj(usr.loc))
		var/obj/O = usr.loc
		O.force_eject_occupant(usr)
	if(src.mob)
		var/mob/A = src.mob
		var/turf/T = get_turf(M)
		if(T && isturf(T))
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
			admin_forcemove(A, M.loc)
		else
			to_chat(A, "This mob is not located in the game world.")

/client/proc/jumptocoord(tx as num, ty as num, tz as num)
	if(!isobserver(usr) && !check_rights(R_ADMIN)) // Only admins can jump without being a ghost
		return

	var/turf/T = locate(tx, ty, tz)
	if(T)
		if(isobj(usr.loc))
			var/obj/O = usr.loc
			O.force_eject_occupant(usr)
		admin_forcemove(usr, T)
		if(isobserver(usr))
			var/mob/dead/observer/O = usr
			O.manual_follow(T)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Coordinate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	if(!isobserver(usr))
		message_admins("[key_name_admin(usr)] jumped to coordinates [tx], [ty], [tz]")

/client/proc/jumptokey(client/C)
	if(!C?.mob || !check_rights(R_ADMIN))
		return
	var/mob/M = C.mob
	log_admin("[key_name(usr)] jumped to [key_name(M)]")
	if(!isobserver(usr))
		message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]", 1)
	if(isobj(usr.loc))
		var/obj/O = usr.loc
		O.force_eject_occupant(usr)
	admin_forcemove(usr, M.loc)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Key") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB_AND_CONTEXT_MENU(teleport_mob, R_ADMIN, "Teleport Mob", "Teleport a mob to your location.", VERB_CATEGORY_ADMIN, mob/M in GLOB.mob_list)
	if(!istype(M))
		return

	if(isobj(M.loc))
		var/obj/O = M.loc
		O.force_eject_occupant(M)
	admin_forcemove(M, get_turf(client.mob))
	log_admin("[key_name(client)] teleported [key_name(M)]")
	message_admins("[key_name_admin(client)] teleported [key_name_admin(M)]", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Get Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB_AND_CONTEXT_MENU(teleport_ckey, R_ADMIN, "Teleport Client", "Teleport a mob to your location by client.", VERB_CATEGORY_ADMIN)
	var/list/keys = list()
	for(var/mob/M in GLOB.player_list)
		keys += M.client
	var/selection = input(client, "Please, select a player!", "Admin Jumping", null) as null|anything in sortKey(keys)
	if(!selection)
		return
	var/mob/M = selection:mob

	if(!M)
		return
	log_admin("[key_name(client.mob)] teleported [key_name(M)]")
	message_admins("[key_name_admin(client.mob)] teleported [key_name(M)]", 1)
	if(M)
		if(isobj(M.loc))
			var/obj/O = M.loc
			O.force_eject_occupant(M)
		admin_forcemove(M, get_turf(client.mob))
		admin_forcemove(client.mob, M.loc)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Get Key") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(send_mob, R_ADMIN, "Send Mob", "Send mob to an area.", VERB_CATEGORY_ADMIN, mob/M in GLOB.mob_list)
	var/area/A = input(client, "Pick an area.", "Pick an area") as null|anything in return_sorted_areas()
	if(!A)
		return

	if(isobj(M.loc))
		var/obj/O = M.loc
		O.force_eject_occupant(M)
	admin_forcemove(M, pick(get_area_turfs(A)))
	log_admin("[key_name(client)] teleported [key_name(M)] to [A]")
	message_admins("[key_name_admin(client)] teleported [key_name_admin(M)] to [A]", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Send Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/admin_forcemove(mob/mover, atom/newloc)
	mover.forceMove(newloc)
	mover.on_forcemove(newloc)

/mob/proc/on_forcemove(atom/newloc)
	return
