SUBSYSTEM_DEF(statpanels)
	name = "Stat Panels"
	wait = 4
	init_order = INIT_ORDER_STATPANELS
	priority = FIRE_PRIORITY_STATPANEL
	flags = SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	var/list/currentrun = list()
	/// Stuff shown to everyone.
	var/list/global_data
	/// Stuff shown to all admins.
	var/list/admin_data
	var/list/mc_data

	/// How many subsystem fires between most tab updates
	var/default_wait = 10
	/// How many subsystem fires between updates of the status tab
	var/status_wait = 6
	/// How many subsystem fires between updates of the MC tab
	var/mc_wait = 5
	/// How many full runs this subsystem has completed. used for variable rate refreshes.
	var/num_fires = 0

/datum/controller/subsystem/statpanels/fire(resumed = FALSE)
	if(!resumed)
		num_fires++
		var/datum/map/cached = SSmapping.next_map
		var/round_time = world.time - SSticker.time_game_started
		global_data = list(
			list("Map:", SSmapping.map_datum?.fluff_name ? SSmapping.map_datum?.fluff_name : "Loading..."),
			cached ? list("Next Map:", "[cached.fluff_name]") : null,
			list("Round ID:", "[GLOB.round_id ? GLOB.round_id : "NULL"]"),
			list("Server Time:", "[time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")]"),
			list("[SSticker.time_game_started ? "Round Time" : "Lobby Time"]:", "[round_time > MIDNIGHT_ROLLOVER ? "[round(round_time / MIDNIGHT_ROLLOVER)]:[roundtime2text()]" : roundtime2text()]"),
			list("Station Time:", "[station_time_timestamp()]"),
			list("Time Dilation:", "[round(SStime_track.time_dilation_current, 1)]% AVG:([round(SStime_track.time_dilation_avg_fast, 1)]%, [round(SStime_track.time_dilation_avg, 1)]%, [round(SStime_track.time_dilation_avg_slow, 1)]%)"),
			list("Players Connected:", "[length(GLOB.clients)]"),
			list("Players in Lobby:", "[length(GLOB.new_player_mobs)]")
		)

		admin_data = list()
		if(SSticker?.current_state == GAME_STATE_PREGAME)
			global_data += list(list("Time To Start:", SSticker.ticker_going ? deciseconds_to_time_stamp(SSticker.pregame_timeleft) : "DELAYED"))

			var/players_ready = 0
			admin_data += list(list("Players Ready:", "?"))
			var/players_ready_index = length(admin_data)
			for(var/mob/new_player/player in GLOB.player_list)
				admin_data += list(list("[player.key]", player.ready ? "(Ready)" : "(Not ready)"))
				if(player.ready)
					players_ready++

			admin_data[players_ready_index][2] = "[players_ready]"

		if(SSshuttle.emergency)
			var/eta = SSshuttle.emergency.getModeStr()
			if(eta)
				global_data += list(list("[eta]", "[SSshuttle.emergency.getTimerStr()]"))
		src.currentrun = GLOB.clients.Copy()
		mc_data = null

	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/client/target = currentrun[length(currentrun)]
		currentrun.len--

		if(!target.stat_panel.is_ready())
			continue

		if(target.stat_tab == "Status" && num_fires % status_wait == 0)
			set_status_tab(target)

		if(!target.holder || !(target.prefs?.toggles2 & PREFTOGGLE_2_MC_TAB))
			target.stat_panel.send_message("remove_mc_tab", !target.holder ? TRUE : FALSE)

		else if(target.mob && check_rights(R_DEBUG | R_VIEWRUNTIMES, FALSE, target.mob) && target.prefs?.toggles2 & PREFTOGGLE_2_MC_TAB)
			if(!("MC" in target.panel_tabs))
				target.stat_panel.send_message("add_mc_tab", target.holder.href_token)

			if(target.stat_tab == "MC" && ((num_fires % mc_wait == 0)))
				set_MC_tab(target)

		if(target.mob)
			var/mob/target_mob = target.mob
			// Handle the examined turf of the stat panel, if it's been long enough, or if we've generated new images for it
			var/turf/listed_turf = target_mob?.listed_turf
			if(listed_turf && num_fires % default_wait == 0)
				if(target.stat_tab == listed_turf.name || !(listed_turf.name in target.panel_tabs))
					set_turf_examine_tab(target, target_mob)

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/statpanels/proc/set_status_tab(client/target)
	if(!global_data) //statbrowser hasnt fired yet and we were called from immediate_send_stat_data()
		return

	target.stat_panel.send_message("update_stat", list(
		global_data = global_data,
		mob_specific_data = target.mob?.get_status_tab_items(),
	))

/datum/controller/subsystem/statpanels/proc/set_MC_tab(client/target)
	var/turf/eye_turf = get_turf(target.eye)
	var/coord_entry = COORD(eye_turf)
	if(!mc_data)
		generate_mc_data()
	target.stat_panel.send_message("update_mc", list(mc_data = mc_data, coord_entry = coord_entry))

/datum/controller/subsystem/statpanels/proc/set_turf_examine_tab(client/target, mob/target_mob)
	var/list/overrides = list()
	for(var/image/target_image as anything in target.images)
		if(!target_image.loc || target_image.loc.loc != target_mob.listed_turf || !target_image.override)
			continue
		overrides += target_image.loc

	var/list/atoms_to_display = list(target_mob.listed_turf)
	for(var/atom/movable/turf_content as anything in target_mob.listed_turf)
		if(turf_content.mouse_opacity == MOUSE_OPACITY_TRANSPARENT)
			continue
		if(turf_content.invisibility > target_mob.see_invisible)
			continue
		if(turf_content in overrides)
			continue
		if(turf_content.IsObscured())
			continue
		atoms_to_display += turf_content

	/// Set the atoms we're meant to display
	var/datum/object_window_info/obj_window = istype(target.obj_window) ? target.obj_window : new(target)
	obj_window.atoms_to_show = atoms_to_display
	refresh_client_obj_view(target, obj_window.min_index, obj_window.max_index)

/datum/controller/subsystem/statpanels/proc/refresh_client_obj_view(client/refresh, min_index = 0, max_index = 30)
	var/list/turf_items = return_object_images(refresh, min_index, max_index)
	if(!length(turf_items) || !refresh.mob?.listed_turf)
		return
	refresh.stat_panel.send_message("update_listedturf", turf_items)

#define OBJ_IMAGE_LOADING "statpanels obj loading temporary"

/// Returns all our ready object tab images
/// Returns a list in the form list(list(object_name, object_ref, loaded_image), ...)
/datum/controller/subsystem/statpanels/proc/return_object_images(client/load_from, min_index, max_index)
	// You might be inclined to think that this is a waste of cpu time, since we
	// A: Double iterate over atoms in the build case, or
	// B: Generate these lists over and over in the refresh case
	// It's really not very hot. The hot portion of this code is genuinely mostly in the image generation
	// So it's ok to pay a performance cost for cleanliness here

	// No turf? go away
	if(!load_from.mob?.listed_turf)
		return list()

	var/datum/object_window_info/obj_window = load_from.obj_window
	if(!obj_window)
		return list()
	var/list/already_seen = obj_window.atoms_to_images
	var/list/to_make = obj_window.atoms_to_imagify
	var/list/turf_items = list()
	var/i = 0
	var/client_uid = load_from.UID()
	for(var/atom/turf_item as anything in obj_window.atoms_to_show)
		// Limit what we send to the client's rendered section.
		i++
		if(i <= min_index || i > max_index)
			continue

		// First, we fill up the list of refs to display
		// If we already have one, just use that
		var/existing_image = already_seen[turf_item]
		if(existing_image == OBJ_IMAGE_LOADING)
			continue
		// We already have it. Success!

		// Store the cache the MD5'd UID for safety reasons
		var/obj_m5_uid = turf_item.MD5_UID()
		load_from.m5_uid_cache[obj_m5_uid] = turf_item.unique_datum_id

		if(existing_image)
			turf_items["[i]"] = list("[turf_item.name]", obj_m5_uid, SSassets.transport.get_asset_url(existing_image), existing_image, client_uid)
			continue
		// Now, we're gonna queue image generation out of those refs
		to_make += turf_item
		already_seen[turf_item] = OBJ_IMAGE_LOADING
		obj_window.RegisterSignal(turf_item, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/datum/object_window_info, viewing_atom_deleted), override = TRUE) // we reset cache if anything in it gets deleted
	turf_items["total"] = i
	obj_window.min_index = min_index
	obj_window.max_index = max_index
	if(length(to_make))
		START_PROCESSING(SSobj_tab_items, obj_window)
	return turf_items

#undef OBJ_IMAGE_LOADING

/datum/controller/subsystem/statpanels/proc/generate_mc_data()
	mc_data = list(
		list("CPU:", Master.formatcpu(world.cpu)),
		list("Map CPU:", Master.formatcpu(world.map_cpu)),
		list("Instances:", "[num2text(length(world.contents), 10)]"),
		list("World Time:", "[world.time]"),
		list("Server Time:", time_stamp()),
		list("Globals:", GLOB.stat_entry(), "[GLOB.UID()]"),
		list("Byond:", "(FPS:[world.fps]) (TickCount:[world.time / world.tick_lag]) (TickDrift:[round(Master.tickdrift, 1)]([round((Master.tickdrift / (world.time / world.tick_lag)) * 100, 0.1)]%)) (Internal Tick Usage: [round(MAPTICK_LAST_INTERNAL_TICK_USAGE, 0.1)]%)"),
		list("Master Controller:", Master.stat_entry(), "[Master.UID()]"),
		list("Failsafe Controller:", Failsafe.stat_entry(), "[Failsafe.UID()]"),
		list("","")
	)
	for(var/datum/controller/subsystem/sub_system as anything in Master.subsystems)
		mc_data[++mc_data.len] = list("\[[sub_system.state_letter()]][sub_system.name]", sub_system.stat_entry(), "[sub_system.UID()]")
	mc_data[++mc_data.len] = list("Camera Net", "Cameras: [length(GLOB.cameranet.cameras)] | Chunks: [length(GLOB.cameranet.chunks)]", "[GLOB.cameranet.UID()]")

///immediately update the active statpanel tab of the target client
/datum/controller/subsystem/statpanels/proc/immediate_send_stat_data(client/target)
	if(!target.stat_panel.is_ready())
		return FALSE

	if(target.stat_tab == "Status")
		set_status_tab(target)
		return TRUE

	var/mob/target_mob = target.mob
	if(target_mob?.listed_turf)
		if(!target_mob.TurfAdjacent(target_mob.listed_turf))
			target_mob.set_listed_turf(null)

		else if(target.stat_tab == target_mob?.listed_turf.name || !(target_mob?.listed_turf.name in target.panel_tabs))
			set_turf_examine_tab(target, target_mob)
			return TRUE

	if(!target.holder)
		return FALSE

	if(target.stat_tab == "MC")
		set_MC_tab(target)
		return TRUE

/// Stat panel window declaration, we don't usually allow this but tgui windows/panels are exceptions
/* check_grep:ignore */ /client/var/datum/tgui_window/stat_panel


/// Datum that holds and tracks info about a client's object window
/// Really only exists because I want to be able to do logic with signals
/// And need a safe place to do the registration
/datum/object_window_info
	/// list of atoms to show to our client via the object tab, at least currently
	var/list/atoms_to_show = list()
	/// list of atom -> image string for objects we have had in the right click tab
	/// this is our caching
	var/list/atoms_to_images = list()
	/// list of atoms to turn into images for the object tab
	var/list/atoms_to_imagify = list()
	/// Our owner client
	var/client/parent
	/// Are we currently tracking a turf?
	var/actively_tracking = FALSE
	/// The minimum index currently sent to the client.
	var/min_index = 0
	/// The maximum index currently sent to the client.
	var/max_index = 30

/datum/object_window_info/New(client/parent)
	. = ..()
	src.parent = parent

/datum/object_window_info/Destroy(force, ...)
	atoms_to_show = null
	atoms_to_images = null
	atoms_to_imagify = null
	parent.obj_window = null
	parent = null
	STOP_PROCESSING(SSobj_tab_items, src)
	return ..()

/// Takes a client, attempts to generate object images for it
/// We will update the client with any improvements we make when we're done
/datum/object_window_info/process(delta_time)
	// Cache the datum access for sonic speed
	var/list/to_make = atoms_to_imagify
	var/list/newly_seen = atoms_to_images
	var/index = 0
	for(index in 1 to length(to_make))
		var/atom/thing = to_make[index]

		var/generated_string
		if(ismob(thing) || length(thing.overlays) > 2)
			generated_string = costly_icon2asset(thing, parent)
		else
			generated_string = icon2asset(thing, parent, thing.icon_state)

		newly_seen[thing] = generated_string
		if(TICK_CHECK)
			to_make.Cut(1, index + 1)
			index = 0
			break
	// If we've not cut yet, do it now
	if(index)
		to_make.Cut(1, index + 1)
	SSstatpanels.refresh_client_obj_view(parent, min_index, max_index)
	if(!length(to_make))
		return PROCESS_KILL

/datum/object_window_info/proc/start_turf_tracking()
	if(actively_tracking)
		stop_turf_tracking()
	var/static/list/connections = list(
		COMSIG_MOVABLE_MOVED = PROC_REF(on_mob_move),
		COMSIG_MOB_LOGOUT = PROC_REF(on_mob_logout),
	)
	AddComponent(/datum/component/connect_mob_behalf, parent, connections)
	actively_tracking = TRUE

/datum/object_window_info/proc/stop_turf_tracking()
	DeleteComponent(/datum/component/connect_mob_behalf)
	actively_tracking = FALSE

/datum/object_window_info/proc/on_mob_move(mob/source)
	SIGNAL_HANDLER
	var/turf/listed = source.listed_turf
	if(!listed || !source.TurfAdjacent(listed))
		source.set_listed_turf(null)

/datum/object_window_info/proc/on_mob_logout(mob/source)
	SIGNAL_HANDLER
	on_mob_move(parent.mob)

/// Clears any cached object window stuff
/// We use hard refs cause we'd need a signal for this anyway. Cleaner this way
/datum/object_window_info/proc/viewing_atom_deleted(atom/deleted)
	SIGNAL_HANDLER
	atoms_to_show -= deleted
	atoms_to_imagify -= deleted
	atoms_to_images -= deleted

/mob/proc/set_listed_turf(turf/new_turf)
	listed_turf = new_turf
	if(!client)
		return
	if(!client.obj_window)
		client.obj_window = new(client)
	if(listed_turf)
		client.stat_panel.send_message("create_listedturf", listed_turf.name)
		client.obj_window.start_turf_tracking()
		client.obj_window.min_index = 0
		client.obj_window.max_index = 30
		SSstatpanels.set_turf_examine_tab(client, src)
	else
		client.stat_panel.send_message("remove_listedturf")
		client.obj_window.stop_turf_tracking()
