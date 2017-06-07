//PIMP-CART
/obj/vehicle/janicart
	name = "janicart (pimpin' ride)"
	desc = "A brave janitor cyborg gave its life to produce such an amazing combination of speed and utility."
	icon_state = "pussywagon"
	keytype = /obj/item/key/janitor
	var/obj/item/weapon/storage/bag/trash/mybag = null
	var/floorbuffer = 0


/obj/vehicle/janicart/handle_vehicle_offsets()
	..()
	if(buckled_mob)
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


/obj/item/key/janitor
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon_state = "keyjanitor"


/obj/item/janiupgrade
	name = "floor buffer upgrade"
	desc = "An upgrade for mobile janicarts."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "upgrade"
	origin_tech = "materials=3;engineering=4"

/obj/vehicle/janicart/Move(atom/OldLoc, Dir)
	..()
	if(floorbuffer)
		var/turf/tile = loc
		if(isturf(tile))
			tile.clean_blood()
			if(istype(tile, /turf/simulated/floor))
				var/turf/simulated/floor/F = tile
				F.dirt = 0
			for(var/A in tile)
				if(is_cleanable(A))
					qdel(A)



/obj/vehicle/janicart/examine(mob/user)
	..()
	if(floorbuffer)
		to_chat(user, "It has been upgraded with a floor buffer.")


/obj/vehicle/janicart/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/storage/bag/trash))
		if(keytype == /obj/item/key/janitor)
			if(!user.drop_item())
				return
			to_chat(user, "<span class='notice'>You hook the trashbag onto \the [name].</span>")
			I.loc = src
			mybag = I
	else if(istype(I, /obj/item/janiupgrade))
		if(keytype == /obj/item/key/janitor)
			floorbuffer = 1
			qdel(I)
			to_chat(user,"<span class='notice'>You upgrade \the [name] with the floor buffer.</span>")
	update_icon()

	..()


/obj/vehicle/janicart/update_icon()
	overlays.Cut()
	if(mybag)
		overlays += "cart_garbage"
	if(floorbuffer)
		overlays += "cart_buffer"


/obj/vehicle/janicart/attack_hand(mob/user)
	if(..())
		return 1
	else if(mybag)
		mybag.loc = get_turf(user)
		user.put_in_hands(mybag)
		mybag = null
		update_icon()