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
	if(isscrewdriver(C))
		pry_tile(C, user)
		return

/turf/simulated/floor/wood/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	if(T.turf_type == type)
		return
	var/obj/item/tool
	if(isscrewdriver(user.get_inactive_hand()))
		tool = user.get_inactive_hand()
	if(!tool && iscrowbar(user.get_inactive_hand()))
		tool = user.get_inactive_hand()
	if(!tool)
		return
	var/turf/simulated/floor/plating/P = pry_tile(tool, user, TRUE)
	if(!istype(P))
		return
	P.attackby(T, user, params)

/turf/simulated/floor/wood/pry_tile(obj/item/C, mob/user, silent = FALSE)
	var/is_screwdriver = isscrewdriver(C)
	playsound(src, C.usesound, 80, 1)
	return remove_tile(user, silent, make_tile = is_screwdriver)

/turf/simulated/floor/wood/remove_tile(mob/user, silent = FALSE, make_tile = TRUE)
	if(broken || burnt)
		broken = 0
		burnt = 0
		if(user && !silent)
			to_chat(user, "<span class='danger'>You remove the broken planks.</span>")
	else
		if(make_tile)
			if(user && !silent)
				to_chat(user, "<span class='danger'>You unscrew the planks.</span>")
			if(builtin_tile)
				builtin_tile.forceMove(src)
				builtin_tile = null
		else
			if(user && !silent)
				to_chat(user, "<span class='danger'>You forcefully pry off the planks, destroying them in the process.</span>")
	return make_plating()

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
	if(istype(C, /obj/item/shovel))
		new /obj/item/stack/ore/glass(src, 2) //Make some sand if you shovel grass
		to_chat(user, "<span class='notice'>You shovel the grass.</span>")
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1)
		make_plating()

// NEEDS TO BE UPDATED
/turf/simulated/floor/basalt //By your powers combined, I am captain planet
	name = "volcanic floor"
	icon_state = "basalt0"
	oxygen = 14
	nitrogen = 23
	temperature = 300

/turf/simulated/floor/basalt/attackby(obj/item/W, mob/user, params)
	if(..())
		return
	if(istype(W, /obj/item/shovel))
		new /obj/item/stack/ore/glass/basalt(src, 2)
		user.visible_message("<span class='notice'>[user] digs up [src].</span>", "<span class='notice'>You uproot [src].</span>")
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1)
		make_plating()

/turf/simulated/floor/basalt/New()
	..()
	if(prob(15))
		icon_state = "basalt[rand(0, 12)]"
		switch(icon_state)
			if("basalt1", "basalt2", "basalt3")
				set_light(1, 1)

/turf/simulated/floor/carpet
	name = "carpet"
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
			queue_smooth(src)
	else
		make_plating()
		if(smooth)
			queue_smooth_neighbors(src)

/turf/simulated/floor/carpet/break_tile()
	broken = 1
	update_icon()

/turf/simulated/floor/carpet/burn_tile()
	burnt = 1
	update_icon()

/turf/simulated/floor/carpet/black
	icon = 'icons/turf/floors/carpet_black.dmi'
	floor_tile = /obj/item/stack/tile/carpet/black
	canSmoothWith = list(/turf/simulated/floor/carpet/black)

/turf/simulated/floor/fakespace
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	floor_tile = /obj/item/stack/tile/fakespace
	broken_states = list("damaged")

/turf/simulated/floor/fakespace/New()
	..()
	icon_state = "[rand(0,25)]"

/turf/simulated/floor/carpet/arcade
	icon = 'icons/goonstation/turf/floor.dmi'
	icon_state = "arcade"
	floor_tile = /obj/item/stack/tile/arcade_carpet
	smooth = SMOOTH_FALSE
