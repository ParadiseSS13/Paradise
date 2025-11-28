/obj/item/petcollar
	name = "pet collar"
	desc = "The latest fashion accessory for your favorite pets!"
	icon_state = "petcollar"
	var/tagname = null
	var/original_name
	var/original_real_name
	var/obj/item/card/id/access_id

/obj/item/petcollar/Destroy()
	QDEL_NULL(access_id)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/petcollar/attack_self__legacy__attackchain(mob/user)
	var/option = "Change Name"
	if(access_id)
		option = tgui_input_list(user, "What do you want to do?", "[src]", list("Change Name", "Remove ID"))
		if(QDELETED(src) || !Adjacent(user))
			return
	switch(option)
		if("Change Name")
			var/petname = input(user, "Would you like to change the name on the tag?", "Name your new pet", tagname ? tagname : "Spot") as null|text
			if(petname && !QDELETED(src) && Adjacent(user))
				tagname = copytext(sanitize(petname), 1, MAX_NAME_LEN)
				name = "[initial(name)] - [tagname]"
		if("Remove ID")
			if(access_id)
				user.visible_message("<span class='warning'>[user] starts unclipping [access_id] from [src].</span>")
				if(do_after(user, 5 SECONDS, target = user) && access_id && !QDELETED(src) && Adjacent(user))
					user.visible_message("<span class='warning'>[user] unclips [access_id] from [src].</span>")
					access_id.forceMove(get_turf(user))
					user.put_in_hands(access_id)
					access_id = null

/obj/item/petcollar/attackby__legacy__attackchain(obj/item/card/id/W, mob/user, params)
	if(!istype(W))
		return ..()
	if(access_id)
		to_chat(user, "<span class='warning'>There is already \a [access_id] clipped onto [src].</span>")
		return ..()
	user.drop_item()
	W.forceMove(src)
	access_id = W
	to_chat(user, "<span class='notice'>[W] clips onto [src] snugly.</span>")

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
