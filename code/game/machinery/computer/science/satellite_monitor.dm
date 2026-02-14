/obj/machinery/computer/satellite_monitor
	name = "Satellite Monitor"
	var/list/linked_satellites
	var/collected_science_data = 0
	var/obj/item/disk/tech_disk/inserted_disk
	var/datum/tech/programming/data_collected


/obj/machinery/computer/satellite_monitor/Initialize(mapload)
	. = ..()
	linked_satellites = list()

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
	data["linked_satellites"] = linked_satellites
	data["collected_science_data"] = collected_science_data
	data["inserted_disk"] = istype(inserted_disk)
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
		atom_say("Error unkown data.")
		return

	if(multitool.buffer in linked_satellites) //already registered this satellite
		atom_say("Error entry already stored in database.")
		return

	linked_satellites += multitool.buffer
	to_chat(user, SPAN_NOTICE("You save \the [multitool]'s data into the [src]'s database. "))
	atom_say("Successfully stored information into the database.")
