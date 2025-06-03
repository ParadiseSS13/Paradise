/obj/item/mounted
	var/list/buildon_types = list(
		/turf/simulated/mineral/ancient,
		/turf/simulated/wall
	)
	var/allow_floor_mounting = FALSE
	new_attack_chain = TRUE

/obj/item/mounted/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if(is_type_in_list(target, buildon_types))
		if(try_build(target, user))
			do_build(target, user)
			return ITEM_INTERACT_COMPLETE
	..()

/obj/item/mounted/proc/try_build(turf/on_wall, mob/user) //checks
	if(!on_wall || !user)
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
