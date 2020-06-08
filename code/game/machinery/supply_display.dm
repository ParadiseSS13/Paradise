/obj/machinery/status_display/supply_display
	name = "дисплей статуса доставки"
	ignore_friendc = 1

/obj/machinery/status_display/supply_display/update()
	if(!..() && mode == STATUS_DISPLAY_CUSTOM)
		if(SSshuttle.supply.mode == SHUTTLE_IDLE)
			if(is_station_level(SSshuttle.supply.z))
				message1 = "ГРУЗ"
				message2 = "ГОТОВ"
			else
				message1 = "ВРЕМЯ"
				message2 = station_time_timestamp("hh:mm")
		else
			message1 = "ГРУЗ"
			message2 = SSshuttle.supply.getTimerStr()
			if(length(message2) > CHARS_PER_LINE)
				message2 = "Error"

		update_display(message1, message2)
		return 1
	return 0

/obj/machinery/status_display/supply_display/receive_signal/(datum/signal/signal)
	if(signal.data["command"] == "supply")
		mode = STATUS_DISPLAY_CUSTOM
	else
		return

#undef CHARS_PER_LINE
#undef STATUS_DISPLAY_CUSTOM
