#define SM_EVENT_CLASS_ANOMALY "Class Anomaly"
#define SM_EVENT_THREAT_D 0
#define SM_EVENT_THREAT_C 1
#define SM_EVENT_THREAT_B 2
#define SM_EVENT_THREAT_A 3
#define SM_EVENT_THREAT_S 4

/datum/supermatter_event
	name = "Unknown XK-Class Anomaly (Report this to coders)"
	var/obj/machinery/atmospherics/supermatter_crystal/supermatter
	var/datum/gas_mixture/environment
	var/threat_level
	# warn this threat_level var might not be needed, if you can't find a good use for it, remove it
	var/duration

/datum/supermatter_event/New(obj/machinery/atmospherics/supermatter_crystal/_supermatter)
	. = ..()
	supermatter = _supermatter
	if(!supermatter)
		stack_trace("a /datum/supermatter_event was called without an involved supermatter.")
		return
	if(!istype(supermatter))
		stack_trace("a /datum/supermatter_event was called with (name: [supermatter], type: [supermatter.type]) instead!")
		return
	var/turf/T = get_turf(supermatter)
	environment = T.return_air()
	supermatter.event_active = src

/datum/supermatter_event/proc/start_event()
	on_start()
	alert_engi()
	if(duration)
		addtimer(CALLBACK(src, PROC_REF(on_end)), 30 SECONDS)

/datum/supermatter_event/proc/on_start()
	return

/datum/supermatter_event/proc/alert_engi()
	return

/datum/supermatter_event/proc/after_duration()
	// Normally, just call on end. Some s-class events require a 2 timers
	on_end()

/datum/supermatter_event/proc/on_end()
	sm_radio_say("Anomalous crystal activity has ended.")
	supermatter.heat_penalty_threshold = HEAT_PENALTY_THRESHOLD
	supermatter.gas_multiplier = 1
	supermatter.power_additive = 0
	supermatter.event_active = null
	supermatter.last_event = src

/datum/supermatter_event/proc/sm_radio_say(text)
	if(!text)
		return
	supermatter.radio.autosay(text, name, "Engineering", list(z))

// Below this are procs used for the SM events, in order of severity

//D class events

/datum/supermatter_event/delta_tier/
	threat = SM_EVENT_THREAT_D

// sleeping gas
/datum/supermatter_event/delta_tier/sleeping_gas
	name = "D-1"

/datum/supermatter_event/delta_tier/sleeping_gas/on_start()
	environment.sleeping_agent += 200

// nitrogen
/datum/supermatter_event/delta_tier/nitrogen
	name = "D-2"

/datum/supermatter_event/delta_tier/sleeping_gas/on_start()
	environment.nitrogen += 200

// carbon dioxide
/datum/supermatter_event/delta_tier/carbon_dioxide
	name = "D-3"

/datum/supermatter_event/delta_tier/sleeping_gas/on_start()
	environment.carbon_dioxide += 250


// C class events

/datum/supermatter_event/charlie_tier
	threat = SM_EVENT_THREAT_C
	duration = 30 SECONDS

/datum/supermatter_event/charlie_tier/alert_engi()
	sm_radio_say("Anomalous crystal activity detected! Activity class: [name]. Operator intervention may be required!")

// oxygen
/datum/supermatter_event/charlie_tier/oxygen
	name = "C-1"

/datum/supermatter_event/charlie_tier/oxygen/on_start()
	environment.oxygen += 250

// plasma
/datum/supermatter_event/charlie_tier/plasma
	name = "C-2"

/datum/supermatter_event/charlie_tier/plasma/on_start()
	environment.toxins += 200

// make it bad to the cold? idk what the fuck this does
# warn add a better comment here
/datum/supermatter_event/charlie_tier/heat_penalty_threshold
	name = "C-3"
	duration = 1 MINUTES

/datum/supermatter_event/charlie_tier/heat_penalty_threshold/on_start()
	supermatter.heat_penalty_threshold = -73

//Class B events
/datum/supermatter_event/beta_tier
	threat = SM_EVENT_THREAT_B
	duration = 1 MINUTES

/datum/supermatter_event/beta_tier/alert_engi()
	sm_radio_say("Anomalous crystal activity detected! Activity class: [name]. Operator intervention is required!")


//type 1
/obj/machinery/atmospherics/supermatter_crystal/proc/event_b1()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/atmospherics/supermatter_crystal, end_event)), 1 MINUTES)
	src.radio.autosay("Anomalous crystal activity detected! Activity class: B-1. Operator intervention is required!", name, "Engineering", list(z))
	gas_multiplier = 1.5
	event_active = TRUE
	name = "B-1"
	return

//type 2
/obj/machinery/atmospherics/supermatter_crystal/proc/event_b2()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/atmospherics/supermatter_crystal, end_event)), 1 MINUTES)
	src.radio.autosay("Anomalous crystal activity detected! Activity class: B-2. Operator intervention is required!", name, "Engineering", list(z))
	heat_multiplier = 1.25
	event_active = TRUE
	name = "B-3"
	return

//type 3
/obj/machinery/atmospherics/supermatter_crystal/proc/event_b3()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/atmospherics/supermatter_crystal, end_event)), 1 MINUTES)
	src.radio.autosay("Anomalous crystal activity detected! Activity class: B-1. Operator intervention is required!", name, "Engineering", list(z))
	power_additive = 2000
	event_active = TRUE
	name = "B-2"
	return

//A class events
//type 1
/obj/machinery/atmospherics/supermatter_crystal/proc/event_a1()
	src.radio.autosay("ALERT: Critical anomalous crystal activity detected! Activity class: A-1. IMMEDIATE Operator intervention is REQUIRED!", name, "Engineering", list(z))
	var/area/current_area = get_area(src)
	var/obj/machinery/power/apc/A = current_area.get_apc()
	if(A.wires)
		if(!A.wires.is_cut(WIRE_MAIN_POWER1))
			A.wires.cut(WIRE_MAIN_POWER1)
		if(A.wires.is_cut(WIRE_MAIN_POWER2))
			A.wires.cut(WIRE_MAIN_POWER2)
	if(A.operating)
		A.toggle_breaker()
	event_active = TRUE
	name = "A-1"
	return

//type 2
/obj/machinery/atmospherics/supermatter_crystal/proc/event_a2()
	src.radio.autosay("ALERT: Critical anomalous crystal activity detected! Activity class: A-2. IMMEDIATE Operator intervention is REQUIRED!", name, "Engineering", list(z))
	var/area/current_area = get_area(src)
	var/obj/machinery/alarm/engine/A = current_area.master_air_alarm
	A.apply_mode(AALARM_MODE_SCRUBBING)
	event_active = TRUE
	name = "A-2"
	return

//type 3
/obj/machinery/atmospherics/supermatter_crystal/proc/event_a3()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/atmospherics/supermatter_crystal, end_event)), 2 MINUTES)
	src.radio.autosay("ALERT: Critical anomalous crystal activity detected! Activity class: A-3. IMMEDIATE Operator intervention is REQUIRED!", name, "Engineering", list(z))
	gas_multiplier = 4
	event_active = TRUE
	name = "A-3"
	return

//S class events
//Arc-type
/obj/machinery/atmospherics/supermatter_crystal/proc/event_arctimer()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/atmospherics/supermatter_crystal, event_arc)), 5 MINUTES)
	src.radio.autosay("ALERT: Anomalous supermatter state expected in: 5 minutes", name, null, list(z))
	src.radio.autosay("EMERGENCY ALERT: 5 MINUTES UNTIL [src] EXHIBITS S-ARC CLASS ANOMALOUS ACTIVITY!", name, "Engineering", list(z))
	return
/obj/machinery/atmospherics/supermatter_crystal/proc/event_arc()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/atmospherics/supermatter_crystal, end_event)), 2 MINUTES)
	src.radio.autosay("ALERT: ANOMALOUS SUPERMATTER STATE DETECTED!", name, null, list(z))
	src.radio.autosay("EMERGENCY ALERT: Class S-ARC anomalous behavior in progress!", name, "Engineering", list(z))
	power_additive = 6000
	event_active = TRUE
	name = "S-ARC
	return

//Laminate Rejection-type
/obj/machinery/atmospherics/supermatter_crystal/proc/event_ejectiontimer()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/atmospherics/supermatter_crystal, event_ejection)), 5 MINUTES)
	src.radio.autosay("ALERT: Anomalous supermatter state expected in: 5 minutes", name, null, list(z))
	src.radio.autosay("EMERGENCY ALERT: 5 MINUTES UNTIL [src] EXHIBITS S-LAMINATE REJECTION CLASS ANOMALOUS ACTIVITY!", name, "Engineering", list(z))
	return
/obj/machinery/atmospherics/supermatter_crystal/proc/event_ejection()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/atmospherics/supermatter_crystal, end_event)), 2 MINUTES)
	src.radio.autosay("ALERT: ANOMALOUS SUPERMATTER STATE DETECTED!", name, null, list(z))
	src.radio.autosay("EMERGENCY ALERT: Class S-LAMINATE REJECTION anomalous behavior in progress!", name, "Engineering", list(z))
	heat_multiplier = 10
	event_active = TRUE
	name = "S-LAMINATE REJECTION
	return
