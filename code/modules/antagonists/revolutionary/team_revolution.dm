RESTRICT_TYPE(/datum/team/revolution)

/datum/team/revolution
	name = "Revolution"
	antag_datum_type = /datum/antagonist/rev
	var/max_headrevs = REVOLUTION_MAX_HEADREVS // adminbus is possible
	var/have_we_won = FALSE

/datum/team/revolution/create_team()
	. = ..()
	update_team_objectives()
	SSshuttle.registerHostileEnvironment(src)

/datum/team/revolution/Destroy(force, ...)
	SSshuttle.clearHostileEnvironment(src)
	return ..()

/datum/team/revolution/can_create_team()
	return isnull(SSticker.mode.rev_team)

/datum/team/revolution/assign_team()
	SSticker.mode.rev_team = src

/datum/team/revolution/clear_team_reference()
	if(SSticker.mode.rev_team == src)
		SSticker.mode.rev_team = null
	else
		CRASH("[src] ([type]) attempted to clear a team reference that wasn't itself!")

/datum/team/revolution/get_target_excludes()
	return ..() + get_targetted_head_minds()

/datum/team/revolution/admin_add_objective(mob/user)
	sanitize_objectives()
	. = ..()
	if(sanitize_objectives())
		message_admins("[key_name_admin(user)] added a mutiny objective to the team '[name]', and no target was found, removing.")
		log_admin("[key_name_admin(user)] added a mutiny objective to the team '[name]', and no target was found, removing.")

/datum/team/revolution/get_admin_priority_objectives()
	. = list()
	.["Mutiny"] = /datum/objective/mutiny

/datum/team/revolution/on_round_end()
	return // for now... show nothing. Add this in when revs is added to midround/dynamic. Not showing it currently because its dependent on rev gamemode

/datum/team/revolution/proc/update_team_objectives()
	var/list/heads = SSticker.mode.get_all_heads() - get_targetted_head_minds()

	for(var/datum/mind/head_mind in heads)
		var/datum/objective/mutiny/rev_obj = new
		rev_obj.target = head_mind
		rev_obj.explanation_text = "Assassinate or exile [head_mind.name], the [head_mind.assigned_role]."
		add_team_objective(rev_obj)
	sanitize_objectives()

/datum/team/revolution/proc/get_targetted_head_minds()
	. = list()
	for(var/datum/objective/mutiny/O in objective_holder.get_objectives())
		. |= O.target

/datum/team/revolution/proc/sanitize_objectives()
	for(var/datum/objective/mutiny/O in objective_holder.get_objectives())
		if(!O.target) // revs shouldnt have free objectives
			remove_team_objective(O)
			. = TRUE

/datum/team/revolution/proc/check_all_victory()
	if(have_we_won)
		return
	if(!length(members)) // all the minds got removed/deleted somehow, perhaps admin stuff. Best to just remove the team altogether.
		qdel(src)
		return
	update_team_objectives()
	check_rev_victory()
	check_heads_victory()

/datum/team/revolution/proc/check_rev_victory()
	for(var/datum/objective/mutiny/objective in objective_holder.get_objectives())
		if(!(objective.check_completion()))
			return FALSE

	SSshuttle.clearHostileEnvironment(src) // revs can take the shuttle too if they want
	have_we_won = TRUE

	log_admin("Revolutionary win conditions met. All command, security, and legal jobs are now closed.")
	message_admins("The revolutionaries have won! All command, security, and legal jobs have been closed. You can change this with the \"Free Job Slot\" verb.")
	// HOP can still technically alter some roles, but Nanotrasen wouldn't send heads/sec under threat to the station after revs win
	var/banned_departments = DEP_FLAG_COMMAND | DEP_FLAG_SECURITY | DEP_FLAG_LEGAL
	for(var/datum/job/job in SSjobs.occupations)
		if(!(job.job_department_flags & banned_departments))
			continue
		job.total_positions = 0
		job.job_banned_gamemode = TRUE
	return TRUE

/datum/team/revolution/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in SSticker.mode.head_revolutionaries)
		if(!ishuman(rev_mind?.current))
			continue
		if(rev_mind.current.stat == DEAD)
			continue
		var/turf/T = get_turf(rev_mind.current)
		if(!T || !is_station_level(T.z))
			continue
		return FALSE // there is still a headrev left alive!

	SSshuttle.clearHostileEnvironment(src)
	return TRUE

/**	Calculate how many headrevs are needed, given a certain amount of sec/heads.
 * 		How many Headrevs given security + command (excluding the clamp)
 * 									Security
 *		  		0	1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16
 *		 		------------------------------------------------------------------
 *			0 | -3	-2	-2	-2	-1	-1	-1	0	0	0	1	1	1	2	2	2	3
 *			1 | -2	-1	-1	-1	0	0	0	1	1	1	2	2	2	3	3	3	4
 *			2 | -1	0	0	0	1	1	1	2	2	2	3	3	3	4	4	4	5
 * Command	3 | 0	1	1	1	2	2	2	3	3	3	4	4	4	5	5	5	6
 *			4 | 1	2	2	2	3	3	3	4	4	4	5	5	5	6	6	6	7
 *			5 | 2	3	3	3	4	4	4	5	5	5	6	6	6	7	7	7	8
 *			6 | 3	4	4	4	5	5	5	6	6	6	7	7	7	8	8	8	9
 *			7 | 4	5	5	5	6	6	6	7	7	7	8	8	8	9	9	9	10
 */

/datum/team/revolution/proc/need_another_headrev(clamp_at = 0) // yes, zero. Not false.
	var/head_revolutionaries = length(SSticker.mode.head_revolutionaries)
	var/heads = length(SSticker.mode.get_all_heads())
	var/sec = length(SSticker.mode.get_all_sec())
	if(head_revolutionaries >= max_headrevs)
		return FALSE
	var/sec_diminish = (8 - sec) / 3 // 2 seccies = 2, 5 seccies = 1, 8 seccies = 0

	var/potential = round(heads - sec_diminish) // more sec, increases. more heads, increases
	var/how_many_more_headrevs = clamp(potential, clamp_at, max_headrevs - head_revolutionaries)

	return how_many_more_headrevs

/datum/team/revolution/proc/process_promotion(promotion_type = REVOLUTION_PROMOTION_OPTIONAL)
	if(!need_another_headrev(0) || promotion_type != REVOLUTION_PROMOTION_AT_LEAST_ONE || length(SSticker.mode.head_revolutionaries) > 1)
		// We check the graph to see if we need a headrev
		// If this is called from when a headrev is cryoing and, we must promote or the revolution will die
		// This is called before they are officially removed from SSticker.mode.head_revolutionaries, so we want to make sure we get a new head before things go bad.
		return
	var/list/datum/mind/non_heads = members - SSticker.mode.head_revolutionaries
	if(!length(non_heads))
		return
	for(var/datum/mind/khrushchev in shuffle_inplace(non_heads))
		if(!is_viable_head(khrushchev))
			continue
		// shuffled so its random, we can just pick here and now
		var/datum/antagonist/rev/rev = khrushchev.has_antag_datum(/datum/antagonist/rev)
		rev.promote()
		return // return is needed to break the loop, otherwise we'd get a helluva lot of headrevs

/datum/team/revolution/proc/is_viable_head(datum/mind/rev_mind)
	if(!rev_mind.current || !rev_mind.current.client)
		return FALSE
	if(!ishuman(rev_mind.current))
		return FALSE
	if(rev_mind.current.incapacitated() || HAS_TRAIT(rev_mind.current, TRAIT_HANDS_BLOCKED)) // todo for someone else, make sure the rev heads on ON STATION
		return FALSE
	return TRUE
