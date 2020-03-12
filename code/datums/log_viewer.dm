#define ALL_LOGS list(ATTACK_LOG, DEFENSE_LOG, CONVERSION_LOG, SAY_LOG, WHISPER_LOG, EMOTE_LOG, MISC_LOG)

/datum/log_viewer
	var/time_from = 0
	var/time_to = 2 HOURS // Full range
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
		if(!M)
			invalid_mobs |= M
			to_chat(usr, "<span class='warning'>Mob '[M]' is invalid. Removing from the search criteria.</span>")
			continue
		for(var/log_type in selected_log_types)
			var/list/logs = M.logs[log_type]
			if(length(logs))
				var/start_index = get_earliest_log_index(logs)
				var/end_index = get_latest_log_index(logs)
				log_records.Add(logs.Copy(start_index, end_index))
	
	for(var/i in invalid_mobs)
		selected_mobs -= i // Cleanup

	log_records = sortTim(log_records, /proc/compare_log_record)

/datum/log_viewer/proc/get_earliest_log_index(list/logs)
	if(!time_from)
		return 1
	var/start = 1
	var/end = length(logs)
	var/mid = round_down((end - 1) / 2)
	do
		var/datum/log_record/L = logs[mid]
		if(L.raw_time >= time_from)
			end = mid
		else
			start = mid
		mid = round_down((end - start) / 2)
	while(end - start)

	return mid

/datum/log_viewer/proc/get_latest_log_index(list/logs)
	var/end = length(logs)
	var/datum/log_record/last_log = logs[end]
	if(last_log.raw_time < world.time)
		return end

	var/mid = end / 2
	var/start = 1

	do
		var/datum/log_record/L = logs[mid]
		if(L.raw_time >= time_to)
			end = mid
		else
			start = mid
		mid = round_down((end - start) / 2)
	while(end - start)

	return mid

/datum/log_viewer/proc/add_mob(mob/user, mob/M)
	if(!M || !usr)
		return
	selected_mobs |= M

	show_ui(user)

/datum/log_viewer/proc/show_ui(mob/user)
	var/all_log_types	= ALL_LOGS
	var/half_way_log_types = (length(all_log_types) + 1) / 2
	var/trStyleTop		= "border-top:2px solid; border-bottom:2px solid; padding-top: 5px; padding-bottom: 5px;"
	var/trStyle			= "border-top:1px solid; border-bottom:1px solid; padding-top: 5px; padding-bottom: 5px;"
	var/dat
	dat += "<head><style>.adminticket{border:2px solid}</style></head>"

	// Options part
	var/tdStyleTimeControl	= "border-top:2px solid; border-bottom:2px solid; width:200px; text-align:center;"
	var/thStyleMobs			= "border-top:2px solid; border-bottom:2px solid; width:400px; text-align:center;"
	var/tdStyleMobs			= "border-top:2px solid; border-bottom:2px solid; width:400px; text-align:center; max-height:100px; overflow:hidden; overflow-y:scroll;"
	var/tdStyleLogs			= "border-top:2px solid; border-bottom:2px solid;"
	var/tdStyleSearch		= "border-top:2px solid; border-bottom:2px solid; width:100px; text-align:center;"
	dat += "<table style='width:100%; border: 3px solid;'>"
	dat += "<tr style='[trStyleTop]'><th style='[tdStyleTimeControl]'>Time</th><th style='[thStyleMobs]'>Mobs</th><th style='[tdStyleLogs]'>Log types</th><th style='[tdStyleSearch]'></th></tr>"
	dat += "<tr style='[trStyle]'>"

	dat += "<td style='[tdStyleTimeControl]'>"
	dat += "<a href='?src=[UID()];start_time=1'>[gameTimestamp(wtime = time_from)]</a>"

	dat += "<td style='[thStyleMobs]'>"
	dat += "<a href='?src=[UID()];add_mob=1'>Add mob</a>"
	dat += "<a href='?src=[UID()];clear_mobs=1'>Clear mob</a>"
	dat += "</td>"
	dat += "<td style='[tdStyleLogs]'>"

	for(var/i in 1 to half_way_log_types)
		var/log_type = all_log_types[i]
		var/text = (log_type in selected_log_types) ? "<b>[log_type]</b>" : log_type
		dat += "<a href='?src=[UID()];toggle_log_type=[log_type]'>[text]</a>"
	dat += "</td>"
	dat += "<td style='[tdStyleSearch]'><a href='?src=[UID()];clear_all=1'>Clear all</a></td>"
	dat += "</tr>"

	dat += "<tr style='[trStyle]'>"

	dat += "<td style='[tdStyleTimeControl]'>"
	dat += "<a href='?src=[UID()];end_time=1'>[gameTimestamp(wtime = time_to)]</a>"
	
	dat += "<td style='[tdStyleMobs]'>"
	for(var/i in selected_mobs)
		var/mob/M = i
		dat += "<a href='?src=[UID()];remove_mob=\ref[M]'>[M.name]</a><br>"
	dat += "</td>"
	dat += "<td style='[tdStyleLogs]'>"
	for(var/i in half_way_log_types + 1 to length(all_log_types))
		var/log_type = all_log_types[i]
		var/text = (log_type in selected_log_types) ? "<b>[log_type]</b>" : log_type
		dat += "<a href='?src=[UID()];toggle_log_type=[log_type]'>[text]</a>"
	dat += "<td style='[tdStyleSearch]'><a href='?src=[UID()];search=1'>Search</a></td>"
	dat += "</table>"

	// Search results
	var/tdStyleTime		= "border-top:2px solid; border-bottom:2px solid; width:100px; text-align:center;"
	var/tdStyleType		= "border-top:2px solid; border-bottom:2px solid; width:100px; text-align:center;"
	var/tdStyleWho		= "border-top:2px solid; border-bottom:2px solid; width:200px; text-align:center;"
	var/tdStyleWhat 	= "border-top:2px solid; border-bottom:2px solid;"
	var/tdStyleWhere	= "border-top:2px solid; border-bottom:2px solid; width:200px; text-align:center;"

	dat += "<table style='width:100%; border: 1px solid;'>"
	dat += "<tr style='[trStyleTop]'><th style='[tdStyleTime]'>Time</th><th style='[tdStyleType]'>Type</th><th style='[tdStyleWho]'>Who</th><th style='[tdStyleWhat]'>What</th><th style='[tdStyleWho]'>Target</th><th style='[tdStyleWhere]'>Where</th></tr>"
	for(var/i in log_records)
		var/datum/log_record/L = i
		var/time = gameTimestamp(wtime = L.raw_time)
		dat +="<tr style='[trStyle]'><td style='[tdStyleTime]'>[time]</td><td style='[tdStyleType]'>[L.log_type]</td>\
		<td style='[tdStyleWho]'>[ADMIN_LOOKUPFLW(L.who)]</td><td style='[tdStyleWhat]'>[L.what]</td>\
		<td style='[tdStyleWho]'>[ADMIN_LOOKUPFLW(L.target)]</td><td style='[tdStyleWhere]'>[ADMIN_COORDJMP(L.where)]</td></tr>"

	dat += "</table>"

	var/datum/browser/popup = new(user, "Log viewer", "Log viewer", 1400, 600)
	popup.set_content(dat)
	popup.open()

/datum/log_viewer/Topic(href, href_list)
	if(href_list["start_time"])
		var/input = input(usr, "hh:mm:ss", "Start time", "00:00") as text|null
		if(!input)
			return
		time_from = timeStampToNum(input)
		show_ui(usr)
		return
	if(href_list["end_time"])
		var/input = input(usr, "hh:mm:ss", "End time", "02:00") as text|null
		if(!input)
			return
		time_to = timeStampToNum(input)
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