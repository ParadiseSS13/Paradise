/***
 * How to use:
 * Either place the base unique_spawner in the map and define the key_override to determine which spawners belong to one another.
 * Or make a child instance of the unique_spawner and define the values there.
 *
 * When using the base version be sure to define both total_amount and max_per_spawner on at least one of the spawners of the key group.
 * A mismatch between instances of the same group between these values will lead to a runtime.
 * So either leave it empty for the rest or have the rest have the same values
***/

#define GET_KEY key_override ? key_override : type

/obj/effect/spawner/unique_spawner
	name = "unique spawner"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	/// Which path will be used to spawn.
	var/path_to_spawn
	/// How many will spawn. Set this in the map edit tool or in a child instance to set it for all the other instances.
	var/total_amount
	/// How many will spawn maximum per spawner. Set this in the map edit tool or in a child instance to set it for all the other instances.
	var/max_per_spawner
	/// The key of the group spawners this spawner belongs to. Define this for map instances if you want to link different spawners up or want to use the base version.
	var/key_override

	/// The assoc list of unique spawners. Key = key_override if defined else type, value = list of spawners with that key
	var/static/list/spawners
	/// Which spawners are chosen to spawn the objects
	var/static/list/chosen_spawners
	/// The list which holds the total_amount values for each spawner group
	var/static/list/total_amount_for_spawners
	/// The list which holds the max_per_spawner values for each spawner group
	var/static/list/max_per_spawner_for_spawners

/obj/effect/spawner/unique_spawner/Initialize(mapload)
	. = INITIALIZE_HINT_QDEL // For crash handling
	if(!mapload)
		CRASH("[src] of type [type] was made post mapload")

	var/turf/T = get_turf(src)
	if(!T)
		CRASH("Spawner placed in nullspace!")

	var/key = GET_KEY
	if(key == /obj/effect/spawner/unique_spawner) // Not allowed to use the base type as key
		CRASH("key_override was not set for [src] of type '[type]'")

	..()

	save_spawn_values(key)
	LAZYADDASSOC(spawners, key, src)

	return INITIALIZE_HINT_LATELOAD

/obj/effect/spawner/unique_spawner/LateInitialize()
	..()
	var/key = GET_KEY

	if(LAZYACCESS(spawners, key) && !LAZYACCESS(chosen_spawners, key)) // Not yet picked the spawners
		pick_spawners(key)
	var/list/CS = LAZYACCESS(chosen_spawners, key)
	if(!LAZYACCESS(CS, src)) // I'm not one of the chosen ones ;(
		qdel(src)
		return
	get_spawn_values(key)

	var/turf/T = get_turf(src)
	spawn_objects(T, CS[src])
	qdel(src)

/obj/effect/spawner/unique_spawner/Destroy()
	. = ..()
	var/key = GET_KEY
	LAZYREMOVEASSOC(chosen_spawners, key, src)
	if(!LAZYACCESS(chosen_spawners, key)) // Last instance that uses these values
		LAZYREMOVE(total_amount_for_spawners, key)
		LAZYREMOVE(max_per_spawner_for_spawners, key)

/**
 * Saves the spawn values. Will only pick the first defined version of this key
 */
/obj/effect/spawner/unique_spawner/proc/save_spawn_values(key)
	if(!isnull(total_amount))
		if(LAZYACCESS(total_amount_for_spawners, key) && total_amount_for_spawners[key] != total_amount)
			stack_trace("total_amount mismatch for type [type]. Possible duplicate total_amount definition in the map")
		else
			LAZYSET(total_amount_for_spawners, key, total_amount)
	if(!isnull(max_per_spawner))
		if(LAZYACCESS(max_per_spawner_for_spawners, key) && max_per_spawner_for_spawners[key] != max_per_spawner)
			stack_trace("max_per_spawner mismatch for type [type]. Possible duplicate total_amount definition in the map")
		else
			LAZYSET(max_per_spawner_for_spawners, key, max_per_spawner)

/**
 * Sets the spawn values to the values of the first defined instance of this key
 */
/obj/effect/spawner/unique_spawner/proc/get_spawn_values(key)
	total_amount = total_amount_for_spawners[key]
	max_per_spawner = max_per_spawner_for_spawners[key]

/obj/effect/spawner/unique_spawner/proc/spawn_objects(turf/T, amount)
	for(var/i in 1 to amount)
		new path_to_spawn(T)

/obj/effect/spawner/unique_spawner/proc/pick_spawners(key)
	var/list/pickable_spawners = spawners[key]
	LAZYSET(chosen_spawners, key, list())
	var/list/my_spawners = chosen_spawners[key]

	for(var/i in 1 to total_amount)
		if(!length(pickable_spawners))
			return // No more to pick from
		var/obj/effect/spawner/unique_spawner/S = pick(pickable_spawners)
		if(++my_spawners[S] >= max_per_spawner)
			pickable_spawners -= S

	// Clean up
	pickable_spawners.Cut()
	LAZYREMOVE(spawners, key)

// Example unique spawner
/obj/effect/spawner/unique_spawner/duck_spawn
	name = "unique rubberducky spawner"
	path_to_spawn = /obj/item/bikehorn/rubberducky
	max_per_spawner = 2
	total_amount = 5

#undef GET_KEY
