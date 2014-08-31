//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

// Controls the emergency shuttle

var/global/datum/emergency_shuttle_controller/emergency_shuttle

/datum/emergency_shuttle_controller
	var/datum/shuttle/ferry/emergency/shuttle
	var/list/escape_pods

	var/launch_time			//the time at which the shuttle will be launched
	var/auto_recall = 0		//if set, the shuttle will be auto-recalled
	var/auto_recall_time	//the time at which the shuttle will be auto-recalled
	var/evac = 0			//1 = emergency evacuation, 0 = crew transfer
	var/wait_for_launch = 0	//if the shuttle is waiting to launch
	var/autopilot = 1		//set to 0 to disable the shuttle automatically launching

	var/deny_shuttle = 0	//allows admins to prevent the shuttle from being called
	var/departed = 0		//if the shuttle has left the station at least once


/datum/emergency_shuttle_controller/proc/process()
	if (wait_for_launch)
		if (auto_recall && world.time >= auto_recall_time)
			recall()
		if (world.time >= launch_time)	//time to launch the shuttle
			stop_launch_countdown()

			if (!shuttle.location)	//leaving from the station
				//launch the pods!
				for (var/datum/shuttle/ferry/escape_pod/pod in escape_pods)
					if (!pod.arming_controller || pod.arming_controller.armed)
						pod.launch(src)

			if (autopilot)
				shuttle.launch(src)

//called when the shuttle has arrived.
/datum/emergency_shuttle_controller/proc/shuttle_arrived()
	if (!shuttle.location)	//at station
		if (autopilot)
			set_launch_countdown(SHUTTLE_LEAVETIME)	//get ready to return

			if (evac)
				captain_announce("The Emergency Shuttle has docked with the station. You have approximately [round(estimate_launch_time()/60,1)] minutes to board the Emergency Shuttle.")
				world << sound('sound/AI/shuttledock.ogg')
			else
				captain_announce("The scheduled Crew Transfer Shuttle has docked with the station. It will depart in approximately [round(emergency_shuttle.estimate_launch_time()/60,1)] minutes.")

		//arm the escape pods
		if (evac)
			for (var/datum/shuttle/ferry/escape_pod/pod in escape_pods)
				if (pod.arming_controller)
					pod.arming_controller.arm()

//begins the launch countdown and sets the amount of time left until launch
/datum/emergency_shuttle_controller/proc/set_launch_countdown(var/seconds)
	wait_for_launch = 1
	launch_time = world.time + seconds*10

/datum/emergency_shuttle_controller/proc/stop_launch_countdown()
	wait_for_launch = 0

//calls the shuttle for an emergency evacuation
/datum/emergency_shuttle_controller/proc/call_evac()
	if(!can_call()) return 0

	//set the launch timer
	autopilot = 1
	set_launch_countdown(get_shuttle_prep_time())
	auto_recall_time = rand(world.time + 300, launch_time - 300)

	//reset the shuttle transit time if we need to
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION

	evac = 1
	captain_announce("An emergency evacuation shuttle has been called. It will arrive in approximately [round(estimate_arrival_time()/60)] minutes.")
	world << sound('sound/AI/shuttlecalled.ogg')
	for(var/area/A in world)
		if(istype(A, /area/hallway))
			A.readyalert()

	return 1

//calls the shuttle for a routine crew transfer
/datum/emergency_shuttle_controller/proc/call_transfer()
	if(!can_call()) return

	//set the launch timer
	autopilot = 1
	set_launch_countdown(get_shuttle_prep_time())
	auto_recall_time = rand(world.time + 300, launch_time - 300)

	//reset the shuttle transit time if we need to
	shuttle.move_time = SHUTTLE_TRANSIT_DURATION

	captain_announce("A crew transfer has been scheduled. The shuttle has been called. It will arrive in approximately [round(estimate_arrival_time()/60)] minutes.")

//recalls the shuttle
/datum/emergency_shuttle_controller/proc/recall()
	if (!can_recall()) return

	wait_for_launch = 0
	shuttle.cancel_launch(src)

	if (evac)
		captain_announce("The emergency shuttle has been recalled.")
		world << sound('sound/AI/shuttlerecalled.ogg')

		for(var/area/A in world)
			if(istype(A, /area/hallway))
				A.readyreset()
		evac = 0
	else
		captain_announce("The scheduled crew transfer has been cancelled.")

/datum/emergency_shuttle_controller/proc/can_call()
	if (deny_shuttle)
		return 0
	if (shuttle.moving_status != SHUTTLE_IDLE || !shuttle.location)	//must be idle at centcom
		return 0
	if (wait_for_launch)	//already launching
		return 0
	return 1

//this only returns 0 if it would absolutely make no sense to recall
//e.g. the shuttle is already at the station or wasn't called to begin with
//other reasons for the shuttle not being recallable should be handled elsewhere
/datum/emergency_shuttle_controller/proc/can_recall()
	if (shuttle.moving_status == SHUTTLE_INTRANSIT)	//if the shuttle is already in transit then it's too late
		return 0
	if (!shuttle.location)	//already at the station.
		return 0
	if (!wait_for_launch)	//we weren't going anywhere, anyways...
		return 0
	return 1

/datum/emergency_shuttle_controller/proc/get_shuttle_prep_time()
	// During mutiny rounds, the shuttle takes longer. Unless of course the directive is finished.
	if(!ticker) return SHUTTLE_PREPTIME
	var/datum/game_mode/mutiny/m = ticker.mode
	if(istype(m) && !m.ead.activated)
		return SHUTTLE_PREPTIME * 3		//15 minutes

	return SHUTTLE_PREPTIME


/*
	These procs are not really used by the controller itself, but are for other parts of the
	game whose logic depends on the emergency shuttle.
*/

//returns 1 if the shuttle is docked at the station and waiting to leave
/datum/emergency_shuttle_controller/proc/waiting_to_leave()
	if (shuttle.location)
		return 0	//not at station
	return (wait_for_launch || shuttle.moving_status != SHUTTLE_INTRANSIT)

//so we don't have emergency_shuttle.shuttle.location everywhere
/datum/emergency_shuttle_controller/proc/location()
	if (!shuttle)
		return 1 	//if we dont have a shuttle datum, just act like it's at centcom
	return shuttle.location

//returns the time left until the shuttle arrives at it's destination, in seconds
/datum/emergency_shuttle_controller/proc/estimate_arrival_time()
	var/eta
	if (shuttle.has_arrive_time())
		//we are in transition and can get an accurate ETA
		eta = shuttle.arrive_time
	else
		//otherwise we need to estimate the arrival time using the scheduled launch time
		eta = launch_time + shuttle.move_time*10 + shuttle.warmup_time*10
	return (eta - world.time)/10

//returns the time left until the shuttle launches, in seconds
/datum/emergency_shuttle_controller/proc/estimate_launch_time()
	return (launch_time - world.time)/10

/datum/emergency_shuttle_controller/proc/has_eta()
	return (wait_for_launch || shuttle.moving_status != SHUTTLE_IDLE)

//returns 1 if the shuttle has gone to the station and come back at least once,
//used for game completion checking purposes
/datum/emergency_shuttle_controller/proc/returned()
	return (departed && shuttle.moving_status == SHUTTLE_IDLE && shuttle.location)	//we've gone to the station at least once, no longer in transit and are idle back at centcom

//returns 1 if the shuttle is not idle at centcom
/datum/emergency_shuttle_controller/proc/online()
	if (!shuttle.location)	//not at centcom
		return 1
	if (wait_for_launch || shuttle.moving_status != SHUTTLE_IDLE)
		return 1
	return 0

//returns 1 if the shuttle is currently in transit (or just leaving) to the station
/datum/emergency_shuttle_controller/proc/going_to_station()
	return (!shuttle.direction && shuttle.moving_status != SHUTTLE_IDLE)

//returns 1 if the shuttle is currently in transit (or just leaving) to centcom
/datum/emergency_shuttle_controller/proc/going_to_centcom()
	return (shuttle.direction && shuttle.moving_status != SHUTTLE_IDLE)


/datum/emergency_shuttle_controller/proc/get_status_panel_eta()
	if (online())
		if (shuttle.has_arrive_time())
			var/timeleft = emergency_shuttle.estimate_arrival_time()
			return "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"

		if (waiting_to_leave())
			if (shuttle.moving_status == SHUTTLE_WARMUP)
				return "Departing..."

			var/timeleft = emergency_shuttle.estimate_launch_time()
			return "ETD-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"

	return ""
/*
	Some slapped-together star effects for maximum spess immershuns. Basically consists of a
	spawner, an ender, and bgstar. Spawners create bgstars, bgstars shoot off into a direction
	until they reach a starender.
*/

/obj/effect/bgstar
	name = "star"
	var/speed = 10
	var/direction = SOUTH
	layer = 2 // TURF_LAYER

/obj/effect/bgstar/New()
	..()
	pixel_x += rand(-2,30)
	pixel_y += rand(-2,30)
	var/starnum = pick("1", "1", "1", "2", "3", "4")

	icon_state = "star"+starnum

	speed = rand(2, 5)

/obj/effect/bgstar/proc/startmove()

	while(src)
		sleep(speed)
		step(src, direction)
		for(var/obj/effect/starender/E in loc)
			del(src)


/obj/effect/starender
	invisibility = 101

/obj/effect/starspawner
	invisibility = 101
	var/spawndir = SOUTH
	var/spawning = 0

/obj/effect/starspawner/West
	spawndir = WEST

/obj/effect/starspawner/proc/startspawn()
	spawning = 1
	while(spawning)
		sleep(rand(2, 30))
		var/obj/effect/bgstar/S = new/obj/effect/bgstar(locate(x,y,z))
		S.direction = spawndir
		spawn()
			S.startmove()
