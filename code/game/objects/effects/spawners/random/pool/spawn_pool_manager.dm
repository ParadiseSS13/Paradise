GLOBAL_DATUM_INIT(spawn_pool_manager, /datum/spawn_pool_manager, new)

/datum/spawn_pool_manager
	var/list/spawn_pools = list()

/datum/spawn_pool_manager/New()
	for(var/spawn_pool_type in subtypesof(/datum/spawn_pool))
		var/datum/spawn_pool/pool = new spawn_pool_type
		spawn_pools[pool.id] = pool

/datum/spawn_pool_manager/proc/get(id)
	return spawn_pools[id]

/datum/spawn_pool_manager/proc/process_pools()
	for(var/pool_id in spawn_pools)
		var/datum/spawn_pool/pool = spawn_pools[pool_id]
		pool.process_spawners()

/datum/spawn_pool_manager/Destroy()
	QDEL_LIST_CONTENTS(spawn_pools)
	return ..()
