/obj/tram/floor
	name = "tram platform"
	desc = "A holding space for a tram system."
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	var/obj/tram/tram_controller/controller
	anchored = 1
	layer = TURF_LAYER + 0.2

/obj/tram/floor/proc/spread_floors()
	var/turf/T = get_turf(src)
	if(!T)	return
	if(!controller)	return
	for(var/cdir in cardinal)
		var/turf/T2 = get_step(T,cdir)
		var/obj/tram/floor/TF = locate(/obj/tram/floor) in T2
		if(istype(TF))
			if(TF in controller.tram_floors)	continue
			controller.add_floor(TF)
			TF.spread_floors()