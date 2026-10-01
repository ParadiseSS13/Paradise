

/datum/engi_event/reactor_event
	name = "Unknown X-K (Report this to coders)"
	var/obj/machinery/atmospherics/fission_reactor/reactor
	var/turf/reactor_turf
	var/end_message = TRUE
	var/end_message_contents = "<b>Heightened reactor activity has ended.</b>"

/datum/engi_event/reactor_event/New(obj/machinery/atmospherics/fission_reactor/_reactor)
	. = ..()
	reactor = _reactor
	if(!reactor)
		stack_trace("a /datum/engi_event/reactor_event was called without an involved reactor.")
		return
	if(!istype(reactor))
		stack_trace("a /datum/engi_event/reactor_event was called with (name: [reactor], type: [reactor.type]) instead of a reactor!")
		return

/datum/engi_event/reactor_event/start_event()
	reactor.event_active = src
	reactor.investigate_log("event [src] has been triggered", INVESTIGATE_REACTOR)
	. = ..()

/datum/engi_event/reactor_event/on_end()
	if(end_message)
		reactor_radio_say(end_message_contents)
	reactor.event_gas_multiplier = 1
	reactor.event_heat_multiplier = 1
	reactor.event_power_additive = 0
	reactor.event_active = null
	reactor.event_reactivity_additive = 0

/datum/engi_event/reactor_event/proc/reactor_radio_say(text)
	if(!text)
		return
	reactor.radio.autosay(text, reactor.name, "Engineering")

/datum/engi_event/reactor_event/proc/general_radio_say(text)
	if(!text)
		return
	reactor.radio.autosay(text, reactor.name, null)

// Below this are procs used for the Reactor events, in order of severity.

// MARK: D class events

/datum/engi_event/reactor_event/delta_tier
	threat_level = SM_EVENT_THREAT_D
	duration = 10 SECONDS

/datum/engi_event/reactor_event/delta_tier/alert_engi()
	reactor_radio_say("Heightened neutron activity detected. Activity class: [name]. Operator intervention may be required.")

/datum/engi_event/reactor_event/delta_tier/sleeping_gas
	name = "D-1"

// MARK: C class events

/datum/engi_event/reactor_event/charlie_tier
	threat_level = SM_EVENT_THREAT_C
	duration = 15 SECONDS

/datum/engi_event/reactor_event/charlie_tier/generate_nitrogen_minor
	name = "D-1"

/datum/engi_event/reactor_event/charlie_tier/generate_gas_minor/on_start()
	reactor.generate_extra_gas = TRUE
	reactor.extra_gas_amount = 20
	reactor.extra_gas_type = pickweight(list(
		SPAWN_GAS_NITROGEN = 40,
		SPAWN_GAS_N2O = 10,
		SPAWN_GAS_CO2 = 20,
		SPAWN_GAS_PLASMA = 20,
		SPAWN_GAS_HYDROGEN = 5,
	))

/datum/engi_event/reactor_event/charlie_tier/generate_gas_minor/on_end()
	reactor.generate_extra_gas = FALSE

// MARK: B class events

/datum/engi_event/reactor_event/bravo_tier
	threat_level = SM_EVENT_THREAT_B
	duration = 1 MINUTES

// MARK: A class events

/datum/engi_event/reactor_event/alpha_tier
	threat_level = SM_EVENT_THREAT_A
	duration = 2 MINUTES

/datum/engi_event/reactor_event/alpha_tier/eject_rod


// MARK: S class events
// S-tier events are special. They are very dangerous, but give a 5 minute warning to the engis.

/datum/engi_event/reactor_event/sierra_tier
	threat_level = SM_EVENT_THREAT_S
	duration = 7 MINUTES // 5 minute leadup timer

/datum/engi_event/reactor_event/sierra_tier/on_start()
	addtimer(CALLBACK(src, PROC_REF(start_sierra_event)), 5 MINUTES)
	reactor.has_run_sclass = TRUE

/datum/engi_event/reactor_event/sierra_tier/alert_engi()
	general_radio_say(SPAN_BIG("ALERT: Anomalous reactor state expected in: 5 minutes."))
	reactor_radio_say(SPAN_REALLYBIG("EMERGENCY ALERT: 5 MINUTES UNTIL [reactor] EXHIBITS [name] CLASS EVENT!"))

/datum/engi_event/reactor_event/sierra_tier/proc/start_sierra_event()
	general_radio_say(SPAN_BIG("ALERT: CRITICAL REACTOR STATE DETECTED!"))
	reactor_radio_say(SPAN_REALLYBIG("EMERGENCY ALERT: Class [name] event in progress!"))
