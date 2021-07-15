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
	res.ip = ip
	. = res
	if(!ip || !config.ipintel_email || !SSipintel.enabled)
		return
	if(!bypasscache)
		var/datum/ipintel/cachedintel = SSipintel.cache[ip]
		if(cachedintel && cachedintel.is_valid())
			cachedintel.cache = TRUE
			return cachedintel

		if(SSdbcore.IsConnected())
			var/datum/db_query/query_get_ip_intel = SSdbcore.NewQuery({"
				SELECT date, intel, TIMESTAMPDIFF(MINUTE,date,NOW())
				FROM [format_table_name("ipintel")]
				WHERE
					ip = INET_ATON(:ip)
					AND ((
							intel < :rating_bad
							AND
							date + INTERVAL :save_good HOUR > NOW()
						) OR (
							intel >= :rating_bad
							AND
							date + INTERVAL :save_bad HOUR > NOW()
					))
				"}, list(
					"ip" = ip,
					"rating_bad" = config.ipintel_rating_bad,
					"save_good" = config.ipintel_save_good,
					"save_bad" = config.ipintel_save_bad,
				))
			if(!query_get_ip_intel.warn_execute())
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
		if(SSdbcore.IsConnected())
			var/datum/db_query/query_add_ip_intel = SSdbcore.NewQuery({"
				INSERT INTO [format_table_name("ipintel")] (ip, intel) VALUES (INET_ATON(:ip), :intel)
				ON DUPLICATE KEY UPDATE intel = VALUES(intel), date = NOW()"},
				list(
					"ip" = ip,
					"intel" = res.intel
				)
			)
			query_add_ip_intel.warn_execute()
			qdel(query_add_ip_intel)


/proc/ip_intel_query(ip, retryed=0)
	. = -1 //default
	if(!ip)
		return
	if(SSipintel.throttle > world.timeofday)
		return
	if(!SSipintel.enabled)
		return

	// Do not refactor this to use SShttp, because that requires the subsystem to be firing for requests to be made, and this will be triggered before the MC has finished loading
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
	if(!SSdbcore.IsConnected())
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
	var/datum/db_query/query_get_ip_intel = SSdbcore.NewQuery({"
		SELECT * FROM [format_table_name("ipintel")] WHERE ip = INET_ATON(:target_ip)
		AND intel >= :rating_bad AND (date + INTERVAL :valid_hours HOUR) > NOW()"},
		list(
			"target_ip" = target_ip,
			"rating_bad" = rating_bad,
			"valid_hours" = valid_hours
		)
	)
	if(!query_get_ip_intel.warn_execute())
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
	var/datum/db_query/query_whitelist_check = SSdbcore.NewQuery("SELECT * FROM [format_table_name("vpn_whitelist")] WHERE ckey=:ckey", list(
		"ckey" = target_ckey
	))
	if(!query_whitelist_check.warn_execute())
		qdel(query_whitelist_check)
		return FALSE
	if(query_whitelist_check.NextRow())
		qdel(query_whitelist_check)
		return TRUE // At least one row in the whitelist names their ckey. That means they are whitelisted.
	qdel(query_whitelist_check)
	return FALSE

/proc/vpn_whitelist_add(target_ckey)
	var/reason_string = input(usr, "Enter link to the URL of their whitelist request on the forum.","Reason required") as message|null
	if(!reason_string)
		return FALSE
	var/datum/db_query/query_whitelist_add = SSdbcore.NewQuery("INSERT INTO [format_table_name("vpn_whitelist")] (ckey,reason) VALUES (:targetckey, :reason)", list(
		"targetckey" = target_ckey,
		"reason" = reason_string
	))
	if(!query_whitelist_add.warn_execute())
		qdel(query_whitelist_add)
		return FALSE
	qdel(query_whitelist_add)
	return TRUE

/proc/vpn_whitelist_remove(target_ckey)
	var/datum/db_query/query_whitelist_remove = SSdbcore.NewQuery("DELETE FROM [format_table_name("vpn_whitelist")] WHERE ckey=:targetckey", list(
		"targetckey" = target_ckey
	))
	if(!query_whitelist_remove.warn_execute())
		qdel(query_whitelist_remove)
		return FALSE
	qdel(query_whitelist_remove)
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
