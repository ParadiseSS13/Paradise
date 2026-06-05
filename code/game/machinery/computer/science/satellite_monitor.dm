/obj/machinery/computer/satellite_monitor
	name = "Satellite Monitor"
	icon_screen = "sat"
	var/list/linked_satellites = new()
	var/obj/item/disk/tech_disk/inserted_disk
	var/datum/tech/programming/data_collected
	var/current_planet_base64
	var/current_background_base64
	var/obj/machinery/science_satellite/selected_satellite_ui
	circuit = /obj/item/circuitboard/satellite_monitor

/obj/machinery/computer/satellite_monitor/Initialize(mapload)
	. = ..()
	var/icon/temp_background = icon('icons/effects/parallax.dmi', "layer1")
	temp_background.Blend(icon('icons/effects/parallax.dmi', "layer2"), ICON_ADD)
	temp_background.Blend(icon('icons/effects/parallax.dmi', "layer3"), ICON_ADD)
	current_background_base64 = icon2base64(temp_background)

	var/theme = SSmapping.lavaland_theme?.planet_icon_state
	theme = (theme)? theme : "planet_lava"
	current_planet_base64 = icon2base64(icon('icons/effects/planets.dmi', theme, SOUTH, 1))

/obj/machinery/computer/satellite_monitor/attack_ai(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN | NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/satellite_monitor/attack_hand(mob/living/user)
	add_fingerprint(user)
	if(stat & (BROKEN | NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/satellite_monitor/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/satellite_monitor/ui_data(mob/user)
	var/list/data = list()
	var/list/satellite_data = list()
	for(var/obj/machinery/science_satellite/satellite in linked_satellites)
		var/datum/orbit_data/orbit_data = satellite.orbit_data
		var/list/planned_maneuvers = list()
		for(var/datum/maneuver_data/maneuver in orbit_data.planned_maneuvers)
			planned_maneuvers += list(list( // funny byond required a listed list to be sent to TGUI
				"prograde" = maneuver.prograde,
				"normal" = maneuver.normal,
				"burn_time" = maneuver.burn_time,
				"time_to_maneuver" = maneuver.world_time_at_maneuver - world.time
			))

		var/list/planned_orbit = list()
		//log_debug("planned_orbit length: [length(orbit_data.planned_orbit)] index0: [(!length(orbit_data.planned_orbit)? "null/0": "([orbit_data.planned_orbit[0]["X"]], [orbit_data.planned_orbit[0]["Y"]], [orbit_data.planned_orbit[0]["Z"]])" )]")
		for(var/list/point in orbit_data.planned_orbit)
			planned_orbit += list(list( // funny byond required a listed list to be sent to TGUI
				"X" = point["X"],
				"Y" = point["Y"],
				"Z" = point["Z"]
			))

		if(planned_maneuvers.len) // in case no maneuver has been set this still needs to become an array
			planned_maneuvers += list()

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
			"active_power_generation" = satellite.satellite_stats.active_power_generation,
			"power_consumption" = satellite.satellite_stats.power_consumption,
			"power_capacity" = satellite.satellite_stats.power_capacity,
			"current_power" = satellite.satellite_stats.current_power,
			"current_fuel" = satellite.satellite_stats.current_fuel,
			"fuel_usage" = satellite.satellite_stats.fuel_usage,
			"orbit_data" = list(
				"apoapsis" = orbit_data.apoapsis,
				"periapsis" = orbit_data.periapsis,
				"inclination" = orbit_data.inclination,
				"period_multiplier" = orbit_data.period_multiplier,
				"period" = orbit_data.period,
				"launch_time" = orbit_data.launch_time,
				//"velocity" = orbit_data.velocity,
				//"orbit_progress" = orbit_data.orbit_progress,
				"planned_maneuvers" = planned_maneuvers,
				"planned_orbit" = planned_orbit,
				"posX" = orbit_data.posX,
				"posY" = orbit_data.posY,
				"posZ" = orbit_data.posZ,
				"velX" = orbit_data.velX,
				"velY" = orbit_data.velY,
				"velZ" = orbit_data.velZ
			)
		))

	data["satellite_data"] = satellite_data
	data["inserted_disk"] = istype(inserted_disk)
	data["cmagged"] = HAS_TRAIT(src, TRAIT_CMAGGED)
	data["world_time"] = world.time
	data["current_planet_base64"] = current_planet_base64
	data["current_background_base64"] = current_background_base64
	data["selected_satellite_UID_ui"] = selected_satellite_ui?.UID()
	return data

/obj/machinery/computer/satellite_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SatelliteMonitor", name)
		ui.open()

/obj/machinery/computer/satellite_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = TRUE

	atom_say("ui_act uid: [params["uid"]]")

	var/obj/machinery/science_satellite/satellite = get_satellite_from_UID(params["uid"])
	if(action == "select_satellite") // satellite can be null here in order to unset the selected satellite
		atom_say("select_satellite")
		selected_satellite_ui = satellite
		return

	if(!satellite)
		return

	switch(action)
		if("launch")
			atom_say("launch")

			// TODO: Launch code
			satellite.status = "in orbit"
		if("add_maneuver")
			var/prograde = text2num(params["prograde"])
			var/normal = text2num(params["normal"])
			var/burn_time = text2num(params["burnTime"])
			var/time_to_maneuver = text2num(params["timeToManeuver"])
			atom_say("add_maneuver. prograde: [prograde] normal: [normal] burn_time: [burn_time] time_to_maneuver: [time_to_maneuver]")
			satellite.orbit_data.add_maneuver(prograde, normal, time_to_maneuver MINUTES, burn_time SECONDS)
			satellite.status = "waiting for maneuver"
		if("delete_all_maneuvers")
			atom_say("delete_all_maneuvers")

			satellite.orbit_data.planned_maneuvers = new()
		if("load_data_onto_disk")
			atom_say("load_data_onto_disk")

			// TODO: Load Data
			return FALSE
		if("eject_disk")
			// TODO: Ejeckt Disk
			return FALSE

/obj/machinery/computer/satellite_monitor/proc/get_satellite_from_UID(uid)
	for(var/obj/machinery/science_satellite/satellite in linked_satellites)
		if(satellite.UID() == uid)
			return satellite

/obj/machinery/computer/satellite_monitor/multitool_act(mob/living/user, obj/item/I)
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

/obj/machinery/computer/satellite_monitor/cmag_act(mob/user)
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		return FALSE
	ADD_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)
	to_chat(user, SPAN_NOTICE("You slather [src]'s keyboard with bananium!"))
	return TRUE

/obj/machinery/computer/satellite_monitor/examine(mob/user)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_CMAGGED))
		return

	. += SPAN_WARNING("Bananium ooze is dripping from the keyboard!")

/obj/machinery/computer/satellite_monitor/Destroy()
	for(var/obj/machinery/science_satellite/satellite in linked_satellites)
		satellite.linked_consoles -= src
	. = ..()
