/atom/var/pressure_resistance = ONE_ATMOSPHERE

/turf/var/zone/zone

/turf/assume_air(datum/gas_mixture/giver) //use this for machines to adjust air
	del(giver)
	return 0

/turf/return_air()
	//Create gas mixture to hold data for passing
	var/datum/gas_mixture/GM = new

	GM.oxygen = oxygen
	GM.carbon_dioxide = carbon_dioxide
	GM.nitrogen = nitrogen
	GM.toxins = toxins

	GM.temperature = temperature
	GM.update_values()

	return GM

/turf/remove_air(amount as num)
	var/datum/gas_mixture/GM = new

	var/sum = oxygen + carbon_dioxide + nitrogen + toxins
	if(sum>0)
		GM.oxygen = (oxygen/sum)*amount
		GM.carbon_dioxide = (carbon_dioxide/sum)*amount
		GM.nitrogen = (nitrogen/sum)*amount
		GM.toxins = (toxins/sum)*amount

	GM.temperature = temperature
	GM.update_values()

	return GM

/turf/simulated/var/current_graphic = null

/turf/simulated/var/tmp/datum/gas_mixture/air

/turf/simulated/var/tmp/air_check_directions = 0 //Do not modify this, just add turf to air_master.tiles_to_update

/turf/simulated/var/tmp/unsim_check_directions = 0 //See above.

/turf/simulated/var/tmp/obj/fire/active_hotspot

/turf/simulated/var/tmp/was_icy = 0

/turf/simulated/proc/update_visuals()
	overlays = null

	var/siding_icon_state = return_siding_icon_state()
	if(siding_icon_state)
		overlays += image('icons/turf/floors.dmi',siding_icon_state)
	var/datum/gas_mixture/model = return_air()


	switch(model.graphic)
		if(1)
			overlays.Add(plmaster) //TODO: Make invisible plasma an option
		if(2)
			overlays.Add(slmaster)
		if(3)
			if(!was_icy)
				wet=3 // Custom ice
				was_icy=1
				var/o=""
				//if(is_plating())
				//	o="snowfloor_s"
				//else
				if(is_plasteel_floor())
					o="snowfloor"
				if(o!="")
					overlays += image('icons/turf/overlays.dmi',o)
		else
			if(was_icy)
				wet=0
				was_icy=0
				if(prob(10))
					wet = 1
					if(wet_overlay)
						overlays -= wet_overlay
						wet_overlay = null
					wet_overlay = image('icons/effects/water.dmi',src,"wet_floor")
					overlays += wet_overlay

					spawn(800)
						if (!istype(src)) return
						if(wet >= 2) return
						wet = 0
						if(wet_overlay)
							overlays -= wet_overlay
							wet_overlay = null


/turf/simulated/New()
	if(!blocks_air)
		air = new

		air.oxygen = oxygen
		air.carbon_dioxide = carbon_dioxide
		air.nitrogen = nitrogen
		air.toxins = toxins

		air.temperature = temperature
		air.update_values()

		if(air_master)
			air_master.tiles_to_update.Add(src)

	else
		if(air_master)
			for(var/direction in cardinal)
				var/turf/simulated/floor/target = get_step(src,direction)
				if(istype(target))
					air_master.tiles_to_update |= target

	. = ..()

/turf/simulated/Destroy()
	if(active_hotspot)
		del(active_hotspot)
	if(blocks_air)
		for(var/direction in list(NORTH, SOUTH, EAST, WEST))
			var/turf/simulated/tile = get_step(src,direction)
			if(istype(tile) && !tile.blocks_air)
				air_master.tiles_to_update.Add(tile)
	..()

/turf/simulated/assume_air(datum/gas_mixture/giver)
	if(!giver)	return 0
	if(zone)
		zone.assume_air(giver)
		return 1
	else
		return ..()

/turf/simulated/return_air()
	if(zone)
		return zone.air
	else if(air)
		return air

	else
		return ..()

/turf/simulated/remove_air(amount as num)
	if(zone)
		return zone.remove_air(amount)

	else if(air)
		var/datum/gas_mixture/removed = null
		removed = air.remove(amount)

		if(air.check_tile_graphic())
			update_visuals(air)
		return removed

	else
		return ..()

/turf/simulated/proc/update_air_properties()
	var/air_directions_archived = air_check_directions
	air_check_directions = 0

	var/unsim_directions_archived = unsim_check_directions
	unsim_check_directions = 0

	for(var/direction in cardinal)
		var/turf/check_turf = get_step(src, direction)
		if(ZAirPass(check_turf))
			if(istype(check_turf, /turf/simulated))
				air_check_directions |= direction
			else if(istype(check_turf, /turf/space) || istype(check_turf, /turf/unsimulated))
				unsim_check_directions |= direction

	if(!zone && !blocks_air) //No zone, but not a wall.
		for(var/direction in DoorDirections) //Check door directions first.
			if(air_check_directions & direction)
				var/turf/simulated/T = get_step(src, direction)
				if(!istype(T))
					continue
				if(T.zone)
					T.zone.AddTurf(src)
					break
		if(!zone) //Still no zone
			for(var/direction in CounterDoorDirections) //Check the others second.
				if(air_check_directions & direction)
					var/turf/simulated/T = get_step(src,direction)
					if(!istype(T))
						continue
					if(T.zone)
						T.zone.AddTurf(src)
						break
		if(!zone) //No zone found, new zone!
			new/zone(src)
		if(!zone) //Still no zone, the floodfill determined it is not part of a larger zone.  Force a zone on it.
			new/zone(list(src))

	//Check pass sanity of the connections.
	if(src in air_master.turfs_with_connections)
		air_master.AddConnectionToCheck(air_master.turfs_with_connections[src])

	if(zone && !air_master.zones_needing_rebuilt.Find(zone))
		for(var/direction in cardinal)
			var/turf/T = get_step(src,direction)
			if(!istype(T))
				continue

			//I can connect to air in this direction
			if(air_check_directions & direction || unsim_check_directions & direction)

				//If either block air, we must look to see if the adjacent turfs need rebuilt.
				if(!CanPass(null, T, 0, 0))

					//Target blocks air
					if(!T.CanPass(null, T, 0, 0))
						var/turf/NT = get_step(T, direction)

						//If that turf is in my zone still, rebuild.
						if(istype(NT,/turf/simulated) && NT in zone.contents)
							air_master.zones_needing_rebuilt.Add(zone)

						//If that is an unsimulated tile in my zone, see if we need to rebuild or just remove.
						else if(istype(NT) && NT in zone.unsimulated_tiles)
							var/consider_rebuild = 0
							for(var/d in cardinal)
								var/turf/UT = get_step(NT,d)
								if(istype(UT, /turf/simulated) && UT.zone == zone && UT.CanPass(null, NT, 0, 0)) //If we find a neighboring tile that is in the same zone, check if we need to rebuild
									consider_rebuild = 1
									break
							if(consider_rebuild)
								air_master.zones_needing_rebuilt.Add(zone) //Gotta check if we need to rebuild, dammit
							else
								zone.RemoveTurf(NT) //Not adjacent to anything, and unsimulated.  Goodbye~

						//To make a closed connection through closed door.
						ZConnect(T, src)

					//If I block air.
					else if(T.zone && !air_master.zones_needing_rebuilt.Find(T.zone))
						var/turf/NT = get_step(src, reverse_direction(direction))

						//If I am splitting a zone, rebuild.
						if(istype(NT,/turf/simulated) && (NT in T.zone.contents || (NT.zone && T in NT.zone.contents)))
							air_master.zones_needing_rebuilt.Add(T.zone)

						//If NT is unsimulated, parse if I should remove it or rebuild.
						else if(istype(NT) && NT in T.zone.unsimulated_tiles)
							var/consider_rebuild = 0
							for(var/d in cardinal)
								var/turf/UT = get_step(NT,d)
								if(istype(UT, /turf/simulated) && UT.zone == T.zone && UT.CanPass(null, NT, 0, 0)) //If we find a neighboring tile that is in the same zone, check if we need to rebuild
									consider_rebuild = 1
									break

							//Needs rebuilt.
							if(consider_rebuild)
								air_master.zones_needing_rebuilt.Add(T.zone)

							//Not adjacent to anything, and unsimulated.  Goodbye~
							else
								T.zone.RemoveTurf(NT)

				else
					//Produce connection through open door.
					ZConnect(src,T)

			//Something like a wall was built, changing the geometry.
			else if(air_directions_archived & direction || unsim_directions_archived & direction)
				var/turf/NT = get_step(T, direction)

				//If the tile is in our own zone, and we cannot connect to it, better rebuild.
				if(istype(NT,/turf/simulated) && NT in zone.contents)
					air_master.zones_needing_rebuilt.Add(zone)

				//Parse if we need to remove the tile, or rebuild the zone.
				else if(istype(NT) && NT in zone.unsimulated_tiles)
					var/consider_rebuild = 0

					//Loop through all neighboring turfs to see if we should remove the turf or just rebuild.
					for(var/d in cardinal)
						var/turf/UT = get_step(NT,d)

						//If we find a neighboring tile that is in the same zone, rebuild
						if(istype(UT, /turf/simulated) && UT.zone == zone && UT.CanPass(null, NT, 0, 0))
							consider_rebuild = 1
							break

					//The unsimulated turf is adjacent to another one of our zone's turfs,
					//  better rebuild to be sure we didn't get cut in twain
					if(consider_rebuild)
						air_master.zones_needing_rebuilt.Add(NT.zone)

					//Not adjacent to anything, and unsimulated.  Goodbye~
					else
						zone.RemoveTurf(NT)

	return 1

/turf/proc/HasDoor(turf/O)
	//Checks for the presence of doors, used for zone spreading and connection.
	//A positive numerical argument checks only for closed doors.
	//Another turf as an argument checks for windoors between here and there.
	for(var/obj/machinery/door/D in src)
		if(isnum(O) && O)
			if(!D.density) continue
		if(istype(D,/obj/machinery/door/window))
			if(!istype(O))
				continue
			if(D.dir == get_dir(D,O))
				return 1
		else
			return 1

/turf/proc/ZCanPass(turf/simulated/T, var/include_space = 0)
	//Fairly standard pass checks for turfs, objects and directional windows. Also stops at the edge of space.
	if(!istype(T))
		return 0

	if(!istype(T) && !include_space)
		return 0
	else
		if(T.blocks_air||blocks_air)
			return 0

		for(var/obj/obstacle in src)
			if(istype(obstacle, /obj/machinery/door) && !(obstacle:air_properties_vary_with_direction))
				continue
			if(!obstacle.CanPass(null, T, 1.5, 1))
				return 0

		for(var/obj/obstacle in T)
			if(istype(obstacle, /obj/machinery/door) && !(obstacle:air_properties_vary_with_direction))
				continue
			if(!obstacle.CanPass(null, src, 1.5, 1))
				return 0

		return 1

/turf/proc/ZAirPass(turf/T)
	//Fairly standard pass checks for turfs, objects and directional windows.
	if(!istype(T))
		return 0

	if(T.blocks_air||blocks_air)
		return 0

	for(var/obj/obstacle in src)
		if(istype(obstacle, /obj/machinery/door) && !(obstacle:air_properties_vary_with_direction))
			continue
		if(!obstacle.CanPass(null, T, 0, 0))
			return 0

	for(var/obj/obstacle in T)
		if(istype(obstacle, /obj/machinery/door) && !(obstacle:air_properties_vary_with_direction))
			continue
		if(!obstacle.CanPass(null, src, 0, 0))
			return 0

	return 1

/*UNUSED
/turf/proc/check_connections()
	//Checks for new connections that can be made.
	for(var/d in cardinal)
		var/turf/simulated/T = get_step(src,d)
		if(istype(T) && ( !T.zone || !T.CanPass(0,src,0,0) ) )
			continue
		if(T.zone != zone)
			ZConnect(src,T)

/turf/proc/check_for_space()
	//Checks for space around the turf.
	for(var/d in cardinal)
		var/turf/T = get_step(src,d)
		if(istype(T,/turf/space) && T.CanPass(0,src,0,0))
			zone.AddSpace(T)
			*/