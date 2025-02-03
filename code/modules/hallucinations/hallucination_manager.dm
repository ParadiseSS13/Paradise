/*
 * Hallucination manager
 * Automatically spawns a hallucination effect according to `get_spawn_location` and `initial_hallucination`
 * By default invokes a 10 second trigger. By default that trigger will delete the manager and thus the hallucination
 */

/datum/hallucination_manager
	/// Person on who this hallucination is
	var/mob/living/owner
	/// Reference to the timer that will do the first trigger
	var/trigger_timer
	/// How fast do we need to start our first trigger
	var/trigger_time = 10 SECONDS
	/// A list with all of our hallucinations
	var/list/hallucination_list = list()
	/// A list with any images that we made separately from our hallucinations
	var/list/images = list()
	/// The first hallucination that we spawn. Also doubles as a reference to our hallucination
	var/obj/effect/hallucination/no_delete/initial_hallucination

// `ignore_this_argument` is here because there are still old hallucinations which require a location passed
/datum/hallucination_manager/New(turf/ignore_this_argument, mob/living/hallucinator)
	. = ..()
	owner = hallucinator
	if(QDELETED(owner))
		qdel(src)
		return
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(signal_qdel))
	spawn_hallucination()

/datum/hallucination_manager/Destroy(force)
	. = ..()
	owner = null
	QDEL_NULL(hallucination_list)
	QDEL_NULL(images)

/datum/hallucination_manager/proc/spawn_hallucination()
	var/turf/spawn_location = get_spawn_location()
	if(!spawn_location)
		return
	if(initial_hallucination)
		initial_hallucination = new initial_hallucination(spawn_location, owner)
		hallucination_list |= initial_hallucination
	on_spawn()
	trigger_timer = addtimer(CALLBACK(src, PROC_REF(on_trigger)), trigger_time, TIMER_DELETE_ME)

/// Returns a turf on where to spawn a hallucination
/datum/hallucination_manager/proc/get_spawn_location()
	var/list/turfs = view(5, owner)
	return pick(turfs)

/// The proc that runs when our hallucination is first spawned
/datum/hallucination_manager/proc/on_spawn()
	return

/// Trigger. By default will delete the manager
/datum/hallucination_manager/proc/on_trigger()
	// If you want to have more behaviour after this callback, define a new proc on your own manager
	qdel(src)
