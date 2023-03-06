/datum/event/bureaucratic_error
	announceWhen = 1

/datum/event/bureaucratic_error/announce()
	GLOB.major_announcement.Announce("A recent bureaucratic error in the Organic Resources Department may result in personnel shortages in some departments and redundant staffing in others.", "Paperwork Mishap Alert")

/datum/event/bureaucratic_error/start()
	var/list/jobs = SSjobs.occupations.Copy()
	var/datum/job/overflow
	var/errors
	while(errors <= rand(1, 6))
		overflow = pick_n_take(jobs)
		overflow.total_positions = max(overflow.total_positions + rand(-1, 1), 0)
		errors++

