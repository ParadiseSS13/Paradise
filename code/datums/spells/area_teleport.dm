/obj/effect/proc_holder/spell/area_teleport
	name = "Area teleport"
	desc = "This spell teleports you to a type of area of your selection."
	nonabstract_req = TRUE

	/// If it lets the usr choose the teleport loc or picks it from the list.
	var/randomise_selection = FALSE
	/// If the invocation appends the selected area.
	var/invocation_area = TRUE
	/// Sound played on teleportation start turf.
	var/sound_in = 'sound/weapons/zapbang.ogg'
	/// Sound played on destination turf.
	var/sound_out = 'sound/weapons/zapbang.ogg'
	/// Currently selected area.
	var/area/selected_area


/obj/effect/proc_holder/spell/area_teleport/before_cast(list/targets, mob/user)
	..()
	selected_area = null // Reset it
	var/A

	if(!randomise_selection)
		A = input("Area to teleport to", "Teleport", A) as null|anything in GLOB.teleportlocs
	else
		A = pick(GLOB.teleportlocs)

	if(!A)
		smoke_type = SMOKE_NONE
		return

	var/area/thearea = GLOB.teleportlocs[A]

	if(thearea.tele_proof && !istype(thearea, /area/wizard_station))
		to_chat(user, "A mysterious force disrupts your arcane spell matrix, and you remain where you are.")
		return

	selected_area = thearea



/obj/effect/proc_holder/spell/area_teleport/cast(list/targets, mob/living/user)
	if(!selected_area)
		revert_cast(user)
		return

	smoke_type = SMOKE_HARMLESS
	playsound(get_turf(user), sound_in, 50, TRUE)
	for(var/mob/living/target in targets)
		var/list/area_turfs = list()
		for(var/turf/area_turf in get_area_turfs(selected_area.type))
			if(!area_turf.density)
				var/clear = TRUE
				for(var/obj/object in area_turf)
					if(object.density)
						clear = FALSE
						break

				if(clear)
					area_turfs += area_turf

		if(!length(area_turfs))
			to_chat(user, "The spell matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry.")
			return

		if(target?.buckled)
			target.buckled.unbuckle_mob(target, force = TRUE)

		if(target?.has_buckled_mobs())
			target.unbuckle_all_mobs(force = TRUE)

		var/list/area_turfs_temp = area_turfs
		var/attempt = null
		var/success = FALSE
		while(length(area_turfs_temp))
			attempt = pick(area_turfs_temp)
			success = target.Move(attempt)
			if(!success)
				area_turfs_temp.Remove(attempt)
			else
				break

		if(!success)
			target.forceMove(pick(area_turfs))
			playsound(get_turf(user), sound_out, 50, TRUE)

		user.update_action_buttons_icon()  //Update action buttons as some spells might now be castable


/obj/effect/proc_holder/spell/area_teleport/invocation(mob/user)
	if(!invocation_area || !selected_area)
		return

	switch(invocation_type)
		if("shout")
			user.say("[invocation] [uppertext(selected_area.name)]")

		if("whisper")
			user.whisper("[invocation] [uppertext(selected_area.name)]")

