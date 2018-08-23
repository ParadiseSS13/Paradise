/obj/item/mounted/frame/extinguisher
	name = "Extinguisher Cabinet Frame"
	desc = "Used for building extinguisher cabinet"
	icon = 'icons/obj/closet.dmi'
	icon_state = "extinguisher_frame"
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/extinguisher/do_build(turf/on_wall, mob/user)
	new /obj/structure/extinguisher_cabinet/empty(get_turf(src), get_dir(user, on_wall))
	qdel(src)
