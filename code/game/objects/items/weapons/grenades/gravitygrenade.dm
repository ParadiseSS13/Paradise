/obj/item/grenade/gravitygrenade
	name = "Gravaton Grenade"
	desc = "This grenade emmits a blast of negative gravatons, inverting gravity in the nearbye area for 30 seconds."
	icon_state = "gravity"
	item_state = "flashtool"
	origin_tech = "magnets=4;combat=4"
	///used if it is a clusterbuster, so it deletes if it fails to activate, and doesnt leave 10+ unactivated nades
	var/clustersegment = FALSE

/obj/item/grenade/gravitygrenade/prime()
	update_mob()
	var/area/area = get_area(src)
	if(area.outdoors)
		visible_message("<span class='warning'> The [src] will not work in such a big area!</span>")
		unprime()
		return
	if(!is_teleport_allowed(area.z))
		visible_message("<span class='warning'> The [src] seems to not work here!</span>")
		unprime()
		return
	if(istype(area, /area/shuttle) || istype(area, /area/ruin))
		visible_message("<span class='warning'> The [src] seems to not work here!</span>")
		unprime()
		return
	if(area.has_gravity)
		area.gravitychange(0, area)
	else
		area.gravitychange(1, area)

	if(area.skreked_gravity)
		area.skreked_gravity = FALSE
	else
		area.skreked_gravity = TRUE
	playsound(loc, 'sound/weapons/wave.ogg', 60, 1)
	addtimer(CALLBACK(null, .proc/unskrek_gravity, area), 30 SECONDS)
	qdel(src)

/obj/item/grenade/gravitygrenade/proc/unskrek_gravity(area/area)
	if(area.has_gravity)
		area.gravitychange(0, area)
	else
		area.gravitychange(1, area)

	if(area.skreked_gravity)
		area.skreked_gravity = FALSE
	else
		area.skreked_gravity = TRUE

/obj/item/grenade/gravitygrenade/proc/unprime()
	active = 0
	icon_state = initial(icon_state)
	if(clustersegment)
		qdel(src)

/obj/item/grenade/gravitygrenade/clustersegment
	clustersegment = TRUE
