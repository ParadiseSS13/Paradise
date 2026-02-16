/obj/machinery/computer/satellite_monitor
	name = "Satellite Monitor"
	var/list/linked_satellites = new()
	var/collected_science_data = 0
	var/obj/item/disk/tech_disk/inserted_disk
	var/datum/tech/programming/data_collected
	var/current_planet_base64
	var/current_background_base64

/obj/machinery/computer/satellite_monitor/Initialize(mapload)
	. = ..()
	var/icon/temp_background = icon('icons/effects/parallax.dmi', "layer1")
	temp_background.Blend(new/icon('icons/effects/parallax.dmi', "layer2"), ICON_ADD)
	temp_background.Blend(new/icon('icons/effects/parallax.dmi', "layer3"), ICON_ADD)
	current_background_base64 = icon2base64(temp_background)

	var/theme = SSmapping.lavaland_theme?.planet_icon_state
	theme = (theme)? theme : "planet_lavaland"
	current_planet_base64 = icon2base64(new/icon('icons/effects/planets.dmi', theme, SOUTH, 1))

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
		satellite_data += list(list(
			"name" = satellite.internal_name,
			"weight" = satellite.satellite_stats.weight,
			"fuel_efficiency" = satellite.satellite_stats.fuel_efficiency,
			"fuel_capacity" = satellite.satellite_stats.fuel_capacity,
			"science_multiplier" = satellite.satellite_stats.science_multiplier,
			"power_generation" = satellite.satellite_stats.power_generation,
			"power_consumption" = satellite.satellite_stats.power_consumption,
			"power_capacity" = satellite.satellite_stats.power_capacity,
			"current_power" = satellite.current_power,
			"current_fuel" = satellite.current_fuel
		))

	data["satellite_data"] = satellite_data
	data["collected_science_data"] = collected_science_data
	data["inserted_disk"] = istype(inserted_disk)
	data["cmagged"] = HAS_TRAIT(src, TRAIT_CMAGGED)
	data["current_planet_base64"] = current_planet_base64
	data["current_background_base64"] = current_background_base64
	return data

/obj/machinery/computer/satellite_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SatelliteMonitor", name)
		ui.open()

/obj/machinery/computer/satellite_monitor/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(!istype(I, /obj/item/multitool))
		return

	var/obj/item/multitool/multitool = I
	if (!istype(multitool.buffer, /obj/machinery/science_satellite)) //not a satellite in buffer (for example a teleporter)
		atom_say("Error: unkown data.")
		return

	var/obj/machinery/science_satellite/satellite = multitool.buffer
	if(QDELETED(satellite))
		return

	if(satellite in linked_satellites) //already registered this satellite
		atom_say("Error: entry already stored in database.")
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
