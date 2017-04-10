/obj/item/mounted/frame/newscaster_frame
	name = "newscaster frame"
	desc = "Used to build newscasters, just secure to the wall."
	icon_state = "newscaster"
	item_state = "syringe_kit"
	materials = list(MAT_METAL=14000, MAT_GLASS=8000)
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/newscaster_frame/try_build(turf/on_wall, mob/user)
	if(..())
		var/turf/loc = get_turf(usr)
		var/area/A = loc.loc
		if(!istype(loc, /turf/simulated/floor))
			to_chat(usr, "<span class='alert'>Newscaster cannot be placed on this spot.</span>")
			return
		if(A.requires_power == 0 || A.name == "Space")
			to_chat(usr, "<span class='alert'>Newscaster cannot be placed in this area.</span>")
			return

		for(var/obj/machinery/newscaster/T in loc)
			to_chat(usr, "<span class='alert'>There is another newscaster here.</span>")
			return

		return 1
	return

/obj/item/mounted/frame/newscaster_frame/do_build(turf/on_wall, mob/user)
	var/obj/machinery/newscaster/N = new /obj/machinery/newscaster(get_turf(src), get_dir(on_wall, user), 1)
	N.pixel_y -= (loc.y - on_wall.y) * 32
	N.pixel_x -= (loc.x - on_wall.x) * 32
	qdel(src)