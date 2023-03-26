/datum/event/bureaucratic_error
	announceWhen = 1

/datum/event/bureaucratic_error/announce()
	GLOB.major_announcement.Announce("A recent bureaucratic error in the Human Resources Department may result in personnel shortages in some departments and redundant staffing in others.", "Paperwork Mishap Alert")

/datum/event/bureaucratic_error/start()
	var/list/jobs = SSjobs.occupations.Copy()
	var/datum/job/overflow
	var/overflow_amount = rand(1, 6)
	var/errors = 0
	while(errors <= overflow_amount)
		var/random_change = pick(-1, 1)
		overflow = pick_n_take(jobs)
		if(!overflow.allow_bureaucratic_error)
			continue
		overflow.total_positions = max(overflow.total_positions + random_change, 0)
		log_and_message_admins("[overflow] slot changed by [random_change]")
		errors++
