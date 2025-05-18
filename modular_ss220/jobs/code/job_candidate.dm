/datum/job_candidate
	/// Player donator level.
	VAR_PRIVATE/donator_level

/datum/job_candidate/load_from_player(mob/new_player/player)
	. = ..()
	donator_level = player.client.donator_level

/datum/job_candidate/proc/is_donor_allowed(datum/job/job)
	switch(donator_level)
		if(LITTLE_WORKER_TIER)
			if(job.donator_tier > LITTLE_WORKER_LEVEL)
				return FALSE
		if(BIG_WORKER_TIER)
			if(job.donator_tier > BIG_WORKER_LEVEL)
				return FALSE
	return job.donator_tier <= donator_level
