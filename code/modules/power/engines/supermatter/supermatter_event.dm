/datum/engi_event/supermatter_event
	name = "Unknown X-K (Report this to coders)"
	var/obj/machinery/atmospherics/supermatter_crystal/supermatter
	var/turf/supermatter_turf

/datum/engi_event/supermatter_event/New(obj/machinery/atmospherics/supermatter_crystal/_supermatter)
	. = ..()
	supermatter = _supermatter
	supermatter_turf = get_turf(supermatter)
	if(!supermatter)
		stack_trace("a /datum/engi_event/supermatter_event was called without an involved supermatter.")
		return
	if(!istype(supermatter))
		stack_trace("a /datum/engi_event/supermatter_event was called with (name: [supermatter], type: [supermatter.type]) instead of a supermatter!")
		return

/datum/engi_event/supermatter_event/start_event()
	supermatter.event_active = src
	supermatter.investigate_log("event [src] has been triggered", INVESTIGATE_SUPERMATTER)
	. = ..()

/datum/engi_event/supermatter_event/on_end()
	sm_radio_say("<b>Anomalous crystal activity has ended.</b>")
	supermatter.heat_penalty_threshold = SUPERMATTER_HEAT_PENALTY_THRESHOLD
	supermatter.gas_multiplier = 1
	supermatter.power_additive = 0
	supermatter.heat_multiplier = 1
	supermatter.event_active = null

/datum/engi_event/supermatter_event/proc/sm_radio_say(text)
	if(!text)
		return
	supermatter.radio.autosay(text, supermatter.name, "Engineering")

/datum/engi_event/supermatter_event/proc/general_radio_say(text)
	if(!text)
		return
	supermatter.radio.autosay(text, supermatter.name, null)

// Below this are procs used for the SM events, in order of severity

//D class events

/datum/engi_event/supermatter_event/delta_tier
	threat_level = SM_EVENT_THREAT_D
	duration = 10 SECONDS

/datum/engi_event/supermatter_event/delta_tier/alert_engi()
	sm_radio_say("Abnormal crystal activity detected! Activity class: [name].")

// sleeping gas
/datum/engi_event/supermatter_event/delta_tier/sleeping_gas
	name = "D-1"

/datum/engi_event/supermatter_event/delta_tier/sleeping_gas/on_start()
	var/datum/gas_mixture/air = new()
	air.set_sleeping_agent(2000)
	supermatter_turf.blind_release_air(air)

// nitrogen
/datum/engi_event/supermatter_event/delta_tier/nitrogen
	name = "D-2"

/datum/engi_event/supermatter_event/delta_tier/nitrogen/on_start()
	var/datum/gas_mixture/air = new()
	air.set_nitrogen(2000)
	supermatter_turf.blind_release_air(air)

// carbon dioxide
/datum/engi_event/supermatter_event/delta_tier/carbon_dioxide
	name = "D-3"

/datum/engi_event/supermatter_event/delta_tier/carbon_dioxide/on_start()
	var/datum/gas_mixture/air = new()
	air.set_carbon_dioxide(2000)
	supermatter_turf.blind_release_air(air)


// C class events

/datum/engi_event/supermatter_event/charlie_tier
	threat_level = SM_EVENT_THREAT_C
	duration = 15 SECONDS

/datum/engi_event/supermatter_event/charlie_tier/alert_engi()
	sm_radio_say("Anomalous crystal activity detected. Activity class: [name]. Operator intervention may be required.")

// oxygen
/datum/engi_event/supermatter_event/charlie_tier/oxygen
	name = "C-1"

/datum/engi_event/supermatter_event/charlie_tier/oxygen/on_start()
	var/datum/gas_mixture/air = new()
	air.set_oxygen(2000)
	supermatter_turf.blind_release_air(air)

// plasma
/datum/engi_event/supermatter_event/charlie_tier/plasma
	name = "C-2"

/datum/engi_event/supermatter_event/charlie_tier/plasma/on_start()
	var/datum/gas_mixture/air = new()
	air.set_toxins(2000)
	supermatter_turf.blind_release_air(air)

// lowers the temp required for the SM to take damage.
/datum/engi_event/supermatter_event/charlie_tier/heat_penalty_threshold
	name = "C-3"
	duration = 5 MINUTES

/datum/engi_event/supermatter_event/charlie_tier/heat_penalty_threshold/on_start()
	supermatter.heat_penalty_threshold -= 173

//Class B events
/datum/engi_event/supermatter_event/bravo_tier
	threat_level = SM_EVENT_THREAT_B
	duration = 1 MINUTES

/datum/engi_event/supermatter_event/bravo_tier/alert_engi()
	sm_radio_say("<b>Anomalous crystal activity detected! Activity class: [name]. Operator intervention is required!</b>")


// more gas
/datum/engi_event/supermatter_event/bravo_tier/gas_multiply
	name = "B-1"

/datum/engi_event/supermatter_event/bravo_tier/gas_multiply/on_start()
	supermatter.gas_multiplier = 3


/datum/engi_event/supermatter_event/bravo_tier/heat_multiplier
	name = "B-2"

/datum/engi_event/supermatter_event/bravo_tier/heat_multiplier/on_start()
	supermatter.heat_multiplier = 3

/datum/engi_event/supermatter_event/bravo_tier/power_additive
	name = "B-3"

/datum/engi_event/supermatter_event/bravo_tier/power_additive/on_start()
	supermatter.power += 3000
	duration = 10 SECONDS

//A class events
/datum/engi_event/supermatter_event/alpha_tier
	threat_level = SM_EVENT_THREAT_A
	duration = 10 SECONDS

/datum/engi_event/supermatter_event/alpha_tier/alert_engi()
	sm_radio_say("<span class='big'>ALERT: Critical anomalous crystal activity detected! Activity class: [name]. IMMEDIATE Operator intervention is REQUIRED!</span>")

/datum/engi_event/supermatter_event/alpha_tier/apc_short
	name = "A-1"

/datum/engi_event/supermatter_event/alpha_tier/apc_short/on_start()
	var/area/current_area = get_area(supermatter)
	var/obj/machinery/power/apc/A = current_area.get_apc()
	A.apc_short()

/datum/engi_event/supermatter_event/alpha_tier/air_siphon
	name = "A-2"

/datum/engi_event/supermatter_event/alpha_tier/air_siphon/on_start()
	var/area/current_area = get_area(supermatter)
	for(var/obj/machinery/alarm/A in current_area)
		A.mode = AALARM_MODE_OFF
		A.apply_mode()

/datum/engi_event/supermatter_event/alpha_tier/gas_multiplier
	name = "A-3"
	duration = 2 MINUTES

/datum/engi_event/supermatter_event/alpha_tier/gas_multiplier/on_start()
	supermatter.gas_multiplier = 4

// S-tier events are special. They are very dangerous, but give a 5 minute warning to the engis.
/datum/engi_event/supermatter_event/sierra_tier
	threat_level = SM_EVENT_THREAT_S
	duration = 7 MINUTES // 2 MINUTES of s-tier anomaly

/datum/engi_event/supermatter_event/sierra_tier/alert_engi()
	general_radio_say("<span class='big'>ALERT: Anomalous supermatter state expected in: 5 minutes.</span>")
	sm_radio_say("<span class='reallybig'>EMERGENCY ALERT: 5 MINUTES UNTIL [supermatter] EXHIBITS [name] CLASS ANOMALOUS ACTIVITY!</span>")

/datum/engi_event/supermatter_event/sierra_tier/on_start()
	addtimer(CALLBACK(src, PROC_REF(start_sierra_event)), 5 MINUTES)
	supermatter.has_run_sclass = TRUE

/datum/engi_event/supermatter_event/sierra_tier/proc/start_sierra_event()
	general_radio_say("<span class='big'>ALERT: ANOMALOUS SUPERMATTER STATE DETECTED!</span>")
	sm_radio_say("<span class='reallybig'>EMERGENCY ALERT: Class [name] anomalous behavior in progress!</span>")

//S class events
//Arc-type
/datum/engi_event/supermatter_event/sierra_tier/arc
	name = "S-ARC"

/datum/engi_event/supermatter_event/sierra_tier/arc/start_sierra_event()
	..()
	supermatter.power_additive = 6000

// Laminate type
/datum/engi_event/supermatter_event/sierra_tier/laminate
	name = "S-LAMINATE REJECTION"

/datum/engi_event/supermatter_event/sierra_tier/laminate/start_sierra_event()
	..()
	supermatter.heat_multiplier = 25
	supermatter.gas_multiplier = 25
	empulse(supermatter, 3, 6, TRUE, "S-laminite event")
