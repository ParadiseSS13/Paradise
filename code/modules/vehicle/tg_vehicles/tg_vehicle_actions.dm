//VEHICLE DEFAULT HANDLING

/**
 * ## generate_actions
 *
 * You override this with initialize_passenger_action_type and initialize_controller_action_type calls
 * To give passengers actions when they enter the vehicle.
 * Read the documentation on the aforementioned procs to learn the difference
 */
/obj/tgvehicle/proc/generate_actions()
	return

/**
 * ## generate_action_type
 *
 * A small proc to properly set up each action path.
 * args:
 * * actiontype: typepath of the action the proc sets up.
 * returns created and set up action instance
 */
/obj/tgvehicle/proc/generate_action_type(actiontype)
	var/datum/action/vehicle/A = new actiontype
	if(!istype(A))
		return
	A.vehicle_target = src
	return A

/**
 * ## initialize_passenger_action_type
 *
 * Gives any passenger that enters the mech this action.
 * They will lose it when they disembark.
 * args:
 * * actiontype: typepath of the action you want to give occupants.
 */
/obj/tgvehicle/proc/initialize_passenger_action_type(actiontype)
	autogrant_actions_passenger += actiontype
	for(var/i in occupants)
		grant_passenger_actions(i) //refresh

/**
 * ## destroy_passenger_action_type
 *
 * Removes this action type from all occupants and stops autogranting it
 * args:
 * * actiontype: typepath of the action you want to remove from occupants and the autogrant list.
 */
/obj/tgvehicle/proc/destroy_passenger_action_type(actiontype)
	autogrant_actions_passenger -= actiontype
	for(var/i in occupants)
		remove_action_type_from_mob(actiontype, i)

/**
 * ## initialize_controller_action_type
 *
 * Gives any passenger that enters the vehicle this action... IF they have the correct vehicle control flag.
 * This is used so passengers cannot press buttons only drivers should have, for example.
 * args:
 * * actiontype: typepath of the action you want to give occupants.
 */
/obj/tgvehicle/proc/initialize_controller_action_type(actiontype, control_flag)
	LAZYINITLIST(autogrant_actions_controller["[control_flag]"])
	autogrant_actions_controller["[control_flag]"] += actiontype
	for(var/i in occupants)
		grant_controller_actions(i) //refresh

/**
 * ## destroy_controller_action_type
 *
 * As the name implies, removes the actiontype from autogrant and removes it from all occupants
 * args:
 * * actiontype: typepath of the action you want to remove from occupants and autogrant.
 */
/obj/tgvehicle/proc/destroy_controller_action_type(actiontype, control_flag)
	autogrant_actions_controller["[control_flag]"] -= actiontype
	UNSETEMPTY(autogrant_actions_controller["[control_flag]"])
	for(var/i in occupants)
		remove_action_type_from_mob(actiontype, i)

/**
 * ## grant_action_type_to_mob
 *
 * As on the tin, it does all the annoying small stuff and sanity needed
 * to GRANT an action to a mob.
 * args:
 * * actiontype: typepath of the action you want to give to grant_to.
 * * grant_to: the mob we're giving actiontype to
 * returns TRUE if successfully granted
 */
/obj/tgvehicle/proc/grant_action_type_to_mob(actiontype, mob/grant_to)
	if(isnull(LAZYACCESS(occupants, grant_to)) || !actiontype)
		return FALSE
	LAZYINITLIST(occupant_actions[grant_to])
	if(occupant_actions[grant_to][actiontype])
		return TRUE
	var/datum/action/action = generate_action_type(actiontype)
	action.Grant(grant_to)
	occupant_actions[grant_to][action.type] = action
	return TRUE

/**
 * ## remove_action_type_from_mob
 *
 * As on the tin, it does all the annoying small stuff and sanity needed
 * to REMOVE an action to a mob.
 * args:
 * * actiontype: typepath of the action you want to give to grant_to.
 * * take_from: the mob we're taking actiontype to
 * returns TRUE if successfully removed
 */
/obj/tgvehicle/proc/remove_action_type_from_mob(actiontype, mob/take_from)
	if(isnull(LAZYACCESS(occupants, take_from)) || !actiontype)
		return FALSE
	LAZYINITLIST(occupant_actions[take_from])
	if(occupant_actions[take_from][actiontype])
		var/datum/action/action = occupant_actions[take_from][actiontype]
		// Actions don't dissipate on removal, they just sit around assuming they'll be reusued
		// Gotta qdel
		qdel(action)
		occupant_actions[take_from] -= actiontype
	return TRUE

/**
 * ## grant_passenger_actions
 *
 * Called on every passenger that enters the vehicle, goes through the list of actions it needs to give...
 * and does that.
 * args:
 * * grant_to: mob that needs to get every action the vehicle grants
 */
/obj/tgvehicle/proc/grant_passenger_actions(mob/grant_to)
	for(var/v in autogrant_actions_passenger)
		grant_action_type_to_mob(v, grant_to)

/**
 * ## remove_passenger_actions
 *
 * Called on every passenger that exits the vehicle, goes through the list of actions it needs to remove...
 * and does that.
 * args:
 * * take_from: mob that needs to get every action the vehicle grants
 */
/obj/tgvehicle/proc/remove_passenger_actions(mob/take_from)
	for(var/v in autogrant_actions_passenger)
		remove_action_type_from_mob(v, take_from)

/obj/tgvehicle/proc/grant_controller_actions(mob/M)
	if(!istype(M) || isnull(LAZYACCESS(occupants, M)))
		return FALSE
	for(var/i in GLOB.bitflags)
		if(occupants[M] & i)
			grant_controller_actions_by_flag(M, i)
	return TRUE

/obj/tgvehicle/proc/remove_controller_actions(mob/M)
	if(!istype(M) || isnull(LAZYACCESS(occupants, M)))
		return FALSE
	for(var/i in GLOB.bitflags)
		remove_controller_actions_by_flag(M, i)
	return TRUE

/obj/tgvehicle/proc/grant_controller_actions_by_flag(mob/M, flag)
	if(!istype(M))
		return FALSE
	for(var/v in autogrant_actions_controller["[flag]"])
		grant_action_type_to_mob(v, M)
	return TRUE

/obj/tgvehicle/proc/remove_controller_actions_by_flag(mob/M, flag)
	if(!istype(M))
		return FALSE
	for(var/v in autogrant_actions_controller["[flag]"])
		remove_action_type_from_mob(v, M)
	return TRUE

/obj/tgvehicle/proc/cleanup_actions_for_mob(mob/M)
	if(!istype(M))
		return FALSE
	for(var/path in occupant_actions[M])
		stack_trace("Leftover action type [path] in vehicle type [type] for mob type [M.type] - THIS SHOULD NOT BE HAPPENING!")
		var/datum/action/action = occupant_actions[M][path]
		action.Remove(M)
		occupant_actions[M] -= path
	occupant_actions -= M
	return TRUE

/***************** ACTION DATUMS *****************/

/datum/action/vehicle
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS
	button_background_icon = 'icons/mob/actions/actions_vehicle.dmi'
	button_overlay_icon = 'icons/mob/actions/actions_vehicle.dmi'
	button_overlay_icon_state = "vehicle_eject"
	var/obj/tgvehicle/vehicle_target
	var/obj/tgvehicle/vehicle_ridden_target

/datum/action/vehicle/Destroy()
	vehicle_target = null
	return ..()

/datum/action/vehicle/scooter/skateboard/ollie
	name = "Ollie"
	desc = "Get some air! Land on a table or fence to do a gnarly grind."
	button_overlay_icon_state = "skateboard_ollie"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/vehicle/scooter/skateboard/ollie/Trigger(left_click)
	. = ..()
	if(!.)
		return
	var/obj/tgvehicle/scooter/skateboard/vehicle = vehicle_target
	if(vehicle.grinding)
		return
	var/mob/living/rider = owner
	var/turf/landing_turf = get_step(vehicle.loc, vehicle.dir)
	rider.adjustStaminaLoss(vehicle.instability * 0.75)
	if(rider.getStaminaLoss() >= 100)
		playsound(src, 'sound/effects/bang.ogg', 20, TRUE)
		vehicle.unbuckle_mob(rider)
		rider.throw_at(landing_turf, 2, 2)
		rider.Weaken(5 SECONDS)
		vehicle.visible_message("<span class='danger'>[rider] misses the landing and falls on [rider.p_their()] face!</span>")
		return
	if((locate(/obj/structure/table) in landing_turf) || (locate(/obj/structure/railing) in landing_turf))
		vehicle.grinding = TRUE
		vehicle.icon_state = "[initial(vehicle.icon_state)]-grind"
		addtimer(CALLBACK(vehicle, TYPE_PROC_REF(/obj/tgvehicle/scooter/skateboard, grind)), 2)
	for(var/obj/machinery/atmospherics/P in landing_turf.contents)
		if(P.invisibility == 0 && (landing_turf.layer == PLATING_LAYER || P.layer >= GAS_PIPE_VISIBLE_LAYER))
			vehicle.grinding = TRUE
			vehicle.icon_state = "[initial(vehicle.icon_state)]-grind"
			addtimer(CALLBACK(vehicle, TYPE_PROC_REF(/obj/tgvehicle/scooter/skateboard, grind)), 2)
			break
	rider.spin(spintime = 4, speed = 1)
	animate(rider, pixel_y = -6, time = 4)
	animate(vehicle, pixel_y = -6, time = 3)
	playsound(vehicle, 'sound/effects/skateboard_ollie.ogg', 50, TRUE)
	var/old_pass = rider.pass_flags
	var/old_v_pass = vehicle.pass_flags
	rider.pass_flags |= PASSTABLE | PASSFENCE
	vehicle.pass_flags |= PASSTABLE | PASSFENCE

	rider.Move(landing_turf, vehicle_target.dir)
	rider.pass_flags = old_pass
	vehicle.pass_flags = old_v_pass

/datum/action/vehicle/scooter/skateboard/kickflip
	name = "Kickflip"
	desc = "Kick your board up and catch it."
	button_overlay_icon_state = "skateboard_ollie"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/vehicle/scooter/skateboard/kickflip/Trigger(left_click)
	var/obj/tgvehicle/scooter/skateboard/board = vehicle_target
	var/mob/living/rider = owner

	rider.adjustStaminaLoss(board.instability)
	if(rider.getStaminaLoss() >= 100)
		playsound(src, 'sound/effects/bang.ogg', 20, vary = TRUE)
		board.unbuckle_mob(rider)
		rider.Weaken(5 SECONDS)
		if(prob(15))
			rider.visible_message(
				"<span class='danger'>[rider] misses the landing and falls on [rider.p_their()] face!</span>",
				"<span class='userdanger'>You smack against the board, hard.</span>",
			)
			rider.emote("scream")
			rider.adjustBruteLoss(10)  // thats gonna leave a mark
			return
		rider.visible_message(
			"<span class='danger'>[rider] misses the landing and falls on [rider.p_their()] face!</span>",
			"<span class='userdanger'>You fall flat onto the board!</span>",
		)
		return

	rider.visible_message(
		"<span class='notice'>[rider] does a sick kickflip and catches [rider.p_their()] board in midair.</span>",
		"<span class='notice'>You do a sick kickflip, catching the board in midair! Stylish.</span>",
	)
	playsound(board, 'sound/effects/skateboard_ollie.ogg', 50, vary = TRUE)
	rider.spin(spintime = 4, speed = 1)
	animate(rider, pixel_y = -6, time = 0.4 SECONDS)
	animate(board, pixel_y = -6, time = 0.3 SECONDS)
	board.unbuckle_mob(rider)
	addtimer(CALLBACK(board, TYPE_PROC_REF(/obj/tgvehicle/scooter/skateboard, pick_up_board), rider), 0.5 SECONDS)  // so the board can still handle "picking it up"
