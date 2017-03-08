// Wires for cameras.

/datum/wires/camera
	random = 0
	holder_type = /obj/machinery/camera
	wire_count = 6

/datum/wires/camera/get_status()
	. = ..()
	var/obj/machinery/camera/C = holder
	. += "The focus light is [(C.view_range == initial(C.view_range)) ? "on" : "off"]."
	. += "The power link light is [C.can_use() ? "on" : "off"]."
	. += "The camera light is [C.light_disabled ? "off" : "on"]."
	. += "The alarm light is [C.alarm_on ? "on" : "off"]."

/datum/wires/camera/CanUse(mob/living/L)
	var/obj/machinery/camera/C = holder
	if(!C.panel_open)
		return 0
	return 1

var/const/CAMERA_WIRE_FOCUS = 1
var/const/CAMERA_WIRE_POWER = 2
var/const/CAMERA_WIRE_LIGHT = 4
var/const/CAMERA_WIRE_ALARM = 8
var/const/CAMERA_WIRE_NOTHING1 = 16
var/const/CAMERA_WIRE_NOTHING2 = 32

/datum/wires/camera/UpdateCut(index, mended)
	var/obj/machinery/camera/C = holder

	switch(index)
		if(CAMERA_WIRE_FOCUS)
			var/range = (mended ? initial(C.view_range) : C.short_range)
			C.setViewRange(range)

		if(CAMERA_WIRE_POWER)
			if(C.status && !mended || !C.status && mended)
				C.toggle_cam(usr, 1)

		if(CAMERA_WIRE_LIGHT)
			C.light_disabled = !mended

		if(CAMERA_WIRE_ALARM)
			if(!mended)
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

		if(CAMERA_WIRE_LIGHT)
			C.light_disabled = !C.light_disabled

		if(CAMERA_WIRE_ALARM)
			C.visible_message("[bicon(C)] *beep*", "[bicon(C)] *beep*")
	..()

/datum/wires/camera/proc/CanDeconstruct()
	if(IsIndexCut(CAMERA_WIRE_POWER) && IsIndexCut(CAMERA_WIRE_FOCUS) && IsIndexCut(CAMERA_WIRE_LIGHT) && IsIndexCut(CAMERA_WIRE_NOTHING1) && IsIndexCut(CAMERA_WIRE_NOTHING2))
		return 1
	else
		return 0