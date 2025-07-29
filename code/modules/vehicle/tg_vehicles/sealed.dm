/obj/tgvehicle/sealed
	can_buckle = FALSE
	/// How long it takes to enter the vehice
	var/enter_delay = 2 SECONDS
	/// A special curser you may get while driving
	var/mouse_pointer
	/// Are the headlights on?
	var/headlights_toggle = FALSE
	/// How far do the headlights reach?
	var/headlight_range = 6
	/// How powerful are the headlights?
	var/headlight_power = 2
	/// Determines which occupants provide access when bumping into doors
	var/access_provider_flags = VEHICLE_CONTROL_DRIVE

/obj/tgvehicle/sealed/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_SUPERMATTER_CONSUMED, PROC_REF(on_entered_supermatter))

/obj/tgvehicle/sealed/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/climb_out)

/obj/tgvehicle/sealed/generate_action_type()
	var/datum/action/vehicle/sealed/E = ..()
	. = E
	if(istype(E))
		E.vehicle_entered_target = src

/obj/tgvehicle/sealed/MouseDrop_T(mob/living/M, mob/living/user)
	if(!istype(M))
		return ..()
	mob_try_enter(M)
	return ..()

/obj/tgvehicle/sealed/Exited(atom/movable/gone, direction)
	. = ..()
	if(ismob(gone))
		remove_occupant(gone)

// so that we can check the access of the vehicle's occupants. Ridden vehicles do this in the riding component, but these don't have that
/obj/tgvehicle/sealed/Bump(atom/A)
	. = ..()
	if(istype(A, /obj/machinery/door))
		var/obj/machinery/door/conditionalwall = A
		for(var/mob/occupant as anything in return_controllers_with_flag(access_provider_flags))
			if(!conditionalwall.allowed(occupant))
				continue
			if(conditionalwall.operating || conditionalwall.emagged || conditionalwall.foam_level)
				return
			conditionalwall.bumpopen(occupant)

/obj/tgvehicle/sealed/after_add_occupant(mob/M)
	. = ..()
	ADD_TRAIT(M, TRAIT_HANDS_BLOCKED, VEHICLE_TRAIT)

/obj/tgvehicle/sealed/after_remove_occupant(mob/M)
	. = ..()
	REMOVE_TRAIT(M, TRAIT_HANDS_BLOCKED, VEHICLE_TRAIT)

/obj/tgvehicle/sealed/proc/mob_try_enter(mob/rider)
	if(!istype(rider))
		return FALSE
	var/enter_delay = get_enter_delay(rider)
	if(enter_delay == 0)
		if(enter_checks(rider))
			mob_enter(rider)
			return TRUE
		return FALSE
	if(do_after(rider, enter_delay, target = src))
		if(!enter_checks(rider))
			return FALSE
		mob_enter(rider)
		return TRUE
	return FALSE

/// returns enter do_after delay for the given mob in ticks
/obj/tgvehicle/sealed/proc/get_enter_delay(mob/M)
	return enter_delay

/// Extra checks to perform during the do_after to enter the vehicle
/obj/tgvehicle/sealed/proc/enter_checks(mob/M)
	return occupant_amount() < max_occupants

/obj/tgvehicle/sealed/proc/mob_enter(mob/M, silent = FALSE)
	if(!istype(M))
		return FALSE
	if(!silent)
		M.visible_message("<span class='notice'>[M] climbs into \the [src]!</span>")
	M.forceMove(src)
	add_occupant(M)
	return TRUE

/obj/tgvehicle/sealed/proc/mob_try_exit(mob/M, mob/user, silent = FALSE, randomstep = FALSE)
	mob_exit(M, silent, randomstep)

/obj/tgvehicle/sealed/proc/mob_exit(mob/M, silent = FALSE, randomstep = FALSE)
	if(!istype(M))
		return FALSE
	remove_occupant(M)
	M.forceMove(exit_location(M))
	if(randomstep)
		var/turf/target_turf = get_step(exit_location(M), pick(GLOB.cardinal))
		M.throw_at(target_turf, 5, 10)

	if(!silent)
		M.visible_message("<span class='notice'>[M] drops out of \the [src]!</span>")
	return TRUE

/obj/tgvehicle/sealed/proc/exit_location(M)
	return drop_location()

/obj/tgvehicle/sealed/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(key_type && !is_key(inserted_key) && is_key(I))
		if(I.flags & NODROP || !user.drop_item() || !I.forceMove(src))
			to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		if(inserted_key) // just in case there's an invalid key
			inserted_key.forceMove(drop_location())
		inserted_key = I
		inserted_key.forceMove(src)
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/tgvehicle/sealed/proc/remove_key(mob/user)
	if(!inserted_key)
		to_chat(user, "<span class='warning'>There is no key in [src]!</span>")
		return
	if(!is_occupant(user) || !(occupants[user] & VEHICLE_CONTROL_DRIVE))
		to_chat(user, "<span class='warning'>You must be driving [src] to remove [src]'s key!</span>")
		return
	to_chat(user, "<span class='notice'>You remove [inserted_key] from [src].</span>")
	user.put_in_hands(inserted_key)
	inserted_key = null

/obj/tgvehicle/sealed/Destroy()
	dump_mobs()
	return ..()

/obj/tgvehicle/sealed/proc/dump_mobs(randomstep = TRUE)
	for(var/i in occupants)
		mob_exit(i, randomstep = randomstep)
		if(iscarbon(i))
			var/mob/living/carbon/Carbon = i
			Carbon.Stun(4 SECONDS)

/obj/tgvehicle/sealed/proc/dump_specific_mobs(flag, randomstep = TRUE)
	for(var/i in occupants)
		if(!(occupants[i] & flag))
			continue
		mob_exit(i, randomstep = randomstep)
		if(iscarbon(i))
			var/mob/living/carbon/C = i
			C.Stun(4 SECONDS)


/obj/tgvehicle/sealed/AllowDrop()
	return FALSE

/obj/tgvehicle/sealed/relaymove(mob/living/user, direction)
	if(canmove)
		vehicle_move(direction)
	return TRUE

/// Sinced sealed vehicles (cars and mechs) don't have riding components, the actual movement is handled here from [/obj/tgvehicle/sealed/proc/relaymove]
/obj/tgvehicle/sealed/proc/vehicle_move(direction)
	return FALSE

/// When we touch a crystal, kill everything inside us
/obj/tgvehicle/sealed/proc/on_entered_supermatter(atom/movable/vehicle, atom/movable/supermatter)
	SIGNAL_HANDLER // COMSIG_SUPERMATTER_CONSUMED
	for(var/mob/passenger as anything in occupants)
		if(!is_ai(passenger))
			passenger.Bump(supermatter)
