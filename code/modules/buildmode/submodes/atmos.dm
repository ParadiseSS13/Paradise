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


/datum/buildmode_mode/atmos/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button on turf      = Select corner</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button + Ctrl on turf = Set 'base atmos conditions' for unsimulated turfs in region</span>")
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
		for(var/turf/T in block(cornerA,cornerB))
			if(istype(T, /turf/simulated))
				// fill the turf with the appropriate gasses
				// this feels slightly icky
				var/turf/simulated/S = T
				if(S.air)
					S.air.temperature = temperature
					S.air.oxygen = ppratio_to_moles(oxygen)
					S.air.nitrogen = ppratio_to_moles(nitrogen)
					S.air.toxins = ppratio_to_moles(plasma)
					S.air.carbon_dioxide = ppratio_to_moles(cdiox)
					S.air.trace_gases.Cut()
					if(nitrox)
						var/datum/gas/TG = new /datum/gas/sleeping_agent
						TG.moles = ppratio_to_moles(nitrox)
						S.air.trace_gases += TG
					S.update_visuals()
					S.air_update_turf()
			else if(ctrl_click) // overwrite "default" unsimulated air
				T.temperature = temperature
				T.oxygen = ppratio_to_moles(oxygen)
				T.nitrogen = ppratio_to_moles(nitrogen)
				T.toxins = ppratio_to_moles(plasma)
				T.carbon_dioxide = ppratio_to_moles(cdiox)
				// no interface for trace gases on unsim turfs
				T.air_update_turf()

		// admin log
		log_admin("Build Mode: [key_name(user)] changed the atmos of region [COORD(cornerA)] to [COORD(cornerB)]. T: [temperature], P: [pressure], Ox: [oxygen]%, N2: [nitrogen]%, Plsma: [plasma]%, CO2: [cdiox]%, N2O: [nitrox]%. [ctrl_click ? "Overwrote base unsimulated turf gases." : ""]")