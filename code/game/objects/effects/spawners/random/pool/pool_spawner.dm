/// A random spawner managed by a [/datum/spawn_pool].
/obj/effect/spawner/random/pool
	/// How much this spawner will subtract from the available budget if it
	/// spawns. A value of `-1` (i.e., not setting the value on a subtype)
	/// does not attempt to subtract from the budget. This is useful for
	/// spawners which themselves spawn other spawners.
	var/point_value = -1
	/// Whether non-spawner items should be removed from the shared loot pool
	/// after spawning.
	var/unique_picks = FALSE
	/// Guaranteed spawners will always proc, and always proc first.
	var/guaranteed = FALSE
	/// The type of the spawn pool.
	var/spawn_pool

/obj/effect/spawner/random/pool/Initialize(mapload)
	// short-circuit atom init machinery since we won't be around long
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	if(!spawn_pool)
		stack_trace("No spawn pool ID provided to [src]([type])")

	if(GLOB.spawn_pool_manager.finalized)
		// We've already gotten through SSlate_mapping, so someone probably spawned this manually.
		// Skip all the shit and just spawn it.
		spawn_loot()
		qdel(src)
		return INITIALIZE_HINT_QDEL

	var/datum/spawn_pool/pool = GLOB.spawn_pool_manager.get(spawn_pool)
	if(!pool)
		stack_trace("Could not find spawn pool [spawn_pool]")

	if(unique_picks && !(type in pool.unique_spawners))
		pool.unique_spawners[type] = loot.Copy()

	if(guaranteed)
		pool.guaranteed_spawners |= src
	else
		pool.known_spawners |= src

	return INITIALIZE_HINT_NORMAL

/obj/effect/spawner/random/pool/generate_loot_list()
	var/datum/spawn_pool/pool = GLOB.spawn_pool_manager.get(spawn_pool)
	if(!pool)
		stack_trace("Could not find spawn pool [spawn_pool]")

	if(unique_picks)
		var/list/unique_loot = pool.unique_spawners[type]
		return unique_loot.Copy()

	return ..()

/obj/effect/spawner/random/pool/check_safe(type_path_to_make)
	// TODO: Spawners with `spawn_all_loot` set will subtract the
	// point value for each item spawned. This needs to change so
	// that the budget is only checked once initially, and then
	// all of the loot is spawned after.
	if(!..())
		return FALSE

	var/is_safe = FALSE
	var/deduct_points = TRUE
	var/datum/spawn_pool/pool = GLOB.spawn_pool_manager.get(spawn_pool)
	if(!pool)
		stack_trace("Could not find spawn pool [spawn_pool]")

	if(ispath(type_path_to_make, /obj/effect/spawner/random/pool))
		return TRUE

	// If we're past SSlate_mapping, we're safe and don't have a pool
	// to deduct points from
	if(GLOB.spawn_pool_manager.finalized)
		is_safe = TRUE
		deduct_points = FALSE

	// If we don't have a sane point value, don't deduct points
	if(point_value == -1)
		deduct_points = FALSE

	// If we deduct points, we need to check affordability
	if(deduct_points)
		if(pool.can_afford(point_value))
			is_safe = TRUE
	else
		is_safe = TRUE

	// Early breakout if we're not safe
	if(!is_safe)
		return FALSE

	if(deduct_points)
		pool.consume(point_value)

	if(pool && unique_picks)
		// We may have multiple instances of a given type so just remove the first instance we find
		var/list/unique_spawners = pool.unique_spawners[type]
		unique_spawners.Remove(type_path_to_make)

	return TRUE
