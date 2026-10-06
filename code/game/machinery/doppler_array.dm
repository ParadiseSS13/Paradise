/obj/machinery/doppler_array
	name = "tachyon-doppler array"
	desc = "A highly precise directional sensor array which measures the release of quants from decaying tachyons. The doppler shifting of the mirror-image formed by these quants can reveal the size, location and temporal affects of energetic disturbances within a large radius ahead of the array."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	density = TRUE
	anchored = TRUE
	atom_say_verb = "states coldly"
	var/list/logged_explosions = list() // MIXTODO - Revisit after experiment multipliers.
	var/explosion_target
	/// List of linked machines
	var/list/linked_machines = list()

	/// Points you get for being exactly on target
	var/list/reward = list(RESEARCH_POINT_STANDARD = 3000)
	var/list/stored_points = list()

	/// Tests completed, shared with the circuit.
	var/completed_tests = 0
	/// Amount of tests we can currently do, increasing with upgrades.
	var/possible_tests = 1
	/// Maximum tests, set by the circuit.
	var/maximum_tests = 4

/datum/explosion_log
	var/logged_time
	var/epicenter
	var/actual_size_message
	var/theoretical_size_message

/datum/explosion_log/New(log_time, log_epicenter, log_actual_size_message, log_theoretical_size_message)
	..()
	logged_time = log_time
	epicenter = log_epicenter
	actual_size_message = log_actual_size_message
	theoretical_size_message = log_theoretical_size_message

/obj/machinery/doppler_array/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/doppler(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	component_parts += new /obj/item/stack/cable_coil(null,1)

	RefreshParts()
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, PROC_REF(sense_explosion))
	roll_target()

/obj/machinery/doppler_array/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/S in component_parts)
		T += S.rating

	possible_tests = T
	share_board_info()

/obj/machinery/doppler_array/proc/share_board_info()
	var/obj/item/circuitboard/doppler/board = locate() in component_parts
	if(!completed_tests)
		completed_tests = board.completed_tests
	else
		board.completed_tests = completed_tests
	maximum_tests = board.maximum_tests

/obj/machinery/doppler_array/Destroy()
	logged_explosions.Cut()
	UnregisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION)
	return ..()

/obj/machinery/doppler_array/examine(mob/user)
	. = ..()
	if(length(stored_points) > 0)
		for(var/i in stored_points)
			. += SPAN_NOTICE("There are [stored_points[i]] [i] points stored.")
	else
		. += SPAN_NOTICE("There are no points stored.")
	. += SPAN_NOTICE("[completed_tests] / [possible_tests] tests completed.")

/obj/machinery/doppler_array/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/disk/tech_disk))
		var/obj/item/disk/tech_disk/disk = used
		var/list/tl = list(RESEARCH_POINT_STANDARD = stored_points)
		var/i = disk.load_research(tl)
		if(i)
			to_chat(user, SPAN_NOTICE("You swipe the disk into [src], loading [stored_points] points."))
			stored_points -= i
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/doppler_array/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!default_unfasten_wrench(user, I, 0))
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/doppler_array/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/multi = I
	multi.set_multitool_buffer(user, src)
	to_chat(user, SPAN_NOTICE("You save [src]'s linking data to the buffer."))

/obj/machinery/doppler_array/attack_hand(mob/user)
	if(..())
		return
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/doppler_array/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/doppler_array/AltClick(mob/user)
	rotate(user)

/obj/machinery/doppler_array/proc/roll_target()
	explosion_target = rand(8, 20)

/obj/machinery/doppler_array/proc/rotate(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, SPAN_WARNING("You don't have the dexterity to do that!"))
		return
	dir = turn(dir, 90)
	to_chat(user, SPAN_NOTICE("You rotate [src]."))

/obj/machinery/doppler_array/proc/print_explosive_logs(mob/user)
	if(!length(logged_explosions))
		atom_say("No logs currently stored in internal database.")
		return
	if(active_timers)
		to_chat(user, SPAN_NOTICE("[src] is already printing something, please wait."))
		return
	atom_say("Printing explosive log. Standby...")
	addtimer(CALLBACK(src, PROC_REF(print)), 50)

/obj/machinery/doppler_array/proc/print()
	visible_message(SPAN_NOTICE("[src] prints a piece of paper!"))
	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
	var/obj/item/paper/explosive_log/P = new(get_turf(src))
	for(var/D in logged_explosions)
		var/datum/explosion_log/E = D
		P.info += "<tr>\
		<td>[E.logged_time]</td>\
		<td>[E.epicenter]</td>\
		<td>[E.actual_size_message]</td>\
		<td>[E.theoretical_size_message]</td>\
		</tr>"
	P.info += "</table><hr/>\
	<em>Printed at [station_time_timestamp()].</em>"

/obj/machinery/doppler_array/proc/sense_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range,
		light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	if(stat & NOPOWER)
		return
	if(z != epicenter.z)
		return

	var/dx = abs(epicenter.x - x)
	var/dy = abs(epicenter.y - y)
	var/distance
	var/direct
	var/capped = FALSE

	if(dx > dy)
		distance = dx
		if(epicenter.x > x)
			direct = EAST
		else
			direct = WEST
	else
		distance = dy
		if(epicenter.y > y)
			direct = NORTH
		else
			direct = SOUTH

	if(distance > 100)
		return
	if(!(direct & dir))
		return

	var/coordinates = "[epicenter.x],[epicenter.y]"
	var/list/messages = list("Explosive disturbance detected.", \
							"Epicenter at: grid ([coordinates]). Temporal displacement of tachyons: [took] seconds.", \
							"Actual: Epicenter radius: [devastation_range]. Outer radius: [heavy_impact_range]. Shockwave radius: [light_impact_range].")

	// If the bomb was capped, say its theoretical size.
	if(devastation_range < orig_dev_range || heavy_impact_range < orig_heavy_range || light_impact_range < orig_light_range)
		capped = TRUE
		messages += "Theoretical: Epicenter radius: [orig_dev_range]. Outer radius: [orig_heavy_range]. Shockwave radius: [orig_light_range]."
	logged_explosions.Insert(1, new /datum/explosion_log(station_time_timestamp(), "[coordinates]", "[devastation_range], [heavy_impact_range], [light_impact_range]", capped ? "[orig_dev_range], [orig_heavy_range], [orig_light_range]" : "n/a")) //Newer logs appear first
	messages += "Event successfully logged in internal database."
	var/miss_by = abs(explosion_target - orig_light_range)
	if(!miss_by)
		messages += "Explosion size matches target."
		if(completed_tests < possible_tests)
			for(var/i in reward)
				messages += "[reward[i]] [i] points generated. Swipe a technology disk to save data."
				stored_points[i] += reward[i]
			completed_tests++
			share_board_info()
		else
			messages += "No points generated, scanning module insufficient."
		roll_target()
	else
		messages += "Target ([explosion_target]) missed by : [miss_by]."
	for(var/message in messages)
		atom_say(message)
	for(var/obj/machinery/anomaly_refinery/anom_refiner in linked_machines)
		anom_refiner.refine_core(orig_light_range)

/obj/machinery/doppler_array/update_icon_state()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		icon_state = !(stat & NOPOWER) && anchored ? initial(icon_state) : "[initial(icon_state)]-off"

/// overrides base power_change to check to make sure machine is anchored
/obj/machinery/doppler_array/power_change()
	if(has_power(power_channel) && anchored)
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

/obj/machinery/doppler_array/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/doppler_array/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TachyonArray", name)
		ui.open()

/obj/machinery/doppler_array/ui_data(mob/user) // MIXTODO - Fix the UI point display and add completed/possible tests
	var/list/data = list()
	var/list/records = list()
	for(var/i in 1 to length(logged_explosions))
		var/datum/explosion_log/E = logged_explosions[i]
		records += list(list(
			"logged_time" = E.logged_time,
			"epicenter" = E.epicenter,
			"actual_size_message" = E.actual_size_message,
			"theoretical_size_message" = E.theoretical_size_message,
			"index" = i))
	data["explosion_target"] = explosion_target
	data["records"] = records
	data["printing"] = active_timers
	return data

/obj/machinery/doppler_array/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("delete_logs")
			QDEL_LIST_CONTENTS(logged_explosions)
			to_chat(usr, SPAN_NOTICE("All logs deleted successfully."))
		if("delete_record")
			var/index = text2num(params["index"])
			if(index < 0 || index > length(logged_explosions))
				return

			var/datum/explosion_log/E = logged_explosions[index]
			logged_explosions -= E
			qdel(E)
			to_chat(usr, SPAN_NOTICE("Log deletion successful."))
		if("print_logs")
			print_explosive_logs(usr)
		else
			return
	return TRUE

/obj/item/paper/explosive_log
	name = "explosive log"
	info = "<h3>Explosive Log Report</h3>\
	<table style='width:380px;text-align:left;'>\
	<tr>\
	<th>Time logged</th>\
	<th>Epicenter</th>\
	<th>Actual</th>\
	<th>Theoretical</th>\
	</tr>" //NB: the <table> tag is left open, it is closed later on, when the doppler array adds its data
