/obj/item/grenade/gravitygrenade
	name = "Gravaton Grenade"
	desc = "This grenade emmits a blast of negative gravatons, inverting gravity in the nearby area for 30 seconds."
	icon_state = "gravity"
	item_state = "flashtool"
	origin_tech = "magnets=4;combat=4"
	///used if it is a clusterbuster, so it deletes if it fails to activate, and doesnt leave 10+ unactivated nades
	var/clustersegment = FALSE
	///How long untill gravity returns (In deciseconds)?
	var/gravity_timer = 30 SECONDS

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
	invert_gravity(area)
	playsound(loc, 'sound/weapons/wave.ogg', 60, 1)
	addtimer(CALLBACK(null, .proc/invert_gravity, area), gravity_timer)
	qdel(src)

/obj/item/grenade/gravitygrenade/proc/invert_gravity(area/area)
	area.gravitychange(!area.has_gravity)
	area.has_negative_gravatons = !area.has_negative_gravatons

/obj/item/grenade/gravitygrenade/proc/unprime()
	active = FALSE
	icon_state = initial(icon_state)
	if(clustersegment)
		qdel(src)

/obj/item/grenade/gravitygrenade/clustersegment
	clustersegment = TRUE
