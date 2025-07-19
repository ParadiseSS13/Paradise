/*
 * Turf reservations are used to reserve specific areas of the reserved z-levels for various purposes, typically for late-loading maps.
 * It ensures that reserved turfs are properly managed and can be released when no longer needed.
 * Reservations are not automatically released, so they must be manually released when no longer needed.
 *
 * Usage:
 * - To create a new reservation, call the `request_turf_block_reservation(width, height)` method from the mapping subsystem.
 * - This will return a new instance of /datum/turf_reservation if the reservation is successful.
 *
 * Releasing:
 * - Call the `Release` method on the /datum/turf_reservation instance to release the reserved turfs and cordon turfs.
 * - This will return the used turfs to the mapping subsystem to allow for reuse of the turfs.
 */

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

	/// The z-level traits required by the turf reservation. Modify only if
	/// you are absolutely certain pre-existing reservation types do not support
	/// your use-case, as an entirely new z-level will be reserved if this list
	/// of traits is unique.
	var/list/required_traits = list()

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

	SSmapping.unreserve_turfs(release_turfs)

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

	return TRUE

/// Actually generates the cordon around the reservation, and marking the cordon turfs as reserved
/datum/turf_reservation/proc/generate_cordon()
	for(var/turf/cordon_turf as anything in cordon_turfs)
		var/area/cordon/cordon_area = GLOB.all_unique_areas[/area/cordon] || new /area/cordon

		cordon_area.contents += cordon_turf

		// Its no longer unused, but its also not "used"
		cordon_turf.turf_flags &= ~UNUSED_RESERVATION_TURF
		cordon_turf.empty(/turf/cordon)
		SSmapping.unused_turfs["[cordon_turf.z]"] -= cordon_turf
		// still gets linked to us though
		SSmapping.used_turfs[cordon_turf] = src

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
	for(var/turf/T as anything in final_turfs)
		reserved_turfs |= T
		SSmapping.unused_turfs["[T.z]"] -= T
		SSmapping.used_turfs[T] = src
		T.turf_flags = (T.turf_flags | RESERVATION_TURF) & ~UNUSED_RESERVATION_TURF
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

/datum/turf_reservation/transit
	turf_type = /turf/space/transit
	required_traits = list(TCOMM_RELAY_ALWAYS)
