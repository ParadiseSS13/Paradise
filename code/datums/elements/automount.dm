/datum/element/automount
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	var/x_offset = 0
	var/y_offset = 0

/datum/element/automount/Attach(atom/movable/target)
	. = ..()
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE, PROC_REF(on_atom_after_successful_initialize))

/datum/element/automount/proc/on_atom_after_successful_initialize(atom/movable/source)
	var/turf/origin = get_turf(source)

	for(var/cardinal in list(SOUTH, NORTH, EAST, WEST))
		var/turf/T = get_ranged_target_turf(source, cardinal, 2)
		var/turf/dest = get_step(origin, cardinal)
		if(iswallturf(dest) || ismineralturf(dest))
			continue
		if(!iswallturf(T) && !ismineralturf(T))
			continue

		source.setDir(cardinal)
		source.forceMove(dest)
		switch(cardinal)
			if(NORTH)
				if(y_offset)
					source.pixel_y = y_offset
			if(SOUTH)
				if(y_offset)
					source.pixel_y = -y_offset
			if(WEST)
				if(x_offset)
					source.pixel_x = -x_offset
			if(EAST)
				if(x_offset)
					source.pixel_x = x_offset
		return

	// couldn't find anywhere to mount ourselves, so goodbye
	qdel(source)

/datum/element/automount/apc
	x_offset = 24
	y_offset = 24
