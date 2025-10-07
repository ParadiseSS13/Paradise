	////////////
	//SECURITY//
	////////////
//debugging, uncomment for viewing topic calls
//#define TOPIC_DEBUGGING 1

#define TOPIC_SPAM_DELAY	2		//2 ticks is about 2/10ths of a second; it was 4 ticks, but that caused too many clicks to be lost due to lag
#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 10MB //Boosted this thing. What's the worst that can happen?
#define MIN_CLIENT_VERSION	513		// Minimum byond major version required to play.
									//I would just like the code ready should it ever need to be used.
#define SUGGESTED_CLIENT_VERSION	514		// only integers (e.g: 513, 514) are useful here. This is the part BEFORE the ".", IE 513 out of 513.1542
#define SUGGESTED_CLIENT_BUILD	1566		// only integers (e.g: 1542, 1543) are useful here. This is the part AFTER the ".", IE 1542 out of 513.1542

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
				stack_trace("Got \\ref-based src in topic from [src] for [hsrc_info], should be UID: [href]")

		if(hsrc == src && href_list["m5src"])
			// We found an MD5'd UID, get the REAL thing
			var/datum/D = locateUID(m5_uid_cache[href_list["m5src"]])
			if(!istype(D))
				CRASH("Tried to find an item by MD5'd UID when it wasnt in the client cache!")

			hsrc = D


	// asset_cache
	var/asset_cache_job
	if(href_list["asset_cache_confirm_arrival"])
		asset_cache_job = asset_cache_confirm_arrival(href_list["asset_cache_confirm_arrival"])
		if(!asset_cache_job)
			return

	// Rate limiting
	var/mtl = 150 // 150 topics per minute
	if(!holder) // Admins are allowed to spam click, deal with it.
		var/minute = round(world.time, 600)
		if(!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)

		if(minute != topiclimiter[CURRENT_MINUTE])
			topiclimiter[CURRENT_MINUTE] = minute
			topiclimiter[MINUTE_COUNT] = 0

		topiclimiter[MINUTE_COUNT] += 1
		if(topiclimiter[MINUTE_COUNT] > mtl)
			var/msg = "Your previous action was ignored because you've done too many in a minute."
			if(minute != topiclimiter[ADMINSWARNED_AT]) //only one admin message per-minute. (if they spam the admins can just boot/ban them)
				topiclimiter[ADMINSWARNED_AT] = minute
				msg += " Administrators have been informed."
				log_game("[key_name(src)] Has hit the per-minute topic limit of [mtl] topic calls in a given game minute")
				message_admins("[ADMIN_LOOKUPFLW(usr)] Has hit the per-minute topic limit of [mtl] topic calls in a given game minute")
			to_chat(src, "<span class='danger'>[msg]</span>")
			return

	var/stl = 10 // 10 topics a second
	if(!holder && href_list["window_id"] != "statbrowser" && href_list["window_id"] != "chat_panel") // Admins are allowed to spam click, deal with it.
		var/second = round(world.time, 10)
		if(!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)

		if(second != topiclimiter[CURRENT_SECOND])
			topiclimiter[CURRENT_SECOND] = second
			topiclimiter[SECOND_COUNT] = 0

		topiclimiter[SECOND_COUNT] += 1
		if(topiclimiter[SECOND_COUNT] > stl)
			to_chat(src, "<span class='danger'>Your previous action was ignored because you've done too many in a second</span>")
			return

	//search the href for script injection
	if(findtext(href, "<script", 1, 0))
		log_world("Attempted use of scripts within a topic call, by [src]")
		stack_trace("Attempted use of scripts within a topic call, by [src]")
		message_admins("Attempted use of scripts within a topic call, by [src]")
		return

	//Admin PM
	if(href_list["priv_msg"])
		var/ckey_txt = href_list["priv_msg"]

		cmd_admin_pm(ckey_txt, null, href_list["type"], ticket_id = text2num(href_list["ticket_id"]))
		return

	if(href_list["discord_msg"])
		if(!holder && received_discord_pm < world.time - 6000) // Worse they can do is spam discord for 10 minutes
			to_chat(usr, "<span class='warning'>You are no longer able to use this, it's been more then 10 minutes since an admin on Discord has responded to you</span>")
			return
		if(check_mute(ckey, MUTE_ADMINHELP))
			to_chat(usr, "<span class='warning'>You cannot use this as your client has been muted from sending messages to the admins on Discord</span>")
			return
		cmd_admin_discord_pm()
		return

	//Logs all hrefs
	if(GLOB.configuration.logging.href_logging)
		log_href("[src] (usr:[usr]\[[COORD(usr)]\]) : [hsrc ? "[hsrc] " : ""][href]")

	switch(href_list["_src_"])
		if("holder")	hsrc = holder
		if("usr")		hsrc = mob
		if("prefs")		return prefs.process_link(usr,href_list)
		if("vars")		return view_var_Topic(href,href_list,hsrc)

	if(href_list["ssdwarning"])
		ssd_warning_acknowledged = TRUE
		to_chat(src, "<span class='notice'>SSD warning acknowledged.</span>")
		return

	if(href_list["link_forum_account"])
		link_forum_account()
		return // prevents a recursive loop where the ..() 5 lines after this makes the proc endlessly re-call itself

	if(href_list["withdraw_consent"])
		var/choice = tgui_alert(usr, "Are you SURE you want to withdraw your consent to the Terms of Service?\nYou will be instantaneously removed from the server and will have to re-accept the Terms of Service.", "Warning", list("Yes", "No"))
		if(choice == "Yes")
			// Update the DB
			var/datum/db_query/query = SSdbcore.NewQuery("REPLACE INTO privacy (ckey, datetime, consent) VALUES (:ckey, Now(), 0)", list(
			"ckey" = ckey
			))

			if(!query.warn_execute())
				to_chat(usr, "Well, this is embarassing. We tried to save your ToS withdrawal but the DB failed. Please contact the server host")
				return

			// I know its a very rare occurance, but I wouldnt doubt people using this to withdraw consent right when sec captures them
			message_admins("[key_name_admin(usr)] was disconnected due to withdrawing their ToS consent.")
			to_chat(usr, "<span class='boldannounceooc'>Your ToS consent has been withdrawn. You have been kicked from the server</span>")
			qdel(src)
			return

	// Tgui Topic middleware
	if(tgui_Topic(href_list))
		return

	if(href_list["reload_statbrowser"])
		stat_panel.reinitialize()
		return

	if(href_list["reload_tguipanel"])
		nuke_chat()
		return

	//byond bug ID:2256651
	if(asset_cache_job && (asset_cache_job in completed_asset_jobs))
		to_chat(src, "<span class='danger'>An error has been detected in how your client is receiving resources. Attempting to correct.... (If you keep seeing these messages you might want to close byond and reconnect)</span>")
		src << browse("...", "window=asset_cache_browser")
		return

	if(href_list["asset_cache_preload_data"])
		asset_cache_preload_data(href_list["asset_cache_preload_data"])
		return

	switch(href_list["action"])
		if("openLink")
			src << link(href_list["link"])
			return

		if("silenceSound")
			usr.stop_sound_channel(CHANNEL_ADMIN)
			tgui_panel?.stop_music()
			return

		if("muteAdmin")
			usr.stop_sound_channel(CHANNEL_ADMIN)
			tgui_panel?.stop_music()
			prefs.admin_sound_ckey_ignore |= href_list["a"]
			to_chat(usr, "You will no longer hear admin playsounds from <code>[href_list["a"]]</code>. To remove them, go to Preferences --&gt; <code>Manage Admin Sound Mutes</code>.")
			prefs.save_preferences(src)
			return

	//fun fact: Topic() acts like a verb and is executed at the end of the tick like other verbs. So we have to queue it if the server is
	//overloaded
	if(hsrc && hsrc != holder && DEFAULT_TRY_QUEUE_VERB(VERB_CALLBACK(src, PROC_REF(_Topic), hsrc, href, href_list)))
		return

	..()	//redirect to hsrc.Topic()

///dumb workaround because byond doesnt seem to recognize the Topic() typepath for /datum/proc/Topic() from the client Topic,
///so we cant queue it without this
/client/proc/_Topic(datum/hsrc, href, list/href_list)
	return hsrc.Topic(href, href_list)


/client/proc/get_display_key()
	var/fakekey = holder?.fakekey
	return fakekey ? fakekey : key

//Like for /atoms, but clients are their own snowflake FUCK
/client/proc/setDir(newdir)
	dir = newdir

/client/proc/handle_spam_prevention(message, mute_type, throttle = 0)
	if(throttle)
		if((last_message_time + throttle > world.time) && !check_rights(R_ADMIN, 0))
			var/wait_time = round(((last_message_time + throttle) - world.time) / 10, 1)
			to_chat(src, "<span class='danger'>You are sending messages to quickly. Please wait [wait_time] [wait_time == 1 ? "second" : "seconds"] before sending another message.</span>")
			return 1
		last_message_time = world.time

	if(GLOB.configuration.general.enable_auto_mute && !check_rights(R_ADMIN, 0) && last_message == message)
		last_message_count++
		if(SEND_SIGNAL(mob, COMSIG_MOB_AUTOMUTE_CHECK, src, last_message, mute_type) & WAIVE_AUTOMUTE_CHECK)
			return FALSE
		if(last_message_count >= SPAM_TRIGGER_AUTOMUTE)
			to_chat(src, "<span class='danger'>You have exceeded the spam filter limit for identical messages. An auto-mute was applied.</span>")
			cmd_admin_mute(mob, mute_type, 1)
			return TRUE

		if(last_message_count >= SPAM_TRIGGER_WARNING)
			to_chat(src, "<span class='danger'>You are nearing the spam filter limit for identical messages.</span>")
			return FALSE

	else
		last_message = message
		last_message_count = 0
		return FALSE

//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(filelength > UPLOAD_LIMIT)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>")
		return FALSE
/*	//Don't need this at the moment. But it's here if it's needed later.
	//Helps prevent multiple files being uploaded at once. Or right after eachother.
	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		to_chat(src, "<font color='red'>Error: AllowUpload(): Spam prevention. Please wait [round(time_to_wait/10)] seconds.</font>")
		return 0
	fileaccess_timer = world.time + FTPDELAY	*/
	return TRUE


	///////////
	//CONNECT//
	///////////
/client/New(TopicData)
	// TODO: Remove with 516
	if(byond_version >= 516) // Enable 516 compat browser storage mechanisms
		winset(src, "", "browser-options=byondstorage,find")

	var/tdata = TopicData //save this for later use
	// Instantiate stat panel
	stat_panel = new(src, "statbrowser")
	stat_panel.subscribe(src, PROC_REF(on_stat_panel_message))

	persistent = GLOB.persistent_clients[ckey]
	if(!persistent)
		persistent = new(ckey)
		GLOB.persistent_clients[ckey] = persistent

	tgui_panel = new(src, "chat_panel")
	tgui_say = new(src, "tgui_say")
	TopicData = null							//Prevent calls to client.Topic from connect

	if(connection != "seeker")					//Invalid connection type.
		return null

	if(byond_version < MIN_CLIENT_VERSION) // Too out of date to play at all. Unfortunately, we can't send them a message here.
		version_blocked = TRUE

	if(byond_build < GLOB.configuration.general.minimum_client_build)
		version_blocked = TRUE

	var/show_update_prompt = FALSE

	if(byond_version < SUGGESTED_CLIENT_VERSION) // Update is suggested, but not required.
		show_update_prompt = TRUE

	else if(byond_version == SUGGESTED_CLIENT_VERSION && byond_build < SUGGESTED_CLIENT_BUILD)
		show_update_prompt = TRUE

	// Actually sent to client much later, so it appears after MOTD.
	to_chat(src, "<span class='warning'>If the title screen is black, resources are still downloading. Please be patient until the title screen appears.</span>")

	GLOB.directory[ckey] = src
	// Admin Authorisation
	// Automatically makes localhost connection an admin
	try_localhost_autoadmin()

	log_client_to_db(tdata) // Make sure our client exists in the DB

	pai_save = new(src)

	// This is where we load all of the clients stuff from the DB
	if(SSdbcore.IsConnected())
		// Load in all our client data from the DB
		var/list/datum/db_query/login_queries = list() // List of queries to run for login processing

		for(var/datum/client_login_processor/CLP as anything in GLOB.client_login_processors)
			login_queries[CLP.type] = CLP.get_query(src)

		SSdbcore.MassExecute(login_queries, TRUE, FALSE, TRUE, FALSE) // Warn, no qdel, assoc, no log

		// Now do fancy things with the results
		for(var/datum/client_login_processor/CLP as anything in GLOB.client_login_processors)
			CLP.process_result(login_queries[CLP.type], src)

		QDEL_LIST_ASSOC_VAL(login_queries) // Clear out the used queries

	else
		// Set vars here that need to be set if the DB is offline

		// Give blank prefs
		prefs = new /datum/preferences(src)
		prefs.character_saves = list()

		// Random character
		prefs.character_saves += new /datum/character_save
		prefs.active_character = prefs.character_saves[1]

		// ToS accepted
		tos_consent = TRUE

	holder = GLOB.admin_datums[ckey]
	if(holder)
		holder.associate(src, delay_2fa_complaint = TRUE)
		// Must be async because any sleeps (happen in sql queries) will break connecting clients
		INVOKE_ASYNC(src, PROC_REF(admin_memo_output), "Show", FALSE, TRUE)

	// Holder set up. Inform the relevant places
	INVOKE_ASYNC(src, PROC_REF(announce_join))

	// Setup widescreen
	view = prefs.viewrange

	prefs.init_keybindings(prefs.keybindings_overrides) //The earliest sane place to do it where prefs are not null, if they are null you can't do crap at lobby
	fps = prefs.clientfps

	// Log alts
	if(length(related_accounts_ip))
		log_admin("[key_name(src)] Alts by IP: [jointext(related_accounts_ip, " ")]")

	if(length(related_accounts_cid))
		log_admin("[key_name(src)] Alts by CID: [jointext(related_accounts_cid, " ")]")

	#ifdef MULTIINSTANCE
	// This sleeps so it has to go here. Dont fucking move it.
	SSinstancing.update_playercache(ckey)
	#endif

	// This has to go here to avoid issues
	// If you sleep past this point, you will get SSinput errors as well as goonchat errors
	// DO NOT STUFF RANDOM SQL QUERIES BELOW THIS POINT WITHOUT USING `INVOKE_ASYNC()` OR SIMILAR
	// YOU WILL BREAK STUFF. SERIOUSLY. -aa07
	GLOB.clients += src
	connection_time = world.time

	// Forcibly enable hardware-accelerated graphics, as we need them for the lighting overlays.
	// (but turn them off first, since sometimes BYOND doesn't turn them on properly otherwise)
	spawn(5) // And wait a half-second, since it sounds like you can do this too fast.
		if(src)
			winset(src, null, "command=\".configure graphics-hwmode off\"")
			winset(src, null, "command=\".configure graphics-hwmode on\"")

	// Try doing this before mob login
	generate_clickcatcher()
	apply_clickcatcher()

	. = ..()	//calls mob.Login()

	mob.update_client_colour(0) // Activate colourblind mode if they have one set


	if(ckey in GLOB.clientmessages)
		for(var/message in GLOB.clientmessages[ckey])
			to_chat(src, message)
		GLOB.clientmessages.Remove(ckey)

	acquire_dpi()

	if(SSinput.initialized)
		set_macros()

	// Initialize tgui panel
	tgui_panel.initialize()
	// Initialize stat panel
	stat_panel.initialize(
		inline_html = file2text('html/statbrowser.html'),
		inline_js = file2text('html/statbrowser.js'),
		inline_css = file2text('html/statbrowser.css'),
	)
	addtimer(CALLBACK(src, PROC_REF(check_panel_loaded)), 30 SECONDS)

	// Initialize tgui say
	tgui_say.initialize()

	check_ip_intel()
	send_resources()
	SSchangelog.UpdatePlayerChangelogButton(src)

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

	update_ambience_pref()

	//This is down here because of the browse() calls in tooltip/New()
	if(!tooltips)
		tooltips = new /datum/tooltip(src)

	Master.UpdateTickRate()
	INVOKE_ASYNC(src, TYPE_PROC_REF(/client, nag_516))

	// Tell clients about active testmerges
	if(world.TgsAvailable() && length(GLOB.revision_info.testmerges))
		to_chat(src, GLOB.revision_info.get_testmerge_chatmessage(TRUE))

	if(check_rights(R_ADMIN, FALSE, mob)) // Mob is required. Dont even try without it.
		to_chat(src, "The queue server is currently [SSqueue.queue_enabled ? "<font color='green'>enabled</font>" : "<font color='disabled'>disabled</font>"], with a threshold of <b>[SSqueue.queue_threshold]</b>. This <b>[SSqueue.persist_queue ? "will" : "will not"]</b> persist through rounds.")

	if(holder && holder.restricted_by_2fa)
		to_chat(src,"<span class='boldannounceooc'><big>You do not have 2FA enabled. Admin verbs will be unavailable until you have enabled 2FA.\nTo setup 2FA, head to the following menu: <a href='byond://?_src_=prefs;preference=tab;tab=[TAB_GAME]'>Game Preferences</a></span>")  // Very fucking obvious
	// Tell client about their connection
	to_chat(src, "<span class='notice'>You are currently connected [prefs.server_region ? "via the <b>[prefs.server_region]</b> relay" : "directly"] to Paradise.</span>")
	to_chat(src, "<span class='notice'>You can change this using the <code>Change Region</code> verb in the OOC tab, as selecting a region closer to you may reduce latency.</span>")
	display_job_bans(TRUE)

/client/proc/is_connecting_from_localhost()
	var/static/list/localhost_addresses = list("127.0.0.1", "::1")
	if((!address && !world.port) || (address in localhost_addresses))
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
	announce_leave() // Do not put this below
	SSdebugview.stop_processing(src)
	SSchangelog.startup_clients_open -= src

	if(holder)
		holder.owner = null
		GLOB.admins -= src

	GLOB.directory -= ckey
	GLOB.clients -= src
	#ifdef MULTIINSTANCE
	SSinstancing.update_playercache() // Clear us out
	#endif
	QDEL_NULL(pai_save)

	if(movingmob)
		movingmob.client_mobs_in_contents -= mob
		UNSETEMPTY(movingmob.client_mobs_in_contents)

	if(obj_window)
		QDEL_NULL(obj_window)

	SSambience.ambience_listening_clients -= src
	SSinput.processing -= src
	SSping.current_run -= src
	Master.UpdateTickRate()
	..() //Even though we're going to be hard deleted there are still some things that want to know the destroy is happening
	return QDEL_HINT_HARDDEL_NOW


/client/proc/announce_join()
	if(!holder)
		return

	if(holder.rights & R_MENTOR)
		if(SSredis.connected)
			var/list/mentorcounter = staff_countup(R_MENTOR)
			var/msg = "**[ckey]** logged in. **[mentorcounter[1]]** mentor[mentorcounter[1] == 1 ? "" : "s"] online."
			var/list/data = list()
			data["author"] = "alice"
			data["source"] = GLOB.configuration.system.instance_id
			data["message"] = msg
			SSredis.publish("byond.msay", json_encode(data))

	else if(holder.rights & R_BAN)
		if(SSredis.connected)
			var/list/admincounter = staff_countup(R_BAN)
			var/msg = "**[ckey]** logged in. **[admincounter[1]]** admin[admincounter[1] == 1 ? "" : "s"] online."
			var/list/data = list()
			data["author"] = "alice"
			data["source"] = GLOB.configuration.system.instance_id
			data["message"] = msg
			SSredis.publish("byond.asay", json_encode(data))

/client/proc/announce_leave()
	if(!holder)
		return

	if(holder.rights & R_MENTOR)
		if(SSredis.connected)
			var/list/mentorcounter = staff_countup(R_MENTOR)
			var/mentor_count = mentorcounter[1]
			if(!(holder.fakekey || is_afk()))
				mentor_count-- // Exclude ourself
			var/msg = "**[ckey]** logged out. **[mentor_count]** mentor[mentor_count == 1 ? "" : "s"] online."
			var/list/data = list()
			data["author"] = "alice"
			data["source"] = GLOB.configuration.system.instance_id
			data["message"] = msg
			SSredis.publish("byond.msay", json_encode(data))

	else if(holder.rights & R_BAN)
		if(SSredis.connected)
			var/list/admincounter = staff_countup(R_BAN)
			var/admin_count = admincounter[1]
			if(!(holder.fakekey || is_afk()))
				admin_count-- // Exclude ourself
			var/msg = "**[ckey]** logged out. **[admin_count]** admin[admin_count == 1 ? "" : "s"] online."
			var/list/data = list()
			data["author"] = "alice"
			data["source"] = GLOB.configuration.system.instance_id
			data["message"] = msg
			SSredis.publish("byond.asay", json_encode(data))


/client/proc/donor_loadout_points()
	if(donator_level > 0 && prefs)
		prefs.max_gear_slots = GLOB.configuration.general.base_loadout_points + 5

/client/proc/log_client_to_db(connectiontopic)
	if(IsGuestKey(key))
		return

	if(!SSdbcore.IsConnected())
		return

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT id, datediff(Now(), firstseen) as age FROM player WHERE ckey=:ckey", list(
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

	// Admins don't get slammed by this, I guess
	if(!holder && check_randomizer(connectiontopic))
		return

	var/client_address = address
	if(!client_address) // Localhost can sometimes have no address set
		client_address = "127.0.0.1"

	if(sql_id)
		//Just the standard check to see if it's actually a number
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			return // Return here because if we somehow didnt pull a number from an INT column, EVERYTHING is breaking

		//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
		var/datum/db_query/query_update = SSdbcore.NewQuery("UPDATE player SET lastseen=NOW(), ip=:sql_ip, computerid=:sql_cid WHERE id=:sql_id", list(
			"sql_ip" = client_address,
			"sql_cid" = computer_id,
			"sql_id" = sql_id
		))

		if(!query_update.warn_execute())
			qdel(query_update)
			return

		qdel(query_update)
		// After the regular update
		INVOKE_ASYNC(src, TYPE_PROC_REF(/client, get_byond_account_date), FALSE) // Async to avoid other procs in the client chain being delayed by a web request

	else
		//New player!! Need to insert all the stuff
		var/datum/db_query/query_insert = SSdbcore.NewQuery("INSERT INTO player (id, ckey, firstseen, lastseen, ip, computerid) VALUES (null, :ckey, Now(), Now(), :ip, :cid)", list(
			"ckey" = ckey,
			"ip" = client_address,
			"cid" = computer_id,
		))
		if(!query_insert.warn_execute())
			qdel(query_insert)
			return
		qdel(query_insert)
		// This is their first connection instance, so TRUE here to notify admins
		// This needs to happen here to ensure they actually have a row to update
		INVOKE_ASYNC(src, TYPE_PROC_REF(/client, get_byond_account_date), TRUE) // Async to avoid other procs in the client chain being delayed by a web request

	// Log player connections to DB
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(log_connection), ckey, address, computer_id, CONNECTION_TYPE_ESTABLISHED)

/client/proc/check_ip_intel()
	set waitfor = 0 //we sleep when getting the intel, no need to hold up the client connection while we sleep
	if(GLOB.configuration.ipintel.enabled)
		if(GLOB.configuration.ipintel.playtime_ignore_threshold && GLOB.configuration.jobs.enable_exp_tracking)
			var/living_hours = get_exp_type_num(EXP_TYPE_LIVING) / 60
			if(living_hours >= GLOB.configuration.ipintel.playtime_ignore_threshold)
				return

		if(is_connecting_from_localhost())
			log_debug("check_ip_intel: skip check for player [key_name_admin(src)] connecting from localhost.")
			return

		if(GLOB.ipintel_manager.vpn_whitelist_check(ckey))
			log_debug("check_ip_intel: skip check for player [key_name_admin(src)] [address] on whitelist.")
			return

		var/datum/ipintel/res = GLOB.ipintel_manager.get_ip_intel(address)
		ip_intel = res.intel
		verify_ip_intel()

/client/proc/verify_ip_intel()
	if(ip_intel >= GLOB.configuration.ipintel.bad_rating)
		var/detailsurl = GLOB.configuration.ipintel.details_url ? "(<a href='[GLOB.configuration.ipintel.details_url][address]'>IP Info</a>)" : ""
		if(GLOB.configuration.ipintel.whitelist_mode)
			// Do not move this to isBanned(). This may sound weird, but:
			// This needs to happen after their account is put into the DB
			// This way, admins can then note people
			spawn(40) // This is necessary because without it, they won't see the message, and addtimer cannot be used because the timer system may not have initialized yet
				message_admins("<span class='adminnotice'>IPIntel: [key_name_admin(src)] on IP [address] was rejected. [detailsurl]</span>")
				var/blockmsg = "<B>Error: proxy/VPN detected. Proxy/VPN use is not allowed here. Deactivate it before you reconnect.</B>"
				if(GLOB.configuration.url.banappeals_url)
					blockmsg += "\nIf you are not actually using a proxy/VPN, or have no choice but to use one, request whitelisting at: [GLOB.configuration.url.banappeals_url]"
				to_chat(src, blockmsg)
				qdel(src)
		else
			message_admins("<span class='adminnotice'>IPIntel: [key_name_admin(src)] on IP [address] is likely to be using a Proxy/VPN. [detailsurl]</span>")


/client/proc/check_forum_link()
	if(!GLOB.configuration.url.forum_link_url || !prefs || prefs.fuid)
		return

	if(GLOB.configuration.jobs.enable_exp_tracking)
		var/living_hours = get_exp_type_num(EXP_TYPE_LIVING) / 60
		if(living_hours < 20)
			return

	to_chat(src, "<B>You have no verified forum account. <a href='byond://?src=[UID()];link_forum_account=true'>VERIFY FORUM ACCOUNT</a></B>")

/client/proc/create_oauth_token()
	var/datum/db_query/query_find_token = SSdbcore.NewQuery("SELECT token FROM oauth_tokens WHERE ckey=:ckey limit 1", list(
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

	var/datum/db_query/query_insert_token = SSdbcore.NewQuery("INSERT INTO oauth_tokens (ckey, token) VALUES(:ckey, :tokenstr)", list(
		"ckey" = ckey,
		"tokenstr" = tokenstr,
	))

	// These queries have log_error=FALSE to avoid auth tokens being in plaintext logs
	if(!query_insert_token.warn_execute(log_error = FALSE))
		qdel(query_insert_token)
		return

	qdel(query_insert_token)
	return tokenstr

/client/proc/link_forum_account(fromban)
	if(!GLOB.configuration.url.forum_link_url)
		return

	if(IsGuestKey(key))
		to_chat(src, "Guest keys cannot be linked.")
		return

	if(prefs && prefs.fuid)
		if(!fromban)
			to_chat(src, "Your forum account is already set.")
		return

	var/datum/db_query/query_find_link = SSdbcore.NewQuery("SELECT fuid FROM player WHERE ckey=:ckey LIMIT 1", list(
		"ckey" = ckey
	))

	if(!query_find_link.warn_execute())
		qdel(query_find_link)
		return

	if(query_find_link.NextRow())
		if(query_find_link.item[1])
			if(!fromban)
				to_chat(src, "Your forum account is already set. ([query_find_link.item[1]])")
			qdel(query_find_link)
			return

	qdel(query_find_link)
	var/tokenid = create_oauth_token()
	if(!tokenid)
		to_chat(src, "link_forum_account: unable to create token")
		return

	var/url = "[GLOB.configuration.url.forum_link_url][tokenid]"
	if(fromban)
		url += "&fwd=appeal"
		to_chat(src, {"Now opening a window to verify your information with the forums, so that you can appeal your ban. If the window does not load, please copy/paste this link: <a href="[url]">[url]</a>"})
		to_chat(src, "<span class='boldannounceooc'>If you are screenshotting this screen for your ban appeal, please blur/draw over the token in the above link.</span>")
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
	if(!GLOB.configuration.general.enabled_cid_randomiser_buster)
		return

	// Stash o' ckeys
	var/static/cidcheck = list()
	var/static/tokens = list()
	// Ckeys that failed the test, stored to send acceptance messages only for atoners
	var/static/cidcheck_failedckeys = list()
	var/static/cidcheck_spoofckeys = list()

	var/oldcid = cidcheck[ckey]

	if(!oldcid)
		var/datum/db_query/query_cidcheck = SSdbcore.NewQuery("SELECT computerid FROM player WHERE ckey=:ckey", list(
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
			winset(src, "reconnectbutton", "is-disabled=true")

			tokens[ckey] = cid_check_reconnect()
			sleep(10) // Since browse is non-instant, and kinda async

			to_chat(src, "<pre class=\"system system\">you're a huge nerd. wakka wakka doodle doop nobody's ever gonna see this, the chat system shouldn't be online by this point</pre>")
			qdel(src)
			return TRUE

	else
		if(!topic || !topic["token"] || !tokens[ckey] || topic["token"] != tokens[ckey])
			if(!cidcheck_spoofckeys[ckey])
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
				GLOB.discord_manager.send2discord_simple_noadmins("**\[Warning]** [key_name(src)] has been detected as using a CID randomizer. Connection rejected.")
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
				GLOB.discord_manager.send2discord_simple_noadmins("**\[Info]** [key_name(src)] has been allowed to connect after showing they removed their cid randomizer.")
				cidcheck_failedckeys -= ckey

			if(cidcheck_spoofckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name_admin(src)] has been allowed to connect after appearing to have attempted to spoof a cid randomizer check because it <i>appears</i> they aren't spoofing one this time</span>")
				cidcheck_spoofckeys -= ckey
			cidcheck -= ckey

/client/proc/note_randomizer_user()
	var/const/adminckey = "CID-Error"

	// Check for notes in the last day - only 1 note per 24 hours
	var/datum/db_query/query_get_notes = SSdbcore.NewQuery("SELECT id from notes WHERE ckey=:ckey AND adminckey=:adminckey AND timestamp + INTERVAL 1 DAY < NOW()", list(
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
	var/datum/db_query/query_get_note = SSdbcore.NewQuery("SELECT adminckey FROM notes WHERE ckey=:ckey ORDER BY timestamp DESC LIMIT 1", list(
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
	add_note(ckey, "Detected as using a cid randomizer.", null, adminckey, logged = FALSE)

/client/proc/cid_check_reconnect()
	var/token = md5("[rand(0,9999)][world.time][rand(0,9999)][ckey][rand(0,9999)][address][rand(0,9999)][computer_id][rand(0,9999)]")
	. = token

	log_adminwarn("Failed Login: [key] [computer_id] [address] - CID randomizer check")

	var/url = winget(src, null, "url")

	//special javascript to make them reconnect under a new window.
	src << browse("<!DOCTYPE html><a id='link' href='byond://[url]?token=[token]'>\
		byond://[url]?token=[token]\
	</a>\
	<script type='text/javascript'>\
		document.getElementById(\"link\").click();\
		window.location=\"byond://winset?command=.quit\"\
	</script>",
	"border=0;titlebar=0;size=1x1")

	to_chat(src, "<a href='byond://[url]?token=[token]'>You will be automatically taken to the game, if not, click here to be taken manually</a>. Except you can't, since the chat window doesn't exist yet.")

/client/proc/is_afk(duration = 5 MINUTES)
	if(inactivity > duration)
		return inactivity
	return 0

//Send resources to the client.
/client/proc/send_resources()
	// Change the way they should download resources.
	if(length(GLOB.configuration.url.rsc_urls))
		preload_rsc = pick(GLOB.configuration.url.rsc_urls)
	else
		preload_rsc = 1 // If config.resource_urls is not set, preload like normal.

	spawn (10) //removing this spawn causes all clients to not get verbs.

		//load info on what assets the client has
		src << browse('code/modules/asset_cache/validate_assets.html', "window=asset_cache_browser")

		//Precache the client with all other assets slowly, so as to not block other browse() calls
		if(GLOB.configuration.asset_cache.asset_simple_preload)
			addtimer(CALLBACK(SSassets.transport, TYPE_PROC_REF(/datum/asset_transport, send_assets_slow), src, SSassets.transport.preload), 5 SECONDS)

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

/client/proc/generate_clickcatcher()
	if(!void)
		void = new()
	screen += void

/client/proc/apply_clickcatcher()
	generate_clickcatcher()
	var/list/actualview = getviewsize(view)
	void.UpdateGreed(actualview[1],actualview[2])

/client/proc/send_ssd_warning(mob/M)
	if(!GLOB.configuration.general.ssd_warning)
		return FALSE

	if(ssd_warning_acknowledged)
		return FALSE

	if(M?.player_logged < SSD_WARNING_TIMER)
		return FALSE

	to_chat(src, "Are you taking this person to cryo or giving them medical treatment? If you are, <a href='byond://?src=[UID()];ssdwarning=accepted'>confirm that</a> and proceed. Interacting with SSD players in other ways is against server rules unless you've ahelped first for permission.")
	return TRUE

#undef SSD_WARNING_TIMER

/**
  * Retrieves the BYOND accounts data from the BYOND servers
  *
  * Makes a web request to byond.com to retrieve the details for the BYOND account associated with the clients ckey.
  * Returns the data in a parsed, associative list
  */
/client/proc/retrieve_byondacc_data()
	// Do not refactor this to use SShttp, because that requires the subsystem to be firing for requests to be made, and this will be triggered before the MC has finished loading
	var/list/http[] = HTTPGet("http://www.byond.com/members/[ckey]?format=text")
	if(http)
		var/status = text2num(http["STATUS"])

		if(status == 200)
			// This is wrapped in try/catch because lummox could change the format on any day without informing anyone
			try
				var/list/lines = splittext(http["CONTENT"], "\n")
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
	var/datum/db_query/query_date = SSdbcore.NewQuery("SELECT byond_date, DATEDIFF(Now(), byond_date) FROM player WHERE ckey=:ckey", list(
		"ckey" = ckey
	))

	if(!query_date.warn_execute())
		qdel(query_date)
		return

	while(query_date.NextRow())
		byondacc_date = query_date.item[1]
		byondacc_age = max(text2num(query_date.item[2]), 0) // Ensure account isnt negative days old

	qdel(query_date)

	// They have a date already, lets bail
	if(byondacc_date)
		return

	// They dont have a date, lets grab one
	var/list/byond_data = retrieve_byondacc_data()
	if(isnull(byond_data) || !(byond_data["general"]["joined"]))
		log_debug("Failed to retrieve an account creation date for [ckey].")
		return

	byondacc_date = byond_data["general"]["joined"]

	// Now save it
	var/datum/db_query/query_update = SSdbcore.NewQuery("UPDATE player SET byond_date=:date WHERE ckey=:ckey", list(
		"date" = byondacc_date,
		"ckey" = ckey
	))

	if(!query_update.warn_execute())
		qdel(query_update)
		return

	qdel(query_update)

	// Now retrieve the age again because BYOND doesnt have native methods for this
	var/datum/db_query/query_age = SSdbcore.NewQuery("SELECT DATEDIFF(Now(), byond_date) FROM player WHERE ckey=:ckey", list(
		"ckey" = ckey
	))

	if(!query_age.warn_execute())
		qdel(query_age)
		return

	while(query_age.NextRow())
		byondacc_age = max(text2num(query_age.item[1]), 0) // Ensure account isnt negative days old

	qdel(query_age)

	// Notify admins on new clients connecting, if the byond account age is less than a config value
	if(notify && (byondacc_age < GLOB.configuration.general.byond_account_age_threshold))
		message_admins("[key] has just connected for the first time. BYOND account registered on [byondacc_date] ([byondacc_age] days old)")

/client/proc/show_update_notice()
	to_chat(src, "<span class='userdanger'>Your BYOND client (v: [byond_version].[byond_build]) is out of date. This can cause glitches. We highly suggest you download the latest client from <a href='https://www.byond.com/download/'>byond.com</a> before playing. You can also update via the BYOND launcher application.</span>")

/client/proc/update_ambience_pref()
	if(prefs.sound & SOUND_AMBIENCE)
		if(SSambience.ambience_listening_clients[src] > world.time)
			return // If already properly set we don't want to reset the timer.

		SSambience.ambience_listening_clients[src] = world.time + 10 SECONDS //Just wait 10 seconds before the next one aight mate? cheers.

	else
		SSambience.ambience_listening_clients -= src

/client/proc/try_localhost_autoadmin()
	if(!GLOB.configuration.admin.enable_localhost_autoadmin)
		return FALSE
	if(!is_connecting_from_localhost())
		if(holder && holder.is_localhost_autoadmin)
			qdel(holder)
		return FALSE

	// Unhook the old admin datum, if any.
	if(holder)
		qdel(holder)

	// Hook up a new localhost admin datum.
	var/datum/admins/admin_datum = new /datum/admins("!LOCALHOST!", R_HOST, ckey)
	admin_datum.is_localhost_autoadmin = TRUE
	admin_datum.associate(src)
	return TRUE

// Verb scoped to the client level so its ALWAYS available
/client/verb/open_tos()
	set category = "OOC"
	set name = "Terms of Service"

	var/output = GLOB.join_tos
	output += "<hr><p>By withdrawing your consent, you acknowledge that you will be instantaneously kicked from the server and will have to re-accept the Terms of Service. If you do not wish to withdraw your consent at this moment, feel free to close this window.</p>"
	output += "<p><a href='byond://?src=[UID()];withdraw_consent=1'>Withdraw consent</a></p>"

	var/datum/browser/popup = new(src, "privacy_consent", "<div align='center'>Privacy Consent</div>", 500, 400)

	popup.set_content(output)
	popup.open(FALSE)

/client/verb/change_region()
	set category = "OOC"
	set name = "Change Region"

	if(!length(GLOB.configuration.system.region_map))
		to_chat(usr, "<span class='warning'>Error: No extra regions defined for this server</span>")
		return

	var/list/target_regions = list("--DIRECT--")
	for(var/region in GLOB.configuration.system.region_map)
		target_regions += region

	var/formatted_existing = (prefs.server_region ? prefs.server_region : "--DIRECT--")

	var/choice = input(usr, "Select a region for routing optimisation.\nSelecting --DIRECT-- will bypass routing optimisations.", "Region", formatted_existing) as null|anything in target_regions

	if(!choice || (choice == formatted_existing))
		return

	prefs.server_region = choice
	prefs.save_preferences(src)

	alert(usr, "Now routing you from [formatted_existing] to [choice]. You will briefly disconnect.", "ALERT", "Ok")

	if(choice == "--DIRECT--")
		src << link("byond://[GLOB.configuration.url.server_url]")
	else
		src << link(GLOB.configuration.system.region_map[choice])

/client/proc/set_eye(new_eye)
	if(new_eye == eye)
		return
	eye = new_eye

/client/proc/clear_screen()
	for(var/object in screen)
		screen -= object

/client/verb/reload_graphics()
	set category = "Special Verbs"
	set name = "Reload Graphics"

	winset(src, null, "command=\".configure graphics-hwmode off\"")
	winset(src, null, "command=\".configure graphics-hwmode on\"")

/// Returns the biggest number from client.view so we can do easier maths
/client/proc/maxview()
	var/list/screensize = getviewsize(view)
	return max(screensize[1], screensize[2])

/client/Click(object, location, control, params)
	. = ..()
	// please yell at me if this is Too Much
	SEND_SIGNAL(src, COMSIG_CLIENT_CLICK, object, location, control, params, usr)

/// Compiles a full list of verbs and sends it to the browser
/client/proc/init_verbs()
	if(IsAdminAdvancedProcCall())
		return
	var/list/verblist = list()
	var/list/verbstoprocess = verbs.Copy()
	if(mob)
		verbstoprocess += mob.verbs
		for(var/AM in mob.contents)
			var/atom/movable/thing = AM
			verbstoprocess += thing.verbs
	panel_tabs.Cut() // panel_tabs get reset in init_verbs on JS side anyway
	for(var/thing in verbstoprocess)
		var/procpath/verb_to_init = thing
		if(!verb_to_init)
			continue
		if(verb_to_init.hidden)
			continue
		if(!istext(verb_to_init.category))
			continue
		panel_tabs |= verb_to_init.category
		verblist[++verblist.len] = list(verb_to_init.category, verb_to_init.name)
	src.stat_panel.send_message("init_verbs", list(panel_tabs = panel_tabs, verblist = verblist))

/client/proc/check_panel_loaded()
	if(stat_panel.is_ready())
		return
	to_chat(src, "<span class='userdanger'>Statpanel failed to load, click <a href='byond://?src=[UID()];reload_statbrowser=1'>here</a> to reload the panel </span>")

/**
 * Handles incoming messages from the stat-panel TGUI.
 */
/client/proc/on_stat_panel_message(type, payload)
	switch(type)
		if("Update-Verbs")
			init_verbs()
		if("Remove-Tabs")
			panel_tabs -= payload["tab"]
		if("Send-Tabs")
			panel_tabs |= payload["tab"]
		if("Reset-Tabs")
			panel_tabs = list()
		if("Set-Tab")
			stat_tab = payload["tab"]
			SSstatpanels.immediate_send_stat_data(src)
		if("Listedturf-Scroll")
			if(payload["min"] == payload["max"])
				// Not properly loaded yet, send the default set.
				SSstatpanels.refresh_client_obj_view(src)
			else
				SSstatpanels.refresh_client_obj_view(src, payload["min"], payload["max"])
		// Uncomment to enable log_debug in stat panel code.
		// Disabled normally due to HREF exploit concerns.
		//if("Statpanel-Debug")
		//	log_debug(payload)
		if("Resend-Asset")
			SSassets.transport.send_assets(src, list(payload))
		if("Debug-Stat-Entry")
			var/stat_item = locateUID(payload["stat_item_uid"])
			if(!check_rights(R_DEBUG | R_VIEWRUNTIMES) || !stat_item)
				return
			var/class
			if(istype(stat_item, /datum/controller/subsystem))
				class = "subsystem"
			else if(istype(stat_item, /datum/controller))
				class = "controller"
			else if(istype(stat_item, /datum))
				class = "datum"
			else
				class = "unknown"
			debug_variables(stat_item)
			message_admins("Admin [key_name_admin(usr)] is debugging the [stat_item] [class].")
/**
*	Handles fullscreen on the client.
*/
/client/verb/toggle_fullscreen()
	set name = "Toggle Fullscreen"
	set category = "OOC"

	fullscreen = !fullscreen

	if(fullscreen)
		winset(usr, "mainwindow", "titlebar=false")
		winset(usr, "mainwindow", "can-resize=false")
		winset(usr, "mainwindow", "is-maximized=false")  // Ensures the window doesn't get stretched oddly.
		winset(usr, "mainwindow", "is-maximized=true")
		winset(usr, "mainwindow", "is-fullscreen=true")
		winset(usr, "mainwindow", "menu=")				 // Top-Menu bar [DISABLED]
	else
		winset(usr, "mainwindow", "titlebar=true")
		winset(usr, "mainwindow", "can-resize=true")
		winset(usr, "mainwindow", "is-fullscreen=false") // Order matters. Fullscreen [OFF] -> Maximize [TRUE]
		winset(usr, "mainwindow", "is-maximized=true")
		winset(usr, "mainwindow", "menu=menu")
	var/fullscreen_state = fullscreen ? "on" : "off"
	to_chat(usr, "Toggled fullscreen [fullscreen_state]. To Toggle fullscreen; Go to the tab OOC -> Toggle fullscreen or press F11")
	fit_viewport()

/client/proc/try_open_reagent_editor(atom/target)
	var/target_UID = target.UID()
	var/datum/reagents_editor/editor
	// editors is static, it can be accessed using a null reference
	editor = editor.editors[target_UID]
	if(!editor)
		editor = new /datum/reagents_editor(target)
		editor.editors[target_UID] = editor

	editor.ui_interact(mob)

/client/verb/stop_client_sounds()
	set category = "Special Verbs"
	set name = "Stop Sounds"
	set desc = "Stop Current Sounds."
	SEND_SOUND(usr, sound(null))
	to_chat(src, "All sounds stopped.")
	tgui_panel?.stop_music()

/client/proc/acquire_dpi()
	set waitfor = FALSE

	// Remove with 516
	if(byond_version < 516)
		return

	window_scaling = text2num(winget(src, null, "dpi"))

// This is in its own proc so we can async it out
/client/proc/nag_516()
	if(byond_version >= 516)
		return

	var/choice = alert(src, "Warning - You are currently on BYOND version [byond_version].[byond_build]. Soon, Paradise will start enforcing 516 as the minimum required version, and 515 will no longer work. Please update now to avoid being unable to play in the future.", "BYOND Version Warning", "Update Now", "Ignore for now")
	if(choice != "Update Now")
		return

	src << link("https://secure.byond.com/download/")

/datum/persistent_client/New(ckey)
	// Create a PM tracker bound to this ckey.
	pm_tracker = new(ckey)

#undef LIMITER_SIZE
#undef CURRENT_SECOND
#undef SECOND_COUNT
#undef CURRENT_MINUTE
#undef MINUTE_COUNT
#undef ADMINSWARNED_AT

#undef SUGGESTED_CLIENT_VERSION
#undef SUGGESTED_CLIENT_BUILD
