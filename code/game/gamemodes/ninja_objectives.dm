/datum/objective/ninja_goals
	name = "Complete Missions"
	needs_target = FALSE

/datum/objective/ninja_goals/New()
	gen_amount_goal()
	. = ..()

/datum/objective/ninja_goals/proc/gen_amount_goal()
	target_amount = 4 + round(length(GLOB.crew_list) / 20)
	update_explanation_text()
	return target_amount

/datum/objective/ninja_goals/update_explanation_text()
	explanation_text = "Complete [target_amount] missions for the Spider Clan."

/datum/objective/ninja_goals/check_completion()
	if(..())
		return TRUE
	for(var/datum/mind/M in get_owners())
		var/datum/antagonist/space_ninja/N = M.has_antag_datum(/datum/antagonist/space_ninja)
		for(var/datum/objective/ninja/ninja_objective in N.objective_holder.get_objectives())
			if(!ninja_objective.completed)
				return FALSE
		return TRUE

/datum/objective/ninja
	/// Can you only roll this objective once?
	var/onlyone = FALSE

/datum/objective/ninja/check_completion()
	if(..())
		return TRUE
	for(var/datum/mind/M in get_owners())
		var/datum/antagonist/space_ninja/N = M.has_antag_datum(/datum/antagonist/space_ninja)
		N.forge_new_objective()

/datum/objective/ninja/kill
	name = "Kill a Target"

/datum/objective/ninja/kill/update_explanation_text()
	if(target?.current)
		explanation_text = "Kill [target.current.real_name], the [target.assigned_role]. Scan the corpse with your scanner to verify that the deed is done."

/datum/objective/ninja/capture
	name = "Capture a Target"

/datum/objective/ninja/capture/update_explanation_text()
	if(target?.current)
		explanation_text = "Capture [target.current.real_name], the [target.assigned_role]. Use your energy net to capture them so that we can interrogate them at one of our many secret dojos."

/datum/objective/ninja/hack_rnd
	name = "Hack RnD"
	needs_target = FALSE
	onlyone = TRUE

/datum/objective/ninja/hack_rnd/update_explanation_text()
	explanation_text = "A client wants access to Nanotrasen's research databank. Use your scanner on their servers to give them a way inside."

/datum/objective/ninja/interrogate_ai
	name = "Interrogate AI"
	needs_target = FALSE
	onlyone = TRUE

/datum/objective/ninja/interrogate_ai/update_explanation_text()
	explanation_text = "We wish to expunge some data from their AI system. Use your scanner on the AI core to wirelessly transfer it to us for interrogation."

/datum/objective/ninja/steal_supermatter
	name = "Steal Supermatter"
	needs_target = FALSE
	onlyone = TRUE

/datum/objective/ninja/steal_supermatter/update_explanation_text()
	explanation_text = "Steal the supermatter crystal, using the hypernobilium net we have provided you. The crystal will sell well to the highest bidder."

/datum/objective/ninja/bomb_department
	name = "Bomb Department"
	needs_target = FALSE

/datum/objective/ninja/bomb_department/update_explanation_text()
	explanation_text = "Use the special flare provided to call down and arm a spider bomb. The target department is inscribed on the flare."

/datum/objective/ninja/bomb_department/emp
	name = "EMP Department"

/datum/objective/ninja/bomb_department/emp/update_explanation_text()
	explanation_text = "Use the special flare provided to call down and arm an EMP bomb. The target department is inscribed on the flare."

/datum/objective/ninja/bomb_department/spiders
	name = "Spider Bomb Department"

/datum/objective/ninja_exfiltrate
	name = "Exfiltrate"
	needs_target = FALSE

/datum/objective/ninja/ninja_exfiltrate/update_explanation_text()
	explanation_text = "Use your exfiltration flare to escape the station. Your work here is done."
