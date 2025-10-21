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
	pressure = tgui_input_number(user, "Atmospheric Pressure", "Input", ONE_ATMOSPHERE, 100000, 0, round_value = FALSE)
	temperature = tgui_input_number(user, "Temperature", "Input", T20C, 100000, 0, round_value = FALSE)
	oxygen = tgui_input_number(user, "Oxygen ratio", "Input", O2STANDARD, 100000, 0, round_value = FALSE )
	nitrogen = tgui_input_number(user, "Nitrogen ratio", "Input", N2STANDARD, 100000, 0, round_value = FALSE)
	plasma = tgui_input_number(user, "Plasma ratio", "Input", 0, 100000, 0, round_value = FALSE)
	cdiox = tgui_input_number(user, "CO2 ratio", "Input", 0, 100000, 0, round_value = FALSE)
	nitrox = tgui_input_number(user, "N2O ratio", "Input", 0, 100000, 0, round_value = FALSE)
	agentbx = tgui_input_number(user, "Agent B ratio", "Input", 0, 100000, 0, round_value = FALSE)

/datum/buildmode_mode/atmos/proc/ppratio_to_moles(ppratio)
	// ideal gas equation: Pressure * Volume = Moles * r * Temperature
	// air datum fields are in moles, we have partial pressure ratios
	// Moles = (Pressure * Volume) / (r * Temperature)
	return ((ppratio * pressure) * CELL_VOLUME) / (temperature * R_IDEAL_GAS_EQUATION)

/datum/buildmode_mode/atmos/handle_selected_region(mob/user, params)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/ctrl_click = pa.Find("ctrl")
	if(left_click) //rectangular
		var/datum/gas_mixture/air = new()
		air.set_temperature(temperature)
		air.set_oxygen(ppratio_to_moles(oxygen))
		air.set_nitrogen(ppratio_to_moles(nitrogen))
		air.set_toxins(ppratio_to_moles(plasma))
		air.set_carbon_dioxide(ppratio_to_moles(cdiox))
		air.set_sleeping_agent(ppratio_to_moles(nitrox))
		air.set_agent_b(ppratio_to_moles(agentbx))

		for(var/turf/T in block(cornerA,cornerB))
			if(issimulatedturf(T))
				// fill the turf with the appropriate gasses
				var/turf/simulated/S = T
				if(!S.blocks_air)
					T.blind_set_air(air)
			else if(ctrl_click) // overwrite "default" space air
				T.temperature = temperature
				T.oxygen = air.oxygen()
				T.nitrogen = air.nitrogen()
				T.toxins = air.toxins()
				T.carbon_dioxide = air.carbon_dioxide()
				T.sleeping_agent = air.sleeping_agent()
				T.agent_b = air.agent_b()

		// admin log
		log_admin("Build Mode: [key_name(user)] changed the atmos of region [COORD(cornerA)] to [COORD(cornerB)]. T: [temperature], P: [pressure], Ox: [oxygen]%, N2: [nitrogen]%, Plsma: [plasma]%, CO2: [cdiox]%, N2O: [nitrox]%. [ctrl_click ? "Overwrote base space turf gases." : ""]")
