// old deprecated rusted piece of shit MC
// All this does now is misc. world init stuff because too lazy to put it somewhere else
// It used to run all of the repeating processes controlling the game but now the SMC and Process Scheduler do that

var/global/datum/controller/game_controller/master_controller //Set in world.New()

var/global/controller_iteration = 0
var/global/last_tick_duration = 0

var/global/air_processing_killed = 0
var/global/pipe_processing_killed = 0

/datum/controller/game_controller
	var/list/shuttle_list											// For debugging and VV

/datum/controller/game_controller/New()
	//There can be only one master_controller. Out with the old and in with the new.
	if(master_controller != src)
		if(istype(master_controller))
			qdel(master_controller)
		master_controller = src

	var/watch=0
	if(!job_master)
		watch = start_watch()
		job_master = new /datum/controller/occupations()
		job_master.SetupOccupations()
		job_master.LoadJobs("config/jobs.txt")
		log_startup_progress("Job setup complete in [stop_watch(watch)]s.")

	if(!syndicate_code_phrase)		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)	syndicate_code_response	= generate_code_phrase()

/datum/controller/game_controller/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

/datum/controller/game_controller/proc/setup()
	preloadTemplates()
	if(!config.disable_away_missions)
		createRandomZlevel()
	// Create 6 extra space levels to put space ruins on
	if(!config.disable_space_ruins)
		var/timer = start_watch()
		log_startup_progress("Creating random space levels...")
		seedRuins(level_name_to_num(EMPTY_AREA), rand(0, 3), /area/space, space_ruins_templates)
		log_startup_progress("Loaded random space levels in [stop_watch(timer)]s.")

		// load in extra levels of space ruins

		var/num_extra_space = rand(config.extra_space_ruin_levels_min, config.extra_space_ruin_levels_max)
		for(var/i = 1, i <= num_extra_space, i++)
			var/zlev = space_manager.add_new_zlevel("[EMPTY_AREA] #[i]", linkage = CROSSLINKED)
			seedRuins(zlev, rand(0, 3), /area/space, space_ruins_templates)

	space_manager.do_transition_setup()

	setupfactions()
	setup_economy()

	for(var/i=0, i<max_secret_rooms, i++)
		make_mining_asteroid_secret()

	populate_spawn_points()