//Station Shield
// A chain of satellites encircles the station
// Satellites be actived to generate a shield that will block unorganic matter from passing it.
/datum/station_goal/station_shield
	name = "Station Shield"
	var/coverage_goal = 5000

/datum/station_goal/station_shield/get_report()
	return {"<b>Station Shield construction</b><br>
	The station is located in a zone full of space debris. We have a prototype shielding system you will deploy to reduce collision related accidents.
	<br><br>
	You can order the satellites and control systems through the cargo shuttle."}

/datum/station_goal/station_shield/on_report()
	//Unlock
	var/datum/supply_packs/P = SSshuttle.supply_packs["[/datum/supply_packs/misc/shield_sat]"]
	P.special_enabled = TRUE

	P = SSshuttle.supply_packs["[/datum/supply_packs/misc/shield_sat_control]"]
	P.special_enabled = TRUE

/datum/station_goal/station_shield/check_completion()
	if(..())
		return TRUE
	if(get_coverage() >= coverage_goal)
		return TRUE
	return FALSE

/datum/station_goal/proc/get_coverage()
	var/list/coverage = list()
	for(var/obj/machinery/satellite/meteor_shield/A in GLOB.machines)
		if(!A.active || !is_station_level(A.z))
			continue
		coverage |= view(A.kill_range, A)
	return coverage.len

/obj/item/circuitboard/computer/sat_control
	name = "Satellite Network Control (Computer Board)"
	build_path = /obj/machinery/computer/sat_control
	origin_tech = "engineering=3"

/obj/machinery/computer/sat_control
	name = "Satellite control"
	desc = "Used to control the satellite network."
	circuit = /obj/item/circuitboard/computer/sat_control
	icon_screen = "accelerator"
	icon_keyboard = "accelerator_key"
	var/notice

/obj/machinery/computer/sat_control/attack_hand(mob/user)
	if(..())
		return 1
	ui_interact(user)

/obj/machinery/computer/sat_control/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "sat_control.tmpl", name, 475, 400)
		ui.open()

/obj/machinery/computer/sat_control/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["toggle"])
		toggle(text2num(href_list["id"]))
		. = TRUE

/obj/machinery/computer/sat_control/proc/toggle(id)
	for(var/obj/machinery/satellite/S in GLOB.machines)
		if(S.id == id && atoms_share_level(src, S))
			S.toggle()

/obj/machinery/computer/sat_control/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/list/data = list()

	data["satellites"] = list()
	for(var/obj/machinery/satellite/S in GLOB.machines)
		data["satellites"] += list(list(
			"id" = S.id,
			"active" = S.active,
			"mode" = S.mode
		))
	data["notice"] = notice

	var/datum/station_goal/station_shield/G = locate() in SSticker.mode.station_goals
	if(G)
		data["meteor_shield"] = 1
		data["meteor_shield_coverage"] = G.get_coverage()
		data["meteor_shield_coverage_max"] = G.coverage_goal
		data["meteor_shield_coverage_percentage"] = (G.get_coverage() / G.coverage_goal) * 100
	return data

/obj/machinery/satellite
	name = "Defunct Satellite"
	desc = ""
	icon = 'icons/obj/machines/satellite.dmi'
	icon_state = "sat_inactive"
	var/mode = "NTPROBEV0.8"
	var/active = FALSE
	density = 1
	use_power = FALSE
	var/static/gid = 0
	var/id = 0

/obj/machinery/satellite/New()
	..()
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
			to_chat(user, "<span class='warning'>You can only active the [src] in space.</span>")
		return TRUE
	if(user)
		to_chat(user, "<span class='notice'>You [active ? "deactivate": "activate"] the [src]</span>")
	active = !active
	if(active)
		animate(src, pixel_y = 2, time = 10, loop = -1)
		anchored = 1
	else
		animate(src, pixel_y = 0, time = 10)
		anchored = 0
	update_icon()

/obj/machinery/satellite/update_icon()
	icon_state = active ? "sat_active" : "sat_inactive"

/obj/machinery/satellite/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/multitool))
		to_chat(user, "<span class='notice'>// NTSAT-[id] // Mode : [active ? "PRIMARY" : "STANDBY"] //[emagged ? "DEBUG_MODE //" : ""]</span>")
	else
		return ..()

/obj/machinery/satellite/meteor_shield
	name = "Meteor Shield Satellite"
	desc = "Meteor Point Defense Satellite"
	mode = "M-SHIELD"
	speed_process = TRUE
	var/kill_range = 14

/obj/machinery/satellite/meteor_shield/proc/space_los(meteor)
	for(var/turf/T in getline(src,meteor))
		if(!isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/satellite/meteor_shield/process()
	if(!active)
		return
	for(var/obj/effect/meteor/M in GLOB.meteor_list)
		if(M.z != z)
			continue
		if(get_dist(M, src) > kill_range)
			continue
		if(!emagged && space_los(M))
			Beam(get_turf(M), icon_state = "sat_beam", time = 5, maxdistance = kill_range)
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
				M.weight *= mod

/obj/machinery/satellite/meteor_shield/Destroy()
	. = ..()
	if(active && emagged)
		change_meteor_chance(0.5)

/obj/machinery/satellite/meteor_shield/emag_act(mob/user)
	if(!emagged)
		to_chat(user, "<span class='danger'>You override the shield's circuits, causing it to attract meteors instead of destroying them.</span>")
		emagged = 1
		if(active)
			change_meteor_chance(2)
