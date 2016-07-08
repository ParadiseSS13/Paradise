/obj/machinery/computer3/atmos_alert
	default_prog = /datum/file/program/atmos_alert
	spawn_parts = list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/networking/radio)
	icon_state = "frame-eng"

/datum/file/program/atmos_alert
	name = "atmospheric alert monitor"
	desc = "Recieves alerts over the radio."
	active_state = "alert:2"
	refresh = 1
	var/list/priority_alarms = list()
	var/list/minor_alarms = list()


	execute(var/datum/file/program/source)
		..(source)

		if(!computer.radio)
			computer.Crash(MISSING_PERIPHERAL)

		computer.radio.set_frequency(1437,RADIO_ATMOSIA)


	Reset()
		..()
		// Never save your work
		priority_alarms.Cut()
		minor_alarms.Cut()


	// This will be called as long as the program is running on the parent computer
	// and the computer has the radio peripheral
	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption) return

		var/zone = signal.data["zone"]
		var/severity = signal.data["alert"]
		if(!zone || !severity) return

		minor_alarms -= zone
		priority_alarms -= zone
		if(severity=="severe")
			priority_alarms += zone
		else if(severity=="minor")
			minor_alarms += zone
		update_icon()
		return


	interact()
		if(!interactable())
			return
		if(!computer.radio)
			computer.Crash(MISSING_PERIPHERAL)

		popup.set_content(return_text())
		popup.open()


	update_icon()
		..()
		if(priority_alarms.len > 0)
			overlay.icon_state = "alert:2"
		else if(minor_alarms.len > 0)
			overlay.icon_state = "alert:1"
		else
			overlay.icon_state = "alert:0"

		if(computer)
			computer.update_icon()


	proc/return_text()
		var/priority_text = "<h2>Priority Alerts:</h2>"
		var/minor_text = "<h2>Minor Alerts:</h2>"

		if(priority_alarms.len)
			for(var/zone in priority_alarms)
				priority_text += "<FONT color='red'><B>[format_text(zone)]</B></FONT> [topic_link(src,"priority_clear=[ckey(zone)]","X")]<BR>"
		else
			priority_text += "No priority alerts detected.<BR>"

		if(minor_alarms.len)
			for(var/zone in minor_alarms)
				minor_text += "<B>[format_text(zone)]</B> [topic_link(src,"minor_clear=[ckey(zone)]","X")]<BR>"
		else
			minor_text += "No minor alerts detected.<BR>"

		return "[priority_text]<BR><HR>[minor_text]<BR>[topic_link(src,"close","Close")]"


	Topic(var/href, var/list/href_list)
		if(!interactable() || ..(href,href_list))
			return

		if("priority_clear" in href_list)
			var/removing_zone = href_list["priority_clear"]
			for(var/zone in priority_alarms)
				if(ckey(zone) == removing_zone)
					to_chat(usr, "\green Priority Alert for area [zone] cleared.")
					priority_alarms -= zone

		if("minor_clear" in href_list)
			var/removing_zone = href_list["minor_clear"]
			for(var/zone in minor_alarms)
				if(ckey(zone) == removing_zone)
					to_chat(usr, "\green Minor Alert for area [zone] cleared.")
					minor_alarms -= zone

		computer.updateUsrDialog()
