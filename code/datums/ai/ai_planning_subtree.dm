/// A subtree is attached to a controller and is occasionally called by
/// /ai_controller/select_behaviors(). This mainly exists to act as a way to
/// subtype and modify select_behaviors() without needing to subtype the AI
/// controller itself.
/datum/ai_planning_subtree

/// Determines what behaviors should the controller try processing; if this
/// returns SUBTREE_RETURN_FINISH_PLANNING then the controller won't go through
/// the other subtrees should multiple exist in the controller.
/datum/ai_planning_subtree/proc/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	return
