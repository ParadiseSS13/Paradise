/turf
	icon = 'icons/turf/floors.dmi'
	level = 1.0

	//for floors, use is_plating(), is_plasteel_floor() and is_light_floor()
	var/intact = 1

	//Properties for open tiles (/floor)
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/toxins = 0

	//Properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1

	//Properties for both
	var/temperature = T20C

	var/blocks_air = 0
	var/icon_old = null
	var/pathweight = 1

	//Mining resource generation stuff.
	var/has_resources
	var/list/resources

	var/PathNode/PNode = null //associated PathNode in the A* algorithm

/turf/New()
	..()
	for(var/atom/movable/AM as mob|obj in src)
		spawn( 0 )
			src.Entered(AM)
			return
	return

/turf/ex_act(severity)
	return 0


/turf/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam/pulse))
		src.ex_act(2)
	..()
	return 0

/turf/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/bullet/gyro))
		explosion(src, -1, 0, 2)
	..()
	return 0

/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if (!mover)
		return 1


	// First, make sure it can leave its square
	if(isturf(mover.loc))
		// Nothing but border objects stop you from leaving a tile, only one loop is needed
		for(var/obj/obstacle in mover.loc)
			if(!obstacle.CheckExit(mover, src) && obstacle != mover && obstacle != forget)
				mover.Bump(obstacle, 1)
				return 0

	var/list/large_dense = list()
	//Next, check objects to block entry that are on the border
	for(var/atom/movable/border_obstacle in src)
		if(border_obstacle.flags&ON_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != border_obstacle))
				mover.Bump(border_obstacle, 1)
				return 0
		else
			large_dense += border_obstacle

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in large_dense)
		if(!obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != obstacle))
			mover.Bump(obstacle, 1)
			return 0
	return 1 //Nothing found to block so return success!


/turf/Entered(atom/atom as mob|obj)
	..()
//vvvvv Infared beam stuff vvvvv

	if ((atom && atom.density && !( istype(atom, /obj/effect/beam) )))
		for(var/obj/effect/beam/i_beam/I in src)
			spawn( 0 )
				if (I)
					I.hit()
				break

//^^^^^ Infared beam stuff ^^^^^

	if(!istype(atom, /atom/movable))
		return

	var/atom/movable/M = atom

	var/loopsanity = 100
	if(ismob(M))
		if(!M:lastarea)
			M:lastarea = get_area(M.loc)
		if(M:lastarea.has_gravity == 0)
			inertial_drift(M)

	/*
		if(M.flags & NOGRAV)
			inertial_drift(M)
	*/



		else if(!istype(src, /turf/space))
			M:inertia_dir = 0
	..()
	var/objects = 0
	for(var/atom/A as mob|obj|turf|area in range(1))
		if(objects > loopsanity)	break
		objects++
		spawn( 0 )
			if ((A && M))
				A.HasProximity(M, 1)
			return
	return

/turf/proc/adjacent_fire_act(turf/simulated/floor/source, temperature, volume)
	return

/turf/proc/is_plating()
	return 0
/turf/proc/is_asteroid_floor()
	return 0
/turf/proc/is_plasteel_floor()
	return 0
/turf/proc/is_light_floor()
	return 0
/turf/proc/is_grass_floor()
	return 0
/turf/proc/is_wood_floor()
	return 0
/turf/proc/is_carpet_floor()
	return 0
/turf/proc/is_catwalk()
	return 0
/turf/proc/return_siding_icon_state()		//used for grass floors, which have siding.
	return 0

/turf/proc/inertial_drift(atom/movable/A as mob|obj)
	if(!(A.last_move))	return
	if(istype(A, /obj/spacepod) && src.x > 2 && src.x < (world.maxx - 1) && src.y > 2 && src.y < (world.maxy-1))
		var/obj/spacepod/SP = A
		if(SP.Process_Spacemove(1))
			SP.inertia_dir = 0
			return
		spawn(5)
			if((SP && (SP.loc == src)))
				if(SP.inertia_dir)
					step(SP, SP.inertia_dir)
					return
	if(istype(A, /obj/structure/stool/bed/chair/cart/) && src.x > 2 && src.x < (world.maxx - 1) && src.y > 2 && src.y < (world.maxy-1))
		var/obj/structure/stool/bed/chair/cart/JC = A //A bomb!
		if(JC.Process_Spacemove(1))
			JC.inertia_dir = 0
			return
		spawn(5)
			if((JC && (JC.loc == src)))
				if(JC.inertia_dir)
					step(JC, JC.inertia_dir)
					return
				JC.inertia_dir = JC.last_move
				step(JC, JC.inertia_dir)


	if((istype(A, /mob/) && src.x > 2 && src.x < (world.maxx - 1) && src.y > 2 && src.y < (world.maxy-1)))
		var/mob/M = A
		if(M.Process_Spacemove(1))
			M.inertia_dir  = 0
			return
		spawn(5)
			if((M && !(M.anchored) && !(M.pulledby) && (M.loc == src)))
				if(M.inertia_dir)
					step(M, M.inertia_dir)
					return
				M.inertia_dir = M.last_move
				step(M, M.inertia_dir)
	return

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(src.intact)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(0)

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		del L

//Creates a new turf
/turf/proc/ChangeTurf(var/turf/N)
	if (!N)
		return

	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)

	//world << "Replacing [src.type] with [N]"

	if(connections) connections.erase_all()

	if(istype(src,/turf/simulated))
		//Yeah, we're just going to rebuild the whole thing.
		//Despite this being called a bunch during explosions,
		//the zone will only really do heavy lifting once.
		var/turf/simulated/S = src
		if(S.zone) S.zone.rebuild()

	if(ispath(N, /turf/simulated/floor))
		//if the old turf had a zone, connect the new turf to it as well - Cael
		//Adjusted by SkyMarshal 5/10/13 - The air master will handle the addition of the new turf.
		//if(zone)
		//	zone.RemoveTurf(src)
		//	if(!zone.CheckStatus())
		//		zone.SetStatus(ZONE_ACTIVE)

		var/turf/simulated/W = new N( locate(src.x, src.y, src.z) )
		//W.Assimilate_Air()

		W.lighting_lumcount += old_lumcount
		if(old_lumcount != W.lighting_lumcount)
			W.lighting_changed = 1
			lighting_controller.changed_turfs += W

		if (istype(W,/turf/simulated/floor))
			W.RemoveLattice()

		if(air_master)
			air_master.mark_for_update(src)

		W.levelupdate()
		return W

	else
		//if(zone)
		//	zone.RemoveTurf(src)
		//	if(!zone.CheckStatus())
		//		zone.SetStatus(ZONE_ACTIVE)

		var/turf/W = new N( locate(src.x, src.y, src.z) )
		W.lighting_lumcount += old_lumcount
		if(old_lumcount != W.lighting_lumcount)
			W.lighting_changed = 1
			lighting_controller.changed_turfs += W

		if(air_master)
			air_master.mark_for_update(src)

		W.levelupdate()
		return W

/*
//////Assimilate Air//////
/turf/simulated/proc/Assimilate_Air()
	var/aoxy = 0//Holders to assimilate air from nearby turfs
	var/anitro = 0
	var/aco = 0
	var/atox = 0
	var/atemp = 0
	var/turf_count = 0

	for(var/direction in cardinal)//Only use cardinals to cut down on lag
		var/turf/T = get_step(src,direction)
		if(istype(T,/turf/space))//Counted as no air
			turf_count++//Considered a valid turf for air calcs
			continue
		else if(istype(T,/turf/simulated/floor))
			var/turf/simulated/S = T
			if(S.air)//Add the air's contents to the holders
				aoxy += S.air.oxygen
				anitro += S.air.nitrogen
				aco += S.air.carbon_dioxide
				atox += S.air.toxins
				atemp += S.air.temperature
			turf_count ++
	air.oxygen = (aoxy/max(turf_count,1))//Averages contents of the turfs, ignoring walls and the like
	air.nitrogen = (anitro/max(turf_count,1))
	air.carbon_dioxide = (aco/max(turf_count,1))
	air.toxins = (atox/max(turf_count,1))
	air.temperature = (atemp/max(turf_count,1))//Trace gases can get bant
	air.update_values()

	//cael - duplicate the averaged values across adjacent turfs to enforce a seamless atmos change
	for(var/direction in cardinal)//Only use cardinals to cut down on lag
		var/turf/T = get_step(src,direction)
		if(istype(T,/turf/space))//Counted as no air
			continue
		else if(istype(T,/turf/simulated/floor))
			var/turf/simulated/S = T
			if(S.air)//Add the air's contents to the holders
				S.air.oxygen = air.oxygen
				S.air.nitrogen = air.nitrogen
				S.air.carbon_dioxide = air.carbon_dioxide
				S.air.toxins = air.toxins
				S.air.temperature = air.temperature
				S.air.update_values()
*/
/turf/proc/ReplaceWithLattice()
	src.ChangeTurf(/turf/space)
	new /obj/structure/lattice( locate(src.x, src.y, src.z) )

/turf/proc/kill_creatures(mob/U = null)//Will kill people/creatures and damage mechs./N
//Useful to batch-add creatures to the list.
	for(var/mob/living/M in src)
		if(M==U)	continue//Will not harm U. Since null != M, can be excluded to kill everyone.
		spawn(0)
			M.gib()
	for(var/obj/mecha/M in src)//Mecha are not gibbed but are damaged.
		spawn(0)
			M.take_damage(100, "brute")

/turf/proc/Bless()
	if(flags & NOJAUNT)
		return
	flags |= NOJAUNT

/////////////////////////////////////////////////////////////////////////
// Navigation procs
// Used for A-star pathfinding
////////////////////////////////////////////////////////////////////////

///////////////////////////
//Cardinal only movements
///////////////////////////

// Returns the surrounding cardinal turfs with open links
// Including through doors openable with the ID
/turf/proc/CardinalTurfsWithAccess(var/obj/item/weapon/card/id/ID)
	var/list/L = new()
	var/turf/simulated/T

	for(var/dir in cardinal)
		T = get_step(src, dir)
		if(istype(T) && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L

// Returns the surrounding cardinal turfs with open links
// Don't check for ID, doors passable only if open
/turf/proc/CardinalTurfs()
	var/list/L = new()
	var/turf/simulated/T

	for(var/dir in cardinal)
		T = get_step(src, dir)
		if(istype(T) && !T.density)
			if(!LinkBlocked(src, T))
				L.Add(T)
	return L

///////////////////////////
//All directions movements
///////////////////////////

// Returns the surrounding simulated turfs with open links
// Including through doors openable with the ID
/turf/proc/AdjacentTurfsWithAccess(var/obj/item/weapon/card/id/ID = null,var/list/closed)//check access if one is passed
	var/list/L = new()
	var/turf/simulated/T
	for(var/dir in list(NORTHWEST,NORTHEAST,SOUTHEAST,SOUTHWEST,NORTH,EAST,SOUTH,WEST)) //arbitrarily ordered list to favor non-diagonal moves in case of ties
		T = get_step(src,dir)
		if(T in closed) //turf already proceeded in A*
			continue
		if(istype(T) && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L

//Idem, but don't check for ID and goes through open doors
/turf/proc/AdjacentTurfs(var/list/closed)
	var/list/L = new()
	var/turf/simulated/T
	for(var/dir in list(NORTHWEST,NORTHEAST,SOUTHEAST,SOUTHWEST,NORTH,EAST,SOUTH,WEST)) //arbitrarily ordered list to favor non-diagonal moves in case of ties
		T = get_step(src,dir)
		if(T in closed) //turf already proceeded by A*
			continue
		if(istype(T) && !T.density)
			if(!LinkBlocked(src, T))
				L.Add(T)
	return L

// check for all turfs, including unsimulated ones
/turf/proc/AdjacentTurfsSpace(var/obj/item/weapon/card/id/ID = null, var/list/closed)//check access if one is passed
	var/list/L = new()
	var/turf/T
	for(var/dir in list(NORTHWEST,NORTHEAST,SOUTHEAST,SOUTHWEST,NORTH,EAST,SOUTH,WEST)) //arbitrarily ordered list to favor non-diagonal moves in case of ties
		T = get_step(src,dir)
		if(T in closed) //turf already proceeded by A*
			continue
		if(istype(T) && !T.density)
			if(!ID)
				if(!LinkBlocked(src, T))
					L.Add(T)
			else
				if(!LinkBlockedWithAccess(src, T, ID))
					L.Add(T)
	return L

//////////////////////////////
//Distance procs
//////////////////////////////

//Distance associates with all directions movement
/turf/proc/Distance(var/turf/T)
	return get_dist(src,T)

//  This Distance proc assumes that only cardinal movement is
//  possible. It results in more efficient (CPU-wise) pathing
//  for bots and anything else that only moves in cardinal dirs.
/turf/proc/Distance_cardinal(turf/T)
	if(!src || !T) return 0
	return abs(src.x - T.x) + abs(src.y - T.y)

////////////////////////////////////////////////////