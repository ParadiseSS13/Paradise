#define LONG_BRIDGE_THEME_CULT "cult"
#define LONG_BRIDGE_THEME_HIERO "hiero"
#define LONG_BRIDGE_THEME_CLOCKWORK "clockwork"
#define LONG_BRIDGE_THEME_STONE "stone"
#define LONG_BRIDGE_THEME_WOOD "wood"
#define LONG_BRIDGE_THEME_CATWALK "catwalk"

/**
 * A spawner for dynamic bridges, largely with hardcoded expectations to be
 * operating on Lavaland.
 *
 * It does this by starting at its spawn point, placed by a
 * [/datum/river_spawner] during generation, and walking in each direction
 * "forwards" and "backwards" until it reaches the maximum possible length of
 * the bridge, or a tile that doesn't appear to be a valid "passage"
 * (essentially a tile that doesn't have lava on both sides and thus wouldn't
 * look good or make an effective bridge). If it manages to do this and find two
 * tiles that work as the start and end of the bridge, it places the paths,
 * pillars, and "cleans up" the tiles contiguous to its entrance and exit turfs,
 * removing any lava if present.
 *
 * It attempts this first in the vertical direction, and then the horizontal. So
 * "fowards" and "backwards" can mean NORTH/SOUTH or EAST/WEST depending on the
 * direction it's attempting.
 *
 * There are several bridge "themes" implemented in `make_walkway()` and
 * `make_pillar()`, and more can be added if desired.
 */
/obj/effect/spawner/dynamic_bridge
	var/max_length = 8
	var/min_length = 4
	var/bridge_theme
	var/list/forwards_backwards
	var/list/side_to_side
	var/turf/forward_goal
	var/turf/backward_goal

/obj/effect/spawner/dynamic_bridge/Initialize(mapload)
	. = ..()
	if(!bridge_theme)
		bridge_theme = pick(
			LONG_BRIDGE_THEME_CULT,
			LONG_BRIDGE_THEME_HIERO,
			LONG_BRIDGE_THEME_CLOCKWORK,
			LONG_BRIDGE_THEME_STONE,
			LONG_BRIDGE_THEME_WOOD,
			LONG_BRIDGE_THEME_CATWALK,
		)
	return INITIALIZE_HINT_LATELOAD

/obj/effect/spawner/dynamic_bridge/LateInitialize()
	forwards_backwards = list(NORTH, SOUTH)
	side_to_side = list(EAST, WEST)
	if(attempt_bridge() != BRIDGE_SPAWN_SUCCESS)
		forward_goal = null
		backward_goal = null
		forwards_backwards = list(EAST, WEST)
		side_to_side = list(NORTH, SOUTH)
		attempt_bridge()

	qdel(src)

/// Returns whether the passed in turf is a valid "landing". A valid landing is
/// a tile that hasn't been reserved by another bridge, and has a non-lava tile
/// leading directly to it.
/obj/effect/spawner/dynamic_bridge/proc/valid_landing(turf/T, direction)
	if(T.flags & LAVA_BRIDGE || T.flags & NO_LAVA_GEN)
		return FALSE

	var/turf/end = get_step(T, direction)
	if(end.flags & LAVA_BRIDGE || !(ismineralturf(end) || istype(end, /turf/simulated/floor/plating/asteroid)))
		return FALSE

	var/area/A = get_area(end)
	if(istype(A, /area/lavaland/surface/gulag_rock))
		return FALSE

	if(istype(A, /area/lavaland/surface/outdoors/outpost))
		return FALSE

	if(istype(A, /area/mine/outpost))
		return FALSE

	if(istype(A, /area/shuttle))
		return FALSE

	return TRUE

/obj/effect/spawner/dynamic_bridge/proc/bridgeable_turf(turf/T)
	// Pre SSlatemapping, before we've replaced mapping turfs with their river theme
	if(istype(T, /turf/simulated/floor/lava/mapping_lava))
		return TRUE
	// Everything else
	if(istype(T, /turf/simulated/floor/chasm))
		return TRUE
	if(istype(T, /turf/simulated/floor/lava))
		return TRUE

/// Returns whether the passed in turf is a valid "passage". A valid passage is
/// a lava tile that has lava on both sides of it. Invalid passage tiles do not
/// look good as bridge walkways and defeat the purpose of there is floor right
/// next to it.
/obj/effect/spawner/dynamic_bridge/proc/valid_passage(turf/T)
	if(T.flags & LAVA_BRIDGE)
		return FALSE
	if(!bridgeable_turf(T))
		return FALSE
	if(!bridgeable_turf(get_step(T, side_to_side[1])))
		return FALSE
	if(!bridgeable_turf(get_step(T, side_to_side[2])))
		return FALSE
	var/area/A = get_area(T)
	if(istype(A, /area/lavaland/surface/gulag_rock))
		return FALSE

	return TRUE

/obj/effect/spawner/dynamic_bridge/proc/make_pillar(turf/T)
	for(var/obj/structure/spawner/S in T)
		qdel(S)
	for(var/mob/living/M in T)
		qdel(M)
	for(var/obj/structure/flora/F in T)
		qdel(F)

	switch(bridge_theme)
		if(LONG_BRIDGE_THEME_CULT)
			T.ChangeTurf(/turf/simulated/wall/cult)
		if(LONG_BRIDGE_THEME_HIERO)
			T.ChangeTurf(/turf/simulated/wall/indestructible/hierophant)
		if(LONG_BRIDGE_THEME_CLOCKWORK)
			T.ChangeTurf(/turf/simulated/wall/clockwork)
		if(LONG_BRIDGE_THEME_STONE)
			T.ChangeTurf(/turf/simulated/wall/cult)
		if(LONG_BRIDGE_THEME_WOOD)
			T.ChangeTurf(/turf/simulated/wall/mineral/wood/nonmetal)
		if(LONG_BRIDGE_THEME_CATWALK)
			new /obj/structure/lattice/catwalk/mining(T)
			new /obj/structure/marker_beacon/dock_marker/collision(T)

	T.flags |= LAVA_BRIDGE

/obj/structure/bridge_walkway
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	layer = ABOVE_OPEN_TURF_LAYER
	anchored = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/bridge_walkway/Destroy()
	var/turf/T = get_turf(src)
	if(T)
		T.layer = PLATING_LAYER
		T.clear_filters()

	return ..()

/obj/structure/bridge_walkway/cult
	icon_state = "cult"

/obj/structure/bridge_walkway/hiero
	icon = 'icons/turf/floors/hierophant_floor.dmi'
	icon_state = "floor"

/obj/structure/bridge_walkway/clockwork
	name = "clockwork floor"
	icon_state = "clockwork_floor"

/obj/structure/bridge_walkway/clockwork/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_crossed)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

// Pretend to be a normal clockwork floor and duplicate its visual effect
/obj/structure/bridge_walkway/clockwork/proc/on_crossed(atom/crosser)
	var/counter = 0
	for(var/obj/effect/temp_visual/ratvar/floor/floor in contents)
		if(++counter == 3)
			return

	if(!. && isliving(crosser))
		addtimer(CALLBACK(src, PROC_REF(spawn_visual)), 0.2 SECONDS, TIMER_DELETE_ME)

/obj/structure/bridge_walkway/clockwork/proc/spawn_visual()
	new /obj/effect/temp_visual/ratvar/floor(loc)

/obj/structure/bridge_walkway/wood
	icon_state = "wood"

/obj/effect/spawner/dynamic_bridge/proc/make_walkway(turf/T)
	for(var/obj/structure/spawner/S in T)
		qdel(S)
	for(var/mob/living/M in T)
		qdel(M)
	for(var/obj/structure/flora/F in T)
		qdel(F)

	switch(bridge_theme)
		if(LONG_BRIDGE_THEME_CULT)
			new /obj/structure/bridge_walkway/cult(T)
		if(LONG_BRIDGE_THEME_HIERO)
			new /obj/structure/bridge_walkway/hiero(T)
		if(LONG_BRIDGE_THEME_CLOCKWORK)
			new /obj/structure/bridge_walkway/clockwork(T)
		if(LONG_BRIDGE_THEME_STONE)
			// Stone tiles are different sizes and shapes so these are
			// "safe-looking" arrangements.
			switch(rand(1, 5))
				if(1)
					new /obj/structure/stone_tile/block(T)
					var/obj/structure/stone_tile/block/cracked/C = new(T)
					C.dir = NORTH
				if(2)
					new /obj/structure/stone_tile/slab(T)
				if(3)
					new /obj/structure/stone_tile/surrounding(T)
					new /obj/structure/stone_tile/center(T)
				if(4)
					new /obj/structure/stone_tile/slab/cracked(T)
				if(5)
					new /obj/structure/stone_tile/burnt(T)
					var/obj/structure/stone_tile/surrounding_tile/ST = new(T)
					ST.dir = WEST
					var/obj/structure/stone_tile/block/B = new(T)
					B.dir = NORTH
		if(LONG_BRIDGE_THEME_WOOD)
			var/obj/structure/bridge_walkway/wood/tile = new(T)
			if(prob(20))
				tile.icon_state = pick("wood-broken", "wood-broken2", "wood-broken3", "wood-broken4", "wood-broken5", "wood-broken6", "wood-broken7")
		if(LONG_BRIDGE_THEME_CATWALK)
			new /obj/structure/lattice/catwalk/mining(T)

	T.flags |= LAVA_BRIDGE

/// Make a tile safe for player passage, for use at the bridge entrance and exits
/obj/effect/spawner/dynamic_bridge/proc/cleanup_edge(turf/T)
	if(bridgeable_turf(T))
		T.ChangeTurf(/turf/simulated/floor/plating/asteroid/basalt/lava_land_surface)
		T.icon_state = "basalt" // hate

/obj/effect/spawner/dynamic_bridge/proc/attempt_bridge()
	var/count = 1
	var/walk_dir = forwards_backwards[1]
	var/turf/forward_step = get_turf(src)
	var/turf/backward_step = get_turf(src)
	var/bad_passage = FALSE

	while(count <= max_length && !(forward_goal && backward_goal) && !bad_passage)
		if(walk_dir == forwards_backwards[1])
			if(!forward_goal)
				if(out_of_bounds(walk_dir, forward_step))
					break // Out of bounds
				forward_step = get_step(forward_step, walk_dir)
				if(valid_landing(forward_step, walk_dir))
					forward_goal = forward_step
				else if(!valid_passage(forward_step))
					bad_passage = TRUE
				count++
			walk_dir = forwards_backwards[2]
		else
			if(!backward_goal)
				if(out_of_bounds(walk_dir, backward_step))
					break // Out of bounds
				backward_step = get_step(backward_step, walk_dir)
				if(valid_landing(backward_step, walk_dir))
					backward_goal = backward_step
				else if(!valid_passage(backward_step))
					bad_passage = TRUE
				count++
			walk_dir = forwards_backwards[1]

	if(bad_passage)
		return BRIDGE_SPAWN_BAD_TERRAIN
	if(count < min_length)
		return BRIDGE_SPAWN_TOO_NARROW
	if(count > max_length)
		return BRIDGE_SPAWN_TOO_WIDE

	if(!bad_passage && count >= min_length && forward_goal && backward_goal)
		for(var/turf/T in get_line(forward_goal, backward_goal))
			make_walkway(T)
		for(var/turf/T in list(
				get_step(forward_goal, side_to_side[1]),
				get_step(forward_goal, side_to_side[2]),
				get_step(backward_goal, side_to_side[1]),
				get_step(backward_goal, side_to_side[2])))
			make_pillar(T)
		for(var/turf/T in get_line(
				get_step(get_step(forward_goal, side_to_side[1]), forwards_backwards[1]),
				get_step(get_step(forward_goal, side_to_side[2]), forwards_backwards[1])))
			cleanup_edge(T)
		for(var/turf/T in get_line(
				get_step(get_step(backward_goal, side_to_side[1]), forwards_backwards[2]),
				get_step(get_step(backward_goal, side_to_side[2]), forwards_backwards[2])))
			cleanup_edge(T)

		return BRIDGE_SPAWN_SUCCESS

/// Checks if we are going out of bounds. Returns TRUE if we are close (less than or equal to 2 turfs) to a border
/obj/effect/spawner/dynamic_bridge/proc/out_of_bounds(direction, turf/current_turf)
	if(!direction || !current_turf)
		return TRUE

	switch(direction)
		if(NORTH)
			return current_turf.y >= world.maxy - 2
		if(EAST)
			return current_turf.x >= world.maxx - 2
		if(SOUTH)
			return current_turf.y <= 2
		if(WEST)
			return current_turf.x <= 2
	return TRUE

/obj/effect/spawner/dynamic_bridge/capsule
	bridge_theme = LONG_BRIDGE_THEME_CATWALK

/obj/effect/spawner/dynamic_bridge/capsule/Initialize(mapload, thrown_dir)
	. = ..()
	if(thrown_dir in list(EAST, WEST))
		forwards_backwards = list(EAST, WEST)
		side_to_side = list(NORTH, SOUTH)
	else
		forwards_backwards = list(NORTH, SOUTH)
		side_to_side = list(EAST, WEST)

	return INITIALIZE_HINT_NORMAL

#undef LONG_BRIDGE_THEME_CULT
#undef LONG_BRIDGE_THEME_HIERO
#undef LONG_BRIDGE_THEME_CLOCKWORK
#undef LONG_BRIDGE_THEME_STONE
#undef LONG_BRIDGE_THEME_WOOD
#undef LONG_BRIDGE_THEME_CATWALK
