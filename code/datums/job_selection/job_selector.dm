RESTRICT_TYPE(/datum/job_selector)

/datum/job_selector
	var/list/candidates = list()
	var/list/assigned_candidates = list()
	var/probability_of_antag_role_restriction = 100

/datum/job_selector/proc/add_candidate(mob/new_player/player = null)
	var/datum/job_candidate/candidate = new()
	if(player)
		candidate.load_from_player(player)

	candidates[candidate] = player

/datum/job_selector/proc/assign_role(datum/job_candidate/candidate, datum/job/job, latejoin = FALSE, step = "unknown_step")
	if(!job)
		return FALSE

	var/eligible = candidate.get_job_eligibility(job)
	var/available = latejoin ? job.is_position_available() : job.is_spawn_position_available()

	if(eligible && available)
		candidate.assign_title(job.title)
		assigned_candidates[candidate] = candidates[candidate]
		candidates -= candidate
		job.current_positions++
		SSblackbox.record_feedback("nested tally", "manifest", 1, list(job.title, (latejoin ? "latejoin" : "roundstart")))
		log_chat_debug("jobs/[step]: candidate=[candidate.UID()] job=[job] [latejoin ? "latejoin" : "roundstart"] assigned")
		return TRUE

	log_chat_debug("jobs/[step]: candidate=[candidate.UID()] job=[job] [latejoin ? "latejoin" : "roundstart"] ineligible or unavailable")
	return FALSE

/// Convenience proc for handling a single latejoin player
/datum/job_selector/proc/latejoin_assign(mob/new_player/player, datum/job/job)
	var/datum/job_candidate/candidate = new()
	candidate.load_from_player(player)
	if(assign_role(candidate, job, latejoin = TRUE, step = "latejoin"))
		candidate.apply_to_player(player)
	else
		to_chat(player, "<span class='warning'>You are unable to join the round as [job.title]. Please try another job.</span>")

/datum/job_selector/proc/apply_roles_to_players()
	for(var/datum/job_candidate/candidate in assigned_candidates)
		var/mob/new_player/player = assigned_candidates[candidate]
		if(player)
			candidate.apply_to_player(player)

/datum/job_selector/proc/return_to_lobby(datum/job_candidate/candidate)
	candidate.return_to_lobby()
	assigned_candidates[candidate] = candidates[candidate]
	candidates -= candidate

/datum/job_selector/proc/find_job_candidates(datum/job/job, level, flag)
	var/list/job_candidates = list()
	for(var/datum/job_candidate/candidate as anything in candidates)
		// If the candidate doesn't want the job don't bother checking further, duh
		if(!candidate.wants_job(job, level))
			continue
		if(!candidate.get_job_eligibility(job))
			log_chat_debug("jobs/find_job_candidates: candidate=[candidate.UID()] job=[job] level=[level] ineligible")
			continue
		if(flag && !candidate.has_special(flag))
			log_chat_debug("jobs/find_job_candidates: candidate=[candidate.UID()] job=[job] level=[level] missing flag=[flag]")
			continue
		if(candidate.restricted_from(job))
			log_chat_debug("jobs/find_job_candidates: candidate=[candidate.UID()] job=[job] level=[level] restricted")
			continue
		if(candidate.has_special_role() && (job.title in SSticker.mode.single_antag_positions))
			if(candidate.failed_head_antag_roll() || !prob(probability_of_antag_role_restriction))
				log_chat_debug("jobs/find_job_candidates: candidate=[candidate.UID()] job=[job] special_role=[candidate.has_special_role()] failed head antag roll")
				candidate.fail_head_antag_roll()
				continue
			else
				probability_of_antag_role_restriction /= 10

		job_candidates += candidate

	log_chat_debug("jobs/find_job_candidates: job=[job] level=[level] flag=[flag] returned [length(job_candidates)] candidates")
	return job_candidates

/datum/job_selector/proc/assign_random_job(datum/job_candidate/candidate)
	for(var/datum/job/job as anything in shuffle(SSjobs.occupations))
		if(istype(job, /datum/job/assistant)) // We don't want to give him assistant, that's boring!
			continue

		if(job.is_command_position()) // If you want a command position, select it!
			continue

		if(job.admin_only || job.mentor_only) // No admin/mentor-only positions either.
			continue

		if(!candidate.get_job_eligibility(job))
			continue

		if(candidate.restricted_from(job))
			continue

		if(candidate.has_special_role() && (job.title in SSticker.mode.single_antag_positions))
			if(candidate.failed_head_antag_roll() || !prob(probability_of_antag_role_restriction))
				log_chat_debug("jobs/assign_random_job: candidate=[candidate.UID()] job=[job] special_role=[candidate.has_special_role()] failed head antag roll")
				candidate.fail_head_antag_roll()
				continue
			else
				probability_of_antag_role_restriction /= 10
		if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
			assign_role(candidate, job, step = "assign_random_job")
			return

	log_chat_debug("jobs/assign_random_job candidate=[candidate.UID()] could not assign")

/// This proc is called before the level loop of assign_all_roles() and will try
/// to select a head, ignoring ALL non-head preferences for every level until it
/// locates a head or runs out of levels to check
/datum/job_selector/proc/fill_head_position()
	for(var/level = 1 to 3)
		for(var/command_position in GLOB.command_positions)
			var/datum/job/job = SSjobs.GetJob(command_position)
			if(!job)
				continue
			if(!job.is_spawn_position_available())
				continue
			var/list/job_candidates = find_job_candidates(job, level)
			if(!length(job_candidates))
				continue

			var/list/filtered_candidates = list()

			for(var/datum/job_candidate/candidate as anything in job_candidates)
				var/mob/new_player/real_player = candidates[candidate]
				if(real_player && !real_player.client)
					// Log-out during round-start?
					// What a bad boy, no head position for you!
					continue
				filtered_candidates += candidate

			if(!length(filtered_candidates))
				continue

			var/datum/job_candidate/candidate = pick(filtered_candidates)
			if(assign_role(candidate, job, step = "fill_head_position"))
				return TRUE

	return FALSE

/// This proc is called at the start of the level loop
/// of assign_all_roles() and will cause head jobs to be
/// checked before any other jobs of the same level.
/datum/job_selector/proc/check_command_positions(level)
	for(var/command_position in GLOB.command_positions)
		var/datum/job/job = SSjobs.GetJob(command_position)
		if(!job)
			continue
		if(!job.is_spawn_position_available())
			continue
		var/list/job_candidates = find_job_candidates(job, level)
		if(!length(job_candidates))
			continue
		var/datum/job_candidate/candidate = pick(job_candidates)
		assign_role(candidate, job, step = "check_command_positions")

/datum/job_selector/proc/fill_ai_position()
	if(!GLOB.configuration.jobs.allow_ai)
		return FALSE

	var/ai_selected = FALSE
	var/datum/job/job = SSjobs.GetJob("AI")
	if(!job)
		return FALSE

	for(var/i = job.total_positions, i > 0, i--)
		for(var/level = 1 to 3)
			var/list/job_candidates = list()
			job_candidates = find_job_candidates(job, level)
			if(length(job_candidates))
				var/mob/new_player/candidate = pick(job_candidates)
				if(assign_role(candidate, "AI", step = "fill_ai_position"))
					ai_selected++
					break

		if(ai_selected)
			return TRUE

		return FALSE

/// Fills var "assigned_role" for all ready players.
/datum/job_selector/proc/assign_all_roles()
	// Lets roughly time this
	var/watch = start_watch()
	//Setup new player list and get the jobs list
	SSjobs.SetupOccupations()

	//Holder for Triumvirate is stored in the ticker, this just processes it
	if(SSticker)
		for(var/datum/job/ai/A in SSjobs.occupations)
			if(SSticker.triai)
				A.spawn_positions = 3

	//Get the players who are ready
	for(var/mob/new_player/player in GLOB.player_list)
		if(player.ready && player.mind && !player.mind.assigned_role)
			add_candidate(player)

	if(!length(candidates))
		return FALSE

	candidates = shuffle(candidates)

	handle_feedback_gathering()

	// People who want to be assistants, sure, go on.
	var/datum/job/ast = SSjobs.GetJob("Assistant")
	var/list/assistant_candidates = find_job_candidates(ast, 3)
	for(var/datum/job_candidate/candidate as anything in assistant_candidates)
		assign_role(candidate, ast, step = "assign_all_roles/assistants")

	fill_head_position()
	fill_ai_position()

	// New job giving system by Donkie
	// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
	// Hopefully this will add more randomness and fairness to job giving.

	// Loop through all levels from high to low
	for(var/level = 1 to 3)
		//Check the head jobs first each level
		check_command_positions(level)

		// Loop through all unassigned players
		for(var/datum/job_candidate/candidate as anything in candidates)
			var/list/shuffledoccupations = shuffle(SSjobs.occupations)

			for(var/datum/job/job as anything in shuffledoccupations)
				if(!job.is_spawn_position_available())
					continue

				// If the player wants that job on this level, then try give it to him.
				if(!candidate.wants_job(job, level))
					continue

				if(!candidate.get_job_eligibility(job))
					log_chat_debug("jobs/assign_all_roles: candidate=[candidate.UID()] job=[job] wanted but ineligible")
					continue

				if(candidate.restricted_from(job))
					log_chat_debug("jobs/assign_all_roles: candidate=[candidate.UID()] job=[job] incompatible with antagonist role")
					continue

				if(candidate.has_special_role() && (job.title in SSticker.mode.single_antag_positions))
					if(candidate.failed_head_antag_roll() || !prob(probability_of_antag_role_restriction))
						candidate.fail_head_antag_roll()
						log_chat_debug("jobs/assign_all_roles: candidate=[candidate.UID()] job=[job] special_role=[candidate.has_special_role()] failed head antag roll")
						continue
					else
						probability_of_antag_role_restriction /= 10

				assign_role(candidate, job, step = "assign_all_roles")
				break

	// Hand out random jobs to the people who didn't get any in the last check
	// Also makes sure that they got their preference correct
	for(var/datum/job_candidate/candidate as anything in candidates)
		if(candidate.alternate_spawn_option() == GET_RANDOM_JOB)
			assign_random_job(candidate)

	// Antags, who have to get in, come first
	for(var/datum/job_candidate/candidate as anything in candidates)
		if(candidate.has_special_role())
			if(candidate.alternate_spawn_option() != BE_ASSISTANT)
				assign_random_job(candidate)
				if(!candidate.is_assigned())
					assign_role(candidate, ast, step = "assign_all_roles/special")
			else
				assign_role(candidate, ast, step = "assign_all_roles/antag")
		else if(candidate.has_restricted_roles())
			stack_trace("A player with `restricted_roles` had no `special_role`. They are likely an antagonist, but failed to spawn in.") // this can be fixed by assigning a special_role in pre_setup of the gamemode
			message_admins("A player ([key_name_admin(candidate.get_ckey())]) is likely an antagonist, but may have failed to spawn in! Please report this to coders.")

	// Then we assign what we can to everyone else.
	for(var/datum/job_candidate/candidate as anything in candidates)
		if(candidate.alternate_spawn_option() == BE_ASSISTANT)
			assign_role(candidate, ast, step = "assign_all_roles/assistant")
		else if(candidate.alternate_spawn_option() == RETURN_TO_LOBBY)
			return_to_lobby(candidate)

	log_chat_debug("jobs/assign_all_roles completed in [stop_watch(watch)]s")
	return TRUE

/datum/job_selector/proc/handle_feedback_gathering()
	for(var/datum/job/job as anything in SSjobs.occupations)
		var/high = 0
		var/medium = 0
		var/low = 0
		var/never = 0
		var/banned = 0
		var/young = 0 //account too young
		var/disabled = FALSE //has disability rendering them ineligible
		for(var/datum/job_candidate/candidate as anything in candidates)
			if(candidate.is_jobbanned(job))
				banned++
				continue
			if(!candidate.is_account_old_enough(job))
				young++
				continue
			if(candidate.get_job_exp_restrictions(job))
				young++
				continue
			if(candidate.is_barred_by_disability(job) || candidate.is_barred_by_missing_limbs(job))
				disabled++
				continue
			if(candidate.wants_job(job, 1))
				high++
			else if(candidate.wants_job(job, 2))
				medium++
			else if(candidate.wants_job(job, 3))
				low++
			else
				never++ //not selected

		SSblackbox.record_feedback("nested tally", "job_preferences", high, list("[job.title]", "high"))
		SSblackbox.record_feedback("nested tally", "job_preferences", medium, list("[job.title]", "medium"))
		SSblackbox.record_feedback("nested tally", "job_preferences", low, list("[job.title]", "low"))
		SSblackbox.record_feedback("nested tally", "job_preferences", never, list("[job.title]", "never"))
		SSblackbox.record_feedback("nested tally", "job_preferences", banned, list("[job.title]", "banned"))
		SSblackbox.record_feedback("nested tally", "job_preferences", young, list("[job.title]", "young"))
		SSblackbox.record_feedback("nested tally", "job_preferences", disabled, list("[job.title]", "disabled"))
