/client/proc/air_status(turf/target as turf)
	set category = "Debug"
	set name = "Display Air Status"

	if(!check_rights(R_DEBUG))
		return

	if(!isturf(target))
		return

	var/datum/gas_mixture/GM = target.return_air()
	var/burning = 0
	if(istype(target, /turf/simulated))
		var/turf/simulated/T = target
		if(T.active_hotspot)
			burning = 1

	to_chat(usr, "<span class='notice'>@[target.x],[target.y]: O:[GM.oxygen] T:[GM.toxins] N:[GM.nitrogen] C:[GM.carbon_dioxide] w [GM.temperature] Kelvin, [GM.return_pressure()] kPa [(burning)?("<span class='warning'>BURNING</span>"):(null)]</span>")
	for(var/datum/gas/trace_gas in GM.trace_gases)
		to_chat(usr, "[trace_gas.type]: [trace_gas.moles]")

	message_admins("[key_name_admin(usr)] has checked the air status of [T]")
	log_admin("[key_name(usr)] has checked the air status of [T]")

	feedback_add_details("admin_verb","DAST") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/fix_next_move()
	set category = "Debug"
	set name = "Unfreeze Everyone"

	if(!check_rights(R_DEBUG))
		return

	message_admins("[key_name_admin(usr)] has unfrozen everyone")
	log_admin("[key_name(usr)] has unfrozen everyone")

	var/largest_move_time = 0
	var/largest_click_time = 0
	var/mob/largest_move_mob = null
	var/mob/largest_click_mob = null
	for(var/mob/M in world)
		if(!M.client)
			continue
		if(M.next_move >= largest_move_time)
			largest_move_mob = M
			if(M.next_move > world.time)
				largest_move_time = M.next_move - world.time
			else
				largest_move_time = 1
		if(M.next_click >= largest_click_time)
			largest_click_mob = M
			if(M.next_click > world.time)
				largest_click_time = M.next_click - world.time
			else
				largest_click_time = 0
		log_admin("DEBUG: [key_name(M)]  next_move = [M.next_move]  next_click = [M.next_click]  world.time = [world.time]")
		M.next_move = 1
		M.next_click = 0

	message_admins("[key_name_admin(largest_move_mob)] had the largest move delay with [largest_move_time] frames / [largest_move_time/10] seconds!", 1)
	message_admins("[key_name_admin(largest_click_mob)] had the largest click delay with [largest_click_time] frames / [largest_click_time/10] seconds!", 1)
	message_admins("world.time = [world.time]", 1)

	feedback_add_details("admin_verb","UFE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/radio_report()
	set category = "Debug"
	set name = "Radio report"

	if(!check_rights(R_DEBUG))
		return

	var/filters = list(
		"1" = "RADIO_TO_AIRALARM",
		"2" = "RADIO_FROM_AIRALARM",
		"3" = "RADIO_CHAT",
		"4" = "RADIO_ATMOSIA",
		"5" = "RADIO_NAVBEACONS",
		"6" = "RADIO_AIRLOCK",
		"7" = "RADIO_SECBOT",
		"8" = "RADIO_MULEBOT",
		"_default" = "NO_FILTER"
		)
	var/output = "<b>Radio Report</b><hr>"
	for(var/fq in SSradio.frequencies)
		output += "<b>Freq: [fq]</b><br>"
		var/list/datum/radio_frequency/fqs = SSradio.frequencies[fq]
		if(!fqs)
			output += "&nbsp;&nbsp;<b>ERROR</b><br>"
			continue
		for(var/filter in fqs.devices)
			var/list/f = fqs.devices[filter]
			if(!f)
				output += "&nbsp;&nbsp;[filters[filter]]: ERROR<br>"
				continue
			output += "&nbsp;&nbsp;[filters[filter]]: [f.len]<br>"
			for(var/device in f)
				if(isobj(device))
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device] ([device:x],[device:y],[device:z] in area [get_area(device:loc)])<br>"
				else
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device]<br>"

	usr << browse(output,"window=radioreport")

	message_admins("[key_name_admin(usr)] has generated a radio report")
	log_admin("[key_name(usr)] has generated a radio report")

	feedback_add_details("admin_verb","RR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/reload_admins()
	set name = "Reload Admins"
	set category = "Debug"

	if(!check_rights(R_SERVER))
		return

	message_admins("[key_name_admin(usr)] has manually reloaded admins")
	log_admin("[key_name(usr)] has manually reloaded admins")

	load_admins()
	feedback_add_details("admin_verb","RLDA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/print_jobban_old()
	set name = "Print Jobban Log"
	set desc = "This spams all the active jobban entries for the current round to standard output."
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return

	to_chat(usr, "<b>Jobbans active in this round.</b>")
	for(var/t in jobban_keylist)
		to_chat(usr, "[t]")

	message_admins("[key_name_admin(usr)] has printed the jobban log")
	log_admin("[key_name(usr)] has printed the jobban log")

/client/proc/print_jobban_old_filter()
	set name = "Search Jobban Log"
	set desc = "This searches all the active jobban entries for the current round and outputs the results to standard output."
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return

	var/filter = clean_input("Contains what?","Filter")
	if(!filter)
		return

	to_chat(usr, "<b>Jobbans active in this round.</b>")
	for(var/t in jobban_keylist)
		if(findtext(t, filter))
			to_chat(usr, "[t]")

	message_admins("[key_name_admin(usr)] has searched the jobban log for [filter]")
	log_admin("[key_name(usr)] has searched the jobban log for [filter]")

/client/proc/vv_by_ref()
	set name = "VV by Ref"
	set desc = "Give this a ref string, and you will see its corresponding VV panel if it exists"
	set category = "Debug"

	// It's gated by "Debug Verbs", so might as well gate it to the debug permission
	if(!check_rights(R_DEBUG))
		return

	var/refstring = clean_input("Which reference?","Ref")
	if(!refstring)
		return

	var/datum/D = locate(refstring)
	if(!D)
		to_chat(usr, "<span class='warning'>That ref string does not correspond to any datum.</span>")
		return

	debug_variables(D)
