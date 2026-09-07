/obj/item/petcollar
	name = "pet collar"
	desc = "The latest fashion accessory for your favorite pets!"
	icon_state = "petcollar"
	var/tagname = null
	var/original_name
	var/original_real_name
	var/obj/item/card/id/access_id
	new_attack_chain = TRUE

/obj/item/petcollar/Destroy()
	QDEL_NULL(access_id)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/petcollar/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE
	var/option = "Change Name"
	if(access_id)
		option = tgui_input_list(user, "What do you want to do?", "[src]", list("Change Name", "Remove ID"))
		if(QDELETED(src) || !Adjacent(user))
			return ITEM_INTERACT_COMPLETE
	switch(option)
		if("Change Name")
			var/petname = input(user, "Would you like to change the name on the tag?", "Name your new pet", tagname ? tagname : "Spot") as null|text
			if(petname && !QDELETED(src) && Adjacent(user))
				tagname = copytext(sanitize(petname), 1, MAX_NAME_LEN)
				name = "[initial(name)] - [tagname]"
			return ITEM_INTERACT_COMPLETE
		if("Remove ID")
			if(access_id)
				user.visible_message(SPAN_WARNING("[user] starts unclipping [access_id] from [src]."))
				if(do_after(user, 5 SECONDS, target = user) && access_id && !QDELETED(src) && Adjacent(user))
					user.visible_message(SPAN_WARNING("[user] unclips [access_id] from [src]."))
					access_id.forceMove(get_turf(user))
					user.put_in_hands(access_id)
					access_id = null
	return ITEM_INTERACT_COMPLETE

/obj/item/petcollar/item_interaction(mob/living/user, obj/item/card/id/tool, list/modifiers)
	if(!istype(tool))
		return ..()
	if(access_id)
		to_chat(user, SPAN_WARNING("There is already \a [access_id] clipped onto [src]."))
		return ITEM_INTERACT_COMPLETE
	user.drop_item()
	tool.forceMove(src)
	access_id = tool
	to_chat(user, SPAN_NOTICE("[tool] clips onto [src] snugly."))
	return ITEM_INTERACT_COMPLETE

/obj/item/petcollar/GetAccess()
	return access_id ? access_id.GetAccess() : ..()

/obj/item/petcollar/examine(mob/user)
	. = ..()
	if(access_id)
		. += "There is [bicon(access_id)] \a [access_id] clipped onto it."

/obj/item/petcollar/equipped(mob/living/simple_animal/user)
	if(istype(user))
		START_PROCESSING(SSobj, src)

/obj/item/petcollar/dropped(mob/living/simple_animal/user)
	..()
	STOP_PROCESSING(SSobj, src)

/obj/item/petcollar/process()
	var/mob/living/simple_animal/M = loc
	// if it wasn't intentionally unequipped but isn't being worn, possibly gibbed
	if(istype(M) && M.stat != DEAD)
		return

	var/area/pet_death_area = get_area(M)
	var/obj/item/radio/headset/pet_death_announcer = new /obj/item/radio/headset(src)
	pet_death_announcer.follow_target = src
	if(istype(pet_death_area, /area/syndicate_mothership) || istype(pet_death_area, /area/shuttle/syndicate_elite))
		//give the syndicats a bit of stealth
		pet_death_announcer.autosay("[M] has been vandalized in Space!", "[M]'s Death Alarm")
	else
		pet_death_announcer.autosay("[M] has been vandalized in [pet_death_area.name]!", "[M]'s Death Alarm")
	qdel(pet_death_announcer)
	STOP_PROCESSING(SSobj, src)
