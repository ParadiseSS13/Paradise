// Wires for cameras.

/datum/wires/camera
	random = 0
	holder_type = /obj/machinery/camera
	wire_count = 3

/datum/wires/camera/get_status()
	. = ..()
	var/obj/machinery/camera/C = holder
	. += "The focus light is [(C.view_range == initial(C.view_range)) ? "on" : "off"]."
	. += "The power link light is [C.can_use() ? "on" : "off"]."
	. += "The alarm light is [C.alarm_on ? "on" : "off"]."

/datum/wires/camera/CanUse(mob/living/L)
	var/obj/machinery/camera/C = holder
	if(!C.panel_open)
		return FALSE
	return TRUE

var/const/CAMERA_WIRE_FOCUS = 1
var/const/CAMERA_WIRE_POWER = 2
var/const/CAMERA_WIRE_ALARM = 4

/datum/wires/camera/GetWireName(index)
	switch(index)
		if(CAMERA_WIRE_FOCUS)
			return "Focus"

		if(CAMERA_WIRE_POWER)
			return "Power"

		if(CAMERA_WIRE_ALARM)
			return "Alarm"

/datum/wires/camera/UpdateCut(index, mended)
	var/obj/machinery/camera/C = holder

	switch(index)
		if(CAMERA_WIRE_FOCUS)
			var/range = (mended ? initial(C.view_range) : C.short_range)
			C.setViewRange(range)

		if(CAMERA_WIRE_POWER)
			if(C.status && !mended || !C.status && mended)
				C.toggle_cam(usr, 1)
				C.obj_integrity = C.max_integrity //this is a pretty simplistic way to heal the camera, but there's no reason for this to be complex.

		if(CAMERA_WIRE_ALARM)
			if(mended)
				C.triggerCameraAlarm()
			else
				C.cancelCameraAlarm()
	..()

/datum/wires/camera/UpdatePulsed(index)
	var/obj/machinery/camera/C = holder
	if(IsIndexCut(index))
		return
	switch(index)
		if(CAMERA_WIRE_FOCUS)
			var/new_range = (C.view_range == initial(C.view_range) ? C.short_range : initial(C.view_range))
			C.setViewRange(new_range)

		if(CAMERA_WIRE_POWER)
			C.toggle_cam(null) // Deactivate the camera

		if(CAMERA_WIRE_ALARM)
			C.visible_message("[bicon(C)] *beep*", "[bicon(C)] *beep*")
	..()

/datum/wires/camera/proc/CanDeconstruct()
	if(IsIndexCut(CAMERA_WIRE_POWER) && IsIndexCut(CAMERA_WIRE_FOCUS) && IsIndexCut(CAMERA_WIRE_ALARM))
		return TRUE
	else
		return FALSE