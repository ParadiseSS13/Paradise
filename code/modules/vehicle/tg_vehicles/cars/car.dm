/obj/tgvehicle/sealed/car
	layer = ABOVE_MOB_LAYER
	move_resist = MOVE_FORCE_VERY_STRONG

	///Bitflags for special behavior such as kidnapping
	var/car_traits = NONE
	///Sound file(s) to play when we drive around
	var/engine_sound = 'sound/vehicles/carrev.ogg'
	///Set this to the length of the engine sound.
	var/engine_sound_length = 2 SECONDS
	///Time it takes to break out of the car.
	var/escape_time = 6 SECONDS
	/// How long it takes to move, cars don't use the riding component similar to mechs so we handle it ourselves
	var/vehicle_move_delay = 1
	/// What sound to play if someone was forced in.
	var/forced_enter_sound
	/// How long it takes to rev (vrrm vrrm!)
	COOLDOWN_DECLARE(enginesound_cooldown)

/obj/tgvehicle/sealed/car/generate_actions()
	. = ..()
	if(!isnull(key_type))
		initialize_controller_action_type(/datum/action/vehicle/sealed/remove_key, VEHICLE_CONTROL_DRIVE)
	if(car_traits & CAN_KIDNAP)
		initialize_controller_action_type(/datum/action/vehicle/sealed/dump_kidnapped_mobs, VEHICLE_CONTROL_DRIVE)

/obj/tgvehicle/sealed/car/MouseDrop_T(mob/living/M, mob/living/user)
	if(!istype(M))
		return FALSE
	if(HAS_TRAIT(M, TRAIT_HANDS_BLOCKED) && !is_driver(M))
		return FALSE
	if((car_traits & CAN_KIDNAP) && isliving(user) && M != user)
		var/mob/living/kidnapped = M
		kidnapped.visible_message("<span class='warning'>[user] starts forcing [kidnapped] into [src]!</span>")
		mob_try_forced_enter(user, kidnapped)
	return ..()

/obj/tgvehicle/sealed/car/mob_try_exit(mob/future_pedestrian, mob/user, silent = FALSE)
	if(future_pedestrian != user || !(LAZYACCESS(occupants, future_pedestrian) & VEHICLE_CONTROL_KIDNAPPED))
		mob_exit(future_pedestrian, silent)
		return TRUE
	if(escape_time > 0)
		to_chat(user, "<span class='notice'>You push against the back of \the [src]'s trunk to try and get out.</span>")
		if(!do_after(user, escape_time, target = src))
			return FALSE
	to_chat(user, "<span class='danger'>[user] gets out of [src].</span>")
	mob_exit(future_pedestrian, silent)
	return TRUE

/obj/tgvehicle/sealed/car/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!(car_traits & CAN_KIDNAP))
		return
	to_chat(user, "<span class='notice'>You start opening [src]'s trunk.</span>")
	if(!do_after(user, 30, target = src))
		return
	if(return_amount_of_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED))
		to_chat(user, "<span class='notice'>The people stuck in [src]'s trunk all come tumbling out.</span>?")
		dump_specific_mobs(VEHICLE_CONTROL_KIDNAPPED)
		return
	to_chat(user, "<span class='notice'>It seems [src]'s trunk was empty.</span>")

/// Attempts to force a mob into the car
/obj/tgvehicle/sealed/car/proc/mob_try_forced_enter(mob/forcer, mob/kidnapped, silent = FALSE)
	if(occupant_amount() >= max_occupants)
		return FALSE
	var/atom/old_loc = loc
	var/enter_delay = get_enter_delay(kidnapped)
	if(enter_delay == 0 || do_after(forcer, enter_delay, target = kidnapped, extra_checks=CALLBACK(src, TYPE_PROC_REF(/obj/tgvehicle/sealed/car, is_car_stationary), old_loc)))
		mob_forced_enter(kidnapped, silent)
		return TRUE
	return FALSE

/// Callback proc to check for
/obj/tgvehicle/sealed/car/proc/is_car_stationary(atom/old_loc)
	return (old_loc == loc)

/// Proc called when someone is forcefully stuffedd into a car
/obj/tgvehicle/sealed/car/proc/mob_forced_enter(mob/kidnapped, silent = FALSE)
	if(!silent)
		kidnapped.visible_message("<span class='warning'>[kidnapped] is forced into \the [src]!</span>")
		if(forced_enter_sound)
			playsound(src, forced_enter_sound, 70, TRUE)
	kidnapped.forceMove(src)
	add_occupant(kidnapped, VEHICLE_CONTROL_KIDNAPPED, TRUE)

/obj/tgvehicle/sealed/car/Destroy()
	explosion(src, heavy_impact_range = 1, light_impact_range = 2, flash_range = 3, adminlog = FALSE)
	log_attack("[src] exploded due to destruction")
	return ..()

/obj/tgvehicle/sealed/car/relaymove(mob/living/user, direction)
	if(is_driver(user) && canmove && (!key_type || istype(inserted_key, key_type)))
		vehicle_move(direction)
	return TRUE

/obj/tgvehicle/sealed/car/vehicle_move(direction)
	if(!COOLDOWN_FINISHED(src, cooldown_vehicle_move))
		return FALSE
	COOLDOWN_START(src, cooldown_vehicle_move, vehicle_move_delay)

	if(COOLDOWN_FINISHED(src, enginesound_cooldown))
		COOLDOWN_START(src, enginesound_cooldown, engine_sound_length)
		playsound(get_turf(src), engine_sound, 100, TRUE)

	..()
	if(trailer)
		var/dir_to_move = get_dir(trailer.loc, loc)
		var/did_move = step(trailer, direction)
		if(did_move)
			step(trailer, dir_to_move)
		return did_move
	after_move(direction)
	return step(src, direction)
