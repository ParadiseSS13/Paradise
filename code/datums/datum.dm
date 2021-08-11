/datum
	var/gc_destroyed //Time when this object was destroyed.
	var/list/active_timers  //for SStimer
	var/list/datum_components //for /datum/components
	/// Status traits attached to this datum
	var/list/status_traits
	var/list/comp_lookup
	var/list/list/datum/callback/signal_procs
	var/signal_enabled = FALSE
	var/var_edited = FALSE //Warranty void if seal is broken
	var/tmp/unique_datum_id = null

	/**
	  * Lazy associative list of currently active cooldowns.
	  *
	  * cooldowns [ COOLDOWN_INDEX ] = addtimer()
	  * addtimer() returns the truthy value of -1 when not stoppable, and else a truthy numeric index
	  */
	var/list/cooldowns

#ifdef REFERENCE_TRACKING
	var/running_find_references
	var/last_find_references = 0
#endif

// Default implementation of clean-up code.
// This should be overridden to remove all references pointing to the object being destroyed.
// Return the appropriate QDEL_HINT; in most cases this is QDEL_HINT_QUEUE.
/datum/proc/Destroy(force = FALSE, ...)
	SHOULD_CALL_PARENT(TRUE)
	tag = null

	var/list/timers = active_timers
	active_timers = null
	for(var/thing in timers)
		var/datum/timedevent/timer = thing
		if(timer.spent)
			continue
		qdel(timer)

	//BEGIN: ECS SHIT
	signal_enabled = FALSE

	var/list/dc = datum_components
	if(dc)
		var/all_components = dc[/datum/component]
		if(length(all_components))
			for(var/I in all_components)
				var/datum/component/C = I
				qdel(C, FALSE, TRUE)
		else
			var/datum/component/C = all_components
			qdel(C, FALSE, TRUE)
		dc.Cut()

	var/list/lookup = comp_lookup
	if(lookup)
		for(var/sig in lookup)
			var/list/comps = lookup[sig]
			if(length(comps))
				for(var/i in comps)
					var/datum/component/comp = i
					comp.UnregisterSignal(src, sig)
			else
				var/datum/component/comp = comps
				comp.UnregisterSignal(src, sig)
		comp_lookup = lookup = null

	for(var/target in signal_procs)
		UnregisterSignal(target, signal_procs[target])
	//END: ECS SHIT

	return QDEL_HINT_QUEUE

/**
  * Callback called by a timer to end an associative-list-indexed cooldown.
  *
  * Arguments:
  * * source - datum storing the cooldown
  * * index - string index storing the cooldown on the cooldowns associative list
  *
  * This sends a signal reporting the cooldown end.
  */
/proc/end_cooldown(datum/source, index)
	if(QDELETED(source))
		return
	SEND_SIGNAL(source, COMSIG_CD_STOP(index))
	TIMER_COOLDOWN_END(source, index)

/**
  * Proc used by stoppable timers to end a cooldown before the time has ran out.
  *
  * Arguments:
  * * source - datum storing the cooldown
  * * index - string index storing the cooldown on the cooldowns associative list
  *
  * This sends a signal reporting the cooldown end, passing the time left as an argument.
  */
/proc/reset_cooldown(datum/source, index)
	if(QDELETED(source))
		return
	SEND_SIGNAL(source, COMSIG_CD_RESET(index), S_TIMER_COOLDOWN_TIMELEFT(source, index))
	TIMER_COOLDOWN_END(source, index)


/datum/nothing
	// Placeholder object, used for ispath checks. Has to be defined to prevent errors, but shouldn't ever be created.
