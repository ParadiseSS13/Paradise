/obj/item/mounted/frame/intercom
	name = "Intercom Frame"
	desc = "Used for building intercoms"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "intercom-frame"
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/intercom/do_build(turf/on_wall, mob/user)
	new /obj/item/radio/intercom(get_turf(src), get_dir(user, on_wall), 0)
	qdel(src)
