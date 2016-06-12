/turf/simulated/floor/wood
	icon_state = "wood"
	floor_tile = /obj/item/stack/tile/wood
	broken_states = list("wood-broken", "wood-broken2", "wood-broken3", "wood-broken4", "wood-broken5", "wood-broken6", "wood-broken7")

	footstep_sounds = list(
		"human" = list('sound/effects/footstep/wood_all.ogg'), //@RonaldVanWonderen of Freesound.org
		"xeno"  = list('sound/effects/footstep/wood_all.ogg')  //@RonaldVanWonderen of Freesound.org
	)

/turf/simulated/floor/wood/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/weapon/screwdriver))
		if(broken || burnt)
			return
		to_chat(user, "<span class='danger'>You unscrew the planks.</span>")
		new floor_tile(src)
		make_plating()
		playsound(src, 'sound/items/Screwdriver.ogg', 80, 1)
		return

/turf/simulated/floor/grass
	name = "grass patch"
	icon_state = "grass1"
	floor_tile = /obj/item/stack/tile/grass
	broken_states = list("sand")

/turf/simulated/floor/grass/New()
	..()
	spawn(1)
		update_icon()

/turf/simulated/floor/grass/update_icon()
	..()
	if(!(icon_state in list("grass1", "grass2", "grass3", "grass4", "sand")))
		icon_state = "grass[pick("1","2","3","4")]"

/turf/simulated/floor/grass/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/weapon/shovel))
		new /obj/item/weapon/ore/glass(src)
		new /obj/item/weapon/ore/glass(src) //Make some sand if you shovel grass
		to_chat(user, "<span class='notice'>You shovel the grass.</span>")
		make_plating()

/turf/simulated/floor/carpet
	name = "Carpet"
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet"
	floor_tile = /obj/item/stack/tile/carpet
	broken_states = list("damaged")
	smooth = SMOOTH_TRUE
	canSmoothWith = null

	footstep_sounds = list(
		"human" = list('sound/effects/footstep/carpet_human.ogg'),
		"xeno"  = list('sound/effects/footstep/carpet_xeno.ogg')
	)


/turf/simulated/floor/carpet/New()
	..()
	if(broken || burnt)
		make_plating()

/turf/simulated/floor/carpet/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		if(smooth)
			smooth_icon(src)
	else
		make_plating()
		if(smooth)
			smooth_icon_neighbors(src)

/turf/simulated/floor/carpet/break_tile()
	broken = 1
	update_icon()

/turf/simulated/floor/carpet/burn_tile()
	burnt = 1
	update_icon()

/turf/simulated/floor/fakespace
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	floor_tile = /obj/item/stack/tile/fakespace
	broken_states = list("damaged")

/turf/simulated/floor/fakespace/New()
	..()
	icon_state = "[rand(0,25)]"