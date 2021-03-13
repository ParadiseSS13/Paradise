/obj/machinery/computer/rdconsole
	var/secureprotocols = TRUE	//si esta activo las cajas con req acces salen boqueadas por defecto

/obj/machinery/computer/rdconsole/power_change()
	..()
	if(!powered(power_channel))
		qdel(files)
		files = new /datum/research(src)
