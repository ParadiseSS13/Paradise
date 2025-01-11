/**
 * /datum/component/force_door_open
 *
 * This component allows item to pry open airlock doors in the game.
 * It provides functionality for both powered and unpowered airlocks,
 * with specific conditions for opening based on the state of the airlock
 *
 */

/datum/component/force_door_open
	/// The time it takes to open the airlock when forced
	var/time_to_open
	/// Whether the airlock can be forced open while powered.
	var/can_force_open_while_powered
	/// Whether the airlock can be forced open while unpowered.
	var/can_force_open_while_unpowered
	/// The sound played when the airlock is forced open.
	var/open_sound
	/// Indicates whether no sound should be played when opening.
	var/no_sound
	/// send help
	var/mantis

/datum/component/force_door_open/Initialize(
	time_to_open = 5 SECONDS,
	can_force_open_while_powered = TRUE,
	can_force_open_while_unpowered = TRUE,
	open_sound = 'sound/machines/airlock_alien_prying.ogg',
	no_sound = FALSE,
	mantis = FALSE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.time_to_open = time_to_open
	src.can_force_open_while_powered = can_force_open_while_powered
	src.can_force_open_while_unpowered = can_force_open_while_unpowered
	src.open_sound = open_sound
	src.no_sound = no_sound
	src.mantis = mantis

	RegisterSignal(parent, COMSIG_TRY_TO_PRY_DOOR, PROC_REF(force_open_door))

/datum/component/force_door_open/proc/force_open_door(obj/item/attaked, obj/target)
	SIGNAL_HANDLER // COMSIG_TRY_TO_PRY_DOOR

	if(usr.a_intent == INTENT_HARM)
		return

	if(istype(target, /obj/machinery/door/firedoor))
		INVOKE_ASYNC(src, PROC_REF(open_unpowered_door), target) // open it
		return

	if(!istype(target, /obj/machinery/door/airlock)) // dont open blastdoors and windowdoors
		return

	var/obj/machinery/door/airlock/airlock = target

	if(airlock.allowed(usr) && airlock.arePowerSystemsOn()) // just opens
		return

	if(parent.GetComponent(/datum/component/two_handed))
		if(!HAS_TRAIT(parent, TRAIT_WIELDED) && airlock.arePowerSystemsOn())
			to_chat(usr, "<span class='warning'>You need to be wielding [parent] to do that!</span>")
			return

	// send help
	if(mantis)
		var/obj/item/melee/mantis_blade/secondblade = usr.get_inactive_hand()
		if(!istype(secondblade, /obj/item/melee/mantis_blade))
			to_chat(usr, "<span class='warning'>You need a second [parent] to pry open doors!</span>")
			return

	if(!airlock.density)
		return

	// open unpowered
	if(!airlock.arePowerSystemsOn() && can_force_open_while_unpowered)
		INVOKE_ASYNC(src, PROC_REF(open_unpowered_door), airlock)
		return

	// open powered
	if(can_force_open_while_powered)
		INVOKE_ASYNC(src, PROC_REF(open_powered_airlock), airlock)
		return

/datum/component/force_door_open/proc/open_powered_airlock(obj/machinery/door/airlock/airlock)
	if(!no_sound)
		playsound(parent, open_sound, 100, 1)

	if(do_after_once(usr, time_to_open, target = airlock))
		airlock.open(TRUE)
		if (airlock.density && !airlock.open(TRUE))
			to_chat(usr, "<span class='warning'>Despite your attempts, [airlock] refuses to open.</span>")

/datum/component/force_door_open/proc/open_unpowered_door(obj/machinery/door/door)
	door.open(TRUE)



