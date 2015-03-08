/atom/movable/proc/nano_host()
	return src

/obj/nano_module/nano_host()
	return loc


/atom/movable/proc/CanUseTopic(var/mob/user, href_list, var/datum/topic_state/custom_state)
	return user.can_use_topic(nano_host(), custom_state)


/mob/proc/can_use_topic(var/mob/user, var/datum/topic_state/custom_state)
	return STATUS_CLOSE // By default no mob can do anything with NanoUI

/mob/dead/observer/can_use_topic()
	if(check_rights(R_ADMIN, 0, src))
		return STATUS_INTERACTIVE				// Admins are more equal
	return STATUS_UPDATE						// Ghosts can view updates

/mob/living/silicon/pai/can_use_topic(var/src_object)
	if(src_object == src && !stat)
		return STATUS_INTERACTIVE
	else
		return ..()

/mob/living/silicon/robot/can_use_topic(var/src_object, var/datum/topic_state/custom_state)
	if(stat || !client)
		return STATUS_CLOSE
	if(lockcharge || stunned || weakened)
		return STATUS_DISABLED
	// robots can interact with things they can see within their view range
	if(!(custom_state.flags & NANO_IGNORE_DISTANCE) && (src_object in view(src)))
		return STATUS_INTERACTIVE	// interactive (green visibility)
	return STATUS_DISABLED			// no updates, completely disabled (red visibility)

/mob/living/silicon/robot/syndicate/can_use_topic(var/src_object)
	. = ..()
	if(. != STATUS_INTERACTIVE)
		return

	if(z in config.admin_levels)						// Syndicate borgs can interact with everything on the admin level
		return STATUS_INTERACTIVE
	if(istype(get_area(src), /area/syndicate_station))	// If elsewhere, they can interact with everything on the syndicate shuttle
		return STATUS_INTERACTIVE
	if(istype(src_object, /obj/machinery))				// Otherwise they can only interact with emagged machinery
		var/obj/machinery/Machine = src_object
		if(Machine.emagged)
			return STATUS_INTERACTIVE
	return STATUS_UPDATE

/mob/living/silicon/ai/can_use_topic(var/src_object)
	if(!client || check_unable(1))
		return STATUS_CLOSE
	// Prevents the AI from using Topic on admin levels (by for example viewing through the court/thunderdome cameras)
	// unless it's on the same level as the object it's interacting with.
	var/turf/T = get_turf(src_object)
	if(!T || !(z == T.z || (T.z in config.player_levels)))
		return STATUS_CLOSE

	// If an object is in view then we can interact with it
	if(src_object in view(client.view, src))
		return STATUS_INTERACTIVE

	// If we're installed in a chassi, rather than transfered to an inteliCard or other container, then check if we have camera view
	if(is_in_chassis())
		//stop AIs from leaving windows open and using then after they lose vision
		//apc_override is needed here because AIs use their own APC when powerless
		if(cameranet && !cameranet.checkTurfVis(get_turf(src_object)))
			return apc_override ? STATUS_INTERACTIVE : STATUS_CLOSE
		return STATUS_INTERACTIVE

	return 	STATUS_CLOSE

/mob/living/proc/shared_living_nano_interaction(var/src_object)
	if (src.stat != CONSCIOUS)
		return STATUS_CLOSE						// no updates, close the interface
	else if (restrained() || lying || stat || stunned || weakened)
		return STATUS_UPDATE					// update only (orange visibility)
	return STATUS_INTERACTIVE

/mob/living/proc/shared_living_nano_distance(var/atom/movable/src_object)
	if(!isturf(src_object.loc))
		if(src_object.loc == src)				// Item in the inventory
			return STATUS_INTERACTIVE
		if(src.contents.Find(src_object.loc))	// A hidden uplink inside an item
			return STATUS_INTERACTIVE

	if (!(src_object in view(4, src))) 	// If the src object is not in visable, disable updates
		return STATUS_CLOSE

	var/dist = get_dist(src_object, src)
	if (dist <= 1)
		return STATUS_INTERACTIVE	// interactive (green visibility)
	else if (dist <= 2)
		return STATUS_UPDATE 		// update only (orange visibility)
	else if (dist <= 4)
		return STATUS_DISABLED 		// no updates, completely disabled (red visibility)
	return STATUS_CLOSE

/mob/living/can_use_topic(var/src_object, var/datum/topic_state/custom_state)
	. = shared_living_nano_interaction(src_object)
	if(. == STATUS_INTERACTIVE && !(custom_state.flags & NANO_IGNORE_DISTANCE))
		. = shared_living_nano_distance(src_object)
	if(STATUS_INTERACTIVE)
		return STATUS_UPDATE

/mob/living/carbon/human/can_use_topic(var/src_object, var/datum/topic_state/custom_state)
	. = shared_living_nano_interaction(src_object)
	if(. == STATUS_INTERACTIVE && !(custom_state.flags & NANO_IGNORE_DISTANCE))
		. = shared_living_nano_distance(src_object)
		if(. == STATUS_UPDATE && (TK in mutations))	// If we have telekinesis and remain close enough, allow interaction.
			return STATUS_INTERACTIVE

/var/global/datum/topic_state/default_state = new()

/datum/topic_state
	var/flags = 0

/datum/topic_state/proc/href_list(var/mob/user)
	return list()