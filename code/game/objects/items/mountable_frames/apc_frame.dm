/obj/item/mounted/frame/apc_frame
	name = "APC frame"
	desc = "Used for repairing or building APCs"
	icon = 'icons/obj/apc_repair.dmi'
	icon_state = "apc_frame"
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/apc_frame/try_build(turf/on_wall, mob/user)
	if(!..())
		return
	var/turf/T = get_turf(user)
	var/area/A = get_area(T)
	if(A.get_apc())
		to_chat(user, "<span class='warning'>This area already has an APC!</span>")
		return //only one APC per area
	if(!A.requires_power)
		to_chat(user, "<span class='warning'>You cannot place [src] in this area!</span>")
		return //can't place apcs in areas with no power requirement
	for(var/obj/machinery/power/terminal/E in T)
		if(E.master)
			to_chat(user, "<span class='warning'>There is another network terminal here!</span>")
			return
		else
			var/obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(T)
			C.amount = 10
			to_chat(user, "<span class='notice'>You cut the cables and disassemble the unused power terminal.</span>")
			qdel(E)
	return TRUE

/obj/item/mounted/frame/apc_frame/do_build(turf/on_wall, mob/user)
	new /obj/machinery/power/apc(get_turf(src), get_dir(user, on_wall), 1)
	qdel(src)
