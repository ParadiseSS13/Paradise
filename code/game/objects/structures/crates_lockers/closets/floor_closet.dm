/obj/structure/closet/floor_closet
	name = "floor"
	desc = "Where did this come from?"
	density = 0
	icon_state = "bluespace"
	icon_closed = "bluespaceclosed"
	icon_opened = "bluespaceopen"
	storage_capacity = 30


/obj/structure/closet/floor_closet/close()
	. = ..()
	var/turf/T = get_turf(src)
	if (T)
		src.icon = T.icon
		src.icon_closed = T.icon_state
		src.desc = T.desc + " It looks odd."
		src.plane = T.plane
	else
		src.icon = 'icons/obj/closet.dmi'
		src.icon_closed = "bluespaceclosed"
	return

/obj/structure/closet/floor_closet/open()
	. = ..()
	src.plane = initial(src.plane)
	return TRUE
