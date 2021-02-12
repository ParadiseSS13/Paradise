#define WHITELISTFILE "data/whitelist.txt"

GLOBAL_LIST_EMPTY(whitelist)

/proc/init_whitelists()
	if(config.usewhitelist)
		load_whitelist()
	if(config.usealienwhitelist)
		load_alienwhitelist()

/proc/load_whitelist()
	GLOB.whitelist = file2list(WHITELISTFILE)
	if(!GLOB.whitelist.len)
		GLOB.whitelist = null
/*
/proc/check_whitelist(mob/M, var/rank)
	if(!whitelist)
		return 0
	return ("[M.ckey]" in whitelist)
*/

/proc/is_job_whitelisted(mob/M, var/rank)
	if(guest_jobbans(rank))
		if(!config.usewhitelist)
			return TRUE
		if(config.disable_karma)
			return TRUE
		if(check_rights(R_ADMIN, 0, M))
			return TRUE
		if(!SSdbcore.IsConnected())
			return FALSE
		else
			var/datum/db_query/job_read = SSdbcore.NewQuery(
				"SELECT job FROM [format_table_name("whitelist")] WHERE ckey=:ckey",
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




GLOBAL_LIST_EMPTY(alien_whitelist)

/proc/load_alienwhitelist()
	var/text = file2text("config/alienwhitelist.txt")
	if(!text)
		log_config("Failed to load config/alienwhitelist.txt\n")
	else
		GLOB.alien_whitelist = splittext(text, "\n")

//todo: admin aliens
/proc/is_alien_whitelisted(mob/M, var/species)
	if(!config.usealienwhitelist)
		return TRUE
	if(config.disable_karma)
		return TRUE
	if(species == "human" || species == "Human")
		return TRUE
	if(check_rights(R_ADMIN, 0))
		return TRUE
	if(!GLOB.alien_whitelist)
		return FALSE
	if(!SSdbcore.IsConnected())
		return FALSE
	else
		var/datum/db_query/species_read = SSdbcore.NewQuery(
			"SELECT species FROM [format_table_name("whitelist")] WHERE ckey=:ckey",
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
/*
	if(M && species)
		for(var/s in alien_whitelist)
			if(findtext(s,"[M.ckey] - [species]"))
				return 1
			if(findtext(s,"[M.ckey] - All"))
				return 1
*/


#undef WHITELISTFILE
