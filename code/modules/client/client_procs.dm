	////////////
	//SECURITY//
	////////////
//debugging, uncomment for viewing topic calls
//#define TOPIC_DEBUGGING 1

#define TOPIC_SPAM_DELAY	2		//2 ticks is about 2/10ths of a second; it was 4 ticks, but that caused too many clicks to be lost due to lag
#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 10MB //Boosted this thing. What's the worst that can happen?
#define MIN_CLIENT_VERSION	513		// Minimum byond major version required to play.
									//I would just like the code ready should it ever need to be used.
#define SUGGESTED_CLIENT_VERSION	513		// only integers (e.g: 513, 514) are useful here. This is the part BEFORE the ".", IE 513 out of 513.1536
#define SUGGESTED_CLIENT_BUILD	1536		// only integers (e.g: 1536, 1539) are useful here. This is the part AFTER the ".", IE 1536 out of 513.1536

#define SSD_WARNING_TIMER 30 // cycles, not seconds, so 30=60s

#define LIMITER_SIZE	5
#define CURRENT_SECOND	1
#define SECOND_COUNT	2
#define CURRENT_MINUTE	3
#define MINUTE_COUNT	4
#define ADMINSWARNED_AT	5

	/*
	When somebody clicks a link in game, this Topic is called first.
	It does the stuff in this proc and  then is redirected to the Topic() proc for the src=[0xWhatever]
	(if specified in the link). ie locate(hsrc).Topic()

	Such links can be spoofed.

	Because of this certain things MUST be considered whenever adding a Topic() for something:
		- Can it be fed harmful values which could cause runtimes?
		- Is the Topic call an admin-only thing?
		- If so, does it have checks to see if the person who called it (usr.client) is an admin?
		- Are the processes being called by Topic() particularly laggy?
		- If so, is there any protection against somebody spam-clicking a link?
	If you have any  questions about this stuff feel free to ask. ~Carn
	*/
/client/Topic(href, href_list, hsrc)
	if(!usr || usr != mob)	//stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return

	// src should always be a UID; if it isn't, warn instead of failing entirely
	if(href_list["src"])
		hsrc = locateUID(href_list["src"])
		// If there's a ]_ in the src, it's a UID, so don't try to locate it
		if(!hsrc && !findtext(href_list["src"], "]_"))
			hsrc = locate(href_list["src"])
			if(hsrc)
				var/hsrc_info = datum_info_line(hsrc) || "[hsrc]"
				log_runtime(EXCEPTION("Got \\ref-based src in topic from [src] for [hsrc_info], should be UID: [href]"))

	#if defined(TOPIC_DEBUGGING)
	to_chat(world, "[src]'s Topic: [href] destined for [hsrc].")
	#endif

	if(href_list["asset_cache_confirm_arrival"])
//		to_chat(src, "ASSET JOB [href_list["asset_cache_confirm_arrival"]] ARRIVED.")
		var/job = text2num(href_list["asset_cache_confirm_arrival"])
		completed_asset_jobs += job
		return

	if(href_list["_src_"] == "chat")
		return chatOutput.Topic(href, href_list)

	// Rate limiting
	var/mtl = 100 // 100 topics per minute
	if (!holder) // Admins are allowed to spam click, deal with it.
		var/minute = round(world.time, 600)
		if (!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if (minute != topiclimiter[CURRENT_MINUTE])
			topiclimiter[CURRENT_MINUTE] = minute
			topiclimiter[MINUTE_COUNT] = 0
		topiclimiter[MINUTE_COUNT] += 1
		if (topiclimiter[MINUTE_COUNT] > mtl)
			var/msg = "Your previous action was ignored because you've done too many in a minute."
			if (minute != topiclimiter[ADMINSWARNED_AT]) //only one admin message per-minute. (if they spam the admins can just boot/ban them)
				topiclimiter[ADMINSWARNED_AT] = minute
				msg += " Administrators have been informed."
				log_game("[key_name(src)] Has hit the per-minute topic limit of [mtl] topic calls in a given game minute")
				message_admins("[ADMIN_LOOKUPFLW(usr)] Has hit the per-minute topic limit of [mtl] topic calls in a given game minute")
			to_chat(src, "<span class='danger'>[msg]</span>")
			return

	var/stl = 10 // 10 topics a second
	if (!holder) // Admins are allowed to spam click, deal with it.
		var/second = round(world.time, 10)
		if (!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if (second != topiclimiter[CURRENT_SECOND])
			topiclimiter[CURRENT_SECOND] = second
			topiclimiter[SECOND_COUNT] = 0
		topiclimiter[SECOND_COUNT] += 1
		if (topiclimiter[SECOND_COUNT] > stl)
			to_chat(src, "<span class='danger'>Your previous action was ignored because you've done too many in a second</span>")
			return

	//search the href for script injection
	if( findtext(href,"<script",1,0) )
		log_world("Attempted use of scripts within a topic call, by [src]")
		log_runtime(EXCEPTION("Attempted use of scripts within a topic call, by [src]"), src)
		message_admins("Attempted use of scripts within a topic call, by [src]")
		return

	//Admin PM
	if(href_list["priv_msg"])
		var/ckey_txt = href_list["priv_msg"]

		cmd_admin_pm(ckey_txt, null, href_list["type"])
		return

	if(href_list["discord_msg"])
		if(!holder && received_discord_pm < world.time - 6000) // Worse they can do is spam discord for 10 minutes
			to_chat(usr, "<span class='warning'>You are no longer able to use this, it's been more then 10 minutes since an admin on Discord has responded to you</span>")
			return
		if(prefs.muted & MUTE_ADMINHELP)
			to_chat(usr, "<span class='warning'>You cannot use this as your client has been muted from sending messages to the admins on Discord</span>")
			return
		cmd_admin_discord_pm()
		return



	//Logs all hrefs
	if(config && config.log_hrefs)
		log_href("[src] (usr:[usr]\[[COORD(usr)]\]) : [hsrc ? "[hsrc] " : ""][href]")

	if(href_list["karmashop"])
		if(config.disable_karma)
			return

		switch(href_list["karmashop"])
			if("tab")
				karma_tab = text2num(href_list["tab"])
				karmashopmenu()
				return
			if("shop")
				if(href_list["KarmaBuy"])
					var/karma=verify_karma()
					if(isnull(karma)) //Doesn't display anything if karma database is down.
						return
					switch(href_list["KarmaBuy"])
						if("1")
							karma_purchase(karma,5,"job","Barber")
						if("2")
							karma_purchase(karma,5,"job","Brig Physician")
						if("3")
							karma_purchase(karma,30,"job","Nanotrasen Representative")
						if("5")
							karma_purchase(karma,30,"job","Blueshield")
						if("6")
							karma_purchase(karma,30,"job","Mechanic")
						if("7")
							karma_purchase(karma,45,"job","Magistrate")
						if("9")
							karma_purchase(karma,30,"job","Security Pod Pilot")
					return
				if(href_list["KarmaBuy2"])
					var/karma=verify_karma()
					if(isnull(karma)) //Doesn't display anything if karma database is down.
						return
					switch(href_list["KarmaBuy2"])
						if("1")
							karma_purchase(karma,15,"species","Machine People","Machine")
						if("2")
							karma_purchase(karma,30,"species","Kidan")
						if("3")
							karma_purchase(karma,30,"species","Grey")
						if("4")
							karma_purchase(karma,45,"species","Vox")
						if("5")
							karma_purchase(karma,45,"species","Slime People")
						if("6")
							karma_purchase(karma,45,"species","Plasmaman")
						if("7")
							karma_purchase(karma,30,"species","Drask")
					return
				if(href_list["KarmaRefund"])
					var/type = href_list["KarmaRefundType"]
					var/job = href_list["KarmaRefund"]
					var/cost = href_list["KarmaRefundCost"]
					karmarefund(type,job,cost)
					return

	switch(href_list["_src_"])
		if("holder")	hsrc = holder
		if("usr")		hsrc = mob
		if("prefs")		return prefs.process_link(usr,href_list)
		if("vars")		return view_var_Topic(href,href_list,hsrc)

	if(href_list["ssdwarning"])
		ssd_warning_acknowledged = TRUE
		to_chat(src, "<span class='notice'>SSD warning acknowledged.</span>")
	if(href_list["link_forum_account"])
		link_forum_account()
		return // prevents a recursive loop where the ..() 5 lines after this makes the proc endlessly re-call itself
	switch(href_list["action"])
		if("openLink")
			src << link(href_list["link"])

	..()	//redirect to hsrc.Topic()

/client/proc/is_content_unlocked()
	if(!prefs.unlock_content)
		to_chat(src, "Become a BYOND member to access member-perks and features, as well as support the engine that makes this game possible. <a href='http://www.byond.com/membership'>Click here to find out more</a>.")
		return 0
	return 1

//Like for /atoms, but clients are their own snowflake FUCK
/client/proc/setDir(newdir)
	dir = newdir

/client/proc/handle_spam_prevention(var/message, var/mute_type, var/throttle = 0)
	if(throttle)
		if((last_message_time + throttle > world.time) && !check_rights(R_ADMIN, 0))
			var/wait_time = round(((last_message_time + throttle) - world.time) / 10, 1)
			to_chat(src, "<span class='danger'>You are sending messages to quickly. Please wait [wait_time] [wait_time == 1 ? "second" : "seconds"] before sending another message.</span>")
			return 1
		last_message_time = world.time
	if(config.automute_on && !check_rights(R_ADMIN, 0) && last_message == message)
		last_message_count++
		if(last_message_count >= SPAM_TRIGGER_AUTOMUTE)
			to_chat(src, "<span class='danger'>You have exceeded the spam filter limit for identical messages. An auto-mute was applied.</span>")
			cmd_admin_mute(mob, mute_type, 1)
			return 1
		if(last_message_count >= SPAM_TRIGGER_WARNING)
			to_chat(src, "<span class='danger'>You are nearing the spam filter limit for identical messages.</span>")
			return 0
	else
		last_message = message
		last_message_count = 0
		return 0

//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(filelength > UPLOAD_LIMIT)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>")
		return 0
/*	//Don't need this at the moment. But it's here if it's needed later.
	//Helps prevent multiple files being uploaded at once. Or right after eachother.
	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		to_chat(src, "<font color='red'>Error: AllowUpload(): Spam prevention. Please wait [round(time_to_wait/10)] seconds.</font>")
		return 0
	fileaccess_timer = world.time + FTPDELAY	*/
	return 1


	///////////
	//CONNECT//
	///////////
/client/New(TopicData)
	var/tdata = TopicData //save this for later use
	chatOutput = new /datum/chatOutput(src) // Right off the bat.
	TopicData = null							//Prevent calls to client.Topic from connect

	if(connection != "seeker")					//Invalid connection type.
		return null
	if(byond_version < MIN_CLIENT_VERSION) // Too out of date to play at all. Unfortunately, we can't send them a message here.
		version_blocked = TRUE
	if(byond_build < config.minimum_client_build)
		version_blocked = TRUE

	var/show_update_prompt = FALSE
	if(byond_version < SUGGESTED_CLIENT_VERSION) // Update is suggested, but not required.
		show_update_prompt = TRUE
	else if(byond_version == SUGGESTED_CLIENT_VERSION && byond_build < SUGGESTED_CLIENT_BUILD)
		show_update_prompt = TRUE
	// Actually sent to client much later, so it appears after MOTD.

	to_chat(src, "<span class='warning'>If the title screen is black, resources are still downloading. Please be patient until the title screen appears.</span>")

	GLOB.directory[ckey] = src
	//Admin Authorisation
	// Automatically makes localhost connection an admin
	if(!config.disable_localhost_admin)
		if(is_connecting_from_localhost())
			new /datum/admins("!LOCALHOST!", R_HOST, ckey) // Makes localhost rank
	holder = GLOB.admin_datums[ckey]
	if(holder)
		GLOB.admins += src
		holder.owner = src

	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = GLOB.preferences_datums[ckey]
	if(!prefs)
		prefs = new /datum/preferences(src)
		GLOB.preferences_datums[ckey] = prefs
	else
		prefs.parent = src
	prefs.last_ip = address				//these are gonna be used for banning
	prefs.last_id = computer_id			//these are gonna be used for banning
	if(world.byond_version >= 511 && byond_version >= 511 && prefs.clientfps)
		fps = prefs.clientfps

	// Check if the client has or has not accepted TOS
	check_tos_consent()

	// This has to go here to avoid issues
	// If you sleep past this point, you will get SSinput errors as well as goonchat errors
	// DO NOT STUFF RANDOM SQL QUERIES BELOW THIS POINT WITHOUT USING `INVOKE_ASYNC()` OR SIMILAR
	// YOU WILL BREAK STUFF. SERIOUSLY. -aa07
	GLOB.clients += src

	spawn() // Goonchat does some non-instant checks in start()
		chatOutput.start()

	if( (world.address == address || !address) && !GLOB.host )
		GLOB.host = key
		world.update_status()

	if(holder)
		on_holder_add()
		add_admin_verbs()
		// Must be async because any sleeps (happen in sql queries) will break connectings clients
		INVOKE_ASYNC(src, .proc/admin_memo_output, "Show", FALSE, TRUE)

	// Forcibly enable hardware-accelerated graphics, as we need them for the lighting overlays.
	// (but turn them off first, since sometimes BYOND doesn't turn them on properly otherwise)
	spawn(5) // And wait a half-second, since it sounds like you can do this too fast.
		if(src)
			winset(src, null, "command=\".configure graphics-hwmode off\"")
			winset(src, null, "command=\".configure graphics-hwmode on\"")

	log_client_to_db(tdata)
	. = ..()	//calls mob.Login()


	if(ckey in GLOB.clientmessages)
		for(var/message in GLOB.clientmessages[ckey])
			to_chat(src, message)
		GLOB.clientmessages.Remove(ckey)

	if(SSinput.initialized)
		set_macros()

	donator_check()
	check_ip_intel()
	send_resources()

	if(prefs.toggles & PREFTOGGLE_UI_DARKMODE) // activates dark mode if its flagged. -AA07
		activate_darkmode()
	else
		// activate_darkmode() calls the CL update button proc, so we dont want it double called
		SSchangelog.UpdatePlayerChangelogButton(src)


	if(prefs.toggles & PREFTOGGLE_DISABLE_KARMA) // activates if karma is disabled
		to_chat(src,"<span class='notice'>You have disabled karma gains.") // reminds those who have it disabled
	else
		to_chat(src,"<span class='notice'>You have enabled karma gains.")

	generate_clickcatcher()
	apply_clickcatcher()

	if(show_update_prompt)
		show_update_notice()

	check_forum_link()

	if(GLOB.custom_event_msg && GLOB.custom_event_msg != "")
		to_chat(src, "<h1 class='alert'>Custom Event</h1>")
		to_chat(src, "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>")
		to_chat(src, "<span class='alert'>[html_encode(GLOB.custom_event_msg)]</span>")
		to_chat(src, "<br>")

	if(!winexists(src, "asset_cache_browser")) // The client is using a custom skin, tell them.
		to_chat(src, "<span class='warning'>Unable to access asset cache browser, if you are using a custom skin file, please allow DS to download the updated version, if you are not, then make a bug report. This is not a critical issue but can cause issues with resource downloading, as it is impossible to know when extra resources arrived to you.</span>")
	//This is down here because of the browse() calls in tooltip/New()
	if(!tooltips)
		tooltips = new /datum/tooltip(src)

	Master.UpdateTickRate()

	// Check total playercount
	var/playercount = 0
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			playercount += 1

	// Update the state of the panic bunker based on current playercount
	var/threshold = config.panic_bunker_threshold

	if((playercount > threshold) && (GLOB.panic_bunker_enabled == FALSE))
		GLOB.panic_bunker_enabled = TRUE
		message_admins("Panic bunker has been automatically enabled due to playercount rising above [threshold]")

	if((playercount < threshold) && (GLOB.panic_bunker_enabled == TRUE))
		GLOB.panic_bunker_enabled = FALSE
		message_admins("Panic bunker has been automatically disabled due to playercount dropping below [threshold]")

/client/proc/is_connecting_from_localhost()
	var/localhost_addresses = list("127.0.0.1", "::1") // Adresses
	if(!isnull(address) && (address in localhost_addresses))
		return TRUE
	return FALSE

//////////////
//DISCONNECT//
//////////////

/client/Del()
	if(!gc_destroyed)
		Destroy() //Clean up signals and timers.
	return ..()

/client/Destroy()
	if(holder)
		holder.owner = null
		GLOB.admins -= src
	GLOB.directory -= ckey
	GLOB.clients -= src
	if(movingmob)
		movingmob.client_mobs_in_contents -= mob
		UNSETEMPTY(movingmob.client_mobs_in_contents)
	Master.UpdateTickRate()
	..() //Even though we're going to be hard deleted there are still some things that want to know the destroy is happening
	return QDEL_HINT_HARDDEL_NOW


/client/proc/donator_check()
	set waitfor = FALSE // This needs to run async because any sleep() inside /client/New() breaks stuff badly
	if(IsGuestKey(key))
		return

	if(!SSdbcore.IsConnected())
		return

	if(check_rights(R_ADMIN, 0, mob)) // Yes, the mob is required, regardless of other examples in this file, it won't work otherwise
		donator_level = DONATOR_LEVEL_MAX
		donor_loadout_points()
		return

	//Donator stuff.
	var/datum/db_query/query_donor_select = SSdbcore.NewQuery("SELECT ckey, tier, active FROM `[format_table_name("donators")]` WHERE ckey=:ckey", list(
		"ckey" = ckey
	))

	if(!query_donor_select.warn_execute())
		qdel(query_donor_select)
		return

	while(query_donor_select.NextRow())
		if(!text2num(query_donor_select.item[3]))
			// Inactive donator.
			donator_level = 0
			qdel(query_donor_select)
			return
		donator_level = text2num(query_donor_select.item[2])
		donor_loadout_points()
		break
	qdel(query_donor_select)

/client/proc/donor_loadout_points()
	if(donator_level > 0 && prefs)
		prefs.max_gear_slots = config.max_loadout_points + 5

/client/proc/log_client_to_db(connectiontopic)
	set waitfor = FALSE // This needs to run async because any sleep() inside /client/New() breaks stuff badly
	if(IsGuestKey(key))
		return

	if(!SSdbcore.IsConnected())
		return

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT id, datediff(Now(),firstseen) as age FROM [format_table_name("player")] WHERE ckey=:ckey", list(
		"ckey" = ckey
	))
	if(!query.warn_execute())
		qdel(query)
		return

	var/sql_id = 0
	player_age = 0	// New players won't have an entry so knowing we have a connection we set this to zero to be updated if there is a record.
	while(query.NextRow())
		sql_id = query.item[1]
		player_age = text2num(query.item[2])
		break

	qdel(query)
	var/datum/db_query/query_ip = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("player")] WHERE ip=:address", list(
		"address" = address
	))
	if(!query_ip.warn_execute())
		qdel(query_ip)
		return
	related_accounts_ip = list()
	while(query_ip.NextRow())
		if(ckey != query_ip.item[1])
			related_accounts_ip.Add("[query_ip.item[1]]")

	qdel(query_ip)

	var/datum/db_query/query_cid = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("player")] WHERE computerid=:cid", list(
		"cid" = computer_id
	))
	if(!query_cid.warn_execute())
		qdel(query_cid)
		return

	related_accounts_cid = list()
	while(query_cid.NextRow())
		if(ckey != query_cid.item[1])
			related_accounts_cid.Add("[query_cid.item[1]]")

	qdel(query_cid)

	var/admin_rank = "Player"
	if(holder)
		admin_rank = holder.rank
	// Admins don't get slammed by this, I guess
	else
		if(check_randomizer(connectiontopic))
			return


	//Log all the alts
	if(related_accounts_cid.len)
		log_admin("[key_name(src)] alts:[jointext(related_accounts_cid, " - ")]")


	var/watchreason = check_watchlist(ckey)
	if(watchreason)
		message_admins("<font color='red'><B>Notice: </B></font><font color='blue'>[key_name_admin(src)] is on the watchlist and has just connected - Reason: [watchreason]</font>")
		SSdiscord.send2discord_simple("**\[Watchlist]** [key_name(src)] is on the watchlist and has just connected - Reason: [watchreason]")


	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			return

	if(sql_id)
		var/client_address = address
		if(!client_address) // Localhost can sometimes have no address set
			client_address = "127.0.0.1"
		//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
		var/datum/db_query/query_update = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET lastseen = Now(), ip=:sql_ip, computerid=:sql_cid, lastadminrank=:sql_ar WHERE id=:sql_id", list(
			"sql_ip" = client_address,
			"sql_cid" = computer_id,
			"sql_ar" = admin_rank,
			"sql_id" = sql_id
		))

		if(!query_update.warn_execute())
			qdel(query_update)
			return
		qdel(query_update)
		// After the regular update
		INVOKE_ASYNC(src, /client/.proc/get_byond_account_date, FALSE) // Async to avoid other procs in the client chain being delayed by a web request
	else
		//New player!! Need to insert all the stuff

		// Check new peeps for panic bunker
		if(GLOB.panic_bunker_enabled)
			var/threshold = config.panic_bunker_threshold
			src << "Server is not accepting connections from never-before-seen players until player count is less than [threshold]. Please try again later."
			qdel(src)
			return // Dont insert or they can just go in again

		var/datum/db_query/query_insert = SSdbcore.NewQuery("INSERT INTO [format_table_name("player")] (id, ckey, firstseen, lastseen, ip, computerid, lastadminrank) VALUES (null, :ckey, Now(), Now(), :ip, :cid, :rank)", list(
			"ckey" = ckey,
			"ip" = address,
			"cid" = computer_id,
			"rank" = admin_rank
		))
		if(!query_insert.warn_execute())
			qdel(query_insert)
			return
		qdel(query_insert)
		// This is their first connection instance, so TRUE here to nofiy admins
		// This needs to happen here to ensure they actually have a row to update
		INVOKE_ASYNC(src, /client/.proc/get_byond_account_date, TRUE) // Async to avoid other procs in the client chain being delayed by a web request

	// Log player connections to DB
	var/datum/db_query/query_accesslog = SSdbcore.NewQuery("INSERT INTO `[format_table_name("connection_log")]`(`datetime`,`ckey`,`ip`,`computerid`) VALUES(Now(), :ckey, :ip, :cid)", list(
		"ckey" = ckey,
		"ip" = "[address ? address : ""]", // This is important. NULL is not the same as "", and if you directly open the `.dmb` file, you get a NULL IP.
		"cid" = computer_id
	))
	// We do nothing with output here, or anything else after, so we dont need to if() wrap it
	// If you ever extend this proc below this point, please wrap these with an if() in the same way its done above
	query_accesslog.warn_execute()
	qdel(query_accesslog)

/client/proc/check_ip_intel()
	set waitfor = 0 //we sleep when getting the intel, no need to hold up the client connection while we sleep
	if(config.ipintel_email)
		if(config.ipintel_maxplaytime && config.use_exp_tracking)
			var/living_hours = get_exp_type_num(EXP_TYPE_LIVING) / 60
			if(living_hours >= config.ipintel_maxplaytime)
				return

		if(is_connecting_from_localhost())
			log_debug("check_ip_intel: skip check for player [key_name_admin(src)] connecting from localhost.")
			return

		if(vpn_whitelist_check(ckey))
			log_debug("check_ip_intel: skip check for player [key_name_admin(src)] [address] on whitelist.")
			return

		var/datum/ipintel/res = get_ip_intel(address)
		ip_intel = res.intel
		verify_ip_intel()

/client/proc/verify_ip_intel()
	if(ip_intel >= config.ipintel_rating_bad)
		var/detailsurl = config.ipintel_detailsurl ? "(<a href='[config.ipintel_detailsurl][address]'>IP Info</a>)" : ""
		if(config.ipintel_whitelist)
			spawn(40) // This is necessary because without it, they won't see the message, and addtimer cannot be used because the timer system may not have initialized yet
				message_admins("<span class='adminnotice'>IPIntel: [key_name_admin(src)] on IP [address] was rejected. [detailsurl]</span>")
				var/blockmsg = "<B>Error: proxy/VPN detected. Proxy/VPN use is not allowed here. Deactivate it before you reconnect.</B>"
				if(config.banappeals)
					blockmsg += "\nIf you are not actually using a proxy/VPN, or have no choice but to use one, request whitelisting at: [config.banappeals]"
				to_chat(src, blockmsg)
				qdel(src)
		else
			message_admins("<span class='adminnotice'>IPIntel: [key_name_admin(src)] on IP [address] is likely to be using a Proxy/VPN. [detailsurl]</span>")


/client/proc/check_forum_link()
	if(!config.forum_link_url || !prefs || prefs.fuid)
		return
	if(config.use_exp_tracking)
		var/living_hours = get_exp_type_num(EXP_TYPE_LIVING) / 60
		if(living_hours < 20)
			return
	to_chat(src, "<B>You have no verified forum account. <a href='?src=[UID()];link_forum_account=true'>VERIFY FORUM ACCOUNT</a></B>")

/client/proc/create_oauth_token()
	var/datum/db_query/query_find_token = SSdbcore.NewQuery("SELECT token FROM [format_table_name("oauth_tokens")] WHERE ckey=:ckey limit 1", list(
		"ckey" = ckey
	))
	// These queries have log_error=FALSE to avoid auth tokens being in plaintext logs
	if(!query_find_token.warn_execute(log_error=FALSE))
		qdel(query_find_token)
		return
	if(query_find_token.NextRow())
		var/tkn = query_find_token.item[1]
		qdel(query_find_token)
		return tkn
	qdel(query_find_token)

	var/tokenstr = md5("[rand(0,9999)][world.time][rand(0,9999)][ckey][rand(0,9999)][address][rand(0,9999)][computer_id][rand(0,9999)]")

	var/datum/db_query/query_insert_token = SSdbcore.NewQuery("INSERT INTO [format_table_name("oauth_tokens")] (ckey, token) VALUES(:ckey, :tokenstr)", list(
		"ckey" = ckey,
		"tokenstr" = tokenstr,
	))
	// These queries have log_error=FALSE to avoid auth tokens being in plaintext logs
	if(!query_insert_token.warn_execute(log_error=FALSE))
		qdel(query_insert_token)
		return
	qdel(query_insert_token)
	return tokenstr

/client/proc/link_forum_account(fromban)
	if(!config.forum_link_url)
		return
	if(IsGuestKey(key))
		to_chat(src, "Guest keys cannot be linked.")
		return
	if(prefs && prefs.fuid)
		if(!fromban)
			to_chat(src, "Your forum account is already set.")
		return
	var/datum/db_query/query_find_link = SSdbcore.NewQuery("SELECT fuid FROM [format_table_name("player")] WHERE ckey=:ckey LIMIT 1", list(
		"ckey" = ckey
	))
	if(!query_find_link.warn_execute())
		qdel(query_find_link)
		return
	if(query_find_link.NextRow())
		if(query_find_link.item[1])
			if(!fromban)
				to_chat(src, "Your forum account is already set. (" + query_find_link.item[1] + ")")
			qdel(query_find_link)
			return
	qdel(query_find_link)
	var/tokenid = create_oauth_token()
	if(!tokenid)
		to_chat(src, "link_forum_account: unable to create token")
		return
	var/url = "[config.forum_link_url][tokenid]"
	if(fromban)
		url += "&fwd=appeal"
		to_chat(src, {"Now opening a window to verify your information with the forums, so that you can appeal your ban. If the window does not load, please copy/paste this link: <a href="[url]">[url]</a>"})
	else
		to_chat(src, {"Now opening a window to verify your information with the forums. If the window does not load, please go to: <a href="[url]">[url]</a>"})
	src << link(url)
	return

#undef TOPIC_SPAM_DELAY
#undef UPLOAD_LIMIT
#undef MIN_CLIENT_VERSION

// Returns true if a randomizer is being used
/client/proc/check_randomizer(topic)
	set waitfor = FALSE // Yes I know this is already called from an async proc but someone may change that without thinking properly
	. = FALSE
	if(connection != "seeker")					//Invalid connection type.
		return null
	topic = params2list(topic)
	if(!config.check_randomizer)
		return
	// Stash o' ckeys
	var/static/cidcheck = list()
	var/static/tokens = list()
	// Ckeys that failed the test, stored to send acceptance messages only for atoners
	var/static/cidcheck_failedckeys = list()
	var/static/cidcheck_spoofckeys = list()

	var/oldcid = cidcheck[ckey]

	if(!oldcid)
		var/datum/db_query/query_cidcheck = SSdbcore.NewQuery("SELECT computerid FROM [format_table_name("player")] WHERE ckey=:ckey", list(
			"ckey" = ckey
		))
		if(!query_cidcheck.warn_execute())
			qdel(query_cidcheck)
			return

		var/lastcid = computer_id
		if(query_cidcheck.NextRow())
			lastcid = query_cidcheck.item[1]
		qdel(query_cidcheck)

		if(computer_id != lastcid)
			// Their current CID does not match what the DB says - OFF WITH THEIR HEAD
			cidcheck[ckey] = computer_id

			// Disable the reconnect button to force a CID change
			winset(src, "reconnectbutton", "is-disable=true")

			tokens[ckey] = cid_check_reconnect()
			sleep(10) // Since browse is non-instant, and kinda async

			to_chat(src, "<pre class=\"system system\">you're a huge nerd. wakka wakka doodle doop nobody's ever gonna see this, the chat system shouldn't be online by this point</pre>")
			qdel(src)
			return TRUE
	else
		if (!topic || !topic["token"] || !tokens[ckey] || topic["token"] != tokens[ckey])
			if (!cidcheck_spoofckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name(src)] appears to have attempted to spoof a cid randomizer check.</span>")
				cidcheck_spoofckeys[ckey] = TRUE
			cidcheck[ckey] = computer_id
			tokens[ckey] = cid_check_reconnect()

			sleep(10) //browse is queued, we don't want them to disconnect before getting the browse() command.
			qdel(src)
			return TRUE
		// We DO have their cached CID handy - compare it, now
		if(oldcid != computer_id)
			// Change detected, they are randomizing
			cidcheck -= ckey	// To allow them to try again after removing CID randomization

			to_chat(src, "<span class='userdanger'>Connection Error:</span>")
			to_chat(src, "<span class='danger'>Invalid ComputerID(spoofed). Please remove the ComputerID spoofer from your BYOND installation and try again.</span>")

			if(!cidcheck_failedckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name(src)] has been detected as using a CID randomizer. Connection rejected.</span>")
				SSdiscord.send2discord_simple_noadmins("**\[Warning]** [key_name(src)] has been detected as using a CID randomizer. Connection rejected.")
				cidcheck_failedckeys[ckey] = TRUE
				note_randomizer_user()

			log_adminwarn("Failed Login: [key] [computer_id] [address] - CID randomizer confirmed (oldcid: [oldcid])")

			qdel(src)
			return TRUE
		else
			// don't shoot, I'm innocent
			if(cidcheck_failedckeys[ckey])
				// Atonement
				message_admins("<span class='adminnotice'>[key_name_admin(src)] has been allowed to connect after showing they removed their cid randomizer</span>")
				SSdiscord.send2discord_simple("**\[Info]** [key_name(src)] has been allowed to connect after showing they removed their cid randomizer.")
				cidcheck_failedckeys -= ckey
			if (cidcheck_spoofckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name_admin(src)] has been allowed to connect after appearing to have attempted to spoof a cid randomizer check because it <i>appears</i> they aren't spoofing one this time</span>")
				cidcheck_spoofckeys -= ckey
			cidcheck -= ckey

/client/proc/note_randomizer_user()
	var/const/adminckey = "CID-Error"

	// Check for notes in the last day - only 1 note per 24 hours
	var/datum/db_query/query_get_notes = SSdbcore.NewQuery("SELECT id from [format_table_name("notes")] WHERE ckey=:ckey AND adminckey=:adminckey AND timestamp + INTERVAL 1 DAY < NOW()", list(
		"ckey" = ckey,
		"adminckey" = adminckey
	))
	if(!query_get_notes.warn_execute())
		qdel(query_get_notes)
		return
	if(query_get_notes.NextRow())
		qdel(query_get_notes)
		return
	qdel(query_get_notes)

	// Only add a note if their most recent note isn't from the randomizer blocker, either
	var/datum/db_query/query_get_note = SSdbcore.NewQuery("SELECT adminckey FROM [format_table_name("notes")] WHERE ckey=:ckey ORDER BY timestamp DESC LIMIT 1", list(
		"ckey" = ckey
	))
	if(!query_get_note.warn_execute())
		qdel(query_get_note)
		return
	if(query_get_note.NextRow())
		if(query_get_note.item[1] == adminckey)
			qdel(query_get_note)
			return
	qdel(query_get_note)
	add_note(ckey, "Detected as using a cid randomizer.", null, adminckey, logged = 0)

/client/proc/cid_check_reconnect()
	var/token = md5("[rand(0,9999)][world.time][rand(0,9999)][ckey][rand(0,9999)][address][rand(0,9999)][computer_id][rand(0,9999)]")
	. = token
	log_adminwarn("Failed Login: [key] [computer_id] [address] - CID randomizer check")
	var/url = winget(src, null, "url")
	//special javascript to make them reconnect under a new window.
	src << browse("<a id='link' href='byond://[url]?token=[token]'>\
		byond://[url]?token=[token]\
	</a>\
	<script type='text/javascript'>\
		document.getElementById(\"link\").click();\
		window.location=\"byond://winset?command=.quit\"\
	</script>",
	"border=0;titlebar=0;size=1x1")
	to_chat(src, "<a href='byond://[url]?token=[token]'>You will be automatically taken to the game, if not, click here to be taken manually</a>. Except you can't, since the chat window doesn't exist yet.")

//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration=3000)
	if(inactivity > duration)	return inactivity
	return 0

//Send resources to the client.
/client/proc/send_resources()
	// Change the way they should download resources.
	if(config.resource_urls)
		preload_rsc = pick(config.resource_urls)
	else
		preload_rsc = 1 // If config.resource_urls is not set, preload like normal.
	// Most assets are now handled through global_cache.dm
	getFiles(
		'html/search.js', // Used in various non-TGUI HTML windows for search functionality
		'html/panels.css' // Used for styling certain panels, such as in the new player panel
	)
	spawn (10) //removing this spawn causes all clients to not get verbs.
		//Precache the client with all other assets slowly, so as to not block other browse() calls
		getFilesSlow(src, SSassets.preload, register_asset = FALSE)

//For debugging purposes
/client/proc/list_all_languages()
	for(var/L in GLOB.all_languages)
		var/datum/language/lang = GLOB.all_languages[L]
		var/message = "[lang.name] : [lang.type]"
		if(lang.flags & RESTRICTED)
			message += " (RESTRICTED)"
		to_chat(world, "[message]")

/client/proc/colour_transition(list/colour_to = null, time = 10) //Call this with no parameters to reset to default.
	animate(src, color = colour_to, time = time, easing = SINE_EASING)

/client/proc/on_varedit()
	var_edited = TRUE

/////////////////
// DARKMODE UI //
/////////////////
// IF YOU CHANGE ANYTHING IN ACTIVATE, MAKE SURE IT HAS A DEACTIVATE METHOD, -AA07
/client/proc/activate_darkmode()
	///// BUTTONS /////
	SSchangelog.UpdatePlayerChangelogButton(src)
	/* Rpane */
	winset(src, "rpane.textb", "background-color=#40628a;text-color=#FFFFFF")
	winset(src, "rpane.infob", "background-color=#40628a;text-color=#FFFFFF")
	winset(src, "rpane.wikib", "background-color=#40628a;text-color=#FFFFFF")
	winset(src, "rpane.forumb", "background-color=#40628a;text-color=#FFFFFF")
	winset(src, "rpane.rulesb", "background-color=#40628a;text-color=#FFFFFF")
	winset(src, "rpane.githubb", "background-color=#40628a;text-color=#FFFFFF")
	/* Mainwindow */
	winset(src, "mainwindow.saybutton", "background-color=#40628a;text-color=#FFFFFF")
	winset(src, "mainwindow.mebutton", "background-color=#40628a;text-color=#FFFFFF")
	///// UI ELEMENTS /////
	/* Mainwindow */
	winset(src, "mainwindow", "background-color=#36393F")
	winset(src, "mainwindow.mainvsplit", "background-color=#36393F")
	winset(src, "mainwindow.tooltip", "background-color=#36393F")
	/* Outputwindow */
	winset(src, "outputwindow.browseroutput", "background-color=#36393F")
	/* Rpane */
	winset(src, "rpane", "background-color=#36393F")
	winset(src, "rpane.rpanewindow", "background-color=#36393F")
	/* Browserwindow */
	winset(src, "browserwindow", "background-color=#36393F")
	winset(src, "browserwindow.browser", "background-color=#36393F")
	/* Infowindow */
	winset(src, "infowindow", "background-color=#36393F;text-color=#FFFFFF")
	winset(src, "infowindow.info", "background-color=#36393F;text-color=#FFFFFF;highlight-color=#009900;tab-text-color=#FFFFFF;tab-background-color=#36393F")
	// NOTIFY USER
	to_chat(src, "<span class='notice'>Darkmode Enabled</span>")

/client/proc/deactivate_darkmode()
	///// BUTTONS /////
	SSchangelog.UpdatePlayerChangelogButton(src)
	/* Rpane */
	winset(src, "rpane.textb", "background-color=none;text-color=#000000")
	winset(src, "rpane.infob", "background-color=none;text-color=#000000")
	winset(src, "rpane.wikib", "background-color=none;text-color=#000000")
	winset(src, "rpane.forumb", "background-color=none;text-color=#000000")
	winset(src, "rpane.rulesb", "background-color=none;text-color=#000000")
	winset(src, "rpane.githubb", "background-color=none;text-color=#000000")
	/* Mainwindow */
	winset(src, "mainwindow.saybutton", "background-color=none;text-color=#000000")
	winset(src, "mainwindow.mebutton", "background-color=none;text-color=#000000")
	///// UI ELEMENTS /////
	/* Mainwindow */
	winset(src, "mainwindow", "background-color=none")
	winset(src, "mainwindow.mainvsplit", "background-color=none")
	winset(src, "mainwindow.tooltip", "background-color=none")
	/* Outputwindow */
	winset(src, "outputwindow.browseroutput", "background-color=none")
	/* Rpane */
	winset(src, "rpane", "background-color=none")
	winset(src, "rpane.rpanewindow", "background-color=none")
	/* Browserwindow */
	winset(src, "browserwindow", "background-color=none")
	winset(src, "browserwindow.browser", "background-color=none")
	/* Infowindow */
	winset(src, "infowindow", "background-color=none;text-color=#000000")
	winset(src, "infowindow.info", "background-color=none;text-color=#000000;highlight-color=#007700;tab-text-color=#000000;tab-background-color=none")
	///// NOTIFY USER /////
	to_chat(src, "<span class='notice'>Darkmode Disabled</span>") // what a sick fuck

/client/proc/generate_clickcatcher()
	if(!void)
		void = new()
		screen += void

/client/proc/apply_clickcatcher()
	generate_clickcatcher()
	var/list/actualview = getviewsize(view)
	void.UpdateGreed(actualview[1],actualview[2])

/client/proc/send_ssd_warning(mob/M)
	if(!config.ssd_warning)
		return FALSE
	if(ssd_warning_acknowledged)
		return FALSE
	if(M && M.player_logged < SSD_WARNING_TIMER)
		return FALSE
	to_chat(src, "Are you taking this person to cryo or giving them medical treatment? If you are, <a href='byond://?src=[UID()];ssdwarning=accepted'>confirm that</a> and proceed. Interacting with SSD players in other ways is against server rules unless you've ahelped first for permission.")
	return TRUE

#undef SSD_WARNING_TIMER

/client/verb/resend_ui_resources()
	set name = "Reload UI Resources"
	set desc = "Reload your UI assets if they are not working"
	set category = "Special Verbs"

	if(last_ui_resource_send > world.time)
		to_chat(usr, "<span class='warning'>You requested your UI resource files too quickly. Please try again in [(last_ui_resource_send - world.time)/10] seconds.</span>")
		return

	var/choice = alert(usr, "This will reload your TGUI resources. If you have any open UIs this may break them. Are you sure?", "Resource Reloading", "Yes", "No")
	if(choice == "Yes")
		// 600 deciseconds = 1 minute
		last_ui_resource_send = world.time + 60 SECONDS

		// Close their open UIs
		SStgui.close_user_uis(usr)

		// Resend the resources

		var/datum/asset/tgui_assets = get_asset_datum(/datum/asset/simple/tgui)
		tgui_assets.register()

		var/datum/asset/nanomaps = get_asset_datum(/datum/asset/simple/nanomaps)
		nanomaps.register()

		// Clear the user's cache so they get resent.
		// This is not fully clearing their BYOND cache, just their assets sent from the server this round
		cache = list()

		to_chat(usr, "<span class='notice'>UI resource files resent successfully. If you are still having issues, please try manually clearing your BYOND cache. <b>This can be achieved by opening your BYOND launcher, pressing the cog in the top right, selecting preferences, going to the Games tab, and pressing 'Clear Cache'.</b></span>")


/**
  * Retrieves the BYOND accounts data from the BYOND servers
  *
  * Makes a web request to byond.com to retrieve the details for the BYOND account associated with the clients ckey.
  * Returns the data in a parsed, associative list
  */
/client/proc/retrieve_byondacc_data()
	// Do not refactor this to use SShttp, because that requires the subsystem to be firing for requests to be made, and this will be triggered before the MC has finished loading
	var/list/http[] = world.Export("http://www.byond.com/members/[ckey]?format=text")
	if(http)
		var/status = text2num(http["STATUS"])

		if(status == 200)
			// This is wrapped in try/catch because lummox could change the format on any day without informing anyone
			try
				var/list/lines = splittext(file2text(http["CONTENT"]), "\n")
				var/list/initial_data = list()
				var/current_index = ""
				for(var/L in lines)
					if(L == "")
						continue
					if(!findtext(L, "\t"))
						current_index = L
						initial_data[current_index] = list()
						continue
					initial_data[current_index] += replacetext(replacetext(L, "\t", ""), "\"", "")

				var/list/parsed_data = list()

				for(var/key in initial_data)
					var/inner_list = list()
					for(var/entry in initial_data[key])
						var/list/split = splittext(entry, " = ")
						var/inner_key = split[1]
						var/inner_value = split[2]
						inner_list[inner_key] = inner_value

					parsed_data[key] = inner_list

				// Main return is here
				return parsed_data
			catch
				log_debug("Error parsing byond.com data for [ckey]. Please inform maintainers.")
				return null
		else
			log_debug("Error retrieving data from byond.com for [ckey]. Invalid status code (Expected: 200 | Got: [status]).")
			return null
	else
		log_debug("Failed to retrieve data from byond.com for [ckey]. Connection failed.")
		return null


/**
  * Sets the clients BYOND date up properly
  *
  * If the client does not have a saved BYOND account creation date, retrieve it from the website
  * If they do have a saved date, use that from the DB, because this value will never change
  * Arguments:
  * * notify - Do we notify admins of this new accounts date
  */
/client/proc/get_byond_account_date(notify = FALSE)
	// First we see if the client has a saved date in the DB
	var/datum/db_query/query_date = SSdbcore.NewQuery("SELECT byond_date, DATEDIFF(Now(), byond_date) FROM [format_table_name("player")] WHERE ckey=:ckey", list(
		"ckey" = ckey
	))
	if(!query_date.warn_execute())
		qdel(query_date)
		return

	while(query_date.NextRow())
		byondacc_date = query_date.item[1]
		byondacc_age = max(text2num(query_date.item[2]), 0) // Ensure account isnt negative days old

	qdel(query_date)

	// They have a date, lets bail
	if(byondacc_date)
		return

	// They dont have a date, lets grab one
	var/list/byond_data = retrieve_byondacc_data()
	if(isnull(byond_data) || !(byond_data["general"]["joined"]))
		log_debug("Failed to retrieve an account creation date for [ckey].")
		return

	byondacc_date = byond_data["general"]["joined"]

	// Now save it
	var/datum/db_query/query_update = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET byond_date=:date WHERE ckey=:ckey", list(
		"date" = byondacc_date,
		"ckey" = ckey
	))
	if(!query_update.warn_execute())
		qdel(query_update)
		return
	qdel(query_update)

	// Now retrieve the age again because BYOND doesnt have native methods for this
	var/datum/db_query/query_age = SSdbcore.NewQuery("SELECT DATEDIFF(Now(), byond_date) FROM [format_table_name("player")] WHERE ckey=:ckey", list(
		"ckey" = ckey
	))
	if(!query_age.warn_execute())
		qdel(query_age)
		return

	while(query_age.NextRow())
		byondacc_age = max(text2num(query_age.item[1]), 0) // Ensure account isnt negative days old
	qdel(query_age)

	// Notify admins on new clients connecting, if the byond account age is less than a config value
	if(notify && (byondacc_age < config.byond_account_age_threshold))
		message_admins("[key] has just connected for the first time. BYOND account registered on [byondacc_date] ([byondacc_age] days old)")

/client/proc/show_update_notice()
	to_chat(src, "<span class='userdanger'>Your BYOND client (v: [byond_version].[byond_build]) is out of date. This can cause glitches. We highly suggest you download the latest client from <a href='https://www.byond.com/download/'>byond.com</a> before playing. You can also update via the BYOND launcher application.</span>")

/**
  * Checks if the client has accepted TOS
  *
  * Runs some checks against vars and the DB to see if the client has accepted TOS.
  * Returns TRUE or FALSE if they have or have not
  */
/client/proc/check_tos_consent()
	// If there is no TOS, auto accept
	if(!GLOB.join_tos)
		tos_consent = TRUE
		return TRUE

	// If theres no DB, assume yes
	if(!SSdbcore.IsConnected())
		tos_consent = TRUE
		return TRUE

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("privacy")] WHERE ckey=:ckey AND consent=1", list(
		"ckey" = ckey
	))
	if(!query.warn_execute())
		qdel(query)
		// If our query failed, just assume yes
		tos_consent = TRUE
		return TRUE

	// If we returned a row, they accepted
	while(query.NextRow())
		qdel(query)
		tos_consent = TRUE
		return TRUE

	qdel(query)
	// If we are here, they have not accepted, and need to read it
	return FALSE

#undef LIMITER_SIZE
#undef CURRENT_SECOND
#undef SECOND_COUNT
#undef CURRENT_MINUTE
#undef MINUTE_COUNT
#undef ADMINSWARNED_AT
