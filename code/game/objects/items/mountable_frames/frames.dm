/obj/item/mounted/frame
	name = "mountable frame"
	desc = "Place it on a wall."
	origin_tech = "materials=1;engineering=1"
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'

	///amount of metal sheets returned upon the frame being wrenched
	var/metal_sheets_refunded = 2
	///amount of glass sheets returned upon the frame being wrenched
	var/glass_sheets_refunded = 0
	///The requirements for this frame to be placed, uses bit flags
	var/mount_requirements = 0

/obj/item/mounted/frame/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/wrench))
		var/turf/user_turf = get_turf(user)
		if(metal_sheets_refunded)
			new /obj/item/stack/sheet/metal(user_turf, metal_sheets_refunded)
		if(glass_sheets_refunded)
			new /obj/item/stack/sheet/glass(user_turf, glass_sheets_refunded)
		qdel(src)

/obj/item/mounted/frame/try_build(turf/on_wall, mob/user)
	if(!..())
		return

	var/turf/build_turf = get_turf(user)
	if((mount_requirements & MOUNTED_FRAME_SIMFLOOR) && !isfloorturf(build_turf))
		to_chat(user, "<span class='warning'>[src] cannot be placed on this spot.</span>")
		return
	if(mount_requirements & MOUNTED_FRAME_NOSPACE)
		var/area/my_area = get_area(build_turf)
		if(!istype(my_area) || !my_area.requires_power || istype(my_area, /area/space))
			to_chat(user, "<span class='warning'>[src] cannot be placed in this area.</span>")
			return
	return TRUE
