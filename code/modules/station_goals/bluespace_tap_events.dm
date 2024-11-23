/datum/bluespace_tap_event
	var/name = "Unknown Anomaly (Report this to coders)"
	var/obj/machinery/power/bluespace_tap/tap
	/// Probability of the event not running, higher tiers being rarer
	var/threat_level
	var/duration
	var/turf/tap_turf

/datum/bluespace_tap_event/New(obj/machinery/power/bluespace_tap/_tap)
	. = ..()
	tap = _tap
	tap_turf = get_turf(tap)
	if(!tap)
		stack_trace("a /datum/bluespace_tap_event was called without an involved bluespace tap.")
		return
	if(!istype(tap))
		stack_trace("a /datum/bluespace_tap_event was called with (name: [tap], type: [tap.type]) instead of a bluespace tap!")
		return

/datum/bluespace_tap_event/proc/start_event()
	on_start()
	alert_engi()
	tap.investigate_log("event [src] has been triggered", "bluespace_tap")

/datum/bluespace_tap_event/proc/on_start()
	return

/datum/bluespace_tap_event/proc/alert_engi()
	return

// gas events
/datum/bluespace_tap_event/gas
	name = "Gas Event"

/datum/bluespace_tap_event/gas/alert_engi()
	tap.radio.autosay("Bluespace harvester has released a class [src] gas pocket!", tap, "Engineering")

// sleeping gas
/datum/bluespace_tap_event/gas/sleeping_gas
	name = "G-1"

/datum/bluespace_tap_event/gas/sleeping_gas/on_start()
	var/datum/gas_mixture/air = new()
	air.set_sleeping_agent(200)
	air.set_temperature(T20C)
	tap_turf.blind_release_air(air)

// nitrogen
/datum/bluespace_tap_event/gas/nitrogen
	name = "G-2"

/datum/bluespace_tap_event/gas/nitrogen/on_start()
	var/datum/gas_mixture/air = new()
	air.set_nitrogen(250)
	air.set_temperature(T20C)
	tap_turf.blind_release_air(air)

// carbon dioxide
/datum/bluespace_tap_event/gas/carbon_dioxide
	name = "G-3"

/datum/bluespace_tap_event/gas/carbon_dioxide/on_start()
	var/datum/gas_mixture/air = new()
	air.set_carbon_dioxide(250)
	air.set_temperature(T20C)
	tap_turf.blind_release_air(air)

// plasma
/datum/bluespace_tap_event/gas/plasma
	name = "G-4"

/datum/bluespace_tap_event/gas/plasma/on_start()
	var/datum/gas_mixture/air = new()
	air.set_toxins(250)
	air.set_temperature(T20C)
	tap_turf.blind_release_air(air)


// oxygen
/datum/bluespace_tap_event/gas/oxygen
	name = "G-5"

/datum/bluespace_tap_event/gas/oxygen/on_start()
	var/datum/gas_mixture/air = new()
	air.set_oxygen(250)
	air.set_temperature(T20C)
	tap_turf.blind_release_air(air)

// agent_b
/datum/bluespace_tap_event/gas/agent_b
	name = "G-6"

/datum/bluespace_tap_event/gas/agent_b/on_start()
	var/datum/gas_mixture/air = new()
	air.set_agent_b(250)
	air.set_temperature(T20C)
	tap_turf.blind_release_air(air)

// dirty
/datum/bluespace_tap_event/dirty
	name = "F-1"

/datum/bluespace_tap_event/dirty/alert_engi()
	tap.radio.autosay("Bluespace harvester has struck a congealed mass of filth!", tap, "Engineering")

/datum/bluespace_tap_event/dirty/on_start()
	tap.dirty = TRUE
	var/list/gunk = list("carbon","flour","blood")
	var/datum/reagents/R = new/datum/reagents(50)
	R.my_atom = tap
	R.add_reagent(pick(gunk), 50)

	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(R, tap, TRUE)
	playsound(tap.loc, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	smoke.start(3)
	qdel(R)

// radiation pulse
/datum/bluespace_tap_event/radiation
	name = "R-1"

/datum/bluespace_tap_event/radiation/alert_engi()
	tap.radio.autosay("Bluespace harvester has released a spike of radiation!", tap, "Engineering")

/datum/bluespace_tap_event/radiation/on_start()
	radiation_pulse(tap, 3000, 7)

// electrical arc
/datum/bluespace_tap_event/electric_arc
	name = "E-1"

/datum/bluespace_tap_event/electric_arc/alert_engi()
	tap.radio.autosay("Class [src] power spike detected in bluespace harvester operation!", tap, "Engineering")

/datum/bluespace_tap_event/electric_arc/on_start()
	var/list/shock_mobs = list()
	for(var/C in view(tap_turf, 5)) // We only want to shock a single random mob in range, not every one.
		if(isliving(C))
			shock_mobs += C
	if(length(shock_mobs))
		var/mob/living/L = pick(shock_mobs)
		L.electrocute_act(rand(5, 25), "electrical arc")
		playsound(get_turf(L), 'sound/effects/eleczap.ogg', 75, TRUE)
		tap.Beam(L, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 5)

// mass electrical arc
/datum/bluespace_tap_event/electric_arc/mass
	name = "E-2"

/datum/bluespace_tap_event/electric_arc/mass/on_start()
	for(var/C in view(tap_turf, 5)) // Zap everyone
		if(isliving(C))
			var/mob/living/L = C
			L.electrocute_act(rand(5, 25), "electrical arc")
			playsound(get_turf(L), 'sound/effects/eleczap.ogg', 75, TRUE)
			tap.Beam(L, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 5)
