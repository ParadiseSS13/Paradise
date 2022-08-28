/obj/item/mounted/frame/newscaster_frame
	name = "newscaster frame"
	desc = "Used to build newscasters, just secure to the wall."
	icon_state = "newscaster"
	item_state = "syringe_kit"

	materials = list(MAT_METAL=14000, MAT_GLASS=8000)
	mount_requirements = MOUNTED_FRAME_SIMFLOOR | MOUNTED_FRAME_NOSPACE
	metal_sheets_refunded = 7
	glass_sheets_refunded = 4

/obj/item/mounted/frame/newscaster_frame/do_build(turf/on_wall, mob/user)
	var/obj/machinery/newscaster/N = new /obj/machinery/newscaster(get_turf(src), get_dir(on_wall, user), 1)
	N.pixel_y -= (loc.y - on_wall.y) * 32
	N.pixel_x -= (loc.x - on_wall.x) * 32
	qdel(src)
