/obj/item/mounted/frame/newscaster_frame
	name = "newscaster frame"
	desc = "Used to build newscasters, just secure to the wall."
	icon_state = "newscaster"
	item_state = "syringe_kit"

	materials = list(MAT_METAL=6000, MAT_GLASS=2000)
	mount_requirements = MOUNTED_FRAME_SIMFLOOR | MOUNTED_FRAME_NOSPACE
	metal_sheets_refunded = 3
	glass_sheets_refunded = 1

/obj/item/mounted/frame/newscaster_frame/do_build(turf/on_wall, mob/user)
	var/obj/machinery/newscaster/N = new /obj/machinery/newscaster(get_turf(src), get_dir(on_wall, user), 1)
	N.pixel_y -= (loc.y - on_wall.y) * 32
	N.pixel_x -= (loc.x - on_wall.x) * 32
	qdel(src)
/obj/item/mounted/frame/newscaster_frame/display_frame
	name = "status display frame"
	desc = "Used to build status displays, just secure to the wall."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	item_state = "syringe_kit"

/obj/item/mounted/frame/newscaster_frame/display_frame/do_build(turf/on_wall, mob/user)
	var/obj/machinery/status_display/N = new /obj/machinery/status_display(get_turf(src), get_dir(on_wall, user), 1)
	N.pixel_y -= (loc.y - on_wall.y) * 32
	N.pixel_x -= (loc.x - on_wall.x) * 32
	qdel(src)

/obj/item/mounted/frame/newscaster_frame/ai_display_frame
	name = "ai status display frame"
	desc = "Used to build ai status displays, just secure to the wall."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	item_state = "syringe_kit"

/obj/item/mounted/frame/newscaster_frame/ai_display_frame/do_build(turf/on_wall, mob/user)
	var/obj/machinery/ai_status_display/N = new /obj/machinery/ai_status_display(get_turf(src), get_dir(on_wall, user), 1)
	N.pixel_y -= (loc.y - on_wall.y) * 32
	N.pixel_x -= (loc.x - on_wall.x) * 32
	qdel(src)

/obj/item/mounted/frame/newscaster_frame/entertainment_frame
	name = "entertainment monitor frame"
	desc = "Used to build entertainment monitors, just secure to the wall."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	item_state = "syringe_kit"

/obj/item/mounted/frame/newscaster_frame/entertainment_frame/do_build(turf/on_wall, mob/user)
	var/obj/machinery/computer/security/telescreen/entertainment/N = new /obj/machinery/computer/security/telescreen/entertainment(get_turf(src), get_dir(on_wall, user), 1)
	N.pixel_y -= (loc.y - on_wall.y) * 32
	N.pixel_x -= (loc.x - on_wall.x) * 32
	qdel(src)
