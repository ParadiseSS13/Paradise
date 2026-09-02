GLOBAL_LIST_EMPTY(high_value_items)

/datum/element/high_value_item
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/high_value_item/Attach(datum/target)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	GLOB.high_value_items |= target

/datum/element/high_value_item/Detach(datum/source, force)
	. = ..()
	var/turf/turf_loc = get_turf(source)
	if(turf_loc)
		message_admins("[source] has been destroyed in [get_area(turf_loc)] at [ADMIN_COORDJMP(turf_loc)].")
		log_game("[source] has been destroyed at ([turf_loc.x],[turf_loc.y],[turf_loc.z]) in the location [turf_loc.loc].")
	else
		message_admins("[source] has been destroyed in nullspace.")
		log_game("[source] has been destroyed in nullspace.")
	GLOB.high_value_items -= source

