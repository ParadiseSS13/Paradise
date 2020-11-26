/obj/machinery/doppler_array/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/doppler_array(null)
	component_parts += new /obj/item/stock_parts/manipulator/nano(null)
	component_parts += new /obj/item/stock_parts/scanning_module/adv(null)
	component_parts += new /obj/item/stock_parts/scanning_module/adv(null)
	RefreshParts()

/obj/machinery/doppler_array/range
	name = "long range tachyon-doppler array"
	desc = "A highly precise sensor array which measures the release of quants from decaying tachyons. The doppler shifting of the mirror-image formed by these quants can reveal the size, location and temporal affects of energetic disturbances within a large radius ahead of the array."
	icon = 'icons/hispania/obj/machines/research.dmi'

/obj/machinery/doppler_array/range/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/doppler_array/range(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	RefreshParts()

/obj/machinery/doppler_array/range/attackby(obj/item/I, mob/user, params)
		return

/obj/machinery/doppler_array/range/AltClick(mob/user)
	return

/obj/machinery/doppler_array/range/rotate(mob/user)
	return

/obj/machinery/doppler_array/range/sense_explosion(var/x0,var/y0,var/z0,var/devastation_range,var/heavy_impact_range,var/light_impact_range,
												  var/took,var/orig_dev_range,var/orig_heavy_range,var/orig_light_range)
	if(stat & NOPOWER)
		return

	var/capped = FALSE

	var/list/messages = list("Explosive disturbance detected.", \
							 "Epicenter at: grid ([x0],[y0],[z0]). Temporal displacement of tachyons: [took] seconds.", \
							 "Actual: Epicenter radius: [devastation_range]. Outer radius: [heavy_impact_range]. Shockwave radius: [light_impact_range].")

	// If the bomb was capped, say its theoretical size.
	if(devastation_range < orig_dev_range || heavy_impact_range < orig_heavy_range || light_impact_range < orig_light_range)
		capped = TRUE
		messages += "Theoretical: Epicenter radius: [orig_dev_range]. Outer radius: [orig_heavy_range]. Shockwave radius: [orig_light_range]."
	logged_explosions.Insert(1, new /datum/explosion_log(station_time_timestamp(), "[x0],[y0],[z0]", "[devastation_range], [heavy_impact_range], [light_impact_range]", capped ? "[orig_dev_range], [orig_heavy_range], [orig_light_range]" : "n/a")) //Newer logs appear first
	messages += "Event successfully logged in internal database."
	for(var/message in messages)
		atom_say(message)

/obj/machinery/doppler_array/range/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "doppler_array_longrange.tmpl", "Long range Tachyon-doppler array", 500, 650)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/doppler_array/range/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]
	var/list/explosion_data = list()
	for(var/D in logged_explosions)
		var/datum/explosion_log/E = D
		explosion_data += list(list(
			"logged_time" = E.logged_time,
			"epicenter" = E.epicenter,
			"actual_size_message" = E.actual_size_message,
			"theoretical_size_message" = E.theoretical_size_message,
			"unique_datum_id" = E.UID()))
	data["explosion_data"] = explosion_data
	data["printing"] = active_timers
	return data
