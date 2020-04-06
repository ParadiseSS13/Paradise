/*
AIR ALARM ITEM
Handheld air alarm frame, for placing on walls
Code shamelessly copied from apc_frame
*/
/obj/item/mounted/frame/alarm_frame
	name = "air alarm frame"
	desc = "Used for building Air Alarms"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm_bitem"
	materials = list(MAT_METAL=2000)
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/alarm_frame/do_build(turf/on_wall, mob/user)
	new /obj/machinery/alarm(get_turf(src), get_dir(on_wall, user), 1)
	qdel(src)
