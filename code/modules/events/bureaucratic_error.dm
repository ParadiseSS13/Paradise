/datum/event/bureaucratic_error
	announceWhen = 1
	/// Jobs that are not allowed to be picked for the bureaucratic error
	var/list/blacklisted_jobs = list(
		/datum/job/assistant,
		/datum/job/ai,
		/datum/job/cyborg,
		/datum/job/blueshield,
		/datum/job/chaplain,
		/datum/job/officer,
		/datum/job/warden
	)

	/// Jobs that pass an additional 40% chance per roll to be picked for the bureaucratic error
	var/list/uncommon_jobs = list(
		/datum/job/chief_engineer,
		/datum/job/cmo,
		/datum/job/rd,
		/datum/job/hos,
		/datum/job/captain,
		/datum/job/hop,
		/datum/job/nanotrasenrep,
		/datum/job/judge,
		/datum/job/qm,
		/datum/job/nanotrasentrainer
	)

/datum/event/bureaucratic_error/announce()
	GLOB.major_announcement.Announce("A recent bureaucratic error in the Human Resources Department may result in personnel shortages in some departments and redundant staffing in others. Contact your local HoP to solve this issue.", "Paperwork Mishap Alert")

/datum/event/bureaucratic_error/start()
	var/list/affected_jobs = list() // For logging
	var/list/jobs = SSjobs.occupations.Copy()
	var/datum/job/overflow
	var/overflow_amount = pick(1, 2)
	var/errors = 0
	while(errors < overflow_amount)
		var/random_change = pick(-2, -1, 1, 2)
		overflow = pick_n_take(jobs)
		if((overflow.admin_only) || (overflow.type in blacklisted_jobs))
			continue
		if(overflow.type in uncommon_jobs)
			if(prob(40))
				random_change = clamp(random_change, 1, 2)
			else
				continue
		overflow.total_positions = max(overflow.total_positions + random_change, 0)
		affected_jobs += "[overflow.title] slot changed by [random_change]"
		errors++
	log_and_message_admins(affected_jobs.Join(".\n"))
	for(var/mob/M as anything in GLOB.dead_mob_list)
		to_chat(M, "<span class='deadsay'><b>Bureaucratic Error:</b> The following job slots have changed: \n[affected_jobs.Join(",\n ")].</span>")
