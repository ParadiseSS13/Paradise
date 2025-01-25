//Yes, they can only be rectangular.
//Yes, I'm sorry.
/datum/turf_reservation
	/// All turfs that we've reserved
	var/list/reserved_turfs = list()

	/// Turfs around the reservation for cordoning
	var/list/cordon_turfs = list()

	/// Area of turfs next to the cordon to fill with pre_cordon_area's
	var/list/pre_cordon_turfs = list()

	/// The width of the reservation
	var/width = 0

	/// The height of the reservation
	var/height = 0

	/// Bottom left turf of the reservation
	var/turf/bottom_left_turf

	/// Top right turf of the reservation
	var/turf/top_right_turf

	/// The turf type the reservation is initially made with
	var/turf_type = /turf/space

	/// Do we override baseturfs with turf_type?
	// var/turf_type_is_baseturf = TRUE

	// ///Distance away from the cordon where we can put a "sort-cordon" and run some extra code (see make_repel). 0 makes nothing happen
	// var/pre_cordon_distance = 0

/datum/turf_reservation/New()
	LAZYADD(SSmapping.turf_reservations, src)

/datum/turf_reservation/Destroy()
	Release()
	LAZYREMOVE(SSmapping.turf_reservations, src)
	return ..()

/datum/turf_reservation/proc/Release()
	bottom_left_turf = null
	top_right_turf = null

	var/list/reserved_copy = reserved_turfs.Copy()
	SSmapping.used_turfs -= reserved_turfs
	reserved_turfs = list()

	var/list/cordon_copy = cordon_turfs.Copy()
	SSmapping.used_turfs -= cordon_turfs
	cordon_turfs = list()

	var/release_turfs = reserved_copy + cordon_copy

	for(var/turf/reserved_turf as anything in release_turfs)

		// immediately disconnect from atmos
		reserved_turf.blocks_air = TRUE
		// CALCULATE_ADJACENT_TURFS(reserved_turf, KILL_EXCITED)

	// Makes the linter happy, even tho we don't await this
	SSmapping.reserve_turfs(release_turfs)
	// INVOKE_ASYNC(SSmapping, TYPE_PROC_REF(/datum/controller/subsystem/mapping, reserve_turfs), release_turfs)

/// Attempts to calaculate and store a list of turfs around the reservation for cordoning. Returns whether a valid cordon was calculated
/datum/turf_reservation/proc/calculate_cordon_turfs(turf/bottom_left, turf/top_right)
	if(bottom_left.x < 2 || bottom_left.y < 2 || top_right.x > (world.maxx - 2) || top_right.y > (world.maxy - 2))
		return FALSE // no space for a cordon here

	var/list/possible_turfs = CORNER_OUTLINE(bottom_left, width, height)
	// if they're our cordon turfs, accept them
	possible_turfs -= cordon_turfs
	for(var/turf/cordon_turf as anything in possible_turfs)
		// if we changed this to check reservation turf instead of not unused, we could have overlapping cordons.
		// Unfortunately, that means adding logic for cordons not being removed if they have multiple edges and I'm lazy
		if(!(cordon_turf.turf_flags & UNUSED_RESERVATION_TURF))
			return FALSE
	cordon_turfs |= possible_turfs

	// if(pre_cordon_distance)
	// 	var/turf/offset_turf = locate(bottom_left.x + pre_cordon_distance, bottom_left.y + pre_cordon_distance, bottom_left.z)
	// 	var/list/to_add = CORNER_OUTLINE(offset_turf, width - pre_cordon_distance * 2, height - pre_cordon_distance * 2) //we step-by-stop move inwards from the outer cordon
	// 	for(var/turf/turf_being_added as anything in to_add)
	// 		pre_cordon_turfs |= turf_being_added //add one by one so we can filter out duplicates

	return TRUE

/// Actually generates the cordon around the reservation, and marking the cordon turfs as reserved
/datum/turf_reservation/proc/generate_cordon()
	for(var/turf/cordon_turf as anything in cordon_turfs)
		var/area/cordon/cordon_area = GLOB.all_unique_areas[/area/cordon] || new /area/cordon
		// var/area/old_area = cordon_turf.loc

		// LISTASSERTLEN(old_area.turfs_to_uncontain_by_zlevel, cordon_turf.z, list())
		// LISTASSERTLEN(cordon_area.turfs_by_zlevel, cordon_turf.z, list())
		// old_area.turfs_to_uncontain_by_zlevel[cordon_turf.z] += cordon_turf
		// cordon_area.turfs_by_zlevel[cordon_turf.z] += cordon_turf
		cordon_area.contents += cordon_turf

		// Its no longer unused, but its also not "used"
		cordon_turf.turf_flags &= ~UNUSED_RESERVATION_TURF
		cordon_turf.empty(/turf/cordon)
		SSmapping.unused_turfs["[cordon_turf.z]"] -= cordon_turf
		// still gets linked to us though
		SSmapping.used_turfs[cordon_turf] = src

	// //swap the area with the pre-cordoning area
	// for(var/turf/pre_cordon_turf as anything in pre_cordon_turfs)
	// 	make_repel(pre_cordon_turf)

/// Internal proc which handles reserving the area for the reservation.
/datum/turf_reservation/proc/_reserve_area(width, height, zlevel)
	src.width = width
	src.height = height
	if(width > world.maxx || height > world.maxy || width < 1 || height < 1)
		return FALSE
	var/list/avail = SSmapping.unused_turfs["[zlevel]"]
	var/turf/bottom_left
	var/turf/top_right
	var/list/turf/final_turfs = list()
	var/passing = FALSE
	for(var/i in avail)
		CHECK_TICK
		bottom_left = i
		if(!(bottom_left.turf_flags & UNUSED_RESERVATION_TURF))
			continue
		if(bottom_left.x + width > world.maxx || bottom_left.y + height > world.maxy)
			continue
		top_right = locate(bottom_left.x + width - 1, bottom_left.y + height - 1, bottom_left.z)
		if(!(top_right.turf_flags & UNUSED_RESERVATION_TURF))
			continue
		final_turfs = block(bottom_left, top_right)
		if(!final_turfs)
			continue
		passing = TRUE
		for(var/I in final_turfs)
			var/turf/checking = I
			if(!(checking.turf_flags & UNUSED_RESERVATION_TURF))
				passing = FALSE
				break
		if(passing) // found a potentially valid area, now try to calculate its cordon
			passing = calculate_cordon_turfs(bottom_left, top_right)
		if(!passing)
			continue
		break
	if(!passing || !istype(bottom_left) || !istype(top_right))
		return FALSE
	for(var/i in final_turfs)
		var/turf/T = i
		reserved_turfs |= T
		SSmapping.unused_turfs["[T.z]"] -= T
		SSmapping.used_turfs[T] = src
		T.turf_flags = (T.turf_flags | RESERVATION_TURF) & ~UNUSED_RESERVATION_TURF
		T.blocks_air = FALSE // Experimental atmos on this z-level
		T.empty(turf_type)

	bottom_left_turf = bottom_left
	top_right_turf = top_right
	return TRUE

/datum/turf_reservation/proc/reserve(width, height, z_reservation)

	if(!_reserve_area(width, height, z_reservation))
		log_debug("Failed turf reservation: releasing")
		Release()
		return FALSE

	log_debug("Turf reservation successful, generating cordon")
	generate_cordon()
	return TRUE

/// Calculates the effective bounds information for the given turf. Returns a list of the information, or null if not applicable.
// /datum/turf_reservation/proc/calculate_turf_bounds_information(turf/target)
// 	var/turf/bottom_left = bottom_left_turfs[z_idx]
// 	var/turf/top_right = top_right_turfs[z_idx]
// 	var/bl_x = bottom_left.x
// 	var/bl_y = bottom_left.y
// 	var/tr_x = top_right.x
// 	var/tr_y = top_right.y

// 	if(target.x < bl_x)
// 		return

// 	if(target.y < bl_y)
// 		return

// 	if(target.x > tr_x)
// 		return

// 	if(target.y > tr_y)
// 		return

// 	var/list/return_information = list()
// 	return_information["offset_x"] = target.x - bl_x
// 	return_information["offset_y"] = target.y - bl_y
// 	return return_information

/// Schedules a group of turfs to be handed back to the reservation system's control
/datum/controller/subsystem/mapping/proc/reserve_turfs(list/turfs)
	lists_to_reserve += list(turfs)
