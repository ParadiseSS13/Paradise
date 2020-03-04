/obj/structure/closet/floor_closet
	name = "floor"
	desc = "Where did this come from?"
	density = 0
	icon_state = "bluespace"
	icon_closed = "bluespaceclosed"
	icon_opened = "bluespaceopen"
	storage_capacity = 30
	var/materials = list(MAT_METAL = 5000, MAT_PLASMA = 2500, MAT_TITANIUM = 500, MAT_BLUESPACE = 500)


/obj/structure/closet/floor_closet/close()
	var/turf/T = get_turf(src)
		if (T)
			src.icon = T.icon
			src.icon_closed = T.icon_state
			src.desc = T.desc + " It looks odd."
			src.plane = T.plane
		else
			src.icon = 'icons/obj/closet.dmi'
			src.icon_closed = "closet"

    . = ..()
	return

/obj/structure/closet/floor_closet/open()
		if (src.welded)
			return
		src.icon = 'icons/obj/closet.dmi'
		src.plane = initial(src.plane)
		..()
		return
