#define MIN_ZOOM 1
#define MAX_ZOOM 8
#define MIN_TAB_INDEX 0
#define MAX_TAB_INDEX 1

//Station Shield
// A chain of satellites encircles the station
// Satellites be actived to generate a shield that will block unorganic matter from passing it.
/datum/station_goal/station_shield
	name = "Station Shield"
	var/coverage_goal = 75
	var/last_coverage = 0
	var/is_testing = FALSE
	var/thrown = 0
	var/list/defended = list()
	var/list/collisions = list()

/datum/station_goal/station_shield/get_report()
	return {"<b>Station Shield construction</b><br>
	The station is located in a zone full of space debris. We have a prototype shielding system you will deploy to reduce collision related accidents.
	<br><br>
	You can order the satellites and control systems through the cargo shuttle."}

/datum/station_goal/station_shield/on_report()
	//Unlock
	var/datum/supply_packs/P = SSeconomy.supply_packs["[/datum/supply_packs/misc/station_goal/shield_sat]"]
	P.special_enabled = TRUE

	P = SSeconomy.supply_packs["[/datum/supply_packs/misc/station_goal/shield_sat_control]"]
	P.special_enabled = TRUE

/datum/station_goal/station_shield/check_completion()
	if(..())
		return TRUE
	return last_coverage >= coverage_goal

/datum/station_goal/station_shield/proc/update_coverage(success, turf/where)
	if(success)
		defended += list(list("x" = where.x, "y" = where.y))
	else
		collisions += list(list("x" = where.x, "y" = where.y))
	if(length(defended) > last_coverage)
		last_coverage = length(defended)
	if(length(defended) + length(collisions) >= 100)
		last_coverage = length(defended)
		is_testing = FALSE

/datum/station_goal/station_shield/proc/simulate_meteors()
	if(is_testing)
		return FALSE
	is_testing = TRUE
	thrown = 0
	defended = list()
	collisions = list()
	START_PROCESSING(SSprocessing, src)

/datum/station_goal/station_shield/process()
	spawn_meteor(list(/obj/effect/meteor/fake = 1))
	thrown++
	if(thrown >= 100)
		return PROCESS_KILL

/obj/item/circuitboard/computer/sat_control
	board_name = "Satellite Network Control"
	build_path = /obj/machinery/computer/sat_control
	origin_tech = "engineering=3"

/obj/machinery/computer/sat_control
	name = "Satellite control"
	desc = "Used to control the satellite network."
	circuit = /obj/item/circuitboard/computer/sat_control
	icon_screen = "accelerator"
	icon_keyboard = "rd_key"
	/// A notice to display to the user.
	var/notice = ""
	/// The color to use for the notice.
	var/notice_color = "white"
	/// Before world.time reaches this, the notice will not automatically update to show the testing status.
	var/freeze_notice_until = 0
	/// The X offset of the UI map
	var/offset_x = 0
	/// The Y offset of the UI map
	var/offset_y = 0
	/// The zoom of the UI map
	var/zoom = 1
	/// The ID of the currently opened UI tab
	var/tab_index = 0

/obj/machinery/computer/sat_control/attack_hand(mob/user)
	if(..())
		return 1
	ui_interact(user)

/obj/machinery/computer/sat_control/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/sat_control/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SatelliteControl", name)
		ui.open()

/obj/machinery/computer/sat_control/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/nanomaps)
	)

/obj/machinery/computer/sat_control/ui_data(mob/user)
	var/list/data = list()

	data["satellites"] = list()
	for(var/obj/machinery/satellite/S in SSmachines.get_by_type(/obj/machinery/satellite))
		var/turf/T = get_turf(S)
		data["satellites"] += list(list(
			"id" = S.id,
			"active" = S.active,
			"mode" = S.mode,
			"x" = T.x,
			"y" = T.y
		))
	update_notice()
	data["notice"] = notice
	data["notice_color"] = notice_color
	data["zoom"] = zoom
	data["offsetX"] = offset_x
	data["offsetY"] = offset_y
	data["tabIndex"] = tab_index

	var/datum/station_goal/station_shield/G = locate() in SSticker.mode?.station_goals
	if(G)
		data["has_goal"] = 1
		data["coverage"] = G.last_coverage
		data["coverage_goal"] = G.coverage_goal
		data["testing"] = G.is_testing
		data["thrown"] = G.thrown
		data["defended"] = G.defended
		data["collisions"] = G.collisions
		var/list/fake_meteors = list()
		if(G.is_testing)
			for(var/obj/effect/meteor/fake/meteor in GLOB.meteor_list)
				fake_meteors += list(list("x" = meteor.x, "y" = meteor.y))
		data["fake_meteors"] = fake_meteors
	return data

/obj/machinery/computer/sat_control/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("begin_test")
			var/datum/station_goal/station_shield/G = locate() in SSticker.mode?.station_goals
			if(G)
				G.simulate_meteors()
		if("toggle")
			toggle(text2num(params["id"]))
			. = TRUE
		if("set_tab_index")
			var/new_tab_index = text2num(params["tab_index"])
			if(isnull(new_tab_index) || new_tab_index < MIN_TAB_INDEX || new_tab_index > MAX_TAB_INDEX)
				return
			tab_index = new_tab_index
		if("set_zoom")
			var/new_zoom = text2num(params["zoom"])
			if(isnull(new_zoom) || new_zoom < MIN_ZOOM || new_zoom > MAX_ZOOM)
				return
			zoom = new_zoom
		if("set_offset")
			var/new_offset_x = text2num(params["offset_x"])
			var/new_offset_y = text2num(params["offset_y"])
			if(isnull(new_offset_x) || isnull(new_offset_y))
				return
			offset_x = new_offset_x
			offset_y = new_offset_y

/obj/machinery/computer/sat_control/proc/toggle(id)
	for(var/obj/machinery/satellite/S in SSmachines.get_by_type(/obj/machinery/satellite))
		if(S.id == id && atoms_share_level(src, S))
			if(!S.toggle())
				notice = "You can only activate satellites which are in space"
				notice_color = "red"
				freeze_notice_until = world.time + 5 SECONDS

/obj/machinery/computer/sat_control/proc/update_notice()
	var/datum/station_goal/station_shield/G = locate() in SSticker.mode?.station_goals
	if(!G)
		return
	if(freeze_notice_until >= world.time)
		return

	if(G.is_testing && G.thrown < 100)
		notice = "Throwing simulated meteors ([G.thrown]/100)..."
		notice_color = "white"
		return

	var/total_meteors = length(G.defended) + length(G.collisions)
	if(total_meteors == 0)
		notice = "No simulation yet."
		notice_color = "red"
		return

	if(G.is_testing)
		notice = "Waiting for simulated meteors ([total_meteors]/100)..."
		notice_color = "white"
		return

	notice = "Test complete. [100 - G.last_coverage] collisions out of 100 meteors."
	notice_color = (G.last_coverage > G.coverage_goal) ? "blue" : "red"

/obj/machinery/satellite
	name = "Defunct Satellite"
	desc = ""
	icon = 'icons/obj/machines/satellite.dmi'
	icon_state = "sat_inactive"
	var/mode = "NTPROBEV0.8"
	var/active = FALSE
	density = TRUE
	power_state = NO_POWER_USE
	var/static/gid = 0
	var/id = 0

/obj/machinery/satellite/Initialize(mapload)
	. = ..()
	id = gid++

/obj/machinery/satellite/attack_hand(mob/user)
	if(..())
		return 1
	interact(user)

/obj/machinery/satellite/interact(mob/user)
	toggle(user)

/obj/machinery/satellite/proc/toggle(mob/user)
	if(!active && !isinspace())
		if(user)
			to_chat(user, "<span class='warning'>You can only activate satellites which are in space.</span>")
		return FALSE
	if(user)
		to_chat(user, "<span class='notice'>You [active ? "deactivate": "activate"] [src]</span>")
	active = !active
	if(active)
		animate(src, pixel_y = 2, time = 10, loop = -1)
		anchored = TRUE
	else
		animate(src, pixel_y = 0, time = 10)
		anchored = FALSE
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/satellite/update_icon_state()
	icon_state = active ? "sat_active" : "sat_inactive"

/obj/machinery/satellite/multitool_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>// NTSAT-[id] // Mode : [active ? "PRIMARY" : "STANDBY"] //[emagged ? "DEBUG_MODE //" : ""]</span>")

/obj/machinery/satellite/meteor_shield
	name = "Meteor Shield Satellite"
	desc = "Meteor Point Defense Satellite."
	mode = "M-SHIELD"
	speed_process = TRUE
	var/kill_range = 14

/obj/machinery/satellite/meteor_shield/proc/space_los(meteor)
	for(var/turf/T in get_line(src,meteor))
		if(!isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/satellite/meteor_shield/process()
	if(!active)
		return
	for(var/obj/effect/M in GLOB.meteor_list)
		if(M.z != z)
			continue
		if(get_dist(M, src) > kill_range)
			continue
		var/is_fake = istype(M, /obj/effect/meteor/fake)
		if((!emagged || is_fake) && space_los(M))
			if(!is_fake)
				Beam(get_turf(M), icon_state = "sat_beam", time = 5, maxdistance = kill_range)
				if(istype(M, /obj/effect/space_dust/meaty))
					new /obj/item/food/meatsteak(get_turf(M))
			qdel(M)

/obj/machinery/satellite/meteor_shield/toggle(user)
	if(..(user))
		return TRUE
	if(emagged)
		if(active)
			change_meteor_chance(2)
		else
			change_meteor_chance(0.5)

/obj/machinery/satellite/meteor_shield/proc/change_meteor_chance(mod)
	for(var/datum/event_container/container in SSevents.event_containers)
		for(var/datum/event_meta/M in container.available_events)
			if(M.event_type == /datum/event/meteor_wave)
				M.weight_mod *= mod

/obj/machinery/satellite/meteor_shield/Destroy()
	. = ..()
	if(active && emagged)
		change_meteor_chance(0.5)

/obj/machinery/satellite/meteor_shield/emag_act(mob/user)
	if(!emagged)
		to_chat(user, "<span class='danger'>You override the shield's circuits, causing it to attract meteors instead of destroying them.</span>")
		emagged = TRUE
		if(active)
			change_meteor_chance(2)
		return TRUE

#undef MIN_ZOOM
#undef MAX_ZOOM
#undef MIN_TAB_INDEX
#undef MAX_TAB_INDEX
