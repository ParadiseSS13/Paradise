/obj/machinery/computer/rdconsole/auto_use_power()
	..()
	if(!powered(power_channel))
		qdel(files)
		files = new /datum/research(src)


