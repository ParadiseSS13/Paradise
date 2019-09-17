/obj/item/mounted/frame
	name = "mountable frame"
	desc = "Place it on a wall."
	origin_tech = "materials=1;engineering=1"
	var/sheets_refunded = 2
	var/list/mount_reqs = list() //can contain simfloor, nospace. Used in try_build to see if conditions are needed, then met
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/mounted/frame/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/wrench) && sheets_refunded)
		//new /obj/item/stack/sheet/metal( get_turf(src.loc), sheets_refunded )
		var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(get_turf(src))
		M.amount = sheets_refunded
		qdel(src)

/obj/item/mounted/frame/try_build(turf/on_wall, mob/user)
	if(..()) //if we pass the parent tests
		var/turf/turf_loc = get_turf(user)

		if(src.mount_reqs.Find("simfloor") && !istype(turf_loc, /turf/simulated/floor))
			to_chat(user, "<span class='warning'>[src] cannot be placed on this spot.</span>")
			return
		if(src.mount_reqs.Find("nospace"))
			var/area/my_area = turf_loc.loc
			if(!istype(my_area) || (my_area.requires_power == 0 || istype(my_area,/area/space)))
				to_chat(user, "<span class='warning'>[src] cannot be placed in this area.</span>")
				return
		return 1
