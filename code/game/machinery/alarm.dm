// A datum for dealing with threshold limit values
// used in /obj/machinery/alarm
/datum/tlv
	var/min2
	var/min1
	var/max1
	var/max2

/datum/tlv/New(_min2 as num, _min1 as num, _max1 as num, _max2 as num)
	min2 = _min2
	min1 = _min1
	max1 = _max1
	max2 = _max2

/datum/tlv/proc/get_danger_level(curval as num)
	if(max2 >=0 && curval>max2)
		return ATMOS_ALARM_DANGER
	if(min2 >=0 && curval<min2)
		return ATMOS_ALARM_DANGER
	if(max1 >=0 && curval>max1)
		return ATMOS_ALARM_WARNING
	if(min1 >=0 && curval<min1)
		return ATMOS_ALARM_WARNING
	return ATMOS_ALARM_NONE

/datum/tlv/proc/CopyFrom(datum/tlv/other)
	min2 = other.min2
	min1 = other.min1
	max1 = other.max1
	max2 = other.max2

#define AALARM_MODE_SCRUBBING 1
#define AALARM_MODE_VENTING 2 //makes draught
#define AALARM_MODE_PANIC 3 //like siphon, but stronger (enables widenet)
#define AALARM_MODE_REPLACEMENT 4 //sucks off all air, then refill and swithes to scrubbing
#define AALARM_MODE_SIPHON 5 //Scrubbers suck air
#define AALARM_MODE_CONTAMINATED 6 //Turns on all filtering and widenet scrubbing.
#define AALARM_MODE_REFILL 7 //just like normal, but with triple the air output
#define AALARM_MODE_OFF 8
#define AALARM_MODE_FLOOD 9 //Emagged mode; turns off scrubbers and pressure checks on vents

#define AALARM_PRESET_HUMAN     1 // Default
#define AALARM_PRESET_VOX       2 // Support Vox
#define AALARM_PRESET_COLDROOM  3 // Kitchen coldroom
#define AALARM_PRESET_SERVER    4 // Server coldroom

#define AALARM_REPORT_TIMEOUT 100

#define RCON_NO		1
#define RCON_AUTO	2
#define RCON_YES	3

//1000 joules equates to about 1 degree every 2 seconds for a single tile of air.
#define MAX_ENERGY_CHANGE 1000

#define MAX_TEMPERATURE 363.15 // 90C
#define MIN_TEMPERATURE 233.15 // -40C

#define AIR_ALARM_FRAME		0
#define AIR_ALARM_BUILDING	1
#define AIR_ALARM_READY		2

//all air alarms in area are connected via magic
/area
	var/obj/machinery/alarm/master_air_alarm
	var/list/air_vent_names = list()
	var/list/air_scrub_names = list()
	var/list/air_vent_info = list()
	var/list/air_scrub_info = list()

/obj/machinery/alarm
	name = "alarm"
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "alarm0"
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 8
	power_channel = ENVIRON
	req_access = list(ACCESS_ATMOSPHERICS, ACCESS_ENGINE_EQUIP)
	max_integrity = 250
	integrity_failure = 80
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 30)
	resistance_flags = FIRE_PROOF
	siemens_strength = 1
	frequency = ATMOS_VENTSCRUB
	var/alarm_id = null
	//var/skipprocess = 0 //Experimenting
	var/alarm_frequency = ATMOS_FIRE_FREQ
	var/remote_control = TRUE
	var/rcon_setting = RCON_AUTO
	var/rcon_time = 0
	var/locked = 1
	var/datum/wires/alarm/wires = null
	var/wiresexposed = 0 // If it's been screwdrivered open.
	var/aidisabled = 0
	var/AAlarmwires = 31
	var/shorted = 0

	// Waiting on a device to respond.
	// Specifies an id_tag.  NULL means we aren't waiting.
	var/waiting_on_device = null

	var/mode = AALARM_MODE_SCRUBBING
	var/preset = AALARM_PRESET_HUMAN
	var/area_uid
	var/area/alarm_area
	var/danger_level = ATMOS_ALARM_NONE
	var/alarmActivated = 0 // Manually activated (independent from danger level)

	var/buildstage = AIR_ALARM_READY

	var/target_temperature = T20C
	var/regulating_temperature = 0
	var/thermostat_state = FALSE

	var/list/TLV = list()

	var/report_danger_level = TRUE

/obj/machinery/alarm/monitor
	report_danger_level = FALSE

/obj/machinery/alarm/syndicate //general syndicate access
	report_danger_level = FALSE
	remote_control = FALSE
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/alarm/monitor/server
	preset = AALARM_PRESET_SERVER

/obj/machinery/alarm/server
	preset = AALARM_PRESET_SERVER

/obj/machinery/alarm/vox
	preset = AALARM_PRESET_VOX

/obj/machinery/alarm/kitchen_cold_room
	preset = AALARM_PRESET_COLDROOM

/obj/machinery/alarm/proc/apply_preset(var/no_cycle_after=0)
	// Propogate settings.
	for(var/obj/machinery/alarm/AA in alarm_area)
		if(!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted && AA.preset != src.preset)
			AA.preset=preset
			apply_preset(1) // Only this air alarm should send a cycle.

	TLV = list (
		"oxygen"         = new/datum/tlv(16, 19, 135, 140), // Partial pressure, kpa
		"nitrogen"       = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // Partial pressure, kpa
		"carbon dioxide" = new/datum/tlv(-1.0, -1.0, 5,  10), // Partial pressure, kpa
		"plasma"         = new/datum/tlv(-1.0, -1.0, 0.2, 0.5), // Partial pressure, kpa
		"other"          = new/datum/tlv(-1.0, -1.0, 0.5, 1.0), // Partial pressure, kpa
		"pressure"       = new/datum/tlv(ONE_ATMOSPHERE*0.80,ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE*1.10,ONE_ATMOSPHERE*1.20), /* kpa */
		"temperature"    = new/datum/tlv(T0C, T0C+10, T0C+40, T0C+66), // K
	)
	switch(preset)
		if(AALARM_PRESET_VOX)
			TLV = list(
				"oxygen"         = new/datum/tlv(-1.0, -1.0, 1, 2), // Partial pressure, kpa
				"nitrogen"       = new/datum/tlv(16, 19, 135, 140), // Partial pressure, kpa
				"carbon dioxide" = new/datum/tlv(-1.0, -1.0, 5,  10), // Partial pressure, kpa
				"plasma"         = new/datum/tlv(-1.0, -1.0, 0.2, 0.5), // Partial pressure, kpa
				"other"          = new/datum/tlv(-1.0, -1.0, 0.5, 1.0), // Partial pressure, kpa
				"pressure"       = new/datum/tlv(ONE_ATMOSPHERE*0.80,ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE*1.10,ONE_ATMOSPHERE*1.20), /* kpa */
				"temperature"    = new/datum/tlv(T0C, T0C+10, T0C+40, T0C+66), // K
			)
		if(AALARM_PRESET_COLDROOM)
			TLV = list(
				"oxygen"         = new/datum/tlv(16, 19, 135, 140), // Partial pressure, kpa
				"nitrogen"       = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // Partial pressure, kpa
				"carbon dioxide" = new/datum/tlv(-1.0, -1.0,   5,  10), // Partial pressure, kpa
				"plasma"         = new/datum/tlv(-1.0, -1.0, 0.2, 0.5), // Partial pressure, kpa
				"other"          = new/datum/tlv(-1.0, -1.0, 0.5, 1.0), // Partial pressure, kpa
				"pressure"       = new/datum/tlv(ONE_ATMOSPHERE*0.80,ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE*1.50,ONE_ATMOSPHERE*1.60), /* kpa */
				"temperature"    = new/datum/tlv(T0C-50, T0C-20, T0C, T20C), // K
			)
		if(AALARM_PRESET_SERVER)
			TLV = list(
				"oxygen"         = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // Partial pressure, kpa
				"nitrogen"       = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // Partial pressure, kpa
				"carbon dioxide" = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // Partial pressure, kpa
				"plasma"         = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // Partial pressure, kpa
				"other"          = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // Partial pressure, kpa
				"pressure"       = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), /* kpa */
				"temperature"    = new/datum/tlv(0, 0, T20C + 5, T20C + 15), // K
			)

	if(!no_cycle_after)
		mode = AALARM_MODE_REPLACEMENT
		apply_mode()

/obj/machinery/alarm/New(loc, direction, building = 0)
	. = ..()
	GLOB.air_alarms += src
	GLOB.air_alarms = sortAtom(GLOB.air_alarms)

	wires = new(src)

	if(building)
		if(loc)
			src.loc = loc

		if(dir)
			setDir(direction)

		buildstage = 0
		wiresexposed = 1
		set_pixel_offsets_from_dir(-24, 24, -24, 24)
		update_icon()
		return

	first_run()

/obj/machinery/alarm/Destroy()
	SStgui.close_uis(wires)
	GLOB.air_alarms -= src
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	GLOB.air_alarm_repository.update_cache(src)
	QDEL_NULL(wires)
	if(alarm_area && alarm_area.master_air_alarm == src)
		alarm_area.master_air_alarm = null
		elect_master(exclude_self = 1)
	alarm_area = null
	return ..()

/obj/machinery/alarm/proc/first_run()
	alarm_area = get_area(src)
	area_uid = alarm_area.uid
	if(name == "alarm")
		name = "[alarm_area.name] Air Alarm"
	apply_preset(1) // Don't cycle.
	GLOB.air_alarm_repository.update_cache(src)

/obj/machinery/alarm/Initialize()
	..()
	set_frequency(frequency)
	if(is_taipan(z)) // Синдидоступ при сборке на тайпане
		req_access = list(ACCESS_SYNDICATE)

	if(!master_is_operating())
		elect_master()

/obj/machinery/alarm/proc/master_is_operating()
	if(!alarm_area)
		alarm_area = get_area(src)
	if(!alarm_area)
		log_runtime(EXCEPTION("Air alarm /obj/machinery/alarm lacks alarm_area vars during proc/master_is_operating()"), src)
		return FALSE
	return alarm_area.master_air_alarm && !(alarm_area.master_air_alarm.stat & (NOPOWER|BROKEN))


/obj/machinery/alarm/proc/elect_master(exclude_self = 0) //Why is this an alarm and not area proc?
	for(var/obj/machinery/alarm/AA in alarm_area)
		if(exclude_self && AA == src)
			continue
		if(!(AA.stat & (NOPOWER|BROKEN)))
			alarm_area.master_air_alarm = AA
			return 1
	return 0

/obj/machinery/alarm/process()
	if((stat & (NOPOWER|BROKEN)) || shorted || buildstage != 2)
		return

	var/turf/simulated/location = loc
	if(!istype(location))
		return 0

	var/datum/gas_mixture/environment = location.return_air()
	var/datum/tlv/cur_tlv

	handle_heating_cooling(environment, cur_tlv, location)

	var/GET_PP = R_IDEAL_GAS_EQUATION*environment.temperature/environment.volume

	cur_tlv = TLV["pressure"]
	var/environment_pressure = environment.return_pressure()
	var/pressure_dangerlevel = cur_tlv.get_danger_level(environment_pressure)

	cur_tlv = TLV["oxygen"]
	var/oxygen_dangerlevel = cur_tlv.get_danger_level(environment.oxygen*GET_PP)

	cur_tlv = TLV["nitrogen"]
	var/nitrogen_dangerlevel = cur_tlv.get_danger_level(environment.nitrogen*GET_PP)

	cur_tlv = TLV["carbon dioxide"]
	var/co2_dangerlevel = cur_tlv.get_danger_level(environment.carbon_dioxide*GET_PP)

	cur_tlv = TLV["plasma"]
	var/plasma_dangerlevel = cur_tlv.get_danger_level(environment.toxins*GET_PP)

	cur_tlv = TLV["other"]
	var/other_dangerlevel = cur_tlv.get_danger_level(environment.total_trace_moles() * GET_PP)

	cur_tlv = TLV["temperature"]
	var/temperature_dangerlevel = cur_tlv.get_danger_level(environment.temperature)

	var/old_danger_level = danger_level
	danger_level = max(
		pressure_dangerlevel,
		oxygen_dangerlevel,
		nitrogen_dangerlevel,
		co2_dangerlevel,
		plasma_dangerlevel,
		other_dangerlevel,
		temperature_dangerlevel
	)

	if(old_danger_level != danger_level)
		apply_danger_level()

	if(mode == AALARM_MODE_REPLACEMENT && environment_pressure < ONE_ATMOSPHERE * 0.05)
		mode = AALARM_MODE_SCRUBBING
		apply_mode()


/obj/machinery/alarm/proc/handle_heating_cooling(datum/gas_mixture/environment, datum/tlv/cur_tlv, turf/simulated/location)
	cur_tlv = TLV["temperature"]
	//Handle temperature adjustment here.
	if(environment.temperature < target_temperature - 2 || environment.temperature > target_temperature + 2 || regulating_temperature)
		//If it goes too far, we should adjust ourselves back before stopping.
		if(!cur_tlv.get_danger_level(target_temperature))
			var/datum/gas_mixture/gas = location.remove_air(0.25 * environment.total_moles())
			if(!gas)
				return
			if(!regulating_temperature && thermostat_state)
				regulating_temperature = TRUE
				visible_message("\The [src] clicks as it starts [environment.temperature > target_temperature ? "cooling" : "heating"] the room.", "You hear a click and a faint electronic hum.")

			if(target_temperature > MAX_TEMPERATURE)
				target_temperature = MAX_TEMPERATURE

			if(target_temperature < MIN_TEMPERATURE)
				target_temperature = MIN_TEMPERATURE

			if(thermostat_state)
				var/heat_capacity = gas.heat_capacity()
				var/energy_used = max(abs(heat_capacity * (gas.temperature - target_temperature) ), MAX_ENERGY_CHANGE)

				//Use power.  Assuming that each power unit represents 1000 watts....
				use_power(energy_used / 1000, ENVIRON)

				//We need to cool ourselves.
				if(heat_capacity)
					if(environment.temperature > target_temperature)
						gas.temperature -= energy_used / heat_capacity
					else
						gas.temperature += energy_used / heat_capacity

				if(abs(environment.temperature - target_temperature) <= 0.5)
					regulating_temperature = FALSE
					visible_message("[src] clicks quietly as it stops [environment.temperature > target_temperature ? "cooling" : "heating"] the room.", "You hear a click as a faint electronic humming stops.")

			environment.merge(gas)

/obj/machinery/alarm/update_icon()
	if(wiresexposed)
		icon_state = "alarmx"
		set_light(0)
		return
	if((stat & (NOPOWER|BROKEN)) || shorted)
		icon_state = "alarmp"
		set_light(0)
		return

	var/new_color = null
	switch(max(danger_level, alarm_area.atmosalm-1))
		if(ATMOS_ALARM_NONE)
			icon_state = "alarm0"
			new_color = COLOR_GREEN
		if(ATMOS_ALARM_WARNING)
			icon_state = "alarm2" //yes, alarm2 is yellow alarm
			new_color = COLOR_YELLOW
		if(ATMOS_ALARM_DANGER)
			icon_state = "alarm1"
			new_color = COLOR_RED

	set_light(1, 1, new_color)

/obj/machinery/alarm/proc/register_env_machine(m_id, device_type)
	var/new_name
	if(device_type=="AVP")
		new_name = "[alarm_area.name] Vent Pump #[alarm_area.air_vent_names.len+1]"
		alarm_area.air_vent_names[m_id] = new_name
	else if(device_type=="AScr")
		new_name = "[alarm_area.name] Air Scrubber #[alarm_area.air_scrub_names.len+1]"
		alarm_area.air_scrub_names[m_id] = new_name
	else
		return
	spawn (10)
		send_signal(m_id, list("init" = new_name) )

/obj/machinery/alarm/proc/refresh_all()
	for(var/id_tag in alarm_area.air_vent_names)
		var/list/I = alarm_area.air_vent_info[id_tag]
		if(I && I["timestamp"]+AALARM_REPORT_TIMEOUT/2 > world.time)
			continue
		send_signal(id_tag, list("status") )
	for(var/id_tag in alarm_area.air_scrub_names)
		var/list/I = alarm_area.air_scrub_info[id_tag]
		if(I && I["timestamp"]+AALARM_REPORT_TIMEOUT/2 > world.time)
			continue
		send_signal(id_tag, list("status") )

/obj/machinery/alarm/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_TO_AIRALARM)

/obj/machinery/alarm/proc/send_signal(target, list/command)//sends signal 'command' to 'target'. Returns 0 if no radio connection, 1 otherwise
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = command
	signal.data["tag"] = target
	signal.data["sigtype"] = "command"

	radio_connection.post_signal(src, signal, RADIO_FROM_AIRALARM)
	return TRUE

/obj/machinery/alarm/proc/apply_mode()
	switch(mode)
		if(AALARM_MODE_SCRUBBING)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 1,
					"o2_scrub" = (preset==AALARM_PRESET_VOX),
					"n2_scrub" = 0,
					"co2_scrub"= 1,
					"scrubbing"= 1,
					"widenet"= 0,
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 1,
					"checks"= 1,
					"set_external_pressure"= ONE_ATMOSPHERE
				))
		if(AALARM_MODE_CONTAMINATED)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 1,
					"co2_scrub"= 1,
					"tox_scrub"= 1,
					"n2o_scrub"= 1,
					"scrubbing"= 1,
					"widenet"= 1,
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 1,
					"checks"= 1,
					"set_external_pressure"= ONE_ATMOSPHERE
				))
		if(AALARM_MODE_VENTING)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 1,
					"widenet"= 0,
					"scrubbing"= 0
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 1,
					"checks"= 1,
					"set_external_pressure" = ONE_ATMOSPHERE*2
				))
		if(AALARM_MODE_REFILL)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 1,
					"co2_scrub"= 1,
					"tox_scrub"= 0,
					"n2o_scrub"= 0,
					"scrubbing"= 1,
					"widenet"= 0,
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 1,
					"checks"= 1,
					"set_external_pressure" = ONE_ATMOSPHERE*3
				))
		if(
			AALARM_MODE_PANIC,
			AALARM_MODE_REPLACEMENT
		)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 1,
					"widenet"= 1,
					"scrubbing"= 0
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 0
				))
		if(
			AALARM_MODE_SIPHON
		)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 1,
					"widenet"= 0,
					"scrubbing"= 0
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 0
				))

		if(AALARM_MODE_OFF)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 0
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 0
				))
		if(AALARM_MODE_FLOOD)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"=0
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 1,
					"checks"= 0,
				))

/obj/machinery/alarm/proc/apply_danger_level()
	var/new_area_danger_level = ATMOS_ALARM_NONE
	for(var/obj/machinery/alarm/AA in alarm_area)
		if(!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
			new_area_danger_level = max(new_area_danger_level, AA.danger_level)
	if(alarm_area.atmosalert(new_area_danger_level, src)) //if area was in normal state or if area was in alert state
		post_alert(new_area_danger_level)

	update_icon()

/obj/machinery/alarm/proc/post_alert(alert_level)
	if(!report_danger_level)
		return
	var/datum/radio_frequency/frequency = SSradio.return_frequency(alarm_frequency)

	if(!frequency)
		return

	var/datum/signal/alert_signal = new
	alert_signal.source = src
	alert_signal.transmission_method = 1
	alert_signal.data["zone"] = get_area_name(src, TRUE)
	alert_signal.data["type"] = "Atmospheric"

	if(alert_level == ATMOS_ALARM_DANGER)
		alert_signal.data["alert"] = "severe"
	else if(alert_level == ATMOS_ALARM_WARNING)
		alert_signal.data["alert"] = "minor"
	else if(alert_level == ATMOS_ALARM_NONE)
		alert_signal.data["alert"] = "clear"

	frequency.post_signal(src, alert_signal)

///////////////
//END HACKING//
///////////////

/obj/machinery/alarm/attack_ai(mob/user)
	if(buildstage != 2)
		return

	add_hiddenprint(user)
	return ui_interact(user)

/obj/machinery/alarm/attack_ghost(mob/user)
	return interact(user)

/obj/machinery/alarm/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	return interact(user)

/obj/machinery/alarm/interact(mob/user)
	if(buildstage != 2)
		return

	if(wiresexposed)
		wires.Interact(user)

	if(!shorted)
		ui_interact(user)

/obj/machinery/alarm/proc/ui_air_status()
	var/turf/location = get_turf(src)
	if(!istype(location))
		return

	var/datum/gas_mixture/environment = location.return_air()
	var/known_total = environment.oxygen + environment.nitrogen + environment.carbon_dioxide + environment.toxins
	var/total = environment.total_moles()
	if(total == 0)
		return null

	var/datum/tlv/cur_tlv
	var/GET_PP = R_IDEAL_GAS_EQUATION*environment.temperature/environment.volume

	cur_tlv = TLV["pressure"]
	var/environment_pressure = environment.return_pressure()
	var/pressure_dangerlevel = cur_tlv.get_danger_level(environment_pressure)

	cur_tlv = TLV["oxygen"]
	var/oxygen_dangerlevel = cur_tlv.get_danger_level(environment.oxygen*GET_PP)
	var/oxygen_percent = environment.oxygen / total * 100

	cur_tlv = TLV["nitrogen"]
	var/nitrogen_dangerlevel = cur_tlv.get_danger_level(environment.nitrogen*GET_PP)
	var/nitrogen_percent = environment.nitrogen / total * 100

	cur_tlv = TLV["carbon dioxide"]
	var/co2_dangerlevel = cur_tlv.get_danger_level(environment.carbon_dioxide*GET_PP)
	var/co2_percent = environment.carbon_dioxide / total * 100

	cur_tlv = TLV["plasma"]
	var/plasma_dangerlevel = cur_tlv.get_danger_level(environment.toxins*GET_PP)
	var/plasma_percent = environment.toxins / total * 100

	cur_tlv = TLV["other"]
	var/other_moles = total - known_total
	var/other_dangerlevel = cur_tlv.get_danger_level(other_moles*GET_PP)
	var/other_percent = other_moles / total * 100

	cur_tlv = TLV["temperature"]
	var/temperature_dangerlevel = cur_tlv.get_danger_level(environment.temperature)

	var/list/data = list()
	data["pressure"] = environment_pressure
	data["temperature"] = environment.temperature
	data["temperature_c"] = round(environment.temperature - T0C, 0.1)
	data["thermostat_state"] = thermostat_state

	var/list/percentages = list()
	percentages["oxygen"] = oxygen_percent
	percentages["nitrogen"] = nitrogen_percent
	percentages["co2"] = co2_percent
	percentages["plasma"] = plasma_percent
	percentages["other"] = other_percent
	data["contents"] = percentages

	var/list/danger = list()
	danger["pressure"] = pressure_dangerlevel
	danger["temperature"] = temperature_dangerlevel
	danger["oxygen"] = oxygen_dangerlevel
	danger["nitrogen"] = nitrogen_dangerlevel
	danger["co2"] = co2_dangerlevel
	danger["plasma"] = plasma_dangerlevel
	danger["other"] = other_dangerlevel
	danger["overall"] = max(pressure_dangerlevel,oxygen_dangerlevel,nitrogen_dangerlevel,co2_dangerlevel,plasma_dangerlevel,other_dangerlevel,temperature_dangerlevel)
	data["danger"] = danger
	return data

/obj/machinery/alarm/proc/has_rcon_access(mob/user)
	return user && (isAI(user) || allowed(user) || emagged || rcon_setting == RCON_YES)

// Intentional nulls here
/obj/machinery/alarm/ui_data(mob/user)
	var/list/data = list()

	data["name"] = sanitize(name)
	data["air"] = ui_air_status()
	data["alarmActivated"] = alarmActivated || danger_level == ATMOS_ALARM_DANGER
	data["thresholds"] = generate_thresholds_menu()

	// Locked when:
	//   Not sent from atmos console AND
	//   Not silicon AND locked.
	var/datum/tgui/active_ui = SStgui.get_open_ui(user, src, "main")
	data["locked"] = !is_authenticated(user, active_ui)
	data["rcon"] = rcon_setting
	data["target_temp"] = target_temperature - T0C
	data["atmos_alarm"] = alarm_area.atmosalm
	data["emagged"] = emagged
	data["modes"] = list(
		AALARM_MODE_SCRUBBING   = list("name"="Filtering",   "desc"="Scrubs out contaminants", "id" = AALARM_MODE_SCRUBBING),\
		AALARM_MODE_VENTING		= list("name"="Draught", 	 "desc"="Siphons out air while replacing", "id" = AALARM_MODE_VENTING),\
		AALARM_MODE_PANIC       = list("name"="Panic Siphon","desc"="Siphons air out of the room quickly", "id" = AALARM_MODE_PANIC),\
		AALARM_MODE_REPLACEMENT = list("name"="Cycle",       "desc"="Siphons air before replacing", "id" = AALARM_MODE_REPLACEMENT),\
		AALARM_MODE_SIPHON	    = list("name"="Siphon",		 "desc"="Siphons air out of the room", "id" = AALARM_MODE_SIPHON),\
		AALARM_MODE_CONTAMINATED= list("name"="Contaminated","desc"="Scrubs out all contaminants quickly", "id" = AALARM_MODE_CONTAMINATED),\
		AALARM_MODE_REFILL      = list("name"="Refill",      "desc"="Triples vent output", "id" = AALARM_MODE_REFILL),\
		AALARM_MODE_OFF         = list("name"="Off",         "desc"="Shuts off vents and scrubbers", "id" = AALARM_MODE_OFF),\
		AALARM_MODE_FLOOD 		= list("name"="Flood", 		 "desc"="Shuts off scrubbers and opens vents", 	"emagonly" = TRUE, "id" = AALARM_MODE_FLOOD)
	)
	data["mode"] = mode
	data["presets"] = list(
		AALARM_PRESET_HUMAN		= list("name"="Human",     	 "desc"="Checks for oxygen and nitrogen", "id" = AALARM_PRESET_HUMAN),\
		AALARM_PRESET_VOX 		= list("name"="Vox",       	 "desc"="Checks for nitrogen only", "id" = AALARM_PRESET_VOX),\
		AALARM_PRESET_COLDROOM 	= list("name"="Coldroom", 	 "desc"="For freezers", "id" = AALARM_PRESET_COLDROOM),\
		AALARM_PRESET_SERVER 	= list("name"="Server Room", "desc"="For server rooms", "id" = AALARM_PRESET_SERVER)
	)
	data["preset"] = preset

	var/list/vents = list()
	if(alarm_area.air_vent_names.len)
		for(var/id_tag in alarm_area.air_vent_names)
			var/list/vent_info = list()
			var/long_name = alarm_area.air_vent_names[id_tag]
			var/list/vent_data = alarm_area.air_vent_info[id_tag]
			if(!vent_data)
				continue
			vent_info["id_tag"] = id_tag
			vent_info["name"] = sanitize(long_name)
			vent_info += vent_data
			vents += list(vent_info)
	data["vents"] = vents

	var/list/scrubbers = list()
	if(alarm_area.air_scrub_names.len)
		for(var/id_tag in alarm_area.air_scrub_names)
			var/long_name = alarm_area.air_scrub_names[id_tag]
			var/list/scrubber_data = alarm_area.air_scrub_info[id_tag]
			if(!scrubber_data)
				continue
			scrubber_data["id_tag"] = id_tag
			scrubber_data["name"] = sanitize(long_name)
			scrubbers += list(scrubber_data)
	data["scrubbers"] = scrubbers
	return data

/obj/machinery/alarm/proc/get_console_data(mob/user)
	var/list/data = list()
	data["name"] = sanitize(name)
	data["ref"] = "\ref[src]"
	data["danger"] = max(danger_level, alarm_area.atmosalm)
	var/area/A = get_area(src)
	data["area"] = sanitize(A.name)
	var/turf/T = get_turf(src)
	data["x"] = T.x
	data["y"] = T.y
	data["z"] = T.z
	return data

/obj/machinery/alarm/proc/generate_thresholds_menu()
	var/datum/tlv/selected
	var/list/thresholds = list()

	var/list/gas_names = list(
		"oxygen"         = "O2",
		"nitrogen"       = "N2",
		"carbon dioxide" = "CO2",
		"plasma"         = "Toxin",
		"other"          = "Other")
	for(var/g in gas_names)
		thresholds += list(list("name" = gas_names[g], "settings" = list()))
		selected = TLV[g]
		thresholds[thresholds.len]["settings"] += list(list("env" = g, "val" = "min2", "selected" = selected.min2))
		thresholds[thresholds.len]["settings"] += list(list("env" = g, "val" = "min1", "selected" = selected.min1))
		thresholds[thresholds.len]["settings"] += list(list("env" = g, "val" = "max1", "selected" = selected.max1))
		thresholds[thresholds.len]["settings"] += list(list("env" = g, "val" = "max2", "selected" = selected.max2))

	selected = TLV["pressure"]
	thresholds += list(list("name" = "Pressure", "settings" = list()))
	thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "min2", "selected" = selected.min2))
	thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "min1", "selected" = selected.min1))
	thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "max1", "selected" = selected.max1))
	thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "max2", "selected" = selected.max2))

	selected = TLV["temperature"]
	thresholds += list(list("name" = "Temperature", "settings" = list()))
	thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "min2", "selected" = selected.min2))
	thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "min1", "selected" = selected.min1))
	thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "max1", "selected" = selected.max1))
	thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "max2", "selected" = selected.max2))

	return thresholds

/obj/machinery/alarm/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AirAlarm", name, 570, 410, master_ui, state)
		ui.open()

/obj/machinery/alarm/proc/is_authenticated(mob/user, datum/tgui/ui=null)
	// Return true if they are connecting with a remote console
	// DO NOT CHANGE THIS TO USE ISTYPE, IT WILL NOT WORK
	if(ui?.master_ui?.src_object.type == /datum/ui_module/atmos_control)
		return TRUE
	if(user.can_admin_interact())
		return TRUE
	else if(isAI(user) || (isrobot(user) || emagged) && !iscogscarab(user))
		return TRUE
	else
		return !locked

/obj/machinery/alarm/ui_status(mob/user, datum/ui_state/state)
	if(buildstage != 2)
		return STATUS_CLOSE

	if(aidisabled && (isAI(user) || isrobot(user)))
		to_chat(user, "<span class='warning'>AI control for \the [src] interface has been disabled.</span>")
		return STATUS_CLOSE

	. = shorted ? STATUS_DISABLED : STATUS_INTERACTIVE

	return min(..(), .)

// TODO: Refactor these utter pieces of garbage
/obj/machinery/alarm/ui_act(action, list/params)
	if(..())
		return

	add_fingerprint(usr)

	. = TRUE

	// Used for rcon auth
	var/datum/tgui/active_ui = SStgui.get_open_ui(usr, src, "main")

	switch(action)
		if("set_rcon")
			var/attempted_rcon_setting = text2num(params["rcon"])
			switch(attempted_rcon_setting)
				if(RCON_NO)
					rcon_setting = RCON_NO
				if(RCON_AUTO)
					rcon_setting = RCON_AUTO
				if(RCON_YES)
					rcon_setting = RCON_YES


		if("command")
			if(!is_authenticated(usr, active_ui))
				return

			var/device_id = params["id_tag"]
			switch(params["cmd"])
				if ("power",
					"adjust_external_pressure",
					"set_external_pressure",
					"checks",
					"co2_scrub",
					"tox_scrub",
					"n2o_scrub",
					"n2_scrub",
					"o2_scrub",
					"widenet",
					"scrubbing",
					"direction")
					var/val
					if(params["val"])
						val=text2num(params["val"])
					else
						var/newval = input("Enter new value") as num|null
						if(isnull(newval))
							return
						if(params["cmd"] == "set_external_pressure")
							if(newval > 1000 + ONE_ATMOSPHERE)
								newval = 1000 + ONE_ATMOSPHERE
							if(newval < 0)
								newval = 0
						val = newval

					// For those who read this: This radio BS is what makes air alarms take 10 years to update in the UI
					send_signal(device_id, list(params["cmd"] = val))
					waiting_on_device = device_id

				if("set_threshold")
					var/env = params["env"]
					var/varname = params["var"]
					var/datum/tlv/tlv = TLV[env]
					var/newval = input("Enter [varname] for [env]", "Alarm triggers", tlv.vars[varname]) as num|null

					if(isnull(newval) || ..()) // No setting if you walked away
						return
					if(newval < 0)
						tlv.vars[varname] = -1.0
					else if(env == "temperature" && newval > 5000)
						tlv.vars[varname] = 5000
					else if(env == "pressure" && newval > 50 * ONE_ATMOSPHERE)
						tlv.vars[varname] = 50 * ONE_ATMOSPHERE
					else if(env != "temperature" && env != "pressure" && newval > 200)
						tlv.vars[varname] = 200
					else
						newval = round(newval, 0.01)
						tlv.vars[varname] = newval

		if("atmos_alarm")
			if(alarm_area.atmosalert(ATMOS_ALARM_DANGER, src))
				post_alert(ATMOS_ALARM_DANGER)
			alarmActivated = TRUE
			update_icon()

		if("atmos_reset")
			if(alarm_area.atmosalert(ATMOS_ALARM_NONE, src, TRUE))
				post_alert(ATMOS_ALARM_NONE)
			alarmActivated = FALSE
			update_icon()

		if("mode")
			if(!is_authenticated(usr, active_ui))
				return

			mode = text2num(params["mode"])
			apply_mode()


		if("preset")
			if(!is_authenticated(usr, active_ui))
				return

			preset = text2num(params["preset"])
			apply_preset()


		if("temperature")
			var/datum/tlv/selected = TLV["temperature"]
			var/max_temperature = selected.max1 >= 0 ? min(selected.max1, MAX_TEMPERATURE) : max(selected.max1, MAX_TEMPERATURE)
			var/min_temperature = max(selected.min1, MIN_TEMPERATURE)
			var/max_temperature_c = max_temperature - T0C
			var/min_temperature_c = min_temperature - T0C
			var/input_temperature = input("What temperature would you like the system to maintain? (Capped between [min_temperature_c]C and [max_temperature_c]C)", "Thermostat Controls") as num|null
			if(isnull(input_temperature) || ..()) // No temp setting if you walked away
				return
			input_temperature = input_temperature + T0C
			if(input_temperature > max_temperature || input_temperature < min_temperature)
				to_chat(usr, "<span class='warning'>Temperature must be between [min_temperature_c]C and [max_temperature_c]C</span>")
			else
				target_temperature = input_temperature

		if("thermostat_state")
			thermostat_state = !thermostat_state

/obj/machinery/alarm/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		if(user)
			user.visible_message("<span class='warning'>Sparks fly out of the [src]!</span>", "<span class='notice'>You emag the [src], disabling its safeties.</span>")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 50, TRUE)
		return

/obj/machinery/alarm/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)

	switch(buildstage)
		if(2)
			if(I.GetID() || ispda(I)) // trying to unlock the interface
				if(stat & (NOPOWER|BROKEN))
					to_chat(user, "It does nothing")
					return
				else
					if(allowed(usr) && !wires.is_cut(WIRE_IDSCAN))
						locked = !locked
						to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the Air Alarm interface.</span>")
						SStgui.update_uis(src)
					else
						to_chat(user, "<span class='warning'>Access denied.</span>")
				return

		if(1)
			if(iscoil(I))
				var/obj/item/stack/cable_coil/coil = I
				if(coil.get_amount() < 5)
					to_chat(user, "You need more cable for this!")
					return

				to_chat(user, "You wire \the [src]!")
				playsound(get_turf(src), coil.usesound, 50, 1)
				coil.use(5)
				if(!coil.amount)
					qdel(coil)

				buildstage = 2
				update_icon()
				first_run()
				return
		if(0)
			if(istype(I, /obj/item/airalarm_electronics))
				to_chat(user, "You insert the circuit!")
				playsound(get_turf(src), I.usesound, 50, 1)
				qdel(I)
				buildstage = 1
				update_icon()
				return
	return ..()

/obj/machinery/alarm/crowbar_act(mob/user, obj/item/I)
	if(buildstage != AIR_ALARM_BUILDING)
		return
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	to_chat(user, "You start prying out the circuit.")
	if(!I.use_tool(src, user, 20, volume = I.tool_volume))
		return
	if(buildstage != AIR_ALARM_BUILDING)
		return
	to_chat(user, "You pry out the circuit!")
	new /obj/item/airalarm_electronics(user.drop_location())
	buildstage = AIR_ALARM_FRAME
	update_icon()

/obj/machinery/alarm/multitool_act(mob/user, obj/item/I)
	if(buildstage != AIR_ALARM_READY)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(wiresexposed)
		attack_hand(user)

/obj/machinery/alarm/screwdriver_act(mob/user, obj/item/I)
	if(buildstage != AIR_ALARM_READY)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	wiresexposed = !wiresexposed
	update_icon()
	if(wiresexposed)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE

/obj/machinery/alarm/wirecutter_act(mob/user, obj/item/I)
	if(buildstage != AIR_ALARM_READY)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(wires.is_all_cut()) // all wires cut
		var/obj/item/stack/cable_coil/new_coil = new /obj/item/stack/cable_coil(user.drop_location())
		new_coil.amount = 5
		buildstage = AIR_ALARM_BUILDING
		update_icon()
	if(wiresexposed)
		wires.Interact(user)

/obj/machinery/alarm/wrench_act(mob/user, obj/item/I)
	if(buildstage != AIR_ALARM_FRAME)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	new /obj/item/mounted/frame/alarm_frame(get_turf(user))
	WRENCH_UNANCHOR_WALL_MESSAGE
	qdel(src)

/obj/machinery/alarm/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	spawn(rand(0,15))
		update_icon()

/obj/machinery/alarm/obj_break(damage_flag)
	..()
	update_icon()

/obj/machinery/alarm/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 2)
		var/obj/item/I = new /obj/item/airalarm_electronics(loc)
		if(!disassembled)
			I.obj_integrity = I.max_integrity * 0.5
		new /obj/item/stack/cable_coil(loc, 3)
	qdel(src)

/obj/machinery/alarm/examine(mob/user)
	. = ..()
	if(buildstage < 2)
		. += "<span class='notice'>It is not wired.</span>"
	if(buildstage < 1)
		. += "<span class='notice'>The circuit is missing.</span>"

/obj/machinery/alarm/proc/unshort_callback()
	if(shorted)
		shorted = FALSE
		update_icon()

/obj/machinery/alarm/proc/enable_ai_control_callback()
	if(aidisabled)
		aidisabled = FALSE

/obj/machinery/alarm/all_access
	name = "all-access air alarm"
	desc = "This particular atmos control unit appears to have no access restrictions."
	locked = FALSE
	req_access = null

/*
AIR ALARM CIRCUIT
Just an object used in constructing air alarms
*/
/obj/item/airalarm_electronics
	name = "air alarm electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "Looks like a circuit. Probably is."
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50, MAT_GLASS=50)
	origin_tech = "engineering=2;programming=1"
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'


#undef AIR_ALARM_FRAME
#undef AIR_ALARM_BUILDING
#undef AIR_ALARM_READY
