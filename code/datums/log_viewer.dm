#define ALL_LOGS list(ATTACK_LOG, DEFENSE_LOG, CONVERSION_LOG, SAY_LOG, EMOTE_LOG, MISC_LOG)

/datum/log_viewer
	var/time_from = 0
	var/time_to = 4 HOURS					// 4 Hours should be enough. INFINITY would screw the UI up
	var/list/selected_mobs = list()			// The mobs in question
	var/list/selected_log_types = list()	// The log types being searched for

	var/list/log_records = list()			// Found and sorted records

/datum/log_viewer/proc/clear_all()
	selected_mobs.Cut()
	selected_log_types.Cut()
	time_from = initial(time_from)
	time_to = initial(time_to)
	log_records.Cut()
	return

/datum/log_viewer/proc/search()
	log_records.Cut() // Empty the old results
	var/list/invalid_mobs = list()
	for(var/i in selected_mobs)
		var/mob/M = i
		if(!M || QDELETED(M))
			invalid_mobs |= M
			continue
		for(var/log_type in selected_log_types)
			var/list/logs = M.logs[log_type]
			var/len_logs = length(logs)
			if(len_logs)
				var/start_index = get_earliest_log_index(logs)
				if(!start_index) // No log found that matches the starting time criteria
					continue
				var/end_index = get_latest_log_index(logs)
				if(!end_index) // No log found that matches the end time criteria
					continue
				log_records.Add(logs.Copy(start_index, end_index + 1))

	if(invalid_mobs.len)
		to_chat(usr, "<span class='warning'>The search criteria contained invalid mobs. They have been removed from the criteria.</span>")
		for(var/i in invalid_mobs)
			selected_mobs -= i // Cleanup

	log_records = sortTim(log_records, /proc/compare_log_record)

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

/datum/log_viewer/proc/add_mob(mob/user, mob/M)
	if(!M || !user)
		return
	selected_mobs |= M

	show_ui(user)

/datum/log_viewer/proc/show_ui(mob/user)
	var/all_log_types	= ALL_LOGS
	var/trStyleTop		= "border-top:2px solid; border-bottom:2px solid; padding-top: 5px; padding-bottom: 5px;"
	var/trStyle			= "border-top:1px solid; border-bottom:1px solid; padding-top: 5px; padding-bottom: 5px;"
	var/dat
	dat += "<head><style>.adminticket{border:2px solid} td{border:1px solid grey;} th{border:1px solid grey;} span{float:left;width:150px;}</style></head>"
	dat += "<div style='height:15vh'>"
	dat += "<span>Time Search Range:</span> <a href='?src=[UID()];start_time=1'>[gameTimestamp(wtime = time_from)]</a>"
	dat += " To: <a href='?src=[UID()];end_time=1'>[gameTimestamp(wtime = time_to)]</a>"
	dat += "<BR>"

	dat += "<span>Mobs being used:</span>"
	for(var/i in selected_mobs)
		var/mob/M = i
		dat += "<a href='?src=[UID()];remove_mob=\ref[M]'>[M.name]</a>"
	dat += "<a href='?src=[UID()];add_mob=1'>Add Mob</a>"
	dat += "<a href='?src=[UID()];clear_mobs=1'>Clear All Mobs</a>"
	dat += "<BR>"

	dat += "<span>Log Types:</span>"
	for(var/i in all_log_types)
		var/log_type = i
		var/enabled = (log_type in selected_log_types)
		var/text
		var/style
		if(enabled)
			text = "<b>[log_type]</b>"
			style = "background: [get_logtype_color(i)]"
		else
			text = log_type

		dat += "<a href='?src=[UID()];toggle_log_type=[log_type]' style='[style]'>[text]</a>"

	dat += "<BR>"
	dat += "<a href='?src=[UID()];clear_all=1'>Clear All Settings</a>"
	dat += "<a href='?src=[UID()];search=1'>Search</a>"
	dat += "</div>"

	// Search results
	var/tdStyleTime		= "width:80px; text-align:center;"
	var/tdStyleType		= "width:80px; text-align:center;"
	var/tdStyleWho		= "width:300px; text-align:center;"
	var/tdStyleWhere	= "width:150px; text-align:center;"
	dat += "<div style='overflow-y: auto; max-height:76vh;'>"
	dat += "<table style='width:100%; border: 1px solid;'>"
	dat += "<tr style='[trStyleTop]'><th style='[tdStyleTime]'>When</th><th style='[tdStyleType]'>Type</th><th style='[tdStyleWho]'>Who</th><th>What</th><th>Target</th><th style='[tdStyleWhere]'>Where</th></tr>"
	for(var/i in log_records)
		var/datum/log_record/L = i
		var/time = gameTimestamp(wtime = L.raw_time - 9.99) // The time rounds up for some reason. Will result in weird filtering results

		dat +="<tr style='[trStyle]'><td style='[tdStyleTime]'>[time]</td><td style='[tdStyleType]background: [get_logtype_color(L.log_type)]'>[L.log_type]</td>\
		<td style='[tdStyleWho]'>[L.who]</td><td style='background: [get_logtype_color(L.log_type)];'>[L.what]</td>\
		<td style='[tdStyleWho]'>[L.target]</td><td style='[tdStyleWhere]'>[ADMIN_COORDJMP(L.where)]</td></tr>"

	dat += "</table>"
	dat += "</div>"

	var/datum/browser/popup = new(user, "Log viewer", "Log viewer", 1400, 600)
	popup.set_content(dat)
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
	if(href_list["add_mob"])
		var/list/mobs = getpois(TRUE, TRUE)
		var/datum/async_input/A = input_autocomplete_async(usr, "Please, select a mob: ", mobs)
		A.on_close(CALLBACK(src, .proc/add_mob, usr))
		return
	if(href_list["remove_mob"])
		var/mob/M = locate(href_list["remove_mob"])
		if(M)
			selected_mobs -= M
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
	return "slategray"
