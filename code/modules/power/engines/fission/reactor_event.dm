

/datum/engi_event/reactor_event
	name = "Unknown X-K (Report this to coders)"
	var/obj/machinery/atmospherics/fission_reactor/reactor
	var/turf/reactor_turf
	var/end_message = TRUE
	var/end_message_contents = "<b>Abnormal reactor conditions have ended.</b>"

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
	reactor.event_reactivity_additive = 0
	reactor.event_meltdown_chance = 0
	reactor.generate_extra_gas = FALSE
	reactor.event_active = null

/datum/engi_event/reactor_event/proc/begin_async_event()
	return

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
	reactor_radio_say("Abnormal reactor conditions detected! Activity class: [name].")

/datum/engi_event/reactor_event/delta_tier/generate_nitrogen_minor
	name = "D-1"

/datum/engi_event/reactor_event/delta_tier/generate_nitrogen_minor/on_start()
	reactor.generate_extra_gas = TRUE
	reactor.extra_gas_amount = rand(8, 12)
	reactor.extra_gas_type = SPAWN_GAS_NITROGEN


/datum/engi_event/reactor_event/delta_tier/generate_sleepy_gas_minor
	name = "D-2"

/datum/engi_event/reactor_event/delta_tier/generate_sleepy_gas_minor/on_start()
	reactor.generate_extra_gas = TRUE
	reactor.extra_gas_amount = rand(8, 12)
	reactor.extra_gas_type = SPAWN_GAS_N2O


/datum/engi_event/reactor_event/delta_tier/generate_co2_minor
	name = "D-3"

/datum/engi_event/reactor_event/delta_tier/generate_co2_minor/on_start()
	reactor.generate_extra_gas = TRUE
	reactor.extra_gas_amount = rand(8, 12)
	reactor.extra_gas_type = SPAWN_GAS_CO2


/datum/engi_event/reactor_event/delta_tier/generate_water_minor
	name = "D-4"

/datum/engi_event/reactor_event/delta_tier/generate_water_minor/on_start()
	reactor.generate_extra_gas = TRUE
	reactor.extra_gas_amount = rand(8, 12)
	reactor.extra_gas_type = SPAWN_GAS_WATER


// MARK: C class events

/datum/engi_event/reactor_event/charlie_tier
	threat_level = SM_EVENT_THREAT_C
	duration = 15 SECONDS

/datum/engi_event/reactor_event/charlie_tier/alert_engi()
	reactor_radio_say("Abnormal reactor conditions detected! Activity class: [name]. Operator intervention may be required.")

/datum/engi_event/reactor_event/charlie_tier/generate_nitrogen_moderate
	name = "C-1"

/datum/engi_event/reactor_event/charlie_tier/generate_nitrogen_moderate/on_start()
	reactor.generate_extra_gas = TRUE
	reactor.extra_gas_amount = rand(25, 40)
	reactor.extra_gas_type = SPAWN_GAS_WATER

/datum/engi_event/reactor_event/delta_tier/generate_sleepy_gas_moderate
	name = "C-2"

/datum/engi_event/reactor_event/delta_tier/generate_sleepy_gas_moderate/on_start()
	reactor.generate_extra_gas = TRUE
	reactor.extra_gas_amount = rand(25, 40)
	reactor.extra_gas_type = SPAWN_GAS_N2O

/datum/engi_event/reactor_event/delta_tier/generate_o2_moderate
	name = "C-3"

/datum/engi_event/reactor_event/delta_tier/generate_o2_moderate/on_start()
	reactor.generate_extra_gas = TRUE
	reactor.extra_gas_amount = rand(25, 40)
	reactor.extra_gas_type = SPAWN_GAS_OXYGEN

/datum/engi_event/reactor_event/delta_tier/generate_hydrogen_moderate
	name = "C-4"

/datum/engi_event/reactor_event/delta_tier/generate_hydrogen_moderate/on_start()
	reactor.generate_extra_gas = TRUE
	reactor.extra_gas_amount = rand(25, 40)
	reactor.extra_gas_type = SPAWN_GAS_HYDROGEN

// MARK: B class events

/datum/engi_event/reactor_event/bravo_tier
	threat_level = SM_EVENT_THREAT_B
	duration = 1 MINUTES

/datum/engi_event/reactor_event/bravo_tier/alert_engi()
	reactor_radio_say("Abnormal reactor conditions detected! Activity class: [name]. Operator intervention recommended.")

/datum/engi_event/reactor_event/bravo_tier/raise_chamber
	name = "B-1"
	end_message = FALSE

/datum/engi_event/reactor_event/bravo_tier/raise_chamber/alert_engi()
	reactor_radio_say("Abnormal reactor conditions detected! Activity class: [name]. Raising Nuclear Containment Chamber due to fault.")

/datum/engi_event/reactor_event/bravo_tier/raise_chamber/on_start()
	INVOKE_ASYNC(src, PROC_REF(begin_async_event))

/datum/engi_event/reactor_event/bravo_tier/raise_chamber/begin_async_event()
	var/list/full_chambers = list()
	for(var/obj/machinery/atmospherics/reactor_chamber/chamber in reactor.connected_chambers)
		if(chamber.held_rod && chamber.chamber_state == CHAMBER_DOWN)
			full_chambers += chamber

	var/obj/machinery/atmospherics/reactor_chamber/picked_chamber = pick(full_chambers)
	picked_chamber.raise()
	sleep(0.7 SECONDS)
	picked_chamber.open()

/datum/engi_event/reactor_event/bravo_tier/gas_multiplier
	name = "B-2"

/datum/engi_event/reactor_event/bravo_tier/gas_multiplier/on_start()
	reactor.event_gas_multiplier = 3

/datum/engi_event/reactor_event/bravo_tier/heat_multiplier
	name = "B-3"

/datum/engi_event/reactor_event/bravo_tier/heat_multiplier/on_start()
	reactor.event_gas_multiplier = 3

/datum/engi_event/reactor_event/bravo_tier/reactivity_additive
	name = "B-4"

/datum/engi_event/reactor_event/bravo_tier/reactivity_additive/on_start()
	reactor.event_reactivity_additive = 2
	reactor.event_power_additive += 100 KW

/datum/engi_event/reactor_event/bravo_tier/vent_toggle
	name = "B-5"
	end_message = FALSE

/datum/engi_event/reactor_event/bravo_tier/vent_toggle/on_start()
	reactor.venting = !reactor.venting

/datum/engi_event/reactor_event/bravo_tier/control_rod_failure
	name = "B-6"
	duration = 20 SECONDS

/datum/engi_event/reactor_event/bravo_tier/control_rod_failure/on_start()
	INVOKE_ASYNC(src, PROC_REF(begin_async_event))

/datum/engi_event/reactor_event/bravo_tier/control_rod_failure/begin_async_event()
	sleep(5 SECONDS)
	var/amount_of_failures = rand(1, 3)
	while(amount_of_failures)
		reactor.control_rod_failure()
		amount_of_failures--
		sleep(2 SECONDS)

// MARK: A class events

/datum/engi_event/reactor_event/alpha_tier
	threat_level = SM_EVENT_THREAT_A
	duration = 2 MINUTES

/datum/engi_event/reactor_event/alpha_tier/alert_engi()
	reactor_radio_say("ALERT: Highly Unstable reactor conditions detected! Activity class: [name]. IMMEDIATE Operator intervention is REQUIRED!")

/datum/engi_event/reactor_event/alpha_tier/eject_rod
	name = "A-1"
	end_message = FALSE

/datum/engi_event/reactor_event/alpha_tier/eject_rod/on_start()
	INVOKE_ASYNC(src, PROC_REF(begin_async_event))

/datum/engi_event/reactor_event/alpha_tier/eject_rod/begin_async_event()
	sleep(5 SECONDS) // a short warning
	var/list/full_chambers = list()
	for(var/obj/machinery/atmospherics/reactor_chamber/chamber in reactor.connected_chambers)
		if(chamber.held_rod && chamber.chamber_state == CHAMBER_DOWN)
			full_chambers += chamber

	if(!full_chambers.len)
		return

	var/ejection_amount = rand(2,5)
	while(ejection_amount)
		if(!full_chambers.len)
			return
		var/obj/machinery/atmospherics/reactor_chamber/picked_chamber = pick(full_chambers)
		picked_chamber.eject_rod()
		full_chambers -= picked_chamber
		ejection_amount--
		sleep(0.3 SECONDS)

/datum/engi_event/reactor_event/alpha_tier/apc_short
	name = "A-2"
	end_message = FALSE

/datum/engi_event/reactor_event/alpha_tier/apc_short/on_start()
	var/area/current_area = get_area(reactor)
	var/obj/machinery/power/apc/A = current_area.get_apc()
	A.apc_short()

/datum/engi_event/reactor_event/alpha_tier/adjust_throttle
	name = "A-3"
	end_message = FALSE

/datum/engi_event/reactor_event/alpha_tier/adjust_throttle/on_start()
	if(prob(30) && reactor.desired_power < 90) // chance to just near-max it...
		reactor.desired_power = rand(90, 100)
	else
		reactor.desired_power = rand(10, 100)

/datum/engi_event/reactor_event/alpha_tier/integrity_hit
	name = "A-4"
	end_message = FALSE

/datum/engi_event/reactor_event/alpha_tier/integrity_hit/on_start()
	reactor.damage = clamp(reactor.damage + rand(350, 650), 0, 950) // no exploding for you
	reactor.event_reactivity_additive = 3

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
	reactor_powered_lockout()

/datum/engi_event/reactor_event/sierra_tier/on_end()
	..()
	reactor.control_lockout = FALSE

/// Locks out the reactor at its highest power setting. For extra tension.
/datum/engi_event/reactor_event/sierra_tier/proc/reactor_powered_lockout()
	reactor.control_lockout = TRUE // Nuh uh
	reactor.desired_power = 100
	reactor.operating_power = 100
	if(reactor.offline || reactor.starting_up)
		reactor.become_operational()

/datum/engi_event/reactor_event/sierra_tier/waste_flood
	name = "S-FLOOD"
	duration = 6 MINUTES // a little shorter than the others

/datum/engi_event/reactor_event/sierra_tier/waste_flood/start_sierra_event()
	..()
	reactor.generate_extra_gas = TRUE
	reactor.extra_gas_type = SPAWN_GAS_HYDROGEN
	reactor.extra_gas_amount = rand(2500, 4000)
	reactor.event_reactivity_additive = 3

/datum/engi_event/reactor_event/sierra_tier/cascade
	name = "S-CASCADE"

/datum/engi_event/reactor_event/sierra_tier/cascade/start_sierra_event()
	..()
	reactor.event_reactivity_additive = 25 // BEEEEEEG POWER!
	reactor.event_heat_multiplier = 4
	reactor.event_power_additive = 10 MW
	reactor.event_gas_multiplier = 5

/datum/engi_event/reactor_event/sierra_tier/malfunction
	name = "S-MALFUNCTION"
	duration = 6 MINUTES

/datum/engi_event/reactor_event/sierra_tier/malfunction/start_sierra_event()
	..()
	reactor.event_reactivity_additive = 5
	reactor.event_meltdown_chance = 3 // The primary focus
	reactor.event_gas_multiplier = 5
	reactor.event_heat_multiplier = 10
