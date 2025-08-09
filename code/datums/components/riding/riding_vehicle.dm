// For any /obj/tgvehicle's that can be ridden

/// For making timers not accidentally skip an extra tick.
#define EPSILON (world.tick_lag * 0.1)

/datum/component/riding/vehicle/Initialize(mob/living/riding_mob, force = FALSE, ride_check_flags = (RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS), potion_boost = FALSE)
	if(!istgvehicle(parent))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/riding/vehicle/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_RIDDEN_DRIVER_MOVE, PROC_REF(driver_move))

/datum/component/riding/vehicle/driver_move(atom/movable/movable_parent, mob/living/user, direction)
	if(!COOLDOWN_FINISHED(src, vehicle_move_cooldown))
		return COMPONENT_DRIVER_BLOCK_MOVE
	var/obj/tgvehicle/vehicle_parent = parent

	if(!keycheck(user))
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>[vehicle_parent] has no key inserted!</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(user.incapacitated())
		if(ride_check_flags & UNBUCKLE_DISABLED_RIDER)
			INVOKE_ASYNC(vehicle_parent, TYPE_PROC_REF(/atom/movable, unbuckle_mob), user, TRUE)
			user.visible_message("<span class='danger'>[user] falls off [vehicle_parent].</span>",\
			"<span class='danger'>You slip off [vehicle_parent] as your body slumps!</span>")
			user.Stun(3 SECONDS)

		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>You cannot operate [vehicle_parent] right now!</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(ride_check_flags & RIDER_NEEDS_LEGS && HAS_TRAIT(user, TRAIT_FLOORED))
		if(ride_check_flags & UNBUCKLE_DISABLED_RIDER)
			INVOKE_ASYNC(vehicle_parent, TYPE_PROC_REF(/atom/movable, unbuckle_mob), user, TRUE)
			user.visible_message("<span class='danger'>[user] falls off [vehicle_parent].</span>",\
			"<span class='danger'>You fall off [vehicle_parent] while trying to operate it while unable to stand!</span>")
			user.Stun(3 SECONDS)

		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>You can't seem to manage that while unable to stand up enough to move [vehicle_parent]...</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(ride_check_flags & RIDER_NEEDS_ARMS && HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		if(ride_check_flags & UNBUCKLE_DISABLED_RIDER)
			INVOKE_ASYNC(vehicle_parent, TYPE_PROC_REF(/atom/movable, unbuckle_mob), user, TRUE)
			user.visible_message("<span class='danger'>[user] falls off [vehicle_parent].</span>",\
			"<span class='danger'>You fall off [vehicle_parent] while trying to operate it without being able to hold on!</span>")
			user.Stun(3 SECONDS)

		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>You can't seem to hold onto [vehicle_parent] to move it...</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	handle_ride(user, direction)
	return ..()

/// This handles the actual movement for vehicles once [/datum/component/riding/vehicle/proc/driver_move] has given us the green light
/datum/component/riding/vehicle/proc/handle_ride(mob/user, direction)
	var/atom/movable/movable_parent = parent

	var/turf/next = get_step(movable_parent, direction)
	var/turf/current = get_turf(movable_parent)
	if(!istype(next) || !istype(current))
		return //not happening.
	if(!turf_check(next, current))
		to_chat(user, "<span class='warning'>[movable_parent] cannot go onto [next]!</span>")
		return
	if(GLOB.move_manager.processing_on(movable_parent, SSspacedrift) && !override_allow_spacemove)
		return
	if(!isturf(movable_parent.loc))
		return

	step(movable_parent, direction)
	last_move_diagonal = ((direction & (direction - 1)) && (movable_parent.loc == next))
	if(last_move_diagonal)
		movable_parent.set_glide_size(MOVEMENT_ADJUSTED_GLIDE_SIZE(vehicle_move_delay, 1) * 0.5)
		COOLDOWN_START(src, vehicle_move_cooldown, 2 * vehicle_move_delay - EPSILON)
	else
		movable_parent.set_glide_size(MOVEMENT_ADJUSTED_GLIDE_SIZE(vehicle_move_delay, 1))
		COOLDOWN_START(src, vehicle_move_cooldown, vehicle_move_delay - EPSILON)

	if(QDELETED(src))
		return
	handle_vehicle_layer(movable_parent.dir)
	handle_vehicle_offsets(movable_parent.dir)
	return TRUE

/datum/component/riding/vehicle/scooter
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/scooter/handle_specials(mob/living/riding_mob)
	. = ..()
	if(isrobot(riding_mob))
		set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0), TEXT_SOUTH = list(0), TEXT_EAST = list(0), TEXT_WEST = list(2)))
	else
		set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(2), TEXT_SOUTH = list(-2), TEXT_EAST = list(0), TEXT_WEST = list(2)))

/datum/component/riding/vehicle/scooter/skateboard
	vehicle_move_delay = 1.5
	ride_check_flags = RIDER_NEEDS_LEGS | UNBUCKLE_DISABLED_RIDER | RIDER_CARBON_OR_SILICON_NO_LARGE_MOBS
	///If TRUE, the vehicle will be slower (but safer) to ride on walk intent.
	var/can_slow_down = TRUE

/datum/component/riding/vehicle/scooter/skateboard/handle_specials()
	. = ..()
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/datum/component/riding/vehicle/scooter/skateboard/RegisterWithParent()
	. = ..()
	if(can_slow_down)
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	var/obj/tgvehicle/scooter/skateboard/board = parent
	if(istype(board))
		board.can_slow_down = can_slow_down

/datum/component/riding/vehicle/scooter/skateboard/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER //COMSIG_PARENT_EXAMINE
	examine_list += "<span class='notice'>Going nice and slow at walk speed will prevent crashing into things.</span>"

/datum/component/riding/vehicle/scooter/skateboard/vehicle_mob_buckle(datum/source, mob/living/rider, force = FALSE)
	. = ..()
	if(can_slow_down)
		RegisterSignal(rider, COMSIG_MOVE_INTENT_TOGGLED, PROC_REF(toggle_move_delay))
		toggle_move_delay(rider)
	RegisterSignal(rider, COMSIG_ATOM_BULLET_ACT, PROC_REF(check_knockoff))

/datum/component/riding/vehicle/scooter/skateboard/handle_unbuckle(mob/living/rider)
	. = ..()
	if(can_slow_down)
		toggle_move_delay(rider)
		UnregisterSignal(rider, COMSIG_MOVE_INTENT_TOGGLED)
	UnregisterSignal(rider, COMSIG_ATOM_BULLET_ACT)

/datum/component/riding/vehicle/scooter/skateboard/proc/toggle_move_delay(mob/living/rider)
	SIGNAL_HANDLER // COMSIG_MOVE_INTENT_TOGGLED
	vehicle_move_delay = initial(vehicle_move_delay)
	if(rider.m_intent == MOVE_INTENT_WALK)
		vehicle_move_delay += 0.6

/datum/component/riding/vehicle/scooter/skateboard/proc/check_knockoff(datum/source, obj/item/projectile)
	SIGNAL_HANDLER // COMSIG_ATOM_BULLET_ACT
	if(!istype(parent, /obj/tgvehicle/scooter/skateboard))
		return
	var/obj/tgvehicle/scooter/skateboard/S = parent
	for(var/mob/living/L in S.return_occupants()) // Only one on a skateboard unless an admin var edits it. If an admin var edits it, that is on them.
		if((L.getStaminaLoss() >= 60 || L.health <= 40) && !L.absorb_stun(0)) // Only injured people can be shot off. Hulks and people on stimulants can not be shot off.
			S.unbuckle_mob(L)
			L.KnockDown(2 SECONDS)
			L.visible_message("<span class='warning'>[L] gets shot off [S] by [projectile]!</span>",
				"<span class='warning'>You get shot off [S] by [projectile]!</span>")

/datum/component/riding/vehicle/scooter/skateboard/pro
	vehicle_move_delay = 1

/// This one lets the rider ignore gravity, move in zero g and so on, but only on ground turfs or at most one z-level above them.
/datum/component/riding/vehicle/scooter/skateboard/hover
	vehicle_move_delay = 1
	override_allow_spacemove = TRUE

/datum/component/riding/vehicle/scooter/skateboard/hover/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_HAS_GRAVITY, PROC_REF(check_grav))
	RegisterSignal(parent, COMSIG_MOVABLE_SPACEMOVE, PROC_REF(check_drifting))
	hover_check()

///Makes sure that the vehicle is grav-less if capable of zero-g movement. Forced gravity will honestly screw this.
/datum/component/riding/vehicle/scooter/skateboard/hover/proc/check_grav(datum/source, turf/gravity_turf, list/gravs)
	SIGNAL_HANDLER //COMSIG_ATOM_HAS_GRAVITY
	if(override_allow_spacemove)
		gravs += 0

///Makes sure the vehicle isn't drifting while it can be maneuvered.
/datum/component/riding/vehicle/scooter/skateboard/hover/proc/check_drifting(datum/source, movement_dir, continuous_move)
	SIGNAL_HANDLER //COMSIG_MOVABLE_SPACEMOVE
	if(override_allow_spacemove)
		return COMSIG_MOVABLE_STOP_SPACEMOVE

/datum/component/riding/vehicle/scooter/skateboard/hover/vehicle_moved(atom/movable/source, oldloc, dir, forced)
	. = ..()
	hover_check(TRUE)

///Makes sure that the hoverboard can move in zero-g in (open) space but only there's a ground turf on the z-level below.
/datum/component/riding/vehicle/scooter/skateboard/hover/proc/hover_check(is_moving = FALSE)
	var/atom/movable/movable = parent
	if(!isspaceturf(movable.loc) || locate(/obj/structure/railing) in range(1, movable.loc)) //If you can't grind the faragus rails, why live?
		override_allow_spacemove = TRUE
		return
	override_allow_spacemove = FALSE

/datum/component/riding/vehicle/clowncar
	vehicle_move_delay = 0.6
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS

#undef EPSILON
