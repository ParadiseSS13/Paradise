

/datum/objective_holder
	var/list/datum/objective/objectives = list()

	var/datum/objective_owner // mind, antag_datum, or a team

	/// A list of strings which contain [targets][/datum/objective/var/target] of the antagonist's objectives. Used to prevent duplicate objectives.
	var/list/assigned_targets

	var/datum/callback/on_add_callback
	var/datum/callback/on_remove_callback

/datum/objective_holder/New(new_owner)
	. = ..()
	objective_owner = new_owner

/datum/objective_holder/Destroy(force, ...)
	clear()
	return ..()

/datum/objective_holder/proc/clear(check_type)
	for(var/datum/objective/O as anything in objectives)
		if(check_type && !istype(O, check_type))
			return
		remove_objective(O)
		. = TRUE

/datum/objective_holder/proc/set_callbacks(_on_add_callback, _on_remove_callback)
	on_add_callback = _on_add_callback
	on_remove_callback = _on_remove_callback


/datum/objective_holder/proc/has_objectives()
	return length(objectives) > 0

/datum/objective_holder/proc/get_objectives()
	return objectives

// /datum/objective_holder/proc/find_objective(datum/objective/Objective)
// 	return objectives.Find(objective)

/datum/objective_holder/proc/replace_objective(datum/objective/old_objective, datum/objective/new_objective)
	var/old_owner = old_objective.owner
	remove_objective(old_objective)

	new_objective = add_objective(new_objective, add_to_list = FALSE)
	new_objective.owner = old_owner
	// Replace where the old objective was, with the new one
	objectives.Insert(objectives.Find(old_objective), new_objective)

/datum/objective_holder/proc/add_objective(datum/objective/Objective, explanation_text, mob/target_override, add_to_list = TRUE)
	if(ispath(Objective))
		Objective = new Objective()

	Objective.holder = src

	if(add_to_list)
		objectives += Objective
	if(Objective.needs_target && !Objective.target)
		handle_objective(Objective, explanation_text, target_override)

	on_add_callback?.Invoke(objective_owner, Objective)

	RegisterSignal(Objective, COMSIG_PARENT_QDELETING, PROC_REF(remove_objective))
	return Objective

/datum/objective_holder/proc/handle_objective(datum/objective/O, explanation_text, mob/target_override) // ctodo, check this is all needed
	var/found_valid_target = FALSE
	if(target_override)
		O.target = target_override
		found_valid_target = TRUE
	else
		var/loops = 5
		// Steal objectives need snowflake handling here unfortunately.
		if(istype(O, /datum/objective/steal))
			var/datum/objective/steal/S = O
			while(loops--)
				S.find_target()
				if(S.steal_target && !("[S.steal_target.name]" in assigned_targets))
					found_valid_target = TRUE
					break
		else
			while(loops--)
				O.find_target()
				if(O.target && !("[O.target]" in assigned_targets))
					found_valid_target = TRUE
					break

	if(found_valid_target)
		// This is its own seperate section in case someone passes a `target_override`.
		if(istype(O, /datum/objective/steal))
			var/datum/objective/steal/S = O
			assigned_targets |= "[S.steal_target.name]"
		else
			assigned_targets |= "[O.target]"
	else
		O.explanation_text = "Free Objective"
		O.target = null

/datum/objective_holder/proc/remove_objective(datum/objective/O)
	objectives -= O
	assigned_targets -= "[O.target]"
	if(istype(O, /datum/objective/steal))
		var/datum/objective/steal/S = O
		assigned_targets -= "[S.steal_target]"

	on_remove_callback?.Invoke(objective_owner, O)
	if(!QDELETED(O))
		qdel(O)
