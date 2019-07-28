
/obj/vehicle
	name = "vehicle"
	desc = "A basic vehicle, vroom"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "scooter"
	density = 1
	anchored = 0
	can_buckle = 1
	buckle_lying = 0
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0)
	var/keytype = null //item typepath, if non-null an item of this type is needed in your hands to drive this vehicle
	var/next_vehicle_move = 0 //used for move delays
	var/vehicle_move_delay = 2 //tick delay between movements, lower = faster, higher = slower
	var/auto_door_open = TRUE
	var/needs_gravity = 0//To allow non-space vehicles to move in no gravity or not, mostly for adminbus
	//Pixels
	var/generic_pixel_x = 0 //All dirs show this pixel_x for the driver
	var/generic_pixel_y = 0 //All dirs shwo this pixel_y for the driver
	var/spaceworthy = FALSE


/obj/vehicle/New()
	..()
	handle_vehicle_layer()


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
	if(buckled_mob)
		buckled_mob.dir = dir
		buckled_mob.pixel_x = generic_pixel_x
		buckled_mob.pixel_y = generic_pixel_y


/obj/vehicle/update_icon()
	return



//KEYS
/obj/vehicle/proc/keycheck(mob/user)
	if(keytype)
		if(istype(user.l_hand, keytype) || istype(user.r_hand, keytype))
			return 1
	else
		return 1
	return 0

/obj/item/key
	name = "key"
	desc = "A small grey key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "key"
	w_class = WEIGHT_CLASS_TINY


//BUCKLE HOOKS
/obj/vehicle/unbuckle_mob(force = 0)
	if(buckled_mob)
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
	M.loc = get_turf(src)
	..()
	handle_vehicle_offsets()


/obj/vehicle/bullet_act(obj/item/projectile/Proj)
	if(buckled_mob)
		buckled_mob.bullet_act(Proj)

//MOVEMENT
/obj/vehicle/relaymove(mob/user, direction)
	if(user.incapacitated())
		unbuckle_mob()

	if(keycheck(user))
		if(!Process_Spacemove(direction) || world.time < next_vehicle_move || !isturf(loc))			return
		next_vehicle_move = world.time + vehicle_move_delay

		step(src, direction)

		if(buckled_mob)
			if(buckled_mob.loc != loc)
				buckled_mob.buckled = null //Temporary, so Move() succeeds.
				buckled_mob.buckled = src //Restoring

			if(istype(src.loc, /turf/simulated))
				var/turf/simulated/T = src.loc
				if(T.wet == TURF_WET_LUBE)	//Lube! Fall off!
					playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
					buckled_mob.Stun(7)
					buckled_mob.Weaken(7)
					unbuckle_mob()
					step(src, dir)

		handle_vehicle_layer()
		handle_vehicle_offsets()
	else
		to_chat(user, "<span class='notice'>You'll need the keys in one of your hands to drive \the [name].</span>")


/obj/vehicle/Move(NewLoc,Dir=0,step_x=0,step_y=0)
	..()
	handle_vehicle_layer()
	handle_vehicle_offsets()


/obj/vehicle/attackby(obj/item/I, mob/user, params)
	if(keytype && istype(I, keytype))
		to_chat(user, "Hold [I] in one of your hands while you drive \the [name].")


/obj/vehicle/Bump(atom/movable/M)
	if(!spaceworthy && isspaceturf(get_turf(src)))
		return 0
	. = ..()
	if(auto_door_open)
		if(istype(M, /obj/machinery/door) && buckled_mob)
			M.Bumped(buckled_mob)

/obj/vehicle/proc/RunOver(var/mob/living/carbon/human/H)
	return		//write specifics for different vehicles


/obj/vehicle/Process_Spacemove(direction)
	if(has_gravity(src))
		return 1

	if(pulledby && pulledby != buckled_mob)	// no pulling the vehicle you're driving through space!
		return 1

	if(needs_gravity)
		return 1

	return 0

/obj/vehicle/space
	pressure_resistance = INFINITY
	spaceworthy = TRUE

/obj/vehicle/space/Process_Spacemove(direction)
	return 1
