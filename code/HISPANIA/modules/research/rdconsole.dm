/obj/machinery/computer/rdconsole/power_change()
	..()
	if(!powered(power_channel))
		qdel(files)
		files = new /datum/research(src)


