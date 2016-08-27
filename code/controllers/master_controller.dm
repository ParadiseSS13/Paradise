//simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
//It ensures master_controller.process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)
//WIP, needs lots of work still

var/global/datum/controller/game_controller/master_controller //Set in world.New()

var/global/controller_iteration = 0
var/global/last_tick_duration = 0

var/global/air_processing_killed = 0
var/global/pipe_processing_killed = 0

/datum/controller
	var/processing = 0
	var/iteration = 0
	var/processing_interval = 0

	// Dummy object to let us click it to debug while in the stat panel
	var/obj/effect/statclick/debug/statclick

/datum/controller/proc/recover() // If we are replacing an existing controller (due to a crash) we attempt to preserve as much as we can.

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
	world.tick_lag = config.Ticklag

	preloadTemplates()
	if(!config.disable_away_missions)
		createRandomZlevel()
	// Create 6 extra space levels to put space ruins on
	if(!config.disable_space_ruins)
		var/timer = start_watch()
		log_startup_progress("Creating random space levels...")
		seedRuins(level_name_to_num(EMPTY_AREA), rand(0, 3), /area/space, space_ruins_templates)
		log_startup_progress("Loaded random space levels in [stop_watch(timer)]s.")

		// We'll keep this around for the time when we finally expunge all
		// code that checks on hard-defined z positions

		// var/num_extra_space = 6
		// for(var/i = 1, i <= num_extra_space, i++)
		// 	var/zlev = space_manager.add_new_zlevel("[EMPTY_AREA] #[i]", linkage = CROSSLINKED)
		// 	seedRuins(zlev, rand(0, 3), /area/space, space_ruins_templates)

	space_manager.do_transition_setup()

	setup_objects()
	setupgenetics()
	setupfactions()
	setup_economy()

	for(var/i=0, i<max_secret_rooms, i++)
		make_mining_asteroid_secret()

	populate_spawn_points()

/datum/controller/game_controller/proc/setup_objects()
	var/watch = start_watch()
	var/count = 0
	var/overwatch = start_watch() // Overall.

	log_startup_progress("Populating asset cache...")
	populate_asset_cache()
	log_startup_progress("	Populated [asset_cache.len] assets in [stop_watch(watch)]s.")

	watch = start_watch()
	log_startup_progress("Initializing objects...")
	for(var/atom/movable/object in world)
		object.initialize()
		count++
	log_startup_progress("	Initialized [count] objects in [stop_watch(watch)]s.")

	watch = start_watch()
	count = 0
	log_startup_progress("Initializing atmospherics machinery...")
	for(var/obj/machinery/atmospherics/unary/U in machines)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()
			count++
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()
			count++
	log_startup_progress("	Initialized [count] atmospherics machines in [stop_watch(watch)]s.")

	watch = start_watch()
	count = 0
	log_startup_progress("Initializing pipe networks...")
	for(var/obj/machinery/atmospherics/machine in machines)
		machine.build_network()
		count++
	log_startup_progress("	Initialized [count] pipes in [stop_watch(watch)]s.")

	log_startup_progress("Finished object initializations in [stop_watch(overwatch)]s.")
