/**
 * An objective holder for minds, antag datums, and teams.
 */

/datum/objective_holder
	/// Our list of current objectives
	VAR_PRIVATE/list/datum/objective/objectives = list()
	/// Who do we belong to [mind, antagonist, team]
	VAR_PRIVATE/datum/objective_owner
	/// A list of strings which contain [targets][/datum/objective/var/target] of the antagonist's objectives. Used to prevent duplicate objectives.
	VAR_PRIVATE/list/assigned_targets = list()
	/// A callback invoked when a new objective is added. This is required because sometimes objectives are added directly without going through objective_owner. Not currently used.
	VAR_PRIVATE/datum/callback/on_add_callback
	/// A callback invoked when a new objective is added. This is required because sometimes objectives are removed directly without going through objective_owner (EX: replace_objective(), clear()). Not currently used.
	VAR_PRIVATE/datum/callback/on_remove_callback

/datum/objective_holder/New(new_owner)
	. = ..()
	objective_owner = new_owner

/datum/objective_holder/Destroy(force, ...)
	clear()
	objective_owner = null
	QDEL_NULL(on_add_callback)
	QDEL_NULL(on_remove_callback)
	return ..()

/**
 * Clear all objectives of a certain type
 * * checktype - The type to check, if null, remoe all objectives.
 */
/datum/objective_holder/proc/clear(check_type)
	for(var/datum/objective/Objective as anything in objectives)
		if(check_type && !istype(Objective, check_type))
			return
		remove_objective(Objective)
		. = TRUE

/**
 * Sets the callbacks, not on new because that can be irreliable for subtypes.
 */
/datum/objective_holder/proc/set_callbacks(_on_add_callback, _on_remove_callback)
	on_add_callback = _on_add_callback
	on_remove_callback = _on_remove_callback

/**
 * Do we have any objectives
 */
/datum/objective_holder/proc/has_objectives()
	return length(objectives) > 0

/**
 * Get all of the objectives we own
 */
/datum/objective_holder/proc/get_objectives()
	return objectives

/**
 * Get all of our targets
 */
/datum/objective_holder/proc/get_targets()
	return assigned_targets

/**
 * Replace old_objective with new_objective
 */
/datum/objective_holder/proc/replace_objective(datum/objective/old_objective, datum/objective/new_objective, datum/original_target_department, list/original_steal_list)
	new_objective.target_department = original_target_department
	new_objective.steal_list = original_steal_list
	new_objective = add_objective(new_objective, add_to_list = FALSE)
	// Replace where the old objective was, with the new one
	objectives.Insert(objectives.Find(old_objective), new_objective)
	remove_objective(old_objective)

/**
 * Add an objective.
 *
 * * Objective - The objective to add [/datum/objective, path]
 * * _explanation_text - Optional, will assign this text to the objective
 * * target_override - A target override, will prevent finding a target
 * * add_to_list - Do we add the new objective to our list? Or will it be handled elsewhere (like replace_objective). Should not be set to false outside of this file.
 */

/datum/objective_holder/proc/add_objective(datum/objective/Objective, _explanation_text, mob/target_override, add_to_list = TRUE)
	if(ispath(Objective))
		Objective = new Objective()

	Objective.holder = src

	if(add_to_list)
		objectives += Objective

	if(target_override)
		Objective.target = target_override
	else if(Objective.needs_target && !Objective.found_target())
		handle_objective(Objective)

	var/found = Objective.found_target() // in case we are given a target override
	if(found)
		assigned_targets |= found

	if(_explanation_text)
		Objective.explanation_text = _explanation_text

	on_add_callback?.Invoke(objective_owner, Objective)
	return Objective

/**
 * Handles the searching of targets for objectives that need it.
 */

/datum/objective_holder/proc/handle_objective(datum/objective/Objective)
	for(var/loop in 1 to 5)
		Objective.find_target(assigned_targets)
		if(Objective.found_target()) // Handles normal objectives, and steal objectives
			return

	// We failed to find any target. Oh well...
	Objective.explanation_text = "Free Objective"
	Objective.target = null

/**
 * Remove an objective and deletes it. You should never need to transfer an objective.
 */
/datum/objective_holder/proc/remove_objective(datum/objective/Objective)
	objectives -= Objective
	assigned_targets -= Objective.found_target()

	on_remove_callback?.Invoke(objective_owner, Objective)
	if(!QDELETED(Objective))
		qdel(Objective)

/**
 * Returns `objective_owner`
 */
/datum/objective_holder/proc/get_holder_owner()
	RETURN_TYPE(/datum)
	return objective_owner
