//MISC items
//These items don't belong anywhere else, so they have this file.

//Current contents:
/*
	mouse_drag_pointer
	Beach Ball
	petcollar
*/

/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/item/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	item_state = "beachball"
	density = 0
	anchored = 0
	w_class = WEIGHT_CLASS_TINY
	force = 0.0
	throwforce = 0.0
	throw_speed = 1
	throw_range = 20
	flags = CONDUCT

/obj/item/petcollar
	name = "pet collar"
	desc = "The latest fashion accessory for your favorite pets!"
	icon_state = "petcollar"
	item_color = "petcollar"
	var/tagname = null
	var/obj/item/card/id/access_id

/obj/item/petcollar/Destroy()
	QDEL_NULL(access_id)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/petcollar/attack_self(mob/user)
	var/option = "Change Name"
	if(access_id)
		option = input(user, "What do you want to do?", "[src]", option) as null|anything in list("Change Name", "Remove ID")

	switch(option)
		if("Change Name")
			var/t = input(user, "Would you like to change the name on the tag?", "Name your new pet", tagname ? tagname : "Spot") as null|text
			if(t)
				tagname = copytext(sanitize(t), 1, MAX_NAME_LEN)
				name = "[initial(name)] - [tagname]"
		if("Remove ID")
			if(access_id)
				user.visible_message("<span class='warning'>[user] starts unclipping [access_id] from [src].</span>")
				if(do_after(user, 5 SECONDS, target = user) && access_id)
					user.visible_message("<span class='warning'>[user] unclips [access_id] from [src].</span>")
					access_id.forceMove(get_turf(user))
					user.put_in_hands(access_id)
					access_id = null

/obj/item/petcollar/attackby(obj/item/card/id/I, mob/user, params)
	if(!istype(I))
		return ..()
	if(access_id)
		to_chat(user, "<span class='warning'>There is already \an [access_id] clipped onto [src]</span>")
		return
	user.drop_item()
	I.forceMove(src)
	access_id = I
	to_chat(user, "<span class='notice'>[I] clips onto [src] snugly.</span>")

/obj/item/petcollar/GetAccess()
	return access_id ? access_id.GetAccess() : ..()

/obj/item/petcollar/examine(mob/user)
	. = ..()
	if(access_id)
		. += "There is [bicon(access_id)] \an [access_id] clipped onto it."

/obj/item/petcollar/equipped(mob/living/simple_animal/user)
	if(istype(user))
		START_PROCESSING(SSobj, src)

/obj/item/petcollar/dropped(mob/living/simple_animal/user)
	..()
	STOP_PROCESSING(SSobj, src)

/obj/item/petcollar/process()
	var/mob/living/simple_animal/M = loc
	// if it wasn't intentionally unequipped but isn't being worn, possibly gibbed
	if(istype(M) && src == M.pcollar && M.stat != DEAD)
		return

	var/area/A = get_area(M)
	var/obj/item/radio/headset/H = new /obj/item/radio/headset(src)
	if(istype(A, /area/syndicate_mothership) || istype(A, /area/shuttle/syndicate_elite))
		//give the syndicats a bit of stealth
		H.autosay("[M] has been vandalized in Space!", "[M]'s Death Alarm")
	else
		H.autosay("[M] has been vandalized in [A.name]!", "[M]'s Death Alarm")
	qdel(H)
	return PROCESS_KILL
