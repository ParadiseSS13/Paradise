#define DATA_RECORD_RIFT_ID 1
#define DATA_RECORD_GOAL_POINTS 2
#define DATA_RECORD_PROBE_POINTS 3
#define DATA_RECORD_TIMES_RIFT_SCANNED 4
#define DATA_RECORD_MINED_GOAL_POINTS 5
#define DATA_RECORD_MINED_PROBE_POINTS 6
#define DATA_RECORD_LENGTH 6

/obj/item/circuitboard/brs_server
	name = "Сервер сканирирования разлома (Computer Board)"
	desc = "Плата сервера сканирования и изучения блюспейс разлома."
	build_path = /obj/machinery/brs_server
	icon_state = "cpuboard_super"
	board_type = "machine"
	origin_tech = "engineering=4;bluespace=3"
	req_components = list(
		/obj/item/stack/sheet/metal = 10,
		/obj/item/stack/sheet/glass = 5,
		/obj/item/stock_parts/capacitor/super = 10,
		/obj/item/stock_parts/scanning_module/phasic = 2,
		/obj/item/stack/cable_coil = 20
	)

/obj/machinery/brs_server
	name = "Сервер сканирования блюспейс разлома"
	icon = 'icons/obj/machines/BRS/scanner_server.dmi'
	icon_state = "scan_server"
	anchored = TRUE
	density = TRUE
	luminosity = 1
	max_integrity = 350
	integrity_failure = 150

	use_power = IDLE_POWER_USE
	idle_power_usage = 4000
	active_power_usage = 12000

	/// One probe price
	var/points_per_probe = 1500
	/// One probe price if the server is emagged
	var/points_per_probe_emagged = 500
	/// 0 <= chance <= 1, 0-never, 1-always
	var/probe_success_chance = 0.5
	///	0 <= chance <= 1, 0-never, 1-always
	var/probe_success_chance_emagged = 0.2

	/// Minimal time delay between probes
	var/probe_cooldown_time = 15 SECONDS
	/// World time when probe cooldown ends
	var/probe_cooldown_end_time = 0

	var/research_points_on_probe_success = 100

	/// Keeps goal points and probe points.
	/// Goal points - needed to complete the station goal.
	/// Probe points - needed to "probe" a rift.
	var/list/data

	/// Needed for users to distinguish between servers
	var/id

/obj/machinery/brs_server/Initialize(mapload)
	. = ..()

	// init data list
	data = list()
	for(var/datum/station_goal/bluespace_rift/goal in SSticker.mode.station_goals)
		var/record = get_record(goal.UID())
		data[record][DATA_RECORD_GOAL_POINTS] = goal.get_current_research_points()

	// Assign an id
	var/list/existing_ids = list()
	for(var/obj/machinery/brs_server/server as anything in GLOB.bluespace_rifts_server_list)
		existing_ids += server.id
	for(var/possible_id in 1 to length(existing_ids))
		if(!(possible_id in existing_ids))
			id = possible_id
	if(!id)
		id = length(existing_ids) + 1
	name = "[name] \[#[id]\]"

	GLOB.bluespace_rifts_server_list.Add(src)
	GLOB.poi_list |= src

	probe_cooldown_end_time = world.time + probe_cooldown_time

	new_component_parts()
	update_icon()

/obj/machinery/brs_server/Destroy()
	GLOB.bluespace_rifts_server_list.Remove(src)
	GLOB.poi_list.Remove(src)
	return ..()

/obj/machinery/brs_server/process()
	for(var/list/record in data)
		if(record[DATA_RECORD_TIMES_RIFT_SCANNED] == 0)
			continue
		
		record[DATA_RECORD_GOAL_POINTS] += record[DATA_RECORD_MINED_GOAL_POINTS] * (1 + log(record[DATA_RECORD_TIMES_RIFT_SCANNED]))
		record[DATA_RECORD_PROBE_POINTS] += record[DATA_RECORD_MINED_PROBE_POINTS] * (1 + log(record[DATA_RECORD_TIMES_RIFT_SCANNED]))

		record[DATA_RECORD_TIMES_RIFT_SCANNED] = 0
		record[DATA_RECORD_MINED_GOAL_POINTS] = 0
		record[DATA_RECORD_MINED_PROBE_POINTS] = 0

/** Points mined by scanners shoud be added by this proc. */
/obj/machinery/brs_server/proc/add_points(rift_id, added_research_points, added_probe_points)
	var/record = get_record(rift_id)
	data[record][DATA_RECORD_TIMES_RIFT_SCANNED] += 1
	data[record][DATA_RECORD_MINED_GOAL_POINTS] += added_research_points
	data[record][DATA_RECORD_MINED_PROBE_POINTS] += added_probe_points

/** Removes rift record from `data` */
/obj/machinery/brs_server/proc/remove_rift_data(rift_id)
	var/index = get_record(rift_id)
	data.Cut(index, index + 1)

/** Returns goal points amount for a particular goal. */
/obj/machinery/brs_server/proc/get_goal_points(rift_id)
	var/record = get_record(rift_id)
	return data[record][DATA_RECORD_GOAL_POINTS]

/** Returns the index of the rift record in `data`. Creates a new record if there is no such `rift_id` in `data`. */
/obj/machinery/brs_server/proc/get_record(rift_id)

	// Search for that record
	for(var/record in 1 to length(data))
		if(data[record][DATA_RECORD_RIFT_ID] == rift_id)
			return record

	// Add a new record if not found
	var/list/new_record[DATA_RECORD_LENGTH]

	new_record[DATA_RECORD_RIFT_ID] = rift_id
	new_record[DATA_RECORD_GOAL_POINTS] = 0
	new_record[DATA_RECORD_PROBE_POINTS] = 0

	new_record[DATA_RECORD_TIMES_RIFT_SCANNED] = 0
	new_record[DATA_RECORD_MINED_GOAL_POINTS] = 0
	new_record[DATA_RECORD_MINED_PROBE_POINTS] = 0

	data += list(new_record)
	// Return index of the last element
	return length(data)

/obj/machinery/brs_server/update_icon()
	var/prefix = initial(icon_state)

	overlays.Cut()
	if(panel_open)
		overlays += image(icon, "[initial(icon_state)]-panel")

	if(stat & (BROKEN))
		icon_state = "[prefix]-broken"
		set_light(0)
		return
	if(stat & (NOPOWER))
		icon_state = prefix
		set_light(0)
		return
	if(emagged)
		icon_state = "[prefix]-on-emagged"
		set_light(l_range = 1, l_power = 1, l_color = COLOR_RED_LIGHT)
		return
	icon_state = "[prefix]-on"
	set_light(l_range = 1, l_power = 1, l_color = COLOR_BLUE_LIGHT)

/obj/machinery/brs_server/power_change()
	..()
	update_icon()

/obj/machinery/brs_server/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, 80)

/obj/machinery/brs_server/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	update_icon()

/obj/machinery/brs_server/crowbar_act(mob/living/user, obj/item/I)
	if((!panel_open) || (flags & NODECONSTRUCT))
		return FALSE
	. = TRUE

	// Add a delay, as server's points will be lost after disassembly
	user.visible_message("[user] начина[pluralize_ru(user.gender, "ет", "ют")] разбирать [src].", "Вы начинаете разбирать [src].")
	if(!I.use_tool(src, user, 8 SECONDS, volume = I.tool_volume))
		return

	default_deconstruction_crowbar(user, I)

/obj/machinery/brs_server/welder_act(mob/user, obj/item/I)
	. = TRUE
	default_welder_repair(user, I)

/obj/machinery/brs_server/proc/new_component_parts()
	component_parts = list()

	component_parts += new /obj/item/circuitboard/brs_server(null)
	
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)

	for(var/i in 1 to 10)
		component_parts += new /obj/item/stock_parts/capacitor/super(null)

	component_parts += new /obj/item/stack/sheet/metal(null, 10)
	component_parts += new /obj/item/stack/sheet/glass(null, 5)
	component_parts += new /obj/item/stack/cable_coil(null, 20)

	RefreshParts()

/obj/machinery/brs_server/emag_act(mob/user)
	if(emagged)
		return
	emagged = TRUE
	points_per_probe = points_per_probe_emagged
	probe_success_chance = probe_success_chance_emagged
	playsound(loc, 'sound/effects/sparks4.ogg', 60, TRUE)
	update_icon()
	to_chat(user, span_warning("@?%!№@Протоколы безопасности сканнера перезаписаны@?%!№@"))

/obj/machinery/brs_server/emp_act(severity)
	if(!(stat & (BROKEN|NOPOWER)))
		flick_active()
	return ..()

/obj/machinery/brs_server/proc/flick_active()
	if(stat & (BROKEN|NOPOWER))
		return
	var/prefix = initial(icon_state)
	if(emagged)
		flick("[prefix]-act-emagged", src)
	else
		flick("[prefix]-act", src)

/obj/machinery/brs_server/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/brs_server/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/brs_server/attack_hand(mob/user)
	if(..())
		return TRUE
	
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	ui_interact(user)

/obj/machinery/brs_server/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BluespaceRiftServer", name, 570, 400)
		ui.open()

/obj/machinery/brs_server/ui_data(mob/user)
	var/list/uidata = list()

	uidata["pointsPerProbe"] = points_per_probe
	uidata["emagged"] = emagged

	var/cooldown_ends_in = (probe_cooldown_end_time > world.time) ? (probe_cooldown_end_time - world.time) : 0
	uidata["cooldown"] = cooldown_ends_in / (1 SECONDS)

	uidata["goals"] = list()
	for(var/datum/station_goal/bluespace_rift/goal in SSticker.mode.station_goals)
		var/rift_id = goal.UID()
		var/record = get_record(rift_id)
		uidata["goals"] += list(list(
			"riftId" = rift_id,
			"riftName" = goal.rift ? goal.rift.name : "Unknown",
			"targetResearchPoints" = goal.target_research_points,
			"rewardGiven" = goal.reward_given,
			"researchPoints" = data[record][DATA_RECORD_GOAL_POINTS],
			"probePoints" = data[record][DATA_RECORD_PROBE_POINTS],
		))

	uidata["scanners"] = list()
	for(var/obj/machinery/power/brs_stationary_scanner/scanner in GLOB.bluespace_rifts_scanner_list)
		if(scanner.stat & (BROKEN|NOPOWER))
			continue
		if(!scanner.cable_powered)
			continue
		uidata["scanners"] += list(list(
			"scannerId" = scanner.UID(),
			"scannerName" = scanner.name,
			"scanStatus" = scanner.scanning_status,
			"canSwitch" = 1,
			"switching" = scanner.switching,
		))
	for(var/obj/machinery/brs_portable_scanner/scanner in GLOB.bluespace_rifts_scanner_list)
		if(scanner.stat & (BROKEN|NOPOWER))
			continue
		uidata["scanners"] += list(list(
			"scannerName" = scanner.name,
			"scanStatus" = scanner.scanning_status,
			"canSwitch" = 0,
			"switching" = scanner.switching,
		))

	uidata["servers"] = list()
	for(var/obj/machinery/brs_server/server in GLOB.bluespace_rifts_server_list)
		if(server.stat & (BROKEN|NOPOWER))
			continue

		var/list/server_probe_points = list()
		for(var/datum/station_goal/bluespace_rift/goal in SSticker.mode.station_goals)
			var/record = server.get_record(goal.UID())
			server_probe_points += list(list(
				"riftName" = goal.rift ? goal.rift.name : "Unknown",
				"probePoints" = server.data[record][DATA_RECORD_PROBE_POINTS],
			))

		uidata["servers"] += list(list(
			"servName" = server.name,
			"servData" = server_probe_points,
		))

	return uidata

/obj/machinery/brs_server/ui_act(action, list/params)
	if(..())
		return

	if(stat & (NOPOWER|BROKEN))
		return

	switch(action)
		if("toggle_scanner")
			var/scanner_uid = params["scanner_id"]
			var/obj/machinery/power/brs_stationary_scanner/scanner = locateUID(scanner_uid)
			scanner.toggle()
			return TRUE
		if("probe")
			flick_active()
			if(probe_cooldown_end_time > world.time)
				return FALSE
			probe_cooldown_end_time = world.time + probe_cooldown_time
			var/goal_uid = params["rift_id"]
			probe(goal_uid, usr)
			return TRUE
		if("reward")
			flick_active()
			var/goal_uid = params["rift_id"]
			var/datum/station_goal/bluespace_rift/goal = locateUID(goal_uid)

			if(goal.reward_given)
				return FALSE

			var/record = get_record(goal_uid)
			if(data[record][DATA_RECORD_GOAL_POINTS] < goal.target_research_points)
				return FALSE

			new /obj/effect/spawner/lootdrop/bluespace_rift_server(get_turf(src))
			goal.rift.spawn_reward()
			goal.reward_given = TRUE
			visible_message(span_notice("Исследование завершено. Судя по индикации сервера, из разлома выпало что-то, что может представлять большую научную ценность."))
			return TRUE

/obj/machinery/brs_server/proc/probe(goal_uid, mob/user)
	var/record = get_record(goal_uid)

	if(data[record][DATA_RECORD_PROBE_POINTS] < points_per_probe)
		return

	use_power(active_power_usage)

	data[record][DATA_RECORD_PROBE_POINTS] -= points_per_probe

	var/successful
	if(probe_success_chance == 0)
		successful = FALSE
	else if(rand() <= probe_success_chance)
		successful = TRUE
	else
		successful = FALSE

	var/datum/station_goal/bluespace_rift/goal = locateUID(goal_uid)

	if(successful)
		goal.rift.probe(successful = TRUE)
		visible_message(span_notice("Судя по индикации сервера, зондирование прошло успешно. Из разлома удалось извлечь какой-то предмет."))
		data[record][DATA_RECORD_GOAL_POINTS] += research_points_on_probe_success
	else
		goal.rift.probe(successful = FALSE)
		visible_message(span_warning("Судя по индикации сервера, зондирование спровоцировало изменение стабильности блюспейс-разлома. Это не хорошо."))

	// Log it
	if(successful)
		add_game_logs("used [src] to probe a bluespace rift, successful (random reward given).", user)
	else
		add_game_logs("used [src] to probe a bluespace rift, unsuccessful (random rift event triggered).", user)

#undef DATA_RECORD_RIFT_ID
#undef DATA_RECORD_GOAL_POINTS
#undef DATA_RECORD_PROBE_POINTS
#undef DATA_RECORD_TIMES_RIFT_SCANNED
#undef DATA_RECORD_MINED_GOAL_POINTS
#undef DATA_RECORD_MINED_PROBE_POINTS
#undef DATA_RECORD_LENGTH
