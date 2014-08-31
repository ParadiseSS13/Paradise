#define IDLE_STATE		0
#define WAIT_LAUNCH		1
#define WAIT_ARRIVE		2
#define WAIT_FINISH		3

#define DOCK_ATTEMPT_TIMEOUT 200	//how long in ticks we wait before assuming the docking controller is broken or blown up.

/datum/shuttle/ferry
	var/location = 0	//0 = at area_station, 1 = at area_offsite
	var/direction = 0	//0 = going to station, 1 = going to offsite.
	var/process_state = IDLE_STATE

	var/in_use = null	//tells the controller whether this shuttle needs processing

	var/area_transition
	var/move_time = 0		//the time spent in the transition area
	var/transit_direction = null	//needed for area/move_contents_to() to properly handle shuttle corners - not exactly sure how it works.

	var/area_station
	var/area_offsite
	//TODO: change location to a string and use a mapping for area and dock targets.
	var/dock_target_station
	var/dock_target_offsite
	
	var/last_dock_attempt_time = 0

/datum/shuttle/ferry/short_jump(var/area/origin,var/area/destination)
	if(isnull(location))
		return

	if(!destination)
		destination = get_location_area(!location)
	if(!origin)
		origin = get_location_area(location)

	direction = !location
	..(origin, destination)

/datum/shuttle/ferry/long_jump(var/area/departing, var/area/destination, var/area/interim, var/travel_time, var/direction)
	//world << "shuttle/ferry/long_jump: departing=[departing], destination=[destination], interim=[interim], travel_time=[travel_time]"
	if(isnull(location))
		return

	if(!destination)
		destination = get_location_area(!location)
	if(!departing)
		departing = get_location_area(location)

	direction = !location
	..(departing, destination, interim, travel_time, direction)

/datum/shuttle/ferry/move(var/area/origin,var/area/destination)
	..(origin, destination)

	if (destination == area_station) location = 0
	if (destination == area_offsite) location = 1
	//if this is a long_jump retain the location we were last at until we get to the new one

/datum/shuttle/ferry/dock()
	..()
	last_dock_attempt_time = world.time

/datum/shuttle/ferry/proc/get_location_area(location_id = null)
	if (isnull(location_id))
		location_id = location

	if (!location_id)
		return area_station
	return area_offsite

/datum/shuttle/ferry/proc/process()
	switch(process_state)
		if (WAIT_LAUNCH)
			if (skip_docking_checks() || docking_controller.can_launch())

				//world << "shuttle/ferry/process: area_transition=[area_transition], travel_time=[travel_time]"
				if (move_time && area_transition)
					long_jump(interim=area_transition, travel_time=move_time, direction=transit_direction)
				else
					short_jump()

				process_state = WAIT_ARRIVE
		if (WAIT_ARRIVE)
			if (moving_status == SHUTTLE_IDLE)
				dock()
				in_use = null	//release lock
				process_state = WAIT_FINISH
		if (WAIT_FINISH)
			if (skip_docking_checks() || docking_controller.docked() || world.time > last_dock_attempt_time + DOCK_ATTEMPT_TIMEOUT)
				process_state = IDLE_STATE
				arrived()

/datum/shuttle/ferry/current_dock_target()
	var/dock_target
	if (!location)	//station
		dock_target = dock_target_station
	else
		dock_target = dock_target_offsite
	return dock_target


/datum/shuttle/ferry/proc/launch(var/user)
	if (!can_launch()) return

	in_use = user	//obtain an exclusive lock on the shuttle

	process_state = WAIT_LAUNCH
	undock()

/datum/shuttle/ferry/proc/force_launch(var/user)
	if (!can_force()) return

	in_use = user	//obtain an exclusive lock on the shuttle

	if (move_time && area_transition)
		long_jump(interim=area_transition, travel_time=move_time, direction=transit_direction)
	else
		short_jump()


	process_state = WAIT_ARRIVE

/datum/shuttle/ferry/proc/cancel_launch(var/user)
	if (!can_cancel()) return

	moving_status = SHUTTLE_IDLE
	process_state = WAIT_FINISH
	in_use = null

	if (docking_controller && !docking_controller.undocked())
		docking_controller.force_undock()

	spawn(10)
		dock()

	return

/datum/shuttle/ferry/proc/can_launch()
	if (moving_status != SHUTTLE_IDLE)
		return 0

	if (in_use)
		return 0

	return 1

/datum/shuttle/ferry/proc/can_force()
	if (moving_status == SHUTTLE_IDLE && process_state == WAIT_LAUNCH)
		return 1
	return 0

/datum/shuttle/ferry/proc/can_cancel()
	if (moving_status == SHUTTLE_WARMUP || process_state == WAIT_LAUNCH)
		return 1
	return 0

//returns 1 if the shuttle is getting ready to move, but is not in transit yet
/datum/shuttle/ferry/proc/is_launching()
	return (moving_status == SHUTTLE_WARMUP || process_state == WAIT_LAUNCH)	

//This gets called when the shuttle finishes arriving at it's destination
//This can be used by subtypes to do things when the shuttle arrives.
/datum/shuttle/ferry/proc/arrived()
	return	//do nothing for now

