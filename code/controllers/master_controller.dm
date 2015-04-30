//simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
//It ensures master_controller.process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)
//WIP, needs lots of work still

var/global/datum/controller/game_controller/master_controller //Set in world.New()

var/global/controller_iteration = 0
var/global/last_tick_duration = 0

var/global/air_processing_killed = 0
var/global/pipe_processing_killed = 0

datum/controller/game_controller
	var/breather_ticks = 2		//a somewhat crude attempt to iron over the 'bumps' caused by high-cpu use by letting the MC have a breather for this many ticks after every loop
	var/minimum_ticks = 20		//The minimum length of time between MC ticks

	var/air_cost 		= 0
	var/sun_cost		= 0
	var/mobs_cost		= 0
	var/diseases_cost	= 0
	var/machines_cost	= 0
	var/aibots_cost     = 0
	var/objects_cost	= 0
	var/networks_cost	= 0
	var/powernets_cost	= 0
	var/nano_cost		= 0
	var/events_cost		= 0
	var/puddles_cost
	var/ticker_cost		= 0
	var/garbageCollectorCost = 0
	var/total_cost		= 0

	var/last_thing_processed

	var/list/shuttle_list	                    // For debugging and VV
	var/datum/ore_distribution/asteroid_ore_map // For debugging and VV.

	var/global/datum/garbage_collector/garbageCollector

datum/controller/game_controller/New()
	//There can be only one master_controller. Out with the old and in with the new.
	if(master_controller != src)
		if(istype(master_controller))
			Recover()
			qdel(master_controller)
		master_controller = src

	if(!job_master)
		job_master = new /datum/controller/occupations()
		job_master.SetupOccupations()
		job_master.LoadJobs("config/jobs.txt")
		world << "\red \b Job setup complete"

	if(!syndicate_code_phrase)		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)	syndicate_code_response	= generate_code_phrase()
	//if(!emergency_shuttle)			emergency_shuttle = new /datum/emergency_shuttle_controller()	MOVED TO SCHEDULER
	//if(!shuttle_controller)			shuttle_controller = new /datum/shuttle_controller()

datum/controller/game_controller/proc/setup()
	world.tick_lag = config.Ticklag

	spawn(20)
		createRandomZlevel()

	/* MOVED TO SCHEDULER
	if(!air_master)
		air_master = new /datum/controller/air_system()
		air_master.Setup()

	if(!ticker)
		ticker = new /datum/controller/gameticker()
	*/


	color_windows_init()
	setup_objects()
	setupgenetics()
	setupfactions()
	setup_economy()
	SetupXenoarch()

	for(var/i=0, i<max_secret_rooms, i++)
		make_mining_asteroid_secret()

	populate_spawn_points()

/* MOVED TO SCHEDULER

	spawn(0)
		if(ticker)
			ticker.pregame()

	lighting_controller.Initialize()
*/

datum/controller/game_controller/proc/setup_objects()
	world << "\red \b Initializing objects"
	sleep(-1)
	for(var/atom/movable/object in world)
		object.initialize()

	world << "\red \b Initializing pipe networks"
	sleep(-1)
	for(var/obj/machinery/atmospherics/machine in machines)
		machine.build_network()

	world << "\red \b Initializing atmos machinery."
	sleep(-1)
	for(var/obj/machinery/atmospherics/unary/U in machines)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()

	//Create the mining ore distribution map.
	asteroid_ore_map = new /datum/ore_distribution()
	asteroid_ore_map.populate_distribution_map()


	//Set up roundstart seed list.
	populate_seed_list()

	world << "\red \b Initializations complete."
	sleep(-1)


datum/controller/game_controller/proc/process()
	processing = 1
	spawn(0)
		//set background = 1
		while(1)	//far more efficient than recursively calling ourself
			if(!failsafe)	new /datum/controller/failsafe()


			if(processing)
				var/timer
				var/start_time = world.timeofday
				controller_iteration++

				vote.process()
//				transfer_controller.process()
				shuttle_controller.process()
				process_newscaster()

				//AIR

				if(!air_processing_killed)
					timer = world.timeofday
					last_thing_processed = air_master.type

					air_master.current_cycle++
//					if(!air_master.tick()) Runtimed.
					if(!air_master.process())
						air_master.failed_ticks++
						if(air_master.failed_ticks > 5)
							world << "<font color='red'><b>RUNTIMES IN ATMOS TICKER.  Killing air simulation!</font></b>"
							world.log << "### LINDA SHUTDOWN"
							message_admins("LINDAALERT: unable to run [air_master.tick_progress], shutting down!")
							log_admin("LINDAALERT: unable run zone/process() -- [air_master.tick_progress]")
							air_processing_killed = 1
							air_master.failed_ticks = 0
				air_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//SUN
				timer = world.timeofday
				last_thing_processed = sun.type
				sun.calc_position()
				sun_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//MOBS
				timer = world.timeofday
				processMobs()
				mobs_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//MACHINES
				timer = world.timeofday
				processMachines()
				machines_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//BOTS
				timer = world.timeofday
				process_bots()
				aibots_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//OBJECTS
				timer = world.timeofday
				processObjects()
				objects_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//PIPENETS
				if(!pipe_processing_killed)
					timer = world.timeofday
					processPipenets()
					networks_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//POWERNETS
				timer = world.timeofday
				processPowernets()
				powernets_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//NANO UIS
				timer = world.timeofday
				processNano()
				nano_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//EVENTS
				timer = world.timeofday
				processEvents()
				events_cost = (world.timeofday - timer) / 10

/*
				//PUDDLES
				timer = world.timeofday
				processPuddles()
				puddles_cost = (world.timeofday - timer) / 10
*/

				//TICKER
				timer = world.timeofday
				last_thing_processed = ticker.type
				ticker.process()
				ticker_cost = (world.timeofday - timer) / 10

				// GC
				timer = world.timeofday
				last_thing_processed = garbageCollector.type
				garbageCollector.process()
				garbageCollectorCost = (world.timeofday - timer) / 10

				//TIMING
				total_cost = air_cost + sun_cost + mobs_cost + diseases_cost + machines_cost + aibots_cost + objects_cost + networks_cost + powernets_cost + nano_cost + events_cost + puddles_cost + ticker_cost + garbageCollectorCost

				var/end_time = world.timeofday
				if(end_time < start_time)	//why not just use world.time instead?
					start_time -= 864000    //deciseconds in a day
				sleep( round(minimum_ticks - (end_time - start_time),1) )
			else
				sleep(10)

/datum/controller/game_controller/proc/processMobs()
	for (var/mob/Mob in mob_list)
		if (Mob)
			last_thing_processed = Mob.type
			Mob.Life()
			continue

		mob_list = mob_list - Mob



/datum/controller/game_controller/proc/processMachines()
	for (var/obj/machinery/Machinery in machines)
		if (Machinery && Machinery.loc)
			last_thing_processed = Machinery.type

			if(Machinery.process() != PROCESS_KILL)
				if (Machinery) // Why another check?
					if (Machinery.use_power)
						Machinery.auto_use_power()

					continue

		if(Machinery) Machinery.removeAtProcessing()

/datum/controller/game_controller/proc/process_bots()
	for(var/obj/machinery/bot/Bot in aibots)
		if(!Bot.gc_destroyed)
			last_thing_processed = Bot.type
			spawn(0)
				Bot.bot_process()
			continue
		aibots -= Bot

/datum/controller/game_controller/proc/processObjects()
	for (var/obj/Object in processing_objects)
		if (Object && Object.loc)
			last_thing_processed = Object.type
			Object.process()
			continue

		processing_objects -= Object

/datum/controller/game_controller/proc/processPipenets()
	last_thing_processed = /datum/pipe_network

	for (var/datum/pipe_network/Pipe_Network in pipe_networks)
		if(Pipe_Network)
			Pipe_Network.process()
			continue

		pipe_networks -= Pipe_Network

/datum/controller/game_controller/proc/processPowernets()
	last_thing_processed = /datum/powernet

	for (var/datum/powernet/Powernet in powernets)
		if (Powernet)
			Powernet.reset()
			continue

		powernets -= Powernet

/datum/controller/game_controller/proc/processNano()
	last_thing_processed = /datum/nanoui
	for (var/datum/nanoui/Nanoui in nanomanager.processing_uis)
		if (Nanoui)
			Nanoui.process()
			continue

		nanomanager.processing_uis -= Nanoui

/datum/controller/game_controller/proc/processEvents()
	last_thing_processed = /datum/event
	event_manager.process()


/*
/datum/controller/game_controller/proc/processPuddles()
	last_thing_processed = /datum/puddle

	for (var/datum/puddle/Puddle in puddles)
		if (Puddle)
			Puddle.process()
			continue
*/

datum/controller/game_controller/proc/Recover()		//Mostly a placeholder for now.
	var/msg = "## DEBUG: [time2text(world.timeofday)] MC restarted. Reports:\n"
	for(var/varname in master_controller.vars)
		switch(varname)
			if("tag","bestF","type","parent_type","vars")	continue
			else
				var/varval = master_controller.vars[varname]
				if(istype(varval,/datum))
					var/datum/D = varval
					msg += "\t [varname] = [D.type]\n"
				else
					msg += "\t [varname] = [varval]\n"
	world.log << msg

