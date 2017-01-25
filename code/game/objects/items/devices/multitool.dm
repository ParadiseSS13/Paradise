/**
 * Multitool -- A multitool is used for hacking electronic devices.
 * TO-DO -- Using it as a power measurement tool for cables etc. Nannek.
 *
 */

/obj/item/device/multitool
	name = "multitool"
	desc = "Used for pulsing wires to test which to cut. Not recommended by doctors."
	icon_state = "multitool"
	flags = CONDUCT
	force = 5.0
	w_class = 2
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	materials = list(MAT_METAL=50, MAT_GLASS=20)
	origin_tech = "magnets=1;engineering=1"
	var/obj/machinery/buffer // simple machine buffer for device linkage

/obj/item/device/multitool/proc/IsBufferA(var/typepath)
	if(!buffer)
		return 0
	return istype(buffer,typepath)

// Syndicate device disguised as a multitool; it will turn red when an AI camera is nearby.


/obj/item/device/multitool/ai_detect
	var/track_delay = 0

/obj/item/device/multitool/ai_detect/New()
	..()
	processing_objects += src


/obj/item/device/multitool/ai_detect/Destroy()
	processing_objects -= src
	return ..()

/obj/item/device/multitool/ai_detect/process()

	if(track_delay > world.time)
		return

	var/found_eye = 0

	for(var/mob/camera/aiEye/A in living_mob_list)

		var/turf/our_turf = get_turf(src)
		var/turf/eye_turf = get_turf(A)

		if(get_dist(our_turf, eye_turf) < 9)
			found_eye = 1
			break

	if(found_eye)
		icon_state = "[initial(icon_state)]_red"
	else
		icon_state = initial(icon_state)

	track_delay = world.time + 10 // 1 second
	return

