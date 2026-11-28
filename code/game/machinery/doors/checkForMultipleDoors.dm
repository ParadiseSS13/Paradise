/obj/machinery/door/proc/checkForMultipleDoors()
	if(!loc)
		return FALSE
	for(var/obj/machinery/door/D in loc)
		if(!istype(D, /obj/machinery/door/window) && D.density)
			return FALSE
	return TRUE

/turf/simulated/wall/proc/checkForMultipleDoors()
	if(!loc)
		return FALSE
	for(var/obj/machinery/door/D in locate(x,y,z))
		if(!istype(D, /obj/machinery/door/window) && D.density)
			return FALSE
	//There are no false wall checks because that would be foolish
	return TRUE
