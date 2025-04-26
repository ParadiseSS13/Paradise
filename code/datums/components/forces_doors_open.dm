/**
 * /datum/component/forces_doors_open
 *
 * This component allows item to pry open doors.
 *
 */

/datum/component/forces_doors_open
	/// The time it takes to open the airlock when forced
	var/time_to_open
	/// Whether the airlock can be forced open while powered.
	var/can_force_open_while_powered
	/// Whether the airlock can be forced open while unpowered.
	var/can_force_open_while_unpowered
	///	Whether the firedoor can be opened.
	var/can_open_firedoors
	/// The sound played when the airlock is forced open.
	var/open_sound
	/// Indicates whether no sound should be played when opening.
	var/no_sound

/datum/component/forces_doors_open/Initialize(
	time_to_open = 5 SECONDS,
	can_force_open_while_powered = TRUE,
	can_force_open_while_unpowered = TRUE,
	can_open_firedoors = TRUE,
	open_sound = 'sound/machines/airlock_alien_prying.ogg',
	no_sound = FALSE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.time_to_open = time_to_open
	src.can_force_open_while_powered = can_force_open_while_powered
	src.can_force_open_while_unpowered = can_force_open_while_unpowered
	src.can_open_firedoors = can_open_firedoors
	src.open_sound = open_sound
	src.no_sound = no_sound

	RegisterSignal(parent, COMSIG_INTERACTING, PROC_REF(on_interact))

/datum/component/forces_doors_open/proc/on_interact(datum/source, mob/user, atom/target)
	SIGNAL_HANDLER // COMSIG_INTERACTING

	if(check_intent(user))
		return

	if(try_to_open_firedoor(target))
		return ITEM_INTERACT_COMPLETE

	if(try_to_force_open_airlock(user, target))
		return ITEM_INTERACT_COMPLETE

/// check is user in harm intent
/datum/component/forces_doors_open/proc/check_intent(mob/user)
	if(user.a_intent == INTENT_HARM)
		return TRUE

/// try to open firedoor
/datum/component/forces_doors_open/proc/try_to_open_firedoor(atom/target)
	if(can_open_firedoors && istype(target, /obj/machinery/door/firedoor)) // open firedoor and dont open blastdoors and windowdoors
		INVOKE_ASYNC(src, PROC_REF(open_unpowered_door), target)
		return TRUE

/// try to force open airlock
/datum/component/forces_doors_open/proc/try_to_force_open_airlock(mob/user, obj/machinery/door/airlock/airlock)
	if(!istype(airlock, /obj/machinery/door/airlock)) // only airlocks have arePowerSystemsOn()
		return

	if(SEND_SIGNAL(parent, COMSIG_TWOHANDED_WIELDED_TRY_WIELD_INTERACT) && airlock.arePowerSystemsOn())
		to_chat(user, "<span class='warning'>You need to be wielding [parent] to do that!</span>")
		return TRUE

	if(!airlock.density)
		return TRUE

	// open unpowered
	if(can_force_open_while_unpowered && !airlock.arePowerSystemsOn())
		INVOKE_ASYNC(src, PROC_REF(open_unpowered_door), airlock)
		return TRUE

	// open powered
	if(can_force_open_while_powered)
		INVOKE_ASYNC(src, PROC_REF(open_powered_airlock), airlock, user)
		return TRUE

/// open airlock with delay
/datum/component/forces_doors_open/proc/open_powered_airlock(obj/machinery/door/airlock/airlock, mob/user)
	if(!no_sound)
		playsound(parent, open_sound, 100, 1)

	if(do_after_once(user, time_to_open, target = airlock, attempt_cancel_message = "You decide to stop prying [airlock] with [parent]."))
		if(airlock.open(TRUE))
			return // successfully opened

		// opening failed
		if(airlock.density)
			to_chat(user, "<span class='warning'>Despite your attempts, [airlock] refuses to open.</span>")

/// open door without checks
/datum/component/forces_doors_open/proc/open_unpowered_door(obj/machinery/door/door)
	door.open(TRUE)

/// subtype for mantis blades
/datum/component/forces_doors_open/mantis/on_interact(datum/source, mob/user, atom/target)
	if(check_intent(user))
		return

	if(try_to_open_firedoor(target))
		return ITEM_INTERACT_COMPLETE

	var/obj/item/melee/mantis_blade/secondblade = user.get_inactive_hand()
	if(!istype(secondblade, /obj/item/melee/mantis_blade))
		to_chat(user, "<span class='warning'>You need a second [parent] to pry open doors!</span>")
		return ITEM_INTERACT_COMPLETE

	if(try_to_force_open_airlock(user, target))
		return ITEM_INTERACT_COMPLETE
