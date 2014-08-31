//These lists are populated in /datum/shuttle_controller/New()
//Shuttle controller is instantiated in master_controller.dm.

//shuttle moving state defines are in setup.dm

/datum/shuttle
	var/warmup_time = 0
	var/moving_status = SHUTTLE_IDLE

	var/docking_controller_tag	//tag of the controller used to coordinate docking
	var/datum/computer/file/embedded_program/docking/docking_controller	//the controller itself. (micro-controller, not game controller)

	var/arrive_time = 0	//the time at which the shuttle arrives when long jumping

/datum/shuttle/proc/short_jump(var/area/origin,var/area/destination)
	if(moving_status != SHUTTLE_IDLE) return

	//it would be cool to play a sound here
	moving_status = SHUTTLE_WARMUP
	spawn(warmup_time*10)
		if (moving_status == SHUTTLE_IDLE)
			return	//someone cancelled the launch

		move(origin, destination)
		moving_status = SHUTTLE_IDLE

/datum/shuttle/proc/long_jump(var/area/departing, var/area/destination, var/area/interim, var/travel_time, var/direction)
	//world << "shuttle/long_jump: departing=[departing], destination=[destination], interim=[interim], travel_time=[travel_time]"
	if(moving_status != SHUTTLE_IDLE) return

	//it would be cool to play a sound here
	moving_status = SHUTTLE_WARMUP
	spawn(warmup_time*10)
		if (moving_status == SHUTTLE_IDLE)
			return	//someone cancelled the launch

		move(departing, interim, direction)

		moving_status = SHUTTLE_INTRANSIT
		arrive_time = world.time + travel_time*10
		while (world.time < arrive_time)
			sleep(5)

		move(interim, destination, direction)

		moving_status = SHUTTLE_IDLE

/datum/shuttle/proc/dock()
	if (!docking_controller)
		return

	var/dock_target = current_dock_target()
	if (!dock_target)
		return

	docking_controller.initiate_docking(dock_target)

/datum/shuttle/proc/undock()
	if (!docking_controller)
		return
	docking_controller.initiate_undocking()

/datum/shuttle/proc/current_dock_target()
	return null

/datum/shuttle/proc/skip_docking_checks()
	if (!docking_controller || !current_dock_target())
		return 1	//shuttles without docking controllers or at locations without docking ports act like old-style shuttles
	return 0

//just moves the shuttle from A to B, if it can be moved
/datum/shuttle/proc/move(var/area/origin, var/area/destination, var/direction=null)

	//world << "move_shuttle() called for [shuttle_tag] leaving [origin] en route to [destination]."

	//world << "area_coming_from: [origin]"
	//world << "destination: [destination]"

	if(origin == destination)
		//world << "cancelling move, shuttle will overlap."
		return

	if (docking_controller && !docking_controller.undocked())
		docking_controller.force_undock()

	var/list/dstturfs = list()
	var/throwy = world.maxy

	for(var/turf/T in destination)
		dstturfs += T
		if(T.y < throwy)
			throwy = T.y

	for(var/turf/T in dstturfs)
		var/turf/D = locate(T.x, throwy - 1, 1)
		for(var/atom/movable/AM as mob|obj in T)
			AM.Move(D)
		if(istype(T, /turf/simulated))
			del(T)

	for(var/mob/living/carbon/bug in destination)
		bug.gib()

	for(var/mob/living/simple_animal/pest in destination)
		pest.gib()

	origin.move_contents_to(destination, direction=direction)

	for(var/mob/M in destination)
		if(M.client)
			spawn(0)
				if(M.buckled)
					M << "\red Sudden acceleration presses you into your chair!"
					shake_camera(M, 3, 1)
				else
					M << "\red The floor lurches beneath you!"
					shake_camera(M, 10, 1)
		if(istype(M, /mob/living/carbon))
			if(!M.buckled)
				M.Weaken(3)

	return

//returns 1 if the shuttle has a valid arrive time
/datum/shuttle/proc/has_arrive_time()
	return (moving_status == SHUTTLE_INTRANSIT)
