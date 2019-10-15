
/**********************Asteroid**************************/

/turf/simulated/floor/plating/asteroid
	gender = PLURAL
	name = "asteroid sand"
	baseturf = /turf/simulated/floor/plating/asteroid
	icon_state = "asteroid"
	icon_plating = "asteroid"
	footstep_sounds = list()
	var/environment_type = "asteroid"
	var/turf_type = /turf/simulated/floor/plating/asteroid //Because caves do whacky shit to revert to normal
	var/floor_variance = 20 //probability floor has a different icon state
	var/obj/item/stack/digResult = /obj/item/stack/ore/glass/basalt
	var/dug

/turf/simulated/floor/plating/asteroid/Initialize(mapload)
	var/proper_name = name
	. = ..()
	name = proper_name
	if(prob(floor_variance))
		icon_state = "[environment_type][rand(0,12)]"

/turf/simulated/floor/plating/asteroid/proc/getDug()
	new digResult(src, 5)
	icon_plating = "[environment_type]_dug"
	icon_state = "[environment_type]_dug"
	dug = TRUE

/turf/simulated/floor/plating/asteroid/proc/can_dig(mob/user)
	if(!dug)
		return TRUE
	if(user)
		to_chat(user, "<span class='notice'>Looks like someone has dug here already.</span>")

/turf/simulated/floor/plating/asteroid/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/simulated/floor/plating/asteroid/burn_tile()
	return

/turf/simulated/floor/plating/asteroid/MakeSlippery(wet_setting)
	return

/turf/simulated/floor/plating/asteroid/MakeDry(wet_setting)
	return

/turf/simulated/floor/plating/asteroid/remove_plating()
	return

/turf/simulated/floor/plating/asteroid/ex_act(severity)
	if(!can_dig())
		return
	switch(severity)
		if(3)
			return
		if(2)
			if(prob(20))
				getDug()
		if(1)
			getDug()

/turf/simulated/floor/plating/asteroid/attackby(obj/item/I, mob/user, params)
	//note that this proc does not call ..()
	if(!I|| !user)
		return FALSE

	if((istype(I, /obj/item/shovel) || istype(I, /obj/item/pickaxe)))
		if(!can_dig(user))
			return TRUE

		var/turf/T = get_turf(user)
		if(!istype(T))
			return

		to_chat(user, "<span class='notice'>You start digging...</span>")

		playsound(src, I.usesound, 50, TRUE)
		if(do_after(user, 40 * I.toolspeed, target = src))
			if(!can_dig(user))
				return TRUE
			to_chat(user, "<span class='notice'>You dig a hole.</span>")
			getDug()
			return TRUE

	else if(istype(I, /obj/item/storage/bag/ore))
		var/obj/item/storage/bag/ore/S = I
		if(S.collection_mode == 1)
			for(var/obj/item/stack/ore/O in contents)
				O.attackby(I, user)
				return

	else if(istype(I, /obj/item/stack/tile))
		var/obj/item/stack/tile/Z = I
		if(!Z.use(1))
			return
		if(istype(Z, /obj/item/stack/tile/plasteel)) // Turn asteroid floors into plating by default
			ChangeTurf(/turf/simulated/floor/plating, keep_icon = FALSE)
		else
			ChangeTurf(Z.turf_type, keep_icon = FALSE)
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)

/turf/simulated/floor/plating/asteroid/basalt
	name = "volcanic floor"
	baseturf = /turf/simulated/floor/plating/asteroid/basalt
	icon_state = "basalt"
	icon_plating = "basalt"
	environment_type = "basalt"
	floor_variance = 15
	digResult = /obj/item/stack/ore/glass/basalt

/turf/simulated/floor/plating/asteroid/basalt/lava //lava underneath
	baseturf = /turf/simulated/floor/plating/lava/smooth

/turf/simulated/floor/plating/asteroid/basalt/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/plating/asteroid/basalt/Initialize(mapload)
	. = ..()
	set_basalt_light(src)

/turf/simulated/floor/plating/asteroid/basalt/getDug()
	set_light(0)
	return ..()

/proc/set_basalt_light(turf/simulated/floor/B)
	switch(B.icon_state)
		if("basalt1", "basalt2", "basalt3")
			B.set_light(2, 0.6, LIGHT_COLOR_LAVA) //more light
		if("basalt5", "basalt9")
			B.set_light(1.4, 0.6, LIGHT_COLOR_LAVA) //barely anything!

///////Surface. The surface is warm, but survivable without a suit. Internals are required. The floors break to chasms, which drop you into the underground.

/turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	planetary_atmos = TRUE
	baseturf = /turf/simulated/floor/plating/lava/smooth/lava_land_surface

/turf/simulated/floor/plating/asteroid/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0
	turf_type = /turf/simulated/floor/plating/asteroid/airless

#define SPAWN_MEGAFAUNA "bluh bluh huge boss"
#define SPAWN_BUBBLEGUM 6

GLOBAL_LIST_INIT(megafauna_spawn_list, list(/mob/living/simple_animal/hostile/megafauna/dragon = 4, /mob/living/simple_animal/hostile/megafauna/colossus = 2, /mob/living/simple_animal/hostile/megafauna/bubblegum = SPAWN_BUBBLEGUM))

/turf/simulated/floor/plating/asteroid/airless/cave
	var/length = 100
	var/list/mob_spawn_list
	var/list/megafauna_spawn_list
	var/list/flora_spawn_list
	var/sanity = 1
	var/forward_cave_dir = 1
	var/backward_cave_dir = 2
	var/going_backwards = TRUE
	var/has_data = FALSE
	var/data_having_type = /turf/simulated/floor/plating/asteroid/airless/cave/has_data
	turf_type = /turf/simulated/floor/plating/asteroid/airless

/turf/simulated/floor/plating/asteroid/airless/cave/has_data //subtype for producing a tunnel with given data
	has_data = TRUE

/turf/simulated/floor/plating/asteroid/airless/cave/volcanic
	mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/goliath/beast/random = 50, /obj/structure/spawner/lavaland/goliath = 3,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/random = 40, /obj/structure/spawner/lavaland = 2,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/random = 30, /obj/structure/spawner/lavaland/legion = 3,
		SPAWN_MEGAFAUNA = 6, /mob/living/simple_animal/hostile/asteroid/goldgrub = 10)

	data_having_type = /turf/simulated/floor/plating/asteroid/airless/cave/volcanic/has_data
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300

/turf/simulated/floor/plating/asteroid/airless/cave/volcanic/has_data //subtype for producing a tunnel with given data
	has_data = TRUE

/turf/simulated/floor/plating/asteroid/airless/cave/Initialize(mapload)
	if (!mob_spawn_list)
		mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/goldgrub = 1, /mob/living/simple_animal/hostile/asteroid/goliath = 5, /mob/living/simple_animal/hostile/asteroid/basilisk = 4, /mob/living/simple_animal/hostile/asteroid/hivelord = 3)
	if (!megafauna_spawn_list)
		megafauna_spawn_list = GLOB.megafauna_spawn_list
	if (!flora_spawn_list)
		flora_spawn_list = list(/obj/structure/flora/ash/leaf_shroom = 2 , /obj/structure/flora/ash/cap_shroom = 2 , /obj/structure/flora/ash/stem_shroom = 2 , /obj/structure/flora/ash/cacti = 1, /obj/structure/flora/ash/tall_shroom = 2)
	. = ..()
	if(!has_data)
		produce_tunnel_from_data()

/turf/simulated/floor/plating/asteroid/airless/cave/proc/get_cave_data(set_length, exclude_dir = -1)
	// If set_length (arg1) isn't defined, get a random length; otherwise assign our length to the length arg.
	if(!set_length)
		length = rand(25, 50)
	else
		length = set_length

	// Get our directiosn
	forward_cave_dir = pick(alldirs - exclude_dir)
	// Get the opposite direction of our facing direction
	backward_cave_dir = angle2dir(dir2angle(forward_cave_dir) + 180)

/turf/simulated/floor/plating/asteroid/airless/cave/proc/produce_tunnel_from_data(tunnel_length, excluded_dir = -1)
	get_cave_data(tunnel_length, excluded_dir)
	// Make our tunnels
	make_tunnel(forward_cave_dir)
	if(going_backwards)
		make_tunnel(backward_cave_dir)
	// Kill ourselves by replacing ourselves with a normal floor.
	SpawnFloor(src)

/turf/simulated/floor/plating/asteroid/airless/cave/proc/make_tunnel(dir)
	var/turf/simulated/mineral/tunnel = src
	var/next_angle = pick(45, -45)

	for(var/i = 0; i < length; i++)
		if(!sanity)
			break

		var/list/L = list(45)
		if(IsOdd(dir2angle(dir))) // We're going at an angle and we want thick angled tunnels.
			L += -45

		// Expand the edges of our tunnel
		for(var/edge_angle in L)
			var/turf/simulated/mineral/edge = get_step(tunnel, angle2dir(dir2angle(dir) + edge_angle))
			if(istype(edge))
				SpawnFloor(edge)

		if(!sanity)
			break

		// Move our tunnel forward
		tunnel = get_step(tunnel, dir)

		if(istype(tunnel))
			// Small chance to have forks in our tunnel; otherwise dig our tunnel.
			if(i > 3 && prob(20))
				var/turf/simulated/floor/plating/asteroid/airless/cave/C = tunnel.ChangeTurf(data_having_type, FALSE, TRUE)
				C.going_backwards = FALSE
				C.produce_tunnel_from_data(rand(10, 15), dir)
			else
				SpawnFloor(tunnel)
		else //if(!istype(tunnel, src.parent)) // We hit space/normal/wall, stop our tunnel.
			break

		// Chance to change our direction left or right.
		if(i > 2 && prob(33))
			// We can't go a full loop though
			next_angle = -next_angle
			setDir(angle2dir(dir2angle(dir) )+ next_angle)


/turf/simulated/floor/plating/asteroid/airless/cave/proc/SpawnFloor(turf/T)
	for(var/S in RANGE_TURFS(1, src))
		var/turf/NT = S
		if(!NT || isspaceturf(NT) || istype(NT.loc, /area/mine/explored) || istype(NT.loc, /area/lavaland/surface/outdoors/explored))
			sanity = 0
			break
	if(!sanity)
		return
	SpawnFlora(T)

	SpawnMonster(T)
	T.ChangeTurf(turf_type, FALSE, FALSE, TRUE)

/turf/simulated/floor/plating/asteroid/airless/cave/proc/SpawnMonster(turf/T)
	if(prob(30))
		if(istype(loc, /area/mine/explored) || !istype(loc, /area/lavaland/surface/outdoors/unexplored))
			return
		var/randumb = pickweight(mob_spawn_list)
		while(randumb == SPAWN_MEGAFAUNA)
			if(istype(loc, /area/lavaland/surface/outdoors/unexplored/danger)) //this is danger. it's boss time.
				var/maybe_boss = pickweight(megafauna_spawn_list)
				if(megafauna_spawn_list[maybe_boss])
					randumb = maybe_boss
			else //this is not danger, don't spawn a boss, spawn something else
				randumb = pickweight(mob_spawn_list)

		for(var/thing in urange(12, T)) //prevents mob clumps
			if(!ishostile(thing) && !istype(thing, /obj/structure/spawner))
				continue
			if((ispath(randumb, /mob/living/simple_animal/hostile/megafauna) || ismegafauna(thing)) && get_dist(src, thing) <= 7)
				return //if there's a megafauna within standard view don't spawn anything at all
			if(ispath(randumb, /mob/living/simple_animal/hostile/asteroid) || istype(thing, /mob/living/simple_animal/hostile/asteroid))
				return //if the random is a standard mob, avoid spawning if there's another one within 12 tiles
			if((ispath(randumb, /obj/structure/spawner/lavaland) || istype(thing, /obj/structure/spawner/lavaland)) && get_dist(src, thing) <= 2)
				return //prevents tendrils spawning in each other's collapse range

		if(ispath(randumb, /mob/living/simple_animal/hostile/megafauna/bubblegum)) //there can be only one bubblegum, so don't waste spawns on it
			megafauna_spawn_list.Remove(randumb)

		new randumb(T)

#undef SPAWN_MEGAFAUNA
#undef SPAWN_BUBBLEGUM

/turf/simulated/floor/plating/asteroid/airless/cave/proc/SpawnFlora(turf/T)
	if(prob(12))
		if(istype(loc, /area/mine/explored) || istype(loc, /area/lavaland/surface/outdoors/explored))
			return
		var/randumb = pickweight(flora_spawn_list)
		for(var/obj/structure/flora/ash/F in range(4, T)) //Allows for growing patches, but not ridiculous stacks of flora
			if(!istype(F, randumb))
				return
		new randumb(T)



/turf/simulated/floor/plating/asteroid/snow
	gender = PLURAL
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	baseturf = /turf/simulated/floor/plating/asteroid/snow
	icon_state = "snow"
	icon_plating = "snow"
	temperature = 180
	slowdown = 2
	environment_type = "snow"
	planetary_atmos = TRUE
	burnt_states = list("snow_dug")
	digResult = /obj/item/stack/sheet/mineral/snow

/turf/simulated/floor/plating/asteroid/snow/burn_tile()
	if(!burnt)
		visible_message("<span class='danger'>[src] melts away!.</span>")
		slowdown = 0
		burnt = TRUE
		icon_state = "snow_dug"
		return TRUE
	return FALSE

/turf/simulated/floor/plating/asteroid/snow/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/plating/asteroid/snow/temperature
	temperature = 255.37

/turf/simulated/floor/plating/asteroid/snow/atmosphere
	oxygen = 22
	nitrogen = 82
	temperature = 180
	planetary_atmos = FALSE