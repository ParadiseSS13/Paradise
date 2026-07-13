/obj/machinery/computer/science_collector/satellite_monitor
	name = "Satellite Monitor"
	icon_screen = "sat"
	science_type = /datum/tech/programming
	circuit = /obj/item/circuitboard/satellite_monitor
	var/list/linked_satellites = new()
	var/datum/tech/programming/data_collected
	var/current_planet_theme
	var/current_background_base64
	var/obj/machinery/science_satellite/selected_satellite_ui

/obj/machinery/computer/science_collector/satellite_monitor/Initialize(mapload)
	. = ..()
	var/icon/temp_background = icon('icons/effects/parallax.dmi', "layer1")
	temp_background.Blend(icon('icons/effects/parallax.dmi', "layer2"), ICON_ADD)
	temp_background.Blend(icon('icons/effects/parallax.dmi', "layer3"), ICON_ADD)
	current_background_base64 = icon2base64(temp_background)

	var/theme = SSmapping.lavaland_theme?.planet_icon_state
	theme = (theme)? theme : "planet_lava"
	current_planet_theme = "[theme].png" //icon2base64(icon('icons/effects/planets.dmi', theme, SOUTH, 1))

/obj/machinery/computer/science_collector/satellite_monitor/attack_ai(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN | NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/science_collector/satellite_monitor/attack_hand(mob/living/user)
	add_fingerprint(user)
	if(stat & (BROKEN | NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/science_collector/satellite_monitor/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/science_collector/satellite_monitor/ui_data(mob/user)
	var/list/data = list()
	var/list/satellite_data = list()
	for(var/obj/machinery/science_satellite/satellite in linked_satellites)
		var/datum/orbit_data/orbit_data = satellite.orbit_data
		var/list/planned_maneuvers = list()
		for(var/datum/maneuver_data/maneuver in orbit_data.planned_maneuvers)
			planned_maneuvers += list(list( // funny byond required a listed list to be sent to TGUI, because they will merge the associative lists and overwrite their values
				"prograde" = maneuver.prograde,
				"normal" = maneuver.normal,
				"burn_time" = maneuver.burn_time,
				"time_to_maneuver" = maneuver.world_time_at_maneuver - world.time
			))

		if(planned_maneuvers.len) // in case no maneuver has been set this still needs to become an array
			planned_maneuvers += list()

		var/list/predicted_orbit = list()
		for(var/vector/point in orbit_data.predicted_orbit)
			predicted_orbit += list(list(
				"x" = point.x,
				"y" = point.y,
				"z" = point.z
			))

		if(predicted_orbit.len)
			predicted_orbit += list()

		var/list/pos_vec = list()
		if(orbit_data.position)
			pos_vec["x"] = orbit_data.position.x
			pos_vec["y"] = orbit_data.position.y
			pos_vec["z"] = orbit_data.position.z

		var/list/vel_vec = list()
		if(orbit_data.velocity)
			vel_vec["x"] = orbit_data.velocity.x
			vel_vec["y"] = orbit_data.velocity.y
			vel_vec["z"] = orbit_data.velocity.z

		var/generators_available = 0
		for(var/capabilitiy in satellite.satellite_stats.capabilities)
			if(capabilitiy == SCIENCE_SATELLITE_HAS_GENERATOR)
				generators_available++

		var/list/apoap_vec = list()
		if(orbit_data.apoapsis_position)
			apoap_vec["x"] = orbit_data.apoapsis_position.x
			apoap_vec["y"] = orbit_data.apoapsis_position.y
			apoap_vec["z"] = orbit_data.apoapsis_position.z

		var/list/periap_vec = list()
		if(orbit_data.periapsis_position)
			periap_vec["x"] = orbit_data.periapsis_position.x
			periap_vec["y"] = orbit_data.periapsis_position.y
			periap_vec["z"] = orbit_data.periapsis_position.z

		satellite_data += list(list( // funny byond required a listed list to be sent to TGUI
			"UID" = satellite.UID(),
			"name" = satellite.internal_name,
			"collected_science_data" = satellite.collected_science_data,
			"status" = satellite.status,
			"weight" = satellite.satellite_stats.weight,
			"fuel_efficiency" = satellite.satellite_stats.fuel_efficiency,
			"fuel_capacity" = satellite.satellite_stats.fuel_capacity,
			"science_multiplier" = satellite.satellite_stats.science_multiplier,
			"passive_power_generation" = satellite.satellite_stats.passive_power_generation,
			"active_power_generation" = satellite.satellite_stats.active_power_generation * satellite.is_performing_maneuver() + satellite.generators_in_use * SCIENCE_SATELLITE_WATTS_PER_GENERATOR,
			"power_consumption" = satellite.satellite_stats.power_consumption,
			"power_capacity" = satellite.satellite_stats.power_capacity,
			"current_power" = satellite.satellite_stats.current_power,
			"current_fuel" = satellite.satellite_stats.current_fuel,
			"fuel_usage" = satellite.satellite_stats.fuel_usage,
			"generators_available" = generators_available,
			"generators_in_use" = satellite.generators_in_use,
			"fuel_per_generator" = SCIENCE_SATELLITE_MILLILITER_USE_PER_GENERATOR,
			"has_been_launched" = satellite.orbit_data.has_been_launched,
			"orbit_data" = list(
				"apoapsis" = orbit_data.apoapsis,
				"periapsis" = orbit_data.periapsis,
				"apoapsis_position" = apoap_vec,
				"periapsis_position" = periap_vec,
				"inclination" = orbit_data.inclination,
				"period" = orbit_data.period,
				"launch_time" = orbit_data.launch_time,
				//"velocity" = orbit_data.velocity,
				//"orbit_progress" = orbit_data.orbit_progress,
				"planned_maneuvers" = planned_maneuvers,
				"planned_orbit" = predicted_orbit,
				"position" = pos_vec, //orbit_data.position,
				"velocity" = vel_vec//orbit_data.velocity
			)
		))


	var/list/weather_nodes = list()
	for(var/datum/weather_node/node in SSscience_satellite.active_weather_nodes)
		var/list/this_node = list()

		var/list/pos_vec = list()
		if(node.position)
			pos_vec += list(
				"x" = node.position.x,
				"y" = node.position.y,
				"z" = node.position.z,
			)
			//pos_vec["x"] = node.position.x
			//pos_vec["y"] = node.position.y
			//pos_vec["z"] = node.position.z
		else
			log_debug("[node.node_type] node.position was null! [node.position]")

		this_node += list(
			"position" = pos_vec,
			"node_type" = node.node_type,
			"asset_icon" = node.asset_icon
		)

		weather_nodes += list(this_node)

	data["satellite_data"] = satellite_data
	data["inserted_disk"] = istype(inserted_disk)
	data["cmagged"] = HAS_TRAIT(src, TRAIT_CMAGGED)
	data["world_time"] = world.time
	data["current_planet_theme"] = current_planet_theme
	data["current_background_base64"] = current_background_base64
	data["selected_satellite_UID_ui"] = selected_satellite_ui?.UID()
	data["weather_nodes"] = weather_nodes
	data["planet_radius"] = SSscience_satellite.planet_radius

	return data

/obj/machinery/computer/science_collector/satellite_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SatelliteMonitor", name)
		ui.open()

/obj/machinery/computer/science_collector/satellite_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = TRUE

	atom_say("ui_act uid: [params["uid"]]") //TODO: Remove debug

	var/obj/machinery/science_satellite/satellite = get_satellite_from_UID(params["uid"])
	if(action == "select_satellite") // satellite can be null here in order to unset the selected satellite
		atom_say("select_satellite") //TODO: Remove debug
		selected_satellite_ui = satellite
		return

	//if(!satellite)
	//	return

	switch(action)
		if("launch")
			atom_say("launching satellite")
			satellite.orbit_data.launch()
		if("add_maneuver")
			if(!satellite.orbit_data.has_been_launched)
				atom_say("[satellite.internal_name] needs to be launched first!")
				return FALSE
			var/prograde = text2num(params["prograde"])
			var/normal = text2num(params["normal"])
			var/burn_time = text2num(params["burnTime"])
			var/time_to_maneuver = text2num(params["timeToManeuver"])
			atom_say("add_maneuver. prograde: [prograde] normal: [normal] burn_time: [burn_time] time_to_maneuver: [time_to_maneuver]")
			satellite.orbit_data.add_maneuver(prograde, normal, time_to_maneuver MINUTES, burn_time SECONDS)
		if("delete_all_maneuvers")
			atom_say("delete_all_maneuvers")

			satellite.orbit_data.planned_maneuvers = new()
		if("load_data_onto_disk")
			atom_say("load_data_onto_disk")
			var/data_points = 0
			for(var/obj/machinery/science_satellite/linked_satellite in linked_satellites)
				data_points += linked_satellite.collected_science_data

			load_data_onto_disk(/datum/tech/programming/, data_points)
			// TODO: Load Data
			return FALSE
		if("set_generators_in_use")
			log_debug("param: generators_in_use: [text2num(params["generators_in_use"])]")
			satellite.generators_in_use = text2num(params["generators_in_use"]) // precision down to 0.1
		if("eject_disk")
			eject_disk(ui.user)
			// TODO: Ejeckt Disk
			return FALSE

/obj/machinery/computer/science_collector/satellite_monitor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/science_satellite),
	)

/obj/machinery/computer/science_collector/satellite_monitor/proc/get_satellite_from_UID(uid)
	for(var/obj/machinery/science_satellite/satellite in linked_satellites)
		if(satellite.UID() == uid)
			return satellite

/obj/machinery/computer/science_collector/satellite_monitor/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(!istype(I, /obj/item/multitool))
		return

	var/obj/item/multitool/multitool = I
	if (!istype(multitool.buffer, /obj/machinery/science_satellite)) //not a satellite in buffer (for example a teleporter)
		atom_say("Error: Unknown data.")
		return

	var/obj/machinery/science_satellite/satellite = multitool.buffer
	if(QDELETED(satellite))
		return

	if(satellite in linked_satellites) //already registered this satellite
		atom_say("Error: Entry already stored in database.")
		return

	linked_satellites += satellite
	to_chat(user, SPAN_NOTICE("You save \the [multitool]'s data into the [src]'s database. "))
	atom_say("Successfully stored information into the database.")
	satellite.linked_consoles += src
	return ITEM_INTERACT_COMPLETE

/obj/machinery/computer/science_collector/satellite_monitor/cmag_act(mob/user)
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		return FALSE
	ADD_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)
	to_chat(user, SPAN_NOTICE("You slather [src]'s keyboard with bananium!"))
	return TRUE

/obj/machinery/computer/science_collector/satellite_monitor/examine(mob/user)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_CMAGGED))
		return

	. += SPAN_WARNING("Bananium ooze is dripping from the keyboard!")

/obj/machinery/computer/science_collector/satellite_monitor/Destroy()
	for(var/obj/machinery/science_satellite/satellite in linked_satellites)
		satellite.linked_consoles -= src
	. = ..()
