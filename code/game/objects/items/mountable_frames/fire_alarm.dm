/obj/item/mounted/frame/firealarm
	name = "fire alarm frame"
	desc = "Used for building Fire Alarms"
	icon = 'icons/obj/fire_alarm.dmi'
	icon_state = "casing"
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/firealarm/do_build(turf/on_wall, mob/user)
	new /obj/machinery/firealarm(get_turf(src), get_dir(user, on_wall), 1)
	qdel(src)
