/obj/item/mounted/frame/firealarm
	name = "fire alarm frame"
	desc = "Used for building Fire Alarms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "firealarm_frame"

	mount_requirements = MOUNTED_FRAME_SIMFLOOR | MOUNTED_FRAME_NOSPACE

/obj/item/mounted/frame/firealarm/do_build(turf/on_wall, mob/user)
	new /obj/machinery/firealarm(get_turf(src), get_dir(user, on_wall), 1)
	qdel(src)
