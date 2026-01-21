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
		for(var/datum/objective/ninja/ninja_objective in N.get_antag_objectives())
			if(!ninja_objective.completed)
				return FALSE
		return TRUE

#define NINJA_OBJECTIVE_EASY 10
#define NINJA_OBJECTIVE_NORMAL 20
#define NINJA_OBJECTIVE_HARD 40

/datum/objective/ninja
	/// Can you only roll this objective once?
	var/onlyone = FALSE
	/// Does this objective come with special gear
	var/special_equipment_path
	/// Rewarded currency for objective completion
	var/reward_tc = NINJA_OBJECTIVE_EASY

/datum/objective/ninja/New(text, datum/team/team_to_join, datum/mind/_owner)
	. = ..()
	if(special_equipment_path)
		addtimer(CALLBACK(src, PROC_REF(hand_out_equipment)), 3 SECONDS, TIMER_DELETE_ME)

/datum/objective/ninja/proc/hand_out_equipment()
	give_kit(special_equipment_path)

/datum/objective/ninja/check_completion()
	if(..())
		return TRUE
	for(var/datum/mind/M in get_owners())
		var/obj/item/uplink/hidden/nuplink = M.find_syndicate_uplink()
		nuplink.uses += reward_tc
		var/datum/antagonist/space_ninja/N = M.has_antag_datum(/datum/antagonist/space_ninja)
		N.forge_new_objective()

/datum/objective/ninja/kill
	name = "Kill a Target"
	reward_tc = NINJA_OBJECTIVE_NORMAL

/datum/objective/ninja/kill/update_explanation_text()
	if(target?.current)
		explanation_text = "Kill [target.current.real_name], the [target.assigned_role]. Scan the corpse with your scanner to verify that the deed is done."
		var/datum/job/target_job = target.current.job
		if(target_job.job_department_flags & DEP_FLAG_COMMAND || target_job.job_department_flags & DEP_FLAG_SECURITY)
			reward_tc = NINJA_OBJECTIVE_HARD

/datum/objective/ninja/capture
	name = "Capture a Target"

/datum/objective/ninja/capture/update_explanation_text()
	if(target?.current)
		explanation_text = "Capture [target.current.real_name], the [target.assigned_role]. Use your energy net to capture them so that we can interrogate them at one of our many secret dojos."
		var/datum/job/target_job = target.current.job
		if(target_job.job_department_flags & DEP_FLAG_COMMAND || target_job.job_department_flags & DEP_FLAG_SECURITY)
			reward_tc = NINJA_OBJECTIVE_HARD
		if(target.current.job.job_department_flags & DEP_FLAG_SERVICE)
			reward_tc = NINJA_OBJECTIVE_EASY

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
	reward_tc = NINJA_OBJECTIVE_HARD

/datum/objective/ninja/interrogate_ai/update_explanation_text()
	explanation_text = "We wish to expunge some data from their AI system. Use your scanner on the AI core to wirelessly transfer it to us for interrogation."

/datum/objective/ninja/steal_supermatter
	name = "Steal Supermatter"
	needs_target = FALSE
	onlyone = TRUE
	reward_tc = NINJA_OBJECTIVE_HARD

/datum/objective/ninja/steal_supermatter/update_explanation_text()
	explanation_text = "Steal the supermatter crystal, using the hypernobilium net we have provided you. The crystal will sell well to the highest bidder."

/datum/objective/ninja/bomb_department
	name = "Bomb Department"
	needs_target = FALSE
	special_equipment_path = /obj/item/wormhole_jaunter/ninja_bomb
	reward_tc = NINJA_OBJECTIVE_NORMAL

/datum/objective/ninja/bomb_department/update_explanation_text()
	explanation_text = "Use the special flare provided to call down and arm a spider bomb. The target department is inscribed on the flare."

/datum/objective/ninja/bomb_department/emp
	name = "EMP Department"
	special_equipment_path = /obj/item/wormhole_jaunter/ninja_bomb/emp

/datum/objective/ninja/bomb_department/emp/update_explanation_text()
	explanation_text = "Use the special flare provided to call down and arm an EMP bomb. The target department is inscribed on the flare."

/datum/objective/ninja/bomb_department/spiders
	name = "Spider Bomb Department"
	special_equipment_path = /obj/item/wormhole_jaunter/ninja_bomb/spiders

/datum/objective/ninja_exfiltrate
	name = "Exfiltrate"
	needs_target = FALSE
	reward_tc = 0

/datum/objective/ninja/ninja_exfiltrate/update_explanation_text()
	explanation_text = "Use your exfiltration flare to escape the station. Your work here is done."

#undef NINJA_OBJECTIVE_EASY
#undef NINJA_OBJECTIVE_NORMAL
#undef NINJA_OBJECTIVE_HARD
