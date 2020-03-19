#define WHITELISTFILE "data/whitelist.txt"

GLOBAL_LIST_EMPTY(whitelist)

/hook/startup/proc/loadWhitelist()
	if(config.usewhitelist)
		load_whitelist()
	return 1

/proc/load_whitelist()
	GLOB.whitelist = file2list(WHITELISTFILE)
	if(!GLOB.whitelist.len)	GLOB.whitelist = null
/*
/proc/check_whitelist(mob/M, var/rank)
	if(!whitelist)
		return 0
	return ("[M.ckey]" in whitelist)
*/

/proc/is_job_whitelisted(mob/M, var/rank)
	if(guest_jobbans(rank))
		if(!config.usewhitelist)
			return 1
		if(config.disable_karma)
			return 1
		if(check_rights(R_ADMIN, 0, M))
			return 1
		if(!GLOB.dbcon.IsConnected())
			to_chat(usr, "<span class='warning'>Unable to connect to whitelist database. Please try again later.<br></span>")
			return 0
		else
			var/DBQuery/query = GLOB.dbcon.NewQuery("SELECT job FROM [format_table_name("whitelist")] WHERE ckey='[M.ckey]'")
			query.Execute()


			while(query.NextRow())
				var/joblist = query.item[1]
				if(joblist!="*")
					var/allowed_jobs = splittext(joblist,",")
					if(rank in allowed_jobs) return 1
				else return 1
			return 0
	else
		return 1




GLOBAL_LIST_EMPTY(alien_whitelist)

/hook/startup/proc/loadAlienWhitelist()
	if(config.usealienwhitelist)
		load_alienwhitelist()
	return 1

/proc/load_alienwhitelist()
	var/text = file2text("config/alienwhitelist.txt")
	if(!text)
		log_config("Failed to load config/alienwhitelist.txt\n")
	else
		GLOB.alien_whitelist = splittext(text, "\n")

//todo: admin aliens
/proc/is_alien_whitelisted(mob/M, var/species)
	if(!config.usealienwhitelist)
		return 1
	if(config.disable_karma)
		return 1
	if(species == "human" || species == "Human")
		return 1
	if(check_rights(R_ADMIN, 0))
		return 1
	if(!GLOB.alien_whitelist)
		return 0
	if(!GLOB.dbcon.IsConnected())
		to_chat(usr, "<span class='warning'>Unable to connect to whitelist database. Please try again later.<br></span>")
		return 0
	else
		var/DBQuery/query = GLOB.dbcon.NewQuery("SELECT species FROM [format_table_name("whitelist")] WHERE ckey='[M.ckey]'")
		query.Execute()

		while(query.NextRow())
			var/specieslist = query.item[1]
			if(specieslist!="*")
				var/allowed_species = splittext(specieslist,",")
				if(species in allowed_species) return 1
			else return 1
		return 0
/*
	if(M && species)
		for(var/s in alien_whitelist)
			if(findtext(s,"[M.ckey] - [species]"))
				return 1
			if(findtext(s,"[M.ckey] - All"))
				return 1
*/


#undef WHITELISTFILE
