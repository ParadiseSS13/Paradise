/datum/buildmode_mode/atmos
	key = "atmos"

	use_corner_selection = TRUE
	var/pressure = ONE_ATMOSPHERE
	var/temperature = T20C
	var/oxygen = O2STANDARD
	var/nitrogen = N2STANDARD
	var/plasma = 0
	var/cdiox = 0
	var/nitrox = 0
	var/agentbx = 0


/datum/buildmode_mode/atmos/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button on turf      = Select corner</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button + Ctrl on turf = Set 'base atmos conditions' for space turfs in region</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on buildmode button = Adjust target atmos</span>")
	to_chat(user, "<span class='notice'><b>Notice:</b> Starts out with standard breathable/liveable defaults</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

// FIXME this is a little tedious, something where you don't have to fill in each field would be cooler
// maybe some kind of stat panel thing?
/datum/buildmode_mode/atmos/change_settings(mob/user)
	pressure = input(user, "Atmospheric Pressure", "Input", ONE_ATMOSPHERE) as num|null
	temperature = input(user, "Temperature", "Input", T20C) as num|null
	oxygen = input(user, "Oxygen ratio", "Input", O2STANDARD) as num|null
	nitrogen = input(user, "Nitrogen ratio", "Input", N2STANDARD) as num|null
	plasma = input(user, "Plasma ratio", "Input", 0) as num|null
	cdiox = input(user, "CO2 ratio", "Input", 0) as num|null
	nitrox = input(user, "N2O ratio", "Input", 0) as num|null
	agentbx = input(user, "Agent B ratio", "Input", 0) as num|null

/datum/buildmode_mode/atmos/proc/ppratio_to_moles(ppratio)
	// ideal gas equation: Pressure * Volume = Moles * r * Temperature
	// air datum fields are in moles, we have partial pressure ratios
	// Moles = (Pressure * Volume) / (r * Temperature)
	return ((ppratio * pressure) * CELL_VOLUME) / (temperature * R_IDEAL_GAS_EQUATION)

/datum/buildmode_mode/atmos/handle_selected_region(mob/user, params)
	// Any proc that wants MILLA to be synchronous should not sleep.
	SHOULD_NOT_SLEEP(TRUE)
	SSair.synchronize(CALLBACK(src, TYPE_PROC_REF(/datum/buildmode_mode/atmos, handle_selected_region_sync), user, params))

/datum/buildmode_mode/atmos/proc/handle_selected_region_sync(mob/user, params)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/ctrl_click = pa.Find("ctrl")
	if(left_click) //rectangular
		for(var/turf/T in block(cornerA,cornerB))
			if(issimulatedturf(T))
				// fill the turf with the appropriate gasses
				// this feels slightly icky
				var/turf/simulated/S = T
				if(!S.blocks_air)
					var/datum/gas_mixture/air = S.get_air()
					air.set_temperature(temperature)
					air.set_oxygen(ppratio_to_moles(oxygen))
					air.set_nitrogen(ppratio_to_moles(nitrogen))
					air.set_toxins(ppratio_to_moles(plasma))
					air.set_carbon_dioxide(ppratio_to_moles(cdiox))
					air.set_sleeping_agent(ppratio_to_moles(nitrox))
					air.set_agent_b(ppratio_to_moles(agentbx))
					S.update_visuals()
			else if(ctrl_click) // overwrite "default" space air
				T.temperature = temperature
				T.oxygen = ppratio_to_moles(oxygen)
				T.nitrogen = ppratio_to_moles(nitrogen)
				T.toxins = ppratio_to_moles(plasma)
				T.carbon_dioxide = ppratio_to_moles(cdiox)
				T.sleeping_agent = ppratio_to_moles(nitrox)
				T.agent_b = ppratio_to_moles(agentbx)

		// admin log
		log_admin("Build Mode: [key_name(user)] changed the atmos of region [COORD(cornerA)] to [COORD(cornerB)]. T: [temperature], P: [pressure], Ox: [oxygen]%, N2: [nitrogen]%, Plsma: [plasma]%, CO2: [cdiox]%, N2O: [nitrox]%. [ctrl_click ? "Overwrote base space turf gases." : ""]")
