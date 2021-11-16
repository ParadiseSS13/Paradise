/proc/is_job_whitelisted(mob/M, rank)
	if(!check_job_karma(rank)) // If it aint a karma job, let them play
		return TRUE
	if(!GLOB.configuration.general.enable_karma)
		return TRUE
	if(check_rights(R_ADMIN, FALSE, M))
		return TRUE
	if(rank in M.client.karmaholder.unlocked_jobs)
		return TRUE

	return FALSE

/proc/can_use_species(mob/M, species)
	if(!GLOB.configuration.general.enable_karma)
		return TRUE
	if(species == "human" || species == "Human")
		return TRUE
	if(check_rights(R_ADMIN, FALSE))
		return TRUE
	if(species in M.client.karmaholder.unlocked_species)
		return TRUE
	return FALSE
