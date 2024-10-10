/obj/item/mounted
	var/list/buildon_types = list(
		/turf/simulated/mineral/ancient,
		/turf/simulated/wall
	)
	var/allow_floor_mounting = FALSE


/obj/item/mounted/afterattack(atom/A, mob/user, proximity_flag)
	if(is_type_in_list(A, buildon_types))
		if(try_build(A, user, proximity_flag))
			return do_build(A, user)
	..()

/obj/item/mounted/proc/try_build(turf/on_wall, mob/user, proximity_flag) //checks
	if(!on_wall || !user)
		return FALSE
	if(!proximity_flag) //if we aren't next to the turf
		return FALSE

	if(!allow_floor_mounting)
		if(!(get_dir(on_wall, user) in GLOB.cardinal))
			to_chat(user, "<span class='warning'>You need to be standing next to [on_wall] to place [src].</span>")
			return FALSE

		if(gotwallitem(get_turf(user), get_dir(user, on_wall)))
			to_chat(user, "<span class='warning'>There's already an item on this wall!</span>")
			return FALSE

	return TRUE

/obj/item/mounted/proc/do_build(turf/on_wall, mob/user) //the buildy bit after we pass the checks
	return
