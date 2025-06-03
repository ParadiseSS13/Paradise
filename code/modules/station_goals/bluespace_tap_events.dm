/datum/engi_event/bluespace_tap_event
	name = "Unknown Anomaly (Report this to coders)"
	/// Which bluespace tap started the event
	var/obj/machinery/power/bluespace_tap/tap

/datum/engi_event/bluespace_tap_event/New(obj/machinery/power/bluespace_tap/_tap)
	. = ..()
	tap = _tap
	if(!tap)
		stack_trace("a /datum/bluespace_tap_event was called without an involved bluespace tap.")
		return
	if(!istype(tap))
		stack_trace("a /datum/bluespace_tap_event was called with (name: [tap], type: [tap.type]) instead of a bluespace tap!")
		return

/datum/engi_event/bluespace_tap_event/start_event()
	tap.investigate_log("event [src] has been triggered", "bluespace_tap")
	return ..()

/datum/engi_event/bluespace_tap_event/Destroy(force, ...)
	tap = null
	return ..()

// gas events
/datum/engi_event/bluespace_tap_event/gas
	name = "Gas Event"

/datum/engi_event/bluespace_tap_event/gas/alert_engi()
	tap.radio.autosay("Bluespace harvester has released a class [src] gas pocket!", tap, "Engineering")

/datum/engi_event/bluespace_tap_event/gas/on_start()
	var/datum/gas_mixture/air = new()
	var/picked_gas = pick("N2O", "N2", "O2", "CO2", "Plasma", "Unknown")
	switch(picked_gas)
		if("N2")
			name = "G-1"
			air.set_nitrogen(250)
		if("O2")
			name = "G-2"
			air.set_oxygen(250)
		if("N2O")
			name = "G-3"
			air.set_sleeping_agent(200)
		if("CO2")
			name = "G-4"
			air.set_carbon_dioxide(250)
		if("Plasma")
			name = "G-5"
			air.set_toxins(250)
		if("Unknown")
			name = "G-6"
			air.set_agent_b(250)

	air.set_temperature(T20C)
	var/turf/tap_turf = get_turf(tap)
	tap_turf.blind_release_air(air)

// dirty
/datum/engi_event/bluespace_tap_event/dirty
	name = "F-1"

/datum/engi_event/bluespace_tap_event/dirty/alert_engi()
	tap.radio.autosay("Bluespace harvester has struck a congealed mass of filth!", tap, "Engineering")

/datum/engi_event/bluespace_tap_event/dirty/on_start()
	tap.dirty = TRUE
	var/list/gunk = list("carbon", "flour", "blood")
	var/datum/reagents/R = new /datum/reagents(50)
	R.my_atom = tap
	R.add_reagent(pick(gunk), 50)
	tap.update_icon()

	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(R, tap, TRUE)
	playsound(tap.loc, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	smoke.start(3)
	qdel(R)

// radiation pulse
/datum/engi_event/bluespace_tap_event/radiation
	name = "R-1"

/datum/engi_event/bluespace_tap_event/radiation/alert_engi()
	tap.radio.autosay("Bluespace harvester has released a spike of radiation!", tap, "Engineering")

/datum/engi_event/bluespace_tap_event/radiation/on_start()
	radiation_pulse(tap, 12000, BETA_RAD)

// electrical arc
/datum/engi_event/bluespace_tap_event/electric_arc
	name = "E-1"

/datum/engi_event/bluespace_tap_event/electric_arc/alert_engi()
	tap.radio.autosay("Class [src] power spike detected in bluespace harvester operation!", tap, "Engineering")

/datum/engi_event/bluespace_tap_event/electric_arc/on_start()
	var/shock_type = pick("single", "mass")
	switch(shock_type)
		if("single")
			var/list/shock_mobs = list()
			for(var/C in view(get_turf(tap), 5)) // We only want to shock a single random mob in range, not every one.
				if(isliving(C))
					shock_mobs += C
			if(length(shock_mobs))
				var/mob/living/L = pick(shock_mobs)
				L.electrocute_act(rand(5, 25), "electrical arc")
				playsound(get_turf(L), 'sound/effects/eleczap.ogg', 75, TRUE)
				tap.Beam(L, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 5)
		if("mass")
			name = "E-2"
			for(var/C in view(get_turf(tap), 5)) // Zap everyone
				if(isliving(C))
					var/mob/living/L = C
					L.electrocute_act(rand(5, 25), "electrical arc")
					playsound(get_turf(L), 'sound/effects/eleczap.ogg', 75, TRUE)
					tap.Beam(L, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 5)


