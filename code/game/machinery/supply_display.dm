/obj/machinery/status_display/supply_display
	name = "supply status display"
	ignore_friendc = 1

/obj/machinery/status_display/supply_display/update()
	if(!..() && mode == STATUS_DISPLAY_CUSTOM)
		var/line1
		var/line2
		if(shuttle_master.supply.mode == SHUTTLE_IDLE)
			if(shuttle_master.supply.z == ZLEVEL_STATION)
				line1 = "CARGO"
				line2 = "Docked"
		else
			line1 = "CARGO"
			line2 = get_supply_shuttle_timer()
			if(lentext(line2) > CHARS_PER_LINE)
				line2 = "Error"

		update_display(line1, line2)
		return 1
	return 0

/obj/machinery/status_display/supply_display/receive_signal/(datum/signal/signal)
	if(signal.data["command"] == "supply")
		mode = STATUS_DISPLAY_CUSTOM
	else
		return
