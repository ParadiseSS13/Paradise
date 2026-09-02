/// alternative to blob just straight up destroying nukes
/obj/structure/blob/captured_nuke
	name = "blob captured nuke"
	icon_state = "blob"
	desc = "A Nuclear Warhead tangled in blob tendrils pulsating with a horrific green glow."
	max_integrity = 100
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 65, ACID = 90)

/obj/structure/blob/captured_nuke/Initialize(mapload, obj/machinery/nuclearbomb/N)
	. = ..()
	START_PROCESSING(SSobj, src)
	N?.forceMove(src)
	update_icon(UPDATE_OVERLAYS)

/obj/structure/blob/captured_nuke/update_overlays()
	. = ..()
	var/image/nuke_overlay = image('icons/mob/blob.dmi', "blob_nuke_overlay")
	nuke_overlay.appearance_flags = RESET_COLOR
	. += nuke_overlay

/obj/structure/blob/captured_nuke/Destroy()
	for(var/obj/machinery/nuclearbomb/O in contents)
		O.forceMove(loc)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/blob/captured_nuke/Life(seconds, times_fired)
	obj_integrity = min(max_integrity, obj_integrity + 1)
