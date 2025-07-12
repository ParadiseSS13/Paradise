GLOBAL_DATUM_INIT(space_manager, /datum/zlev_manager, new())

/datum/zlev_manager
	// A list of z-levels
	var/list/z_list = list()
	var/list/levels_by_name = list()
	var/list/heaps = list()

	// Levels that need their transitions rebuilt
	var/list/unbuilt_space_transitions = list()

	var/list/linkage_maps = list()
	var/initialized = 0

	var/list/areas_in_z = list()

// Populate our space level list
// and prepare space transitions
/datum/zlev_manager/proc/initialize()
	var/num_official_z_levels = length(GLOB.map_transition_config)
	var/k = 1

	// First take care of "Official" z levels, without visiting levels outside of the list
	for(var/list/features in GLOB.map_transition_config)
		if(k > world.maxz)
			CRASH("More map attributes pre-defined than existent z levels - [num_official_z_levels]")
		var/name = features["name"]
		var/linking = features["linkage"]
		var/list/attributes = features["attributes"]
		attributes = attributes.Copy() // Clone the list so it can't be changed on accident

		milla_init_z(k)
		var/datum/space_level/S = new /datum/space_level(k, name, transition_type = linking, traits = attributes)
		z_list["[k]"] = S
		levels_by_name[name] = S
		k++

	// Then, we take care of unmanaged z levels
	// They get the default linkage of SELFLOOPING
	for(var/i = k, i <= world.maxz, i++)
		milla_init_z(k)
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
/datum/zlev_manager/proc/increase_max_zlevel_to(new_maxz)
	if(world.maxz>=new_maxz)
		return
	while(world.maxz<new_maxz)
		add_new_zlevel("Anonymous Z level [world.maxz]")

// Increments the max z-level by one
// For convenience's sake returns the z-level added
/datum/zlev_manager/proc/add_new_zlevel(name, linkage = SELFLOOPING, traits = list(BLOCK_TELEPORT), transition_tag, level_type = /datum/space_level)
	if(name in levels_by_name)
		throw EXCEPTION("Name already in use: [name]")
	world.maxz++
	SSai_controllers.on_max_z_changed()
	var/our_z = world.maxz
	milla_init_z(our_z)
	var/datum/space_level/S = new level_type(our_z, name, transition_type = linkage, traits = traits, transition_tag_ = transition_tag)
	levels_by_name[name] = S
	z_list["[our_z]"] = S
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NEW_Z, name, linkage, traits, transition_tag, level_type, our_z)
	return our_z

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
