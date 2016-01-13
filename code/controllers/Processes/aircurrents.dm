//handle giving cycles to each individual air currents.
//air currents is a system that keep track of tiles where more than a defined % air was added in a cycle
//it then check neighboring tiles to find a path going away from the source with the most (or least depending on direction) air up to a defined number of turfs and equalise the air on the whole path at once. this will have for impact of spreading atmospherics much faster, heat can also be shared this way
//current will only stop once the air stabilised on the whole current line for a defined number of cycles
//it will also priorize holes open to space since it does not actually work on space, only 1 air current per hole can be active and as such without a multiplier would be dramatically slower than same air exchange between 2 connected room

#define MINIMUM_AIR_CURRENTS_STARTPRESSURE 10 //any gas exchange with less pressure than this is just ignored if there is no currents in the area
#define MINIMUM_AIR_CURRENTS_EXTRAPRESSURE 3 //any gas exchange with less pressure than this is just ignored if there are currents in the area
#define MINIMUM_AIR_CURRENTS_STARTRATIO 0.3 //minimum ratio of pressure added to a tile in a cycle before its considered for the currents system when its the first
#define MINIMUM_AIR_CURRENTS_EXTRARATIO 0.1 //minimum ratio of pressure needed for subsequent currents
#define AIR_CURRENTS_LENGHT 8 //maximum number of turf considered for a current
#define AIR_CURRENTS_STABLE_CYCLE 3 //number of cycles where no air was exchanged by the current before it can be considered dead
#define AIR_CURRENTS_TOOSLOW_RATIO 0.09 //ratio at which its considered a slow currents and should be removed soon. should be slower than MINIMUM_AIR_CURRENTS_STARTRATIO
#define AIR_CURRENTS_TOOSLOW_CYCLE 10 //number of cycles where less than AIR_CURRENTS_TOOSLOW_RATIO pressure was added to the air current tile before we are considered done
#define AIR_CURRENTS_SPEED_FACTOR 1.0//1.0 cause the air in the current and the source to equilibrate 1 air_master tick in a closed room
#define AIR_CURRENTS_TEMPERATURE_SPEED 0.0001 //affect how fast the temperature spread using the air currents
#define AIR_CURRENTS_PRESSUREPUSH_MULT 2 //due to how the air is averaged on the chain, the pressure difference is actually often much smaller than it should be, so we simply apply add a multiplier
#define AIR_CURRENTS_SPACESIPHON_MULT 4 //if the source of the air current is next to a turf open to space, the current will "consume" AIR_CURRENTS_SPACESIPHON_MULT times the air the src used in its balance. This allow for accounting of the fact most of the air you add in the turf connected to space, end up continuing into space
var/global/datum/controller/process/aircurrents/air_currents_master
/datum/controller/process/aircurrents/var/list/active_air_currents[0] //our list of active air currents

//uncomments to have a visual debug ingame of how the air currents act. Be warned this add a sizeable performance overhead
//#define AIRCURRENTDEBUG 1
#ifdef AIRCURRENTDEBUG

var/obj/effect/overlay/debugsrc
var/obj/effect/overlay/debug1
var/obj/effect/overlay/debug2
var/obj/effect/overlay/debug3
var/obj/effect/overlay/debug4
var/obj/effect/overlay/debug5
var/obj/effect/overlay/debug6
var/obj/effect/overlay/debug6p
#endif
/datum/controller/process/aircurrents/setup()
	name = "air_currents"
	schedule_interval = 20
	start_delay = 4
	air_currents_master = src
#ifdef AIRCURRENTDEBUG
	debugsrc = new /obj/effect/overlay()
	debugsrc.icon = 'icons/misc/debug_group.dmi'
	debugsrc.icon_state = ""
	debugsrc.layer = FLY_LAYER
	debugsrc.mouse_opacity = 0

	debug1 = new /obj/effect/overlay()
	debug1.icon = 'icons/misc/debug_rebuild.dmi'
	debug1.icon_state = "1"
	debug1.layer = FLY_LAYER
	debug1.mouse_opacity = 0

	debug2 = new /obj/effect/overlay()
	debug2.icon = 'icons/misc/debug_rebuild.dmi'
	debug2.icon_state = "2"
	debug2.layer = FLY_LAYER
	debug2.mouse_opacity = 0

	debug3 = new /obj/effect/overlay()
	debug3.icon = 'icons/misc/debug_rebuild.dmi'
	debug3.icon_state = "3"
	debug3.layer = FLY_LAYER
	debug3.mouse_opacity = 0

	debug4 = new /obj/effect/overlay()
	debug4.icon = 'icons/misc/debug_rebuild.dmi'
	debug4.icon_state = "4"
	debug4.layer = FLY_LAYER
	debug4.mouse_opacity = 0

	debug5 = new /obj/effect/overlay()
	debug5.icon = 'icons/misc/debug_rebuild.dmi'
	debug5.icon_state = "5"
	debug5.layer = FLY_LAYER
	debug5.mouse_opacity = 0

	debug6 = new /obj/effect/overlay()
	debug6.icon = 'icons/misc/debug_rebuild.dmi'
	debug6.icon_state = "6"
	debug6.layer = FLY_LAYER
	debug6.mouse_opacity = 0

	debug6p = new /obj/effect/overlay()
	debug6p.icon = 'icons/misc/debug_rebuild.dmi'
	debug6p.icon_state = ""
	debug6p.layer = FLY_LAYER
	debug6p.mouse_opacity = 0
#endif
/datum/controller/process/aircurrents/statProcess()
	..()
	stat(null, "[active_air_currents.len] active")


/datum/controller/process/aircurrents/doWork()
	process_allcurrents()
	return 1

/datum/controller/process/aircurrents/proc/process_allcurrents()
	for (var/turf/simulated/T in active_air_currents)
		if (T == null)
			active_air_currents -= T
		else
			T.process_aircurrents()
		SCHECK

/datum/controller/process/aircurrents/proc/removeTurf(var/turf/simulated/T)

	active_air_currents -= T //remove us, if we still need a current well be readded
	if (T == null)
		return
	T.skipaircurrents = 0
	T.aircurrentsdirection = 0
	T.slowcount = 0
	T.stablecount = 0
	T.opentospace = 0
	var/area/A = get_area(T)
	A.aircurrentsturfs -= T

/datum/controller/process/aircurrents/proc/onGasExchange(var/turf/simulated/T, var/startpressure, var/endpressure)
	//temporary
	if (!T)
		return
	var/deltapressure = abs(startpressure - endpressure)

	var/area/A = get_area(T)
	if (world.time - A.lastAirCurrentsCreated < 2)
		return //try again next time
	if (A.aircurrentsturfs.len > 0 || world.time - A.lastAirCurrents < 50)
		if (deltapressure < MINIMUM_AIR_CURRENTS_EXTRAPRESSURE)
			return
	else
		if (deltapressure < MINIMUM_AIR_CURRENTS_STARTPRESSURE)
			return
	if (T in air_currents_master.active_air_currents)
		return

	if (A.aircurrentsturfs.len > 0)
		//theres other currents in the area, so lets check distance
		for (var/turf/simulated/Tcurrents in A.aircurrentsturfs)
			var/dist = cheap_hypotenuse(Tcurrents.x, Tcurrents.y, T.x, T.y)
			if (dist < AIR_CURRENTS_LENGHT) //its in collision range, lets see if we can do anything about it
				if (Tcurrents.opentospace > 0)
					return //space holes are very important
				if (Tcurrents.aircurrentsdirection < 0 && startpressure < endpressure) //this one is spitting air, so lower priority
					removeTurf(Tcurrents)
					continue
				if (dist < 3) //no placing anything within 3 dist if you cant remove the old one
					return
				if ((world.time - Tcurrents.lastcurrentseffect > 30 && T.lastcurrentseffect == 0 ) || (T.lastcurrentseffect != 0 && Tcurrents.lastcurrentseffect - T.lastcurrentseffect > 30)) //that tile has been untouched for at least 3 seconds even with a current in range, so go ahead
					continue

				return //another in range so sorry no can do

	var/ratio
	if (startpressure > endpressure)
		if (endpressure == 0)
			ratio = startpressure
		else
			ratio = deltapressure / endpressure
	else
		if (startpressure == 0)
			ratio = endpressure
		else
			ratio = deltapressure / startpressure

	if (ratio > MINIMUM_AIR_CURRENTS_STARTRATIO || ((A.aircurrentsturfs.len > 0 || world.time - A.lastAirCurrents < 50) && ratio > MINIMUM_AIR_CURRENTS_EXTRARATIO))
		air_currents_master.active_air_currents |= T
		A.aircurrentsturfs |= T
		T.lastcurrentseffect = world.time
		A.lastAirCurrentsCreated = world.time
		if (startpressure > endpressure)
			T.aircurrentsdirection = -1
		else
			T.aircurrentsdirection = 1


/datum/aircurrentspath/var/list/turfsInPath[0]
/datum/aircurrentspath/var/totalpressure=0


/turf/simulated/var/aircurrentsdirection = 0 //1 if the air goes into the turf from the currents, and -1 if it goes out of the turf into the currents
/turf/simulated/var/skipaircurrents = 0 //skip process calls until this reach 0. When we find a case where theres just no path, no point in checking every 0.5 sec
/turf/simulated/var/stablecount = 0
/turf/simulated/var/slowcount = 0
/turf/simulated/var/lastcurrentseffect = 0 //used to determine if a tile is reasonably safe from being affected by a current by comparing with source time. If its been more than 10 seconds with no contact, assume there wont ever be any
/turf/simulated/var/opentospace = 0
/area/var/list/aircurrentsturfs[0] //list containing the currently active currents in the area
/area/var/lastAirCurrents = 0 //used to air currents can become contagious inter area
/area/var/lastAirCurrentsCreated = 0 //only make at most 1 air current per area per 0.2 sec

/turf/var/list/atmopasscache[4]
/turf/var/list/atmopasscachetime[4]
/turf/proc/InvalidateAtmoPassCache() //this way door opening get their updates instantly. most walls and other airblock destruction and construction also call this
	atmopasscachetime[1] = 0
	atmopasscachetime[2] = 0
	atmopasscachetime[3] = 0
	atmopasscachetime[4] = 0

//similar to the linda version, except it cache result up to 5seconds and does not update atmos_supeconductivity
//(cache invalidated by air_update_turf which doors call on open / close so that those do not get delayed).
//This does mean that object destruction / repair could take up to 5 seconds to update for the air currents if they did not call air_update_turf()
//this is a necessary compromise to achieve low cpu load with a faster air update speed where needed
/turf/proc/CanAtmosPassCached(var/turf/T, var/D)
	if(!istype(T))	return 0
	var/cacheIndex = 0
	switch (D)
		if (NORTH) cacheIndex = 1
		if (EAST)  cacheIndex = 2
		if (SOUTH) cacheIndex = 3
		if (WEST)  cacheIndex = 4

	if (world.time - atmopasscachetime[cacheIndex] < 50)
		return atmopasscache[cacheIndex]

	var/R
	if(blocks_air || T.blocks_air)
		R = 1

	for(var/obj/O in contents)
		if(!O.CanAtmosPass(T))
			R = 1
			if(O.BlockSuperconductivity()) 	//the direction and open/closed are already checked on CanAtmosPass() so there are no arguments
				atmopasscachetime[cacheIndex] = world.time
				atmopasscache[cacheIndex] = 0
				return 0						//no need to keep going, we got all we asked

	for(var/obj/O in T.contents)
		if(!O.CanAtmosPass(src))
			R = 1
			if(O.BlockSuperconductivity())
				atmopasscachetime[cacheIndex] = world.time
				atmopasscache[cacheIndex] = 0
				return 0

	if(!R)
		atmopasscachetime[cacheIndex] = world.time
		atmopasscache[cacheIndex] = 1
		return 1
	atmopasscachetime[cacheIndex] = world.time
	atmopasscache[cacheIndex] = 0


/turf/simulated/proc/process_aircurrents() //find us an air current path around us
	if (skipaircurrents > 1)
		skipaircurrents--
		return
	if (skipaircurrents == 1)
		air_currents_master.removeTurf(src)
		return

	var/list/paths[0]
	var/list/usedturfs[0]

	opentospace = 0
	for(var/directionstart in cardinal) //check for a path in all 4 directions
		var/turf/sourcetile = get_step(src, directionstart)
		if (!CanAtmosPassCached(sourcetile,directionstart))
			continue

		var/datum/aircurrentspath/path = new()
		if(istype(sourcetile,/turf/simulated)) //we allow for the first tile to be space, maybe its a hole in the floor, so skip above
			var/turf/simulated/source = sourcetile
			path.turfsInPath.Add(source)
			usedturfs.Add(source)
			path.totalpressure += source.air.return_pressure()
			if (istype(source, /turf/unsimulated)) //space
				opentospace++
		for(var/i=0, i < AIR_CURRENTS_LENGHT, i++)
			var/turf/simulated/highestPressureT = null
			var/bestPressureVal
			if (aircurrentsdirection > 0)
				bestPressureVal = -1
			else
				bestPressureVal = 999999999 //we are looking for the lowest pressure path to dump air in
			for(var/direction in cardinal)
				/*if(!(atmos_adjacent_turfs & direction))
					continue*/

				var/turf/tile = get_step(sourcetile, direction)
				if(!istype(tile,/turf/simulated))
					continue
				var/turf/simulated/T = tile
				if (!sourcetile.CanAtmosPassCached(T,direction))
					continue
				if (!T.air)
					continue
				if (T in path.turfsInPath)
					continue //cant step back on our track
				var/press = T.air.return_pressure()
				if (aircurrentsdirection > 0)
					if (press > bestPressureVal)
						bestPressureVal = press
						highestPressureT = T
				else
					if (press < bestPressureVal)
						bestPressureVal = press
						highestPressureT = T
			if (bestPressureVal == -1 || bestPressureVal == 999999999)
				break
			path.turfsInPath.Add(highestPressureT)
			usedturfs.Add(highestPressureT)
			path.totalpressure +=bestPressureVal
			sourcetile = highestPressureT
		if (path.turfsInPath.len > 0)
			paths.Add(path)

	if (paths.len == 0)
		skipaircurrents = 16 + rand(0,8) //try again in about 8-12 sec
		return

	var/bestPressureVal
	var/datum/aircurrentspath/path = null
	if (aircurrentsdirection > 0)
		bestPressureVal = -1
	else
		bestPressureVal = 999999999 //we are looking for the lowest pressure path to dump air in
	for (var/datum/aircurrentspath/possiblePath in paths) //find the best path for our air current
		if (aircurrentsdirection > 0)
			if (possiblePath.totalpressure > bestPressureVal)
				bestPressureVal = possiblePath.totalpressure
				path = possiblePath
		else
			if (possiblePath.totalpressure < bestPressureVal)
				bestPressureVal = possiblePath.totalpressure
				path = possiblePath

	if (bestPressureVal == -1 || bestPressureVal == 999999999)
		skipaircurrents = 16 + rand(0,8) //try again in about 8-12 sec
		return null



	var/pathpressurestart = src.air.return_pressure()
	//now we have a set of turfs we can equalise and push things around on
	var/totalOxygen = 0
	var/totalCarbon = 0
	var/totalNitrogen = 0
	var/totalToxins = 0
	var/totalTemperature = 0

	for (var/turf/simulated/T in path.turfsInPath)
		totalOxygen += T.air.oxygen
		totalCarbon += T.air.carbon_dioxide
		totalNitrogen += T.air.nitrogen
		totalToxins += T.air.toxins
		totalTemperature += T.air.temperature

	var/averageOxygen = totalOxygen/path.turfsInPath.len
	var/averageCarbon = totalCarbon/path.turfsInPath.len
	var/averageNitrogen = totalNitrogen/path.turfsInPath.len
	var/averageToxins = totalToxins/path.turfsInPath.len
	var/averageTemperature = totalTemperature/path.turfsInPath.len

	var/deltaOxy = AIR_CURRENTS_SPEED_FACTOR * (averageOxygen - src.air.oxygen)/(1+air_master.schedule_interval/air_currents_master.schedule_interval)
	var/deltaCarb = AIR_CURRENTS_SPEED_FACTOR * (averageCarbon - src.air.carbon_dioxide)/(1+air_master.schedule_interval/air_currents_master.schedule_interval)
	var/deltaNitro = AIR_CURRENTS_SPEED_FACTOR * (averageNitrogen - src.air.nitrogen)/(1+air_master.schedule_interval/air_currents_master.schedule_interval)
	var/deltaTox = AIR_CURRENTS_SPEED_FACTOR * (averageToxins - src.air.toxins)/(1+air_master.schedule_interval/air_currents_master.schedule_interval)
	var/deltaTemp = AIR_CURRENTS_TEMPERATURE_SPEED * (averageTemperature - src.air.temperature)/(1+air_master.schedule_interval/air_currents_master.schedule_interval)

	if (opentospace == 0)
		totalOxygen -=deltaOxy
		totalCarbon -=deltaCarb
		totalNitrogen -=deltaNitro
		totalToxins -=deltaTox
		totalTemperature -=deltaTemp
	else
		totalOxygen -=deltaOxy * opentospace * AIR_CURRENTS_SPACESIPHON_MULT //were open to space so grab more air. air currents does not travel on the space tile so without this multiplier hole to space are much slower to act than hole between room
		totalCarbon -=deltaCarb * opentospace * AIR_CURRENTS_SPACESIPHON_MULT
		totalNitrogen -=deltaNitro * opentospace * AIR_CURRENTS_SPACESIPHON_MULT
		totalToxins -=deltaTox * opentospace * AIR_CURRENTS_SPACESIPHON_MULT
		totalTemperature -=deltaTemp * opentospace * AIR_CURRENTS_SPACESIPHON_MULT


	var/totalTurfsPath = path.turfsInPath.len

	src.air.oxygen += deltaOxy
	src.air.carbon_dioxide += deltaCarb
	src.air.nitrogen += deltaNitro
	src.air.toxins += deltaTox
	src.air.temperature += deltaTemp



	for (var/turf/simulated/T in path.turfsInPath) //equalise the air
		air_master.add_to_active(T)
		var/area/A = get_area(T)
		A.lastAirCurrents = world.time

		T.lastcurrentseffect = world.time
		T.air.oxygen = totalOxygen/totalTurfsPath
		T.air.carbon_dioxide = totalCarbon/totalTurfsPath
		T.air.nitrogen = totalNitrogen/totalTurfsPath
		T.air.toxins = totalToxins/totalTurfsPath
		T.air.temperature = totalTemperature/totalTurfsPath

	var/pathpressureend = src.air.return_pressure()
	var/pathpressuremvm
	if (opentospace > 0)
		pathpressuremvm  = abs(pathpressureend - pathpressurestart) * opentospace * AIR_CURRENTS_SPACESIPHON_MULT //also multiply the pressure moved
	else
		pathpressuremvm = abs(pathpressureend - pathpressurestart)


	if (pathpressuremvm < 0) //air went away so the mvm is from the source down the path
		var/turf/currentTile = src
		for (var/turf/simulated/T in path.turfsInPath)
			air_currents_master.consider_path_pressure(currentTile, T, pathpressuremvm)
			currentTile = T
	else //air goes from the path to the tile so the air pressure push stuff toward src
		var/turf/currentTile = path.turfsInPath[path.turfsInPath.len]
		var/turf/T
		if (path.turfsInPath.len > 0)
			for(var/i=path.turfsInPath.len-1,i>0,i--)
				T = path.turfsInPath[i]
				air_currents_master.consider_path_pressure(currentTile, T, pathpressuremvm*AIR_CURRENTS_PRESSUREPUSH_MULT)
				currentTile = T
		air_currents_master.consider_path_pressure(currentTile, src, pathpressuremvm*AIR_CURRENTS_PRESSUREPUSH_MULT) //last tile is the src since its not part of the path



	if (pathpressuremvm == 0)
		stablecount++
		slowcount++
	else
		stablecount = 0
		var/pressuremvmratio
		if (pathpressureend > pathpressurestart)
			pressuremvmratio = pathpressuremvm / pathpressurestart
		else
			pressuremvmratio = pathpressuremvm / pathpressureend
		if (pressuremvmratio < AIR_CURRENTS_TOOSLOW_RATIO)
			slowcount++
		else
			slowcount = 0
#ifdef AIRCURRENTDEBUG
	spawn(0)
		src.overlays |= debugsrc
		sleep(0.3)
		var/count = 1
		for (var/turf/simulated/T in path.turfsInPath)
			switch (count)
				if(1) T.overlays |= debug1
				if(2) T.overlays |= debug2
				if(3) T.overlays |= debug3
				if(4) T.overlays |= debug4
				if(5) T.overlays |= debug5
				if(6) T.overlays |= debug6
				else T.overlays |= debug6p
			count++
			sleep(0.3)
		sleep(3)
		src.overlays -= debugsrc
		sleep(0.3)
		count = 1
		for (var/turf/simulated/T in path.turfsInPath)
			switch (count)
				if(1) T.overlays -= debug1
				if(2) T.overlays -= debug2
				if(3) T.overlays -= debug3
				if(4) T.overlays -= debug4
				if(5) T.overlays -= debug5
				if(6) T.overlays -= debug6
				else T.overlays -= debug6p
			count++
			sleep(0.3)
	if (opentospace > 0)
		if (stablecount >= AIR_CURRENTS_STABLE_CYCLE*3)
			air_currents_master.removeTurf(src)
		else if (slowcount >= AIR_CURRENTS_TOOSLOW_CYCLE*3)
			air_currents_master.removeTurf(src)
	else
		if (stablecount >= AIR_CURRENTS_STABLE_CYCLE)
			air_currents_master.removeTurf(src)
		else if (slowcount >= AIR_CURRENTS_TOOSLOW_CYCLE)
			air_currents_master.removeTurf(src)
#endif

/datum/controller/process/aircurrents/proc/consider_path_pressure(var/turf/simulated/Tsrc, var/turf/simulated/Tdest, var/difference)
	air_master.high_pressure_delta |= Tsrc
	if(difference > Tsrc.pressure_difference)
		Tsrc.pressure_direction = get_dir(Tsrc, Tdest)
		Tsrc.pressure_difference = difference