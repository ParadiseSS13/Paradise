GLOBAL_DATUM_INIT(spawn_pool_manager, /datum/spawn_pool_manager, new)

/// The singleton which keeps track of all spawn pools.
/// All known [/datum/spawn_pool] subtypes are registered
/// to it and are processed in SSlate_mapping.
/datum/spawn_pool_manager
	var/list/spawn_pools = list()
	var/finalized = FALSE

/datum/spawn_pool_manager/New()
	for(var/spawn_pool_type in subtypesof(/datum/spawn_pool))
		var/datum/spawn_pool/pool = new spawn_pool_type
		spawn_pools[spawn_pool_type] = pool

/datum/spawn_pool_manager/proc/get(spawn_pool)
	return spawn_pools[spawn_pool]

/datum/spawn_pool_manager/proc/process_pools()
	for(var/pool_id in spawn_pools)
		var/datum/spawn_pool/pool = spawn_pools[pool_id]
		pool.process_spawners()

	finalized = TRUE

/datum/spawn_pool_manager/Destroy()
	QDEL_LIST_CONTENTS(spawn_pools)
	return ..()
