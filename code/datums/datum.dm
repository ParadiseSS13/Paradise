/datum
	var/gc_destroyed //Time when this object was destroyed.
	var/list/active_timers  //for SStimer
	var/list/datum_components //for /datum/components
	/// Status traits attached to this datum
	var/list/status_traits
	var/list/comp_lookup
	var/list/list/datum/callback/signal_procs
	var/var_edited = FALSE //Warranty void if seal is broken
	var/tmp/unique_datum_id = null
	/// MD5'd version of the UID. Used for instances where we dont want to make clients aware of UIDs.
	VAR_PRIVATE/tmp/md5_unique_datum_id = null // using VAR_PRIVATE means it cant be accessed outside of the MD5_UID() proc

	/// Used by SSprocessing
	var/isprocessing = FALSE

/**
  * A cached version of our \ref
  * The brunt of \ref costs are in creating entries in the string tree (a tree of immutable strings)
  * This avoids doing that more then once per datum by ensuring ref strings always have a reference to them after they're first pulled
  */
	var/cached_ref

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

	// Close our open TGUIs
	SStgui.close_uis(src)

	var/list/timers = active_timers
	active_timers = null
	for(var/thing in timers)
		var/datum/timedevent/timer = thing
		if(timer.spent && !(timer.flags & TIMER_DELETE_ME))
			continue
		qdel(timer)

	//BEGIN: ECS SHIT
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

	_clear_signal_refs()
	//END: ECS SHIT

	return QDEL_HINT_QUEUE

/// Do not override this. This proc exists solely to be overriden by /turf. This
/// allows it to ignore clearing out signals which refer to it, in order to keep
/// those signals valid after the turf has been changed.
/datum/proc/_clear_signal_refs()
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
