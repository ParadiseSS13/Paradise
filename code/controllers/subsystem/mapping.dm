SUBSYSTEM_DEF(mapping)
   	name = "Mapping"
   	init_order = INIT_ORDER_MAPPING // 9
   	flags = SS_NO_FIRE

/datum/controller/subsystem/mapping/Initialize(timeofday)
	// Load all Z level templates
	preloadTemplates()
	// Pick a random away mission.
	if(!config.disable_away_missions)
		createRandomZlevel()
	// Seed space ruins
	if(!config.disable_space_ruins)
		var/timer = start_watch()
		log_startup_progress("Creating random space levels...")
		seedRuins(list(level_name_to_num(EMPTY_AREA)), rand(0, 3), /area/space, GLOB.space_ruins_templates)
		log_startup_progress("Loaded random space levels in [stop_watch(timer)]s.")

		// load in extra levels of space ruins

		var/num_extra_space = rand(config.extra_space_ruin_levels_min, config.extra_space_ruin_levels_max)
		for(var/i = 1, i <= num_extra_space, i++)
			var/zlev = GLOB.space_manager.add_new_zlevel("[EMPTY_AREA] #[i]", linkage = CROSSLINKED, traits = list(REACHABLE))
			seedRuins(list(zlev), rand(0, 3), /area/space, GLOB.space_ruins_templates)

	// Setup the Z-level linkage
	GLOB.space_manager.do_transition_setup()

	// Spawn Lavaland ruins and rivers.
	seedRuins(list(level_name_to_num(MINING)), config.lavaland_budget, /area/lavaland/surface/outdoors/unexplored, GLOB.lava_ruins_templates)
	spawn_rivers(list(level_name_to_num(MINING)))

	return ..()


/datum/controller/subsystem/mapping/proc/seedRuins(list/z_levels = null, budget = 0, whitelist = /area/space, list/potentialRuins)
	if(!z_levels || !z_levels.len)
		WARNING("No Z levels provided - Not generating ruins")
		return

	for(var/zl in z_levels)
		var/turf/T = locate(1, 1, zl)
		if(!T)
			WARNING("Z level [zl] does not exist - Not generating ruins")
			return

	var/list/ruins = potentialRuins.Copy()

	var/list/forced_ruins = list()		//These go first on the z level associated (same random one by default)
	var/list/ruins_availible = list()	//we can try these in the current pass
	var/forced_z	//If set we won't pick z level and use this one instead.

	//Set up the starting ruin list
	for(var/key in ruins)
		var/datum/map_template/ruin/R = ruins[key]
		if(R.cost > budget) //Why would you do that
			continue
		if(R.always_place)
			forced_ruins[R] = -1
		if(R.unpickable)
			continue
		ruins_availible[R] = R.placement_weight

	while(budget > 0 && (ruins_availible.len || forced_ruins.len))
		var/datum/map_template/ruin/current_pick
		var/forced = FALSE
		if(forced_ruins.len) //We have something we need to load right now, so just pick it
			for(var/ruin in forced_ruins)
				current_pick = ruin
				if(forced_ruins[ruin] > 0) //Load into designated z
					forced_z = forced_ruins[ruin]
				forced = TRUE
				break
		else //Otherwise just pick random one
			current_pick = pickweight(ruins_availible)

		var/placement_tries = PLACEMENT_TRIES
		var/failed_to_place = TRUE
		var/z_placed = 0
		while(placement_tries > 0)
			placement_tries--
			z_placed = pick(z_levels)
			if(!current_pick.try_to_place(forced_z ? forced_z : z_placed,whitelist))
				continue
			else
				failed_to_place = FALSE
				break

		//That's done remove from priority even if it failed
		if(forced)
			//TODO : handle forced ruins with multiple variants
			forced_ruins -= current_pick
			forced = FALSE

		if(failed_to_place)
			for(var/datum/map_template/ruin/R in ruins_availible)
				if(R.id == current_pick.id)
					ruins_availible -= R
			log_world("Failed to place [current_pick.name] ruin.")
		else
			budget -= current_pick.cost
			if(!current_pick.allow_duplicates)
				for(var/datum/map_template/ruin/R in ruins_availible)
					if(R.id == current_pick.id)
						ruins_availible -= R
			if(current_pick.never_spawn_with)
				for(var/blacklisted_type in current_pick.never_spawn_with)
					for(var/possible_exclusion in ruins_availible)
						if(istype(possible_exclusion,blacklisted_type))
							ruins_availible -= possible_exclusion
		forced_z = 0

		//Update the availible list
		for(var/datum/map_template/ruin/R in ruins_availible)
			if(R.cost > budget)
				ruins_availible -= R

	log_world("Ruin loader finished with [budget] left to spend.")

/datum/controller/subsystem/mapping/Recover()
	flags |= SS_NO_INIT
