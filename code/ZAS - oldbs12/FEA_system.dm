/*
Overview:
	The air_master global variable is the workhorse for the system.

Why are you archiving data before modifying it?
	The general concept with archiving data and having each tile keep track of when they were last updated is to keep everything symmetric
		and totally independent of the order they are read in an update cycle.
	This prevents abnormalities like air/fire spreading rapidly in one direction and super slowly in the other.

Why not just archive everything and then calculate?
	Efficiency. While a for-loop that goes through all tils and groups to archive their information before doing any calculations seems simple, it is
		slightly less efficient than the archive-before-modify/read method.

Why is there a cycle check for calculating data as well?
	This ensures that every connection between group-tile, tile-tile, and group-group is only evaluated once per loop.




Important variables:
	air_master.groups_to_rebuild (list)
		A list of air groups that have had their geometry occluded and thus may need to be split in half.
		A set of adjacent groups put in here will join together if validly connected.
		This is done before air system calculations for a cycle.
	air_master.tiles_to_update (list)
		Turfs that are in this list have their border data updated before the next air calculations for a cycle.
		Place turfs in this list rather than call the proc directly to prevent race conditions

	turf/simulated.archive() and datum/air_group.archive()
		This stores all data for.
		If you modify, make sure to update the archived_cycle to prevent race conditions and maintain symmetry

	atom/CanPass(atom/movable/mover, turf/target, height, air_group)
		returns 1 for allow pass and 0 for deny pass
		Turfs automatically call this for all objects/mobs in its turf.
		This is called both as source.CanPass(target, height, air_group)
			and  target.CanPass(source, height, air_group)

		Cases for the parameters
		1. This is called with args (mover, location, height>0, air_group=0) for normal objects.
		2. This is called with args (null, location, height=0, air_group=0) for flowing air.
		3. This is called with args (null, location, height=?, air_group=1) for determining group boundaries.

		Cases 2 and 3 would be different for doors or other objects open and close fairly often.
			(Case 3 would return 0 always while Case 2 would return 0 only when the door is open)
			This prevents the necessity of re-evaluating group geometry every time a door opens/closes.


Important Procedures
	air_master.process()
		This first processes the air_master update/rebuild lists then processes all groups and tiles for air calculations

*/

var/tick_multiplier = 2

atom/proc/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	//Purpose: Determines if the object (or airflow) can pass this atom.
	//Called by: Movement, airflow.
	//Inputs: The moving atom (optional), target turf, "height" and air group
	//Outputs: Boolean if can pass.

	return (!density || !height || air_group)

/turf/CanPass(atom/movable/mover, turf/target, height=1.5,air_group=0)
	if(!target) return 0

	if(istype(mover)) // turf/Enter(...) will perform more advanced checks
		return !density

	else // Now, doing more detailed checks for air movement and air group formation
		if(target.blocks_air||blocks_air)
			return 0

		for(var/obj/obstacle in src)
			if(!obstacle.CanPass(mover, target, height, air_group))
				return 0
		if(target != src)
			for(var/obj/obstacle in target)
				if(!obstacle.CanPass(mover, src, height, air_group))
					return 0

		return 1


var/datum/controller/air_system/air_master

/datum/controller/air_system
	//Geometry lists
	var/list/turfs_with_connections = list()
	var/list/active_hotspots = list()

	//Special functions lists
	var/reconsidering_zones = FALSE
	var/list/tiles_to_reconsider_zones = list()
	var/list/tiles_to_reconsider_alternate

	//Geometry updates lists
	var/updating_tiles = FALSE
	var/list/tiles_to_update = list()
	var/list/tiles_to_update_alternate

	var/checking_connections = FALSE
	var/list/connections_to_check = list()
	var/list/connections_to_check_alternate

	var/list/potential_intrazone_connections = list()

	//Zone lists
	var/list/active_zones = list()
	var/list/zones_needing_rebuilt = list()
	var/list/zones = list()


	var/current_cycle = 0
	var/update_delay = 5 //How long between check should it try to process atmos again.
	var/failed_ticks = 0 //How many ticks have runtimed?

	var/tick_progress = 0


/datum/controller/air_system/proc/Setup()
	//Purpose: Call this at the start to setup air groups geometry
	//    (Warning: Very processor intensive but only must be done once per round)
	//Called by: Gameticker/Master controller
	//Inputs: None.
	//Outputs: None.

	//set background = 1
	world << "\red \b Processing Geometry..."
	sleep(-1)

	var/start_time = world.timeofday

	var/simulated_turf_count = 0

	for(var/turf/simulated/S in world)
		simulated_turf_count++
		if(!S.zone && !S.blocks_air)
			if(S.CanPass(null, S, 0, 0))
				new/zone(S)

	for(var/turf/simulated/S in world)
		S.update_air_properties()

	world << {"<font color='red'><b>Geometry initialized in [round(0.1*(world.timeofday-start_time),0.1)] seconds.</b>
Total Simulated Turfs: [simulated_turf_count]
Total Zones: [zones.len]
Total Unsimulated Turfs: [world.maxx*world.maxy*world.maxz - simulated_turf_count]</font>"}

//	spawn Start()


/datum/controller/air_system/proc/Start()
	//Purpose: This is kicked off by the master controller, and controls the processing of all atmosphere.
	//Called by: Master controller
	//Inputs: None.
	//Outputs: None.


	//set background = 1

	while(1)
		if(!air_processing_killed)
			var/success = Tick() //Changed so that a runtime does not crash the ticker.
			if(!success) //Runtimed.
				failed_ticks++
				if(failed_ticks > 20)
					world << "<font color='red'><b>ERROR IN ATMOS TICKER.  Killing air simulation!</font></b>"
					air_processing_killed = 1
		sleep(max(5,update_delay*tick_multiplier))


/datum/controller/air_system/proc/Tick()
	. = 1 //Set the default return value, for runtime detection.

	current_cycle++

	//If there are tiles to update, do so.
	tick_progress = "updating turf properties"
	if(tiles_to_update.len)
		updating_tiles = TRUE

		for(var/turf/simulated/T in tiles_to_update)
			if(. && T && !T.update_air_properties())
				//If a runtime occured, make sure we can sense it.
				. = 0

		updating_tiles = FALSE

		if(.)
			if(tiles_to_update_alternate)
				tiles_to_update = tiles_to_update_alternate
				tiles_to_update_alternate = null
			else
				tiles_to_update = list()

		else if(tiles_to_update_alternate)
			tiles_to_update |= tiles_to_update_alternate
			tiles_to_update_alternate = null

	//Rebuild zones.
	if(.)
		tick_progress = "rebuilding zones"
	if(zones_needing_rebuilt.len)
		for(var/zone/zone in zones_needing_rebuilt)
			zone.Rebuild()

		zones_needing_rebuilt = list()

	//Check sanity on connection objects.
	if(.)
		tick_progress = "checking/creating connections"
	if(connections_to_check.len)
		checking_connections = TRUE

		for(var/connection/C in connections_to_check)
			C.Cleanup()

		for(var/turf/simulated/turf_1 in potential_intrazone_connections)
			for(var/turf/simulated/turf_2 in potential_intrazone_connections[turf_1])

				if(!turf_1.zone || !turf_2.zone)
					continue

				if(turf_1.zone == turf_2.zone)
					continue

				var/should_skip = FALSE
				if(turf_1 in air_master.turfs_with_connections)

					for(var/connection/C in turfs_with_connections[turf_1])
						if(C.B == turf_2 || C.A == turf_2)
							should_skip = TRUE
							break
				if(should_skip)
					continue

				new /connection(turf_1, turf_2)

		checking_connections = FALSE

		potential_intrazone_connections = list()

		if(connections_to_check_alternate)
			connections_to_check = connections_to_check_alternate
			connections_to_check_alternate = null
		else
			connections_to_check = list()

	//Process zones.
	if(.)
		tick_progress = "processing zones"
	for(var/zone/Z in active_zones)
		if(Z.last_update < current_cycle)
			var/output = Z.process()
			if(Z)
				Z.last_update = current_cycle
			if(. && Z && !output)
				. = 0

	//Ensure tiles still have zones.
	if(.)
		tick_progress = "reconsidering zones on turfs"
	if(tiles_to_reconsider_zones.len)
		reconsidering_zones = TRUE

		for(var/turf/simulated/T in tiles_to_reconsider_zones)
			if(!T.zone)
				new /zone(T)

		reconsidering_zones = FALSE

		if(tiles_to_reconsider_alternate)
			tiles_to_reconsider_zones = tiles_to_reconsider_alternate
			tiles_to_reconsider_alternate = null
		else
			tiles_to_reconsider_zones = list()

	//Process fires.
	if(.)
		tick_progress = "processing fire"
	for(var/obj/fire/F in active_hotspots)
		if(. && F && !F.process())
			. = 0

	if(.)
		tick_progress = "success"


/datum/controller/air_system/proc/AddTurfToUpdate(turf/simulated/outdated_turf)
	var/list/tiles_to_check = list()

	if(istype(outdated_turf))
		tiles_to_check |= outdated_turf

	if(istype(outdated_turf, /turf))
		for(var/direction in cardinal)
			var/turf/simulated/adjacent_turf = get_step(outdated_turf, direction)
			if(istype(adjacent_turf))
				tiles_to_check |= adjacent_turf

	if(updating_tiles)
		if(!tiles_to_update_alternate)
			tiles_to_update_alternate = tiles_to_check
		else
			tiles_to_update_alternate |= tiles_to_check
	else
		tiles_to_update |= tiles_to_check


/datum/controller/air_system/proc/AddConnectionToCheck(connection/connection)
	if(checking_connections)
		if(istype(connection, /list))
			if(!connections_to_check_alternate)
				connections_to_check_alternate = connection

		else if(!connections_to_check_alternate)
			connections_to_check_alternate = list()

		connections_to_check_alternate |= connection

	else
		connections_to_check |= connection


/datum/controller/air_system/proc/ReconsiderTileZone(var/turf/simulated/zoneless_turf)
	if(zoneless_turf.zone)
		return

	if(reconsidering_zones)
		if(!tiles_to_reconsider_alternate)
			tiles_to_reconsider_alternate = list()

		tiles_to_reconsider_alternate |= zoneless_turf

	else
		tiles_to_reconsider_zones |= zoneless_turf


/datum/controller/air_system/proc/AddIntrazoneConnection(var/turf/simulated/A, var/turf/simulated/B)
	if(!istype(A) || !istype(B))
		return

	if(A in potential_intrazone_connections)
		if(B in potential_intrazone_connections[A])
			return

	if (B in potential_intrazone_connections)
		if(A in potential_intrazone_connections[B])
			return

		potential_intrazone_connections[B] += A

	else
		potential_intrazone_connections[B] = list(A)
