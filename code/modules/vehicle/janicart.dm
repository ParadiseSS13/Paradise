//PIMP-CART
/obj/vehicle/janicart
	name = "janicart (pimpin' ride)"
	desc = "A brave janitor cyborg gave its life to produce such an amazing combination of speed and utility."
	icon_state = "pussywagon"
	key_type = /obj/item/key/janitor
	var/obj/item/storage/bag/trash/trash_bag
	var/floorbuffer = FALSE

/obj/vehicle/janicart/Destroy()
	QDEL_NULL(trash_bag)
	return ..()

/obj/vehicle/janicart/handle_vehicle_offsets()
	..()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			switch(buckled_mob.dir)
				if(NORTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 4
				if(EAST)
					buckled_mob.pixel_x = -12
					buckled_mob.pixel_y = 7
				if(SOUTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 7
				if(WEST)
					buckled_mob.pixel_x = 12
					buckled_mob.pixel_y = 7

/obj/vehicle/janicart/Move(atom/OldLoc, Dir)
	. = ..()
	if(floorbuffer)
		var/turf/tile = loc
		if(isturf(tile))
			tile.clean_blood()
			for(var/A in tile)
				if(is_cleanable(A))
					qdel(A)

/obj/vehicle/janicart/examine(mob/user)
	. = ..()
	if(floorbuffer)
		. += "<span class='notice'>It has been upgraded with a floor buffer.</span>"

/obj/vehicle/janicart/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/storage/bag/trash))
		if(trash_bag)
			to_chat(user, "<span class='warning'>[src] already has a trashbag hooked!</span>")
			return
		if(!user.drop_item())
			return
		I.forceMove(src)
		to_chat(user, "<span class='notice'You hook the trashbag onto [src].</span>")
		trash_bag = I
		update_icon()
	else if(istype(I, /obj/item/janiupgrade))
		if(floorbuffer)
			to_chat(user, "<span class='warning'>[src] already has an upgrade installed! Use a screwdriver to remove it.</span>")
			return
		floorbuffer = TRUE
		qdel(I)
		to_chat(user,"<span class='notice'>You upgrade [src] with [I].</span>")
		update_icon()
	else if(trash_bag && (!is_key(I) || is_key(inserted_key))) // don't put a key in the trash when we need it
		trash_bag.attackby(I, user)
	else
		return ..()

/obj/vehicle/janicart/update_icon()
	cut_overlays()
	if(trash_bag)
		add_overlay("cart_garbage")
	if(floorbuffer)
		add_overlay("cart_buffer")

/obj/vehicle/janicart/attack_hand(mob/user)
	if(..())
		return TRUE
	else if(trash_bag)
		trash_bag.forceMove(get_turf(user))
		user.put_in_hands(trash_bag)
		trash_bag = null
		update_icon()

/obj/item/key/janitor
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon_state = "keyjanitor"

/obj/item/janiupgrade
	name = "floor buffer upgrade"
	desc = "An upgrade for mobile janicarts."
	icon = 'icons/obj/vehicles/vehicles.dmi'
	icon_state = "upgrade"
	origin_tech = "materials=3;engineering=4"
