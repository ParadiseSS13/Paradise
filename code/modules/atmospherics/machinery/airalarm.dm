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

#define AALARM_PRESET_HUMAN     1 // Default
#define AALARM_PRESET_VOX       2 // Support Vox
#define AALARM_PRESET_COLDROOM  3 // Kitchen coldroom
#define AALARM_PRESET_SERVER    4 // Server coldroom
#define AALARM_PRESET_DISABLED  5 // Disables all alarms

#define AALARM_REPORT_TIMEOUT 100

#define RCON_NO		1
#define RCON_AUTO	2
#define RCON_YES	3

//1000 joules equates to about 1 degree every 2 seconds for a single tile of air.
#define MAX_ENERGY_CHANGE 1000

#define MAX_TEMPERATURE 363.15 // 90C
#define MIN_TEMPERATURE 233.15 // -40C

GLOBAL_LIST_INIT(aalarm_modes, list(
	"[AALARM_MODE_FILTERING]" = "Filtering",
	"[AALARM_MODE_DRAUGHT]" = "Draught",
	"[AALARM_MODE_PANIC]" = "Panic",
	"[AALARM_MODE_CYCLE]" = "Cycle",
	"[AALARM_MODE_SIPHON]" = "Siphon",
	"[AALARM_MODE_CONTAMINATED]" = "Contaminated",
	"[AALARM_MODE_REFILL]" = "Refill",
	"[AALARM_MODE_CUSTOM]" = "Custom",
	"[AALARM_MODE_OFF]" = "Off",
	"[AALARM_MODE_FLOOD]" = "Flood",
))

/obj/machinery/alarm
	name = "air alarm"
	desc = "A wall-mounted device used to control atmospheric equipment. It looks a little cheaply made..."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm0"
	anchored = TRUE
	idle_power_consumption = 4
	active_power_consumption = 8
	power_channel = PW_CHANNEL_ENVIRONMENT
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_ENGINE_EQUIP)
	max_integrity = 250
	integrity_failure = 80
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, RAD = 100, FIRE = 90, ACID = 30)
	resistance_flags = FIRE_PROOF
	siemens_strength = 1
	var/custom_name
	var/alarm_id = null
	//var/skipprocess = 0 //Experimenting
	var/remote_control = TRUE
	var/rcon_setting = RCON_AUTO
	var/rcon_time = 0
	var/locked = TRUE
	var/datum/wires/alarm/wires = null
	var/wiresexposed = FALSE // If it's been screwdrivered open.
	var/aidisabled = FALSE
	var/AAlarmwires = 31
	var/shorted = FALSE

	var/mode = AALARM_MODE_FILTERING
	var/preset = AALARM_PRESET_HUMAN
	var/area/alarm_area
	var/danger_level = ATMOS_ALARM_NONE
	var/alarmActivated = 0 // Manually activated (independent from danger level)

	var/buildstage = AIR_ALARM_READY

	var/target_temperature = T20C
	var/regulating_temperature = 0
	var/thermostat_state = FALSE

	var/list/TLV = list()

	var/report_danger_level = TRUE

	/// Which MILLA tick were we initialized at?
	var/init_tick

/obj/machinery/alarm/monitor
	report_danger_level = FALSE

/obj/machinery/alarm/engine
	locked = FALSE
	req_access = null
	custom_name = "engine air alarm"
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_ENGINE)

/// general syndicate access
/obj/machinery/alarm/syndicate
	report_danger_level = FALSE
	remote_control = FALSE
	req_access = list(ACCESS_SYNDICATE)
	req_one_access = list()

/obj/machinery/alarm/monitor/server
	preset = AALARM_PRESET_SERVER

/obj/machinery/alarm/server
	preset = AALARM_PRESET_SERVER

/obj/machinery/alarm/vox
	preset = AALARM_PRESET_VOX

/obj/machinery/alarm/kitchen_cold_room
	preset = AALARM_PRESET_COLDROOM

/obj/machinery/alarm/disabled
	preset = AALARM_PRESET_DISABLED

/obj/machinery/alarm/proc/apply_preset(no_cycle_after=0)
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
		"nitrous oxide"  = new/datum/tlv(-1.0, -1.0, 0.2, 0.5), // Partial pressure, kpa
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
				"nitrous oxide"  = new/datum/tlv(-1.0, -1.0, 0.2, 0.5), // Partial pressure, kpa
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
				"nitrous oxide"  = new/datum/tlv(-1.0, -1.0, 0.2, 0.5), // Partial pressure, kpa
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
				"nitrous oxide"  = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // Partial pressure, kpa
				"other"          = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // Partial pressure, kpa
				"pressure"       = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), /* kpa */
				"temperature"    = new/datum/tlv(0, 0, T20C + 5, T20C + 15), // K
			)
		if(AALARM_PRESET_DISABLED)
			no_cycle_after = TRUE
			TLV = list(
				"oxygen"         = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // Partial pressure, kpa
				"nitrogen"       = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // Partial pressure, kpa
				"carbon dioxide" = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // Partial pressure, kpa
				"plasma"         = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // Partial pressure, kpa
				"nitrous oxide"  = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // Partial pressure, kpa
				"other"          = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // Partial pressure, kpa
				"pressure"       = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), /* kpa */
				"temperature"    = new/datum/tlv(-1.0, -1.0, -1.0, -1.0), // K
			)

	if(!no_cycle_after)
		mode = AALARM_MODE_CYCLE
		apply_mode()

/obj/machinery/alarm/Initialize(mapload, direction, building = 0)
	. = ..()

	alarm_area = get_area(src)

	if(custom_name)
		name = custom_name
	else
		name = "[alarm_area.name] Air Alarm"

	if(building) // Do this first since the Init uses this later on. TODO refactor to just use an Init
		if(direction)
			setDir(direction)

		buildstage = AIR_ALARM_FRAME
		wiresexposed = TRUE
		set_pixel_offsets_from_dir(24, -24, 24, -24)

	GLOB.air_alarms += src
	alarm_area.air_alarms += src

	if(!mapload)
		GLOB.air_alarms = sortAtom(GLOB.air_alarms)

	wires = new(src)

	if(!building)
		first_run()

	init_tick = SSair.milla_tick

/obj/machinery/alarm/Destroy()
	SStgui.close_uis(wires)
	GLOB.air_alarms -= src
	alarm_area.air_alarms -= src
	GLOB.air_alarm_repository.update_cache(src)
	QDEL_NULL(wires)
	alarm_area = null
	return ..()

/obj/machinery/alarm/proc/first_run()
	apply_preset(AALARM_PRESET_HUMAN) // Don't cycle.
	GLOB.air_alarm_repository.update_cache(src)

/obj/machinery/alarm/process()
	if((stat & (NOPOWER|BROKEN)) || shorted || buildstage != AIR_ALARM_READY || init_tick == SSair.milla_tick)
		return

	var/turf/simulated/location = loc
	if(!istype(location))
		return 0

	if(thermostat_state)
		var/datum/milla_safe/airalarm_heat_cool/milla = new()
		milla.invoke_async(src)

	var/datum/gas_mixture/environment = location.get_readonly_air()
	var/GET_PP = R_IDEAL_GAS_EQUATION * environment.temperature() / environment.volume
	var/datum/tlv/cur_tlv

	cur_tlv = TLV["pressure"]
	var/environment_pressure = environment.return_pressure()
	var/pressure_dangerlevel = cur_tlv.get_danger_level(environment_pressure)
	if(environment_pressure < cur_tlv.min2 && mode == AALARM_MODE_FILTERING)
		mode = AALARM_MODE_OFF
		apply_mode()
		var/area/A = location.loc
		A.firealert(src)

	if(mode == AALARM_MODE_REFILL && environment_pressure >= cur_tlv.min1)
		mode = AALARM_MODE_FILTERING
		apply_mode()

	cur_tlv = TLV["oxygen"]
	var/oxygen_dangerlevel = cur_tlv.get_danger_level(environment.oxygen() * GET_PP)

	cur_tlv = TLV["nitrogen"]
	var/nitrogen_dangerlevel = cur_tlv.get_danger_level(environment.nitrogen() * GET_PP)

	cur_tlv = TLV["carbon dioxide"]
	var/co2_dangerlevel = cur_tlv.get_danger_level(environment.carbon_dioxide() * GET_PP)

	cur_tlv = TLV["plasma"]
	var/plasma_dangerlevel = cur_tlv.get_danger_level(environment.toxins() * GET_PP)

	cur_tlv = TLV["nitrous oxide"]
	var/sleeping_agent_dangerlevel = cur_tlv.get_danger_level(environment.sleeping_agent() * GET_PP)

	cur_tlv = TLV["other"]
	var/other_dangerlevel = cur_tlv.get_danger_level(environment.total_trace_moles() * GET_PP)

	cur_tlv = TLV["temperature"]
	var/temperature_dangerlevel = cur_tlv.get_danger_level(environment.temperature())

	var/old_danger_level = danger_level
	danger_level = max(
		pressure_dangerlevel,
		oxygen_dangerlevel,
		nitrogen_dangerlevel,
		co2_dangerlevel,
		plasma_dangerlevel,
		sleeping_agent_dangerlevel,
		other_dangerlevel,
		temperature_dangerlevel
	)

	if(old_danger_level != danger_level)
		apply_danger_level()

	cur_tlv = TLV["pressure"]
	if(mode == AALARM_MODE_CYCLE && environment_pressure < cur_tlv.min2 * 0.05)
		mode = AALARM_MODE_REFILL
		apply_mode()

/datum/milla_safe/airalarm_heat_cool

/datum/milla_safe/airalarm_heat_cool/on_run(obj/machinery/alarm/alarm)
	var/turf/location = get_turf(alarm)
	var/datum/gas_mixture/environment = get_turf_air(location)

	var/datum/tlv/cur_tlv = alarm.TLV["temperature"]
	//Handle temperature adjustment here.
	if(environment.temperature() < alarm.target_temperature - 2 || environment.temperature() > alarm.target_temperature + 2 || alarm.regulating_temperature)
		//If it goes too far, we should adjust ourselves back before stopping.
		if(!cur_tlv.get_danger_level(alarm.target_temperature))
			var/datum/gas_mixture/gas = environment.remove(0.25 * environment.total_moles())
			if(!gas)
				return
			if(!alarm.regulating_temperature && alarm.thermostat_state)
				alarm.regulating_temperature = TRUE
				alarm.visible_message("\The [alarm] clicks as it starts [environment.temperature() > alarm.target_temperature ? "cooling" : "heating"] the room.", "You hear a click and a faint electronic hum.")

			if(alarm.target_temperature > MAX_TEMPERATURE)
				alarm.target_temperature = MAX_TEMPERATURE

			if(alarm.target_temperature < MIN_TEMPERATURE)
				alarm.target_temperature = MIN_TEMPERATURE

			var/heat_capacity = gas.heat_capacity()
			var/energy_used = max(abs(heat_capacity * (gas.temperature() - alarm.target_temperature) ), MAX_ENERGY_CHANGE)

			//Use power.  Assuming that each power unit represents 1000 watts....
			alarm.use_power(energy_used / 1000, PW_CHANNEL_ENVIRONMENT)

			//We need to cool ourselves.
			if(heat_capacity)
				if(environment.temperature() > alarm.target_temperature)
					gas.set_temperature(gas.temperature() - energy_used / heat_capacity)
				else
					gas.set_temperature(gas.temperature() + energy_used / heat_capacity)

			if(abs(environment.temperature() - alarm.target_temperature) <= 0.5)
				alarm.regulating_temperature = FALSE
				alarm.visible_message("[alarm] clicks quietly as it stops [environment.temperature() > alarm.target_temperature ? "cooling" : "heating"] the room.", "You hear a click as a faint electronic humming stops.")

			environment.merge(gas)

/obj/machinery/alarm/update_icon_state()
	if(wiresexposed)
		switch(buildstage)
			if(AIR_ALARM_FRAME)
				icon_state = "alarm_b1"
			if(AIR_ALARM_UNWIRED)
				icon_state = "alarm_b2"
			if(AIR_ALARM_READY)
				icon_state = "alarmx"
		return
	if((stat & (NOPOWER|BROKEN)) || shorted)
		icon_state = "alarmp"
		return

	if(!alarm_area) // We wont have our alarm_area if we aint initialised
		return

	switch(max(danger_level, alarm_area.atmosalm - 1))
		if(ATMOS_ALARM_NONE)
			icon_state = "alarm0"
		if(ATMOS_ALARM_WARNING)
			icon_state = "alarm2" //yes, alarm2 is yellow alarm
		if(ATMOS_ALARM_DANGER)
			icon_state = "alarm1"

/obj/machinery/alarm/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER || buildstage != AIR_ALARM_READY || wiresexposed || shorted)
		return

	underlays += emissive_appearance(icon, "alarm_lightmask")

/obj/machinery/alarm/proc/apply_mode()
	var/datum/tlv/pressure_tlv = TLV["pressure"]
	switch(mode)
		if(AALARM_MODE_FILTERING)
			for(var/obj/machinery/atmospherics/unary/vent_scrubber/S as anything in alarm_area.scrubbers)
				if(S.stat & (NOPOWER|BROKEN))
					continue
				S.on = TRUE
				S.scrub_O2 = (preset == AALARM_PRESET_VOX)
				S.scrub_N2 = FALSE
				S.scrub_CO2 = TRUE
				S.scrub_Toxins = FALSE
				S.scrub_N2O = FALSE
				S.scrubbing = TRUE
				S.widenet = FALSE
				S.update_icon(UPDATE_ICON_STATE)

			for(var/obj/machinery/atmospherics/unary/vent_pump/P as anything in alarm_area.vents)
				if(P.stat & (NOPOWER|BROKEN))
					continue
				P.on = TRUE
				P.pressure_checks = ONLY_CHECK_EXT_PRESSURE
				P.external_pressure_bound = (pressure_tlv.min1 + pressure_tlv.max1) / 2
				P.update_icon(UPDATE_ICON_STATE)


		if(AALARM_MODE_CONTAMINATED)
			for(var/obj/machinery/atmospherics/unary/vent_scrubber/S as anything in alarm_area.scrubbers)
				if(S.stat & (NOPOWER|BROKEN))
					continue
				S.on = TRUE
				S.scrub_CO2 = TRUE
				S.scrub_Toxins = TRUE
				S.scrub_N2O = TRUE
				S.scrubbing = TRUE
				S.widenet = TRUE
				S.update_icon(UPDATE_ICON_STATE)

			for(var/obj/machinery/atmospherics/unary/vent_pump/P as anything in alarm_area.vents)
				if(P.stat & (NOPOWER|BROKEN))
					continue
				P.on = TRUE
				P.pressure_checks = ONLY_CHECK_EXT_PRESSURE
				P.external_pressure_bound = (pressure_tlv.min1 + pressure_tlv.max1) / 2
				P.update_icon(UPDATE_ICON_STATE)


		if(AALARM_MODE_DRAUGHT)
			for(var/obj/machinery/atmospherics/unary/vent_scrubber/S as anything in alarm_area.scrubbers)
				if(S.stat & (NOPOWER|BROKEN))
					continue
				S.on = TRUE
				S.widenet = FALSE
				S.scrubbing = FALSE
				S.update_icon(UPDATE_ICON_STATE)

			for(var/obj/machinery/atmospherics/unary/vent_pump/P as anything in alarm_area.vents)
				if(P.stat & (NOPOWER|BROKEN))
					continue
				P.on = TRUE
				P.pressure_checks = ONLY_CHECK_EXT_PRESSURE
				P.external_pressure_bound = pressure_tlv.max1
				P.update_icon(UPDATE_ICON_STATE)


		if(AALARM_MODE_REFILL)
			for(var/obj/machinery/atmospherics/unary/vent_scrubber/S as anything in alarm_area.scrubbers)
				if(S.stat & (NOPOWER|BROKEN))
					continue
				S.on = TRUE
				S.scrub_CO2 = TRUE
				S.scrub_Toxins = FALSE
				S.scrub_N2O = FALSE
				S.scrubbing = TRUE
				S.widenet = FALSE
				S.update_icon(UPDATE_ICON_STATE)

			for(var/obj/machinery/atmospherics/unary/vent_pump/P as anything in alarm_area.vents)
				if(P.stat & (NOPOWER|BROKEN))
					continue
				P.on = TRUE
				P.pressure_checks = ONLY_CHECK_EXT_PRESSURE
				P.external_pressure_bound = (pressure_tlv.min1 + pressure_tlv.max1) / 2
				P.update_icon(UPDATE_ICON_STATE)


		if(AALARM_MODE_PANIC, AALARM_MODE_CYCLE)
			for(var/obj/machinery/atmospherics/unary/vent_scrubber/S as anything in alarm_area.scrubbers)
				if(S.stat & (NOPOWER|BROKEN))
					continue
				S.on = TRUE
				S.widenet = TRUE
				S.scrubbing = FALSE
				S.update_icon(UPDATE_ICON_STATE)

			for(var/obj/machinery/atmospherics/unary/vent_pump/P as anything in alarm_area.vents)
				if(P.stat & (NOPOWER|BROKEN))
					continue
				P.on = FALSE
				P.update_icon(UPDATE_ICON_STATE)


		if(AALARM_MODE_SIPHON)
			for(var/obj/machinery/atmospherics/unary/vent_scrubber/S as anything in alarm_area.scrubbers)
				if(S.stat & (NOPOWER|BROKEN))
					continue
				S.on = TRUE
				S.widenet = FALSE
				S.scrubbing = FALSE
				S.update_icon(UPDATE_ICON_STATE)

			for(var/obj/machinery/atmospherics/unary/vent_pump/P as anything in alarm_area.vents)
				if(P.stat & (NOPOWER|BROKEN))
					continue
				P.on = FALSE
				P.update_icon(UPDATE_ICON_STATE)


		if(AALARM_MODE_OFF)
			for(var/obj/machinery/atmospherics/unary/vent_scrubber/S as anything in alarm_area.scrubbers)
				if(S.stat & (NOPOWER|BROKEN))
					continue
				S.on = FALSE
				S.update_icon(UPDATE_ICON_STATE)

			for(var/obj/machinery/atmospherics/unary/vent_pump/P as anything in alarm_area.vents)
				if(P.stat & (NOPOWER|BROKEN))
					continue
				P.on = FALSE
				P.update_icon(UPDATE_ICON_STATE)


		if(AALARM_MODE_FLOOD)
			for(var/obj/machinery/atmospherics/unary/vent_scrubber/S as anything in alarm_area.scrubbers)
				if(S.stat & (NOPOWER|BROKEN))
					continue
				S.on = FALSE
				S.update_icon(UPDATE_ICON_STATE)

			for(var/obj/machinery/atmospherics/unary/vent_pump/P as anything in alarm_area.vents)
				if(P.stat & (NOPOWER|BROKEN))
					continue
				P.on = TRUE
				P.pressure_checks = ONLY_CHECK_INT_PRESSURE
				P.internal_pressure_bound = 0
				P.update_icon(UPDATE_ICON_STATE)

/obj/machinery/alarm/proc/apply_danger_level()
	var/new_area_danger_level = ATMOS_ALARM_NONE
	for(var/obj/machinery/alarm/AA in alarm_area)
		if(!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
			new_area_danger_level = max(new_area_danger_level, AA.danger_level)
	alarm_area.atmosalert(new_area_danger_level, src)

	update_icon(UPDATE_ICON_STATE)

///////////////
//END HACKING//
///////////////

/obj/machinery/alarm/attack_ai(mob/user)
	if(buildstage != AIR_ALARM_READY)
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
	if(buildstage != AIR_ALARM_READY)
		return

	if(wiresexposed)
		wires.Interact(user)

	if(!shorted)
		ui_interact(user)

/obj/machinery/alarm/proc/ui_air_status()
	var/turf/location = get_turf(src)
	if(!istype(location))
		return

	var/datum/gas_mixture/environment = location.get_readonly_air()
	var/known_total = environment.oxygen() + environment.nitrogen() + environment.carbon_dioxide() + environment.toxins() + environment.sleeping_agent()
	var/total = environment.total_moles()

	var/datum/tlv/cur_tlv
	var/GET_PP = R_IDEAL_GAS_EQUATION * environment.temperature() / environment.volume

	cur_tlv = TLV["pressure"]
	var/environment_pressure = environment.return_pressure()
	var/pressure_dangerlevel = cur_tlv.get_danger_level(environment_pressure)

	cur_tlv = TLV["oxygen"]
	var/oxygen_dangerlevel = cur_tlv.get_danger_level(environment.oxygen() * GET_PP)
	var/oxygen_percent = total ? environment.oxygen() / total * 100 : 0

	cur_tlv = TLV["nitrogen"]
	var/nitrogen_dangerlevel = cur_tlv.get_danger_level(environment.nitrogen() * GET_PP)
	var/nitrogen_percent = total ? environment.nitrogen() / total * 100 : 0

	cur_tlv = TLV["carbon dioxide"]
	var/co2_dangerlevel = cur_tlv.get_danger_level(environment.carbon_dioxide() * GET_PP)
	var/co2_percent = total ? environment.carbon_dioxide() / total * 100 : 0

	cur_tlv = TLV["plasma"]
	var/plasma_dangerlevel = cur_tlv.get_danger_level(environment.toxins() * GET_PP)
	var/plasma_percent = total ? environment.toxins() / total * 100 : 0

	cur_tlv = TLV["nitrous oxide"]
	var/sleeping_agent_dangerlevel = cur_tlv.get_danger_level(environment.sleeping_agent() * GET_PP)
	var/sleeping_agent_percent = total ? environment.sleeping_agent() / total * 100 : 0

	cur_tlv = TLV["other"]
	var/other_moles = total - known_total
	var/other_dangerlevel = cur_tlv.get_danger_level(other_moles*GET_PP)
	var/other_percent = total ? other_moles / total * 100 : 0

	cur_tlv = TLV["temperature"]
	var/temperature_dangerlevel = cur_tlv.get_danger_level(environment.temperature())

	var/list/data = list()
	data["pressure"] = environment_pressure
	data["temperature"] = environment.temperature()
	data["temperature_c"] = round(environment.temperature() - T0C, 0.1)
	data["thermostat_state"] = thermostat_state

	var/list/percentages = list()
	percentages["oxygen"] = oxygen_percent
	percentages["nitrogen"] = nitrogen_percent
	percentages["co2"] = co2_percent
	percentages["plasma"] = plasma_percent
	percentages["n2o"] = sleeping_agent_percent
	percentages["other"] = other_percent
	data["contents"] = percentages

	var/list/danger = list()
	danger["pressure"] = pressure_dangerlevel
	danger["temperature"] = temperature_dangerlevel
	danger["oxygen"] = oxygen_dangerlevel
	danger["nitrogen"] = nitrogen_dangerlevel
	danger["co2"] = co2_dangerlevel
	danger["plasma"] = plasma_dangerlevel
	danger["n2o"] = sleeping_agent_dangerlevel
	danger["other"] = other_dangerlevel
	danger["overall"] = max(pressure_dangerlevel,oxygen_dangerlevel,nitrogen_dangerlevel,co2_dangerlevel,plasma_dangerlevel,other_dangerlevel,temperature_dangerlevel)
	data["danger"] = danger
	return data

/obj/machinery/alarm/proc/has_rcon_access(mob/user)
	return user && (is_ai(user) || allowed(user) || emagged || rcon_setting == RCON_YES)

// Intentional nulls here
/obj/machinery/alarm/ui_data(mob/user)
	var/list/data = list()

	data["name"] = name
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
		"mode[AALARM_MODE_FILTERING]"		= list("name"=GLOB.aalarm_modes["[AALARM_MODE_FILTERING]"],	"desc"="Scrubs out contaminants. Will shut off and drop firelocks if pressure drops too low.", "id" = AALARM_MODE_FILTERING),
		"mode[AALARM_MODE_DRAUGHT]"			= list("name"=GLOB.aalarm_modes["[AALARM_MODE_DRAUGHT]"],			"desc"="Siphons out air while replacing", "id" = AALARM_MODE_DRAUGHT),
		"mode[AALARM_MODE_PANIC]"			= list("name"=GLOB.aalarm_modes["[AALARM_MODE_PANIC]"],				"desc"="Siphons air out of the room quickly", "id" = AALARM_MODE_PANIC),
		"mode[AALARM_MODE_CYCLE]"			= list("name"=GLOB.aalarm_modes["[AALARM_MODE_CYCLE]"],				"desc"="Siphons air before replacing", "id" = AALARM_MODE_CYCLE),
		"mode[AALARM_MODE_SIPHON]"			= list("name"=GLOB.aalarm_modes["[AALARM_MODE_SIPHON]"],			"desc"="Siphons air out of the room", "id" = AALARM_MODE_SIPHON),
		"mode[AALARM_MODE_CONTAMINATED]"	= list("name"=GLOB.aalarm_modes["[AALARM_MODE_CONTAMINATED]"],		"desc"="Scrubs out all contaminants quickly", "id" = AALARM_MODE_CONTAMINATED),
		"mode[AALARM_MODE_REFILL]"			= list("name"=GLOB.aalarm_modes["[AALARM_MODE_REFILL]"],			"desc"="Refills a room to normal pressure, then switches to Filtering.", "id" = AALARM_MODE_REFILL),
		"mode[AALARM_MODE_CUSTOM]"			= list("name"=GLOB.aalarm_modes["[AALARM_MODE_CUSTOM]"],			"desc"="Custom settings with no automatic mode switching.", "id" = AALARM_MODE_CUSTOM),
		"mode[AALARM_MODE_OFF]"				= list("name"=GLOB.aalarm_modes["[AALARM_MODE_OFF]"],				"desc"="Shuts off vents and scrubbers", "id" = AALARM_MODE_OFF),
		"mode[AALARM_MODE_FLOOD]"			= list("name"=GLOB.aalarm_modes["[AALARM_MODE_FLOOD]"],				"desc"="Shuts off scrubbers and opens vents", 	"emagonly" = TRUE, "id" = AALARM_MODE_FLOOD)
	)
	data["mode"] = mode
	data["presets"] = list(
		AALARM_PRESET_HUMAN		= list("name"="Human",     	 "desc"="Checks for oxygen and nitrogen", "id" = AALARM_PRESET_HUMAN),\
		AALARM_PRESET_VOX 		= list("name"="Vox",       	 "desc"="Checks for nitrogen only", "id" = AALARM_PRESET_VOX),\
		AALARM_PRESET_COLDROOM 	= list("name"="Coldroom", 	 "desc"="For freezers", "id" = AALARM_PRESET_COLDROOM),\
		AALARM_PRESET_SERVER 	= list("name"="Server Room", "desc"="For server rooms", "id" = AALARM_PRESET_SERVER),\
		AALARM_PRESET_DISABLED 	= list("name"="Disabled", "desc"="Disables all alarms", "id" = AALARM_PRESET_DISABLED)
	)
	data["preset"] = preset

	var/list/vents = list()
	if(length(alarm_area.vents))
		for(var/obj/machinery/atmospherics/unary/vent_pump/P as anything in alarm_area.vents)
			var/list/vent_info = list()
			vent_info["id_tag"] = P.UID()
			vent_info["name"] = P.name
			vent_info["power"] = P.on
			vent_info["direction"] = P.releasing
			vent_info["checks"] = P.pressure_checks
			vent_info["external"] = P.external_pressure_bound
			vents += list(vent_info)
	data["vents"] = vents

	var/list/scrubbers = list()
	if(length(alarm_area.scrubbers))
		for(var/obj/machinery/atmospherics/unary/vent_scrubber/S as anything in alarm_area.scrubbers)
			var/list/scrubber_info = list()
			scrubber_info["id_tag"] = S.UID()
			scrubber_info["name"] = S.name
			scrubber_info["power"] = S.on
			scrubber_info["scrubbing"] = S.scrubbing
			scrubber_info["widenet"] = S.widenet
			scrubber_info["filter_o2"] = S.scrub_O2
			scrubber_info["filter_n2"] = S.scrub_N2
			scrubber_info["filter_co2"] = S.scrub_CO2
			scrubber_info["filter_toxins"] = S.scrub_Toxins
			scrubber_info["filter_n2o"] = S.scrub_N2O
			scrubbers += list(scrubber_info)
	data["scrubbers"] = scrubbers
	return data

/obj/machinery/alarm/proc/get_console_data(mob/user)
	var/list/data = list()
	data["name"] = name
	data["ref"] = "\ref[src]"
	data["danger"] = max(danger_level, alarm_area.atmosalm)
	var/area/A = get_area(src)
	data["area"] = A.name
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
		"nitrous oxide"  = "N2O",
		"other"          = "Other")
	for(var/g in gas_names)
		thresholds += list(list("name" = gas_names[g], "settings" = list()))
		selected = TLV[g]
		thresholds[length(thresholds)]["settings"] += list(list("env" = g, "val" = "min2", "selected" = selected.min2))
		thresholds[length(thresholds)]["settings"] += list(list("env" = g, "val" = "min1", "selected" = selected.min1))
		thresholds[length(thresholds)]["settings"] += list(list("env" = g, "val" = "max1", "selected" = selected.max1))
		thresholds[length(thresholds)]["settings"] += list(list("env" = g, "val" = "max2", "selected" = selected.max2))

	selected = TLV["pressure"]
	thresholds += list(list("name" = "Pressure", "settings" = list()))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "pressure", "val" = "min2", "selected" = selected.min2))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "pressure", "val" = "min1", "selected" = selected.min1))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "pressure", "val" = "max1", "selected" = selected.max1))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "pressure", "val" = "max2", "selected" = selected.max2))

	selected = TLV["temperature"]
	thresholds += list(list("name" = "Temperature", "settings" = list()))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "temperature", "val" = "min2", "selected" = selected.min2))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "temperature", "val" = "min1", "selected" = selected.min1))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "temperature", "val" = "max1", "selected" = selected.max1))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "temperature", "val" = "max2", "selected" = selected.max2))

	return thresholds

/obj/machinery/alarm/ui_state(mob/user)
	if(issilicon(user))
		if(is_ai(user))
			var/mob/living/silicon/ai/AI = user
			if(!AI.lacks_power() || AI.apc_override)
				return GLOB.always_state
		else
			for(var/obj/machinery/computer/atmoscontrol/AC in view(user.client.maxview(), user))
				if(!AC.stat)
					return GLOB.always_state

	if(ishuman(user))
		for(var/obj/machinery/computer/atmoscontrol/AC in range(1, user))
			if(!AC.stat)
				return GLOB.always_state

	return GLOB.default_state

/obj/machinery/alarm/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirAlarm", name)
		ui.open()

/obj/machinery/alarm/proc/is_authenticated(mob/user, datum/tgui/ui = null, bypass = FALSE)
	// Return true if they are connecting with a remote console
	// lol this is a wank hack, please don't shoot me
	for(var/obj/machinery/computer/atmoscontrol/control in orange(1, user))
		return TRUE
	if(user.can_admin_interact())
		return TRUE
	else if(is_ai(user) || isrobot(user) || emagged || user.has_unlimited_silicon_privilege)
		return TRUE
	else
		return !locked

/obj/machinery/alarm/ui_status(mob/user, datum/ui_state/state)
	if(buildstage != AIR_ALARM_READY)
		return UI_CLOSE

	if(aidisabled && (is_ai(user) || isrobot(user)))
		to_chat(user, "<span class='warning'>AI control for \the [src] interface has been disabled.</span>")
		return UI_CLOSE

	. = shorted ? UI_DISABLED : UI_INTERACTIVE

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
			var/cmd = params["cmd"]
			switch(cmd)
				if("power",
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
					var/val = isnum(params["val"]) ? params["val"] : text2num(params["val"])
					if(isnull(val))
						var/newval = tgui_input_number(usr, "Enter new value", "New Value", ONE_ATMOSPHERE, 1000 + ONE_ATMOSPHERE, 0, round_value = FALSE)
						if(isnull(newval))
							return
						val = newval

					// Figure out what it is
					var/obj/machinery/atmospherics/unary/U = locateUID(device_id)
					if(!U)
						return

					if(!((U in alarm_area.vents) || (U in alarm_area.scrubbers)))
						message_admins("<span class='boldannounceooc'>[key_name_admin(usr)] attempted to href-exploit an air alarm to control another object!!!</span>")
						return

					mode = AALARM_MODE_CUSTOM

					// Its a vent. Handle
					if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
						var/obj/machinery/atmospherics/unary/vent_pump/V = U

						if(V.stat & (NOPOWER|BROKEN))
							return

						switch(cmd)
							if("power")
								V.on = val
							if("adjust_external_pressure")
								V.external_pressure_bound = clamp(V.external_pressure_bound + val, 0, ONE_ATMOSPHERE * 50)
							if("set_external_pressure")
								V.external_pressure_bound = clamp(val, 0, ONE_ATMOSPHERE * 50)
							if("checks")
								V.pressure_checks = val
							if("direction")
								V.releasing = val

						V.update_icon(UPDATE_ICON_STATE)

					// Its a scrubber. Do the same but ever so slightly similar.
					else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
						var/obj/machinery/atmospherics/unary/vent_scrubber/S = U

						if(S.stat & (NOPOWER|BROKEN))
							return

						switch(cmd)
							if("power")
								S.on = val
							if("co2_scrub")
								S.scrub_CO2 = val
							if("tox_scrub")
								S.scrub_Toxins = val
							if("n2o_scrub")
								S.scrub_N2O = val
							if("n2_scrub")
								S.scrub_N2 = val
							if("o2_scrub")
								S.scrub_O2 = val
							if("widenet")
								S.widenet = val
							if("scrubbing")
								S.scrubbing = val

						S.update_icon(UPDATE_ICON_STATE)

				if("set_threshold")
					var/env = params["env"]
					var/varname = params["var"]
					if(!(varname in list("min1", "min2", "max1", "max2"))) // uh oh
						message_admins("[key_name_admin(usr)] attempted to href edit vars on [src]!!!")
						return
					var/datum/tlv/tlv = TLV[env]
					var/newval = tgui_input_number(usr, "Enter [varname] for [env]", "Alarm triggers", tlv.vars[varname], round_value = FALSE)
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
			alarm_area.atmosalert(ATMOS_ALARM_DANGER, src)
			alarmActivated = TRUE
			update_icon(UPDATE_ICON_STATE)

		if("atmos_reset")
			alarm_area.atmosalert(ATMOS_ALARM_NONE, src, TRUE)
			alarmActivated = FALSE
			update_icon(UPDATE_ICON_STATE)

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
			var/input_temperature = tgui_input_number(usr, "What temperature would you like the system to maintain? (Capped between [min_temperature_c]C and [max_temperature_c]C)", "Thermostat Controls", target_temperature - T0C, max_temperature_c, min_temperature_c)
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
			user.visible_message("<span class='warning'>Sparks fly out of \the [src]!</span>", "<span class='notice'>You emag \the [src], disabling its safeties.</span>")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 50, TRUE)
		return TRUE

/obj/machinery/alarm/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	add_fingerprint(user)

	switch(buildstage)
		if(AIR_ALARM_READY)
			if(istype(used, /obj/item/card/id) || istype(used, /obj/item/pda))// trying to unlock the interface with an ID card
				if(stat & (NOPOWER|BROKEN))
					return ITEM_INTERACT_COMPLETE

				if(allowed(user) && !wires.is_cut(WIRE_IDSCAN))
					locked = !locked
					to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the Air Alarm interface.</span>")
					SStgui.update_uis(src)
				else
					to_chat(user, "<span class='warning'>Access denied.</span>")

				return ITEM_INTERACT_COMPLETE

		if(AIR_ALARM_UNWIRED)
			if(iscoil(used))
				var/obj/item/stack/cable_coil/coil = used
				if(coil.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need more cable for this!</span>")
					return ITEM_INTERACT_COMPLETE

				to_chat(user, "<span class='notice'>You wire [src]!</span>")
				playsound(get_turf(src), coil.usesound, 50, 1)
				coil.use(5)

				buildstage = AIR_ALARM_READY
				wiresexposed = TRUE
				update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
				first_run()
				return ITEM_INTERACT_COMPLETE
		if(AIR_ALARM_FRAME)
			if(istype(used, /obj/item/airalarm_electronics))
				to_chat(user, "<span class='notice'>You insert [used] into [src].</span>")
				playsound(get_turf(src), used.usesound, 50, TRUE)
				qdel(used)
				buildstage = AIR_ALARM_UNWIRED
				update_icon(UPDATE_ICON_STATE)
				return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/alarm/crowbar_act(mob/user, obj/item/I)
	if(buildstage != AIR_ALARM_UNWIRED)
		return
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	CROWBAR_ATTEMPT_PRY_CIRCUIT_MESSAGE
	if(!I.use_tool(src, user, 20, volume = I.tool_volume))
		return
	if(buildstage != AIR_ALARM_UNWIRED)
		return
	CROWBAR_PRY_CIRCUIT_SUCCESS_MESSAGE
	new /obj/item/airalarm_electronics(loc)
	buildstage = AIR_ALARM_FRAME
	update_icon(UPDATE_ICON_STATE)

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
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
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
		var/obj/item/stack/cable_coil/new_coil = new /obj/item/stack/cable_coil(loc)
		new_coil.amount = 5
		buildstage = AIR_ALARM_UNWIRED
		update_icon(UPDATE_ICON_STATE)
		return
	if(wiresexposed)
		wires.Interact(user)

/obj/machinery/alarm/wrench_act(mob/user, obj/item/I)
	if(buildstage != AIR_ALARM_FRAME)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	new /obj/item/mounted/frame/alarm_frame(loc)
	WRENCH_UNANCHOR_WALL_MESSAGE
	qdel(src)

/obj/machinery/alarm/power_change()
	..()
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/obj/machinery/alarm/obj_break(damage_flag)
	..()
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/obj/machinery/alarm/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 2)
		var/obj/item/I = new /obj/item/airalarm_electronics(loc)
		if(!disassembled)
			I.obj_integrity = I.max_integrity * 0.5
		new /obj/item/stack/cable_coil(loc, 3)
	qdel(src)

/obj/machinery/alarm/AltClick(mob/user)
	if(Adjacent(user) && allowed(user) && !wires.is_cut(WIRE_IDSCAN))
		locked = !locked
		to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the Air Alarm interface.</span>")
	else
		to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/machinery/alarm/examine(mob/user)
	. = ..()
	switch(buildstage)
		if(AIR_ALARM_FRAME)
			. += "<span class='notice'>Its <i>circuit</i> is missing and the <b>bolts</b> are exposed.</span>"
		if(AIR_ALARM_UNWIRED)
			. += "<span class='notice'>The frame is missing <i>wires</i> and the control circuit can be <b>pried out</b>.</span>"
		if(AIR_ALARM_READY)
			if(wiresexposed)
				. += "<span class='notice'>The wiring could be <i>cut and removed</i> or panel could <b>screwed</b> closed.</span>"
			else
				. += "<span class='notice'>You can unlock an Air Alarm by using an ID with the required access on it (shortcut: <b>Alt-click</b>), or ask a local synthetic.</span>"

/obj/machinery/alarm/proc/unshort_callback()
	if(shorted)
		shorted = FALSE
		update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/obj/machinery/alarm/proc/enable_ai_control_callback()
	if(aidisabled)
		aidisabled = FALSE

/obj/machinery/alarm/all_access
	desc = "A wall-mounted device used to control atmospheric equipment. Its access restrictions appear to have been removed."
	locked = FALSE
	custom_name = "all-access air alarm"
	req_access = null
	req_one_access = null

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm, 24, 24)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm/all_access, 24, 24)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm/engine, 24, 24)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm/monitor, 24, 24)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm/server, 24, 24)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm/syndicate, 24, 24)

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
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	origin_tech = "engineering=2;programming=1"
	usesound = 'sound/items/deconstruct.ogg'

#undef AALARM_PRESET_HUMAN
#undef AALARM_PRESET_VOX
#undef AALARM_PRESET_COLDROOM
#undef AALARM_PRESET_SERVER
#undef AALARM_PRESET_DISABLED
#undef AALARM_REPORT_TIMEOUT
#undef RCON_NO
#undef RCON_AUTO
#undef RCON_YES
#undef MAX_ENERGY_CHANGE
#undef MAX_TEMPERATURE
#undef MIN_TEMPERATURE
