/obj/effect/proc_holder/spell/area_teleport
	nonabstract_req = 1

	var/randomise_selection = 0 //if it lets the usr choose the teleport loc or picks it from the list
	var/invocation_area = 1 //if the invocation appends the selected area

	var/sound1 = 'sound/weapons/zapbang.ogg'
	var/sound2 = 'sound/weapons/zapbang.ogg'
	var/area/selected_area

/obj/effect/proc_holder/spell/area_teleport/before_cast(list/targets, mob/user)
	..()
	selected_area = null // Reset it
	var/A

	if(!randomise_selection)
		A = input("Area to teleport to", "Teleport", A) as null|anything in SSmapping.teleportlocs
	else
		A = pick(SSmapping.teleportlocs)

	if(!A)
		return

	var/area/thearea = SSmapping.teleportlocs[A]

	if(thearea.tele_proof && !istype(thearea, /area/wizard_station))
		to_chat(user, "A mysterious force disrupts your arcane spell matrix, and you remain where you are.")
		return

	selected_area = thearea

/obj/effect/proc_holder/spell/area_teleport/cast(list/targets, mob/living/user)
	if(!selected_area)
		revert_cast(user)
		return

	playsound(get_turf(user), sound1, 50,1)
	for(var/mob/living/target in targets)
		var/list/L = list()
		for(var/turf/T in get_area_turfs(selected_area.type))
			if(!T.density)
				var/clear = 1
				for(var/obj/O in T)
					if(O.density)
						clear = 0
						break
				if(clear)
					L+=T

		if(!L.len)
			to_chat(usr, "The spell matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry.")
			return

		if(target && target.buckled)
			target.buckled.unbuckle_mob(target, force = TRUE)

		if(target && target.has_buckled_mobs())
			target.unbuckle_all_mobs(force = TRUE)

		var/list/tempL = L
		var/attempt = null
		var/success = 0
		while(tempL.len)
			attempt = pick(tempL)
			success = target.Move(attempt)
			if(!success)
				tempL.Remove(attempt)
			else
				break

		if(!success)
			target.forceMove(pick(L))
			playsound(get_turf(user), sound2, 50,1)

		user.update_action_buttons_icon()  //Update action buttons as some spells might now be castable

	return

/obj/effect/proc_holder/spell/area_teleport/invocation(mob/user)
	if(!invocation_area || !selected_area)
		..()
	else
		switch(invocation_type)
			if("shout")
				user.say("[invocation] [uppertext(selected_area.name)]")
				if(user.gender==MALE)
					playsound(user.loc, pick('sound/misc/null.ogg','sound/misc/null.ogg'), 100, 1)
				else
					playsound(user.loc, pick('sound/misc/null.ogg','sound/misc/null.ogg'), 100, 1)
			if("whisper")
				user.whisper("[invocation] [uppertext(selected_area.name)]")

