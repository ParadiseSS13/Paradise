GLOBAL_LIST_EMPTY(gas_sensors)

#define SENSOR_PRESSURE		(1<<0)
#define SENSOR_TEMPERATURE	(1<<1)
#define SENSOR_O2			(1<<2)
#define SENSOR_PLASMA		(1<<3)
#define SENSOR_N2			(1<<4)
#define SENSOR_CO2			(1<<5)
#define SENSOR_N2O			(1<<6)

/obj/machinery/atmospherics/air_sensor
	icon_state = "gsensor1"
	name = "gas sensor"

	var/state = 0
	var/bolts = TRUE

	on = TRUE
	var/output = SENSOR_PRESSURE | SENSOR_TEMPERATURE
	//Flags: (see lines 3-9)
	// 1 for pressure
	// 2 for temperature
	// Output >= 4 includes gas composition
	// 4 for oxygen concentration
	// 8 for toxins concentration
	// 16 for nitrogen concentration
	// 32 for carbon dioxide concentration
	// 64 for nitrous dioxide concentration

/obj/machinery/atmospherics/air_sensor/Initialize(mapload)
	. = ..()
	GLOB.gas_sensors += src

/obj/machinery/atmospherics/air_sensor/Destroy()
	GLOB.gas_sensors -= src
	return ..()

/obj/machinery/atmospherics/air_sensor/update_icon_state()
	icon_state = "gsensor[on]"

/obj/machinery/atmospherics/air_sensor/wrench_act(mob/user, obj/item/I)
	if(bolts)
		to_chat(usr, "[src] is bolted to the floor! You can't detach it like this.")
		return

	. = TRUE
	if(!I.use_tool(src, user, 40, volume = I.tool_volume))
		return

	user.visible_message("[user] unfastens \the [src].", "<span class='notice'>You have unfastened \the [src].</span>", "You hear ratchet.")
	new /obj/item/pipe_gsensor(loc)
	qdel(src)
	playsound(src, 'sound/items/deconstruct.ogg', 50, 1)

#define ONOFF_TOGGLE(flag) "\[[(output & flag) ? "YES" : "NO"]]"
/obj/machinery/atmospherics/air_sensor/multitool_act(mob/living/user, obj/item/I)
	var/list/options = list(
		"Pressure: [ONOFF_TOGGLE(SENSOR_PRESSURE)]" = SENSOR_PRESSURE,
		"Temperature: [ONOFF_TOGGLE(SENSOR_TEMPERATURE)]" = SENSOR_TEMPERATURE,
		"Oxygen: [ONOFF_TOGGLE(SENSOR_O2)]" = SENSOR_O2,
		"Toxins: [ONOFF_TOGGLE(SENSOR_PLASMA)]" = SENSOR_PLASMA,
		"Nitrogen: [ONOFF_TOGGLE(SENSOR_N2)]" = SENSOR_N2,
		"Carbon Dioxide: [ONOFF_TOGGLE(SENSOR_CO2)]" = SENSOR_CO2,
		"Nitrous Oxide: [ONOFF_TOGGLE(SENSOR_N2O)]" = SENSOR_N2O,
		"-SAVE TO BUFFER-" = "multitool"
	)

	var/temp_answer = tgui_input_list(user, "Select an option to adjust", "Options!", options)

	if(!(src in view(5, user)))
		return TRUE

	if(temp_answer in options) // Null will break us out
		switch(options[temp_answer])
			if(SENSOR_PRESSURE)
				output ^= SENSOR_PRESSURE
			if(SENSOR_TEMPERATURE)
				output ^= SENSOR_TEMPERATURE
			if(SENSOR_O2)
				output ^= SENSOR_O2
			if(SENSOR_PLASMA)
				output ^= SENSOR_PLASMA
			if(SENSOR_N2)
				output ^= SENSOR_N2
			if(SENSOR_CO2)
				output ^= SENSOR_CO2
			if(SENSOR_N2O)
				output ^= SENSOR_N2O
			if("multitool")
				if(!ismultitool(I)) // Should never happen
					return

				var/obj/item/multitool/M = I
				M.buffer_uid = UID()
				to_chat(user, "<span class='notice'>You save [src] into [M]'s buffer</span>")

	return TRUE
#undef ONOFF_TOGGLE




/obj/machinery/computer/general_air_control
	name = "air sensor monitor"
	icon_screen = "tank"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/air_management
	// Map set vars
	/// List of sensors to autolink to. Key = sensor_id, Value = sensor display name
	var/list/autolink_sensors = list()

	// Instanced vars. These are /tmp/ to avoid mappers trying to set them
	/// List of sensor names to UIDs to be used in the display
	var/tmp/list/sensor_name_uid_map = list()
	/// List of sensor names to cache lists used in the display TGUI
	var/tmp/list/sensor_name_data_map = list()

/obj/machinery/computer/general_air_control/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD // Do all our work in here

/obj/machinery/computer/general_air_control/LateInitialize()
	// Setup sensors
	for(var/obj/machinery/atmospherics/air_sensor/AS as anything in GLOB.gas_sensors)
		for(var/sensor_id in autolink_sensors)
			if(AS.autolink_id == sensor_id)
				sensor_name_uid_map[autolink_sensors[sensor_id]] = AS.UID()
				sensor_name_data_map[autolink_sensors[sensor_id]] = list()

	// Setup meters
	for(var/obj/machinery/atmospherics/meter/GM as anything in GLOB.gas_meters)
		for(var/meter_id in autolink_sensors)
			if(GM.autolink_id == meter_id)
				sensor_name_uid_map[autolink_sensors[meter_id]] = GM.UID()
				sensor_name_data_map[autolink_sensors[meter_id]] = list()

/obj/machinery/computer/general_air_control/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/general_air_control/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/general_air_control/ui_interact(mob/user, datum/tgui/ui = null)
	if(!isprocessing)
		START_PROCESSING(SSmachines, src)
		refresh_all()

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		// We can use the same template here for sensors and for tanks with inlets/outlets with TGUI memes
		ui = new(user, src, "AtmosTankControl", name)
		ui.open()

/obj/machinery/computer/general_air_control/ui_data(mob/user)
	var/list/data = list()
	data["sensors"] = sensor_name_data_map // We can make this super cheap by sending our existing data
	return data

/obj/machinery/computer/general_air_control/multitool_act(mob/living/user, obj/item/I)
	if(!ismultitool(I)) // Should never happen
		return

	configure_sensors(user, I)
	return TRUE

// This is its own proc so it can be modified in child types
/obj/machinery/computer/general_air_control/proc/configure_sensors(mob/living/user, obj/item/multitool/M)
	var/choice = tgui_alert(user, "Would you like to add or remove a sensor/meter", "Configuration", list("Add", "Remove", "Cancel"))
	if(!choice || (choice == "Cancel") || !Adjacent(user))
		return

	switch(choice)
		if("Add")
			// First see if they have a scrubber in their buffer
			var/datum/linked_datum = locateUID(M.buffer_uid)
			if(!linked_datum || !(istype(linked_datum, /obj/machinery/atmospherics/air_sensor) || istype(linked_datum, /obj/machinery/atmospherics/meter)))
				to_chat(user, "<span class='warning'>Error: No device in multitool buffer, or device is not a sensor or meter.</span>")
				return

			var/new_name = clean_input(user, "Enter a name for the sensor/meter", "Name")
			if(!new_name || !Adjacent(user))
				return

			sensor_name_uid_map[new_name] = linked_datum.UID() // Make sure the multitool ref didnt change while they had the menu open
			sensor_name_data_map[new_name] = list()
			to_chat(user, "<span class='notice'>Successfully added a new sensor/meter with name <code>[new_name]</code></span>")

		if("Remove")
			var/to_remove = tgui_input_list(user, "Select a sensor/meter to remove", "Sensor/Meter Removal", sensor_name_uid_map)
			if(!to_remove)
				return

			var/confirm = tgui_alert(user, "Are you sure you want to remove the sensor/meter '[to_remove]'?", "Warning", list("Yes", "No"))
			if((confirm != "Yes") || !Adjacent(user))
				return

			sensor_name_uid_map -= to_remove
			sensor_name_data_map -= to_remove
			to_chat(user, "<span class='notice'>Successfully removed sensor/meter with name <code>[to_remove]</code></span>")

// Makes overrides easier
/obj/machinery/computer/general_air_control/proc/refresh_all()
	refresh_sensors()

// Refreshes the sensors every so often, but only when the UI is opened
/obj/machinery/computer/general_air_control/proc/refresh_sensors()
	for(var/sensor_name in sensor_name_uid_map)
		var/obj/machinery/atmospherics/AM = locateUID(sensor_name_uid_map[sensor_name])
		if(QDELETED(AM))
			sensor_name_uid_map -= sensor_name
			sensor_name_data_map -= sensor_name
			continue

		if(istype(AM, /obj/machinery/atmospherics/air_sensor))
			// Cache here to avoid a ton of list lookups
			var/obj/machinery/atmospherics/air_sensor/AS = AM
			var/list/sensor_data = sensor_name_data_map[sensor_name]
			var/turf/T = get_turf(AS)
			var/datum/gas_mixture/air_sample = T.get_readonly_air()

			// We remove it from the list incase sensor reporting is ever disabled
			// We only want to show the information available
			if(AS.output & SENSOR_PRESSURE)
				sensor_data["pressure"] = air_sample.return_pressure()
			else
				sensor_data -= "pressure"

			if(AS.output & SENSOR_TEMPERATURE)
				sensor_data["temperature"] = air_sample.temperature()
			else
				sensor_data -= "temperature"

			var/total_moles = air_sample.total_moles()

			if(total_moles > 0)
				if(AS.output & SENSOR_O2)
					sensor_data["o2"] = round(100 * air_sample.oxygen() / total_moles, 0.1)
				else
					sensor_data -= "o2"

				if(AS.output & SENSOR_PLASMA)
					sensor_data["plasma"] = round(100 * air_sample.toxins() / total_moles, 0.1)
				else
					sensor_data -= "plasma"

				if(AS.output & SENSOR_N2)
					sensor_data["n2"] = round(100 * air_sample.nitrogen() / total_moles, 0.1)
				else
					sensor_data -= "n2"

				if(AS.output & SENSOR_CO2)
					sensor_data["co2"] = round(100 * air_sample.carbon_dioxide() / total_moles, 0.1)
				else
					sensor_data -= "co2"

				if(AS.output & SENSOR_N2O)
					sensor_data["n2o"] = round(100 * air_sample.sleeping_agent() / total_moles, 0.1)
				else
					sensor_data -= "n2o"

		else if(istype(AM, /obj/machinery/atmospherics/meter))
			var/list/meter_data = sensor_name_data_map[sensor_name]
			var/obj/machinery/atmospherics/meter/the_meter = AM
			if(the_meter.target)
				var/datum/gas_mixture/meter_env = the_meter.target.return_obj_air()
				if(meter_env)
					meter_data["pressure"] = meter_env.return_pressure()
					meter_data["temperature"] = meter_env.temperature()


/obj/machinery/computer/general_air_control/process()
	// We only care about refreshing if people are looking at us
	if(src in SStgui.open_uis_by_src)
		refresh_all()
		return

	return PROCESS_KILL

/obj/machinery/computer/general_air_control/large_tank_control
	circuit = /obj/item/circuitboard/large_tank_control

	// Map set vars
	/// Autolink ID of the chamber inlet injector
	var/list/inlet_injector_autolink_ids = list()
	/// Autolink ID of the chamber outlet vent
	var/list/outlet_autolink_ids = list()

	// Instanced vars. These are /tmp/ to avoid mappers trying to set them
	/// The runtime UID of the inlet injector
	var/tmp/list/inlet_uids = list()
	/// The runtime UID of the outlet vent
	var/tmp/list/outlet_uids = list()

	/// UI holder list of the inlet data
	var/tmp/list/inlet_data = list()
	/// UI holder list of the outlet vent data
	var/tmp/list/outlet_vent_data = list()
	/// UI holder list of the outlet scrubber data
	var/tmp/list/outlet_scrubber_data = list()

	/// Default outlet vent setting (About 4559.6)
	var/outlet_setting = ONE_ATMOSPHERE * 45
	/// Default inlet injector setting (50 L/s)
	var/inlet_setting = 50

/obj/machinery/computer/general_air_control/large_tank_control/LateInitialize()
	..()

	// Setup inlet
	if(length(inlet_injector_autolink_ids))
		for(var/obj/machinery/atmospherics/unary/outlet_injector/inlet_injector as anything in GLOB.air_injectors)
			if(inlet_injector.autolink_id in inlet_injector_autolink_ids)
				inlet_uids += inlet_injector.UID() // inlet_injector!
				// Setup some defaults
				inlet_injector.on = TRUE
				inlet_injector.volume_rate = inlet_setting
				inlet_injector.update_icon()
				inlet_data += list("[inlet_injector.UID()]" = list("name"= inlet_injector.name, "on" = inlet_injector.on, "rate" = inlet_injector.volume_rate, "uid" = inlet_injector.UID()))
				refresh_inlets()
				break

	// Setup outlet
	if(length(outlet_autolink_ids))
		for(var/obj/machinery/atmospherics/unary/vent_pump/outlet_vent as anything in GLOB.all_vent_pumps)
			if(outlet_vent.autolink_id in outlet_autolink_ids)
				outlet_uids += outlet_vent.UID()
				var/area/our_area = get_area(src)
				our_area.vents -= outlet_vent
				outlet_vent.on = TRUE
				outlet_vent.releasing = FALSE
				outlet_vent.internal_pressure_bound = outlet_setting
				outlet_vent.update_icon()
				outlet_vent_data += list("[outlet_vent.UID()]" = list("name" =outlet_vent.name, "on" = outlet_vent.on, "checks" = outlet_vent.pressure_checks, "rate" = outlet_vent.pressure_checks == 1 ? outlet_vent.external_pressure_bound : outlet_vent.internal_pressure_bound, "uid" = outlet_vent.UID()))
				refresh_outlets()
				return
		for(var/obj/machinery/atmospherics/unary/vent_scrubber/scrubber in GLOB.all_scrubbers)
			if(scrubber.autolink_id in outlet_autolink_ids)
				outlet_uids += scrubber.UID()
				var/area/our_area = get_area(src)
				our_area.scrubbers -= scrubber
				scrubber.on = TRUE
				scrubber.scrubbing = FALSE
				outlet_scrubber_data += list("[scrubber.UID()]" = list(
				"id_tag" = scrubber.UID(),
				"name" = scrubber.name,
				"power" = scrubber.on,
				"scrubbing" = scrubber.scrubbing,
				"widenet" = scrubber.widenet,
				"filter_o2" = scrubber.scrub_O2,
				"filter_n2" = scrubber.scrub_N2,
				"filter_co2" = scrubber.scrub_CO2,
				"filter_toxins" = scrubber.scrub_Toxins,
				"filter_n2o" = scrubber.scrub_N2O))


/obj/machinery/computer/general_air_control/large_tank_control/multitool_act(mob/living/user, obj/item/I)
	if(!ismultitool(I)) // Should never happen
		return

	var/choice = tgui_input_list(user, "Configure what", "Configuration", list("Inlet", "Outlet", "Sensors", "Cancel"))
	if((!choice) || (choice == "Cancel") || !Adjacent(user))
		return

	switch(choice)
		if("Inlet")
			configure_inlet(user, I)
		if("Outlet")
			configure_outlet(user, I)
		if("Sensors")
			configure_sensors(user, I)

	return TRUE

/obj/machinery/computer/general_air_control/large_tank_control/proc/configure_inlet(mob/living/user, obj/item/multitool/M)
	var/choice = tgui_alert(user, "Would you like to add an inlet, remove the existing inlet or clear it?", "Configuration", list("Add", "Remove", "Clear", "Cancel"))
	if(!choice || (choice == "Cancel") || !Adjacent(user))
		return

	switch(choice)
		if("Add")
			if(M.buffer_uid in inlet_uids)
				to_chat(user, "<span class='warning'>Error: This device is already connected to the console.</span>")
				return
			// First see if they have a scrubber in their buffer
			var/datum/linked_datum = locateUID(M.buffer_uid)
			if(!linked_datum || !istype(linked_datum, /obj/machinery/atmospherics/unary/outlet_injector))
				to_chat(user, "<span class='warning'>Error: No device in multitool buffer, or device is not an injector.</span>")
				return

			inlet_uids += linked_datum.UID() // Make sure the multitool ref didnt change while they had the menu open
			var/obj/machinery/atmospherics/unary/outlet_injector/inlet_injector = linked_datum
			// Setup some defaults
			inlet_injector.on = FALSE
			inlet_injector.volume_rate = inlet_setting
			inlet_injector.update_icon()
			inlet_data += list("[linked_datum.UID()]" = list("name" = inlet_injector.name, "on" = inlet_injector.on, "rate" = inlet_injector.volume_rate, "uid" = inlet_injector.UID()))
			refresh_inlets()
			to_chat(user, "<span class='notice'>Successfully added an inlet injector.</span>")

		if("Remove")
			var/list/namelist = list()
			for(var/uid in inlet_data)
				namelist += inlet_data[uid]["name"]
			choice = tgui_input_list(user, "Select an inlet to remove", "Inlet Selection", namelist)
			for(var/uid in inlet_data)
				if(choice == inlet_data[uid]["name"])
					var/obj/machinery/atmospherics/unary/outlet_injector/inlet_injector
					if(!QDELETED(inlet_injector))
						inlet_injector.on = FALSE
						inlet_injector.update_icon()
					inlet_data -= uid
					inlet_uids -= uid
					break

		if("Clear")
			if(inlet_uids)
				var/obj/machinery/atmospherics/unary/outlet_injector/inlet_injector
				for(var/uid in inlet_uids)
					inlet_injector = locateUID(uid)
					if(!QDELETED(inlet_injector))
						inlet_injector.on = FALSE
						inlet_injector.update_icon()

				inlet_uids = list()
				inlet_data = list()
				refresh_inlets()
				to_chat(user, "<span class='notice'>Successfully unlinked inlet injector.</span>")
			else
				to_chat(user, "<span class='warning'>Error - No injector linked!</span>")


/obj/machinery/computer/general_air_control/large_tank_control/proc/configure_outlet(mob/living/user, obj/item/multitool/M)
	var/choice = tgui_alert(user, "Would you like to add an outlet, remove the existing outlet or clear it?", "Configuration", list("Add", "Remove", "Clear", "Cancel"))
	if(!choice || (choice == "Cancel") || !Adjacent(user))
		return

	switch(choice)
		if("Add")
			if(M.buffer_uid in outlet_uids)
				to_chat(user, "<span class='warning'>Error: This device is already connected to the console.</span>")
				return
			// First see if they have a scrubber in their buffer
			var/datum/linked_datum = locateUID(M.buffer_uid)
			if(!linked_datum)
				to_chat(user, "<span class='warning'>Error: No compatible device in multitool buffer</span>")
				return
			if(istype(linked_datum, /obj/machinery/atmospherics/unary/vent_pump))
				outlet_uids += linked_datum.UID() // Make sure the multitool ref didnt change while they had the menu open
				var/obj/machinery/atmospherics/unary/vent_pump/outlet_vent = linked_datum
				// Setup some defaults
				var/area/our_area = get_area(src)
				our_area.vents -= outlet_vent
				outlet_vent.on = FALSE
				outlet_vent.releasing = FALSE
				outlet_vent.internal_pressure_bound = outlet_setting
				outlet_vent.update_icon()
				outlet_vent_data += list("[linked_datum.UID()]" = list("name" = outlet_vent.name, "on" = outlet_vent.on, "checks" = outlet_vent.pressure_checks, "rate" = outlet_vent.internal_pressure_bound, "uid" = outlet_vent.UID()))
				refresh_outlets()
				to_chat(user, "<span class='notice'>Successfully added an outlet vent</span>")
				return
			if(istype(linked_datum, /obj/machinery/atmospherics/unary/vent_scrubber))
				outlet_uids += linked_datum.UID() // Make sure the multitool ref didnt change while they had the menu open
				var/obj/machinery/atmospherics/unary/vent_scrubber/scrubber = linked_datum
				// Setup some defaults
				var/area/our_area = get_area(src)
				our_area.scrubbers -= scrubber
				scrubber.on = FALSE
				scrubber.scrubbing = FALSE
				scrubber.update_icon()
				outlet_scrubber_data += list("[scrubber.UID()]" = list(
					"id_tag" = scrubber.UID(),
					"name" = scrubber.name,
					"power" = scrubber.on,
					"scrubbing" = scrubber.scrubbing,
					"widenet" = scrubber.widenet,
					"filter_o2" = scrubber.scrub_O2,
					"filter_n2" = scrubber.scrub_N2,
					"filter_co2" = scrubber.scrub_CO2,
					"filter_toxins" = scrubber.scrub_Toxins,
					"filter_n2o" = scrubber.scrub_N2O))
				refresh_outlets()
				to_chat(user, "<span class='notice'>Successfully added an outlet scrubber</span>")
				return
			else
				to_chat(user, "<span class='warning'>Error: No compatible device in multitool buffer</span>")
				return

		if("Remove")
			var/list/namelist = list()

			for(var/uid in outlet_vent_data)
				namelist += outlet_vent_data[uid]["name"]
			for(var/uid in outlet_scrubber_data)
				namelist += outlet_scrubber_data[uid]["name"]

			choice = tgui_input_list(user, "Select an outlet to remove", "outlet Selection", namelist)
			for(var/uid in outlet_uids)
				if((outlet_vent_data[uid] && choice == outlet_vent_data[uid]["name"]) || (outlet_scrubber_data[uid] && choice == outlet_scrubber_data[uid]["name"]))
					var/obj/machinery/atmospherics/unary/outlet = locateUID(uid)
					if(!QDELETED(outlet))
						outlet.on = FALSE
						outlet.update_icon()
					outlet_scrubber_data -= uid
					outlet_vent_data -= uid
					outlet_uids -= uid
					break

		if("Clear")
			if(length(outlet_uids))
				var/obj/machinery/atmospherics/unary/outlet
				for(var/uid in outlet_uids)
					outlet = locateUID(uid)
					if(!QDELETED(outlet))
						outlet.on = FALSE
						outlet.update_icon()
				outlet_uids = list()
				outlet_scrubber_data = list()
				outlet_vent_data = list()
				refresh_outlets()
				to_chat(user, "<span class='notice'>Successfully unlinked outlet vent.</span>")
			else
				to_chat(user, "<span class='warning'>Error - No outlets linked!</span>")


/obj/machinery/computer/general_air_control/large_tank_control/proc/refresh_inlets()
	for(var/uid in inlet_uids)
		var/obj/machinery/atmospherics/unary/outlet_injector/inlet_injector = locateUID(uid)
		if(QDELETED(inlet_injector))
			inlet_data -= uid
			inlet_uids -= uid
			continue
		inlet_data[uid]["name"] = inlet_injector.name
		inlet_data[uid]["on"] = inlet_injector.on
		inlet_data[uid]["rate"] = inlet_injector.volume_rate

/obj/machinery/computer/general_air_control/large_tank_control/proc/refresh_outlets()
	var/obj/machinery/atmospherics/unary/outlet
	for(var/uid in outlet_uids)
		outlet = locateUID(uid)
		if(istype(outlet, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/vent = outlet
			if(QDELETED(vent))
				outlet_scrubber_data -= uid
				outlet_vent_data -= uid
				outlet_uids -= uid
				continue
			outlet_vent_data[uid]["name"] = vent.name
			outlet_vent_data[uid]["on"] = vent.on
			outlet_vent_data[uid]["checks"] = vent.pressure_checks
			outlet_vent_data[uid]["rate"] = vent.pressure_checks == 1 ? vent.external_pressure_bound : vent.internal_pressure_bound
		if(istype(outlet, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/scrubber = outlet
			if(QDELETED(scrubber))
				outlet_scrubber_data -= uid
				outlet_vent_data -= uid
				outlet_uids -= uid
				continue
			outlet_scrubber_data[uid]["id_tag"] = scrubber.UID()
			outlet_scrubber_data[uid]["name"] = scrubber.name
			outlet_scrubber_data[uid]["power"] = scrubber.on
			outlet_scrubber_data[uid]["scrubbing"] = scrubber.scrubbing
			outlet_scrubber_data[uid]["widenet"] = scrubber.widenet
			outlet_scrubber_data[uid]["filter_o2"] = scrubber.scrub_O2
			outlet_scrubber_data[uid]["filter_n2"] = scrubber.scrub_N2
			outlet_scrubber_data[uid]["filter_co2"] = scrubber.scrub_CO2
			outlet_scrubber_data[uid]["filter_toxins"] = scrubber.scrub_Toxins
			outlet_scrubber_data[uid]["filter_n2o"] = scrubber.scrub_N2O

/obj/machinery/computer/general_air_control/large_tank_control/refresh_all()
	..()
	refresh_inlets()
	refresh_outlets()

/obj/machinery/computer/general_air_control/large_tank_control/ui_data(mob/user)
	. = ..()
// This is done so we can use map() in tgui.
	var/list/ui_inlet_data = list()
	var/list/ui_outlet_vent_data = list()
	var/list/ui_outlet_scrubber_data = list()
	for(var/id in inlet_data)
		ui_inlet_data.Add(list(inlet_data[id]))
	for(var/id in outlet_vent_data)
		ui_outlet_vent_data.Add(list(outlet_vent_data[id]))
	for(var/id in outlet_scrubber_data)
		ui_outlet_scrubber_data.Add(list(outlet_scrubber_data[id]))

	.["inlets"] = ui_inlet_data
	.["vent_outlets"] = ui_outlet_vent_data
	.["scrubber_outlets"] = ui_outlet_scrubber_data

/obj/machinery/computer/general_air_control/large_tank_control/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("toggle_inlet_active")
			var/obj/machinery/atmospherics/unary/outlet_injector/inlet_injector = locateUID(params["dev"])
			if(!QDELETED(inlet_injector))
				inlet_injector.on = !inlet_injector.on
				inlet_injector.update_icon()
				refresh_inlets()
		if("toggle_outlet_active")
			var/obj/machinery/atmospherics/unary/vent_pump/outlet_vent = locateUID(params["dev"])
			if(!QDELETED(outlet_vent))
				outlet_vent.on = !outlet_vent.on
				outlet_vent.update_icon()
				refresh_outlets()

		if("set_inlet_volume_rate")
			var/obj/machinery/atmospherics/unary/outlet_injector/inlet_injector = locateUID(params["dev"])
			if(!QDELETED(inlet_injector))
				var/new_value = clamp(text2num(params["val"]), 0, 50)
				if(new_value)
					inlet_injector.volume_rate = new_value
					refresh_inlets()

		if("set_outlet_reference")
			var/obj/machinery/atmospherics/unary/vent_pump/outlet_vent = locateUID(params["dev"])
			if(!QDELETED(outlet_vent))
				outlet_vent.pressure_checks = text2num(params["val"])
				refresh_outlets()

		if("set_outlet_pressure")
			var/obj/machinery/atmospherics/unary/vent_pump/outlet_vent = locateUID(params["dev"])
			if(!QDELETED(outlet_vent))
				if(outlet_vent.pressure_checks == 1)
					outlet_vent.external_pressure_bound = text2num(params["val"])
					refresh_outlets()
				else
					outlet_vent.internal_pressure_bound = text2num(params["val"])
					refresh_outlets()
		if("command")
			var/device_id = params["id_tag"]
			var/cmd = params["cmd"]
			var/obj/machinery/atmospherics/unary/vent_scrubber/scrubber = locateUID(device_id)

			if(scrubber.stat & (NOPOWER|BROKEN))
				return

			switch(cmd)
				if("power")
					scrubber.on = !scrubber.on
				if("co2_scrub")
					scrubber.scrub_CO2 = !scrubber.scrub_CO2
				if("tox_scrub")
					scrubber.scrub_Toxins = !scrubber.scrub_Toxins
				if("n2o_scrub")
					scrubber.scrub_N2O = !scrubber.scrub_N2O
				if("n2_scrub")
					scrubber.scrub_N2 = !scrubber.scrub_N2
				if("o2_scrub")
					scrubber.scrub_O2 = !scrubber.scrub_O2
				if("widenet")
					scrubber.widenet = !scrubber.widenet
				if("scrubbing")
					scrubber.scrubbing = !scrubber.scrubbing
			refresh_outlets()
			scrubber.update_icon(UPDATE_ICON_STATE)

	return TRUE

// Central atmos control //
/obj/machinery/computer/atmoscontrol
	name = "central atmospherics computer"
	icon_keyboard = "atmos_key"
	icon_screen = "tank"
	light_color = LIGHT_COLOR_CYAN
	circuit = /obj/item/circuitboard/atmoscontrol
	req_access = list(ACCESS_ATMOSPHERICS)
	var/datum/ui_module/atmos_control/atmos_control
	var/parent_area_type

/obj/machinery/computer/atmoscontrol/Initialize(mapload)
	. = ..()
	atmos_control = new(src)
	var/area/machine_area = get_area(src)
	parent_area_type = machine_area.get_top_parent_type()
	atmos_control.parent_area_type = parent_area_type
	atmos_control.z_level = z

/obj/machinery/computer/atmoscontrol/Destroy()
	QDEL_NULL(atmos_control)
	return ..()

/obj/machinery/computer/atmoscontrol/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/computer/atmoscontrol/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/atmoscontrol/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/atmoscontrol/ui_interact(mob/user, datum/tgui/ui = null)
	atmos_control.ui_interact(user, ui)


#undef SENSOR_PRESSURE
#undef SENSOR_TEMPERATURE
#undef SENSOR_O2
#undef SENSOR_PLASMA
#undef SENSOR_N2
#undef SENSOR_CO2
#undef SENSOR_N2O
