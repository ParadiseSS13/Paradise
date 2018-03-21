/obj/item/mounted/frame/apc_frame
	name = "APC frame"
	desc = "Used for repairing or building APCs"
	icon = 'icons/obj/apc_repair.dmi'
	icon_state = "apc_frame"
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/apc_frame/try_build(turf/on_wall, mob/user)
	if(..())
		var/turf/turf_loc = get_turf(user)
		var/area/area_loc = turf_loc.loc
		if(area_loc.get_apc())
			to_chat(user, "<span class='warning'>This area already has an APC.</span>")
			return //only one APC per area
		for(var/obj/machinery/power/terminal/T in turf_loc)
			if(T.master)
				to_chat(user, "<span class='warning'>There is another network terminal here.</span>")
				return
			else
				var/obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(turf_loc)
				C.amount = 10
				to_chat(user, "You cut the cables and disassemble the unused power terminal.")
				qdel(T)
		return 1
	return

/obj/item/mounted/frame/apc_frame/do_build(turf/on_wall, mob/user)
	new /obj/machinery/power/apc(get_turf(src), get_dir(user, on_wall), 1)
	qdel(src)