/**
  * Can be used to group spawners together so you ensure a certain amount of things are spawned but can be spawned on multiple locations.
  *
  * How to use:
  * Either place the base grouped_spawner in the map and define the group_id to
  * determine which spawners belong to one another.
  * Or make a child instance of the grouped_spawner and define the values there.
  *
  * When using the base version be sure to define both total_amount and max_per_spawner on
  * at least one of the spawners of the group.
  * A mismatch between instances of the same group between these values will lead to a runtime.
  * So either leave it empty for the rest or have the rest have the same values
**/
/obj/effect/spawner/grouped_spawner
	name = "grouped spawner"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	/// Which path will be used to spawn.
	var/path_to_spawn
	/// How many will spawn. Set this in the map edit tool or in a child instance to set it for all the other instances.
	var/total_amount
	/// How many will spawn maximum per spawner. Set this in the map edit tool or in a child instance to set it for all the other instances.
	var/max_per_spawner
	/// The id of the group this spawner belongs to. If left empty it'll use the type as id. Define this for map instances if you want to link different spawners up or want to use the base version.
	var/group_id

	/// The assoc list of grouped spawners. Key = group_id, value = list of spawners with that key
	var/static/list/spawner_groups
	/// Which spawners are chosen to spawn the objects
	var/static/list/chosen_spawners
	/// The list which holds the total_amount values for each spawner group
	var/static/list/total_amount_for_spawners
	/// The list which holds the max_per_spawner values for each spawner group
	var/static/list/max_per_spawner_for_spawners

/obj/effect/spawner/grouped_spawner/Initialize(mapload)
	. = INITIALIZE_HINT_QDEL // For crash handling
	if(!mapload)
		CRASH("[src] of type [type] was made post mapload")

	var/turf/T = get_turf(src)
	if(!T)
		CRASH("Spawner placed in nullspace!")

	if(isnull(group_id)) // Set the group_id if null
		group_id = type

	if(group_id == /obj/effect/spawner/grouped_spawner) // Not allowed to use the base type as group_id
		CRASH("group_id was not set for [src] of type '[type]'")

	..()

	save_spawn_values()
	LAZYADDASSOC(spawner_groups, group_id, src)

	return INITIALIZE_HINT_LATELOAD

/obj/effect/spawner/grouped_spawner/LateInitialize()
	..()

	if(LAZYACCESS(spawner_groups, group_id) && !LAZYACCESS(chosen_spawners, group_id)) // Not yet picked the spawners
		pick_spawners()
	var/list/CS = LAZYACCESS(chosen_spawners, group_id)
	if(!LAZYACCESS(CS, src)) // I'm not one of the chosen ones ;(
		qdel(src)
		return
	get_spawn_values()

	var/turf/T = get_turf(src)
	spawn_objects(T, CS[src])
	qdel(src)

/obj/effect/spawner/grouped_spawner/Destroy()
	. = ..()

	LAZYREMOVEASSOC(chosen_spawners, group_id, src)
	if(!LAZYACCESS(chosen_spawners, group_id)) // Last instance that uses these values
		LAZYREMOVE(total_amount_for_spawners, group_id)
		LAZYREMOVE(max_per_spawner_for_spawners, group_id)

/**
 * Saves the spawn values. Will only pick the first defined version of this group_id
 */
/obj/effect/spawner/grouped_spawner/proc/save_spawn_values()
	if(!isnull(total_amount))
		if(LAZYACCESS(total_amount_for_spawners, group_id) && total_amount_for_spawners[group_id] != total_amount)
			stack_trace("total_amount mismatch for type [type]. Possible duplicate total_amount definition in the map")
		else
			LAZYSET(total_amount_for_spawners, group_id, total_amount)
	if(!isnull(max_per_spawner))
		if(LAZYACCESS(max_per_spawner_for_spawners, group_id) && max_per_spawner_for_spawners[group_id] != max_per_spawner)
			stack_trace("max_per_spawner mismatch for type [type]. Possible duplicate total_amount definition in the map")
		else
			LAZYSET(max_per_spawner_for_spawners, group_id, max_per_spawner)

/**
 * Sets the spawn values to the values of the first defined instance of this group_id
 */
/obj/effect/spawner/grouped_spawner/proc/get_spawn_values()
	total_amount = total_amount_for_spawners[group_id]
	max_per_spawner = max_per_spawner_for_spawners[group_id]

/obj/effect/spawner/grouped_spawner/proc/spawn_objects(turf/T, amount)
	for(var/i in 1 to amount)
		new path_to_spawn(T)

/obj/effect/spawner/grouped_spawner/proc/pick_spawners()
	var/list/pickable_spawners = spawner_groups[group_id]
	LAZYSET(chosen_spawners, group_id, list())
	var/list/spawners = chosen_spawners[group_id]

	for(var/i in 1 to total_amount)
		if(!length(pickable_spawners))
			return // No more to pick from
		var/obj/effect/spawner/grouped_spawner/S = pick(pickable_spawners)
		if(++spawners[S] >= max_per_spawner)
			pickable_spawners -= S

	// Clean up
	pickable_spawners.Cut()
	LAZYREMOVE(spawner_groups, group_id)

// Example grouped spawner
/obj/effect/spawner/grouped_spawner/duck_spawn
	name = "grouped rubberducky spawner"
	path_to_spawn = /obj/item/bikehorn/rubberducky
	max_per_spawner = 2
	total_amount = 5
