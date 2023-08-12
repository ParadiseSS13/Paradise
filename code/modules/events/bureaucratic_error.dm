/datum/event/bureaucratic_error
	announceWhen = 1
	/// Jobs that are not allowed to be picked for the bureaucratic error
	var/list/blacklisted_jobs = list(
		/datum/job/assistant,
		/datum/job/chief_engineer,
		/datum/job/cmo,
		/datum/job/rd,
		/datum/job/hos,
		/datum/job/ai,
		/datum/job/captain,
		/datum/job/hop,
		/datum/job/nanotrasenrep,
		/datum/job/blueshield,
		/datum/job/judge,
		/datum/job/chaplain,
		/datum/job/officer,
		/datum/job/detective,
		/datum/job/warden
	)

/datum/event/bureaucratic_error/announce()
	GLOB.major_announcement.Announce("A recent bureaucratic error in the Human Resources Department may result in personnel shortages in some departments and redundant staffing in others.", "Paperwork Mishap Alert")

/datum/event/bureaucratic_error/start()
	var/list/affected_jobs = list() // For logging
	var/list/jobs = SSjobs.occupations.Copy()
	var/datum/job/overflow
	var/overflow_amount = rand(1, 6)
	var/errors = 0
	while(errors <= overflow_amount)
		var/random_change = pick(-1, 1)
		overflow = pick_n_take(jobs)
		if(overflow.admin_only)
			continue
		if(overflow.type in blacklisted_jobs)
			continue
		overflow.total_positions = max(overflow.total_positions + random_change, 0)
		affected_jobs += "[overflow.title] slot changed by [random_change]"
		errors++
	log_and_message_admins(affected_jobs.Join(".\n"))
	for(var/mob/M as anything in GLOB.dead_mob_list)
		to_chat(M, "<span class='deadsay'><b>Bureaucratic Error:</b> The following job slots have changed: [affected_jobs.Join(", ")].</span>")
