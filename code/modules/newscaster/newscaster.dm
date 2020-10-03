#define CHANNEL_NAME_MAX_LENGTH 50
#define CHANNEL_DESC_MAX_LENGTH 128
#define STORY_NAME_MAX_LENGTH 128
#define STORY_BODY_MAX_LENGTH 1024
#define WANTED_NOTICE_NAME_MAX_LENGTH 128
#define WANTED_NOTICE_DESC_MAX_LENGTH 512
#define STORIES_PER_LOAD 9999 // TODO during QP...

/obj/machinery/newscaster
	name = "newscaster"
	desc = "A standard Nanotrasen-licensed newsfeed handler for use in commercial space stations. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_normal"
	max_integrity = 200
	integrity_failure = 50
	light_range = 0
	anchored = TRUE
	/// The current screen index in the UI.
	var/screen = NEWSCASTER_HEADLINES
	/// The amount of newspapers the newscaster can print.
	var/paper_remaining = 15
	/// Whether the newscaster can be used to make wanted issues or not.
	var/is_security = FALSE
	/// Whether the newscaster has new stories or not.
	var/alert = FALSE
	/// The newcaster's index among all newscasters (GLOB.allNewscasters).
	var/unit_number = 0
	/// The name of the mob currently using the newscaster.
	var/scanned_user = "Unknown"
	/// The currently attached photo.
	var/obj/item/photo/photo = null
	/// The currently viewed channel.
	var/datum/feed_channel/viewing_channel = null
	/// Whether the unit is silent or not.
	var/is_silent = FALSE
	/// The current temporary notice.
	var/temp_notice
	/// Jobs that shouldn't be advertised if a position is available.
	var/list/jobblacklist = list(
		/datum/job/ai,
		/datum/job/cyborg,
		/datum/job/captain,
		/datum/job/judge,
		/datum/job/blueshield,
		/datum/job/nanotrasenrep,
		/datum/job/pilot,
		/datum/job/brigdoc,
		/datum/job/mechanic,
		/datum/job/barber,
		/datum/job/chaplain,
		/datum/job/ntnavyofficer,
		/datum/job/ntspecops,
		/datum/job/civilian,
		/datum/job/syndicateofficer)
	/// Redacted text
	var/static/REDACTED = "<b class='bad'>\[REDACTED\]</b>"
	/// Static, lazy list containing a user's last view time per channel.
	var/static/last_views

/obj/machinery/newscaster/security_unit
	name = "security newscaster"
	is_security = TRUE

/obj/machinery/newscaster/New()
	GLOB.allNewscasters += src
	unit_number = GLOB.allNewscasters.len
	update_icon() //for any custom ones on the map...
	if(!last_views)
		last_views = list()
	armor = list(melee = 50, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 30)
	..()

/obj/machinery/newscaster/Initialize(mapload)
	. = ..()

/obj/machinery/newscaster/Destroy()
	GLOB.allNewscasters -= src
	viewing_channel = null
	QDEL_NULL(photo)
	return ..()

/obj/machinery/newscaster/update_icon()
	cut_overlays()
	if(inoperable())
		icon_state = "newscaster_off"
	else
		if(!GLOB.news_network.wanted_issue) //wanted icon state, there can be no overlays on it as it's a priority message
			icon_state = "newscaster_normal"
			if(alert) //new message alert overlay
				add_overlay("newscaster_alert")
	var/hp_percent = obj_integrity * 100 / max_integrity
	switch(hp_percent)
		if(75 to INFINITY)
			return
		if(50 to 75)
			add_overlay("crack1")
		if(25 to 50)
			add_overlay("crack2")
		else
			add_overlay("crack3")

/obj/machinery/newscaster/power_change()
	..()
	update_icon()

/obj/machinery/newscaster/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = TRUE, attack_dir)
	. = ..()
	update_icon()

/obj/machinery/newscaster/attack_ghost(mob/user)
	tgui_interact(user)

/obj/machinery/newscaster/attack_hand(mob/user)
	if(..())
		return
	tgui_interact(user)

/obj/machinery/newscaster/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	if(can_scan(user))
		scanned_user = get_scanned_user(user)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Newscaster", name, 800, 600)
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/machinery/newscaster/tgui_data(mob/user)
	var/list/data = list()
	data["unit_number"] = unit_number
	data["is_security"] = is_security
	data["is_admin"] = user.can_admin_interact()
	data["is_silent"] = is_silent
	data["screen"] = screen
	data["modal"] = tgui_modal_data(src)
	if(data["modal"] && !isnull(data["modal"]["args"]["is_admin"]))
		data["modal"]["args"]["is_admin"] = user.can_admin_interact()
	data["temp"] = temp_notice

	// Wanted notice
	if(GLOB.news_network.wanted_issue)
		data["wanted"] = get_message_data(GLOB.news_network.wanted_issue, user)[1]
		data["world_time"] = world.time

	var/user_name = get_scanned_user(usr)
	switch(screen)
		if(NEWSCASTER_HEADLINES, NEWSCASTER_CHANNEL)
			// Get the list of stories to pick from - either all or from a specific channel depending on the screen
			var/list/message_list = GLOB.news_network.stories
			if(screen == NEWSCASTER_CHANNEL)
				if(!viewing_channel) // Uh oh, channel doesn't exist! Redirect to Headlines
					screen = NEWSCASTER_HEADLINES
					return tgui_data(user)
				message_list = viewing_channel.messages
				data["channel_idx"] = GLOB.news_network.channels.Find(viewing_channel)
				data["channel_can_manage"] = viewing_channel.can_modify(usr, user_name)
			// Append the data
			var/list/stories = list()
			data["stories"] = stories
			for(var/i in 1 to min(STORIES_PER_LOAD, length(message_list)))
				stories += get_message_data(message_list[i], user)
			// View and unread data
			var/now = world.time
			data["world_time"] = now
			if(user_name)
				// Increase views
				for(var/m in stories)
					if(now >= m["publish_time"])
						var/datum/feed_message/FM = locateUID(m["uid"])
						if(FM && !(FM.censor_flags & CENSOR_STORY))
							FM.view_count++
							m["view_count"] = FM.view_count
				// Update the last viewed times for the user
				LAZYINITLIST(last_views[user_name])
				for(var/c in GLOB.news_network.channels)
					var/datum/feed_channel/C = c
					if(screen == NEWSCASTER_CHANNEL && C != viewing_channel)
						continue
					last_views[user_name][C.UID()] = now
		if(NEWSCASTER_PRINT)
			// TODO
			// var/total_num = length(GLOB.news_network.channels)
			// var/active_num = total_num
			// var/message_num=0
			// for(var/datum/feed_channel/FC in GLOB.news_network.channels)
			// 	if(!FC.censored)
			// 		message_num += length(FC.messages)
			// 	else
			// 		active_num--
			// data["total_num"] = total_num
			// data["active_num"] = active_num
			// data["message_num"] = message_num
			// data["paper_remaining"] = paper_remaining * 100
		if(NEWSCASTER_JOBS)
			var/list/jobs = list()
			data["jobs"] = jobs
			for(var/cat in list("security", "engineering", "medical", "science", "service", "supply"))
				jobs[cat] = list()

			for(var/datum/job/job in SSjobs.occupations)
				if(job_blacklisted(job))
					continue
				if(job.is_position_available())
					var/list/opening_data = list("title" = job.title)
					// Is the job a command job?
					if(job.title in GLOB.command_positions)
						opening_data["is_command"] = TRUE
					// Add the job opening to the corresponding categories
					// Ugly!
					opening_data = list(opening_data)
					if(job.is_security)
						jobs["security"] += opening_data
					if(job.is_engineering)
						jobs["engineering"] += opening_data
					if(job.is_medical)
						jobs["medical"] += opening_data
					if(job.is_science)
						jobs["science"] += opening_data
					if(job.is_service)
						jobs["service"] += opening_data
					if(job.is_supply)
						jobs["supply"] += opening_data

	// Append temp photo
	if(photo && data["modal"] && data["modal"]["id"] in list("create_story", "wanted_notice"))
		data["photo"] = list(
			name = photo.name,
			uid = photo.UID(),
		)
		user << browse_rsc(photo.img, "inserted_photo_[photo.UID()].png")
	else
		data["photo"] = null

	// Append channels
	var/list/channels = list()
	data["channels"] = channels
	for(var/c in GLOB.news_network.channels)
		var/datum/feed_channel/C = c
		var/list/channel = list(
			uid = C.UID(),
			name = C.channel_name,
			author = C.author,
			description = C.description,
			icon = C.icon,
			public = C.is_public,
			frozen = C.frozen,
			admin = C.admin_locked,
			unread = 0,
		)
		// Add the number of unseen stories if authed
		if(user_name)
			var/last_view_time = (last_views[user_name] && last_views[user_name][C.UID()]) || 0
			for(var/m in C.messages)
				var/datum/feed_message/M = m
				if(last_view_time < M.publish_time)
					channel["unread"]++
		channels += list(channel)

	return data

/**
  * Returns a [/datum/feed_message] in a format that can be used as TGUI data.
  *
  * Arguments:
  * * FM - The story to send
  * * M - Optional. The user to send the story's photo to if it exists
  */
/obj/machinery/newscaster/proc/get_message_data(datum/feed_message/FM, mob/M)
	if(!(FM.censor_flags & CENSOR_STORY) && M && FM.img)
		M << browse_rsc(FM.img, "story_photo_[FM.UID()].png")
	return list(list(
		uid = FM.UID(),
		author = (FM.censor_flags & CENSOR_AUTHOR) ? "" : FM.author,
		title = (FM.censor_flags & CENSOR_STORY) ? "" : FM.title,
		body = (FM.censor_flags & CENSOR_STORY) ? "" : FM.body,
		admin_locked = FM.admin_locked,
		censor_flags = FM.censor_flags,
		view_count = FM.view_count,
		publish_time = FM.publish_time,
		publish_time_proper = station_time_timestamp(time = FM.publish_time),
		has_photo = !isnull(FM.img),
	))

/obj/machinery/newscaster/tgui_act(action, list/params)
	if(..())
		return

	. = TRUE
	if(tgui_act_modal(action, params))
		return

	switch(action)
		if("cleartemp")
			temp_notice = null
		if("jobs")
			screen = NEWSCASTER_JOBS
		if("headlines")
			if(screen == NEWSCASTER_HEADLINES)
				return FALSE
			screen = NEWSCASTER_HEADLINES
		if("channel")
			var/datum/feed_channel/FC = locateUID(params["uid"])
			if(!istype(FC))
				return
			if(screen == NEWSCASTER_CHANNEL && viewing_channel == FC)
				return FALSE
			screen = NEWSCASTER_CHANNEL
			viewing_channel = FC
		if("attach_photo")
			var/list/open_modal = tgui_modal_data(src)
			if(photo || !open_modal || !(open_modal["id"] in list("create_story", "wanted_notice")))
				return
			if(ishuman(usr))
				var/obj/item/photo/P = usr.get_active_hand()
				if(istype(P) && usr.unEquip(P))
					photo = P
					P.forceMove(src)
					usr.visible_message("<span class='notice'>[usr] inserts [P] into [src]'s photo slot.</span>",\
										"<span class='notice'>You insert [P] into [src]'s photo slot.</span>")
					playsound(loc, 'sound/machines/terminal_insert_disc.ogg', 30, TRUE)
			else if(issilicon(usr))
				var/mob/living/silicon/M = usr
				var/datum/picture/selection = M.aiCamera?.selectpicture()
				if(!selection)
					return
				var/obj/item/photo/P = new
				P.construct(selection)
				P.forceMove(src)
				photo = P
				visible_message("<span class='notice'>[src]'s photo slot quietly whirs as it prints [P] inside it.</span>")
				playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 15, TRUE)
		if("eject_photo")
			eject_photo(usr)
			return FALSE // Updating handled in that proc
		if("freeze_channel")
			if(is_security && !has_security_access(usr))
				set_temp("You do not have permission to perform this action. Please ensure your ID has appropiate access.", "danger")
				return
			var/datum/feed_channel/FC = locateUID(params["uid"])
			if(!istype(FC))
				return
			if(FC.admin_locked && !usr.can_admin_interact())
				set_temp("This channel has been locked by CentComm and thus cannot be (un)frozen.", "danger")
				return
			FC.frozen = !FC.frozen
		if("censor_author", "censor_story")
			if(is_security && !has_security_access(usr))
				set_temp("You do not have permission to perform this action. Please ensure your ID has appropiate access.", "danger")
				return
			var/datum/feed_message/FM = locateUID(params["uid"])
			if(!istype(FM))
				return
			if(FM.admin_locked && !usr.can_admin_interact())
				set_temp("This story has been locked by CentComm and thus cannot be censored in any way.", "danger")
				return
			if(action == "censor_author")
				FM.censor_flags = (FM.censor_flags & CENSOR_AUTHOR) ? (FM.censor_flags & ~CENSOR_AUTHOR) : (FM.censor_flags|CENSOR_AUTHOR)
			else if(action == "censor_story")
				FM.censor_flags = (FM.censor_flags & CENSOR_STORY) ? (FM.censor_flags & ~CENSOR_STORY) : (FM.censor_flags|CENSOR_STORY)
			else
				return FALSE
		if("clear_wanted_notice")
			if(is_security && !has_security_access(usr))
				set_temp("You do not have permission to perform this action. Please ensure your ID has appropiate access.", "danger")
				return
			var/datum/feed_message/WN = GLOB.news_network.wanted_issue
			if(!WN)
				return
			if(WN.admin_locked && !usr.can_admin_interact())
				set_temp("This wanted notice has been locked by CentComm and thus cannot be altered.", "danger")
				return
			GLOB.news_network.wanted_issue = null
			set_temp("Wanted notice cleared.", update_now = TRUE)
			return FALSE
		if("toggle_mute")
			is_silent = !is_silent
		else
			return FALSE

	add_fingerprint(usr)

/**
  * Called in tgui_act() to process modal actions
  *
  * Arguments:
  * * action - The action passed by tgui
  * * params - The params passed by tgui
  */
/obj/machinery/newscaster/proc/tgui_act_modal(action, list/params)
	. = TRUE
	var/id = params["id"]
	var/list/arguments = istext(params["arguments"]) ? json_decode(params["arguments"]) : params["arguments"]
	switch(tgui_modal_act(src, action, params))
		if(TGUI_MODAL_OPEN)
			switch(id)
				if("create_channel", "manage_channel")
					// If trying to manage the channel, make sure the user is allowed to!
					if(id == "manage_channel")
						var/datum/feed_channel/FC = locateUID(arguments["uid"])
						if(!istype(FC) || !FC.can_modify(usr, get_scanned_user(usr)))
							return
					tgui_modal_message(src, id, "", arguments = list(
						uid = arguments["uid"], // Only when managing a channel
						scanned_user = scanned_user,
						is_admin = usr.can_admin_interact(),
					))
				if("create_story", "wanted_notice") // Other modals
					if(id == "wanted_notice" && !(is_security || usr.can_admin_interact()))
						return
					tgui_modal_message(src, id, "", arguments = list(
						scanned_user = scanned_user,
						is_admin = usr.can_admin_interact(),
					))
				else
					return FALSE
		if(TGUI_MODAL_ANSWER)
			switch(id)
				if("create_channel", "manage_channel")
					var/author = trim(arguments["author"])
					var/name = trim(arguments["name"])
					if(!length(author) || !length(name))
						return
					var/description = trim(arguments["description"])
					var/icon = arguments["icon"]
					var/public = text2num(arguments["public"])
					var/admin_locked = text2num(arguments["admin_locked"])
					//
					var/datum/feed_channel/FC = null
					if(id == "create_channel") // Channel creation
						if(GLOB.news_network.get_channel_by_name(name))
							set_temp("A channel with this name already exists.", "danger")
							return
						// TODO: check if author already has made a channel or not
						FC = new
						GLOB.news_network.channels += FC
						feedback_inc("newscaster_channels", 1)
						// Redirect
						screen = NEWSCASTER_CHANNEL
						viewing_channel = FC
					else if (id == "manage_channel") // Channel management
						FC = locateUID(arguments["uid"])
						if(!FC || !FC.can_modify(usr, get_scanned_user(usr)))
							return
					// Add/update the information
					FC.channel_name = copytext(name, 1, CHANNEL_NAME_MAX_LENGTH)
					FC.description = copytext(description, 1, CHANNEL_DESC_MAX_LENGTH)
					FC.icon = usr.can_admin_interact() ? icon : "newspaper"
					FC.author = usr.can_admin_interact() ? author : scanned_user
					FC.is_public = public
					FC.admin_locked = usr.can_admin_interact() && admin_locked
					set_temp("Channel [FC.channel_name] created.", "good")
				if("create_story")
					var/author = trim(arguments["author"])
					var/channel = trim(arguments["channel"])
					var/title = trim(arguments["title"])
					var/body = trim(arguments["body"])
					var/admin_locked = text2num(arguments["admin_locked"])
					if(!length(author) || !length(title) || !length(body))
						return
					// Find the named channel the user is trying to publish a story to
					var/user_name = get_scanned_user(usr)
					var/datum/feed_channel/FC
					for(var/fc in GLOB.news_network.channels)
						var/datum/feed_channel/_FC = fc
						if(_FC.channel_name == channel)
							if(_FC.can_publish(usr, user_name))
								FC = _FC
							break
					if(!FC)
						return
					var/datum/feed_message/FM = new
					FM.author = usr.can_admin_interact() ? author : scanned_user
					FM.title = copytext(title, 1, STORY_NAME_MAX_LENGTH)
					FM.body = copytext(body, 1, STORY_BODY_MAX_LENGTH)
					FM.img = photo?.img
					FM.admin_locked = usr.can_admin_interact() && admin_locked
					// Register it
					FC.add_message(FM)
					feedback_inc("newscaster_stories", 1)
					var/announcement = FC.get_announce_text(title)
					// Announce it
					for(var/nc in GLOB.allNewscasters)
						var/obj/machinery/newscaster/NC = nc
						NC.alert_news(announcement)
					// Redirect and eject photo
					LAZYINITLIST(last_views[user_name])
					last_views[user_name][FC.UID()] = world.time
					screen = NEWSCASTER_CHANNEL
					viewing_channel = FC
					eject_photo(usr)
					set_temp("Story published to channel [FC.channel_name].", "good")
				if("wanted_notice")
					if(id == "wanted_notice" && !(is_security || usr.can_admin_interact()))
						return
					var/author = trim(arguments["author"])
					var/name = trim(arguments["name"])
					var/description = trim(arguments["description"])
					var/admin_locked = text2num(arguments["admin_locked"])
					if(!length(author) || !length(name) || !length(description))
						return
					var/datum/feed_message/WN = GLOB.news_network.wanted_issue
					if(WN)
						if(WN.admin_locked && !usr.can_admin_interact())
							set_temp("This wanted notice has been locked by CentComm and thus cannot be altered.", "danger")
							return
					else
						WN = new
						GLOB.news_network.wanted_issue = WN
					WN.author = usr.can_admin_interact() ? author : scanned_user
					WN.title = "WANTED: [copytext(name, 1, WANTED_NOTICE_NAME_MAX_LENGTH)]"
					WN.body = copytext(description, 1, WANTED_NOTICE_DESC_MAX_LENGTH)
					WN.img = photo?.img
					WN.admin_locked = usr.can_admin_interact() && admin_locked
					WN.publish_time = world.time
					// Announce it and eject photo
					for(var/nc in GLOB.allNewscasters)
						var/obj/machinery/newscaster/NC = nc
						NC.alert_news(wanted_notice = TRUE)
					eject_photo(usr)
					set_temp("Wanted notice distributed.", "good")
				else
					return FALSE
		else
			return FALSE

/**
  * Ejects the photo currently held by the machine if there is one.
  *
  * Arguments:
  * * user - The user to try to give the photo to.
  */
/obj/machinery/newscaster/proc/eject_photo(mob/user)
	if(!photo)
		return
	var/obj/item/photo/P = photo
	photo = null
	P.forceMove(loc)
	if(ishuman(user) && user.put_in_active_hand(P))
		visible_message("<span class='notice'>[src] ejects [P] from its photo slot into [user]'s hand.")
	else
		visible_message("<span class='notice'>[src] ejects [P] from its photo slot.")
	playsound(loc, 'sound/machines/terminal_insert_disc.ogg', 30, TRUE)
	SStgui.update_uis(src)

/**
  * Sets a temporary message to display to the user
  *
  * Arguments:
  * * text - Text to display, null/empty to clear the message from the UI
  * * style - The style of the message: (color name), info, success, warning, danger
  */
/obj/machinery/newscaster/proc/set_temp(text = "", style = "info", update_now = FALSE)
	temp_notice = list(text = text, style = style)
	if(update_now)
		SStgui.update_uis(src)

/obj/machinery/newscaster/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, "<span class='notice'>Now [anchored ? "un" : ""]securing [name]</span>")
	if(!I.use_tool(src, user, 60, volume = I.tool_volume))
		return
	playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
	if(stat & BROKEN)
		to_chat(user, "<span class='warning'>The broken remains of [src] fall on the ground.</span>")
		new /obj/item/stack/sheet/metal(loc, 5)
		new /obj/item/shard(loc)
		new /obj/item/shard(loc)
	else
		to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>")
		new /obj/item/mounted/frame/newscaster_frame(loc)
	qdel(src)

/obj/machinery/newscaster/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_welder_repair(user, I)

/obj/machinery/newscaster/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(stat & BROKEN)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 100, TRUE)
			else
				playsound(loc, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/newscaster/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 2)
		new /obj/item/shard(loc)
		new /obj/item/shard(loc)
	qdel(src)

/obj/machinery/newscaster/obj_break()
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT))
		stat |= BROKEN
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
		update_icon()

/obj/machinery/newscaster/proc/AttachPhoto(mob/user)
	if(photo)
		if(!issilicon(user))
			photo.forceMove(get_turf(src))
			user.put_in_inactive_hand(photo)
		photo = null
	if(istype(user.get_active_hand(), /obj/item/photo))
		photo = user.get_active_hand()
		user.drop_item()
		photo.forceMove(src)
	else if(issilicon(user))
		var/mob/living/silicon/tempAI = user
		var/obj/item/camera/siliconcam/camera = tempAI.aiCamera

		if(!camera)
			return
		var/datum/picture/selection = camera.selectpicture()
		if(!selection)
			return

		var/obj/item/photo/P = new/obj/item/photo()
		P.construct(selection)
		photo = P


//########################################################################################################################
//###################################### NEWSPAPER! ######################################################################
//########################################################################################################################

/obj/item/newspaper
	name = "newspaper"
	desc = "An issue of The Griffon, the newspaper circulating aboard Nanotrasen Space Stations."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "newspaper"
	w_class = WEIGHT_CLASS_SMALL	//Let's make it fit in trashbags!
	attack_verb = list("bapped")
	var/screen = 0
	var/pages = 0
	var/curr_page = 0
	var/list/datum/feed_channel/news_content = list()
	var/datum/feed_message/important_message = null
	var/scribble=""
	var/scribble_page = null

/obj/item/newspaper/attack_self(mob/user as mob)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/dat
		pages = 0
		switch(screen)
			if(0) //Cover
				dat+="<DIV ALIGN='center'><B><FONT SIZE=6>The Griffon</FONT></B></div>"
				dat+="<DIV ALIGN='center'><FONT SIZE=2>Nanotrasen-standard newspaper, for use on Nanotrasen Space Facilities</FONT></div><HR>"
				if(isemptylist(news_content))
					if(important_message)
						dat+="Contents:<BR><ul><B><FONT COLOR='red'>**</FONT>Important Security Announcement<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[page [pages+2]\]</FONT><BR></ul>"
					else
						dat+="<I>Other than the title, the rest of the newspaper is unprinted...</I>"
				else
					dat+="Contents:<BR><ul>"
					for(var/datum/feed_channel/NP in news_content)
						pages++
					if(important_message)
						dat+="<B><FONT COLOR='red'>**</FONT>Important Security Announcement<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[page [pages+2]\]</FONT><BR>"
					var/temp_page=0
					for(var/datum/feed_channel/NP in news_content)
						temp_page++
						dat+="<B>[NP.channel_name]</B> <FONT SIZE=2>\[page [temp_page+1]\]</FONT><BR>"
					dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:right;'><A href='?src=[UID()];next_page=1'>Next Page</A></DIV> <div style='float:left;'><A href='?src=[human_user.UID()];mach_close=newspaper_main'>Done reading</A></DIV>"
			if(1) // X channel pages inbetween.
				for(var/datum/feed_channel/NP in news_content)
					pages++ //Let's get it right again.
				var/datum/feed_channel/C = news_content[curr_page]
				dat+="<FONT SIZE=4><B>[C.channel_name]</B></FONT><FONT SIZE=1> \[created by: <FONT COLOR='maroon'>[C.author]</FONT>\]</FONT><BR><BR>"
				if(C.frozen)
					dat+="This channel was deemed dangerous to the general welfare of the station and therefore marked with a <B><FONT COLOR='red'>D-Notice</B></FONT>. Its contents were not transferred to the newspaper at the time of printing."
				else
					if(isemptylist(C.messages))
						dat+="No Feed stories stem from this channel..."
					else
						dat+="<ul>"
						var/i = 0
						for(var/datum/feed_message/MESSAGE in C.messages)
							i++
							dat+="<b>[MESSAGE.title]</b> <br>"
							dat+="[MESSAGE.body] <BR>"
							if(MESSAGE.img)
								user << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
								dat+="<img src='tmp_photo[i].png' width = '180'><BR>"
							dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR><BR>"
						dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[scribble]\"</I>"
				dat+= "<BR><HR><DIV STYLE='float:left;'><A href='?src=[UID()];prev_page=1'>Previous Page</A></DIV> <DIV STYLE='float:right;'><A href='?src=[UID()];next_page=1'>Next Page</A></DIV>"
			if(2) //Last page
				for(var/datum/feed_channel/NP in news_content)
					pages++
				if(important_message!=null)
					dat+="<DIV STYLE='float:center;'><FONT SIZE=4><B>Wanted Issue:</B></FONT SIZE></DIV><BR><BR>"
					dat+="<B>Criminal name</B>: <FONT COLOR='maroon'>[important_message.author]</FONT><BR>"
					dat+="<B>Description</B>: [important_message.body]<BR>"
					dat+="<B>Photo:</B>: "
					if(important_message.img)
						user << browse_rsc(important_message.img, "tmp_photow.png")
						dat+="<BR><img src='tmp_photow.png' width = '180'>"
					else
						dat+="None"
				else
					dat+="<I>Apart from some uninteresting Classified ads, there's nothing on this page...</I>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:left;'><A href='?src=[UID()];prev_page=1'>Previous Page</A></DIV>"
			else
				dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

		dat+="<BR><HR><div align='center'>[curr_page+1]</div>"
		human_user << browse(dat, "window=newspaper_main;size=300x400")
		onclose(human_user, "newspaper_main")
	else
		to_chat(user, "The paper is full of intelligible symbols!")


/obj/item/newspaper/Topic(href, href_list)
	var/mob/living/U = usr
	..()
	if((src in U.contents) || ( istype(loc, /turf) && in_range(src, U) ))
		U.set_machine(src)
		if(href_list["next_page"])
			if(curr_page==pages+1)
				return //Don't need that at all, but anyway.
			if(curr_page == pages) //We're at the middle, get to the end
				screen = 2
			else
				if(curr_page == 0) //We're at the start, get to the middle
					screen=1
			curr_page++
			playsound(loc, "pageturn", 50, 1)

		else if(href_list["prev_page"])
			if(curr_page == 0)
				return
			if(curr_page == 1)
				screen = 0

			else
				if(curr_page == pages+1) //we're at the end, let's go back to the middle.
					screen = 1
			curr_page--
			playsound(loc, "pageturn", 50, 1)

		if(istype(loc, /mob))
			attack_self(loc)


/obj/item/newspaper/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/pen))
		if(scribble_page == curr_page)
			to_chat(user, "<FONT COLOR='blue'>There's already a scribble in this page... You wouldn't want to make things too cluttered, would you?</FONT>")
		else
			var/s = strip_html( input(user, "Write something", "Newspaper", "") )
			s = sanitize(copytext(s, 1, MAX_MESSAGE_LEN))
			if(!s)
				return
			if(!in_range(src, usr) && loc != usr)
				return
			scribble_page = curr_page
			scribble = s
			attack_self(user)
		return
	return ..()

/obj/machinery/newscaster/proc/job_blacklisted(datum/job/job)
	return (job.type in jobblacklist)

/obj/machinery/newscaster/proc/get_scanned_user(mob/user)
	if(ishuman(user))                      							 //User is a human
		var/mob/living/carbon/human/human_user = user
		if(human_user.wear_id)                                      //Newscaster scans you
			if(istype(human_user.wear_id, /obj/item/pda))	//autorecognition, woo!
				var/obj/item/pda/P = human_user.wear_id
				if(P.id)
					return "[P.id.registered_name] ([P.id.assignment])"
			else if(istype(human_user.wear_id, /obj/item/card/id))
				var/obj/item/card/id/ID = human_user.wear_id
				return "[ID.registered_name] ([ID.assignment])"
	else if(issilicon(user))
		var/mob/living/silicon/ai_user = user
		return "[ai_user.name] ([ai_user.job])"
	return "Unknown"

/obj/machinery/newscaster/proc/has_security_access(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/M = user
		if(!M.wear_id)
			return FALSE
		var/obj/item/card/id/ID
		if(istype(M.wear_id, /obj/item/pda))
			var/obj/item/pda/P = M.wear_id
			ID = P.id
		else if(istype(M.wear_id, /obj/item/card/id))
			ID = M.wear_id
		if(!istype(ID))
			return FALSE
		return has_access(list(), list(ACCESS_SECURITY), ID.access)
	return issilicon(user) || user.can_admin_interact()

/obj/machinery/newscaster/proc/can_scan(mob/user)
	if(ishuman(user) || issilicon(user))
		return TRUE
	return FALSE

/obj/machinery/newscaster/proc/print_paper()
	feedback_inc("newscaster_newspapers_printed",1)
	var/obj/item/newspaper/NEWSPAPER = new /obj/item/newspaper
	for(var/datum/feed_channel/FC in GLOB.news_network.channels)
		NEWSPAPER.news_content += FC
	if(GLOB.news_network.wanted_issue)
		NEWSPAPER.important_message = GLOB.news_network.wanted_issue
	NEWSPAPER.loc = get_turf(src)
	paper_remaining--
	return

/**
  * Makes the newscaster say a message and change its icon state for a while.
  *
  * Arguments:
  * * announcement - The message to say
  * * wanted_notice - Whether the alert is a wanted notice notification (overrides announcement)
  */
/obj/machinery/newscaster/proc/alert_news(announcement, wanted_notice = FALSE)
	if(wanted_notice)
		atom_say("Attention! Wanted issue distributed!")
		playsound(loc, 'sound/machines/warning-buzzer.ogg', 75, TRUE)
	else if(length(announcement))
		atom_say("[announcement]!")
		if(!is_silent)
			playsound(loc, 'sound/machines/twobeep.ogg', 75, TRUE)
	else
		return
	alert = TRUE
	addtimer(CALLBACK(src, .proc/alert_timer_finish), 30 SECONDS)
	update_icon()

/**
  * Called when the timer following a news alert finishes.
  */
/obj/machinery/newscaster/proc/alert_timer_finish()
	alert = FALSE
	update_icon()

/obj/machinery/newscaster/verb/eject_photo_verb()
	set name = "Eject Photo"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return

	eject_photo(usr)

#undef CHANNEL_NAME_MAX_LENGTH
#undef CHANNEL_DESC_MAX_LENGTH
#undef STORY_NAME_MAX_LENGTH
#undef STORY_BODY_MAX_LENGTH
#undef WANTED_NOTICE_NAME_MAX_LENGTH
#undef WANTED_NOTICE_DESC_MAX_LENGTH
#undef STORIES_PER_LOAD
