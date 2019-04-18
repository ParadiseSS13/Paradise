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
	setupfactions()
	setup_economy()

	populate_spawn_points()