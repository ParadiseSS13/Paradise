#define DEFAULT_SEED "glowshroom"
#define VINE_GROWTH_STAGES 5

/proc/spacevine_infestation(var/potency_min=70, var/potency_max=100, var/maturation_min=5, var/maturation_max=15)
	spawn() //to stop the secrets panel hanging
		var/list/turf/simulated/floor/turfs = list() //list of all the empty floor turfs in the hallway areas
		for(var/areapath in typesof(/area/hallway))
			var/area/A = locate(areapath)
			for(var/turf/simulated/floor/F in A.contents)
				if(turf_clear(F))
					turfs += F

		if(turfs.len) //Pick a turf to spawn at if we can
			var/turf/simulated/floor/T = pick(turfs)
			var/datum/seed/seed = plant_controller.create_random_seed(1)
			seed.set_trait(TRAIT_SPREAD,2)             // So it will function properly as vines.
			seed.set_trait(TRAIT_POTENCY,rand(potency_min, potency_max)) // 70-100 potency will help guarantee a wide spread and powerful effects.
			seed.set_trait(TRAIT_MATURATION,rand(maturation_min, maturation_max))

			//make vine zero start off fully matured
			var/obj/effect/plant/vine = new(T,seed)
			vine.health = vine.max_health
			vine.mature_time = 0
			vine.process()

			message_admins("<span class='notice'>Event: Spacevines spawned at [T.loc] ([T.x],[T.y],[T.z])</span>")

/obj/effect/dead_plant
	anchored = 1
	opacity = 0
	density = 0
	color = DEAD_PLANT_COLOUR

/obj/effect/dead_plant/attack_hand()
	qdel(src)

/obj/effect/dead_plant/attackby()
	..()
	for(var/obj/effect/plant/neighbor in range(1))
		neighbor.update_neighbors()
	qdel(src)

/obj/effect/plant
	name = "plant"
	anchored = 1
	opacity = 0
	density = 0
	icon = 'icons/obj/hydroponics_growing.dmi'
	icon_state = "bush4-1"
	layer = 3
	pass_flags = PASSTABLE

	var/health = 10
	var/max_health = 100
	var/growth_threshold = 0
	var/growth_type = 0
	var/max_growth = 0

	var/list/neighbors = list()
	var/obj/effect/plant/parent
	var/datum/seed/seed
	var/floor = 0
	var/spread_chance = 40
	var/spread_distance = 3
	var/evolve_chance = 2
	var/mature_time
	var/last_tick = 0
	var/obj/machinery/portable_atmospherics/hydroponics/soil/invisible/plant

	var/movable = 0

/obj/effect/plant/Destroy()
	if(buckled_mob)
		unbuckle_mob()
	if(plant_controller)
		plant_controller.remove_plant(src)
	for(var/obj/effect/plant/neighbor in range(1,src))
		plant_controller.add_plant(neighbor)
	return ..()

/obj/effect/plant/single
	spread_chance = 0

/obj/effect/plant/New(var/newloc, var/datum/seed/newseed, var/obj/effect/plant/newparent)
	..()

	if(!newparent)
		parent = src
	else
		parent = newparent

	if(!plant_controller)
		sleep(250) // ugly hack, should mean roundstart plants are fine.
	if(!plant_controller)
		to_chat(world, "<span class='danger'>Plant controller does not exist and [src] requires it. Aborting.</span>")
		qdel(src)
		return

	if(!istype(newseed))
		newseed = plant_controller.seeds[DEFAULT_SEED]
	seed = newseed
	if(!seed)
		qdel(src)
		return

	name = seed.display_name
	max_health = round(seed.get_trait(TRAIT_ENDURANCE)/2)
	if(seed.get_trait(TRAIT_SPREAD)==2)
		max_growth = VINE_GROWTH_STAGES
		growth_threshold = max_health/VINE_GROWTH_STAGES
		icon = 'icons/obj/hydroponics_vines.dmi'
		growth_type = 2 // Vines by default.
		if(seed.get_trait(TRAIT_CARNIVOROUS) == 2)
			growth_type = 1 // WOOOORMS.
		else if(!(seed.seed_noun in list("seeds","pits")))
			if(seed.seed_noun == "nodes")
				growth_type = 3 // Biomass
			else
				growth_type = 4 // Mold
	else
		max_growth = seed.growth_stages
		growth_threshold = max_health/seed.growth_stages

	if(max_growth > 2 && prob(50))
		max_growth-- //Ensure some variation in final sprite, makes the carpet of crap look less wonky.

	mature_time = world.time + seed.get_trait(TRAIT_MATURATION) + 15 //prevent vines from maturing until at least a few seconds after they've been created.
	spread_chance = seed.get_trait(TRAIT_POTENCY)
	if(growth_type == 0)							//These don't spread far at all (glowshroom, glowberries, brown mold)
		spread_distance = round(spread_chance*0.1)
	else if(growth_type == 2 || growth_type == 3)	//Vines and biomass can go further than worms and mold
		spread_distance = round(spread_chance*0.6)
	else											//Worms and mold go a moderate distance
		spread_distance = round(spread_chance*0.3)
	update_icon()

	spawn(1) // Plants will sometimes be spawned in the turf adjacent to the one they need to end up in, for the sake of correct dir/etc being set.
		set_dir(calc_dir())
		update_icon()
		plant_controller.add_plant(src)
		// Some plants eat through plating.
		if(!isnull(seed.chems["facid"]))
			var/turf/T = get_turf(src)
			T.ex_act(prob(80) ? 3 : 2)

/obj/effect/plant/update_icon()
	//TODO: should really be caching this.
	refresh_icon()
	if(growth_type == 0 && !floor)
		src.transform = null
		var/matrix/M = matrix()
		// should make the plant flush against the wall it's meant to be growing from.
		M.Translate(0,-(rand(12,14)))
		switch(dir)
			if(WEST)
				M.Turn(90)
			if(NORTH)
				M.Turn(180)
			if(EAST)
				M.Turn(270)
		src.transform = M
	var/icon_colour = seed.get_trait(TRAIT_PLANT_COLOUR)
	if(icon_colour)
		color = icon_colour
	// Apply colour and light from seed datum.
	if(seed.get_trait(TRAIT_BIOLUM))
		var/clr
		if(seed.get_trait(TRAIT_BIOLUM_COLOUR))
			clr = seed.get_trait(TRAIT_BIOLUM_COLOUR)
		set_light(1+round(seed.get_trait(TRAIT_POTENCY)/20), l_color = clr)
		return
	else
		set_light(0)

/obj/effect/plant/proc/refresh_icon()
	var/growth = min(max_growth,round(health/growth_threshold))
	var/at_fringe = get_dist(src,parent)
	if(spread_distance > 5)
		if(at_fringe >= (spread_distance-3))
			max_growth--
		if(at_fringe >= (spread_distance-2))
			max_growth--
	max_growth = max(1,max_growth)
	if(growth_type > 0)
		switch(growth_type)
			if(1)
				icon_state = "worms"
			if(2)
				icon_state = "vines-[growth]"
			if(3)
				icon_state = "mass-[growth]"
			if(4)
				icon_state = "mold-[growth]"
	else
		icon_state = "[seed.get_trait(TRAIT_PLANT_ICON)]-[growth]"

	if(growth>2 && growth == max_growth)
		layer = 5
		if(seed.get_trait(TRAIT_SPREAD) == 2)
			opacity = 1
		if(!isnull(seed.chems["woodpulp"]))
			density = 1
	else
		layer = 3
		density = 0

/obj/effect/plant/proc/calc_dir(turf/location = loc)
	set background = 1
	var/direction = 16

	for(var/wallDir in cardinal)
		var/turf/newTurf = get_step(location,wallDir)
		if(newTurf.density)
			direction |= wallDir

	for(var/obj/effect/plant/shroom in location)
		if(shroom == src)
			continue
		if(shroom.floor) //special
			direction &= ~16
		else
			direction &= ~shroom.dir

	var/list/dirList = list()

	for(var/i=1,i<=16,i <<= 1)
		if(direction & i)
			dirList += i

	if(dirList.len)
		var/newDir = pick(dirList)
		if(newDir == 16)
			floor = 1
			newDir = 1
		return newDir

	floor = 1
	return 1

/obj/effect/plant/attackby(var/obj/item/weapon/W, var/mob/user)

	plant_controller.add_plant(src)

	if(istype(W, /obj/item/weapon/wirecutters) || istype(W, /obj/item/weapon/scalpel))
		if(!seed)
			to_chat(user, "There is nothing to take a sample from.")
			return
		seed.harvest(user,0,1)
		health -= (rand(3,5)*10)
	else
		..()
		if(W.force)
			health -= W.force
	check_health()

/obj/effect/plant/ex_act(severity)
	switch(severity)
		if(1.0)
			die_off()
			return
		if(2.0)
			if(prob(50))
				die_off()
				return
		if(3.0)
			if(prob(5))
				die_off()
				return
		else
	return

/obj/effect/plant/proc/check_health()
	if(health <= 0)
		die_off()

/obj/effect/plant/proc/is_mature()
	return (health >= (max_health/3) && world.time > mature_time)