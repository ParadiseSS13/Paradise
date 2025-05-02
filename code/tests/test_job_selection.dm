/// This test doesn't have any actual assertions, it simply runs
/// a simulated job selection with the traitor game mode and logs
/// the results to chat_debug_log.
/datum/game_test/role_selection

/datum/game_test/role_selection/Run()
	var/datum/job_selector/selector = new()
	var/datum/game_mode/traitor/mode = new()

	var/medium_job_preferences_per_candidate = list(
		list(/datum/job/bartender, /datum/job/scientist),
		list(/datum/job/clown, /datum/job/chef),
		list(/datum/job/chemist, /datum/job/explorer, /datum/job/bartender),
		list(/datum/job/atmos, /datum/job/engineer),
		list(/datum/job/chemist),
		list(/datum/job/clown, /datum/job/librarian, /datum/job/cargo_tech),
		list(/datum/job/blueshield, /datum/job/nanotrasenrep),
		list(/datum/job/clown, /datum/job/chaplain, /datum/job/officer),
		list(/datum/job/chief_engineer, /datum/job/captain, /datum/job/hop),
		list(/datum/job/qm, /datum/job/virologist, /datum/job/atmos),
		list(/datum/job/qm, /datum/job/janitor, /datum/job/iaa),
		list(/datum/job/judge, /datum/job/janitor),
		list(/datum/job/officer, /datum/job/paramedic),
		list(/datum/job/psychiatrist, /datum/job/explorer, /datum/job/cyborg),
		list(/datum/job/nanotrasenrep, /datum/job/blueshield, /datum/job/cargo_tech),
		list(/datum/job/iaa, /datum/job/warden, /datum/job/roboticist),

	)

	var/high_job_preferences_per_candidate = list(
		/datum/job/cargo_tech,
		/datum/job/chef,
		/datum/job/captain,
		/datum/job/hop,
		/datum/job/hos,
		/datum/job/captain,
		/datum/job/clown,
		/datum/job/cmo,
		/datum/job/chemist,
	)

	for(var/i in 1 to 90)
		var/datum/job_candidate/candidate = new()
		if(prob(35))
			candidate.active_character.alternate_option = BE_ASSISTANT
		else
			candidate.active_character.alternate_option = GET_RANDOM_JOB
		selector.candidates.Add(candidate)

		if(length(medium_job_preferences_per_candidate) >= i)
			for(var/med_jobpref in medium_job_preferences_per_candidate[i])
				candidate.active_character.SetJobPreferenceLevel(med_jobpref, 2)

		if(length(high_job_preferences_per_candidate) >= i)
			var/high_jobpref = high_job_preferences_per_candidate[i]
			candidate.active_character.SetJobPreferenceLevel(high_jobpref, 1)

		if(i < 5)
			candidate.special_role = SPECIAL_ROLE_TRAITOR
			candidate.restricted_roles = mode.restricted_jobs + mode.protected_jobs

	selector.assign_all_roles()

	log_chat_debug("test_job_selection: [length(selector.assigned_candidates)] assigned candidates")
	log_chat_debug("test_job_selection: [length(selector.candidates)] unassigned candidates remaining")

	for(var/i = 1 to length(selector.assigned_candidates))
		var/datum/job_candidate/candidate = selector.assigned_candidates[i]
		var/special_role = candidate.special_role ? "(special role `[candidate.special_role]`)" : ""
		log_chat_debug("test_job_selection: player=[i] `[candidate.UID()]` [special_role] assigned `[candidate.assigned_job_title]`")
