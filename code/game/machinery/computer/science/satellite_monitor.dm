/obj/machinery/computer/satellite_monitor
	var/list/linked_satellites

/obj/machinery/computer/satellite_monitor/Initialize(mapload)
	. = ..()
	linked_satellites = list()
