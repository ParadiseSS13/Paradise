/obj/tgvehicle
	name = "generic vehicle"
	desc = "Yell at coding chat."
	icon = 'icons/obj/tgvehicles.dmi'
	icon_state = null
	appearance_flags = LONG_GLIDE
	max_integrity = 300
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 0, BOMB = 30, RAD = 0, FIRE = 60, ACID = 60)
	density = TRUE
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	buckle_lying = FALSE
	can_buckle = TRUE
	pass_flags = PASSTABLE
	COOLDOWN_DECLARE(message_cooldown)
	COOLDOWN_DECLARE(cooldown_vehicle_move)
	var/list/mob/occupants //mob = bitflags of their control level.
	///Maximum amount of passengers plus drivers
	var/max_occupants = 1
	////Maximum amount of drivers
	var/max_drivers = 1
	/// Whether the vehicle is currently able to move
	var/canmove = TRUE
	/**
	  * If the driver needs a certain item in hand (or inserted, for vehicles) to drive this. For vehicles, this must be duplicated on their riding component subtype
	  * [/datum/component/riding/var/keytype] variable because only a few specific checks are handled here with this var, and the majority of it is on the riding component
	  * Eventually the remaining checks should be moved to the component and this var removed.
	  */
	var/key_type
	///The inserted key, needed on some vehicles to start the engine
	var/obj/item/key/inserted_key
	var/list/autogrant_actions_passenger //plain list of typepaths
	var/list/autogrant_actions_controller //assoc list "[bitflag]" = list(typepaths)
	var/list/mob/occupant_actions //assoc list mob = list(type = action datum assigned to mob)
	///This vehicle will follow us when we move (like atrailer duh)
	var/obj/tgvehicle/trailer
	var/are_legs_exposed = FALSE
	/// Sound played when entering a vehicle
	var/enter_sound
	/// Sound played when exiting a vehicle
	var/exit_sound

	new_attack_chain = TRUE

/obj/tgvehicle/Initialize(mapload)
	. = ..()
	occupants = list()
	autogrant_actions_passenger = list()
	autogrant_actions_controller = list()
	occupant_actions = list()
	generate_actions()

/obj/tgvehicle/Destroy(force)
	QDEL_NULL(trailer)
	inserted_key = null
	return ..()

/obj/tgvehicle/Exited(atom/movable/gone, direction)
	if(gone == inserted_key)
		inserted_key = null
	if(exit_sound)
		playsound(src, exit_sound, 70, TRUE)
	return ..()

/obj/tgvehicle/examine(mob/user)
	. = ..()
	. += generate_integrity_message()

/// Returns a readable string of the vehicle's health for examining. Overridden by subtypes who want to be more verbose with their health messages.
/obj/tgvehicle/proc/generate_integrity_message()
	var/examine_text = ""
	var/integrity = obj_integrity / max_integrity * 100
	switch(integrity)
		if(50 to 99)
			examine_text = "It looks slightly damaged."
		if(25 to 50)
			examine_text = "It appears heavily damaged."
		if(0 to 25)
			examine_text = "<span class='warning'>It's falling apart!</span>"

	return examine_text

/obj/tgvehicle/proc/is_key(obj/item/I)
	return istype(I, key_type)

/obj/tgvehicle/proc/return_occupants()
	return length(occupants) ? occupants : list()

/obj/tgvehicle/proc/occupant_amount()
	return LAZYLEN(occupants)

/obj/tgvehicle/proc/return_amount_of_controllers_with_flag(flag)
	. = 0
	for(var/i in occupants)
		if(occupants[i] & flag)
			.++

/obj/tgvehicle/proc/return_controllers_with_flag(flag)
	RETURN_TYPE(/list/mob)
	. = list()
	for(var/i in occupants)
		if(occupants[i] & flag)
			. += i

/obj/tgvehicle/proc/return_drivers()
	return return_controllers_with_flag(VEHICLE_CONTROL_DRIVE)

/obj/tgvehicle/proc/driver_amount()
	return return_amount_of_controllers_with_flag(VEHICLE_CONTROL_DRIVE)

/obj/tgvehicle/proc/is_driver(mob/M)
	return is_occupant(M) && occupants[M] & VEHICLE_CONTROL_DRIVE

/obj/tgvehicle/proc/is_occupant(mob/M)
	return !isnull(LAZYACCESS(occupants, M))

/obj/tgvehicle/proc/add_occupant(mob/M, control_flags)
	if(!istype(M) || is_occupant(M))
		return FALSE

	LAZYSET(occupants, M, NONE)
	add_control_flags(M, control_flags)
	after_add_occupant(M)
	grant_passenger_actions(M)
	return TRUE

/obj/tgvehicle/proc/after_add_occupant(mob/M)
	auto_assign_occupant_flags(M)

/obj/tgvehicle/proc/auto_assign_occupant_flags(mob/M) //override for each type that needs it. Default is assign driver if drivers is not at max.
	if(driver_amount() < max_drivers)
		add_control_flags(M, VEHICLE_CONTROL_DRIVE)

/obj/tgvehicle/proc/remove_occupant(mob/M)
	SHOULD_CALL_PARENT(TRUE)
	if(!istype(M))
		return FALSE
	remove_control_flags(M, ALL)
	remove_passenger_actions(M)
	LAZYREMOVE(occupants, M)
	cleanup_actions_for_mob(M)
	after_remove_occupant(M)
	return TRUE

/obj/tgvehicle/proc/after_remove_occupant(mob/M)
	return

/obj/tgvehicle/relaymove(mob/living/user, direction)
	if(!canmove)
		return FALSE
	if(is_driver(user))
		return relaydrive(user, direction)
	return FALSE

/obj/tgvehicle/proc/after_move(direction)
	return

/obj/tgvehicle/proc/add_control_flags(mob/controller, flags)
	if(!is_occupant(controller) || !flags)
		return FALSE
	occupants[controller] |= flags
	for(var/i in GLOB.bitflags)
		if(flags & i)
			grant_controller_actions_by_flag(controller, i)
	return TRUE

/obj/tgvehicle/proc/remove_control_flags(mob/controller, flags)
	if(!is_occupant(controller) || !flags)
		return FALSE
	occupants[controller] &= ~flags
	for(var/i in GLOB.bitflags)
		if(flags & i)
			remove_controller_actions_by_flag(controller, i)
	return TRUE

/// To add a trailer to the vehicle in a manner that allows safe qdels
/obj/tgvehicle/proc/add_trailer(obj/vehicle/added_vehicle)
	trailer = added_vehicle
	RegisterSignal(trailer, COMSIG_PARENT_QDELETING, PROC_REF(remove_trailer))

/// To remove a trailer from the vehicle in a manner that allows safe qdels
/obj/tgvehicle/proc/remove_trailer()
	SIGNAL_HANDLER
	UnregisterSignal(trailer, COMSIG_PARENT_QDELETING)
	trailer = null

/obj/tgvehicle/Move(newloc, dir)
	// It is unfortunate, but this is the way to make it not mess up
	var/atom/old_loc = loc
	// When we do this, it will set the loc to the new loc
	. = ..()
	if(trailer && .)
		var/dir_to_move = get_dir(trailer.loc, old_loc)
		step(trailer, dir_to_move)

/obj/tgvehicle/post_unbuckle_mob(mob/living/M)
	remove_occupant(M)
	return ..()

/obj/tgvehicle/post_buckle_mob(mob/living/M)
	add_occupant(M)
	return ..()

/obj/tgvehicle/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(!key_type || is_key(inserted_key) || !is_key(I))
		return ..()
	if(user.drop_item())
		I.forceMove(src)
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		if(inserted_key)	//just in case there's an invalid key
			inserted_key.forceMove(drop_location())
		inserted_key = I
	else
		to_chat(user, "<span class='warning'>[I] seems to be stuck to your hand!</span>")

/obj/tgvehicle/AltClick(mob/user)
	if(!inserted_key)
		return ..()
	if(!is_occupant(user) || !(occupants[user] & VEHICLE_CONTROL_DRIVE))
		to_chat(user, "<span class='warning'>You must be driving the [src] to remove [src]'s key!</span>")
		return
	to_chat(user, "<span class='notice'>You remove [inserted_key] from [src].</span>")
	inserted_key.forceMove(drop_location())
	user.put_in_hands(inserted_key)
	inserted_key = null

/obj/tgvehicle/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if(!in_range(user, src) || !in_range(M, src))
		return FALSE
	return ..(M, user, FALSE)

/obj/tgvehicle/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!force && occupant_amount() >= max_occupants)
		return FALSE
	return ..()

/obj/tgvehicle/zap_act(power, zap_flags)
	zap_buckle_check(power)
	return ..()
