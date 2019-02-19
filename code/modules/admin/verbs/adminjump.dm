/client/proc/Jump(area/A in return_sorted_areas())
	set name = "Jump to Area"
	set desc = "Area to jump to"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	if(!A)
		return

	var/list/turfs = list()
	for(var/turf/T in A)
		if(T.density)
			continue
		if(locate(/obj/structure/grille, T)) // Quick check to not spawn in windows
			continue
		turfs.Add(T)

	var/turf/T = pick_n_take(turfs)
	if(!T)
		to_chat(src, "Nowhere to jump to!")
		return

	admin_forcemove(usr, T)
	log_admin("[key_name(usr)] jumped to [A]")
	if(!isobserver(usr))
		message_admins("[key_name_admin(usr)] jumped to [A]")
	feedback_add_details("admin_verb","JA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/jumptoturf(var/turf/T in world)
	set name = "Jump to Turf"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	log_admin("[key_name(usr)] jumped to [T.x], [T.y], [T.z] in [T.loc]")
	if(!isobserver(usr))
		message_admins("[key_name_admin(usr)] jumped to [T.x], [T.y], [T.z] in [T.loc]", 1)
	admin_forcemove(usr, T)
	feedback_add_details("admin_verb","JT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/jumptomob(var/mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Jump to Mob"

	if(!check_rights(R_ADMIN))
		return

	log_admin("[key_name(usr)] jumped to [key_name(M)]")
	if(!isobserver(usr))
		message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]", 1)
	if(src.mob)
		var/mob/A = src.mob
		var/turf/T = get_turf(M)
		if(T && isturf(T))
			feedback_add_details("admin_verb","JM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
			admin_forcemove(A, M.loc)
		else
			to_chat(A, "This mob is not located in the game world.")

/client/proc/jumptocoord(tx as num, ty as num, tz as num)
	set category = "Admin"
	set name = "Jump to Coordinate"

	if(!check_rights(R_ADMIN))
		return

	var/turf/T = locate(tx, ty, tz)
	if(T)
		admin_forcemove(usr, T)
		if(isobserver(usr))
			var/mob/dead/observer/O = usr
			O.ManualFollow(T)
		feedback_add_details("admin_verb","JC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	if(!isobserver(usr))
		message_admins("[key_name_admin(usr)] jumped to coordinates [tx], [ty], [tz]")

/client/proc/jumptokey()
	set category = "Admin"
	set name = "Jump to Key"

	if(!check_rights(R_ADMIN))
		return

	var/list/keys = list()
	for(var/mob/M in GLOB.player_list)
		keys += M.client
	var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sortKey(keys)
	if(!selection)
		to_chat(src, "No keys found.")
		return
	var/mob/M = selection:mob
	log_admin("[key_name(usr)] jumped to [key_name(M)]")
	if(!isobserver(usr))
		message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]", 1)

	admin_forcemove(usr, M.loc)

	feedback_add_details("admin_verb","JK") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/Getmob(var/mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Get Mob"
	set desc = "Mob to teleport"

	if(!check_rights(R_ADMIN))
		return

	log_admin("[key_name(usr)] teleported [key_name(M)]")
	message_admins("[key_name_admin(usr)] teleported [key_name_admin(M)]", 1)
	admin_forcemove(M, get_turf(usr))
	feedback_add_details("admin_verb","GM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/Getkey()
	set category = "Admin"
	set name = "Get Key"
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
		admin_forcemove(M, get_turf(usr))
		admin_forcemove(usr, M.loc)
		feedback_add_details("admin_verb","GK") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/sendmob(var/mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Send Mob"

	if(!check_rights(R_ADMIN))
		return

	var/area/A = input(usr, "Pick an area.", "Pick an area") in return_sorted_areas()
	if(A)
		admin_forcemove(M, pick(get_area_turfs(A)))
		feedback_add_details("admin_verb","SMOB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] teleported [key_name(M)] to [A]")
		message_admins("[key_name_admin(usr)] teleported [key_name_admin(M)] to [A]", 1)

/proc/admin_forcemove(mob/mover, atom/newloc)
	mover.forceMove(newloc)
	mover.on_forcemove(newloc)

/mob/proc/on_forcemove(atom/newloc)
	return
