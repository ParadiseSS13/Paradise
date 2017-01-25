#define WHITELISTFILE "data/whitelist.txt"

var/list/whitelist = list()

/hook/startup/proc/loadWhitelist()
	if(config.usewhitelist)
		load_whitelist()
	return 1

/proc/load_whitelist()
	whitelist = file2list(WHITELISTFILE)
	if(!whitelist.len)	whitelist = null
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
		if(check_rights(R_ADMIN, 0, M))
			return 1
		if(!dbcon.IsConnected())
			to_chat(usr, "\red Unable to connect to whitelist database. Please try again later.<br>")
			return 0
		else
			var/DBQuery/query = dbcon.NewQuery("SELECT job FROM [format_table_name("whitelist")] WHERE ckey='[M.key]'")
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




/var/list/alien_whitelist = list()

/hook/startup/proc/loadAlienWhitelist()
	if(config.usealienwhitelist)
		load_alienwhitelist()
	return 1

/proc/load_alienwhitelist()
	var/text = file2text("config/alienwhitelist.txt")
	if(!text)
		diary << "Failed to load config/alienwhitelist.txt\n"
	else
		alien_whitelist = splittext(text, "\n")

//todo: admin aliens
/proc/is_alien_whitelisted(mob/M, var/species)
	if(!config.usealienwhitelist)
		return 1
	if(species == "human" || species == "Human")
		return 1
	if(check_rights(R_ADMIN, 0))
		return 1
	if(!alien_whitelist)
		return 0
	if(!dbcon.IsConnected())
		to_chat(usr, "\red Unable to connect to whitelist database. Please try again later.<br>")
		return 0
	else
		var/DBQuery/query = dbcon.NewQuery("SELECT species FROM [format_table_name("whitelist")] WHERE ckey='[M.key]'")
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