#define UPDATE_CKEY_MOB(__ckey) var/mob/result = selected_ckeys_mobs[__ckey];\
if(!result || result.ckey != __ckey){\
	result = get_mob_by_ckey(__ckey);\
	selected_ckeys_mobs[__ckey] = result;\
}

#define RECORD_WARN_LIMIT 1000
#define RECORD_HARD_LIMIT 2500

/datum/log_viewer
	var/time_from = 0
	var/time_to = 4 HOURS					// 4 Hours should be enough. INFINITY would screw the UI up
	var/list/selected_mobs = list()			// The mobs in question.
	var/list/selected_ckeys = list()		// The ckeys selected to search for. Will show all mobs the ckey is attached to
	var/list/mob/selected_ckeys_mobs = list()
	var/list/selected_log_types = ALL_LOGS	// The log types being searched for
	var/list/log_records = list()			// Found and sorted records

/datum/log_viewer/proc/clear_all()
	selected_mobs.Cut()
	selected_log_types = ALL_LOGS
	selected_ckeys.Cut()
	selected_ckeys_mobs.Cut()
	time_from = initial(time_from)
	time_to = initial(time_to)
	log_records.Cut()
	return

/datum/log_viewer/proc/search(user)
	log_records.Cut() // Empty the old results
	var/list/invalid_mobs = list()
	var/list/ckeys = selected_ckeys.Copy()
	for(var/i in selected_mobs)
		var/mob/M = i
		if(!M || QDELETED(M) || !M.last_known_ckey)
			invalid_mobs |= M
			continue
		ckeys |= M.last_known_ckey

	for(var/ckey in ckeys)
		for(var/log_type in selected_log_types)
			var/list/logs = GLOB.logging.get_logs_by_type(ckey, log_type)
			var/len_logs = length(logs)
			if(len_logs)
				var/start_index = get_earliest_log_index(logs)
				if(!start_index) // No log found that matches the starting time criteria
					continue
				var/end_index = get_latest_log_index(logs)
				if(!end_index) // No log found that matches the end time criteria
					continue
				log_records.Add(logs.Copy(start_index, end_index + 1))

	if(length(invalid_mobs))
		to_chat(user, "<span class='warning'>The search criteria contained invalid mobs. They have been removed from the criteria.</span>")
		for(var/i in invalid_mobs)
			selected_mobs -= i // Cleanup

	log_records = sortTim(log_records, GLOBAL_PROC_REF(compare_log_record))

/** Binary search like implementation to find the earliest log
 * Returns the index of the earliest log using the time_from value for the given list of logs.
 * It will return 0 if no log after time_from is found
*/
/datum/log_viewer/proc/get_earliest_log_index(list/logs)
	if(!time_from)
		return 1
	var/start = 1
	var/end = length(logs)
	var/mid
	do
		mid = round_down((end + start) / 2)
		var/datum/log_record/L = logs[mid]
		if(L.raw_time >= time_from)
			end = mid
		else
			start = mid
	while(end - start > 1)
	var/datum/log_record/L = logs[end]
	if(L.raw_time >= time_from) // Check if there is atleast one valid log
		return end
	return 0

/** Binary search like implementation to find the latest log
 * Returns the index of the latest log using the time_to value (1 second is added to prevent rounding weirdness) for the given list of logs.
 * It will return 0 if no log before time_to + 10 is found
*/
/datum/log_viewer/proc/get_latest_log_index(list/logs)
	if(world.time < time_to)
		return length(logs)

	var/end = length(logs)
	var/start = 1
	var/mid
	var/max_time = time_to + 10
	do
		mid = round((end + start) / 2 + 0.5)
		var/datum/log_record/L = logs[mid]
		if(L.raw_time >= max_time)
			end = mid
		else
			start = mid
	while(end - start > 1)
	var/datum/log_record/L = logs[start]
	if(L.raw_time < max_time) // Check if there is atleast one valid log
		return start
	return 0

/datum/log_viewer/proc/add_mobs(list/mob/mobs)
	if(!length(mobs))
		return
	for(var/i in mobs)
		add_mob(usr, i, FALSE)

/datum/log_viewer/proc/add_ckey(mob/user, ckey)
	if(!user || !ckey)
		return
	selected_ckeys |= ckey
	UPDATE_CKEY_MOB(ckey)
	show_ui(user)

/datum/log_viewer/proc/add_mob(mob/user, mob/M, show_the_ui = TRUE)
	if(!M || !user)
		return

	selected_mobs |= M

	show_ui(user)

/datum/log_viewer/proc/show_ui(mob/user)
	var/all_log_types	= ALL_LOGS
	var/trStyleTop		= "border-top:2px solid; border-bottom:2px solid; padding-top: 5px; padding-bottom: 5px;"
	var/trStyle			= "border-top:1px solid; border-bottom:1px solid; padding-top: 5px; padding-bottom: 5px;"
	var/list/dat = list()
	dat += "<head><meta http-equiv='X-UA-Compatible' content='IE=edge'><style>.adminticket{border:2px solid} td{border:1px solid grey;} th{border:1px solid grey;} span{float:left;width:150px;}</style></head>"
	dat += "<div style='min-height:100px'>"
	dat += "<span>Time Search Range:</span> <a href='byond://?src=[UID()];start_time=1'>[gameTimestamp(wtime = time_from)]</a>"
	dat += " To: <a href='byond://?src=[UID()];end_time=1'>[gameTimestamp(wtime = time_to)]</a>"
	dat += "<BR>"

	dat += "<span>Mobs being used:</span>"
	for(var/i in selected_mobs)
		var/mob/M = i
		if(QDELETED(M))
			selected_mobs -= i
			continue
		dat += "<a href='byond://?src=[UID()];remove_mob=\ref[M]'>[get_display_name(M)]</a>"
	dat += "<a href='byond://?src=[UID()];add_mob=1'>Add Mob</a>"
	dat += "<a href='byond://?src=[UID()];clear_mobs=1'>Clear All Mobs</a>"
	dat += "<BR>"

	dat += "<span>Ckeys being used:</span>"
	for(var/ckey in selected_ckeys)
		dat += "<a href='byond://?src=[UID()];remove_ckey=[ckey]'>[get_ckey_name(ckey)]</a>"
	dat += "<a href='byond://?src=[UID()];add_ckey=1'>Add ckey</a>"
	dat += "<a href='byond://?src=[UID()];clear_ckeys=1'>Clear All ckeys</a>"
	dat += "<BR>"

	dat += "<span>Log Types:</span>"
	for(var/log_type in all_log_types)
		var/enabled = (log_type in selected_log_types)
		var/text
		var/style
		if(enabled)
			text = "<b>[log_type]</b>"
			style = "background: [get_logtype_color(log_type)]"
		else
			text = log_type

		dat += "<a href='byond://?src=[UID()];toggle_log_type=[log_type]' style='[style]'>[text]</a>"

	dat += "<BR>"
	dat += "<a href='byond://?src=[UID()];clear_all=1'>Clear All Settings</a>"
	dat += "<a href='byond://?src=[UID()];search=1'>Search</a>"
	dat += "</div>"

	// Search results
	var/tdStyleTime		= "width:80px; text-align:center;"
	var/tdStyleType		= "width:80px; text-align:center;"
	var/tdStyleWho		= "width:400px; text-align:center;"
	var/tdStyleWhere	= "width:150px; text-align:center;"
	dat += "<div style='overflow-y: auto; max-height:calc(100vh - 150px);'>"
	dat += "<table style='width:100%; border: 1px solid;'>"
	dat += "<tr style='[trStyleTop]'><th style='[tdStyleTime]'>When</th><th style='[tdStyleType]'>Type</th><th style='[tdStyleWho]'>Who</th><th>What</th><th>Target</th><th style='[tdStyleWhere]'>Where</th></tr>"
	for(var/i in log_records)
		var/datum/log_record/L = i
		var/time = gameTimestamp(wtime = L.raw_time - 9.99) // The time rounds up for some reason. Will result in weird filtering results

		dat +="<tr style='[trStyle]'><td style='[tdStyleTime]'>[time]</td><td style='[tdStyleType]background: [get_logtype_color(L.log_type)]'>[L.log_type]</td>\
		<td style='[tdStyleWho]'>[L.who][L.who_usr]</td><td style='background: [get_logtype_color(L.log_type)];'>[L.what]</td>\
		<td style='[tdStyleWho]'>[L.target]</td><td style='[tdStyleWhere]'>[L.where]</td></tr>"
	dat += "</table>"
	dat += "</div>"

	var/datum/browser/popup = new(user, "Log Viewer", "Log Viewer", 1500, 600)
	popup.set_content(dat.Join())
	popup.open()

/datum/log_viewer/Topic(href, href_list)
	if(href_list["start_time"])
		var/input = input(usr, "hh:mm:ss", "Start time", "00:00:00") as text|null
		if(!input)
			return
		var/res = timeStampToNum(input)
		if(res < 0)
			to_chat(usr, "<span class='warning'>'[input]' is an invalid input value.</span>")
			return
		time_from = res
		show_ui(usr)
		return
	if(href_list["end_time"])
		var/input = input(usr, "hh:mm:ss", "End time", "04:00:00") as text|null
		if(!input)
			return
		var/res = timeStampToNum(input)
		if(res < 0)
			to_chat(usr, "<span class='warning'>'[input]' is an invalid input value.</span>")
			return
		time_to = res

		show_ui(usr)
		return
	if(href_list["search"])
		search(usr)
		var/records_len = length(log_records)
		if(records_len > RECORD_WARN_LIMIT)
			var/datum/log_record/last_record = log_records[RECORD_WARN_LIMIT]
			var/last_time = gameTimestamp(wtime = last_record.raw_time - 9.99)
			var/answer = alert(usr, "More than [RECORD_WARN_LIMIT] records were found. continuing will take a long time. This won't cause much lag for the server. Time at the [RECORD_WARN_LIMIT]th record '[last_time]'", "Warning", "Continue", "Limit to [RECORD_WARN_LIMIT]", "Cancel")
			if(answer == "Limit to [RECORD_WARN_LIMIT]")
				log_records.Cut(RECORD_WARN_LIMIT)
			else if(answer == "Cancel")
				log_records.Cut()
			else
				if(records_len > RECORD_HARD_LIMIT)
					to_chat(usr, "<span class='warning'>Record limit reached. Limiting to [RECORD_HARD_LIMIT].</span>")
					log_records.Cut(RECORD_HARD_LIMIT)
		show_ui(usr)
		return
	if(href_list["clear_all"])
		clear_all(usr)
		show_ui(usr)
		return
	if(href_list["clear_mobs"])
		selected_mobs.Cut()
		show_ui(usr)
		return
	if(href_list["clear_ckeys"])
		selected_ckeys.Cut()
		selected_ckeys_mobs.Cut()
		show_ui(usr)
		return
	if(href_list["add_mob"])
		var/list/mobs = getpois(TRUE, TRUE)
		var/mob_choice = tgui_input_list(usr, "Please, select a mob: ", "Mob selector", mobs)
		add_mob(usr, mobs[mob_choice])
		return
	if(href_list["add_ckey"])
		var/list/ckeys = GLOB.logging.get_ckeys_logged()
		var/ckey_choice = tgui_input_list(usr, "Please, select a ckey: ", "Ckey selector", ckeys)
		add_ckey(usr, ckey_choice)
		return
	if(href_list["remove_mob"])
		var/mob/M = locate(href_list["remove_mob"])
		if(M)
			selected_mobs -= M
		show_ui(usr)
		return
	if(href_list["remove_ckey"])
		selected_ckeys -= href_list["remove_ckey"]
		show_ui(usr)
		return
	if(href_list["toggle_log_type"])
		var/log_type = href_list["toggle_log_type"]
		if(log_type in selected_log_types)
			selected_log_types -= log_type
		else
			selected_log_types += log_type
		show_ui(usr)
		return

/datum/log_viewer/proc/get_logtype_color(log_type)
	switch(log_type)
		if(ATTACK_LOG)
			return "darkred"
		if(DEFENSE_LOG)
			return "chocolate"
		if(CONVERSION_LOG)
			return "indigo"
		if(SAY_LOG)
			return "teal"
		if(EMOTE_LOG)
			return "deepskyblue"
		if(MISC_LOG)
			return "gray"
		if(DEADCHAT_LOG)
			return "#cc00c6"
		if(OOC_LOG)
			return "#002eb8"
		if(LOOC_LOG)
			return "#6699CC"
	return "slategray"

/datum/log_viewer/proc/get_display_name(mob/M)
	var/name = M.name
	if(M.name != M.real_name)
		name = "[name] ([M.real_name])"
	if(isobserver(M))
		name = "[name] (DEAD)"
	return "\[[M.last_known_ckey]\] [name]"

/datum/log_viewer/proc/get_ckey_name(ckey)
	UPDATE_CKEY_MOB(ckey)
	var/mob/M = selected_ckeys_mobs[ckey]

	return get_display_name(M)

#undef UPDATE_CKEY_MOB
#undef RECORD_WARN_LIMIT
#undef RECORD_HARD_LIMIT
