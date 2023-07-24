/turf
	icon = 'icons/turf/floors.dmi'
	level = 1
	luminosity = 1

	var/intact = TRUE
	var/turf/baseturf = /turf/space
	var/slowdown = 0 //negative for faster, positive for slower
	/// used to check if pipes should be visible under the turf or not
	var/transparent_floor = FALSE

	/// Set if the turf should appear on a different layer while in-game and map editing, otherwise use normal layer.
	var/real_layer = TURF_LAYER
	layer = MAP_EDITOR_TURF_LAYER

	///Icon-smoothing variable to map a diagonal wall corner with a fixed underlay.
	var/list/fixed_underlay = null

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

	var/blocks_air = FALSE

	flags = 0

	var/image/obscured	//camerachunks

	var/changing_turf = FALSE

	var/list/blueprint_data //for the station blueprints, images of objects eg: pipes

	/// How pathing algorithm will check if this turf is passable by itself (not including content checks). By default it's just density check.
	/// WARNING: Currently to use a density shortcircuiting this does not support dense turfs with special allow through function
	var/pathing_pass_method = TURF_PATHING_PASS_DENSITY

/turf/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	if(layer == MAP_EDITOR_TURF_LAYER)
		layer = real_layer

	// by default, vis_contents is inherited from the turf that was here before
	vis_contents.Cut()

	levelupdate()
	if(length(smoothing_groups))
		sortTim(smoothing_groups) //In case it's not properly ordered, let's avoid duplicate entries with the same values.
		SET_BITFLAG_LIST(smoothing_groups)
	if(length(canSmoothWith))
		sortTim(canSmoothWith)
		if(canSmoothWith[length(canSmoothWith)] > MAX_S_TURF) //If the last element is higher than the maximum turf-only value, then it must scan turf contents for smoothing targets.
			smoothing_flags |= SMOOTH_OBJ
		SET_BITFLAG_LIST(canSmoothWith)
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)
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
	REMOVE_FROM_SMOOTH_QUEUE(src)
	// Adds the adjacent turfs to the current atmos processing
	for(var/turf/simulated/T in atmos_adjacent_turfs)
		SSair.add_to_active(T)
	SSair.remove_from_active(src)
	visibilityChanged()
	QDEL_LIST_CONTENTS(blueprint_data)
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
	var/atom/movable/tompost_bump
	var/top_layer = FALSE
	for(var/atom/movable/obstacle in large_dense)
		if(!obstacle.CanPass(mover, mover.loc, 1) && (forget != obstacle))
			if(obstacle.layer > top_layer)
				tompost_bump = obstacle
				top_layer = obstacle.layer
	if(tompost_bump)
		mover.Bump(tompost_bump, TRUE)
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
		if(O.level == 1 && O.initialized) // Only do this if the object has initialized
			O.hide(FALSE)

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L && !(L.resistance_flags & INDESTRUCTIBLE))
		qdel(L)

/turf/proc/dismantle_wall(devastated = FALSE, explode = FALSE)
	return

/turf/proc/TerraformTurf(path, defer_change = FALSE, keep_icon = TRUE, ignore_air = FALSE)
	return ChangeTurf(path, defer_change, keep_icon, ignore_air)

//Creates a new turf
/turf/proc/ChangeTurf(path, defer_change = FALSE, keep_icon = TRUE, ignore_air = FALSE, copy_existing_baseturf = TRUE)
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
	if(copy_existing_baseturf)
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

/turf/proc/is_safe()
	return FALSE

// I'm including `ignore_air` because BYOND lacks positional-only arguments
/turf/proc/AfterChange(ignore_air = FALSE, keep_cabling = FALSE) //called after a turf has been replaced in ChangeTurf()
	levelupdate()
	CalculateAdjacentTurfs()

	if(!ignore_air)
		SSair.add_to_active(src)

	//update firedoor adjacency
	var/list/turfs_to_check = get_adjacent_open_turfs(src) | src
	for(var/turf/T in turfs_to_check)
		for(var/obj/machinery/door/firedoor/FD in T)
			FD.CalculateAffectingAreas()

	// Check for weeds and either update, create or delete wall weeds
	turfs_to_check = AdjacentTurfs(open_only = TRUE, cardinal_only = FALSE)
	for(var/turf/T in turfs_to_check)
		for(var/obj/structure/alien/weeds/W in T)
			W.check_surroundings()

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

		for(var/turf/T in atmos_adjacent_turfs)
			if(isspaceturf(T))//Counted as no air
				turf_count++//Considered a valid turf for air calcs
				continue
			else if(isfloorturf(T))
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
		INVOKE_ASYNC(M, TYPE_PROC_REF(/mob, gib))
	for(var/obj/mecha/M in src)//Mecha are not gibbed but are damaged.
		INVOKE_ASYNC(M, TYPE_PROC_REF(/obj/mecha, take_damage), 100, "brute")

/turf/proc/Bless()
	flags |= NOJAUNT

/turf/proc/clean(floor_only)
	for(var/obj/effect/decal/cleanable/C in src)
		var/obj/effect/decal/cleanable/blood/B = C
		if(istype(B) && B.off_floor)
			floor_only = FALSE
		else
			qdel(C)
	color = initial(color)
	if(floor_only)
		clean_blood()

	for(var/mob/living/simple_animal/slime/M in src)
		M.adjustToxLoss(rand(5, 10))

// Defined here to avoid runtimes
/turf/proc/MakeDry(wet_setting = TURF_WET_WATER)
	return

/turf/proc/burn_down()
	return

/// Returns the adjacent turfs. Can check for density or cardinal directions only instead of all 8, or just dense turfs entirely. dense_only takes precedence over open_only.
/turf/proc/AdjacentTurfs(open_only = FALSE, cardinal_only = FALSE, dense_only = FALSE)
	var/list/L = new()
	var/turf/T
	var/list/directions = cardinal_only ? GLOB.cardinal : GLOB.alldirs
	for(var/dir in directions)
		T = get_step(src, dir)
		if(!istype(T))
			continue
		if(dense_only && !T.density)
			continue
		if((open_only && T.density) && !dense_only)
			continue
		L.Add(T)
	return L

/turf/proc/Distance(turf/T)
	return get_dist(src, T)

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

/turf/handle_fall()
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
		else if(istype(I, /obj/item/rcl))
			var/obj/item/rcl/R = I
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
	return can_have_cabling() && !intact

/*
	* # power_list()
	* returns a list power machinery on the turf and cables on the turf that have a direction equal to the one supplied in params and are currently connected to a powernet
	*
	* Arguments:
	* source - the atom that is calling this proc
	* direction - the direction that a cable must have in order to be returned in this proc i.e. d1 or d2 must equal direction
	* cable_only - if TRUE, power_list will only return cables, if FALSE it will also return power machinery
*/
/turf/proc/power_list(atom/source, direction, cable_only = FALSE)
	. = list()
	for(var/obj/AM in src)
		if(AM == source)
			continue	//we don't want to return source
		if(istype(AM, /obj/structure/cable))

			var/obj/structure/cable/C = AM
			if(C.d1 == direction || C.d2 == direction)
				. += C // one of the cables ends matches the supplied direction, add it to connnections
		if(cable_only || direction)
			continue
		if(istype(AM, /obj/machinery/power) && !istype(AM, /obj/machinery/power/apc))
			. += AM

/turf/proc/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = icon
	underlay_appearance.icon_state = icon_state
	underlay_appearance.dir = adjacency_dir
	return TRUE

/turf/proc/add_blueprints(atom/movable/AM)
	var/image/I = new
	I.plane = GAME_PLANE
	I.layer = OBJ_LAYER
	I.appearance = AM.appearance
	I.appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM
	I.loc = src
	I.dir = AM.dir
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

/**
 * Returns adjacent turfs to this turf that are reachable, in all cardinal directions
 *
 * Arguments:
 * * caller: The movable, if one exists, being used for mobility checks to see what tiles it can reach
 * * ID: An ID card that decides if we can gain access to doors that would otherwise block a turf
 * * simulated_only: Do we only worry about turfs with simulated atmos, most notably things that aren't space?
 * * no_id: When true, doors with public access will count as impassible
*/
/turf/proc/reachableAdjacentTurfs(caller, ID, simulated_only, no_id = FALSE)
	var/static/space_type_cache = typecacheof(/turf/space)
	. = list()

	for(var/iter_dir in GLOB.cardinal)
		var/turf/turf_to_check = get_step(src, iter_dir)
		if(!turf_to_check || (simulated_only && space_type_cache[turf_to_check.type]))
			continue
		if(turf_to_check.density || LinkBlockedWithAccess(turf_to_check, caller, ID, no_id = no_id))
			continue
		. += turf_to_check

// Makes an image of up to 20 things on a turf + the turf
/turf/proc/photograph(limit = 20)
	var/image/I = new()
	I.add_overlay(src)
	for(var/V in contents)
		var/atom/A = V
		if(A.invisibility)
			continue
		I.add_overlay(A)
		if(limit)
			limit--
		else
			return I
	return I


/turf/hit_by_thrown_carbon(mob/living/carbon/human/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	if(mob_hurt || !density)
		return
	playsound(src, 'sound/weapons/punch1.ogg', 35, 1)
	C.visible_message("<span class='danger'>[C] slams into [src]!</span>", "<span class='userdanger'>You slam into [src]!</span>")
	C.take_organ_damage(damage)
	C.KnockDown(3 SECONDS)
