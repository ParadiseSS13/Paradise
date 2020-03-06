/obj/structure/closet/floor_closet
	name = "floor(?)"
	desc = "Where did this come from?"
	density = 0
	icon_state = "bluespace"
	icon_closed = "bluespaceclosed"
	icon_opened = "bluespaceopen"
	plane = OBJ_LAYER
	layer = BELOW_OBJ_LAYER
	storage_capacity = 30 //With the chameleon technology it doesn't hold as much as a normal one


/obj/structure/closet/floor_closet/close()
	var/turf/T = get_turf(src)
	if (T)
		src.icon = T.icon
		src.icon_closed = T.icon_state
		src.desc = T.desc + " It looks odd."
		src.plane = T.plane
		src.layer = T.layer
		src.name = T.name
	else
		src.icon = 'icons/obj/closet.dmi'
		src.icon_closed = "bluespaceclosed"
	. = ..()
	src.density = 0
	return
	

/obj/structure/closet/floor_closet/open()
	. = ..()
	src.plane = initial(src.plane)
	src.layer = initial(src.layer)
	src.icon = initial(src.icon)
	src.icon_opened = initial(src.icon_opened)
	src.name = initial(src.name)
	src.desc = initial(src.desc)
	return TRUE
