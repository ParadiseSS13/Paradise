/*
 * Hallucination manager
 * Automatically spawns a hallucination effect according to `get_spawn_location`
 *
 */

/datum/hallucination_manager
	/// Person on who this hallucination is
	var/mob/living/owner
	/// Reference to the timer that will do the first callback
	var/callback_timer
	/// How fast do we need to start our first callback
	var/callback_time = 10 SECONDS
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
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(clean_up))
	spawn_hallucination()

/datum/hallucination_manager/Destroy(force, ...)
	. = ..()
	clean_up(TRUE)

/datum/hallucination_manager/proc/clean_up(called_by_destroy = FALSE) // If anyone has a better suggestion to not go into a delete loop I'm all ears
	owner = null
	QDEL_NULL(hallucination_list)
	QDEL_NULL(images)

	if(!called_by_destroy)
		qdel(src)

/datum/hallucination_manager/proc/spawn_hallucination()
	var/turf/spawn_location = get_spawn_location()
	initial_hallucination = new (spawn_location, owner)
	hallucination_list |= initial_hallucination
	on_spawn()
	callback_timer = addtimer(CALLBACK(src, PROC_REF(first_callback)), callback_time, TIMER_DELETE_ME)

/// Returns a turf on where to spawn a hallucination
/datum/hallucination_manager/proc/get_spawn_location()
	var/list/turfs = view(5, owner)
	return pick(turfs)

/// The proc that runs when our hallucination is first spawned
/datum/hallucination_manager/proc/on_spawn()
	return

/// The first callback. By default will delete the manager
/datum/hallucination_manager/proc/first_callback()
	// If you want to have more behaviour after this callback, define a new proc on your own manager, for example `second_callback`
	qdel(src)
