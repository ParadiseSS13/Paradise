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

/obj/item/petcollar/attack_self(mob/user as mob)
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
				user.visible_message("<span class='warning'>[user] starts unclipping \the [access_id] from \the [src].</span>")
				if(do_after(user, 50, target = user) && access_id)
					user.visible_message("<span class='warning'>[user] unclips \the [access_id] from \the [src].</span>")
					access_id.forceMove(get_turf(user))
					user.put_in_hands(access_id)
					access_id = null

/obj/item/petcollar/attackby(obj/item/card/id/W, mob/user, params)
	if(!istype(W))
		return ..()
	if(access_id)
		to_chat(user, "<span class='warning'>There is already \a [access_id] clipped onto \the [src]</span>")
	user.drop_item()
	W.forceMove(src)
	access_id = W
	to_chat(user, "<span class='notice'>\The [W] clips onto \the [src] snugly.</span>")

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
	if(istype(M) && src == M.pcollar && M.stat != DEAD)
		return

	var/area/t = get_area(M)
	var/obj/item/radio/headset/a = new /obj/item/radio/headset(src)
	if(istype(t, /area/syndicate_mothership) || istype(t, /area/shuttle/syndicate_elite))
		//give the syndicats a bit of stealth
		a.autosay("[M] has been vandalized in Space!", "[M]'s Death Alarm")
	else
		a.autosay("[M] has been vandalized in [t.name]!", "[M]'s Death Alarm")
	qdel(a)
	STOP_PROCESSING(SSobj, src)
