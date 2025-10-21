/// A subtree is attached to a controller and is occasionally called by
/// /ai_controller/select_behaviors(). This mainly exists to act as a way to
/// subtype and modify select_behaviors() without needing to subtype the AI
/// controller itself.
/datum/ai_planning_subtree
	/// A list of typepaths of "operational datums" (elements/components) we
	/// absolutely NEED to run. Checked in unit tests, as well as be a nice
	/// reminder to developers that such a thing might be needed. Note that in
	/// the Attach/Inititalize/New (or any future equivalent for these procs),
	/// you will need to add the trait TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM
	/// to the mob in question in order for unit tests to succeed. This will
	/// break obviously enough if you don't do this and declare the required
	/// datum here however.
	var/list/operational_datums = null

/// Determines what behaviors should the controller try processing; if this
/// returns SUBTREE_RETURN_FINISH_PLANNING then the controller won't go through
/// the other subtrees should multiple exist in the controller.
/datum/ai_planning_subtree/proc/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	return
