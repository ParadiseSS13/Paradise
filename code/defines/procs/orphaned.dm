/proc/print_command_report(text = "", title = "Central Command Update")
	for(var/obj/machinery/computer/communications/C in machines)
		if(!(C.stat & (BROKEN|NOPOWER)) && C.z == STATION_LEVEL)
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(C.loc)
			P.name = "paper- '[title]'"
			P.info = text
			C.messagetitle.Add("[title]")
			C.messagetext.Add(text)
			P.update_icon()