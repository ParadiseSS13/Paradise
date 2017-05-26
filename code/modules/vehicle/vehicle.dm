
/obj/vehicle
	name = "vehicle"
	desc = "A basic vehicle, vroom"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "fuckyou"
	density = 1
	anchored = 0
	can_buckle = 1
	buckle_lying = 0
	var/auto_door_open = TRUE
	var/needs_gravity = 0//To allow non-space vehicles to move in no gravity or not, mostly for adminbus
	var/spaceworthy = FALSE

	var/datum/riding/riding_datum = null

/obj/vehicle/update_icon()
	return

/obj/item/key
	name = "key"
	desc = "A small grey key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "key"
	w_class = 1

/obj/vehicle/Destroy()
	QDEL_NULL(riding_datum)
	return ..()

//BUCKLE HOOKS
/obj/vehicle/unbuckle_mob(force = 0)
	riding_datum.restore_position(buckled_mob)
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
	riding_datum.handle_vehicle_offsets()
	riding_datum.ridden = src

/obj/vehicle/bullet_act(obj/item/projectile/Proj)
	if(buckled_mob)
		buckled_mob.bullet_act(Proj)

//MOVEMENT
/obj/vehicle/relaymove(mob/user, direction)
	riding_datum.handle_ride(user, direction)


/obj/vehicle/Moved()
	..()
	riding_datum.handle_vehicle_layer()
	riding_datum.handle_vehicle_offsets()



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