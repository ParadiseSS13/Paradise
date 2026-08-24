/datum/proximity_monitor/advanced/interceptor
	use_view = TRUE

/datum/proximity_monitor/advanced/interceptor/New(atom/_host, range, _ignore_if_not_on_turf)
	..()
	recalculate_field(TRUE)

/datum/proximity_monitor/advanced/interceptor/Destroy()
	return ..()

/datum/proximity_monitor/advanced/interceptor/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	. = ..()
	if(isprojectile(movable))
		astype(host, /obj/structure/flock/interceptor).try_intercept_projectile(movable)
