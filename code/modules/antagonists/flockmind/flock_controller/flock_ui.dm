/datum/flock/ui_state(mob/user)
	return GLOB.flock_state

/datum/flock/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FlockPanel")
		ui.open()

/datum/flock/ui_data(mob/user)
	var/list/data = list()
	var/list/drone_info = list()
	var/list/trace_info = list()
	var/list/enemy_info = list()
	var/list/vitals_info = list("name" = name)
	var/list/stats_info = list()
	var/list/structure_info = list()

	data["drones"] = drone_info
	data["partitions"] = trace_info
	data["vitals"] = vitals_info
	data["enemies"] = enemy_info
	data["structures"] = structure_info
	data["category"] = ui_tab
	data["stats"] = stats_info
	data["category_lengths"] = list(
		"traces" = length(traces),
		"drones" = length(drones),
		"enemies" = length(enemies),
		"structures" = length(structures),
	)

	switch(ui_tab)
		if(FLOCK_UI_DRONES)
			for(var/mob/living/basic/flock/drone/bird as anything in drones)
				drone_info[++drone_info.len] = bird.get_flock_data()

		if(FLOCK_UI_TRACES)
			for(var/mob/camera/flock/trace/ghost_bird as anything in traces)
				trace_info[++trace_info.len] = ghost_bird.get_flock_data()

		if(FLOCK_UI_ENEMIES)
			for(var/mob/enemy in enemies)
				var/list/mob_data = list()
				mob_data["name"] = enemy.name
				mob_data["area"] = enemies[enemy]
				mob_data["ref"] = REF(enemy)
				enemy_info[++enemy_info.len] = mob_data

		if(FLOCK_UI_STRUCTURES)
			for(var/obj/structure/flock/struct as anything in structures)
				structure_info[++structure_info.len] = struct.get_flock_data()

	stats_info[++stats_info.len] = list(name = "Drones realized: ", "value" = stat_drones_made)
	stats_info[++stats_info.len] = list(name = "Bits formed: ", "value" = stat_bits_made)
	stats_info[++stats_info.len] = list(name = "Total deaths: ", "value" = stat_deaths)
	stats_info[++stats_info.len] = list(name = "Resources gianed: ", "value" = stat_resources_gained)
	stats_info[++stats_info.len] = list(name = "Partitions divided: ", "value" = stat_traces_made)
	stats_info[++stats_info.len] = list(name = "Tiles converted: ", "value" = stat_tiles_made)
	stats_info[++stats_info.len] = list(name = "Structures materialized: ", "value" = stat_structures_made)
	stats_info[++stats_info.len] = list(name = "Highest bandwidth: ", "value" = stat_highest_bandwidth)

	return data

/datum/flock/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if ("change_tab")
			if (ui_tab != params["tab"])
				ui_tab = params["tab"]
				return TRUE

		if("jump_to")
			var/atom/movable/target = locate(params["origin"])
			var/turf/T = get_turf(target)
			if(isnull(T) || !is_on_safe_z(target))
				to_chat(user, SPAN_ALERT("They are beyond our reach."))
				return

			if(isflockdrone(user))
				var/mob/living/basic/flock/drone/bird = user
				user = bird.controlled_by
				bird.release_control()

			user.forceMove(T)

		if("remove_enemy")
			var/mob/enemy = locate(params["origin"])
			if(enemy)
				remove_enemy(enemy)
				return TRUE

		if("rally")
			var/mob/living/basic/flock/drone/bird = locate(params["origin"])
			if(istype(bird))
				bird.rally(get_turf(user))
				return TRUE

		if("cancel_tealprint")
			var/obj/structure/flock/tealprint/tealprint = locate(params["origin"])
			tealprint?.try_cancel_structure()
			return TRUE

		if("delete_trace")
			var/mob/camera/flock/trace/flocktrace = locate(params["origin"])
			if(!istype(flocktrace))
				message_admins("Warning: possible href exploit by [key_name(usr)] - attempted to remove a flocktrace that wasn't a flocktrace: [flocktrace]")
				log_game("Warning: possible href exploit by [key_name(usr)] - attempted to remove a flocktrace that wasn't a flocktrace: [flocktrace]")
				return TRUE

			if(tgui_alert(user, "This will destroy the Flocktrace. Are you sure you want to do this?", "Confirmation", list("Yes", "No")) == "Yes")
				flock_talk(null, "Partition [flocktrace.real_name] has been reintegrated into flock background processes.", src, involuntary = TRUE)
				to_chat(flocktrace, SPAN_FLOCKSAY("Your higher cognition has been forcibly reintegrated into the collective will of the flock."))
				flocktrace.so_very_sad_death()
			return TRUE
