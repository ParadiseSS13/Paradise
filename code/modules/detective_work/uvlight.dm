/obj/item/device/uv_light
	name = "\improper UV light"
	desc = "A small handheld black light."
	icon_state = "uv_off"
	slot_flags = SLOT_BELT
	w_class = 2
	item_state = "electronic"
	//origin_tech = list(TECH_MAGNET = 1, TECH_ENGINEERING = 1)

	var/list/scanned = list()
	var/list/stored_alpha = list()
	var/list/reset_objects = list()

	var/range = 3
	var/on = 0
	var/step_alpha = 50

/obj/item/device/uv_light/attack_self(var/mob/user)
	on = !on
	if(on)
		set_light(range, 2, "#007fff")
		processing_objects |= src
		icon_state = "uv_on"
	else
		set_light(0)
		clear_last_scan()
		processing_objects -= src
		icon_state = "uv_off"

/obj/item/device/uv_light/proc/clear_last_scan()
	if(scanned.len)
		for(var/atom/O in scanned)
			O.invisibility = scanned[O]
			if(O.fluorescent == 2) O.fluorescent = 1
		scanned.Cut()
	if(stored_alpha.len)
		for(var/atom/O in stored_alpha)
			O.alpha = stored_alpha[O]
			if(O.fluorescent == 2) O.fluorescent = 1
		stored_alpha.Cut()
	if(reset_objects.len)
		for(var/obj/item/I in reset_objects)
			I.overlays -= I.blood_overlay
			if(I.fluorescent == 2) I.fluorescent = 1
		reset_objects.Cut()

/obj/item/device/uv_light/process()
	clear_last_scan()
	if(on)
		step_alpha = round(255/range)
		var/turf/origin = get_turf(src)
		if(!origin)
			return
		for(var/turf/T in range(range, origin))
			var/use_alpha = 255 - (step_alpha * get_dist(origin, T))
			for(var/atom/A in T.contents)
				if(A.fluorescent == 1)
					A.fluorescent = 2 //To prevent light crosstalk.
					if(A.invisibility)
						scanned[A] = A.invisibility
						A.invisibility = 0
						stored_alpha[A] = A.alpha
						A.alpha = use_alpha
					if(istype(A, /obj/item))
						var/obj/item/O = A
						if(O.was_bloodied && !(O.blood_overlay in O.overlays))
							O.overlays |= O.blood_overlay
							reset_objects |= O