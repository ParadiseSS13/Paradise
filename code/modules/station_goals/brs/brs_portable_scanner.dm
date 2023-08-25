//=============================
//Portable Scanner 1x1
//=============================

#define SCAN_OFF 0 //! The scanner turned off
#define SCAN_NO_RIFTS 1 //! No rifts within the scanner's range
#define SCAN_NORMAL 2 //! There are some rifts within the scanner's range
#define SCAN_CRITICAL 3 //! The scanner is within critical range of a rift

/obj/item/circuitboard/brs_portable_scanner
	name = "Портативный сканер разлома (Machine Board)"
	desc = "Плата портативного сканера блюспейс разлома."
	build_path = /obj/machinery/brs_portable_scanner
	icon_state = "scannerplat"
	board_type = "machine"
	origin_tech = "engineering=4;bluespace=3"
	req_components = list(
		/obj/item/stack/sheet/metal = 5,
		/obj/item/stock_parts/capacitor/super = 2,
		/obj/item/stock_parts/micro_laser/ultra = 1,
		/obj/item/stock_parts/scanning_module/phasic = 5,
		/obj/item/stack/ore/bluespace_crystal = 1
	)

/obj/machinery/brs_portable_scanner
	name = "Портативный сканер блюспейс разлома"
	icon = 'icons/obj/machines/BRS/scanner_dynamic.dmi'
	icon_state = "scanner"
	anchored = FALSE
	density = FALSE
	luminosity = 1
	max_integrity = 300
	integrity_failure = 50

	use_power = IDLE_POWER_USE
	idle_power_usage = 4000
	active_power_usage = 7000
	var/switched_off_power_usage = 5

	var/activation_sound = 'sound/effects/servostep.ogg'
	var/deactivation_sound = 'sound/effects/servostep.ogg'
	var/alarm_sound = 'sound/effects/alert.ogg'

	/// Maximum rift detection distance
	var/max_range = 10
	/// Delay before the scanner switches on/off
	var/time_for_switch = 2 SECONDS
	/// Time to failure under critical conditions
	var/time_for_failure = 6 SECONDS
	/// Explosion force during failure, in tiles
	var/failure_force = 2

	/// Needed for users to distinguish between servers
	var/id

	/// World time when the scanner gonna fail
	var/failure_time
	/// Is the scanner switching on/off right now
	var/switching

	var/scanning_status = SCAN_OFF
	var/is_there_any_servers = FALSE

/obj/machinery/brs_portable_scanner/Initialize(mapload)
	. = ..()

	// Assign an id
	var/list/existing_ids = list()
	for(var/obj/machinery/brs_portable_scanner/scanner in GLOB.bluespace_rifts_scanner_list)
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
	status_change()

/obj/machinery/brs_portable_scanner/Destroy()
	GLOB.bluespace_rifts_scanner_list.Remove(src)
	GLOB.poi_list.Remove(src)
	return ..()

/obj/machinery/brs_portable_scanner/ComponentInitialize()
	AddComponent(/datum/component/bluespace_rift_scanner, max_range)

/obj/machinery/brs_portable_scanner/process(seconds_per_tick)
	if(stat & (BROKEN|NOPOWER))
		return
	if(!anchored)
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

/obj/machinery/brs_portable_scanner/proc/process_critical_status()
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

/obj/machinery/brs_portable_scanner/update_icon()
	overlays.Cut()
	set_light(0)
	var/prefix = initial(icon_state)
	if(stat & BROKEN)
		icon_state = "[prefix]-broken"
		return

	if(panel_open)
		overlays += image(icon, "[prefix]-panel")
	
	if(!anchored)
		icon_state = prefix
		return
	
	if((scanning_status == SCAN_OFF) || (stat & NOPOWER))
		icon_state ="[prefix]-anchored"
		return
	if(scanning_status == SCAN_NO_RIFTS)
		icon_state = "[prefix]-on"
		return
	if(scanning_status == SCAN_NORMAL)
		icon_state = "[prefix]-act"
		set_light(l_range = 1, l_power = 1, l_color = COLOR_BLUE_LIGHT)
		return
	if(scanning_status == SCAN_CRITICAL)
		icon_state = "[prefix]-act-critical"
		set_light(l_range = 1, l_power = 1, l_color = COLOR_RED_LIGHT)
		return

/obj/machinery/brs_portable_scanner/power_change()
	..()
	if(stat & NOPOWER)
		SStgui.close_uis(src)
		if(scanning_status != SCAN_OFF)
			playsound(loc, deactivation_sound, 100)
	else
		if(scanning_status != SCAN_OFF)
			playsound(loc, activation_sound, 100)
	update_icon()

/obj/machinery/brs_portable_scanner/obj_break()
	..()
	SStgui.close_uis(src)
	update_icon()

/obj/machinery/brs_portable_scanner/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE

	if(stat & BROKEN)
		to_chat(user, span_warning("[src] сломан, [panel_open ? "за" : "от"]крыть панель невозможно."))
		return

	var/operating = (scanning_status != SCAN_OFF) && (!(stat & NOPOWER))
	if((!panel_open) && operating)
		to_chat(user, span_warning("Панель заблокирована протоколом безопасности. Выключите сканер."))
		return

	default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	update_icon()

	if(panel_open)
		SStgui.close_uis(src)

/obj/machinery/brs_portable_scanner/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE

	if(panel_open && (stat & BROKEN))
		to_chat(user, span_warning("[src] сломан, извлечь детали невозможно."))
		return

	default_deconstruction_crowbar(user, I)

/obj/machinery/brs_portable_scanner/wrench_act(mob/living/user, obj/item/I)
	. = TRUE

	if(stat & BROKEN)
		to_chat(user, span_warning("[src] сломан, [anchored ? "от" : "за"]крутить болты невозможно."))
		return

	if(anchored && (scanning_status != SCAN_OFF) && !(stat & (NOPOWER|BROKEN)))
		to_chat(user, span_warning("Болты заблокированы протоколом безопасности. Выключите сканер."))
		return

	scanning_status = SCAN_OFF
	default_unfasten_wrench(user, I, 4 SECONDS)
	update_icon()

	if(!anchored)
		SStgui.close_uis(src)

	// Allow only one anchored scanner per tile
	if(anchored)
		for(var/obj/machinery/brs_portable_scanner/scanner in get_turf(src))
			if(scanner == src)
				continue
			if(scanner.anchored)
				anchored = FALSE
				update_icon()
				return

	// Update density
	if(anchored)
		density = TRUE
	else
		density = FALSE

/obj/machinery/brs_portable_scanner/welder_act(mob/user, obj/item/I)
	. = TRUE
	default_welder_repair(user, I)
	if(scanning_status != SCAN_OFF)
		// Reset status if the scanner was turned on before the failure.
		turn_on()
	else
		update_icon()

/obj/machinery/brs_portable_scanner/emag_act(mob/user)
	if(!emagged)
		to_chat(user, span_warning("@?%!№@Протоколы безопасности сканера перезаписаны@?%!№@"))
		emagged = TRUE

/obj/machinery/brs_portable_scanner/emp_act(severity)
	. = ..()

/obj/machinery/brs_portable_scanner/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/brs_portable_scanner/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/brs_portable_scanner/attack_hand(mob/user)
	if(..())
		if(stat & NOPOWER)
			// Make it clear, because there's no indications on the icon.
			to_chat(user, span_notice("Сканер не работает. Похоже, нет энергии."))
		return TRUE

	add_fingerprint(user)

	if(!anchored)
		to_chat(user, span_warning("Управление заблокировано протоколом безопасности. Зафиксируйте сканер болтами."))
		return TRUE

	if(panel_open)
		to_chat(user, span_warning("Управление заблокировано протоколом безопасности. Закройте и зафиксируйте панель."))
		return TRUE
	
	ui_interact(user)
	return TRUE

/obj/machinery/brs_portable_scanner/proc/new_component_parts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/brs_portable_scanner(null)

	component_parts += new /obj/item/stack/sheet/metal(null, 5)
	component_parts += new /obj/item/stack/ore/bluespace_crystal(null, 1)

	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)

	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)

	for(var/i in 1 to 5)
		component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)

	RefreshParts()

/obj/machinery/brs_portable_scanner/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BluespaceRiftScanner", name, 475, 400)
		ui.open()

/obj/machinery/brs_portable_scanner/ui_data(mob/user)
	var/list/data = list()
	data["scanStatus"] = scanning_status
	data["serversFound"] = is_there_any_servers
	data["switching"] = switching
	data["time_for_failure"] = time_for_failure
	data["time_till_failure"] = (world.time < failure_time) ? (failure_time - world.time) : 0
	return data

/obj/machinery/brs_portable_scanner/ui_act(action, params)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	if(!anchored || panel_open)
		return

	switch(action)
		if("toggle")
			toggle()
			return TRUE

/** This should be called every time `scanning_status` has been changed. */
/obj/machinery/brs_portable_scanner/proc/status_change()
	if(scanning_status == SCAN_OFF)
		use_power = IDLE_POWER_USE
		idle_power_usage = switched_off_power_usage
	else if(scanning_status == SCAN_NO_RIFTS)
		use_power = IDLE_POWER_USE
		idle_power_usage = initial(idle_power_usage)
	else
		use_power = ACTIVE_POWER_USE
	
	if(scanning_status == SCAN_CRITICAL)
		// Our state just changed to critical
		// Set timer to kaboom
		failure_time = world.time + time_for_failure
	
	update_icon()

/obj/machinery/brs_portable_scanner/proc/toggle()
	switching = TRUE
	if(scanning_status == SCAN_OFF)
		addtimer(CALLBACK(src, PROC_REF(turn_on)), time_for_switch)
	else
		addtimer(CALLBACK(src, PROC_REF(turn_off)), time_for_switch)

/obj/machinery/brs_portable_scanner/proc/turn_on()
	switching = FALSE
	if(panel_open)
		return
	scanning_status = SCAN_NO_RIFTS
	status_change()
	if(!(stat & (NOPOWER|BROKEN)))
		playsound(loc, activation_sound, 100)

/obj/machinery/brs_portable_scanner/proc/turn_off()
	switching = FALSE
	scanning_status = SCAN_OFF
	status_change()
	if(!(stat & (NOPOWER|BROKEN)))
		playsound(loc, deactivation_sound, 100)

#undef SCAN_OFF
#undef SCAN_NO_RIFTS
#undef SCAN_NORMAL
#undef SCAN_CRITICAL
