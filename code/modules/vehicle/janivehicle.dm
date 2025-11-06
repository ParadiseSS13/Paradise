//PIMP-CART
/obj/vehicle/janicart
	name = "janicart (pimpin' ride)"
	desc = "A brave janitor cyborg gave its life to produce such an amazing combination of speed and utility."
	icon_state = "pussywagon"
	key_type = /obj/item/key/janitor
	var/obj/item/storage/bag/trash/mybag
	var/buffer_installed = FALSE
	/// How much speed the janicart loses while the buffer is active
	var/buffer_delay = 1
	/// Does it clean the tile under it?
	var/floorbuffer = FALSE

/obj/vehicle/janicart/Initialize(mapload)
	. = ..()
	GLOB.janitorial_equipment += src

/obj/vehicle/janicart/Destroy()
	GLOB.janitorial_equipment -= src
	QDEL_NULL(mybag)
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

/obj/item/key/janitor
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon_state = "keyjanitor"

/datum/action/floor_buffer
	name = "Toggle Floor Buffer"
	desc = "Movement speed is decreased while active."
	button_icon = 'icons/obj/vehicles.dmi'
	button_icon_state = "upgrade"

/datum/action/floor_buffer/Trigger(left_click)
	. = ..()
	var/obj/vehicle/janicart/J = target
	if(!J.floorbuffer)
		J.floorbuffer = TRUE
		J.vehicle_move_delay += J.buffer_delay
	else
		J.floorbuffer = FALSE
		J.vehicle_move_delay -= J.buffer_delay
	to_chat(usr, "<span class='notice'>The floor buffer is now [J.floorbuffer ? "active" : "deactivated"].</span>")

/obj/vehicle/janicart/post_buckle_mob(mob/living/M)
	. = ..()
	if(!buffer_installed)
		return
	var/datum/action/floor_buffer/floorbuffer_action = new(src)
	if(has_buckled_mobs())
		floorbuffer_action.Grant(M)
	else
		floorbuffer_action.Remove(M)

/obj/vehicle/janicart/post_unbuckle_mob(mob/living/M)
	for(var/datum/action/floor_buffer/floorbuffer_action in M.actions)
		floorbuffer_action.Remove(M)
	return ..()

/obj/vehicle/janicart/Move(atom/OldLoc, Dir)
	. = ..()
	if(floorbuffer && has_buckled_mobs())
		var/turf/tile = loc
		if(isturf(tile))
			tile.clean_blood()
			for(var/obj/effect/E in tile)
				if(E.is_cleanable())
					qdel(E)

/obj/vehicle/janicart/examine(mob/user)
	. = ..()
	if(buffer_installed)
		. += "It has been upgraded with a floor buffer."

/obj/vehicle/janicart/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	var/fail_msg = "<span class='notice'>There is already one of those in [src].</span>"

	if(istype(used, /obj/item/storage/bag/trash))
		if(mybag)
			to_chat(user, fail_msg)
			return ITEM_INTERACT_COMPLETE
		if(!user.drop_item())
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You hook [used] onto [src].</span>")
		used.forceMove(src)
		mybag = used
		update_icon(UPDATE_OVERLAYS)
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/borg/upgrade/floorbuffer))
		if(buffer_installed)
			to_chat(user, fail_msg)
			return ITEM_INTERACT_COMPLETE
		buffer_installed = TRUE
		qdel(used)
		to_chat(user,"<span class='notice'>You upgrade [src] with [used].</span>")
		update_icon(UPDATE_OVERLAYS)
		return ITEM_INTERACT_COMPLETE

	if(mybag && user.a_intent == INTENT_HELP && !is_key(used))
		mybag.attackby__legacy__attackchain(used, user)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/vehicle/janicart/update_overlays()
	. = ..()
	if(mybag)
		. += "cart_garbage"
	if(buffer_installed)
		. += "cart_buffer"

/obj/vehicle/janicart/attack_hand(mob/user)
	if(..())
		return TRUE
	else if(mybag)
		mybag.forceMove(get_turf(user))
		user.put_in_hands(mybag)
		mybag = null
		update_icon(UPDATE_OVERLAYS)
