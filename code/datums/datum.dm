/**
  * The absolute base class for everything.
  *
  * A datum instantiated has no physical world prescence, use an atom if you want something
  * that actually lives in the world.
  *
  * Be very mindful about adding variables to this class, they are inherited by every single
  * thing in the entire game, and so you can easily cause memory usage to rise a lot with careless
  * use of variables at this level.
  */
/datum
	/**
	  * Tick count time when this object was destroyed.
	  *
	  * If this is non zero then the object has been garbage collected and is awaiting either
	  * a hard del by the GC subsystme, or to be autocollected (if it has no references)
	  */
	var/gc_destroyed
	/**
	  * Components attached to this datum.
	  *
	  * Lazy associated list in the structure of `type:component/list of components`
	  */
	var/list/datum_components
	/**
	  * Any datum registered to receive signals from this datum is in this list.
	  *
	  * Lazy associated list in the structure of `signal:registree/list of registrees`
	  */
	var/list/comp_lookup
	/**
	  * Lazy associative list of currently active cooldowns.
	  *
	  * cooldowns [ COOLDOWN_INDEX ] = addtimer()
	  * addtimer() returns the truthy value of -1 when not stoppable, and else a truthy numeric index
	  */
	var/list/cooldowns

	/// Active timers with this datum as the target.
	var/list/active_timers
	/// Status traits attached to this datum.
	var/list/status_traits

	/// Lazy associated list in the structure of `signals:proctype` that are run when the datum receives that signal.
	var/list/list/datum/callback/signal_procs
	///Is this datum capable of sending signals?
	var/signal_enabled = FALSE

	/// Has this datum been varedited by an admin?
	var/var_edited = FALSE //Warranty void if seal is broken
	/// Unique ID number (UID) of the datum, used in place of `\ref`.
	var/tmp/unique_datum_id = null

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
	TIMER_COOLDOWN_END(source, index)
	SEND_SIGNAL(source, COMSIG_CD_STOP(index))

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
	TIMER_COOLDOWN_END(source, index)
	SEND_SIGNAL(source, COMSIG_CD_RESET(index), S_TIMER_COOLDOWN_TIMELEFT(source, index))


/datum/nothing
	// Placeholder object, used for ispath checks. Has to be defined to prevent errors, but shouldn't ever be created.
