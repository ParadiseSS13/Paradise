//##############################################
//################### NEWSCASTERS BE HERE! ####
//###-Agouri###################################

/datum/feed_message
	var/author = ""
	var/title = ""
	var/body = ""
	var/message_type = "Story"
	var/backup_body = ""
	var/backup_author = ""
	var/is_admin_message = 0
	var/icon/img = null
	var/icon/backup_img
	var/view_count = 0

/datum/feed_channel
	var/channel_name = ""
	var/list/datum/feed_message/messages = list()
	var/locked = 0
	var/author = ""
	var/backup_author = ""
	var/censored = 0
	var/is_admin_channel = 0
	var/total_view_count = 0

/datum/feed_message/proc/clear()
	author = ""
	body = ""
	backup_body = ""
	backup_author = ""
	img = null
	backup_img = null
	view_count = 0

/datum/feed_channel/proc/clear()
	channel_name = ""
	messages = list()
	locked = 0
	author = ""
	backup_author = ""
	censored = 0
	is_admin_channel = 0
	total_view_count = 0

/datum/feed_channel/proc/announce_news(title="")
	if(title)
		return "Breaking news from [channel_name]: [title]"
	return "Breaking news from [channel_name]"

/datum/feed_channel/station/announce_news()
	return "New Station Announcement Available"

/datum/feed_network
	var/list/datum/feed_channel/network_channels = list()
	var/datum/feed_message/wanted_issue

GLOBAL_DATUM_INIT(news_network, /datum/feed_network, new())     //The global news-network, which is coincidentally a global list.

GLOBAL_LIST_EMPTY(allNewscasters) //Global list that will contain reference to all newscasters in existence.

#define NEWSCASTER_MAIN			0	// Main menu
#define NEWSCASTER_FC_LIST		1	// Feed channel list
#define NEWSCASTER_CREATE_FC	2	// Create feed channel
#define NEWSCASTER_CREATE_FM	3	// Create feed message
#define NEWSCASTER_PRINT		4	// Print newspaper
#define NEWSCASTER_VIEW_FC		5	// Read feed channel
#define NEWSCASTER_NT_CENSOR	6	// Nanotrasen Feed Censorship Tool
#define NEWSCASTER_D_NOTICE		7	// Nanotrasen D-Notice Handler
#define NEWSCASTER_CENSOR_FC	8	// Censor feed channel
#define NEWSCASTER_D_NOTICE_FC	9	// D-Notice feed channel
#define NEWSCASTER_W_ISSUE_H	10	// Wanted Issue handler
#define NEWSCASTER_W_ISSUE		11	// STATIONWIDE WANTED ISSUE
#define NEWSCASTER_JOBS			12	// Available jobs

/obj/machinery/newscaster
	name = "newscaster"
	desc = "A standard Nanotrasen-licensed newsfeed handler for use in commercial space stations. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_normal"
	armor = list(melee = 50, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 30)
	max_integrity = 200
	integrity_failure = 50
	var/screen = NEWSCASTER_MAIN
	var/paper_remaining = 15
	var/securityCaster = 0
		// 0 = Caster cannot be used to issue wanted posters
		// 1 = the opposite
	var/unit_no = 0 //Each newscaster has a unit number
	var/alert_delay = 500
	var/alert = 0
		// 0 = there hasn't been a news/wanted update in the last alert_delay
		// 1 = there has
	var/scanned_user = "Unknown" //Will contain the name of the person who currently uses the newscaster
	var/msg = "" //Feed message
	var/msg_title = "" // Feed message title
	var/obj/item/photo/photo = null
	var/channel_name = "" //the feed channel which will be receiving the feed, or being created
	var/c_locked = 0 //Will our new channel be locked to public submissions?
	var/datum/feed_channel/viewing_channel = null
	var/silence = 0
	var/temp = null
	var/temp_back_screen = NEWSCASTER_MAIN
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

	var/static/REDACTED = "<b class='bad'>\[REDACTED\]</b>"
	light_range = 0
	anchored = 1


/obj/machinery/newscaster/security_unit
	name = "Security Newscaster"
	securityCaster = 1

/obj/machinery/newscaster/New()
	GLOB.allNewscasters += src
	unit_no = GLOB.allNewscasters.len
	update_icon() //for any custom ones on the map...
	..()

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
	var/hp_percent = obj_integrity * 100 /max_integrity
	switch(hp_percent)
		if(75 to 100)
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

/obj/machinery/newscaster/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	update_icon()

/obj/machinery/newscaster/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/newscaster/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/newscaster/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)
	if(can_scan(user))
		scan_user(user)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "newscaster.tmpl", name, 400, 600)
		ui.open()

/obj/machinery/newscaster/ui_data(user)
	var/list/data = list()

	data["unit_no"] = unit_no
	data["temp"] = temp
	data["temp_back_screen"] = temp_back_screen
	data["screen"] = screen

	switch(screen)
		if(0)
			data["wanted_issue"] = GLOB.news_network.wanted_issue ? 1 : 0
			data["silence"] = silence
			data["securityCaster"] = securityCaster
			if(securityCaster)
				data["scanned_user"] = scanned_user
		if(1, 6, 7)
			var/list/channels = list()
			data["channels"] = channels
			for(var/datum/feed_channel/C in GLOB.news_network.network_channels)
				channels[++channels.len] = list("name" = C.channel_name, "ref" = "\ref[C]", "censored" = C.censored, "admin" = C.is_admin_channel)
		if(2)
			data["scanned_user"] = scanned_user
			data["channel_name"] = channel_name
			data["c_locked"] = c_locked
		if(3)
			data["scanned_user"] = scanned_user
			data["channel_name"] = channel_name
			data["title"] = msg_title
			data["msg"] = msg
			data["photo"] = photo ? 1 : 0
		if(4)
			var/total_num = length(GLOB.news_network.network_channels)
			var/active_num = total_num
			var/message_num=0
			for(var/datum/feed_channel/FC in GLOB.news_network.network_channels)
				if(!FC.censored)
					message_num += length(FC.messages)
				else
					active_num--
			data["total_num"] = total_num
			data["active_num"] = active_num
			data["message_num"] = message_num
			data["paper_remaining"] = paper_remaining * 100
		if(5)
			data["channel_name"] = viewing_channel.channel_name
			data["author"] = viewing_channel.author
			data["total_view_count"] = viewing_channel.total_view_count
			data["censored"] = viewing_channel.censored
			var/list/messages = list()
			data["messages"] = messages
			var/message_number = 0
			for(var/datum/feed_message/M in viewing_channel.messages)
				if(M.img)
					user << browse_rsc(M.img, "tmp_photo[message_number].png")
				messages[++messages.len] = list("title" = M.title, "body" = M.body, "img" = M.img ? M.img : null, "message_type" = M.message_type, "author" = M.author, "view_count" = M.view_count, "message_number" = message_number)
				message_number += 1
		if(8, 9)
			data["channel_name"] = viewing_channel.channel_name
			data["ref"] = "\ref[viewing_channel]"
			data["author"] = viewing_channel.author
			data["author_redacted"] = viewing_channel.author == REDACTED ? 1 : 0
			data["total_view_count"] = viewing_channel.total_view_count
			data["censored"] = viewing_channel.censored
			var/list/messages = list()
			data["messages"] = messages
			for(var/datum/feed_message/M in viewing_channel.messages)
				messages[++messages.len] = list("title" = M.title, "body" = M.body, "body_redacted" = (M.body == REDACTED ? 1 : 0) , "message_type" = M.message_type, "author" = M.author, "author_redacted" = (M.author == REDACTED ? 1 : 0), "ref" = "\ref[M]", "view_count" = M.view_count)
		if(10)
			var/wanted_already = 0
			var/end_param = 1
			if(GLOB.news_network.wanted_issue)
				wanted_already = 1
				end_param = 2
			data["wanted_already"] = wanted_already
			data["end_param"] = end_param
			data["channel_name"] = channel_name
			data["msg"] = msg
			data["photo"] = photo ? 1 : 0
			if(wanted_already)
				data["author"] = GLOB.news_network.wanted_issue.backup_author
			else
				data["scanned_user"] = scanned_user
		if(11)
			data["author"] = GLOB.news_network.wanted_issue.backup_author
			data["criminal"] = GLOB.news_network.wanted_issue.author
			data["description"] = GLOB.news_network.wanted_issue.body
			if(GLOB.news_network.wanted_issue.img)
				user << browse_rsc(GLOB.news_network.wanted_issue.img, "tmp_photow.png")
			data["photo"] = GLOB.news_network.wanted_issue.img ? GLOB.news_network.wanted_issue.img : 0
		if(12)
			var/list/jobs = list()
			data["jobs"] = jobs
			for(var/datum/job/job in SSjobs.occupations)
				if(job_blacklisted(job))
					continue
				if(job.is_position_available())
					jobs[++jobs.len] = list("title" = job.title)
	return data

/obj/machinery/newscaster/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["set_channel_name"])
		channel_name = trim(sanitize(strip_html_simple(input(usr, "Provide a Feed Channel Name", "Network Channel Handler", ""))))

	else if(href_list["set_channel_lock"])
		c_locked = !c_locked

	else if(href_list["submit_new_channel"])
		var/list/existing_authors = list()
		for(var/datum/feed_channel/FC in GLOB.news_network.network_channels)
			if(FC.author == REDACTED)
				existing_authors += FC.backup_author
			else
				existing_authors += FC.author
		var/check = 0
		for(var/datum/feed_channel/FC in GLOB.news_network.network_channels)
			if(FC.channel_name == channel_name)
				check = 1
				break
		var/choice = alert("Please confirm feed channel creation", "Network Channel Handler", "Confirm", "Cancel")
		if(choice == "Confirm")
			if(channel_name == "" || channel_name == REDACTED || scanned_user == "Unknown" || check || (scanned_user in existing_authors))
				temp = "<b class='bad'>ERROR: Could not submit feed channel to Network.</b><ul class='bad'>"
				if(scanned_user in existing_authors)
					temp += "<li>There already exists a feed channel under your name.</li>"
				if(channel_name == "" || channel_name == REDACTED)
					temp += "<li>Invalid channel name.</li>"
				if(check)
					temp += "<li>Channel name already in use.</li>"
				if(scanned_user == "Unknown")
					temp += "<li>Channel author unverified.</li>"
				temp += "</ul>"
				temp_back_screen = NEWSCASTER_CREATE_FC
			else
				var/datum/feed_channel/newChannel = new /datum/feed_channel
				newChannel.channel_name = channel_name
				newChannel.author = scanned_user
				newChannel.locked = c_locked
				feedback_inc("newscaster_channels", 1)
				GLOB.news_network.network_channels += newChannel //Adding channel to the global network
				temp = "<span class='good'>Feed channel '[channel_name]' created successfully.</span>"
				temp_back_screen = NEWSCASTER_MAIN

	else if(href_list["set_channel_receiving"])
		var/list/available_channels = list()
		for(var/datum/feed_channel/F in GLOB.news_network.network_channels)
			if((!F.locked || F.author == scanned_user) && !F.censored)
				available_channels += F.channel_name
		channel_name = strip_html_simple(input(usr, "Choose receiving Feed Channel", "Network Channel Handler") in available_channels)

	else if(href_list["set_message_title"])
		msg_title = trim(strip_html(input(usr, "Write a title for your feed story", "Network Channel Handler", "")))
		msg_title = dd_limittext(msg_title, 256)

	else if(href_list["set_new_message"])
		msg = trim(strip_html(input(usr, "Write your feed story", "Network Channel Handler", "")))

	else if(href_list["set_attachment"])
		AttachPhoto(usr)

	else if(href_list["submit_new_message"])
		if(msg == "" || msg == REDACTED || scanned_user == "Unknown" || channel_name == "" )
			temp = "<b class='bad'>ERROR: Could not submit feed story to Network.</b><ul class='bad'>"
			if(channel_name == "")
				temp += "<li>Invalid receiving channel name.</li>"
			if(scanned_user == "Unknown")
				temp += "<li>Channel author unverified.</li>"
			if(msg == "" || msg == REDACTED)
				temp += "<li>Invalid message body.</li>"
			temp += "</ul>"
			temp_back_screen = NEWSCASTER_CREATE_FM
		else
			var/datum/feed_message/newMsg = new /datum/feed_message
			newMsg.author = scanned_user
			newMsg.title = msg_title
			newMsg.body = msg
			if(photo)
				newMsg.img = photo.img
			feedback_inc("newscaster_stories",1)
			var/announcement = ""
			for(var/datum/feed_channel/FC in GLOB.news_network.network_channels)
				if(FC.channel_name == channel_name)
					FC.messages += newMsg                  //Adding message to the network's appropriate feed_channel
					announcement = FC.announce_news(msg_title)
					break
			temp = "<span class='good'>Feed story successfully submitted to [channel_name].</span>"
			temp_back_screen = NEWSCASTER_MAIN
			for(var/obj/machinery/newscaster/NC in GLOB.allNewscasters)
				NC.newsAlert(announcement)

	else if(href_list["create_channel"])
		screen = NEWSCASTER_CREATE_FC

	else if(href_list["create_feed_story"])
		screen = NEWSCASTER_CREATE_FM

	else if(href_list["menu_paper"])
		screen = NEWSCASTER_PRINT

	else if(href_list["print_paper"])
		if(!paper_remaining)
			temp = "<span class='bad'>Unable to print newspaper. Insufficient paper. Please notify maintenance personnell to refill machine storage.</span>"
			temp_back_screen = NEWSCASTER_MAIN
		else
			print_paper()
			temp = "<span class='good'>Printing successful. Please receive your newspaper from the bottom of the machine.</span>"
			temp_back_screen = NEWSCASTER_MAIN

	else if(href_list["silence_unit"])
		silence = !silence

	else if(href_list["menu_censor_story"])
		screen = NEWSCASTER_NT_CENSOR

	else if(href_list["menu_censor_channel"])
		screen = NEWSCASTER_D_NOTICE

	else if(href_list["menu_wanted"])
		var/already_wanted = 0
		if(GLOB.news_network.wanted_issue)
			already_wanted = 1

		if(already_wanted)
			channel_name = GLOB.news_network.wanted_issue.author
			msg = GLOB.news_network.wanted_issue.body
		screen = NEWSCASTER_W_ISSUE_H

	else if(href_list["set_wanted_name"])
		channel_name = trim(strip_html(input(usr, "Provide the name of the wanted person", "Network Security Handler", "")))

	else if(href_list["set_wanted_desc"])
		msg = trim(strip_html(input(usr, "Provide the a description of the wanted person and any other details you deem important", "Network Security Handler", "")))

	else if(href_list["submit_wanted"])
		var/input_param = text2num(href_list["submit_wanted"])
		var/choice = alert("Please confirm wanted issue [input_param == 1 ? "creation." : "edit."]", "Network Security Handler", "Confirm", "Cancel")
		if(choice == "Confirm")
			if(msg == "" || channel_name == "" || scanned_user == "Unknown")
				temp = "<b class='bad'>ERROR: Wanted issue rejected by Network.</b><ul class='bad'>"
				if(channel_name == "" || channel_name == REDACTED)
					temp += "<li>Invalid name for person wanted.</li>"
				if(scanned_user == "Unknown")
					temp += "<li>Channel author unverified.</li>"
				if(msg == "" || msg == REDACTED)
					temp += "<li>Invalid description.</li>"
				temp += "</ul>"
				temp_back_screen = NEWSCASTER_MAIN
			else
				if(input_param == 1) //input_param == 1: new wanted issue, input_param == 2: editing an existing one
					var/datum/feed_message/W = new /datum/feed_message
					W.author = channel_name
					W.body = msg
					W.backup_author = scanned_user //I know, a bit wacky
					if(photo)
						W.img = photo.img
					GLOB.news_network.wanted_issue = W
					for(var/obj/machinery/newscaster/NS in GLOB.allNewscasters)
						NS.newsAlert()
						NS.update_icon()
					temp = "<span class='good'>Wanted issue for [channel_name] is now in Network Circulation.</span>"
					temp_back_screen = NEWSCASTER_MAIN
				else
					if(GLOB.news_network.wanted_issue.is_admin_message)
						alert("The wanted issue has been distributed by a Nanotrasen higherup. You cannot edit it.","Ok")
						return
					GLOB.news_network.wanted_issue.author = channel_name
					GLOB.news_network.wanted_issue.body = msg
					GLOB.news_network.wanted_issue.backup_author = scanned_user
					if(photo)
						GLOB.news_network.wanted_issue.img = photo.img
					temp = "<span class='good'>Wanted issue for [channel_name] successfully edited.</span>"
					temp_back_screen = NEWSCASTER_MAIN

	else if(href_list["cancel_wanted"])
		if(GLOB.news_network.wanted_issue.is_admin_message)
			alert("The wanted issue has been distributed by a Nanotrasen higherup. You cannot take it down.", "Ok")
			return
		var/choice = alert("Please confirm wanted issue removal", "Network Security Handler", "Confirm", "Cancel")
		if(choice == "Confirm")
			GLOB.news_network.wanted_issue = null
			for(var/obj/machinery/newscaster/NC in GLOB.allNewscasters)
				NC.update_icon()
			temp = "<b class='good'>Wanted Issue successfully deleted from Circulation</b>"
			temp_back_screen = NEWSCASTER_MAIN

	else if(href_list["view_wanted"])
		screen = NEWSCASTER_W_ISSUE
	else if(href_list["censor_channel_author"])
		var/datum/feed_channel/FC = locate(href_list["censor_channel_author"])
		if(FC)
			if(FC.is_admin_channel)
				alert("This channel was created by a Nanotrasen Officer. You cannot censor it.","Ok")
				return
			if(FC.author != REDACTED)
				FC.backup_author = FC.author
				FC.author = REDACTED
			else
				FC.author = FC.backup_author

	else if(href_list["censor_channel_story_author"])
		var/datum/feed_message/M = locate(href_list["censor_channel_story_author"])
		if(M)
			if(M.is_admin_message)
				alert("This message was created by a Nanotrasen Officer. You cannot censor its author.","Ok")
				return
			if(M.author != REDACTED)
				M.backup_author = M.author
				M.author = REDACTED
			else
				M.author = M.backup_author

	else if(href_list["censor_channel_story_body"])
		var/datum/feed_message/M = locate(href_list["censor_channel_story_body"])
		if(M)
			if(M.is_admin_message)
				alert("This channel was created by a Nanotrasen Officer. You cannot censor it.","Ok")
				return
			if(M.img != null)
				M.backup_img = M.img
				M.img = null
			else
				M.img = M.backup_img
			if(M.body != REDACTED)
				M.backup_body = M.body
				M.body = REDACTED
			else
				M.body = M.backup_body

	else if(href_list["pick_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["pick_d_notice"])
		if(FC)
			viewing_channel = FC
			screen = NEWSCASTER_D_NOTICE_FC

	else if(href_list["toggle_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["toggle_d_notice"])
		if(FC)
			if(FC.is_admin_channel)
				alert("This channel was created by a Nanotrasen Officer. You cannot place a D-Notice upon it.", "Ok")
				return
			FC.censored = !FC.censored

	else if(href_list["view"])
		screen = NEWSCASTER_FC_LIST

	else if(href_list["setScreen"]) //Brings us to the main menu and resets all fields~
		screen = text2num(href_list["setScreen"])
		if(screen == NEWSCASTER_MAIN)
			scanned_user = "Unknown"
			msg = ""
			msg_title = ""
			c_locked = 0
			channel_name = ""
			viewing_channel = null
		temp = null
		temp_back_screen = NEWSCASTER_MAIN

	else if(href_list["show_channel"])
		var/datum/feed_channel/FC = locate(href_list["show_channel"])
		if(FC)
			viewing_channel = FC
			viewing_channel.total_view_count++
			for(var/datum/feed_message/M in viewing_channel.messages)
				M.view_count++
			screen = NEWSCASTER_VIEW_FC

	else if(href_list["pick_censor_channel"])
		var/datum/feed_channel/FC = locate(href_list["pick_censor_channel"])
		if(FC)
			viewing_channel = FC
			screen = NEWSCASTER_CENSOR_FC

	else if(href_list["refresh"])
		if(can_scan(usr))
			scan_user(usr) //Newscaster scans you

	else if(href_list["jobs"])
		screen = NEWSCASTER_JOBS

	SSnanoui.update_uis(src)
	return 1

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
				if(C.censored)
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


////////////////////////////////////helper procs

/obj/machinery/newscaster/proc/job_blacklisted(datum/job/job)
	return (job.type in jobblacklist)

/obj/machinery/newscaster/proc/scan_user(mob/user)
	if(ishuman(user))                      							 //User is a human
		var/mob/living/carbon/human/human_user = user
		if(human_user.wear_id)                                      //Newscaster scans you
			if(istype(human_user.wear_id, /obj/item/pda))	//autorecognition, woo!
				var/obj/item/pda/P = human_user.wear_id
				if(P.id)
					scanned_user = "[P.id.registered_name] ([P.id.assignment])"
				else
					scanned_user = "Unknown"
			else if(istype(human_user.wear_id, /obj/item/card/id))
				var/obj/item/card/id/ID = human_user.wear_id
				scanned_user = "[ID.registered_name] ([ID.assignment])"
			else
				scanned_user = "Unknown"
		else
			scanned_user = "Unknown"
	else if(issilicon(user))
		var/mob/living/silicon/ai_user = user
		scanned_user = "[ai_user.name] ([ai_user.job])"
	else
		scanned_user = "Unknown"

/obj/machinery/newscaster/proc/can_scan(mob/user)
	if(ishuman(user) || issilicon(user))
		return TRUE
	return FALSE

/obj/machinery/newscaster/proc/print_paper()
	feedback_inc("newscaster_newspapers_printed",1)
	var/obj/item/newspaper/NEWSPAPER = new /obj/item/newspaper
	for(var/datum/feed_channel/FC in GLOB.news_network.network_channels)
		NEWSPAPER.news_content += FC
	if(GLOB.news_network.wanted_issue)
		NEWSPAPER.important_message = GLOB.news_network.wanted_issue
	NEWSPAPER.loc = get_turf(src)
	paper_remaining--
	return

//Removed for now so these aren't even checked every tick. Left this here in-case Agouri needs it later.
///obj/machinery/newscaster/process()       //Was thinking of doing the icon update through process, but multiple iterations per second does not
//	return                                  //bode well with a newscaster network of 10+ machines. Let's just return it, as it's added in the machines list.

/obj/machinery/newscaster/proc/newsAlert(var/news_call)   //This isn't Agouri's work, for it is ugly and vile.
	if(news_call)

		atom_say("[news_call]!")
		alert = 1
		update_icon()
		spawn(300)
			alert = 0
			update_icon()
		if(!silence)
			playsound(loc, 'sound/machines/twobeep.ogg', 75, 1)
	else
		atom_say("Attention! Wanted issue distributed!")
		playsound(loc, 'sound/machines/warning-buzzer.ogg', 75, 1)
	return
