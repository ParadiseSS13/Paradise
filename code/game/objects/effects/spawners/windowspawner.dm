/obj/effect/spawner/window
	name = "window spawner"
	icon = 'icons/obj/structures.dmi'
	icon_state = "window_spawner"
	var/useFull = 0
	var/useGrille = 1
	var/windowtospawn = /obj/structure/window/basic

/obj/effect/spawner/window/New()
	spawn(0)
		for(var/obj/structure/grille/G in get_turf(src))	qdel(G) //just in case mappers don't know what they are doing

		if(!useFull)
			for(var/cdir in cardinal)
				for(var/obj/effect/spawner/window/WS in get_step(src,cdir))
					cdir = null
					break
				if(!cdir)	continue
				var/obj/structure/window/WI = new windowtospawn(get_turf(src))
				WI.dir = cdir
		else
			var/obj/structure/window/W = new windowtospawn(get_turf(src))
			W.dir = SOUTHWEST

		if(useGrille)
			new /obj/structure/grille(get_turf(src))

		src.air_update_turf(1) //atmos can pass otherwise

		spawn(10)
			qdel(src)

/obj/effect/spawner/window/reinforced
	name = "reinforced window spawner"
	icon_state = "rwindow_spawner"
	windowtospawn = /obj/structure/window/reinforced