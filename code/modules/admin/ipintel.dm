/datum/ipintel
	var/ip
	var/intel = 0
	var/cache = FALSE
	var/cacheminutesago = 0
	var/cachedate = ""
	var/cacherealtime = 0

/datum/ipintel/New()
	cachedate = SQLtime()
	cacherealtime = world.realtime

/datum/ipintel/proc/is_valid()
	. = FALSE
	if(intel < 0)
		return
	if(intel <= config.ipintel_rating_bad)
		if(world.realtime < cacherealtime + (config.ipintel_save_good HOURS))
			return TRUE
	else
		if(world.realtime < cacherealtime + (config.ipintel_save_bad HOURS))
			return TRUE

/proc/get_ip_intel(ip, bypasscache = FALSE, updatecache = TRUE)
	var/datum/ipintel/res = new()
	ip = sanitizeSQL(ip)
	res.ip = ip
	. = res
	if(!ip || !config.ipintel_email || !SSipintel.enabled)
		return
	if(!bypasscache)
		var/datum/ipintel/cachedintel = SSipintel.cache[ip]
		if(cachedintel && cachedintel.is_valid())
			cachedintel.cache = TRUE
			return cachedintel

		if(dbcon.IsConnected())
			var/rating_bad = config.ipintel_rating_bad
			var/DBQuery/query_get_ip_intel = dbcon.NewQuery({"
				SELECT date, intel, TIMESTAMPDIFF(MINUTE,date,NOW())
				FROM [format_table_name("ipintel")]
				WHERE
					ip = INET_ATON('[ip]')
					AND ((
							intel < [rating_bad]
							AND
							date + INTERVAL [config.ipintel_save_good] HOUR > NOW()
						) OR (
							intel >= [rating_bad]
							AND
							date + INTERVAL [config.ipintel_save_bad] HOUR > NOW()
					))
				"})
			if(!query_get_ip_intel.Execute())
				qdel(query_get_ip_intel)
				return
			if(query_get_ip_intel.NextRow())
				res.cache = TRUE
				res.cachedate = query_get_ip_intel.item[1]
				res.intel = text2num(query_get_ip_intel.item[2])
				res.cacheminutesago = text2num(query_get_ip_intel.item[3])
				res.cacherealtime = world.realtime - (text2num(query_get_ip_intel.item[3])*10*60)
				SSipintel.cache[ip] = res
				qdel(query_get_ip_intel)
				return
			qdel(query_get_ip_intel)
	res.intel = ip_intel_query(ip)
	if(updatecache && res.intel >= 0)
		SSipintel.cache[ip] = res
		if(dbcon.IsConnected())
			var/DBQuery/query_add_ip_intel = dbcon.NewQuery("INSERT INTO [format_table_name("ipintel")] (ip, intel) VALUES (INET_ATON('[ip]'), [res.intel]) ON DUPLICATE KEY UPDATE intel = VALUES(intel), date = NOW()")
			query_add_ip_intel.Execute()
			qdel(query_add_ip_intel)


/proc/ip_intel_query(ip, var/retryed=0)
	. = -1 //default
	if(!ip)
		return
	if(SSipintel.throttle > world.timeofday)
		return
	if(!SSipintel.enabled)
		return

	var/list/http[] = world.Export("http://[config.ipintel_domain]/check.php?ip=[ip]&contact=[config.ipintel_email]&format=json&flags=b")

	if(http)
		var/status = text2num(http["STATUS"])

		if(status == 200)
			var/response = json_decode(file2text(http["CONTENT"]))
			if(response)
				if(response["status"] == "success")
					var/intelnum = text2num(response["result"])
					if(isnum(intelnum))
						return text2num(response["result"])
					else
						ipintel_handle_error("Bad intel from server: [response["result"]].", ip, retryed)
						if(!retryed)
							sleep(25)
							return .(ip, 1)
				else
					ipintel_handle_error("Bad response from server: [response["status"]].", ip, retryed)
					if(!retryed)
						sleep(25)
						return .(ip, 1)

		else if(status == 429)
			ipintel_handle_error("Error #429: We have exceeded the rate limit.", ip, 1)
			return
		else
			ipintel_handle_error("Unknown status code: [status].", ip, retryed)
			if(!retryed)
				sleep(25)
				return .(ip, 1)
	else
		ipintel_handle_error("Unable to connect to API.", ip, retryed)
		if(!retryed)
			sleep(25)
			return .(ip, 1)


/proc/ipintel_handle_error(error, ip, retryed)
	if(retryed)
		SSipintel.errors++
		error += " Could not check [ip]. Disabling IPINTEL for [SSipintel.errors] minute[( SSipintel.errors == 1 ? "" : "s" )]"
		SSipintel.throttle = world.timeofday + (2 * SSipintel.errors MINUTES)
	else
		error += " Attempting retry on [ip]."
	log_ipintel(error)

/proc/log_ipintel(text)
	log_game("IPINTEL: [text]")
	log_debug("IPINTEL: [text]")


/proc/ipintel_is_banned(t_ckey, t_ip)
	if(!config.ipintel_email)
		return FALSE
	if(!config.ipintel_whitelist)
		return FALSE
	if(!dbcon.IsConnected())
		return FALSE
	if(!ipintel_badip_check(t_ip))
		return FALSE
	if(vpn_whitelist_check(t_ckey))
		return FALSE
	return TRUE

/proc/ipintel_badip_check(target_ip)
	var/rating_bad = config.ipintel_rating_bad
	if(!rating_bad)
		log_debug("ipintel_badip_check reports misconfigured rating_bad directive")
		return FALSE
	var/valid_hours = config.ipintel_save_bad
	if(!valid_hours)
		log_debug("ipintel_badip_check reports misconfigured ipintel_save_bad directive")
		return FALSE
	target_ip = sanitizeSQL(target_ip)
	rating_bad = sanitizeSQL(rating_bad)
	valid_hours = sanitizeSQL(valid_hours)
	var/check_sql = {"SELECT * FROM [format_table_name("ipintel")] WHERE ip = INET_ATON('[target_ip]') AND intel >= [rating_bad] AND (date + INTERVAL [valid_hours] HOUR) > NOW()"}
	var/DBQuery/query_get_ip_intel = dbcon.NewQuery(check_sql)
	if(!query_get_ip_intel.Execute())
		log_debug("ipintel_badip_check reports failed query execution")
		qdel(query_get_ip_intel)
		return FALSE
	if(!query_get_ip_intel.NextRow())
		qdel(query_get_ip_intel)
		return FALSE
	qdel(query_get_ip_intel)
	return TRUE

/proc/vpn_whitelist_check(target_ckey)
	if(!config.ipintel_whitelist)
		return FALSE
	var/target_sql_ckey = ckey(target_ckey)
	var/DBQuery/query_whitelist_check = dbcon.NewQuery("SELECT * FROM [format_table_name("vpn_whitelist")] WHERE ckey = '[target_sql_ckey]'")
	if(!query_whitelist_check.Execute())
		var/err = query_whitelist_check.ErrorMsg()
		log_debug("SQL ERROR on proc/vpn_whitelist_check for ckey '[target_sql_ckey]'. Error : \[[err]\]\n")
		return FALSE
	if(query_whitelist_check.NextRow())
		return TRUE // At least one row in the whitelist names their ckey. That means they are whitelisted.
	return FALSE

/proc/vpn_whitelist_add(target_ckey)
	var/target_sql_ckey = ckey(target_ckey)
	var/reason_string = input(usr, "Enter link to the URL of their whitelist request on the forum.","Reason required") as message|null
	if(!reason_string)
		return FALSE
	reason_string = sanitizeSQL(reason_string)
	var/DBQuery/query_whitelist_add = dbcon.NewQuery("INSERT INTO [format_table_name("vpn_whitelist")] (ckey,reason) VALUES ('[target_sql_ckey]','[reason_string]')")
	if(!query_whitelist_add.Execute())
		var/err = query_whitelist_add.ErrorMsg()
		log_debug("SQL ERROR on proc/vpn_whitelist_add for ckey '[target_sql_ckey]'. Error : \[[err]\]\n")
		return FALSE
	return TRUE

/proc/vpn_whitelist_remove(target_ckey)
	var/target_sql_ckey = ckey(target_ckey)
	var/DBQuery/query_whitelist_remove = dbcon.NewQuery("DELETE FROM [format_table_name("vpn_whitelist")] WHERE ckey = '[target_sql_ckey]'")
	if(!query_whitelist_remove.Execute())
		var/err = query_whitelist_remove.ErrorMsg()
		log_debug("SQL ERROR on proc/vpn_whitelist_remove for ckey '[target_sql_ckey]'. Error : \[[err]\]\n")
		return FALSE
	return TRUE

/proc/vpn_whitelist_panel(target_ckey as text)
	if(!check_rights(R_ADMIN))
		return
	if(!target_ckey)
		return
	var/is_already_whitelisted = vpn_whitelist_check(target_ckey)
	if(is_already_whitelisted)
		var/confirm = alert("[target_ckey] is already whitelisted. Remove them?", "Confirm Removal", "No", "Yes")
		if(!confirm || confirm != "Yes")
			to_chat(usr, "VPN whitelist alteration cancelled.")
			return
		else if(vpn_whitelist_remove(target_ckey))
			to_chat(usr, "[target_ckey] was removed from the VPN whitelist.")
		else
			to_chat(usr, "VPN whitelist unchanged.")
	else
		if(vpn_whitelist_add(target_ckey))
			to_chat(usr, "[target_ckey] was added to the VPN whitelist.")
		else
			to_chat(usr, "VPN whitelist unchanged.")