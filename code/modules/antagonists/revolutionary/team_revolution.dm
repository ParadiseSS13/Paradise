/datum/team/revolution
	name = "Revolution"
	antag_datum_type = /datum/antagonist/rev
	var/max_headrevs = REVOLUTION_MAX_HEADREVS // adminbus is possible

/datum/team/revolution/New()
	. = ..()
	update_team_objectives()
	SSshuttle.registerHostileEnvironment(src)

/datum/team/revolution/Destroy(force, ...)
	SSticker.mode.rev_team = null
	SSshuttle.clearHostileEnvironment(src)
	. = ..()


/datum/team/revolution/proc/update_team_objectives()
	sanitize_objectives()
	var/list/heads = SSticker.mode.get_all_heads() - get_targetted_head_minds()

	for(var/datum/mind/head_mind in heads)
		// add_objective(datum/objective/mutiny)
		var/datum/objective/mutiny/rev_obj = new
		rev_obj.target = head_mind
		rev_obj.team = src
		rev_obj.explanation_text = "Assassinate or exile [head_mind.name], the [head_mind.assigned_role]."
		add_objective_to_members(rev_obj)

/datum/team/revolution/get_target_excludes()
	return ..() + get_targetted_head_minds()

/datum/team/revolution/proc/get_targetted_head_minds()
	. = list()
	for(var/datum/objective/O in objectives)
		. |= O.target

/datum/team/revolution/proc/sanitize_objectives() // contra todo use somewhere
	for(var/datum/objective/O in objectives)
		if(!O.target) // revs shouldnt have free objectives
			remove_objective_from_members(O)

/datum/team/revolution/proc/check_rev_victory()
	for(var/datum/objective/mutiny/objective in objectives)
		if(!(objective.check_completion()))
			return FALSE
	return TRUE

/datum/team/revolution/remove_member(datum/mind/member)
	. = ..()
	var/datum/antagonist/rev/revolting = member.has_antag_datum(/datum/antagonist/rev)
	if(!QDELETED(revolting))
		member.remove_antag_datum(/datum/antagonist/rev)

/datum/team/revolution/proc/head_revolutionaries()
	. = list()
	for(var/datum/mind/M in members)
		if(M.has_antag_datum(/datum/antagonist/rev/head))
			. += M

// im not even sure what this is supposed to calculate, but it does something?
/datum/team/revolution/proc/need_another_headrev(clamp_at = 0) // yes, zero. Not false.
	var/head_revolutionaries = length(head_revolutionaries())
	var/heads = length(SSticker.mode.get_all_heads())
	var/sec = length(SSticker.mode.get_all_sec())
	if(head_revolutionaries >= max_headrevs)
		return FALSE
	var/sec_diminish = (8 - sec) / 3 // 2 seccies = 2, 5 seccies = 1, 8 seccies = 0

	var/potential = round(heads - sec_diminish) // more sec, increases. more heads, increases
	var/weighted_score = clamp(potential, clamp_at, max_headrevs)

	return weighted_score // some magic bullshit idk contra todo


/datum/team/revolution/proc/process_promotion()
	var/list/head_revolutionaries = head_revolutionaries()
	if(need_another_headrev(0))
		var/list/datum/mind/non_heads = members - head_revolutionaries
		if(!length(non_heads))
			return
		for(var/datum/mind/khrushchev in shuffle_inplace(non_heads))
			if(!khrushchev.current || !khrushchev.current.client)
				return
			if(khrushchev.current.incapacitated() || HAS_TRAIT(khrushchev.current, TRAIT_RESTRAINED)) // contra todo, check this
				return
			if(khrushchev.current.stat)
				return
			// shuffled so its random, we can just pick here and now
			var/datum/antagonist/rev/rev = khrushchev.has_antag_datum(/datum/antagonist/rev)
			rev.promote()
			return
