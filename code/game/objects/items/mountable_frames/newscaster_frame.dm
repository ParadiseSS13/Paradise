/obj/item/mounted/frame/display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	item_state = "syringe_kit"
	materials = list(MAT_METAL=6000, MAT_GLASS=2000)
	mount_requirements = MOUNTED_FRAME_SIMFLOOR | MOUNTED_FRAME_NOSPACE
	metal_sheets_refunded = 3
	glass_sheets_refunded = 1
	var/build_path

/obj/item/mounted/frame/display/do_build(turf/on_wall, mob/user)
	var/obj/machinery/status_display/N = new build_path(get_turf(src))
	N.pixel_y -= (loc.y - on_wall.y) * 32
	N.pixel_x -= (loc.x - on_wall.x) * 32
	qdel(src)

/obj/item/mounted/frame/display/newscaster_frame
	name = "newscaster frame"
	desc = "Used to build newscasters, just secure to the wall."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster"
	build_path = /obj/machinery/newscaster

/obj/item/mounted/frame/display/newscaster_frame/do_build(turf/on_wall, mob/user)
	var/obj/machinery/newscaster/N = new build_path(get_turf(src))
	N.pixel_y -= (loc.y - on_wall.y) * 28
	N.pixel_x -= (loc.x - on_wall.x) * 28
	var/constrdir = user.dir
	N.dir = turn(constrdir, 180)
	qdel(src)

/obj/item/mounted/frame/display/display_frame
	name = "status display frame"
	desc = "Used to build status displays, just secure to the wall."
	build_path = /obj/machinery/status_display

/obj/item/mounted/frame/display/ai_display_frame
	name = "ai status display frame"
	desc = "Used to build ai status displays, just secure to the wall."
	build_path = /obj/machinery/ai_status_display

/obj/item/mounted/frame/display/entertainment_frame
	name = "entertainment monitor frame"
	desc = "Used to build entertainment monitors, just secure to the wall."
	icon = 'icons/obj/computer.dmi'
	icon_state = "entertainment_console"
	build_path = /obj/machinery/computer/security/telescreen/entertainment
