/// Approximate lower bound of the walkable land area on Lavaland, north of the southern lava border.
#define LAVALAND_MIN_CAVE_Y 10
/// Approximate upper bound of the walkable land area on Lavaland, south of the Legion entrance.
#define LAVALAND_MAX_CAVE_Y 222

#define SPAWN_MEGAFAUNA "bluh bluh huge boss"

/// Effective probability modifier for spawning flora and fauna in oases.
#define OASIS_SPAWNER_PROB_MODIFIER 43

GLOBAL_LIST_INIT(megafauna_spawn_list, list(
	/mob/living/simple_animal/hostile/megafauna/dragon = 4,
	/mob/living/simple_animal/hostile/megafauna/colossus = 2,
	/mob/living/simple_animal/hostile/megafauna/bubblegum = 6,
	/mob/living/simple_animal/hostile/megafauna/ancient_robot = 4,
))

GLOBAL_LIST_INIT(caves_default_mob_spawns, list(
	/obj/effect/landmark/mob_spawner/abandoned_minebot = 6,
	/obj/effect/landmark/mob_spawner/goldgrub = 10,
	/obj/effect/landmark/mob_spawner/goliath = 50,
	/obj/effect/landmark/mob_spawner/gutlunch = 4,
	/obj/effect/landmark/mob_spawner/legion = 30,
	/obj/effect/landmark/mob_spawner/watcher = 40,

	/obj/structure/spawner/lavaland = 2,
	/obj/structure/spawner/lavaland/goliath = 3,
	/obj/structure/spawner/lavaland/legion = 3,

	SPAWN_MEGAFAUNA = 6,
))

GLOBAL_LIST_INIT(caves_default_flora_spawns, list(
	/obj/structure/flora/ash/cacti = 1,
	/obj/structure/flora/ash/cap_shroom = 2,
	/obj/structure/flora/ash/leaf_shroom = 2,
	/obj/structure/flora/ash/rock/style_random = 1,
	/obj/structure/flora/ash/stem_shroom = 2,
	/obj/structure/flora/ash/tall_shroom = 2,
))

/proc/lavaland_caves_spawn_mob(turf/T, mob_scan_range = 12, megafauna_scan_range = 7)
	var/mob_spawn = pickweight(GLOB.caves_default_mob_spawns)

	while(mob_spawn == SPAWN_MEGAFAUNA)
		if(istype(get_area(T), /area/lavaland/surface/outdoors/unexplored/danger)) //this is danger. it's boss time.
			mob_spawn = pickweight(GLOB.megafauna_spawn_list)
		else //this is not danger, don't spawn a boss, spawn something else
			mob_spawn = pickweight(GLOB.caves_default_mob_spawns)

	for(var/thing in urange(mob_scan_range, T))
		if(!(ishostile(thing) || istype(thing, /obj/structure/spawner) || istype(thing, /obj/effect/landmark/mob_spawner)))
			continue
		// don't spawn a megafauna if there's already one within view
		if((ispath(mob_spawn, /mob/living/simple_animal/hostile/megafauna) || ismegafauna(thing)) && (get_dist(T, thing) <= megafauna_scan_range))
			return
		// if the random is a standard mob, avoid spawning if there's another one within the scan range
		if(ispath(mob_spawn, /obj/effect/landmark/mob_spawner) && istype(thing, /obj/effect/landmark/mob_spawner))
			return
		// prevents tendrils spawning in each other's collapse range
		if((ispath(mob_spawn, /obj/structure/spawner/lavaland) && istype(thing, /obj/structure/spawner/lavaland)) && get_dist(T, thing) <= LAVALAND_TENDRIL_COLLAPSE_RANGE)
			return

	// there can be only one bubblegum, so don't waste spawns on it
	if(ispath(mob_spawn, /mob/living/simple_animal/hostile/megafauna/bubblegum))
		GLOB.megafauna_spawn_list.Remove(mob_spawn)

	// same as above, we do not want multiple of these robots
	if(ispath(mob_spawn, /mob/living/simple_animal/hostile/megafauna/ancient_robot))
		GLOB.megafauna_spawn_list.Remove(mob_spawn)

	new mob_spawn(T)
	SSblackbox.record_feedback("tally", "lavaland_mob_spawns", 1, "[mob_spawn]")

/proc/lavaland_caves_spawn_flora(turf/T)
	var/flora_spawn = pickweight(GLOB.caves_default_flora_spawns)
	for(var/obj/structure/flora/ash/F in range(4, T)) //Allows for growing patches, but not ridiculous stacks of flora
		if(!istype(F, flora_spawn))
			return
	new flora_spawn(T)

/datum/caves_theme
	var/name = "Not Specified"

	var/seed
	var/perlin_accuracy = 5
	var/perlin_stamp_size = 10
	var/perlin_lower_range = 0
	var/perlin_upper_range = 0.3

/datum/caves_theme/New()
	seed = rand(1, 999999)

/datum/caves_theme/proc/setup()
	var/result = rustg_dbp_generate("[seed]", "[perlin_accuracy]", "[perlin_stamp_size]", "[world.maxx]", "[perlin_lower_range]", "[perlin_upper_range]")
	var/z = level_name_to_num(MINING)
	for(var/turf/T in block(1, 1, z, world.maxx, world.maxy, z))
		if(!istype(get_area(T), /area/lavaland/surface/outdoors/unexplored))
			continue
		if(!istype(T, /turf/simulated/mineral))
			continue
		var/c = result[world.maxx * (T.y - 1) + T.x]
		if(c == "1")
			T.ChangeTurf(/turf/simulated/floor/plating/asteroid/basalt/lava_land_surface)
			on_change(T)

		CHECK_TICK

/datum/caves_theme/proc/on_change(turf/T)
	if(prob(2))
		lavaland_caves_spawn_flora(T)
	else if(prob(1))
		lavaland_caves_spawn_mob(T)

/datum/caves_theme/proc/safe_replace(turf/T)
	if(T.flags & NO_LAVA_GEN)
		return FALSE
	if(!istype(get_area(T), /area/lavaland/surface/outdoors/unexplored))
		return FALSE
	if(istype(T, /turf/simulated/floor/chasm))
		return FALSE
	if(istype(T, /turf/simulated/floor/lava/lava_land_surface))
		return FALSE
	if(istype(T, /turf/simulated/floor/lava/mapping_lava))
		return FALSE

	return TRUE

/datum/caves_theme/classic
	name = "Classic Caves"

/datum/caves_theme/burrows
	name = "Blocked Burrows"
	perlin_accuracy = 90
	perlin_stamp_size = 7
	perlin_lower_range = 0
	perlin_upper_range = 0.3

/datum/caves_theme/burrows/on_change(turf/T)
	if(prob(9))
		new /obj/structure/flora/ash/rock/style_random(T)
	else if(prob(5))
		lavaland_caves_spawn_flora(T)
	else if(prob(1))
		lavaland_caves_spawn_mob(T)

/datum/caves_theme/deeprock/proc/maybe_make_room(turf/T)
	if(rand(1, 150) != 1)
		return

	for(var/turf/oasis_centroid in oasis_centroids)
		if(get_dist(T, oasis_centroid) < oasis_padding)
			return

	oasis_centroids |= T
	var/new_scan_range = rand(4, 7)
	var/tempradius = rand(10, 15)
	var/probmodifer = OASIS_SPAWNER_PROB_MODIFIER * tempradius
	var/list/oasis_turfs = list()
	for(var/turf/NT in circlerangeturfs(T, tempradius))
		var/distance = (max(get_dist(T, NT), 1)) //Get dist throws -1 if same turf
		if(safe_replace(NT) && prob(min(probmodifer / distance, 100)))
			var/turf/changed = NT.ChangeTurf(/turf/simulated/floor/plating/asteroid/basalt/lava_land_surface)
			if(prob(5))
				lavaland_caves_spawn_mob(changed, new_scan_range, new_scan_range)
			else if(prob(10))
				lavaland_caves_spawn_flora(changed)
			oasis_turfs |= NT

	if(prob(50))
		tempradius = round(tempradius / 3)
		var/oasis_laketype = pickweight(lake_weights)
		if(oasis_laketype == /turf/simulated/floor/plating/asteroid)
			new /obj/effect/spawner/oasisrock(T, tempradius)
		for(var/turf/oasis in circlerangeturfs(T, tempradius))
			if(safe_replace(oasis))
				oasis.ChangeTurf(oasis_laketype)
				oasis_turfs -= oasis

		// Move tendrils out of the oasis
		for(var/obj/structure/spawner/lavaland/O in circlerange(T, tempradius))
			O.forceMove(pick_n_take(oasis_turfs))

	return T

/datum/caves_theme/deeprock
	name = "Deadly Deeprock"
	perlin_stamp_size = 12
	perlin_lower_range = 0
	perlin_upper_range = 0.2
	var/oasis_padding = 50
	var/list/oasis_centroids = list()
	var/lake_weights = list(
		/turf/simulated/floor/lava/lava_land_surface = 4,
		/turf/simulated/floor/lava/lava_land_surface/plasma = 4,
		/turf/simulated/floor/chasm/straight_down/lava_land_surface = 4,
		/turf/simulated/floor/lava/mapping_lava = 6,
		/turf/simulated/floor/beach/away/water/lavaland_air = 1,
		/turf/simulated/floor/plating/asteroid = 1
	)

/datum/caves_theme/deeprock/on_change(turf/T)
	maybe_make_room(T)
	if(prob(3))
		lavaland_caves_spawn_flora(T)
	else if(prob(2))
		lavaland_caves_spawn_mob(T)


#undef OASIS_SPAWNER_PROB_MODIFIER
#undef SPAWN_MEGAFAUNA

#undef LAVALAND_MIN_CAVE_Y
#undef LAVALAND_MAX_CAVE_Y
