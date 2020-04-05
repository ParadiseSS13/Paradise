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

/datum/controller/subsystem/mapping/Recover()
	flags |= SS_NO_INIT
