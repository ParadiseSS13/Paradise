
/obj/vehicle
	name = "vehicle"
	desc = "A basic vehicle, vroom"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "scooter"
	density = 1
	anchored = 0
	can_buckle = TRUE
	buckle_lying = FALSE
	max_integrity = 300
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60)
	var/key_type
	var/held_key_type //Similar to above, but the vehicle needs the key in hands as opposed to inserted into the ignition
	var/obj/item/key/inserted_key
	var/key_type_exact = TRUE		//can subtypes work
	var/last_vehicle_move = 0 //used for move delays
	var/last_move_diagonal = FALSE
	var/vehicle_move_delay = 2 //tick delay between movements, lower = faster, higher = slower
	var/auto_door_open = TRUE
	var/needs_gravity = 0 //To allow non-space vehicles to move in no gravity or not, mostly for adminbus
	//Pixels
	var/generic_pixel_x = 0 //All dirs show this pixel_x for the driver
	var/generic_pixel_y = 0 //All dirs shwo this pixel_y for the driver
	var/spaceworthy = FALSE


/obj/vehicle/Initialize(mapload)
	. = ..()
	handle_vehicle_layer()

/obj/vehicle/Destroy()
	QDEL_NULL(inserted_key)
	return ..()

/obj/vehicle/examine(mob/user)
	. = ..()
	if(key_type)
		if(!inserted_key)
			. += "<span class='notice'>Put a key inside it by clicking it with the key.</span>"
		else
			. += "<span class='notice'>Alt-click [src] to remove the key.</span>"
	if(resistance_flags & ON_FIRE)
		. += "<span class='warning'>It's on fire!</span>"
	var/healthpercent = obj_integrity/max_integrity * 100
	switch(healthpercent)
		if(50 to 99)
			. += "It looks slightly damaged."
		if(25 to 50)
			. += "It appears heavily damaged."
		if(0 to 25)
			. += "<span class='warning'>It's falling apart!</span>"

/obj/vehicle/attackby(obj/item/I, mob/user, params)
	if(key_type && !is_key(inserted_key) && is_key(I))
		if(user.drop_item())
			I.forceMove(src)
			to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
			if(inserted_key)	//just in case there's an invalid key
				inserted_key.forceMove(drop_location())
			inserted_key = I
		else
			to_chat(user, "<span class='warning'>[I] seems to be stuck to your hand!</span>")
		return
	return ..()

/obj/vehicle/AltClick(mob/user)
	if(inserted_key && user.Adjacent(user))
		if(!(user in buckled_mobs))
			to_chat(user, "<span class='warning'>You must be riding [src] to remove [src]'s key!</span>")
			return
		to_chat(user, "<span class='notice'>You remove [inserted_key] from [src].</span>")
		inserted_key.forceMove(drop_location())
		user.put_in_hands(inserted_key)
		inserted_key = null
	return ..()

/obj/vehicle/proc/is_key(obj/item/I)
	return I ? (key_type_exact ? (I.type == key_type) : istype(I, key_type)) : FALSE

/obj/vehicle/proc/held_keycheck(mob/user)
	if(held_key_type)
		if(istype(user.l_hand, held_key_type) || istype(user.r_hand, held_key_type))
			return TRUE
	else
		return TRUE
	return FALSE

//APPEARANCE
/obj/vehicle/proc/handle_vehicle_layer()
	if(dir != NORTH)
		layer = MOB_LAYER+0.1
	else
		layer = OBJ_LAYER


//Override this to set your vehicle's various pixel offsets
//if they differ between directions, otherwise use the
//generic variables
/obj/vehicle/proc/handle_vehicle_offsets()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(dir)
			buckled_mob.pixel_x = generic_pixel_x
			buckled_mob.pixel_y = generic_pixel_y


/obj/vehicle/update_icon()
	return


/obj/item/key
	name = "key"
	desc = "A small grey key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "key"
	w_class = WEIGHT_CLASS_TINY


//BUCKLE HOOKS
/obj/vehicle/unbuckle_mob(mob/living/buckled_mob, force = FALSE)
	if(istype(buckled_mob))
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
	. = ..()


/obj/vehicle/user_buckle_mob(mob/living/M, mob/user)
	if(user.incapacitated())
		return
	for(var/atom/movable/A in get_turf(src))
		if(A.density)
			if(A != src && A != M)
				return
	M.forceMove(get_turf(src))
	..()
	handle_vehicle_offsets()

/obj/vehicle/bullet_act(obj/item/projectile/Proj)
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.bullet_act(Proj)

//MOVEMENT
/obj/vehicle/relaymove(mob/user, direction)
	if(key_type && !is_key(inserted_key))
		to_chat(user, "<span class='warning'>[src] has no key inserted!</span>")
		return

	if(user.incapacitated())
		unbuckle_mob(user)
		return

	if(world.time < last_vehicle_move + ((last_move_diagonal? 2 : 1) * (vehicle_move_delay + config.human_delay)))
		return
	last_vehicle_move = world.time

	if(held_keycheck(user))
		var/turf/next = get_step(src, direction)
		if(!Process_Spacemove(direction) || !isturf(loc))
			return
		step(src, direction)

		if((direction & (direction - 1)) && (loc == next))		//moved diagonally
			last_move_diagonal = TRUE
		else
			last_move_diagonal = FALSE

		if(has_buckled_mobs())
			if(issimulatedturf(loc))
				var/turf/simulated/T = loc
				if(T.wet == TURF_WET_LUBE)	//Lube! Fall off!
					playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
					for(var/m in buckled_mobs)
						var/mob/living/buckled_mob = m
						buckled_mob.Weaken(5)
					unbuckle_all_mobs()
					step(src, dir)

		handle_vehicle_layer()
		handle_vehicle_offsets()
	else
		to_chat(user, "<span class='warning'>You'll need the keys in one of your hands to drive [src].</span>")


/obj/vehicle/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	handle_vehicle_layer()
	handle_vehicle_offsets()


/obj/vehicle/Bump(atom/movable/M)
	if(!spaceworthy && isspaceturf(get_turf(src)))
		return FALSE
	. = ..()
	if(auto_door_open)
		if(istype(M, /obj/machinery/door) && has_buckled_mobs())
			for(var/m in buckled_mobs)
				M.Bumped(m)

/obj/vehicle/proc/RunOver(var/mob/living/carbon/human/H)
	return		//write specifics for different vehicles


/obj/vehicle/Process_Spacemove(direction)
	if(has_gravity(src))
		return TRUE

	if(pulledby && (pulledby.loc != loc))
		return TRUE

	if(needs_gravity)
		return TRUE

	return FALSE

/obj/vehicle/space
	pressure_resistance = INFINITY
	spaceworthy = TRUE

/obj/vehicle/space/Process_Spacemove(direction)
	return TRUE