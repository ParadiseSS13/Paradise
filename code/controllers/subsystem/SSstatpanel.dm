SUBSYSTEM_DEF(statpanels)
	name = "Stat Panels"
	wait = 4
	init_order = INIT_ORDER_STATPANELS
	priority = FIRE_PRIORITY_STATPANEL
	flags = SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	var/list/currentrun = list()
	var/list/global_data
	var/list/mc_data
	var/list/cached_images = list()

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
		var/round_time = world.time - SSticker.round_start_time
		global_data = list(
			"Map: [SSmapping.map_datum?.fluff_name || "Loading..."]",
			cached ? "Next Map: [cached.fluff_name]" : null,
			"Round ID: [GLOB.round_id ? GLOB.round_id : "NULL"]",
			"Server Time: [time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")]",
			"Round Time: [round_time > MIDNIGHT_ROLLOVER ? "[round(round_time / MIDNIGHT_ROLLOVER)]:[worldtime2text()]" : worldtime2text()]",
			"Station Time: [station_time_timestamp()]",
			"Time Dilation: [round(SStime_track.time_dilation_current, 1)]% AVG:([round(SStime_track.time_dilation_avg_fast, 1)]%, [round(SStime_track.time_dilation_avg, 1)]%, [round(SStime_track.time_dilation_avg_slow, 1)]%)"
		)

		if(SSshuttle.emergency)
			var/ETA = SSshuttle.emergency.getModeStr()
			if(ETA)
				global_data += "[ETA] [SSshuttle.emergency.getTimerStr()]"
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

		if(!target.holder)
			target.stat_panel.send_message("remove_admin_tabs")
		else
			if(!("MC" in target.panel_tabs))
				target.stat_panel.send_message("add_admin_tabs", target.holder.href_token)

			if(target.stat_tab == "MC" && ((num_fires % mc_wait == 0)))
				set_MC_tab(target)

		if(target.mob)
			var/mob/target_mob = target.mob
			if(target_mob?.listed_turf && num_fires % default_wait == 0)
				if(!target_mob.TurfAdjacent(target_mob.listed_turf) || isnull(target_mob.listed_turf))
					target.stat_panel.send_message("remove_listedturf")
					target_mob.listed_turf = null

				else if(target.stat_tab == target_mob?.listed_turf.name || !(target_mob?.listed_turf.name in target.panel_tabs))
					set_turf_examine_tab(target, target_mob)

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/statpanels/proc/set_status_tab(client/target)
	if(!global_data) //statbrowser hasnt fired yet and we were called from immediate_send_stat_data()
		return

	target.stat_panel.send_message("update_stat", list(
		global_data = global_data,
		other_str = target.mob?.get_status_tab_items(),
	))

/datum/controller/subsystem/statpanels/proc/set_MC_tab(client/target)
	var/turf/eye_turf = get_turf(target.eye)
	var/coord_entry = COORD(eye_turf)
	if(!mc_data)
		generate_mc_data()
	target.stat_panel.send_message("update_mc", list(mc_data = mc_data, coord_entry = coord_entry))

/datum/controller/subsystem/statpanels/proc/set_turf_examine_tab(client/target, mob/target_mob)
	var/list/overrides = list()
	var/list/turfitems = list()
	for(var/image/target_image as anything in target.images)
		if(!target_image.loc || target_image.loc.loc != target_mob.listed_turf || !target_image.override)
			continue
		overrides += target_image.loc

	turfitems[++turfitems.len] = list("[target_mob.listed_turf]", target_mob.listed_turf.UID(), icon2html(target_mob.listed_turf, target, sourceonly=TRUE))

	for(var/atom/movable/turf_content as anything in target_mob.listed_turf)
		if(turf_content.mouse_opacity == MOUSE_OPACITY_TRANSPARENT)
			continue
		if(turf_content.invisibility > target_mob.see_invisible)
			continue
		if(turf_content in overrides)
			continue
		if(turf_content.IsObscured())
			continue

		var/turf_content_ref = turf_content.UID()
		if(length(turfitems) < 10) // only create images for the first 10 items on the turf, for performance reasons
			if(!(turf_content_ref in cached_images))
				cached_images += turf_content_ref
				turf_content.RegisterSignal(turf_content, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/atom, remove_from_cache)) // we reset cache if anything in it gets deleted

				if(ismob(turf_content) || length(turf_content.overlays) > 2)
					turfitems[++turfitems.len] = list("[turf_content.name]", turf_content_ref, costly_icon2html(turf_content, target, sourceonly=TRUE))
				else
					turfitems[++turfitems.len] = list("[turf_content.name]", turf_content_ref, icon2html(turf_content, target, sourceonly=TRUE))
			else
				turfitems[++turfitems.len] = list("[turf_content.name]", turf_content_ref)
		else
			turfitems[++turfitems.len] = list("[turf_content.name]", turf_content_ref)

	turfitems = turfitems
	target.stat_panel.send_message("update_listedturf", turfitems)

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
			target.stat_panel.send_message("removed_listedturf")
			target_mob.listed_turf = null

		else if(target.stat_tab == target_mob?.listed_turf.name || !(target_mob?.listed_turf.name in target.panel_tabs))
			set_turf_examine_tab(target, target_mob)
			return TRUE

	if(!target.holder)
		return FALSE

	if(target.stat_tab == "MC")
		set_MC_tab(target)
		return TRUE

/atom/proc/remove_from_cache()
	SIGNAL_HANDLER
	SSstatpanels.cached_images -= UID()

/// Stat panel window declaration
/client/var/datum/tgui_window/stat_panel
