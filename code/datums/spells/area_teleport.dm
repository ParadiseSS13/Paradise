/obj/effect/proc_holder/spell/targeted/area_teleport
	name = "Area teleport"
	desc = "This spell teleports you to a type of area of your selection."
	nonabstract_req = 1

	var/randomise_selection = 0 //if it lets the usr choose the teleport loc or picks it from the list
	var/invocation_area = 1 //if the invocation appends the selected area

	var/sound1 = 'sound/weapons/zapbang.ogg'
	var/sound2 = 'sound/weapons/zapbang.ogg'

/obj/effect/proc_holder/spell/targeted/area_teleport/perform(list/targets, recharge = 1, mob/living/user = usr)
	var/thearea = before_cast(targets)
	if(!thearea || !cast_check(1))
		revert_cast()
		return
	invocation(thearea)
	spawn(0)
		if(charge_type == "recharge" && recharge)
			start_recharge()
	cast(targets,thearea)
	after_cast(targets)

/obj/effect/proc_holder/spell/targeted/area_teleport/before_cast(list/targets)
	var/A = null

	if(!randomise_selection)
		A = input("Area to teleport to", "Teleport", A) as null|anything in GLOB.teleportlocs
	else
		A = pick(GLOB.teleportlocs)

	if(!A)
		return

	var/area/thearea = GLOB.teleportlocs[A]

	if(thearea.tele_proof && !istype(thearea, /area/wizard_station))
		to_chat(usr, "A mysterious force disrupts your arcane spell matrix, and you remain where you are.")
		return

	return thearea

/obj/effect/proc_holder/spell/targeted/area_teleport/cast(list/targets,area/thearea,mob/living/user = usr)
	playsound(get_turf(user), sound1, 50,1)
	for(var/mob/living/target in targets)
		var/list/L = list()
		for(var/turf/T in get_area_turfs(thearea.type))
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

	return

/obj/effect/proc_holder/spell/targeted/area_teleport/invocation(area/chosenarea = null)
	if(!invocation_area || !chosenarea)
		..()
	else
		switch(invocation_type)
			if("shout")
				usr.say("[invocation] [uppertext(chosenarea.name)]")
				if(usr.gender==MALE)
					playsound(usr.loc, pick('sound/misc/null.ogg','sound/misc/null.ogg'), 100, 1)
				else
					playsound(usr.loc, pick('sound/misc/null.ogg','sound/misc/null.ogg'), 100, 1)
			if("whisper")
				usr.whisper("[invocation] [uppertext(chosenarea.name)]")

	return
