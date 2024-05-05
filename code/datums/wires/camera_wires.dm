// Wires for cameras.

/datum/wires/camera
	holder_type = /obj/machinery/camera
	wire_count = 2
	proper_name = "Camera"

/datum/wires/camera/New(atom/_holder)
	wires = list(WIRE_FOCUS, WIRE_MAIN_POWER1)
	return ..()

/datum/wires/camera/get_status()
	. = ..()
	var/obj/machinery/camera/C = holder
	. += "The focus light is [(C.view_range == initial(C.view_range)) ? "on" : "off"]."
	. += "The power link light is [C.can_use() ? "on" : "off"]."

/datum/wires/camera/interactable(mob/user)
	var/obj/machinery/camera/C = holder
	if(!C.panel_open)
		return FALSE
	return TRUE

/datum/wires/camera/on_cut(wire, mend)
	var/obj/machinery/camera/C = holder
	switch(wire)
		if(WIRE_FOCUS)
			var/range = (mend ? initial(C.view_range) : C.short_range)
			C.setViewRange(range)

		if(WIRE_MAIN_POWER1)
			if(C.status && !mend || !C.status && mend)
				C.toggle_cam(usr, TRUE)
				C.obj_integrity = C.max_integrity //this is a pretty simplistic way to heal the camera, but there's no reason for this to be complex.
	..()

/datum/wires/camera/on_pulse(wire)
	var/obj/machinery/camera/C = holder
	if(is_cut(wire))
		return
	switch(wire)
		if(WIRE_FOCUS)
			var/new_range = (C.view_range == initial(C.view_range) ? C.short_range : initial(C.view_range))
			C.setViewRange(new_range)

		if(WIRE_MAIN_POWER1)
			C.toggle_cam(null) // Deactivate the camera
	..()

/datum/wires/camera/proc/CanDeconstruct()
	if(is_cut(WIRE_MAIN_POWER1) && is_cut(WIRE_FOCUS))
		return TRUE
	else
		return FALSE
