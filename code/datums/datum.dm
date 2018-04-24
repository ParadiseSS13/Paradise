/datum
	var/gc_destroyed //Time when this object was destroyed.

	var/var_edited = FALSE //Warranty void if seal is broken

	var/tmp/unique_datum_id = null

#ifdef TESTING
	var/running_find_references
	var/last_find_references = 0
#endif

// Default implementation of clean-up code.
// This should be overridden to remove all references pointing to the object being destroyed.
// Return the appropriate QDEL_HINT; in most cases this is QDEL_HINT_QUEUE.
/datum/proc/Destroy(force = FALSE, ...)
	tag = null
	return QDEL_HINT_QUEUE