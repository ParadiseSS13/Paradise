/// Keeps track of the available points for a given pool, as well as any
/// spawners that need to keep track globally of the number of any specific item
/// that they spawn.
/datum/spawn_pool
	var/id
	var/available_points = 0
	var/list/known_spawners = list()
	var/list/unique_spawners = list()
	var/list/guaranteed_spawners = list()

/datum/spawn_pool/proc/can_afford(points)
	if(available_points >= points)
		return TRUE

	return FALSE

/datum/spawn_pool/proc/consume(points)
	available_points -= points

/datum/spawn_pool/proc/process_spawners()
	log_chat_debug("spawn_pool [type] processing spawners")
	for(var/obj/effect/spawner/random/pool/spawner in guaranteed_spawners)
		spawner.spawn_loot()

	QDEL_LIST_CONTENTS(guaranteed_spawners)

	shuffle_inplace(known_spawners)
	while(length(known_spawners))
		if(available_points <= 0)
			break

		var/obj/effect/spawner/random/pool/spawner = known_spawners[length(known_spawners)]
		known_spawners.len--
		if(spawner.point_value != INFINITY && available_points < spawner.point_value)
			qdel(spawner)
			continue

		spawner.spawn_loot()
		qdel(spawner)

	log_chat_debug("ending spawner process with [available_points] pts and [length(known_spawners)] unfilled spawners")
	QDEL_LIST_CONTENTS(known_spawners)
