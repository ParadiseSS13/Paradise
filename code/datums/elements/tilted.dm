/datum/element/tilted
	element_flags = ELEMENT_BESPOKE
	var/tilt_angle

/datum/element/tilted/Attach(datum/target, tilt_angle)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.tilt_angle = tilt_angle




