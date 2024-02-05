SUBSYSTEM_DEF(statpanels)
	name = "Stat Panels"
	wait = 4
	init_order = INIT_ORDER_STATPANELS
	flags = SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	var/list/currentrun = list()
	var/encoded_global_data
	var/mc_data_encoded
	var/list/cached_images = list()

/datum/controller/subsystem/statpanels/fire(resumed = FALSE)
	if(!resumed)
		var/datum/map/cached = SSmapping.next_map
		var/round_time = world.time - SSticker.round_start_time
		var/list/global_data = list(
			"Map: [SSmapping.map_datum?.fluff_name || "Loading..."]",
			cached ? "Next Map: [cached.fluff_name]" : null,
			"Round ID: [GLOB.round_id ? GLOB.round_id : "NULL"]",
			"Server Time: [time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")]",
			"Round Time: [round_time > MIDNIGHT_ROLLOVER ? "[round(round_time/MIDNIGHT_ROLLOVER)]:[worldtime2text()]" : worldtime2text()]",
			"Station Time: [station_time_timestamp()]",
			"Time Dilation: [round(SStime_track.time_dilation_current,1)]% AVG:([round(SStime_track.time_dilation_avg_fast,1)]%, [round(SStime_track.time_dilation_avg,1)]%, [round(SStime_track.time_dilation_avg_slow,1)]%)"
		)

		if(SSshuttle.emergency)
			var/ETA = SSshuttle.emergency.getModeStr()
			if(ETA)
				global_data += "[ETA] [SSshuttle.emergency.getTimerStr()]"
		encoded_global_data = url_encode(json_encode(global_data))
		src.currentrun = GLOB.clients.Copy()
		mc_data_encoded = null

	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/client/target = currentrun[length(currentrun)]
		currentrun.len--
		if(!target.statbrowser_ready)
			continue
		if(target.stat_tab == "Status")
			var/other_str = url_encode(json_encode(target.mob.get_status_tab_items()))
			target << output("[encoded_global_data];[other_str]", "statbrowser:update")
		if(!target.holder)
			target << output("", "statbrowser:remove_admin_tabs")
		else
			if(!("MC" in target.panel_tabs) || !("Tickets" in target.panel_tabs))
				target << output("[url_encode(target.holder.href_token)]", "statbrowser:add_admin_tabs")
			if(target.stat_tab == "MC")
				var/turf/eye_turf = get_turf(target.eye)
				var/coord_entry = url_encode(COORD(eye_turf))
				if(!mc_data_encoded)
					generate_mc_data()
				target << output("[mc_data_encoded];[coord_entry]", "statbrowser:update_mc")
		if(target.mob)
			var/mob/M = target.mob
			if(M?.listed_turf)
				var/mob/target_mob = M
				if(!target_mob.TurfAdjacent(target_mob.listed_turf))
					target << output("", "statbrowser:remove_listedturf")
					target_mob.listed_turf = null
				else if(target.stat_tab == M?.listed_turf.name || !(M?.listed_turf.name in target.panel_tabs))
					var/list/overrides = list()
					var/list/turfitems = list()
					for(var/img in target.images)
						var/image/target_image = img
						if(!target_image.loc || target_image.loc.loc != target_mob.listed_turf || !target_image.override)
							continue
						overrides += target_image.loc
					turfitems[++turfitems.len] = list("[target_mob.listed_turf]", target_mob.listed_turf.UID(), icon2html(target_mob.listed_turf, target, sourceonly=TRUE))
					for(var/tc in target_mob.listed_turf)
						var/atom/movable/turf_content = tc
						if(turf_content.mouse_opacity == MOUSE_OPACITY_TRANSPARENT)
							continue
						if(turf_content.invisibility > target_mob.see_invisible)
							continue
						if(turf_content in overrides)
							continue
						if(turf_content.IsObscured())
							continue
						if(length(turfitems) < 30) // only create images for the first 30 items on the turf, for performance reasons
							if(!(turf_content.UID() in cached_images))
								cached_images += turf_content.UID()
								turf_content.RegisterSignal(turf_content, COMSIG_PARENT_QDELETING, /atom/.proc/remove_from_cache) // we reset cache if anything in it gets deleted
								if(ismob(turf_content) || length(turf_content.overlays) > 2)
									turfitems[++turfitems.len] = list("[turf_content.name]", turf_content.UID(), costly_icon2html(turf_content, target, sourceonly=TRUE))
								else
									turfitems[++turfitems.len] = list("[turf_content.name]", turf_content.UID(), icon2html(turf_content, target, sourceonly=TRUE))
							else
								turfitems[++turfitems.len] = list("[turf_content.name]", turf_content.UID())
						else
							turfitems[++turfitems.len] = list("[turf_content.name]", turf_content.UID())
					turfitems = url_encode(json_encode(turfitems))
					target << output("[turfitems];", "statbrowser:update_listedturf")
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/statpanels/proc/generate_mc_data()
	var/list/mc_data = list(
		list("CPU:", world.cpu),
		list("Instances:", "[num2text(world.contents.len, 10)]"),
		list("World Time:", "[world.time]"),
		list("Globals:", GLOB.stat_entry(), "[GLOB.UID()]"),
		list("Byond:", "(FPS:[world.fps]) (TickCount:[world.time/world.tick_lag]) (TickDrift:[round(Master.tickdrift,1)]([round((Master.tickdrift/(world.time/world.tick_lag))*100,0.1)]%)) (Internal Tick Usage: [round(MAPTICK_LAST_INTERNAL_TICK_USAGE,0.1)]%)"),
		list("Master Controller:", Master.stat_entry(), "[Master.UID()]"),
		list("Failsafe Controller:", Failsafe.stat_entry(), "[Failsafe.UID()]"),
		list("","")
	)
	for(var/ss in Master.subsystems)
		var/datum/controller/subsystem/sub_system = ss
		mc_data[++mc_data.len] = list("\[[sub_system.state_letter()]][sub_system.name]", sub_system.stat_entry(), "[sub_system.UID()]")
	mc_data[++mc_data.len] = list("Camera Net", "Cameras: [GLOB.cameranet.cameras.len] | Chunks: [GLOB.cameranet.chunks.len]", "[GLOB.cameranet.UID()]")
	mc_data_encoded = url_encode(json_encode(mc_data))

/atom/proc/remove_from_cache()
	SSstatpanels.cached_images -= UID()

/// verbs that send information from the browser UI
/client/verb/set_tab(tab as text|null)
	set name = "Set Tab"
	set hidden = TRUE

	stat_tab = tab

/client/verb/send_tabs(tabs as text|null)
	set name = "Send Tabs"
	set hidden = TRUE

	panel_tabs |= tabs

/client/verb/remove_tabs(tabs as text|null)
	set name = "Remove Tabs"
	set hidden = TRUE

	panel_tabs -= tabs

/client/verb/reset_tabs()
	set name = "Reset Tabs"
	set hidden = TRUE

	panel_tabs = list()

/client/verb/panel_ready()
	set name = "Panel Ready"
	set hidden = TRUE

	statbrowser_ready = TRUE
