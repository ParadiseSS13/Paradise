/// Keeps track of the available points for a given pool, as well as any
/// spawners that need to keep track globally of the number of any specific item
/// that they spawn.
/datum/spawn_pool
	/// The number of points left for the spawner to use. Starts at its initial value.
	var/available_points = 0
	/// A list of all spawners registered to this pool.
	var/list/known_spawners = list()
	/// A key-value list of spawners with TRUE `unique_picks` to a shared copy of their
	/// loot pool. When items from one of these spawners are spawned, it is removed
	/// from the shared loot pool so it never spawns again.
	var/list/unique_spawners = list()
	/// A list of spawners whose `guaranteed` is `TRUE`. These spawners will
	/// always spawn, and always before anything else,
	var/list/guaranteed_spawners = list()

/datum/spawn_pool/proc/can_afford(points)
	if(available_points >= points)
		return TRUE

	return FALSE

/datum/spawn_pool/proc/consume(points)
	available_points -= points

/datum/spawn_pool/proc/process_guaranteed_spawners()
	shuffle_inplace(guaranteed_spawners)
	while(length(guaranteed_spawners))
		var/obj/effect/spawner/random/pool/spawner = guaranteed_spawners[length(guaranteed_spawners)]
		guaranteed_spawners.len--
		spawner.spawn_loot()
		qdel(spawner)

	QDEL_LIST_CONTENTS(guaranteed_spawners)

/datum/spawn_pool/proc/process_spawners()
	process_guaranteed_spawners()

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
		if(length(guaranteed_spawners))
			WARNING("non-guaranteed spawner [spawner.type] spawned a guaranteed spawner, this should be avoided")
			process_guaranteed_spawners()

		qdel(spawner)

	log_game("finished spawner [type] with [length(known_spawners)] remaining spawners and [available_points] points remaining.")

	QDEL_LIST_CONTENTS(known_spawners)
