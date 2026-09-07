/**
 * Base class for all random spawners.
 */
/obj/effect/spawner/random
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "loot"
	/// Stops persistent lootdrop spawns from being shoved into lockers
	/// A list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)
	var/list/loot
	/// The subtypes AND type to combine with the loot list
	var/loot_type_path
	/// The subtypes (this excludes the provided path) to combine with the loot list
	var/loot_subtype_path
	/// How many items will be spawned
	var/spawn_loot_count = 1
	/// If the same item can be spawned twice
	var/spawn_loot_double = TRUE
	/// Whether the items should be staggered visually on their location.
	var/spawn_loot_split = FALSE
	/// The pixel x/y divider offsets for spawn_loot_split (spaced 2 pixels apart by default)
	var/spawn_loot_split_pixel_offsets = 2
	/// The placer for loot when `spawn_loot_split` is enabled
	var/datum/spawner_pixel_placer/pixel_placer
	/// Whether the spawner should spawn all the loot in the list
	var/spawn_all_loot = FALSE
	/// The chance for the spawner to create loot (ignores spawn_loot_count)
	var/spawn_loot_chance = 100
	/// Determines how big of a range (in tiles) we should scatter things in.
	var/spawn_scatter_radius = 0
	/// Whether the items should have a random pixel_x/y offset (maximum offset distance is ± spawn_random_offset_max_pixels for x/y)
	var/spawn_random_offset = FALSE
	/// Maximum offset distance for random pixel offsets.
	var/spawn_random_offset_max_pixels = 16
	/// Whether the spawned items should be rotated randomly.
	var/spawn_random_angle = FALSE
	/// Whether blackbox should record when the spawner spawns.
	var/record_spawn = FALSE
	/// Where do we want to spawn an item (closet, safe etc.)
	var/spawn_inside

// Brief explanation:
// Rather then setting up and then deleting spawners, we block all atomlike setup
// and do the absolute bare minimum
// This is with the intent of optimizing mapload
// TODO: Bring this optimization up one level if possible
/obj/effect/spawner/random/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE
	spawn_loot()
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/random/Destroy()
	. = ..()
	qdel(pixel_placer)

/obj/effect/spawner/random/proc/generate_loot_list()
	if(loot_type_path)
		loot += typesof(loot_type_path)

	if(loot_subtype_path)
		loot += subtypesof(loot_subtype_path)

	return loot

/obj/effect/spawner/random/proc/check_safe(type_path_to_make)
	return TRUE

///If the spawner has any loot defined, randomly picks some and spawns it. Does not cleanup the spawner.
/obj/effect/spawner/random/proc/spawn_loot(lootcount_override)
	if(!prob(spawn_loot_chance))
		return

	var/list/spawn_locations = get_spawn_locations(spawn_scatter_radius)
	var/spawn_loot_count = isnull(lootcount_override) ? src.spawn_loot_count : lootcount_override
	var/atom/container

	if(spawn_inside)
		container = new spawn_inside(loc)

	if(spawn_all_loot)
		spawn_loot_count = INFINITY
		spawn_loot_double = FALSE

	var/list/loot_list = generate_loot_list()
	var/safe_failure_count = 0

	if(spawn_loot_split)
		pixel_placer = new(spawn_loot_split_pixel_offsets, spawn_random_offset_max_pixels)

	if(length(loot_list))
		var/loot_spawned = 0
		while((spawn_loot_count-loot_spawned) && length(loot_list) && safe_failure_count <= 10)
			loot_spawned++
			var/lootspawn = pick_weight_recursive(loot_list)

			if(!check_safe(lootspawn))
				safe_failure_count++
				continue

			if(!spawn_loot_double)
				loot_list.Remove(lootspawn)
			if(lootspawn)
				var/turf/spawn_loc = loc
				if(spawn_scatter_radius > 0 && length(spawn_locations))
					spawn_loc = pick(spawn_locations)

				if(ispath(lootspawn, /turf))
					spawn_loc.ChangeTurf(lootspawn)
					continue

				var/atom/movable/spawned_loot = make_item(spawn_loc, lootspawn)

				// If we make something that then makes something else and gets itself
				// qdel'd, we'll have a null result here. This doesn't necessarily mean
				// that nothing's been spawned, so it's not necessarily a failure.
				if(!spawned_loot)
					continue

				spawned_loot.setDir(dir)

				if(!spawn_loot_split && !spawn_random_offset)
					if(pixel_x != 0)
						spawned_loot.pixel_x = pixel_x
					if(pixel_y != 0)
						spawned_loot.pixel_y = pixel_y
				else if(spawn_random_offset)
					spawned_loot.pixel_x = rand(-spawn_random_offset_max_pixels, spawn_random_offset_max_pixels)
					spawned_loot.pixel_y = rand(-spawn_random_offset_max_pixels, spawn_random_offset_max_pixels)
				else if(spawn_loot_split && loot_spawned)
					pixel_placer.place(spawned_loot, loot_spawned)

				if(container)
					spawned_loot.forceMove(container)

/**
 *  Makes the actual item related to our spawner. If `record_spawn` is `TRUE`,
 *  this is when the items spawned are recorded to blackbox (except for `/obj/effect`s).
 *
 * spawn_loc - where are we spawning it?
 * type_path_to_make - what are we spawning?
 **/
/obj/effect/spawner/random/proc/make_item(spawn_loc, type_path_to_make)
	var/result = new type_path_to_make(spawn_loc)

	if(record_spawn)
		record_item(type_path_to_make)

	var/atom/item = result
	if(spawn_random_angle && istype(item))
		item.transform = turn(item.transform, rand(0, 360))

	return result

/obj/effect/spawner/random/proc/record_item(type_path_to_make)
	if(ispath(type_path_to_make, /obj/effect))
		return

	SSblackbox.record_feedback("tally", "random_spawners", 1, "[type_path_to_make]")

///If the spawner has a spawn_scatter_radius set, this creates a list of nearby turfs available that are in view and have an unblocked line to them.
/obj/effect/spawner/random/proc/get_spawn_locations(radius)
	var/list/scatter_locations = list()

	if(!radius)
		return scatter_locations

	for(var/turf/turf_in_view in view(radius, get_turf(src)))
		if(!isfloorturf(turf_in_view))
			continue
		if(!has_unblocked_line(turf_in_view))
			continue

		scatter_locations += turf_in_view

	return scatter_locations

/obj/effect/spawner/random/proc/has_unblocked_line(destination)
	for(var/turf/potential_blockage as anything in get_line(get_turf(src), destination))
		if(!potential_blockage.is_blocked_turf(exclude_mobs = TRUE))
			continue
		return FALSE
	return TRUE
