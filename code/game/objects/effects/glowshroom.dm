//separate dm since hydro is getting bloated already
/// Time interval between glowshroom "spreads". Made it as a constant for better control.
#define SPREAD_DELAY 13 SECONDS
/// Time interval between glowshroom decay checks.
#define DECAY_DELAY 60 SECONDS

/obj/structure/glowshroom
	name = "glowshroom"
	desc = "Mycena Bregprox, a species of mushroom that glows in the dark."
	anchored = TRUE
	opacity = 0
	density = FALSE
	icon = 'icons/obj/lighting.dmi'
	//replaced in Initialize()
	icon_state = "glowshroom"
	layer = ABOVE_NORMAL_TURF_LAYER
	/// Boolean to indicate if the shroom is on the floor/wall
	var/is_on_floor = FALSE
	/// Mushroom generation number
	var/generation = 1
	/// If we fail to spread this many times we stop trying to spread
	var/max_failed_spreads = 5
	/// Turfs where the glowshroom cannot spread to
	var/static/list/blacklisted_glowshroom_turfs = typecacheof(list(
		/turf/simulated/floor/plating/lava,
		/turf/simulated/floor/beach/water))
	/// Internal seed of the glowshroom, stats are stored here
	var/obj/item/seeds/myseed = /obj/item/seeds/glowshroom

/obj/structure/glowshroom/glowcap
	name = "glowcap"
	desc = "Mycena Ruthenia, a species of mushroom that, while it does glow in the dark, is not actually bioluminescent."
	icon_state = "glowcap"
	myseed = /obj/item/seeds/glowshroom/glowcap

/obj/structure/glowshroom/shadowshroom
	name = "shadowshroom"
	desc = "Mycena Umbra, a species of mushroom that emits shadow instead of light."
	icon_state = "shadowshroom"
	myseed = /obj/item/seeds/glowshroom/shadowshroom

/obj/structure/glowshroom/single/Spread()
	return

/obj/structure/glowshroom/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("This is a [generation]\th generation [name]!")

/**
  *	Creates a new glowshroom structure.
  *
  * Arguments:
  * * newseed - Seed of the shroom
  * * mutate_stats - If the plant needs to mutate their stats
  * * spread - If the plant is a result of spreading, reduce its stats
  */

/obj/structure/glowshroom/Initialize(mapload, obj/item/seeds/newseed, mutate_stats, spread)
	. = ..()
	if(newseed)
		myseed = newseed.Copy()
		myseed.forceMove(src)
	else
		myseed = new myseed(src)
	//baby mushrooms have different stats :3
	if(mutate_stats)
		myseed.adjust_potency(rand(-4, 3))
		myseed.adjust_yield(rand(-3, 2))
		myseed.adjust_production(rand(-3, 3))
		// babies endurance has a min/max value of 30 to prevent endurance loss/boost by botany department
		myseed.endurance = clamp(myseed.endurance, 45, 45)

	if(myseed.get_gene(/datum/plant_gene/trait/glow))
		var/datum/plant_gene/trait/glow/glow_gene = myseed.get_gene(/datum/plant_gene/trait/glow)
		set_light(glow_gene.glow_range(myseed), glow_gene.glow_power(myseed), glow_gene.glow_color)
	setDir(calc_dir())
	var/base_icon_state = initial(icon_state)
	if(!is_on_floor)
		//offset to make it be on the wall rather than on the floor
		switch(dir)
			if(NORTH)
				pixel_y = 32
			if(SOUTH)
				pixel_y = -32
			if(EAST)
				pixel_x = 32
			if(WEST)
				pixel_x = -32
		icon_state = "[base_icon_state][rand(1,3)]"
	else
		//if on the floor, glowshroom on-floor sprite
		icon_state = "[base_icon_state]f"

	addtimer(CALLBACK(src, .proc/Spread), SPREAD_DELAY, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
	addtimer(CALLBACK(src, .proc/Decay), DECAY_DELAY, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)	// Start decaying the plant

/obj/structure/glowshroom/proc/Spread()
	//We could be deleted at any point and the timers might not be cleaned up
	if(QDELETED(src))
		return
	var/turf/ownturf = get_turf(src)
	var/shrooms_planted = 0
	var/list/possible_locs = list()
	//Lets collect a list of possible viewable turfs BEFORE we iterate for yield so we don't call view multiple
	//times when there's no real chance of the viewable range changing, really you could do this once on item
	//spawn and most people probably would not notice.
	for(var/turf/simulated/floor/earth in RANGE_TURFS(1, src))
		if(is_type_in_typecache(earth, blacklisted_glowshroom_turfs))
			continue
		if(!ownturf.CanAtmosPass(earth))
			continue
		possible_locs += earth

	//Lets not even try to spawn again if somehow we have ZERO possible locations
	if(!length(possible_locs))
		return

	for(var/i in 1 to myseed.yield)
		// This formula gives you diminishing returns based on generation. 90% with 1st gen, decreasing to 40%, 23.3(3)%, 15, 10, 6...
		var/chance_generation = 100 / generation - 10

		// Whatever is the higher chance we use it (this is really stupid as the diminishing returns are effectively pointless???)
		if(!prob(chance_generation))
			continue

		var/turf/new_loc = pick(possible_locs)
		//We failed to find any location, skip trying to yield
		var/shroom_count = 0
		var/place_count = 1
		for(var/obj/structure/glowshroom/shroom in new_loc)
			shroom_count++
		for(var/wall_dir in GLOB.cardinal)
			var/turf/is_wall = get_step(new_loc, wall_dir)
			if(is_wall.density)
				place_count++
		if(shroom_count >= place_count)
			continue

		// Decay before spawning new mushrooms to reduce their endurance
		Decay(TRUE, 2)

		//Decay can end us
		if(QDELETED(src))
			return

		var/obj/structure/glowshroom/child = new type(new_loc, myseed, TRUE, TRUE)
		child.generation = generation + 1
		shrooms_planted++

	if(!shrooms_planted)
		max_failed_spreads--

	//if we didn't get all possible shrooms planted or we haven't failed to spread at least 5 times then try to spread again later
	if((shrooms_planted <= myseed.yield) && (max_failed_spreads >= 0))
		myseed.adjust_yield(-shrooms_planted)
		//Lets make this a unique hash
		addtimer(CALLBACK(src, .proc/Spread), SPREAD_DELAY, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)

/obj/structure/glowshroom/proc/calc_dir(turf/location = loc)
	var/direction = (1<<4)

	for(var/wall_dir in GLOB.cardinal)
		var/turf/new_turf = get_step(location, wall_dir)
		if(new_turf.density)
			direction |= wall_dir

	for(var/obj/structure/glowshroom/shroom in location)
		if(shroom == src)
			continue
		//special
		if(shroom.is_on_floor)
			direction &= ~(1<<4)
		else
			direction &= ~shroom.dir

	var/list/dir_list = list()

	for(var/dir_to_check in (GLOB.cardinal + (1<<4)))
		if(direction & dir_to_check)
			dir_list += dir_to_check

	if(length(dir_list))
		var/new_dir = pick(dir_list)
		if(new_dir == (1<<4))
			is_on_floor = TRUE
			new_dir = NORTH
		return new_dir

	is_on_floor = TRUE
	return NORTH
/**
  * Causes the glowshroom to decay by decreasing its endurance.
  *
  * Arguments:
  * * spread - Boolean to indicate if the decay is due to spreading or natural decay.
  * * amount - Amount of endurance to be reduced due to spread decay.
  */
/obj/structure/glowshroom/proc/Decay(spread, amount)
	// Decay due to spread
	if(spread)
		myseed.endurance -= amount
	else
		// Timed decay
		myseed.endurance -= 2
		if(myseed.endurance > 0)
			addtimer(CALLBACK(src, .proc/Decay), DECAY_DELAY, TIMER_UNIQUE|TIMER_NO_HASH_WAIT) // Recall decay timer
			return
	// Plant is gone
	if(myseed.endurance < 1)
		qdel(src)

/obj/structure/glowshroom/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/slash.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/glowshroom/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

/obj/structure/glowshroom/acid_act(acidpwr, acid_volume)
	. = 1
	visible_message(SPAN_DANGER("[src] melts away!"))
	var/obj/effect/decal/cleanable/molten_object/object = new (get_turf(src))
	object.desc = "Looks like this was \an [src] some time ago."
	qdel(src)

/obj/structure/glowshroom/attacked_by(obj/item/tool, mob/living/user)
	var/damage_dealt = tool.force
	if(istype(tool, /obj/item/scythe))
		var/obj/item/scythe/weapon = tool
		//so folded telescythes won't get damage boosts / insta-clears (they instead will be treated like non-scythes)
		if(weapon.extend)
			damage_dealt *= 10
			for(var/obj/structure/glowshroom/shroom in view(1, src))
				shroom.take_damage(damage_dealt, tool.damtype, "melee", 1)
			return

	if(is_sharp(tool) || tool.damtype == BURN)
		damage_dealt *= 4

	take_damage(damage_dealt, tool.damtype, "melee", 1)

//Way to check glowshroom stats using plant analyzer
/obj/structure/glowshroom/attackby(obj/item/plant_analyzer/plant_analyzer, mob/living/user, params)
	if(istype(plant_analyzer))
		// Hacky I guess
		return myseed.attackby(plant_analyzer, user, params)
	return ..()

#undef SPREAD_DELAY
#undef DECAY_DELAY
