//Blocks an attempt to connect before even creating our client datum thing.
/world/IsBanned(key, address, computer_id, type, check_ipintel = TRUE, check_2fa = TRUE, check_guest = TRUE, log_info = TRUE, check_tos = TRUE)

	if(!key || !address || !computer_id)
		log_adminwarn("Failed Login (invalid data): [key] [address]-[computer_id]")
		// The nested ternaries are needed here
		if(log_info)
			INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(log_connection), (ckey(key) || ""), (address || ""), (computer_id || ""), CONNECTION_TYPE_DROPPED_INVALID)
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, please try again. Error message: Your computer provided invalid or blank information to the server on connection (BYOND Username, IP, and Computer ID). Provided information for reference: Username: '[key]' IP: '[address]' Computer ID: '[computer_id]'. If you continue to get this error, please restart byond or contact byond support.")

	if(type == "world")
		return ..() //shunt world topic banchecks to purely to byond's internal ban system

	if(text2num(computer_id) == 2147483647) //this cid causes bans to go haywire
		log_adminwarn("Failed Login (invalid cid): [key] [address]-[computer_id]")
		if(log_info)
			INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(log_connection), ckey(key), address, computer_id, CONNECTION_TYPE_DROPPED_INVALID)
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, Please try again. Error message: Your computer provided an invalid Computer ID.")

	var/admin = 0
	var/ckey = ckey(key)

	var/client/C = GLOB.directory[ckey]
	if(C && ckey == C.ckey && computer_id == C.computer_id && address == C.address)
		return //don't recheck connected clients.

	if((ckey in GLOB.admin_datums) || (ckey in GLOB.de_admins))
		var/datum/admins/A = GLOB.admin_datums[ckey]
		if(A && (A.rights & R_ADMIN))
			admin = 1

	// Lets see if they are logged in on another paradise server
	if(SSdbcore.IsConnected())
		var/other_server_login = SSinstancing.check_player(ckey)
		if(other_server_login)
			return list("reason"="duplicate login", "desc"="\nReason: You are already logged in on server '[other_server_login]'. Please contact the server host if you believe this is an error.")

	//Guest Checking
	if(GLOB.configuration.general.guest_ban && check_guest && IsGuestKey(key))
		log_adminwarn("Failed Login: [key] [computer_id] [address] - Guests not allowed")
		// message_admins("<span class='notice'>Failed Login: [key] - Guests not allowed</span>")
		if(log_info)
			INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(log_connection), ckey(key), address, computer_id, CONNECTION_TYPE_DROPPED_BANNED)
		return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a BYOND account.")

	// Check if we are checking TOS consent before connecting
	if(SSdbcore.IsConnected() && GLOB.configuration.system.external_tos_handler && check_tos)
		// Check if they have a TOS consent
		var/datum/db_query/check_query = SSdbcore.NewQuery("SELECT ckey FROM privacy WHERE ckey=:ckey AND consent=1", list("ckey" = ckey(key)))

		// This is the one case where we will NOT allow entry on DB failure.
		// If a user doesn't consent to us having their data, we arent having their data.
		// Period
		if(!check_query.warn_execute())
			qdel(check_query)
			return list("reason"="tos", "desc"="\nReason: Failed to check ToS consent. If this error persists, please contact the server host.")

		// If there is no row, they didnt accept
		if(!check_query.NextRow())
			qdel(check_query)
			return list("reason"="tos", "desc"="\nReason: You are trying to connect without accepting server ToS. If you did not get a ToS popup, please go to paradise13.org/fixtos")

		qdel(check_query)
		// As per my comment 8 or so lines above, we do NOT log failed connections here

	//check if the IP address is a known proxy/vpn, and the user is not whitelisted
	if(check_ipintel && GLOB.configuration.ipintel.contact_email && GLOB.configuration.ipintel.whitelist_mode && GLOB.ipintel_manager.ipintel_is_banned(key, address))
		log_adminwarn("Failed Login: [key] [computer_id] [address] - Proxy/VPN")
		var/mistakemessage = ""
		if(GLOB.configuration.url.banappeals_url)
			mistakemessage = "\nIf you have to use one, request whitelisting at:  [GLOB.configuration.url.banappeals_url]"
		if(log_info)
			INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(log_connection), ckey(key), address, computer_id, CONNECTION_TYPE_DROPPED_IPINTEL)
		return list("reason"="using proxy or vpn", "desc"="\nReason: Proxies/VPNs are not allowed here. [mistakemessage]")


	// If 2FA is enabled, makes sure they were authed within the last minute
	if(check_2fa && GLOB.configuration.system.api_host)
		// First see if they exist at all
		var/datum/db_query/check_query = SSdbcore.NewQuery("SELECT 2fa_status, ip FROM player WHERE ckey=:ckey", list("ckey" = ckey(key)))

		if(!check_query.warn_execute())
			message_admins("Failed to do a DB 2FA check for [key]. You have been warned.")
			qdel(check_query)
			return


		// If a row is returned, the player exists
		var/_2fa_enabled = FALSE
		var/always_check = FALSE
		var/last_ip
		if(check_query.NextRow())
			if(check_query.item[1] != _2FA_DISABLED)
				_2fa_enabled = TRUE
			if(check_query.item[1] == _2FA_ENABLED_ALWAYS)
				always_check = TRUE
			last_ip = check_query.item[2]
		qdel(check_query)

		// If client has 2FA enabled, and they either:
		// Have it set to always check, or their IP is different
		if(_2fa_enabled && (always_check || (address != last_ip)))
			// They have 2FA enabled, lets make sure they have authed within the last minute
			var/datum/db_query/verify_query = SSdbcore.NewQuery("SELECT ckey FROM 2fa_secrets WHERE (last_time BETWEEN NOW() - INTERVAL 1 MINUTE AND NOW()) AND ckey=:ckey LIMIT 1", list(
				"ckey" = ckey(key)
			))

			if(!verify_query.warn_execute())
				message_admins("Failed to do a DB 2FA check for [key]. You have been warned.")
				qdel(verify_query)
				return

			if(!verify_query.NextRow())
				// If no row was returned, fail 2FA
				qdel(verify_query)
				return list("reason"="2fa check failed", "desc"="You have 2FA enabled but did not properly authenticate.")

			qdel(verify_query)

	if(SSdbcore.IsConnected())
		// If we have a DB, see if the player has been seen before
		var/datum/db_query/exist_query = SSdbcore.NewQuery("SELECT ckey FROM player WHERE ckey=:ckey", list(
			"ckey" = ckey
		))
		// If we didnt execute, skip this part
		if(!exist_query.warn_execute())
			qdel(exist_query)
		else
			if(!exist_query.NextRow()) // If there isnt a row, they aint been seen before
				if(SSqueue?.queue_enabled && (length(GLOB.clients) > SSqueue.queue_threshold) && !(ckey in SSqueue.queue_bypass_list))
					qdel(exist_query)
					return list("reason" = "server queue", "desc" = "You seem to have managed to skip the server queue, possibly due to connecting during a restart. Please reconnect in 10 minutes. If you still cannot connect, please inform the server host.")

		qdel(exist_query)

	var/ckeytext = ckey(key)

	if(!SSdbcore.IsConnected())
		log_world("Ban database connection failure. Key [ckeytext] not checked")
		return

	var/list/sql_query_params = list(
		"ckeytext" = ckeytext
	)

	var/ipquery = ""
	var/cidquery = ""
	if(address)
		ipquery = " OR ip=:ip "
		sql_query_params["ip"] = address

	if(computer_id)
		cidquery = " OR computerid=:cid "
		sql_query_params["cid"] = computer_id

	var/datum/db_query/query = SSdbcore.NewQuery({"
	SELECT ckey, ip, computerid, a_ckey, reason, expiration_time, duration, bantime, bantype, ban_round_id FROM ban
	WHERE (ckey=:ckeytext [ipquery] [cidquery]) AND (bantype = 'PERMABAN' OR bantype = 'ADMIN_PERMABAN'
	OR ((bantype = 'TEMPBAN' OR bantype = 'ADMIN_TEMPBAN') AND expiration_time > Now())) AND isnull(unbanned)"}, sql_query_params)

	if(!query.warn_execute())
		message_admins("Failed to do a DB ban check for [ckeytext]. You have been warned.")
		qdel(query)
		return

	while(query.NextRow())
		var/pckey = query.item[1]
		//var/pip = query.item[2]
		//var/pcid = query.item[3]
		var/ackey = query.item[4]
		var/reason = query.item[5]
		var/expiration = query.item[6]
		var/duration = query.item[7]
		var/bantime = query.item[8]
		var/bantype = query.item[9]
		var/ban_round_id = query.item[10]
		if(bantype == "ADMIN_PERMABAN" || bantype == "ADMIN_TEMPBAN")
			//admin bans MUST match on ckey to prevent cid-spoofing attacks
			//	as well as dynamic ip abuse
			if(pckey != ckey)
				continue
		if(admin)
			if(bantype == "ADMIN_PERMABAN" || bantype == "ADMIN_TEMPBAN")
				log_admin("The admin [key] is admin banned, and has been disallowed access")
				message_admins("<span class='adminnotice'>The admin [key] is admin banned, and has been disallowed access</span>")
			else
				log_admin("The admin [key] has been allowed to bypass a matching ban on [pckey]")
				message_admins("<span class='adminnotice'>The admin [key] has been allowed to bypass a matching ban on [pckey]</span>")
				addclientmessage(ckey,"<span class='adminnotice'>You have been allowed to bypass a matching ban on [pckey].</span>")
				continue
		var/expires = ""
		if(text2num(duration) > 0)
			expires = " The ban is for [duration] minutes and expires on [expiration] (server time)."
		else
			var/appealmessage = ""
			if(GLOB.configuration.url.banappeals_url)
				appealmessage = " You may appeal it at <a href='[GLOB.configuration.url.banappeals_url]'>[GLOB.configuration.url.banappeals_url]</a>."
			expires = " This ban does not expire automatically and must be appealed.[appealmessage]"

		var/desc = "\nReason: You, or another user of this computer or connection ([pckey]) is banned from playing here. The ban reason is:\n[reason]\nThis ban was applied by [ackey] on [bantime][ban_round_id ? " (Round [ban_round_id])" : ""].[expires]"

		. = list("reason"="[bantype]", "desc"="[desc]")

		log_adminwarn("Failed Login: [key] [computer_id] [address] - Banned [.["reason"]]")
		if(log_info)
			INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(log_connection), ckey(key), address, computer_id, CONNECTION_TYPE_DROPPED_BANNED)
		qdel(query)
		return .
	qdel(query)

	. = ..()	//default pager ban stuff
	if(.)
		//byond will not trigger isbanned() for "global" host bans,
		//ie, ones where the "apply to this game only" checkbox is not checked (defaults to not checked)
		//So it's safe to let admins walk thru bans here
		if(admin)
			log_admin("The admin [key] has been allowed to bypass a matching ban")
			message_admins("<span class='adminnotice'>The admin [key] has been allowed to bypass a matching ban</span>")
			addclientmessage(ckey,"<span class='adminnotice'>You have been allowed to bypass a matching ban.</span>")
			return null
		else
			log_adminwarn("Failed Login: [key] [computer_id] [address] - Banned [.["message"]]")
			if(log_info)
				INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(log_connection), ckey(key), address, computer_id, CONNECTION_TYPE_DROPPED_BANNED)
	return .
