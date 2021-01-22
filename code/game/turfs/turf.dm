/turf
	icon = 'icons/turf/floors.dmi'
	level = 1
	luminosity = 1

	var/intact = TRUE
	var/turf/baseturf = /turf/space
	var/slowdown = 0 //negative for faster, positive for slower

	///Properties for open tiles (/floor)
	/// All the gas vars, on the turf, are meant to be utilized for initializing a gas datum and setting its first gas values; the turf vars are never further modified at runtime; it is never directly used for calculations by the atmospherics system.
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/toxins = 0
	var/sleeping_agent = 0
	var/agent_b = 0

	//Properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1

	//Properties for both
	var/temperature = T20C

	var/blocks_air = 0

	var/datum/pathnode/PNode = null //associated PathNode in the A* algorithm

	flags = 0

	var/image/obscured	//camerachunks

	var/changing_turf = FALSE

	var/list/blueprint_data //for the station blueprints, images of objects eg: pipes

	var/list/footstep_sounds
	var/shoe_running_volume = 50
	var/shoe_walking_volume = 20

/turf/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	// by default, vis_contents is inherited from the turf that was here before
	vis_contents.Cut()

	levelupdate()
	if(smooth)
		queue_smooth(src)
	visibilityChanged()

	for(var/atom/movable/AM in src)
		Entered(AM)

	var/area/A = loc
	if(!IS_DYNAMIC_LIGHTING(src) && IS_DYNAMIC_LIGHTING(A))
		add_overlay(/obj/effect/fullbright)

	if(light_power && light_range)
		update_light()

	if(opacity)
		has_opaque_atom = TRUE

	return INITIALIZE_HINT_NORMAL

/turf/Destroy(force)
	. = QDEL_HINT_IWILLGC
	if(!changing_turf)
		stack_trace("Incorrect turf deletion")
	changing_turf = FALSE
	if(force)
		..()
		//this will completely wipe turf state
		var/turf/B = new world.turf(src)
		for(var/A in B.contents)
			qdel(A)
		return
	// Adds the adjacent turfs to the current atmos processing
	for(var/direction in GLOB.cardinal)
		if(atmos_adjacent_turfs & direction)
			var/turf/simulated/T = get_step(src, direction)
			if(istype(T))
				SSair.add_to_active(T)
	SSair.remove_from_active(src)
	visibilityChanged()
	QDEL_LIST(blueprint_data)
	initialized = FALSE
	..()

/turf/attack_hand(mob/user as mob)
	user.Move_Pulled(src)

/turf/ex_act(severity)
	return FALSE

/turf/rpd_act(mob/user, obj/item/rpd/our_rpd) //This is the default turf behaviour for the RPD; override it as required
	if(our_rpd.mode == RPD_ATMOS_MODE)
		our_rpd.create_atmos_pipe(user, src)
	else if(our_rpd.mode == RPD_DISPOSALS_MODE)
		for(var/obj/machinery/door/airlock/A in src)
			if(A.density)
				to_chat(user, "<span class='warning'>That type of pipe won't fit under [A]!</span>")
				return
		our_rpd.create_disposals_pipe(user, src)
	else if(our_rpd.mode == RPD_ROTATE_MODE)
		our_rpd.rotate_all_pipes(user, src)
	else if(our_rpd.mode == RPD_FLIP_MODE)
		our_rpd.flip_all_pipes(user, src)
	else if(our_rpd.mode == RPD_DELETE_MODE)
		our_rpd.delete_all_pipes(user, src)

/turf/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj, /obj/item/projectile/beam/pulse))
		src.ex_act(2)
	..()
	return FALSE

/turf/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj, /obj/item/projectile/bullet/gyro))
		explosion(src, -1, 0, 2)
	..()
	return FALSE

/turf/Enter(atom/movable/mover as mob|obj, atom/forget)
	if(!mover)
		return TRUE

	// First, make sure it can leave its square
	if(isturf(mover.loc))
		// Nothing but border objects stop you from leaving a tile, only one loop is needed
		for(var/obj/obstacle in mover.loc)
			if(!obstacle.CheckExit(mover, src) && obstacle != mover && obstacle != forget)
				mover.Bump(obstacle, TRUE)
				return FALSE

	var/list/large_dense = list()
	//Next, check objects to block entry that are on the border
	for(var/atom/movable/border_obstacle in src)
		if(border_obstacle.flags & ON_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc, 1) && (forget != border_obstacle))
				mover.Bump(border_obstacle, TRUE)
				return FALSE
		else
			large_dense += border_obstacle

	//Then, check the turf itself
	if(!src.CanPass(mover, src))
		mover.Bump(src, TRUE)
		return FALSE

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in large_dense)
		if(!obstacle.CanPass(mover, mover.loc, 1) && (forget != obstacle))
			mover.Bump(obstacle, TRUE)
			return FALSE
	return TRUE //Nothing found to block so return success!

/turf/Entered(atom/movable/M, atom/OL, ignoreRest = FALSE)
	..()
	if(ismob(M))
		var/mob/O = M
		if(!O.lastarea)
			O.lastarea = get_area(O.loc)

	// If an opaque movable atom moves around we need to potentially update visibility.
	if(M.opacity)
		has_opaque_atom = TRUE // Make sure to do this before reconsider_lights(), incase we're on instant updates. Guaranteed to be on in this case.
		reconsider_lights()

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1 && O.initialized) // Only do this if the object has initialized
			O.hide(src.intact)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(FALSE)

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		qdel(L)

/turf/proc/dismantle_wall(devastated = FALSE, explode = FALSE)
	return

/turf/proc/TerraformTurf(path, defer_change = FALSE, keep_icon = TRUE, ignore_air = FALSE)
	return ChangeTurf(path, defer_change, keep_icon, ignore_air)

//Creates a new turf
/turf/proc/ChangeTurf(path, defer_change = FALSE, keep_icon = TRUE, ignore_air = FALSE)
	if(!path)
		return
	if(!GLOB.use_preloader && path == type) // Don't no-op if the map loader requires it to be reconstructed
		return src

	set_light(0)
	var/old_opacity = opacity
	var/old_dynamic_lighting = dynamic_lighting
	var/old_affecting_lights = affecting_lights
	var/old_lighting_object = lighting_object
	var/old_blueprint_data = blueprint_data
	var/old_obscured = obscured
	var/old_corners = corners

	BeforeChange()

	var/old_baseturf = baseturf
	changing_turf = TRUE
	qdel(src)	//Just get the side effects and call Destroy
	var/turf/W = new path(src)
	W.baseturf = old_baseturf

	if(!defer_change)
		W.AfterChange(ignore_air)
	W.blueprint_data = old_blueprint_data

	recalc_atom_opacity()

	if(SSlighting.initialized)
		recalc_atom_opacity()
		lighting_object = old_lighting_object
		affecting_lights = old_affecting_lights
		corners = old_corners
		if(old_opacity != opacity || dynamic_lighting != old_dynamic_lighting)
			reconsider_lights()

		if(dynamic_lighting != old_dynamic_lighting)
			if(IS_DYNAMIC_LIGHTING(src))
				lighting_build_overlay()
			else
				lighting_clear_overlay()

		for(var/turf/space/S in RANGE_TURFS(1, src)) //RANGE_TURFS is in code\__HELPERS\game.dm
			S.update_starlight()

	obscured = old_obscured

	return W

/turf/proc/BeforeChange()
	return

// I'm including `ignore_air` because BYOND lacks positional-only arguments
/turf/proc/AfterChange(ignore_air = FALSE, keep_cabling = FALSE) //called after a turf has been replaced in ChangeTurf()
	levelupdate()
	CalculateAdjacentTurfs()

	if(SSair && !ignore_air)
		SSair.add_to_active(src)

	//update firedoor adjacency
	var/list/turfs_to_check = get_adjacent_open_turfs(src) | src
	for(var/I in turfs_to_check)
		var/turf/T = I
		for(var/obj/machinery/door/firedoor/FD in T)
			FD.CalculateAffectingAreas()

	if(!keep_cabling && !can_have_cabling())
		for(var/obj/structure/cable/C in contents)
			qdel(C)

/turf/simulated/AfterChange(ignore_air = FALSE, keep_cabling = FALSE)
	..()
	RemoveLattice()
	if(!ignore_air)
		Assimilate_Air()

//////Assimilate Air//////
/turf/simulated/proc/Assimilate_Air()
	if(air)
		var/aoxy = 0 //Holders to assimilate air from nearby turfs
		var/anitro = 0
		var/aco = 0
		var/atox = 0
		var/asleep = 0
		var/ab = 0
		var/atemp = 0
		var/turf_count = 0

		for(var/direction in GLOB.cardinal)//Only use cardinals to cut down on lag
			var/turf/T = get_step(src, direction)
			if(istype(T, /turf/space))//Counted as no air
				turf_count++//Considered a valid turf for air calcs
				continue
			else if(istype(T, /turf/simulated/floor))
				var/turf/simulated/S = T
				if(S.air)//Add the air's contents to the holders
					aoxy += S.air.oxygen
					anitro += S.air.nitrogen
					aco += S.air.carbon_dioxide
					atox += S.air.toxins
					asleep += S.air.sleeping_agent
					ab += S.air.agent_b
					atemp += S.air.temperature
				turf_count++
		air.oxygen = (aoxy / max(turf_count, 1)) //Averages contents of the turfs, ignoring walls and the like
		air.nitrogen = (anitro / max(turf_count, 1))
		air.carbon_dioxide = (aco / max(turf_count, 1))
		air.toxins = (atox / max(turf_count, 1))
		air.sleeping_agent = (asleep / max(turf_count, 1))
		air.agent_b = (ab / max(turf_count, 1))
		air.temperature = (atemp / max(turf_count, 1))
		if(SSair)
			SSair.add_to_active(src)

/turf/proc/ReplaceWithLattice()
	ChangeTurf(baseturf)
	new /obj/structure/lattice(locate(x, y, z))

/turf/proc/remove_plating(mob/user)
	return

/turf/proc/kill_creatures(mob/U = null)//Will kill people/creatures and damage mechs./N
//Useful to batch-add creatures to the list.
	for(var/mob/living/M in src)
		if(M == U)
			continue//Will not harm U. Since null != M, can be excluded to kill everyone.
		INVOKE_ASYNC(M, /mob/.proc/gib)
	for(var/obj/mecha/M in src)//Mecha are not gibbed but are damaged.
		INVOKE_ASYNC(M, /obj/mecha/.proc/take_damage, 100, "brute")

/turf/proc/Bless()
	flags |= NOJAUNT

// Defined here to avoid runtimes
/turf/proc/MakeDry(wet_setting = TURF_WET_WATER)
	return

/turf/proc/burn_down()
	return

/////////////////////////////////////////////////////////////////////////
// Navigation procs
// Used for A-star pathfinding
////////////////////////////////////////////////////////////////////////

///////////////////////////
//Cardinal only movements
///////////////////////////

// Returns the surrounding cardinal turfs with open links
// Including through doors openable with the ID
/turf/proc/CardinalTurfsWithAccess(var/obj/item/card/id/ID)
	var/list/L = new()
	var/turf/simulated/T

	for(var/dir in GLOB.cardinal)
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

	for(var/dir in GLOB.cardinal)
		T = get_step(src, dir)
		if(istype(T) && !T.density)
			if(!CanAtmosPass(T))
				L.Add(T)
	return L

///////////////////////////
//All directions movements
///////////////////////////

// Returns the surrounding simulated turfs with open links
// Including through doors openable with the ID
/turf/proc/AdjacentTurfsWithAccess(obj/item/card/id/ID = null, list/closed)//check access if one is passed
	var/list/L = new()
	var/turf/simulated/T
	for(var/dir in GLOB.alldirs2) //arbitrarily ordered list to favor non-diagonal moves in case of ties
		T = get_step(src, dir)
		if(T in closed) //turf already proceeded in A*
			continue
		if(istype(T) && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L

//Idem, but don't check for ID and goes through open doors
/turf/proc/AdjacentTurfs(list/closed)
	var/list/L = new()
	var/turf/simulated/T
	for(var/dir in GLOB.alldirs2) //arbitrarily ordered list to favor non-diagonal moves in case of ties
		T = get_step(src, dir)
		if(T in closed) //turf already proceeded by A*
			continue
		if(istype(T) && !T.density)
			if(!CanAtmosPass(T))
				L.Add(T)
	return L

// check for all turfs, including unsimulated ones
/turf/proc/AdjacentTurfsSpace(obj/item/card/id/ID = null, list/closed)//check access if one is passed
	var/list/L = new()
	var/turf/T
	for(var/dir in GLOB.alldirs2) //arbitrarily ordered list to favor non-diagonal moves in case of ties
		T = get_step(src, dir)
		if(T in closed) //turf already proceeded by A*
			continue
		if(istype(T) && !T.density)
			if(!ID)
				if(!CanAtmosPass(T))
					L.Add(T)
			else
				if(!LinkBlockedWithAccess(src, T, ID))
					L.Add(T)
	return L

//////////////////////////////
//Distance procs
//////////////////////////////

//Distance associates with all directions movement
/turf/proc/Distance(turf/T)
	return get_dist(src, T)

//  This Distance proc assumes that only cardinal movement is
//  possible. It results in more efficient (CPU-wise) pathing
//  for bots and anything else that only moves in cardinal dirs.
/turf/proc/Distance_cardinal(turf/T)
	if(!src || !T)
		return 0
	return abs(src.x - T.x) + abs(src.y - T.y)

////////////////////////////////////////////////////

/turf/acid_act(acidpwr, acid_volume)
	. = TRUE
	var/acid_type = /obj/effect/acid
	if(acidpwr >= 200) //alien acid power
		acid_type = /obj/effect/acid/alien
	var/has_acid_effect = FALSE
	for(var/obj/O in src)
		if(intact && O.level == 1) //hidden under the floor
			continue
		if(istype(O, acid_type))
			var/obj/effect/acid/A = O
			A.acid_level = min(A.level + acid_volume * acidpwr, 12000)//capping acid level to limit power of the acid
			has_acid_effect = 1
			continue
		O.acid_act(acidpwr, acid_volume)
	if(!has_acid_effect)
		new acid_type(src, acidpwr, acid_volume)

/turf/proc/acid_melt()
	return

/turf/handle_fall(mob/faller, forced)
	faller.lying = pick(90, 270)
	if(!forced)
		return
	if(has_gravity(src))
		playsound(src, "bodyfall", 50, TRUE)

/turf/singularity_act()
	if(intact)
		for(var/obj/O in contents) //this is for deleting things like wires contained in the turf
			if(O.level != 1)
				continue
			if(O.invisibility == INVISIBILITY_MAXIMUM)
				O.singularity_act()
	ChangeTurf(baseturf)
	return 2

/turf/proc/visibilityChanged()
	if(SSticker)
		GLOB.cameranet.updateVisibility(src)

/turf/attackby(obj/item/I, mob/user, params)
	if(can_lay_cable())
		if(istype(I, /obj/item/stack/cable_coil))
			var/obj/item/stack/cable_coil/C = I
			for(var/obj/structure/cable/LC in src)
				if(LC.d1 == 0 || LC.d2 == 0)
					LC.attackby(C, user)
					return
			C.place_turf(src, user)
			return TRUE
		else if(istype(I, /obj/item/twohanded/rcl))
			var/obj/item/twohanded/rcl/R = I
			if(R.loaded)
				for(var/obj/structure/cable/LC in src)
					if(LC.d1 == 0 || LC.d2 == 0)
						LC.attackby(R, user)
						return
				R.loaded.place_turf(src, user)
				R.is_empty(user)

	return FALSE

/turf/proc/can_have_cabling()
	return TRUE

/turf/proc/can_lay_cable()
	return can_have_cabling() & !intact

/turf/ratvar_act(force, ignore_mobs, probability = 40)
	. = (prob(probability) || force)
	for(var/I in src)
		var/atom/A = I
		if(ignore_mobs && ismob(A))
			continue
		if(ismob(A) || .)
			A.ratvar_act()

/turf/proc/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = icon
	underlay_appearance.icon_state = icon_state
	underlay_appearance.dir = adjacency_dir
	return TRUE

/turf/proc/add_blueprints(atom/movable/AM)
	var/image/I = new
	I.appearance = AM.appearance
	I.appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM
	I.loc = src
	I.setDir(AM.dir)
	I.alpha = 128
	LAZYADD(blueprint_data, I)

/turf/proc/add_blueprints_preround(atom/movable/AM)
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		add_blueprints(AM)

/turf/proc/empty(turf_type = /turf/space)
	// Remove all atoms except observers, landmarks, docking ports, and (un)`simulated` atoms (lighting overlays)
	var/turf/T0 = src
	for(var/X in T0.GetAllContents())
		var/atom/A = X
		if(!A.simulated)
			continue
		if(istype(A, /mob/dead))
			continue
		if(istype(A, /obj/effect/landmark))
			continue
		if(istype(A, /obj/docking_port))
			continue
		qdel(A, force = TRUE)

	T0.ChangeTurf(turf_type)

	SSair.remove_from_active(T0)
	T0.CalculateAdjacentTurfs()
	SSair.add_to_active(T0, TRUE)

/turf/AllowDrop()
	return TRUE

/turf/proc/water_act(volume, temperature, source)
 	return FALSE
