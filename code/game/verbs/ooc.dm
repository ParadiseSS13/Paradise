#define DEFAULT_PLAYER_OOC_COLOUR "#075FE5" // Can't initial() a global so we store the default in a macro instead
#define BUG_REPORT_CD (5 MINUTES)
GLOBAL_VAR_INIT(normal_ooc_colour, DEFAULT_PLAYER_OOC_COLOUR)

GLOBAL_VAR_INIT(member_ooc_colour, "#035417")
GLOBAL_VAR_INIT(mentor_ooc_colour, "#00B0EB")
GLOBAL_VAR_INIT(moderator_ooc_colour, "#184880")
GLOBAL_VAR_INIT(admin_ooc_colour, "#b82e00")

/client/verb/ooc(msg = "" as text)
	set name = "OOC"
	set category = "OOC"

	if(!mob)
		return
	if(IsGuestKey(key))
		to_chat(src, "<span class='danger'>Guests may not use OOC.</span>", MESSAGE_TYPE_WARNING, confidential = TRUE)
		return

	if(!check_rights(R_ADMIN|R_MOD, 0))
		if(!GLOB.ooc_enabled)
			to_chat(src, "<span class='danger'>OOC is globally muted.</span>", MESSAGE_TYPE_WARNING, confidential = TRUE)
			return
		if(!GLOB.dooc_enabled && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>OOC for dead mobs has been turned off.</span>", MESSAGE_TYPE_WARNING, confidential = TRUE)
			return
		if(check_mute(ckey, MUTE_OOC))
			to_chat(src, "<span class='danger'>You cannot use OOC (muted).</span>", MESSAGE_TYPE_WARNING, confidential = TRUE)
			return

	if(!msg)
		msg = typing_input(src.mob, "", "ooc \"text\"")

	msg = trim(sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN)))
	if(!msg)
		return

	if(!(prefs.toggles & PREFTOGGLE_CHAT_OOC))
		to_chat(src, "<span class='danger'>You have OOC muted.</span>")
		return

	if(!check_rights(R_ADMIN|R_MOD,0))
		if(!GLOB.ooc_enabled)
			to_chat(src, "<span class='danger'>OOC is globally muted.</span>")
			return
		if(handle_spam_prevention(msg, MUTE_OOC, OOC_COOLDOWN))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	log_ooc(msg, src)
	mob.create_log(OOC_LOG, msg)

	var/display_colour = get_ooc_color()

	for(var/client/C in GLOB.clients)
		if(C.prefs.toggles & PREFTOGGLE_CHAT_OOC)
			var/display_name = key

			if(prefs.unlock_content)
				if(prefs.toggles & PREFTOGGLE_MEMBER_PUBLIC)
					var/icon/byond = icon('icons/member_content.dmi', "blag")
					display_name = "[bicon(byond)][display_name]"

			if(donator_level > 0)
				if(prefs.toggles & PREFTOGGLE_DONATOR_PUBLIC)
					var/icon/donator = icon('icons/ooc_tag_16x.png')
					display_name = "[bicon(donator)][display_name]"

			if(holder)
				if(holder.fakekey)
					if(C.holder && C.holder.rights & R_ADMIN)
						display_name = "[holder.fakekey]/([key])"
					else
						display_name = holder.fakekey

			if(GLOB.configuration.general.enable_ooc_emoji)
				msg = emoji_parse(msg)

			to_chat(C, "<font color='[display_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[display_name]:</EM> <span class='message'>[msg]</span></span></font>")

/client/proc/get_ooc_color()
	if(!holder || holder.fakekey)
		if(prefs.unlock_content && (prefs.toggles & PREFTOGGLE_MEMBER_PUBLIC))
			return GLOB.member_ooc_colour
		return GLOB.normal_ooc_colour
	if(!check_rights(R_ADMIN, FALSE))
		if(check_rights(R_MOD, FALSE))
			return GLOB.moderator_ooc_colour
		return GLOB.mentor_ooc_colour
	if(!GLOB.configuration.admin.allow_admin_ooc_colour)
		return GLOB.admin_ooc_colour
	return prefs.ooccolor

/proc/toggle_ooc()
	GLOB.ooc_enabled = (!GLOB.ooc_enabled)
	if(GLOB.ooc_enabled)
		to_chat(world, "<B>The OOC channel has been globally enabled!</B>")
	else
		to_chat(world, "<B>The OOC channel has been globally disabled!</B>")

/proc/auto_toggle_ooc(on)
	if(GLOB.configuration.general.auto_disable_ooc && GLOB.ooc_enabled != on)
		toggle_ooc()

/client/verb/looc(msg = "" as text)
	set name = "LOOC"
	set desc = "Local OOC, seen only by those in view."
	set category = "OOC"

	if(!mob)
		return
	if(IsGuestKey(key))
		to_chat(src, "<span class='danger'>Guests may not use LOOC.</span>", MESSAGE_TYPE_WARNING, confidential = TRUE)
		return

	if(!check_rights(R_ADMIN|R_MOD,0))
		if(!GLOB.looc_enabled)
			to_chat(src, "<span class='danger'>LOOC is globally muted.</span>", MESSAGE_TYPE_WARNING, confidential = TRUE)
			return
		if(!GLOB.dooc_enabled && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>LOOC for dead mobs has been turned off.</span>", MESSAGE_TYPE_WARNING, confidential = TRUE)
			return
		if(check_mute(ckey, MUTE_OOC))
			to_chat(src, "<span class='danger'>You cannot use LOOC (muted).</span>", MESSAGE_TYPE_WARNING, confidential = TRUE)
			return

	if(!msg)
		msg = typing_input(src.mob, "Local OOC, seen only by those in view.", "looc \"text\"")

	msg = trim(sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN)))
	if(!msg)
		return

	if(!(prefs.toggles & PREFTOGGLE_CHAT_LOOC))
		to_chat(src, "<span class='danger'>You have LOOC muted.</span>")
		return

	if(!check_rights(R_ADMIN|R_MOD,0))
		if(handle_spam_prevention(msg, MUTE_OOC, OOC_COOLDOWN))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in LOOC: [msg]")
			return

	log_looc(msg, src)
	mob.create_log(LOOC_LOG, msg)
	if(isliving(mob))
		for(var/mob/M in viewers(7, mob))
			if(M.client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT)
				M.create_chat_message(mob, msg, FALSE, symbol = RUNECHAT_SYMBOL_LOOC)
	var/mob/source = mob.get_looc_source()
	var/list/heard = get_mobs_in_view(7, source)

	var/display_name = key
	if(holder && holder.fakekey)
		display_name = holder.fakekey
	if(mob.stat != DEAD)
		display_name = mob.name

	for(var/client/target in GLOB.clients)
		if(target.prefs.toggles & PREFTOGGLE_CHAT_LOOC)
			var/prefix = ""
			var/admin_stuff = ""
			var/send = 0

			if(target in GLOB.admins)
				if(check_rights(R_ADMIN|R_MOD,0,target.mob))
					admin_stuff += "/([key])"
					if(target != src)
						admin_stuff += " ([admin_jump_link(mob)])"

			if(target.mob in heard)
				send = 1
				if(is_ai(target.mob))
					prefix = " (Core)"

			else if(is_ai(target.mob)) // Special case
				var/mob/living/silicon/ai/A = target.mob
				if(A.eyeobj in hearers(7, source))
					send = 1
					prefix = " (Eye)"

			if(!send && (target in GLOB.admins))
				if(check_rights(R_ADMIN|R_MOD,0,target.mob))
					send = 1
					prefix = "(R)"

			if(send)
				to_chat(target, "<span class='ooc'><span class='looc'>LOOC<span class='prefix'>[prefix]: </span><em>[display_name][admin_stuff]:</em> <span class='message'>[msg]</span></span></span>", MESSAGE_TYPE_OOC)


// Ported from /tg/, full credit to SpaceManiac and Timberpoes.
/client/verb/fit_viewport()
	set name = "Fit Viewport"
	set desc = "Fit the size of the map window to match the viewport."
	set category = "Special Verbs"

	// Fetch aspect ratio
	var/list/view_size = getviewsize(view)
	var/aspect_ratio = view_size[1] / view_size[2]

	// Calculate desired pixel width using window size and aspect ratio
	var/list/sizes = params2list(winget(src, "mainwindow.mainvsplit;paramapwindow", "size"))

	// Client closed the window? Some other error? This is unexpected behaviour, let's CRASH with some info.
	if(!sizes["paramapwindow.size"])
		CRASH("sizes does not contain paramapwindow.size key. This means a winget() failed to return what we wanted. --- sizes var: [sizes] --- list contents:[list2params(sizes)] --- sizes length: [length(sizes)]")

	var/list/map_size = splittext(sizes["paramapwindow.size"], "x")

	// Gets the type of zoom we're currently using
	// If it's 0 we do our pixel calculations based off the size of the mapwindow
	// If it's not, we already know how big we want our window to be, since zoom is the exact pixel ratio of the map
	var/icon_size = params2list(winget(src, "mainwindow.mainvsplit;paramapwindow;map", "icon-size")) || 0
	var/zoom_value = text2num(icon_size["map.icon-size"]) / 32

	var/desired_width = 0
	if(zoom_value)
		desired_width = round(view_size[1] * zoom_value * world.icon_size)
	else

		// Looks like we didn't expect paramapwindow.size to be "ixj" where i and j are numbers.
		// If we don't get our expected 2 outputs, let's give some useful error info.
		if(length(map_size) != 2)
			CRASH("map_size of incorrect length --- map_size var: [map_size] --- map_size length: [length(map_size)]")

		var/height = text2num(map_size[2])
		desired_width = round(height * aspect_ratio)

	if(text2num(map_size[1]) == desired_width)
		// Nothing to do.
		return

	var/list/split_size = splittext(sizes["mainwindow.mainvsplit.size"], "x")
	var/split_width = text2num(split_size[1])

	// Avoid auto-resizing the statpanel and chat into nothing.
	desired_width = min(desired_width, split_width - 300)

	// Calculate and apply a best estimate
	// +4 pixels are for the width of the splitter's handle
	var/pct = 100 * (desired_width + 4) / split_width
	winset(src, "mainwindow.mainvsplit", "splitter=[pct]")

	// Apply an ever-lowering offset until we finish or fail
	var/delta
	for(var/safety in 1 to 10)
		var/after_size = winget(src, "paramapwindow", "size")
		map_size = splittext(after_size, "x")
		var/produced_width = text2num(map_size[1])

		if(produced_width == desired_width)
			// Success!
			return
		else if(isnull(delta))
			// Calculate a probably delta based on the difference
			delta = 100 * (desired_width - produced_width) / split_width
		else if((delta > 0 && produced_width > desired_width) || (delta < 0 && produced_width < desired_width))
			// If we overshot, halve the delta and reverse direction
			delta = -delta / 2

	pct += delta
	winset(src, "mainwindow.mainvsplit", "splitter=[pct]")


/mob/proc/get_looc_source()
	return src

/mob/living/silicon/ai/get_looc_source()
	if(eyeobj)
		return eyeobj
	return src

/client/verb/fix_stat_panel()
	set name = "Fix Stat Panel"
	set hidden = TRUE

	init_verbs()

/client/verb/show_own_notes()
	set name = "Show My Notes"
	set desc = "View your public notes."
	set category = "OOC"

	if(!key)
		return
	if(!SSdbcore.IsConnected())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/list/output = list("<!DOCTYPE html>")
	var/datum/db_query/query_get_notes = SSdbcore.NewQuery({"
		SELECT timestamp, notetext, adminckey, last_editor, server, crew_playtime, round_id
		FROM notes WHERE ckey=:targetkey AND deleted=0 AND public=1 ORDER BY timestamp"}, list(
			"targetkey" = ckey
		))
	if(!query_get_notes.warn_execute())
		to_chat(src, "<span class='danger'>Unfortunately, we were not able to retrieve your notes.</span>")
		qdel(query_get_notes)
		return
	output += "<h2><center>Notes of [ckey]</center></h2><br><center><font size='1'>Don't discuss warnings or other punishments from the admins in Paradise Discord.</font></center>"
	output += "<hr style='background:#000000; border:0; height:3px'>"
	var/found_notes = FALSE
	while(query_get_notes.NextRow())
		found_notes = TRUE
		var/timestamp = query_get_notes.item[1]
		var/notetext = query_get_notes.item[2]
		var/adminckey = query_get_notes.item[3]
		var/last_editor = query_get_notes.item[4]
		var/server = query_get_notes.item[5]
		var/mins = text2num(query_get_notes.item[6])
		var/round_id = text2num(query_get_notes.item[7])
		output += "<b>[timestamp][round_id ? " (Round [round_id])" : ""] | [server] | [adminckey]"
		if(mins)
			var/playstring = get_exp_format(mins)
			output += " | [playstring] as Crew"
		output += "</b>"

		if(last_editor)
			output += " <font size='1'>Last edit by [last_editor].</font>"
		output += "<br>[replacetext(notetext, "\n", "<br>")]<hr style='background:#000000; border:0; height:1px'>"
	if(!found_notes)
		output += "<b>You have no public notes.</b>"
	qdel(query_get_notes)
	var/datum/browser/popup = new(mob, "show_public_notes", "Public Notes", 900, 500)
	popup.set_content(output.Join(""))
	popup.open()

/client/verb/submitbug()
	set name = "Report a Bug"
	set desc = "Submit a bug report."
	set category = "OOC"
	set hidden = TRUE
	if(!usr?.client)
		return

	if(GLOB.bug_report_time[usr.ckey] && world.time < (GLOB.bug_report_time[usr.client] + BUG_REPORT_CD))
		var/cd_total_time = GLOB.bug_report_time[usr.ckey] + BUG_REPORT_CD - world.time
		var/cd_minutes = round(cd_total_time / (1 MINUTES))
		var/cd_seconds = round((cd_total_time - cd_minutes MINUTES) / (1 SECONDS))
		tgui_alert(usr, "You must wait another [cd_minutes]:[cd_seconds < 10 ? "0" : ""][cd_seconds] minute[cd_minutes < 2 ? "" : "s"] before submitting another bug report", "Bug Report Rate Limit")
		return

	var/datum/tgui_bug_report_form/report = new(usr)

	report.ui_interact(usr)
	return

#undef DEFAULT_PLAYER_OOC_COLOUR
#undef BUG_REPORT_CD
