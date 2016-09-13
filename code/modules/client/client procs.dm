	////////////
	//SECURITY//
	////////////
//debugging, uncomment for viewing topic calls
//#define TOPIC_DEBUGGING 1

#define TOPIC_SPAM_DELAY	2		//2 ticks is about 2/10ths of a second; it was 4 ticks, but that caused too many clicks to be lost due to lag
#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 10MB //Boosted this thing. What's the worst that can happen?
#define MIN_CLIENT_VERSION	0		//Just an ambiguously low version for now, I don't want to suddenly stop people playing.
									//I would just like the code ready should it ever need to be used.
#define SUGGESTED_CLIENT_VERSION	510		// only integers (e.g: 510, 511) useful here. Does not properly handle minor versions (e.g: 510.58, 511.848)

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

	if(href_list["nano_err"]) //nano throwing errors
		if(topic_debugging)
			to_chat(src, "## NanoUI: " + html_decode(href_list["nano_err"]))//NANO DEBUG HOOK



	if(href_list["asset_cache_confirm_arrival"])
//		to_chat(src, "ASSET JOB [href_list["asset_cache_confirm_arrival"]] ARRIVED.")
		var/job = text2num(href_list["asset_cache_confirm_arrival"])
		completed_asset_jobs += job
		return

	if(href_list["_src_"] == "chat")
		return chatOutput.Topic(href, href_list)

	//Reduces spamming of links by dropping calls that happen during the delay period
	if(next_allowed_topic_time > world.time)
		return
	next_allowed_topic_time = world.time + TOPIC_SPAM_DELAY

	//search the href for script injection
	if( findtext(href,"<script",1,0) )
		log_to_dd("Attempted use of scripts within a topic call, by [src]")
		log_runtime(EXCEPTION("Attempted use of scripts within a topic call, by [src]"), src)
		message_admins("Attempted use of scripts within a topic call, by [src]")
		return

	//Admin PM
	if(href_list["priv_msg"])
		var/client/C = locate(href_list["priv_msg"])
		if(ismob(C)) 		//Old stuff can feed-in mobs instead of clients
			var/mob/M = C
			C = M.client
		if(!C) // Might be a stealthmin ID, so pass it in straight
			C = href_list["priv_msg"]
		cmd_admin_pm(C, null, href_list["type"])
		return

	if(href_list["irc_msg"])
		if(!holder && received_irc_pm < world.time - 6000) //Worse they can do is spam IRC for 10 minutes
			to_chat(usr, "<span class='warning'>You are no longer able to use this, it's been more then 10 minutes since an admin on IRC has responded to you</span>")
			return
		if(mute_irc)
			to_chat(usr, "<span class='warning'You cannot use this as your client has been muted from sending messages to the admins on IRC</span>")
			return
		cmd_admin_irc_pm()
		return



	//Logs all hrefs
	if(config && config.log_hrefs && href_logfile)
		to_chat(href_logfile, "<small>[time2text(world.timeofday,"hh:mm")] [src] (usr:[usr])</small> || [hsrc ? "[hsrc] " : ""][href]<br>")

	switch(href_list["karmashop"])
		if("tab")
			karma_tab = text2num(href_list["tab"])
			karmashopmenu()
			return
		if("shop")
			if(href_list["KarmaBuy"])
				var/karma=verify_karma()
				switch(href_list["KarmaBuy"])
					if("1")
						if(karma <5)
							to_chat(usr, "You do not have enough karma!")
							return
						else
							src.DB_job_unlock("Barber",5)
							return
					if("2")
						if(karma <5)
							to_chat(usr, "You do not have enough karma!")
							return
						else
							src.DB_job_unlock("Brig Physician",5)
							return
					if("3")
						if(karma <30)
							to_chat(usr, "You do not have enough karma!")
							return
						else
							src.DB_job_unlock("Nanotrasen Representative",30)
							return
					if("5")
						if(karma <30)
							to_chat(usr, "You do not have enough karma!")
							return
						else
							src.DB_job_unlock("Blueshield",30)
							return
					if("6")
						if(karma <30)
							to_chat(usr, "You do not have enough karma!")
							return
						else
							src.DB_job_unlock("Mechanic",30)
							return
					if("7")
						if(karma <45)
							to_chat(usr, "You do not have enough karma!")
							return
						else
							src.DB_job_unlock("Magistrate",45)
							return
					if("9")
						if(karma <30)
							to_chat(usr, "You do not have enough karma!")
							return
						else
							src.DB_job_unlock("Security Pod Pilot",30)
							return
			if(href_list["KarmaBuy2"])
				var/karma=verify_karma()
				switch(href_list["KarmaBuy2"])
					if("1")
						if(karma <15)
							to_chat(usr, "You do not have enough karma!")
							return
						else
							src.DB_species_unlock("Machine",15)
							return
					if("2")
						if(karma <30)
							to_chat(usr, "You do not have enough karma!")
							return
						else
							src.DB_species_unlock("Kidan",30)
							return
					if("3")
						if(karma <30)
							to_chat(usr, "You do not have enough karma!")
							return
						else
							src.DB_species_unlock("Grey",30)
							return
					if("4")
						if(karma <45)
							to_chat(usr, "You do not have enough karma!")
							return
						else
							src.DB_species_unlock("Vox",45)
							return
					if("5")
						if(karma <45)
							to_chat(usr, "You do not have enough karma!")
							return
						else
							src.DB_species_unlock("Slime People",45)
							return
					if("6")
						if(karma <100)
							to_chat(usr, "You do not have enough karma!")
							return
						else
							src.DB_species_unlock("Plasmaman",100)
							return
					if("7")
						if(karma <30)
							to_chat(usr, "You do not have enough karma!")
							return
						else
							src.DB_species_unlock("Drask",30)
							return
			if(href_list["KarmaRefund"])
				var/type = href_list["KarmaRefundType"]
				var/job = href_list["KarmaRefund"]
				var/cost = href_list["KarmaRefundCost"]
				src.karmarefund(type,job,cost)
				return

	switch(href_list["_src_"])
		if("holder")	hsrc = holder
		if("usr")		hsrc = mob
		if("prefs")		return prefs.process_link(usr,href_list)
		if("vars")		return view_var_Topic(href,href_list,hsrc)


	switch(href_list["action"])
		if("openLink")
			src << link(href_list["link"])

	..()	//redirect to hsrc.Topic()

/client/proc/is_content_unlocked()
	if(!prefs.unlock_content)
		to_chat(src, "Become a BYOND member to access member-perks and features, as well as support the engine that makes this game possible. <a href='http://www.byond.com/membership'>Click here to find out more</a>.")
		return 0
	return 1

/client/proc/handle_spam_prevention(var/message, var/mute_type)
	if(config.automute_on && !holder && src.last_message == message)
		src.last_message_count++
		if(src.last_message_count >= SPAM_TRIGGER_AUTOMUTE)
			to_chat(src, "\red You have exceeded the spam filter limit for identical messages. An auto-mute was applied.")
			cmd_admin_mute(src.mob, mute_type, 1)
			return 1
		if(src.last_message_count >= SPAM_TRIGGER_WARNING)
			to_chat(src, "\red You are nearing the spam filter limit for identical messages.")
			return 0
	else
		last_message = message
		src.last_message_count = 0
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
	chatOutput = new /datum/chatOutput(src) // Right off the bat.
	TopicData = null							//Prevent calls to client.Topic from connect

	if(connection != "seeker")					//Invalid connection type.
		return null
	if(byond_version < MIN_CLIENT_VERSION) // Too out of date to play at all. Unfortunately, we can't send them a message here.
		return null
	if(byond_version < SUGGESTED_CLIENT_VERSION) // Update is suggested, but not required.
		to_chat(src,"<span class='userdanger'>Your BYOND client (v: [byond_version]) is out of date. This can cause glitches. We highly suggest you download the latest client from http://www.byond.com/ before playing. </span>")

	if(IsGuestKey(key))
		alert(src,"This server doesn't allow guest accounts to play. Please go to http://www.byond.com/ and register for a key.","Guest","OK")
		del(src)
		return

	// Change the way they should download resources.
	if(config.resource_urls)
		src.preload_rsc = pick(config.resource_urls)
	else src.preload_rsc = 1 // If config.resource_urls is not set, preload like normal.

	to_chat(src, "\red If the title screen is black, resources are still downloading. Please be patient until the title screen appears.")


	clients += src
	directory[ckey] = src

	//Admin Authorisation
	holder = admin_datums[ckey]
	if(holder)
		admins += src
		holder.owner = src

	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = preferences_datums[ckey]
	if(!prefs)
		prefs = new /datum/preferences(src)
		preferences_datums[ckey] = prefs
	prefs.last_ip = address				//these are gonna be used for banning
	prefs.last_id = computer_id			//these are gonna be used for banning

	. = ..()	//calls mob.Login()
	spawn() // Goonchat does some non-instant checks in start()
		chatOutput.start()

	if(custom_event_msg && custom_event_msg != "")
		to_chat(src, "<h1 class='alert'>Custom Event</h1>")
		to_chat(src, "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>")
		to_chat(src, "<span class='alert'>[html_encode(custom_event_msg)]</span>")
		to_chat(src, "<br>")

	if( (world.address == address || !address) && !host )
		host = key
		world.update_status()

	if(holder)
		add_admin_verbs()
		admin_memo_output("Show", 0, 1)

	// Forcibly enable hardware-accelerated graphics, as we need them for the lighting overlays.
	// (but turn them off first, since sometimes BYOND doesn't turn them on properly otherwise)
	spawn(5) // And wait a half-second, since it sounds like you can do this too fast.
		if(src)
			winset(src, null, "command=\".configure graphics-hwmode off\"")
			winset(src, null, "command=\".configure graphics-hwmode on\"")

	log_client_to_db()

	if(ckey in clientmessages)
		for(var/message in clientmessages[ckey])
			to_chat(src, message)
		clientmessages.Remove(ckey)


	send_resources()

	if(prefs.lastchangelog != changelog_hash) //bolds the changelog button on the interface so we know there are updates. -CP
		if(establish_db_connection())
			winset(src, "rpane.changelog", "background-color=#f4aa94;font-style=bold")
			to_chat(src, "<span class='info'>Changelog has changed since your last visit.</span>")

	if(!void)
		void = new()

	screen += void

	if(!winexists(src, "asset_cache_browser")) // The client is using a custom skin, tell them.
		to_chat(src, "<span class='warning'>Unable to access asset cache browser, if you are using a custom skin file, please allow DS to download the updated version, if you are not, then make a bug report. This is not a critical issue but can cause issues with resource downloading, as it is impossible to know when extra resources arrived to you.</span>")


	//This is down here because of the browse() calls in tooltip/New()
	if(!tooltips)
		tooltips = new /datum/tooltip(src)

//////////////
//DISCONNECT//
//////////////
/client/Del()
	if(holder)
		holder.owner = null
		admins -= src
	directory -= ckey
	clients -= src
	return ..()



/client/proc/log_client_to_db()

	if( IsGuestKey(src.key) )
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	var/DBQuery/query = dbcon.NewQuery("SELECT id, datediff(Now(),firstseen) as age FROM [format_table_name("player")] WHERE ckey = '[ckey]'")
	query.Execute()
	var/sql_id = 0
	player_age = 0	// New players won't have an entry so knowing we have a connection we set this to zero to be updated if their is a record.
	while(query.NextRow())
		sql_id = query.item[1]
		player_age = text2num(query.item[2])
		break

	var/DBQuery/query_ip = dbcon.NewQuery("SELECT ckey FROM [format_table_name("player")] WHERE ip = '[address]'")
	query_ip.Execute()
	related_accounts_ip = list()
	while(query_ip.NextRow())
		if(ckey != query_ip.item[1])
			related_accounts_ip.Add("[query_ip.item[1]]")

	var/DBQuery/query_cid = dbcon.NewQuery("SELECT ckey FROM [format_table_name("player")] WHERE computerid = '[computer_id]'")
	query_cid.Execute()
	related_accounts_cid = list()
	while(query_cid.NextRow())
		if(ckey != query_cid.item[1])
			related_accounts_cid.Add("[query_cid.item[1]]")

	//Log all the alts
	if(related_accounts_cid.len)
		log_access("Alts: [key_name(src)]:[jointext(related_accounts_cid, " - ")]")

	var/watchreason = check_watchlist(ckey)
	if(watchreason)
		message_admins("<font color='red'><B>Notice: </B></font><font color='blue'>[key_name_admin(src)] is on the watchlist and has just connected - Reason: [watchreason]</font>")
		send2adminirc("Watchlist - [key_name(src)] is on the watchlist and has just connected - Reason: [watchreason]")

	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			return

	var/admin_rank = "Player"
	if(src.holder)
		admin_rank = src.holder.rank

	var/sql_ip = sanitizeSQL(address)
	var/sql_computerid = sanitizeSQL(computer_id)
	var/sql_admin_rank = sanitizeSQL(admin_rank)


	if(sql_id)
		//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
		var/DBQuery/query_update = dbcon.NewQuery("UPDATE [format_table_name("player")] SET lastseen = Now(), ip = '[sql_ip]', computerid = '[sql_computerid]', lastadminrank = '[sql_admin_rank]' WHERE id = [sql_id]")
		query_update.Execute()
	else
		//New player!! Need to insert all the stuff
		var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO [format_table_name("player")] (id, ckey, firstseen, lastseen, ip, computerid, lastadminrank) VALUES (null, '[ckey]', Now(), Now(), '[sql_ip]', '[sql_computerid]', '[sql_admin_rank]')")
		query_insert.Execute()

	//Logging player access
	var/serverip = "[world.internet_address]:[world.port]"
	var/DBQuery/query_accesslog = dbcon.NewQuery("INSERT INTO `[format_table_name("connection_log")]`(`id`,`datetime`,`serverip`,`ckey`,`ip`,`computerid`) VALUES(null,Now(),'[serverip]','[ckey]','[sql_ip]','[sql_computerid]');")
	query_accesslog.Execute()


#undef TOPIC_SPAM_DELAY
#undef UPLOAD_LIMIT
#undef MIN_CLIENT_VERSION

//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration=3000)
	if(inactivity > duration)	return inactivity
	return 0

//Send resources to the client.
/client/proc/send_resources()
	// Most assets are now handled through global_cache.dm
	getFiles(
		'html/search.js', // Used in various non-NanoUI HTML windows for search functionality
		'html/panels.css' // Used for styling certain panels, such as in the new player panel
	)
	spawn (10)
		//Precache the client with all other assets slowly, so as to not block other browse() calls
		getFilesSlow(src, asset_cache, register_asset = FALSE)

//For debugging purposes
/client/proc/list_all_languages()
	for(var/L in all_languages)
		var/datum/language/lang = all_languages[L]
		var/message = "[lang.name] : [lang.type]"
		if(lang.flags & RESTRICTED)
			message += " (RESTRICTED)"
		to_chat(world, "[message]")
