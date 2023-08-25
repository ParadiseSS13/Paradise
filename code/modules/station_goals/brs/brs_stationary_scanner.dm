//=============================
// Stationary Scanner 3x3
//=============================

#define SCAN_OFF 0 //! The scanner turned off
#define SCAN_NO_RIFTS 1 //! No rifts within the scanner's range
#define SCAN_NORMAL 2 //! There are some rifts within the scanner's range
#define SCAN_CRITICAL 3 //! The scanner is within critical range of a rift

/obj/item/circuitboard/brs_stationary_scanner
	name = "Стационарный сканер разлома (Machine Board)"
	desc = "Плата стационарного сканера блюспейс разлома."
	build_path = /obj/machinery/power/brs_stationary_scanner
	icon_state = "bluespace_scannerplat"
	board_type = "machine"
	origin_tech = "engineering=6;bluespace=5"
	req_components = list(
		/obj/item/stack/sheet/metal = 30,
		/obj/item/stock_parts/capacitor/super = 8,
		/obj/item/stock_parts/micro_laser/ultra = 2,
		/obj/item/stock_parts/scanning_module/phasic = 10,
		/obj/item/stack/ore/bluespace_crystal = 4
	)

/obj/machinery/power/brs_stationary_scanner
	name = "Стационарный сканер блюспейс разлома"
	icon = 'icons/obj/machines/BRS/scanner_static.dmi'
	icon_state = "scanner"
	pixel_x = -32
	pixel_y = -32
	anchored = TRUE
	density = TRUE
	luminosity = 1
	max_integrity = 500
	integrity_failure = 100

	// Power consumption from cables is handled in `process()`
	use_power = NO_POWER_USE
	// That's per second
	idle_power_usage = 6000
	active_power_usage = 10000
	var/switched_off_power_usage = 20
	/// Is there enough power in the powernet.
	var/cable_powered = FALSE

	var/activation_sound = 'sound/effects/electheart.ogg'
	var/deactivation_sound = 'sound/effects/basscannon.ogg'
	var/alarm_sound = 'sound/effects/alert.ogg'

	/// Maximum rift detection distance
	var/max_range = 50
	/// Delay before the scanner switches on/off
	var/time_for_switch = 3 SECONDS
	/// Time to failure under critical conditions
	var/time_for_failure = 30 SECONDS
	/// Explosion force during failure, in tiles
	var/failure_force = 3

	/// Needed for users to distinguish between servers
	var/id

	/// World time when the scanner gonna fail
	var/failure_time
	/// Is the scanner switching on/off right now
	var/switching

	var/scanning_status = SCAN_OFF
	var/is_there_any_servers = FALSE

/obj/machinery/power/brs_stationary_scanner/Initialize(mapload)
	. = ..()

	// Assign an id
	var/list/existing_ids = list()
	for(var/obj/machinery/power/brs_stationary_scanner/scanner in GLOB.bluespace_rifts_scanner_list)
		existing_ids += scanner.id
	for(var/possible_id in 1 to length(existing_ids))
		if(!(possible_id in existing_ids))
			id = possible_id
	if(!id)
		id = length(existing_ids) + 1
	name = "[name] \[#[id]\]"

	GLOB.bluespace_rifts_scanner_list.Add(src)
	GLOB.poi_list |= src
	new_component_parts()
	connect_to_network()
	update_icon()

/obj/machinery/power/brs_stationary_scanner/Destroy()
	GLOB.bluespace_rifts_scanner_list.Remove(src)
	GLOB.poi_list.Remove(src)
	return ..()

/obj/machinery/power/brs_stationary_scanner/ComponentInitialize()
	AddComponent(/datum/component/bluespace_rift_scanner, max_range)

/obj/machinery/power/brs_stationary_scanner/process(seconds_per_tick)
	if(stat & BROKEN)
		return

	process_power_consumption(seconds_per_tick)

	if(!cable_powered)
		return
	if(scanning_status == SCAN_OFF)
		return
	
	var/previous_status = scanning_status

	// Set status
	var/scan_result = SEND_SIGNAL(src, COMSIG_SCANNING_RIFTS, seconds_per_tick, emagged)
	if(scan_result & COMPONENT_SCANNED_NOTHING)
		scanning_status = SCAN_NO_RIFTS
	else if(scan_result & COMPONENT_SCANNED_NORMAL)
		scanning_status = SCAN_NORMAL
	else if(scan_result & COMPONENT_SCANNED_CRITICAL)
		scanning_status = SCAN_CRITICAL
	else
		CRASH("Component returned unexpected value.")

	is_there_any_servers = (scan_result & COMPONENT_SCANNED_NO_SERVERS) ? FALSE : TRUE
	
	if(scanning_status != previous_status)
		status_change()

	if(scanning_status == SCAN_CRITICAL)
		process_critical_status()

/obj/machinery/power/brs_stationary_scanner/proc/process_power_consumption(seconds_per_tick)
	var/current_power_need
	if(scanning_status == SCAN_OFF)
		current_power_need = switched_off_power_usage * seconds_per_tick
	else if(scanning_status == SCAN_NO_RIFTS)
		current_power_need = idle_power_usage * seconds_per_tick
	else
		current_power_need = active_power_usage * seconds_per_tick

	if(surplus() < current_power_need)
		// There's not enough power
		if(cable_powered)
			cable_powered = FALSE
			on_power_change()
		return

	if(!cable_powered)
		cable_powered = TRUE
		on_power_change()
	
	add_load(current_power_need)

/obj/machinery/power/brs_stationary_scanner/proc/process_critical_status()
	if(world.time < failure_time)
		playsound(loc, alarm_sound, 100)
	else
		obj_break()
		explosion(
			loc, 
			light_impact_range = failure_force, 
			flash_range = 2 * failure_force, 
			flame_range =  2 * failure_force, 
			cause = "[src] was working too long within critical range of a rift."
		)

/obj/machinery/power/brs_stationary_scanner/update_icon()
	var/prefix = initial(icon_state)

	overlays.Cut()
	if(panel_open)
		overlays += image(icon, "[prefix]-panel")
	
	if (stat & BROKEN)
		icon_state = "[prefix]-broken"
		return
	if ((scanning_status == SCAN_OFF) || (!cable_powered))
		icon_state = prefix
		return
	icon_state = "[prefix]-act"

/obj/machinery/power/brs_stationary_scanner/power_change()
	// It shouldn't react to the apc
	..()

/obj/machinery/power/brs_stationary_scanner/proc/on_power_change()
	if(!cable_powered)
		SStgui.close_uis(src)
		if(scanning_status != SCAN_OFF)
			playsound(loc, deactivation_sound, 100)
	else
		if(scanning_status != SCAN_OFF)
			playsound(loc, activation_sound, 100)
	update_icon()

/obj/machinery/power/brs_stationary_scanner/obj_break()
	..()
	update_icon()
	SStgui.close_uis(src)

/obj/machinery/power/brs_stationary_scanner/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE

	// It's a large machine, add a delay
	user.visible_message(
		"[user] начина[pluralize_ru(user.gender, "ет", "ют")] [panel_open ? "От" : "За"]кручивать панель [src].", 
		"Вы начинаете [panel_open ? "От" : "За"]кручивать панель [src]."
	)
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume))
		return
	
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	update_icon()

/obj/machinery/power/brs_stationary_scanner/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE

	if((scanning_status != SCAN_OFF) && cable_powered)
		to_chat(user, "<span class='warning'>Панель заблокирована протоколом безопасности. Выключите сканер.</span>")
		return

	// It's a large machine, add a delay
	user.visible_message("[user] начина[pluralize_ru(user.gender, "ет", "ют")] разбирать [src].", "Вы начинаете разбирать [src].")
	if(!I.use_tool(src, user, 8 SECONDS, volume = I.tool_volume))
		return

	default_deconstruction_crowbar(user, I)

/obj/machinery/power/brs_stationary_scanner/wrench_act(mob/living/user, obj/item/I)
	return FALSE

/obj/machinery/power/brs_stationary_scanner/welder_act(mob/user, obj/item/I)
	. = TRUE
	default_welder_repair(user, I)
	if(scanning_status != SCAN_OFF)
		// Reset if the scanner was turned on before the failure.
		turn_on()
	else
		update_icon()

/obj/machinery/power/brs_stationary_scanner/emag_act(mob/user)
	if(!emagged)
		to_chat(user, span_warning("@?%!№@Протоколы безопасности сканера перезаписаны@?%!№@"))
		emagged = TRUE

/obj/machinery/power/brs_stationary_scanner/emp_act(severity)
	. = ..()

/obj/machinery/power/brs_stationary_scanner/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/power/brs_stationary_scanner/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/power/brs_stationary_scanner/attack_hand(mob/user)
	if(..())
		return TRUE
	if(!cable_powered)
		// Make it clear, because there's no indications on the icon.
		to_chat(user, span_notice("Сканер не работает. Похоже, нет энергии."))
		return TRUE

	add_fingerprint(user)
	ui_interact(user)
	return TRUE

/obj/machinery/power/brs_stationary_scanner/proc/new_component_parts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/brs_stationary_scanner(null)

	component_parts += new /obj/item/stack/sheet/metal(null, 30)
	component_parts += new /obj/item/stack/ore/bluespace_crystal(null, 4)

	for(var/i in 1 to 8)
		component_parts += new /obj/item/stock_parts/capacitor/super(null)

	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)

	for(var/i in 1 to 10)
		component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)

	RefreshParts()

/obj/machinery/power/brs_stationary_scanner/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BluespaceRiftScanner", name, 475, 400)
		ui.open()

/obj/machinery/power/brs_stationary_scanner/ui_data(mob/user)
	var/list/data = list()
	data["scanStatus"] = scanning_status
	data["serversFound"] = is_there_any_servers
	data["switching"] = switching
	data["time_for_failure"] = time_for_failure
	data["time_till_failure"] = (world.time < failure_time) ? (failure_time - world.time) : 0
	return data

/obj/machinery/power/brs_stationary_scanner/ui_act(action, params)
	if(..())
		return
	if(stat & BROKEN)
		return
	if(!cable_powered)
		return

	switch(action)
		if("toggle")
			toggle()
			return TRUE

/** This should be called every time `scanning_status` has been changed. */
/obj/machinery/power/brs_stationary_scanner/proc/status_change()	
	if(scanning_status == SCAN_CRITICAL)
		// Our state just changed to critical
		// Set timer to kaboom
		failure_time = world.time + time_for_failure
	update_icon()

/obj/machinery/power/brs_stationary_scanner/proc/toggle()
	switching = TRUE
	if(scanning_status == SCAN_OFF)
		addtimer(CALLBACK(src, PROC_REF(turn_on)), time_for_switch)
	else
		addtimer(CALLBACK(src, PROC_REF(turn_off)), time_for_switch)

/obj/machinery/power/brs_stationary_scanner/proc/turn_on()
	switching = FALSE
	scanning_status = SCAN_NO_RIFTS
	status_change()
	if(cable_powered && (!(stat & BROKEN)))
		playsound(loc, activation_sound, 100)

/obj/machinery/power/brs_stationary_scanner/proc/turn_off()
	switching = FALSE
	scanning_status = SCAN_OFF
	status_change()
	if(cable_powered && (!(stat & BROKEN)))
		playsound(loc, deactivation_sound, 100)

#undef SCAN_OFF
#undef SCAN_NO_RIFTS
#undef SCAN_NORMAL
#undef SCAN_CRITICAL
