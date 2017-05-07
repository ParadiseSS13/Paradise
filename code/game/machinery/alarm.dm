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

#define AALARM_SCREEN_MAIN		1
#define AALARM_SCREEN_VENT		2
#define AALARM_SCREEN_SCRUB		3
#define AALARM_SCREEN_MODE		4
#define AALARM_SCREEN_SENSORS	5

#define AALARM_REPORT_TIMEOUT 100

#define RCON_NO		1
#define RCON_AUTO	2
#define RCON_YES	3

//1000 joules equates to about 1 degree every 2 seconds for a single tile of air.
#define MAX_ENERGY_CHANGE 1000

#define MAX_TEMPERATURE 363.15 // 90C
#define MIN_TEMPERATURE 233.15 // -40C

//all air alarms in area are connected via magic
/area
	var/obj/machinery/alarm/master_air_alarm
	var/list/air_vent_names = list()
	var/list/air_scrub_names = list()
	var/list/air_vent_info = list()
	var/list/air_scrub_info = list()

/obj/machinery/alarm
	name = "alarm"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm0"
	anchored = 1
	use_power = 1
	idle_power_usage = 4
	active_power_usage = 8
	power_channel = ENVIRON
	req_one_access = list(access_atmospherics, access_engine_equip)
	var/alarm_id = null
	var/frequency = 1439
	//var/skipprocess = 0 //Experimenting
	var/alarm_frequency = 1437
	var/remote_control = 0
	var/rcon_setting = 2
	var/rcon_time = 0
	var/locked = 1
	var/datum/wires/alarm/wires = null
	var/wiresexposed = 0 // If it's been screwdrivered open.
	var/aidisabled = 0
	var/AAlarmwires = 31
	var/shorted = 0

	// Waiting on a device to respond.
	// Specifies an id_tag.  NULL means we aren't waiting.
	var/waiting_on_device=null

	var/mode = AALARM_MODE_SCRUBBING
	var/preset = AALARM_PRESET_HUMAN
	var/screen = AALARM_SCREEN_MAIN
	var/area_uid
	var/area/alarm_area
	var/danger_level = ATMOS_ALARM_NONE
	var/alarmActivated = 0 // Manually activated (independent from danger level)

	var/buildstage = 2 //2 is built, 1 is building, 0 is frame.

	var/target_temperature = T20C
	var/regulating_temperature = 0

	var/datum/radio_frequency/radio_connection

	var/list/TLV = list()

	var/report_danger_level = 1

/obj/machinery/alarm/monitor
	report_danger_level = 0

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

/obj/machinery/alarm/New(var/loc, var/dir, var/building = 0)
	..()
	air_alarms += src
	air_alarms = sortAtom(air_alarms)

	wires = new(src)

	if(building)
		if(loc)
			src.loc = loc

		if(dir)
			src.dir = dir

		buildstage = 0
		wiresexposed = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0
		update_icon()
		return

	first_run()

/obj/machinery/alarm/Destroy()
	air_alarms -= src
	if(radio_controller)
		radio_controller.remove_object(src, frequency)
	air_alarm_repository.update_cache(src)
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
	air_alarm_repository.update_cache(src)

/obj/machinery/alarm/initialize()
	..()
	set_frequency(frequency)
	if(!master_is_operating())
		elect_master()

/obj/machinery/alarm/proc/master_is_operating()
	if(! alarm_area)
		alarm_area = areaMaster

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
	var/other_moles = 0.0
	for(var/datum/gas/G in environment.trace_gases)
		other_moles+=G.moles
	var/other_dangerlevel = cur_tlv.get_danger_level(other_moles*GET_PP)

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

	if(old_danger_level!=danger_level)
		apply_danger_level()

	if(mode == AALARM_MODE_REPLACEMENT && environment_pressure < ONE_ATMOSPHERE * 0.05)
		mode = AALARM_MODE_SCRUBBING
		apply_mode()

/obj/machinery/alarm/proc/handle_heating_cooling(var/datum/gas_mixture/environment, var/datum/tlv/cur_tlv, var/turf/simulated/location)
	cur_tlv = TLV["temperature"]
	//Handle temperature adjustment here.
	if(environment.temperature < target_temperature - 2 || environment.temperature > target_temperature + 2 || regulating_temperature)
		//If it goes too far, we should adjust ourselves back before stopping.
		if(!cur_tlv.get_danger_level(target_temperature))
			if(!regulating_temperature)
				regulating_temperature = 1
				visible_message("\The [src] clicks as it starts [environment.temperature > target_temperature ? "cooling" : "heating"] the room.",\
				"You hear a click and a faint electronic hum.")

			if(target_temperature > MAX_TEMPERATURE)
				target_temperature = MAX_TEMPERATURE

			if(target_temperature < MIN_TEMPERATURE)
				target_temperature = MIN_TEMPERATURE

			var/datum/gas_mixture/gas = location.remove_air(0.25*environment.total_moles())
			var/heat_capacity = gas.heat_capacity()
			var/energy_used = max( abs( heat_capacity*(gas.temperature - target_temperature) ), MAX_ENERGY_CHANGE)

			//Use power.  Assuming that each power unit represents 1000 watts....
			use_power(energy_used/1000, ENVIRON)

			//We need to cool ourselves.
			if(heat_capacity)
				if(environment.temperature > target_temperature)
					gas.temperature -= energy_used/heat_capacity
				else
					gas.temperature += energy_used/heat_capacity

			environment.merge(gas)

			if(abs(environment.temperature - target_temperature) <= 0.5)
				regulating_temperature = 0
				visible_message("\The [src] clicks quietly as it stops [environment.temperature > target_temperature ? "cooling" : "heating"] the room.",\
				"You hear a click as a faint electronic humming stops.")

/obj/machinery/alarm/update_icon()
	if(wiresexposed)
		icon_state = "alarmx"
		return
	if((stat & (NOPOWER|BROKEN)) || shorted)
		icon_state = "alarmp"
		return

	switch(max(danger_level, alarm_area.atmosalm-1))
		if(ATMOS_ALARM_NONE)
			icon_state = "alarm0"
		if(ATMOS_ALARM_WARNING)
			icon_state = "alarm2" //yes, alarm2 is yellow alarm
		if(ATMOS_ALARM_DANGER)
			icon_state = "alarm1"

/obj/machinery/alarm/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN) || !alarm_area)
		return
	if(alarm_area.master_air_alarm != src)
		if(master_is_operating())
			return
		elect_master()
		if(alarm_area.master_air_alarm != src)
			return
	if(!signal || signal.encryption)
		return
	var/id_tag = signal.data["tag"]
	if(!id_tag)
		return
	if(signal.data["area"] != area_uid)
		return
	if(signal.data["sigtype"] != "status")
		return

	var/dev_type = signal.data["device"]
	if(!(id_tag in alarm_area.air_scrub_names) && !(id_tag in alarm_area.air_vent_names))
		register_env_machine(id_tag, dev_type)
	var/got_update=0
	if(dev_type == "AScr")
		alarm_area.air_scrub_info[id_tag] = signal.data
		got_update=1
	else if(dev_type == "AVP")
		alarm_area.air_vent_info[id_tag] = signal.data
		got_update=1
	if(got_update && waiting_on_device==id_tag)
		waiting_on_device=null

/obj/machinery/alarm/proc/register_env_machine(var/m_id, var/device_type)
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

/obj/machinery/alarm/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_TO_AIRALARM)

/obj/machinery/alarm/proc/send_signal(var/target, var/list/command)//sends signal 'command' to 'target'. Returns 0 if no radio connection, 1 otherwise
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = command
	signal.data["tag"] = target
	signal.data["sigtype"] = "command"

	radio_connection.post_signal(src, signal, RADIO_FROM_AIRALARM)
//			to_chat(world, text("Signal [] Broadcasted to []", command, target))

	return 1

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

/obj/machinery/alarm/proc/apply_danger_level(var/new_danger_level)
	if(report_danger_level && alarm_area.atmosalert(new_danger_level, src))
		post_alert(new_danger_level)

	update_icon()

/obj/machinery/alarm/proc/post_alert(alert_level)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(alarm_frequency)
	if(!frequency)
		return

	var/datum/signal/alert_signal = new
	alert_signal.source = src
	alert_signal.transmission_method = 1
	alert_signal.data["zone"] = alarm_area.name
	alert_signal.data["type"] = "Atmospheric"

	if(alert_level==2)
		alert_signal.data["alert"] = "severe"
	else if(alert_level==1)
		alert_signal.data["alert"] = "minor"
	else if(alert_level==0)
		alert_signal.data["alert"] = "clear"

	frequency.post_signal(src, alert_signal)

///////////////
//END HACKING//
///////////////

/obj/machinery/alarm/attack_ai(mob/user)
	src.add_hiddenprint(user)
	return ui_interact(user)

/obj/machinery/alarm/attack_ghost(user as mob)
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
	var/total = environment.oxygen + environment.nitrogen + environment.carbon_dioxide + environment.toxins
	if(total==0)
		return null

	var/datum/tlv/cur_tlv
	var/GET_PP = R_IDEAL_GAS_EQUATION*environment.temperature/environment.volume

	cur_tlv = TLV["pressure"]
	var/environment_pressure = environment.return_pressure()
	var/pressure_dangerlevel = cur_tlv.get_danger_level(environment_pressure)

	cur_tlv = TLV["oxygen"]
	var/oxygen_dangerlevel = cur_tlv.get_danger_level(environment.oxygen*GET_PP)
	var/oxygen_percent = round(environment.oxygen / total * 100, 2)

	cur_tlv = TLV["nitrogen"]
	var/nitrogen_dangerlevel = cur_tlv.get_danger_level(environment.nitrogen*GET_PP)
	var/nitrogen_percent = round(environment.nitrogen / total * 100, 2)

	cur_tlv = TLV["carbon dioxide"]
	var/co2_dangerlevel = cur_tlv.get_danger_level(environment.carbon_dioxide*GET_PP)
	var/co2_percent = round(environment.carbon_dioxide / total * 100, 2)

	cur_tlv = TLV["plasma"]
	var/plasma_dangerlevel = cur_tlv.get_danger_level(environment.toxins*GET_PP)
	var/plasma_percent = round(environment.toxins / total * 100, 2)

	cur_tlv = TLV["other"]
	var/other_moles = 0.0
	for(var/datum/gas/G in environment.trace_gases)
		other_moles+=G.moles
	var/other_dangerlevel = cur_tlv.get_danger_level(other_moles*GET_PP)

	cur_tlv = TLV["temperature"]
	var/temperature_dangerlevel = cur_tlv.get_danger_level(environment.temperature)

	var/data[0]
	data["pressure"] = environment_pressure
	data["temperature"] = environment.temperature
	data["temperature_c"] = round(environment.temperature - T0C, 0.1)

	var/percentages[0]
	percentages["oxygen"] = oxygen_percent
	percentages["nitrogen"] = nitrogen_percent
	percentages["co2"] = co2_percent
	percentages["plasma"] = plasma_percent
	percentages["other"] = other_moles
	data["contents"] = percentages

	var/danger[0]
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

/obj/machinery/alarm/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]

	var/list/href_list = state.href_list(user)
	if(href_list)
		data["remote_connection"] = href_list["remote_connection"]
		data["remote_access"] = href_list["remote_access"]

	data["name"] = sanitize(name)
	data["air"] = ui_air_status()
	data["alarmActivated"] = alarmActivated || danger_level == ATMOS_ALARM_DANGER
	data["thresholds"] = generate_thresholds_menu()

	// Locked when:
	//   Not sent from atmos console AND
	//   Not silicon AND locked.
	data["locked"] = !is_authenticated(user, href_list)
	data["rcon"] = rcon_setting
	data["target_temp"] = target_temperature - T0C
	data["atmos_alarm"] = alarm_area.atmosalm
	data["emagged"] = emagged
	data["modes"] = list(
		AALARM_MODE_SCRUBBING   = list("name"="Filtering",   "desc"="Scrubs out contaminants"),\
		AALARM_MODE_VENTING		= list("name"="Draught", 	 "desc"="Siphons out air while replacing"),\
		AALARM_MODE_PANIC       = list("name"="Panic Siphon","desc"="Siphons air out of the room quickly"),\
		AALARM_MODE_REPLACEMENT = list("name"="Cycle",       "desc"="Siphons air before replacing"),\
		AALARM_MODE_SIPHON	    = list("name"="Siphon",		 "desc"="Siphons air out of the room"),\
		AALARM_MODE_CONTAMINATED= list("name"="Contaminated","desc"="Scrubs out all contaminants quickly"),\
		AALARM_MODE_REFILL      = list("name"="Refill",      "desc"="Triples vent output"),\
		AALARM_MODE_OFF         = list("name"="Off",         "desc"="Shuts off vents and scrubbers"),\
		AALARM_MODE_FLOOD 		= list("name"="Flood", 		 "desc"="Shuts off scrubbers and opens vents", 	"emagonly" = 1)
	)
	data["mode"] = mode
	data["presets"] = list(
		AALARM_PRESET_HUMAN		= list("name"="Human",     	 "desc"="Checks for oxygen and nitrogen"),\
		AALARM_PRESET_VOX 		= list("name"="Vox",       	 "desc"="Checks for nitrogen only"),\
		AALARM_PRESET_COLDROOM 	= list("name"="Coldroom", 	 "desc"="For freezers"),\
		AALARM_PRESET_SERVER 	= list("name"="Server Room", "desc"="For server rooms")
	)
	data["preset"] = preset
	data["screen"] = screen

	var/list/vents=list()
	if(alarm_area.air_vent_names.len)
		for(var/id_tag in alarm_area.air_vent_names)
			var/vent_info[0]
			var/long_name = alarm_area.air_vent_names[id_tag]
			var/list/vent_data = alarm_area.air_vent_info[id_tag]
			if(!vent_data)
				continue
			vent_info["id_tag"]=id_tag
			vent_info["name"]=sanitize(long_name)
			vent_info += vent_data
			vents+=list(vent_info)
	data["vents"]=vents

	var/list/scrubbers=list()
	if(alarm_area.air_scrub_names.len)
		for(var/id_tag in alarm_area.air_scrub_names)
			var/long_name = alarm_area.air_scrub_names[id_tag]
			var/list/scrubber_data = alarm_area.air_scrub_info[id_tag]
			if(!scrubber_data)
				continue
			scrubber_data["id_tag"]=id_tag
			scrubber_data["name"]=sanitize(long_name)
			scrubbers+=list(scrubber_data)
	data["scrubbers"]=scrubbers
	return data

/obj/machinery/alarm/proc/get_nano_data_console(mob/user)
	var/data[0]
	data["name"] = sanitize(name)
	data["ref"] = "\ref[src]"
	data["danger"] = max(danger_level, alarm_area.atmosalm)
	var/area/Area = get_area(src)
	data["area"] = sanitize(Area.name)
	var/turf/pos = get_turf(src)
	data["x"] = pos.x
	data["y"] = pos.y
	data["z"] = pos.z
	return data

/obj/machinery/alarm/proc/generate_thresholds_menu()
	var/datum/tlv/selected
	var/list/thresholds = list()

	var/list/gas_names = list(
		"oxygen"         = "O<sub>2</sub>",
		"nitrogen"       = "N<sub>2</sub>",
		"carbon dioxide" = "CO<sub>2</sub>",
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

/obj/machinery/alarm/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, var/master_ui = null, var/datum/topic_state/state = default_state)
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "air_alarm.tmpl", name, 570, 410, state = state)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/alarm/proc/is_authenticated(var/mob/user, href_list)
	if(user.can_admin_interact())
		return 1
	else if(isAI(user) || isrobot(user) || emagged || is_auth_rcon(href_list))
		return 1
	else
		return !locked

/obj/machinery/alarm/proc/is_auth_rcon(href_list)
	if(href_list && href_list["remote_connection"] && href_list["remote_access"])
		return 1
	else
		return 0

/obj/machinery/alarm/CanUseTopic(var/mob/user, var/datum/topic_state/state, var/href_list = list())
	if(buildstage != 2)
		return STATUS_CLOSE

	if(aidisabled && (isAI(user) || isrobot(user)))
		to_chat(user, "<span class='warning'>AI control for \the [src] interface has been disabled.</span>")
		return STATUS_CLOSE

	. = shorted ? STATUS_DISABLED : STATUS_INTERACTIVE

	if(. == STATUS_INTERACTIVE)
		var/extra_href = state.href_list(usr)
		// Prevent remote users from altering RCON settings or activating atmos alarms unless they already have access
		if((href_list["atmos_alarm"] || href_list["rcon"]) && extra_href["remote_connection"] && !extra_href["remote_access"])
			. = STATUS_UPDATE
	return min(..(), .)

/obj/machinery/alarm/Topic(href, href_list, var/nowindow = 0, var/datum/topic_state/state)
	if(..(href, href_list, nowindow, state))
		return 1

	var/state_href = state.href_list(usr)

	if(href_list["rcon"])
		var/attempted_rcon_setting = text2num(href_list["rcon"])
		switch(attempted_rcon_setting)
			if(RCON_NO)
				rcon_setting = RCON_NO
			if(RCON_AUTO)
				rcon_setting = RCON_AUTO
			if(RCON_YES)
				rcon_setting = RCON_YES
		return 1

	add_fingerprint(usr)

	if(href_list["command"])
		if(!is_authenticated(usr, state_href))
			return

		var/device_id = href_list["id_tag"]
		switch(href_list["command"])
			if( "power",
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
				if(href_list["val"])
					val=text2num(href_list["val"])
				else
					var/newval = input("Enter new value") as num|null
					if(isnull(newval))
						return
					if(href_list["command"]=="set_external_pressure")
						if(newval>1000+ONE_ATMOSPHERE)
							newval = 1000+ONE_ATMOSPHERE
						if(newval<0)
							newval = 0
					val = newval

				send_signal(device_id, list(href_list["command"] = val ) )
				waiting_on_device=device_id

			if("set_threshold")
				var/env = href_list["env"]
				var/varname = href_list["var"]
				var/datum/tlv/tlv = TLV[env]
				var/newval = input("Enter [varname] for [env]", "Alarm triggers", tlv.vars[varname]) as num|null

				if(isnull(newval) || ..(href, href_list, nowindow, state))
					return
				if(newval<0)
					tlv.vars[varname] = -1.0
				else if(env=="temperature" && newval>5000)
					tlv.vars[varname] = 5000
				else if(env=="pressure" && newval>50*ONE_ATMOSPHERE)
					tlv.vars[varname] = 50*ONE_ATMOSPHERE
				else if(env!="temperature" && env!="pressure" && newval>200)
					tlv.vars[varname] = 200
				else
					newval = round(newval,0.01)
					tlv.vars[varname] = newval

	if(href_list["screen"])
		if(!is_authenticated(usr, state_href))
			return

		screen = text2num(href_list["screen"])
		return 1

	if(href_list["atmos_alarm"])
		if(alarm_area.atmosalert(ATMOS_ALARM_DANGER, src))
			apply_danger_level(ATMOS_ALARM_DANGER)
		alarmActivated = 1
		update_icon()
		return 1

	if(href_list["atmos_reset"])
		if(alarm_area.atmosalert(ATMOS_ALARM_NONE, src))
			apply_danger_level(ATMOS_ALARM_NONE)
		alarmActivated = 0
		update_icon()
		return 1

	if(href_list["mode"])
		if(!is_authenticated(usr, state_href))
			return

		mode = text2num(href_list["mode"])
		apply_mode()
		return 1

	if(href_list["preset"])
		if(!is_authenticated(usr, state_href))
			return

		preset = text2num(href_list["preset"])
		apply_preset()
		return 1

	if(href_list["temperature"])
		var/datum/tlv/selected = TLV["temperature"]
		var/max_temperature = selected.max1 >= 0 ? min(selected.max1, MAX_TEMPERATURE) : max(selected.max1, MAX_TEMPERATURE)
		var/min_temperature = max(selected.min1, MIN_TEMPERATURE)
		var/max_temperature_c = max_temperature - T0C
		var/min_temperature_c = min_temperature - T0C
		var/input_temperature = input("What temperature would you like the system to maintain? (Capped between [min_temperature_c]C and [max_temperature_c]C)", "Thermostat Controls") as num|null
		if(isnull(input_temperature) || ..(href, href_list, nowindow, state))
			return
		input_temperature = input_temperature + T0C
		if(input_temperature > max_temperature || input_temperature < min_temperature)
			to_chat(usr, "Temperature must be between [min_temperature_c]C and [max_temperature_c]C")
		else
			target_temperature = input_temperature
		return 1

/obj/machinery/alarm/emag_act(mob/user)
	if(!emagged)
		src.emagged = 1
		if(user)
			user.visible_message("<span class='warning'>Sparks fly out of the [src]!</span>", "<span class='notice'>You emag the [src], disabling its safeties.</span>")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 50, 1)
		return

/obj/machinery/alarm/attackby(obj/item/W as obj, mob/user as mob, params)
	src.add_fingerprint(user)

	switch(buildstage)
		if(2)
			if(istype(W, /obj/item/weapon/screwdriver))  // Opening that Air Alarm up.
//				to_chat(user, "You pop the Air Alarm's maintence panel open.")
				wiresexposed = !wiresexposed
				to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"]")
				update_icon()
				return

			if(istype(W, /obj/item/weapon/wirecutters))  // cutting the wires out
				if(wires.wires_status == 31) // all wires cut
					var/obj/item/stack/cable_coil/new_coil = new /obj/item/stack/cable_coil()
					new_coil.amount = 5
					new_coil.loc = user.loc
					buildstage = 1
					update_icon()
					return

			if(wiresexposed && ((istype(W, /obj/item/device/multitool) || istype(W, /obj/item/weapon/wirecutters))))
				return attack_hand(user)

			if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))// trying to unlock the interface with an ID card
				if(stat & (NOPOWER|BROKEN))
					to_chat(user, "It does nothing")
					return
				else
					if(allowed(usr) && !wires.IsIndexCut(AALARM_WIRE_IDSCAN))
						locked = !locked
						to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the Air Alarm interface.</span>")
						updateUsrDialog()
					else
						to_chat(user, "<span class='warning'>Access denied.</span>")


			return

		if(1)
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/coil = W
				if(coil.amount < 5)
					to_chat(user, "You need more cable for this!")
					return

				to_chat(user, "You wire \the [src]!")
				playsound(get_turf(src), coil.usesound, 50, 1)
				coil.amount -= 5
				if(!coil.amount)
					qdel(coil)

				buildstage = 2
				update_icon()
				first_run()
				return

			else if(istype(W, /obj/item/weapon/crowbar))
				to_chat(user, "You start prying out the circuit.")
				playsound(get_turf(src), W.usesound, 50, 1)
				if(do_after(user, 20 * W.toolspeed, target = src))
					if(buildstage != 1)
						return
					to_chat(user, "You pry out the circuit!")
					var/obj/item/weapon/airalarm_electronics/circuit = new /obj/item/weapon/airalarm_electronics()
					circuit.loc = user.loc
					buildstage = 0
					update_icon()
				return
		if(0)
			if(istype(W, /obj/item/weapon/airalarm_electronics))
				to_chat(user, "You insert the circuit!")
				playsound(get_turf(src), W.usesound, 50, 1)
				qdel(W)
				buildstage = 1
				update_icon()
				return

			else if(istype(W, /obj/item/weapon/wrench))
				to_chat(user, "You remove the fire alarm assembly from the wall!")
				new /obj/item/mounted/frame/alarm_frame(get_turf(user))
				playsound(get_turf(src), W.usesound, 50, 1)
				qdel(src)

	return 0

/obj/machinery/alarm/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	spawn(rand(0,15))
		update_icon()

/obj/machinery/alarm/examine(mob/user)
	..(user)
	if(buildstage < 2)
		to_chat(user, "It is not wired.")
	if(buildstage < 1)
		to_chat(user, "The circuit is missing.")

/*
AIR ALARM CIRCUIT
Just an object used in constructing air alarms
*/
/obj/item/weapon/airalarm_electronics
	name = "air alarm electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "Looks like a circuit. Probably is."
	w_class = 2
	materials = list(MAT_METAL=50, MAT_GLASS=50)
	toolspeed = 1
	usesound = 'sound/items/Deconstruct.ogg'
