var/global/datum/zlev_manager/space_manager = new

/datum/zlev_manager
	// A list of z-levels
	var/list/z_list = list()
	var/list/levels_by_name = list()
	var/list/heaps = list()

	// Levels that need their transitions rebuilt
	var/list/unbuilt_space_transitions = list()

	var/datum/spacewalk_grid/linkage_map
	var/initialized = 0

// Populate our space level list
// and prepare space transitions
/datum/zlev_manager/proc/initialize()
	var/num_official_z_levels = map_transition_config.len
	var/k = 1

	// First take care of "Official" z levels, without visiting levels outside of the list
	for(var/list/features in map_transition_config)
		if(k > world.maxz)
			CRASH("More map attributes pre-defined than existent z levels - [num_official_z_levels]")
		var/name = features["name"]
		var/linking = features["linkage"]
		var/list/attributes = features["attributes"]
		attributes = attributes.Copy() // Clone the list so it can't be changed on accident

		var/datum/space_level/S = new /datum/space_level(k, name, transition_type = linking, traits = attributes)
		z_list["[k]"] = S
		levels_by_name[name] = S
		k++

	// Then, we take care of unmanaged z levels
	// They get the default linkage of SELFLOOPING
	for(var/i = k, i <= world.maxz, i++)
		z_list["[i]"] = new /datum/space_level(i)
	initialized = 1


/datum/zlev_manager/proc/get_zlev(z)
	if(!("[z]" in z_list))
		throw EXCEPTION("Unmanaged z level: '[z]'")
	else
		return z_list["[z]"]

/datum/zlev_manager/proc/get_zlev_by_name(A)
	if(!(A in levels_by_name))
		throw EXCEPTION("Non-existent z level: '[A]'")
	return levels_by_name[A]

/*
* "Dirt" management
* "Dirt" is used to keep track of whether a z level should automatically have
* stuff on it initialize or not - If you're loading a map, place
* a freeze on the z levels it touches so as to prevent atmos from exploding,
* among other things
*/


// Returns whether the given z level has a freeze on initialization
/datum/zlev_manager/proc/is_zlevel_dirty(z)
	var/datum/space_level/our_z = get_zlev(z)
	return (our_z.dirt_count > 0)


// Increases the dirt count on a z level
/datum/zlev_manager/proc/add_dirt(z)
	var/datum/space_level/our_z = get_zlev(z)
	if(our_z.dirt_count == 0)
		log_debug("Placing an init freeze on z-level '[our_z.zpos]'!")
	our_z.dirt_count++


// Decreases the dirt count on a z level
/datum/zlev_manager/proc/remove_dirt(z)
	var/datum/space_level/our_z = get_zlev(z)
	our_z.dirt_count--
	if(our_z.dirt_count == 0)
		our_z.resume_init()
	if(our_z.dirt_count < 0)
		log_debug("WARNING: Imbalanced dirt removal")
		our_z.dirt_count = 0

/datum/zlev_manager/proc/postpone_init(z, thing)
	var/datum/space_level/our_z = get_zlev(z)
	our_z.init_list.Add(thing)


/**
*
*	SPACE ALLOCATION
*
*/


// For when you need the z-level to be at a certain point
// Not sure if setting world.maxz at once or repeatedly incrementing makes
// a performance difference
/datum/zlev_manager/proc/increase_max_zlevel_to(new_maxz, list/name_list = null, linkage = SELFLOOPING, traits= list(BLOCK_TELEPORT))
	if(world.maxz>=new_maxz)
		return
	var/old_maxz = world.maxz
	world.maxz = new_maxz
	var/k = 1
	for(var/i from old_maxz to new_maxz)
		var/name = "Anonymous Z level #[i]"
		if(name_list && k <= name_list.len)
			name = name_list[k]
		register_zlevel(name, i, linkage, traits)

// Increments the max z-level by one
// For convenience's sake returns the z-level added
/datum/zlev_manager/proc/add_new_zlevel(name, linkage = SELFLOOPING, traits = list(BLOCK_TELEPORT))
	world.maxz++
	var/our_z = world.maxz
	register_zlevel(name, our_z, linkage = linkage, traits = traits)
	return our_z

/datum/zlev_manager/proc/register_zlevel(name, z, linkage, traits)
	if(name in levels_by_name)
		throw EXCEPTION("Name already in use: [name]")
	if("[z]" in z_list)
		throw EXCEPTION("Level already registered: '[z]'")
	var/datum/space_level/S = new /datum/space_level(our_z, name, transition_type = linkage, traits = traits.Copy())
	levels_by_name[name] = S
	z_list["[z]"] = S

/datum/zlev_manager/proc/cut_levels_downto(new_maxz)
	if(world.maxz <= new_maxz)
		return
	while(world.maxz>new_maxz)
		kill_topmost_zlevel()

// Decrements the max z-level by one
// not normally used, but hey the swapmap loader wanted it
/datum/zlev_manager/proc/kill_topmost_zlevel()
	var/our_z = world.maxz
	var/datum/space_level/S = get_zlev(our_z)
	z_list.Remove(S)
	qdel(S)
	world.maxz--


// An internally-used proc used for heap-zlevel management
/datum/zlev_manager/proc/add_new_heap()
	world.maxz++
	var/our_z = world.maxz
	var/datum/space_level/yup = new /datum/space_level/heap(our_z, traits = list(BLOCK_TELEPORT, ADMIN_LEVEL))
	z_list["[our_z]"] = yup
	levels_by_name["Heap level #[heaps.len]"] = yup
	return yup

// This is what you can call to allocate a section of space smaller than an
// entire z level - players aren't meant to explore outside of the region
// you request
//
// Since we can theoretically add as many z levels as we'd like, this should
// never fail, unless you request more space than is possible to give in a single
// z level
//
// Later, I'll add an argument to let you define the flags on the region
/datum/zlev_manager/proc/allocate_space(width, height)
	if(width > world.maxz || height > world.maxy)
		throw EXCEPTION("Too much space requested! \[[width],[height]\]")
	if(!heaps.len)
		heaps.len++
		heaps[heaps.len] = add_new_heap()
	var/datum/space_level/heap/our_heap
	var/weve_got_vacancy = FALSE
	for(our_heap in heaps)
		var/weve_got_vacancy = our_heap.request(width, height)
		if(weve_got_vacancy)
			break // We're sticking with the present value of `our_heap` - it's got room
		// This loop will also run out if no vacancies are found

	if(!weve_got_vacancy)
		heaps.len++
		heaps[heaps.len] = add_new_heap()
	our_heap.allocate(width, height)
