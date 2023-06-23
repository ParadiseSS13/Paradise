/obj/structure/blob/captured_nuke //alternative to blob just straight up destroying nukes
	name = "blob captured nuke"
	icon_state = "blob"
	desc = "A Nuclear Warhead tangled in blob tendrils pulsating with a horrific green glow."
	max_integrity = 100
	point_return = 0

/obj/structure/blob/captured_nuke/Initialize(mapload, obj/machinery/nuclearbomb/N)
	. = ..()
	START_PROCESSING(SSobj, src)
	N?.forceMove(src)

/obj/structure/blob/captured_nuke/update_icon()
	..()
	cut_overlays()
	var/image/nuke_overlay = image('icons/mob/blob.dmi', "blob_nuke_overlay")
	nuke_overlay.appearance_flags = RESET_COLOR
	add_overlay(nuke_overlay)

/obj/structure/blob/captured_nuke/Destroy()
	for(var/obj/machinery/nuclearbomb/O in contents)
		O.forceMove(loc)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/blob/captured_nuke/Life(seconds, times_fired)
	obj_integrity = min(max_integrity, obj_integrity + 1)
