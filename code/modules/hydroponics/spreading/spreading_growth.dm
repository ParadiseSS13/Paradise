#define NEIGHBOR_REFRESH_TIME 100

/obj/effect/plant/proc/get_cardinal_neighbors()
	var/list/cardinal_neighbors = list()
	for(var/check_dir in cardinal)
		var/turf/simulated/T = get_step(get_turf(src), check_dir)
		if(istype(T))
			cardinal_neighbors |= T
	return cardinal_neighbors

/obj/effect/plant/proc/update_neighbors()
	// Update our list of valid neighboring turfs.
	neighbors = list()
	for(var/turf/simulated/floor in get_cardinal_neighbors())
		if(get_dist(parent, floor) > spread_distance)
			continue
		if((locate(/obj/effect/plant) in floor.contents) || (locate(/obj/effect/dead_plant) in floor.contents) )
			continue
		if(floor.density)
			if(!isnull(seed.chems["pacid"]))
				spawn(rand(5,25)) floor.ex_act(3)
			continue
		if(!Adjacent(floor) || !floor.Enter(src))
			continue
		neighbors |= floor
	// Update all of our friends.
	var/turf/T = get_turf(src)
	for(var/obj/effect/plant/neighbor in range(1,src))
		neighbor.neighbors -= T

/obj/effect/plant/process()

	// Something is very wrong, kill ourselves.
	if(!seed)
		die_off()
		return 0

	/* MOVED INTO code\game\objects\effects\effect_system.dm
	for(var/obj/effect/effect/smoke/chem/smoke in view(1, src))
		if(smoke.reagents.has_reagent("plantbgone"))
			die_off()
			return
	*/

	// Handle life.
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		health -= seed.handle_environment(T,T.return_air(),null,null,1)
	if(health < max_health)
		health += rand(3,5)
		refresh_icon()
		if(health > max_health)
			health = max_health
	else if(health == max_health && !plant)
		plant = new(T,seed)
		plant.dir = src.dir
		plant.transform = src.transform
		plant.age = seed.get_trait(TRAIT_MATURATION)-1
		plant.update_icon()
		if(growth_type==0) //Vines do not become invisible.
			invisibility = INVISIBILITY_MAXIMUM
		else
			plant.layer = layer + 0.1

	if(buckled_mob)
		seed.do_sting(buckled_mob,src)
		if(seed.get_trait(TRAIT_CARNIVOROUS))
			seed.do_thorns(buckled_mob,src)

	if(world.time >= last_tick+NEIGHBOR_REFRESH_TIME)
		last_tick = world.time
		update_neighbors()

	if(is_mature() && neighbors.len && prob(spread_chance))
		//spread to 1-3 adjacent turfs depending on yield trait.
		var/max_spread = between(1, round(seed.get_trait(TRAIT_YIELD)*3/14), 3)

		for(var/i in 1 to max_spread)
			if(prob(spread_chance))
				sleep(rand(3,5))
				if(!neighbors.len)
					break
				var/turf/target_turf = pick(neighbors)
				var/obj/effect/plant/child = new(get_turf(src),seed,parent)
				spawn(1) // This should do a little bit of animation.
					child.loc = target_turf
					child.update_icon()
				// Update neighboring squares.
				for(var/obj/effect/plant/neighbor in range(1,target_turf))
					neighbor.neighbors -= target_turf

	// We shouldn't have spawned if the controller doesn't exist.
	check_health()
	if(neighbors.len || health != max_health)
		plant_controller.add_plant(src)

/obj/effect/plant/proc/die_off()
	// Kill off our plant.
	if(plant) plant.die()
	// This turf is clear now, let our buddies know.
	for(var/turf/simulated/check_turf in get_cardinal_neighbors())
		if(!istype(check_turf))
			continue
		for(var/obj/effect/plant/neighbor in check_turf.contents)
			neighbor.neighbors |= check_turf
			plant_controller.add_plant(neighbor)
	spawn(1) if(src) del(src)

#undef NEIGHBOR_REFRESH_TIME