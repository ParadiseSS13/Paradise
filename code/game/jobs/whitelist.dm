/proc/is_job_whitelisted(mob/M, rank)
	if(guest_jobbans(rank))
		if(!GLOB.configuration.general.enable_karma)
			return TRUE
		if(check_rights(R_ADMIN, 0, M))
			return TRUE
		if(!SSdbcore.IsConnected())
			return FALSE
		else
			var/datum/db_query/job_read = SSdbcore.NewQuery(
				"SELECT job FROM whitelist WHERE ckey=:ckey",
				list("ckey" = M.ckey)
			)

			if(!job_read.warn_execute(async = FALSE)) // Dont async this. Youll make roundstart slow.
				qdel(job_read)
				return FALSE

			. = FALSE
			while(job_read.NextRow())
				var/joblist = job_read.item[1]
				if(joblist != "*")
					var/allowed_jobs = splittext(joblist, ",")
					if(rank in allowed_jobs)
						. = TRUE
						break
				else
					. = TRUE
					break

			qdel(job_read)
	else
		return TRUE

/proc/is_alien_whitelisted(mob/M, species)
	if(!GLOB.configuration.general.enable_karma)
		return TRUE
	if(species == "human" || species == "Human")
		return TRUE
	if(check_rights(R_ADMIN, 0))
		return TRUE
	if(!SSdbcore.IsConnected())
		return FALSE
	else
		var/datum/db_query/species_read = SSdbcore.NewQuery(
			"SELECT species FROM whitelist WHERE ckey=:ckey",
			list("ckey" = M.ckey)
		)

		if(!species_read.warn_execute(async = FALSE)) // Dont async this one. It makes roundstart take 10 years.
			qdel(species_read)
			return FALSE

		. = FALSE
		while(species_read.NextRow())
			var/specieslist = species_read.item[1]
			if(specieslist != "*")
				var/allowed_species = splittext(specieslist, ",")
				if(species in allowed_species)
					. = TRUE
					break
			else
				. = TRUE
				break

		qdel(species_read)
