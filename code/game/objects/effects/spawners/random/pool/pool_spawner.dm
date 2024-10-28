/// A random spawner managed by a [/datum/spawn_pool].
/obj/effect/spawner/random/pool
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "loot"
	/// How much this spawner will subtract from the available budget if it spawns.
	/// A value of `INFINITY`
	var/point_value = INFINITY
	/// Whether non-spawner items should be removed from the shared loot pool after spawning.
	var/unique_picks = FALSE
	/// If a pool spawner is guaranteed, it will always proc, and always proc first.
	var/guaranteed = FALSE
	/// The ID of the spawn pool. Must match the pool's [/datum/spawn_pool/var/id].
	var/spawn_pool_id

/obj/effect/spawner/random/pool/Initialize(mapload)
	// short-circuit atom init machinery since we won't be around long
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	if(!spawn_pool_id)
		stack_trace("No spawn pool ID provided to [src]([type])")

	var/datum/spawn_pool/pool = GLOB.spawn_pool_manager.get(spawn_pool_id)
	if(!pool)
		stack_trace("Could not find spawn pool with ID [spawn_pool_id]")

	if(unique_picks && !(type in pool.unique_spawners))
		pool.unique_spawners[type] = loot.Copy()

	if(guaranteed)
		pool.guaranteed_spawners |= src
	else
		pool.known_spawners |= src

/obj/effect/spawner/random/pool/generate_loot_list()
	var/datum/spawn_pool/pool = GLOB.spawn_pool_manager.get(spawn_pool_id)
	if(!pool)
		stack_trace("Could not find spawn pool with ID [spawn_pool_id]")

	if(unique_picks)
		var/list/unique_loot = pool.unique_spawners[type]
		return unique_loot.Copy()

	return ..()

/obj/effect/spawner/random/pool/check_safe(type_path_to_make)
	if(!..())
		return FALSE

	if(ispath(type_path_to_make, /obj/effect/spawner/random/pool))
		return TRUE

	var/datum/spawn_pool/pool = GLOB.spawn_pool_manager.get(spawn_pool_id)
	if(!pool)
		stack_trace("Could not find spawn pool with ID [spawn_pool_id]")

	if(!pool.can_afford(point_value))
		return FALSE

	pool.consume(point_value)
	log_chat_debug("type_path=[type_path_to_make] point_value=[point_value] remaining=[pool.available_points]")

	if(unique_picks)
		// We may have multiple instances of a given type so just remove the first instance we find
		var/list/unique_spawners = pool.unique_spawners[type]
		unique_spawners.Remove(type_path_to_make)

	return TRUE
