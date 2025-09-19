/client/proc/jump_to()
	set name = "Jump to..."
	set desc = "Area, Mob, Key or Coordinate"
	set category = "Admin"
	var/list/choices = list("Area", "Mob", "Key", "Coordinates")

	if(!check_rights(R_ADMIN))
		return

	var/chosen = input(src, null, "Jump to...") as null|anything in choices
	if(!chosen)
		return

	var/jumping // Thing to jump to
	switch(chosen)
		if("Area")
			jumping = input(src, "Area to jump to", "Jump to Area") as null|anything in return_sorted_areas()
			if(jumping)
				return jumptoarea(jumping)
		if("Mob")
			jumping = input(src, "Mob to jump to", "Jump to Mob") as null|anything in GLOB.mob_list
			if(jumping)
				return jumptomob(jumping)
		if("Key")
			jumping = input(src, "Key to jump to", "Jump to Key") as null|anything in sortKey(GLOB.clients)
			if(jumping)
				return jumptokey(jumping)
		if("Coordinates")
			var/x = input(src, "X Coordinate", "Jump to Coordinates") as null|num
			if(!x)
				return
			var/y = input(src, "Y Coordinate", "Jump to Coordinates") as null|num
			if(!y)
				return
			var/z = input(src, "Z Coordinate", "Jump to Coordinates") as null|num
			if(!z)
				return
			return jumptocoord(x, y, z)


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

/client/proc/jumptoturf(turf/T in world)
	set name = "\[Admin\] Jump to Turf"

	if(!check_rights(R_ADMIN))
		return

	if(isobj(usr.loc))
		var/obj/O = usr.loc
		O.force_eject_occupant(usr)
	log_admin("[key_name(usr)] jumped to [T.x], [T.y], [T.z] in [T.loc]")
	if(!isobserver(usr))
		message_admins("[key_name_admin(usr)] jumped to [T.x], [T.y], [T.z] in [T.loc]", 1)
	admin_forcemove(usr, T)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Turf") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

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

/client/proc/Getmob(mob/M in GLOB.mob_list)
	set name = "\[Admin\] Get Mob"
	set desc = "Mob to teleport"

	if(!check_rights(R_ADMIN))
		return

	log_admin("[key_name(usr)] teleported [key_name(M)]")
	message_admins("[key_name_admin(usr)] teleported [key_name_admin(M)]", 1)

	if(isobj(M.loc))
		var/obj/O = M.loc
		O.force_eject_occupant(M)
	admin_forcemove(M, get_turf(usr))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Get Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/Getkey()
	set name = "\[Admin\] Get Key"
	set desc = "Key to teleport"

	if(!check_rights(R_ADMIN))
		return

	var/list/keys = list()
	for(var/mob/M in GLOB.player_list)
		keys += M.client
	var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sortKey(keys)
	if(!selection)
		return
	var/mob/M = selection:mob

	if(!M)
		return
	log_admin("[key_name(usr)] teleported [key_name(M)]")
	message_admins("[key_name_admin(usr)] teleported [key_name(M)]", 1)
	if(M)
		if(isobj(M.loc))
			var/obj/O = M.loc
			O.force_eject_occupant(M)
		admin_forcemove(M, get_turf(usr))
		admin_forcemove(usr, M.loc)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Get Key") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/sendmob(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Send Mob"

	if(!check_rights(R_ADMIN))
		return

	var/area/A = input(usr, "Pick an area.", "Pick an area") as null|anything in return_sorted_areas()
	if(!A)
		return

	if(isobj(M.loc))
		var/obj/O = M.loc
		O.force_eject_occupant(M)
	admin_forcemove(M, pick(get_area_turfs(A)))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Send Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] teleported [key_name(M)] to [A]")
	message_admins("[key_name_admin(usr)] teleported [key_name_admin(M)] to [A]", 1)

/proc/admin_forcemove(mob/mover, atom/newloc)
	mover.forceMove(newloc)
	mover.on_forcemove(newloc)

/mob/proc/on_forcemove(atom/newloc)
	return
