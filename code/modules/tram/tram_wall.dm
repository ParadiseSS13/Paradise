/obj/tram/wall
	name = "reinforced tram wall"
	desc = "A huge chunk of reinforced metal used to shield a tram system."
	icon = 'icons/turf/walls.dmi'
	icon_state = "r_wall"
	var/obj/tram/tram_controller/controller
	anchored = 1
	density = 1
	opacity = 1

/obj/tram/wall/proc/spread_walls()
	var/turf/T = get_turf(src)
	if(!T)	return
	if(!controller)	return
	for(var/cdir in GLOB.cardinal)
		var/turf/T2 = get_step(T,cdir)
		var/obj/tram/wall/TW = locate(/obj/tram/wall) in T2
		if(istype(TW))
			if(TW in controller.tram_walls)	continue
			controller.add_wall(TW)
			TW.spread_walls()
