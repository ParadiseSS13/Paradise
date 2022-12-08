/obj/machinery/door/airlock/alarmlock
	name = "glass alarm airlock"
	icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
	overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
	opacity = FALSE
	glass = TRUE
	autoclose = FALSE
	var/datum/radio_frequency/air_connection
	var/air_frequency = ATMOS_FIRE_FREQ

/obj/machinery/door/airlock/alarmlock/Destroy()
	if(SSradio)
		SSradio.remove_object(src,air_frequency)
	air_connection = null
	return ..()

/obj/machinery/door/airlock/alarmlock/Initialize()
	. = ..()
	air_connection = new
	SSradio.remove_object(src, air_frequency)
	air_connection = SSradio.add_object(src, air_frequency, RADIO_TO_AIRALARM)
	open()

/obj/machinery/door/airlock/alarmlock/receive_signal(datum/signal/signal)
	..()
	if(stat & (NOPOWER|BROKEN))
		return

	var/alarm_area = signal.data["zone"]
	var/alert = signal.data["alert"]

	var/area/our_area = get_area(src)

	if(alarm_area == our_area.name)
		switch(alert)
			if("severe")
				autoclose = TRUE
				close()
			if("minor", "clear")
				autoclose = FALSE
				open()
