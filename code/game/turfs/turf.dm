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


	var/turf_flags = NONE

	var/image/obscured	//camerachunks

	var/changing_turf = FALSE

	var/list/blueprint_data //for the station blueprints, images of objects eg: pipes

	/// How pathing algorithm will check if this turf is passable by itself (not including content checks). By default it's just density check.
	/// WARNING: Currently to use a density shortcircuiting this does not support dense turfs with special allow through function
	var/pathing_pass_method = TURF_PATHING_PASS_DENSITY

	/*
	Atmos Vars
	*/
	/// The pressure difference between the turf and it's neighbors. Affects movables by pulling them in the path of least resistance
	var/pressure_difference = 0
	/// The direction movables should travel when affected by pressure. Set to the biggest difference in atmos by turf neighbors
	var/pressure_direction = 0
	/// makes turfs less picky about where they transfer gas. Largely just used in the SM
	var/atmos_superconductivity = 0

	/*
	Lighting Vars
	*/
	/// Handles if the lighting should be dynamic. Generally lighting is dynamic if it's not in space
	var/dynamic_lighting = TRUE

	/// If you're curious why these are TMP vars, I don't know! TMP only affects savefiles so this does nothing :) - GDN

	/// Is the lighting on this turf inited
	var/tmp/lighting_corners_initialised = FALSE
	/// The lighting Object affecting us
	var/tmp/datum/lighting_object/lighting_object
	/// Lighting Corner datums.
	var/tmp/datum/lighting_corner/lighting_corner_NE
	var/tmp/datum/lighting_corner/lighting_corner_SE
	var/tmp/datum/lighting_corner/lighting_corner_SW
	var/tmp/datum/lighting_corner/lighting_corner_NW

	/// Which directions does this turf block the vision of, taking into account both the turf's opacity and the movable opacity_sources.
	var/directional_opacity = NONE
	/// Lazylist of movable atoms providing opacity sources.
	var/list/atom/movable/opacity_sources

	/// The general behavior of atmos on this tile.
	var/atmos_mode = ATMOS_MODE_SEALED
	/// The external environment that this tile is exposed to for ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	var/atmos_environment

	var/datum/gas_mixture/bound_to_turf/bound_air

	/// The effect used to render a pressure overlay from this tile.
	var/obj/effect/abstract/pressure_overlay/pressure_overlay

	var/list/milla_data = null

	new_attack_chain = TRUE
	/// The destination x-coordinate that atoms entering this turf will be automatically moved to.
	var/destination_x
	/// The destination y-coordinate that atoms entering this turf will be automatically moved to.
	var/destination_y
	/// The destination z-level that atoms entering this turf will be automatically moved to.
	var/destination_z

	///what /mob/oranges_ear instance is already assigned to us as there should only ever be one.
	///used for guaranteeing there is only one oranges_ear per turf when assigned, speeds up view() iteration
	var/mob/oranges_ear/assigned_oranges_ear

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
	visibility_changed()

	for(var/atom/movable/AM in src)
		Entered(AM)

	var/area/A = loc
	if(!IS_DYNAMIC_LIGHTING(src) && IS_DYNAMIC_LIGHTING(A))
		add_overlay(/obj/effect/fullbright)

	if(light_range && light_power)
		update_light()

	if(opacity)
		directional_opacity = ALL_CARDINALS

	initialize_milla()

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
	visibility_changed()
	QDEL_LIST_CONTENTS(blueprint_data)
	initialized = FALSE
	bound_air = null
	..()

/turf/attack_hand(mob/user as mob)
	. = ..()
	user.Move_Pulled(src)

/turf/attack_robot(mob/user)
	user.Move_Pulled(src)

/turf/attack_animal(mob/user)
	user.Move_Pulled(src)

/turf/attack_alien(mob/living/carbon/alien/user)
	user.Move_Pulled(src)

/turf/attack_larva(mob/user)
	user.Move_Pulled(src)

/turf/attack_slime(mob/user)
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
	else if(our_rpd.mode == RPD_TRANSIT_MODE)
		our_rpd.create_transit_tube(user, src)
	else if(our_rpd.mode == RPD_ROTATE_MODE)
		our_rpd.rotate_all_pipes(user, src)
	else if(our_rpd.mode == RPD_FLIP_MODE)
		our_rpd.flip_all_pipes(user, src)
	else if(our_rpd.mode == RPD_DELETE_MODE)
		our_rpd.delete_all_pipes(user, src)

/turf/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj, /obj/item/projectile/bullet/gyro))
		explosion(src, -1, 0, 2, cause = "[Proj.type] fired by [key_name(Proj.firer)] (hit turf)")
	..()
	return FALSE

//There's a lot of QDELETED() calls here if someone can figure out how to optimize this but not runtime when something gets deleted by a Bump/CanPass/Cross call, lemme know or go ahead and fix this mess - kevinz000
/turf/Enter(atom/movable/mover)
	// Do not call ..()
	// Byond's default turf/Enter() doesn't have the behaviour we want with Bump()
	// By default byond will call Bump() on the first dense object in contents
	// Here's hoping it doesn't stay like this for years before we finish conversion to step_
	var/atom/first_bump
	var/can_pass_self = CanPass(mover, get_dir(src, mover))

	if(can_pass_self)
		var/atom/mover_loc = mover.loc
		for(var/atom/movable/thing as anything in contents)
			if(thing == mover || thing == mover_loc) // Multi tile objects and moving out of other objects
				continue
			if(!thing.Cross(mover))
				if(QDELETED(mover)) //deleted from Cross() (CanPass is pure so it cant delete, Cross shouldnt be doing this either though, but it can happen)
					return FALSE
				if(!first_bump || (thing.layer > first_bump.layer))
					first_bump = thing
	if(QDELETED(mover)) //Mover deleted from Cross/CanPass/Bump, do not proceed.
		return FALSE
	if(!can_pass_self) //Even if mover is unstoppable they need to bump us.
		first_bump = src
	if(first_bump)
		mover.Bump(first_bump)
		return FALSE
	return TRUE

/turf/Entered(atom/movable/A, atom/OL, ignoreRest = FALSE)
	..()
	if(ismob(A))
		var/mob/O = A
		if(!O.lastarea)
			O.lastarea = get_area(O.loc)

	if((!(A) || !(src in A.locs)))
		return

	if(destination_z && destination_x && destination_y && !A.pulledby && !HAS_TRAIT(A, TRAIT_CURRENTLY_Z_MOVING) && !HAS_TRAIT(A, TRAIT_NO_EDGE_TRANSITIONS))
		var/tx = destination_x
		var/ty = destination_y
		var/turf/DT = locate(tx, ty, destination_z)
		var/itercount = 0
		while(DT.density || istype(DT.loc, /area/shuttle)) // Extend towards the center of the map, trying to look for a better place to arrive
			if(itercount++ >= 100)
				stack_trace("SPACE Z-TRANSIT ERROR: Could not find a safe place to land [A] within 100 iterations.")
				break
			if(tx < 128)
				tx++
			else
				tx--
			if(ty < 128)
				ty++
			else
				ty--
			DT = locate(tx, ty, destination_z)

		ADD_TRAIT(A, TRAIT_CURRENTLY_Z_MOVING, ROUNDSTART_TRAIT) // roundstart because its robust and won't be removed by someone being an idiot
		A.forceMove(DT)
		REMOVE_TRAIT(A, TRAIT_CURRENTLY_Z_MOVING, ROUNDSTART_TRAIT)

		itercount = 0
		var/atom/movable/current_pull = A.pulling
		while(current_pull)
			if(itercount > 100)
				stack_trace("SPACE Z-TRANSIT ERROR: [A] encountered a possible infinite loop while traveling through z-levels.")
				break
			var/turf/target_turf = get_step(current_pull.pulledby.loc, REVERSE_DIR(current_pull.pulledby.dir)) || current_pull.pulledby.loc
			ADD_TRAIT(current_pull, TRAIT_CURRENTLY_Z_MOVING, ROUNDSTART_TRAIT)
			current_pull.forceMove(target_turf)
			REMOVE_TRAIT(current_pull, TRAIT_CURRENTLY_Z_MOVING, ROUNDSTART_TRAIT)
			current_pull = current_pull.pulling
			itercount++

	return TRUE

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
	var/old_lighting_object = lighting_object
	var/old_blueprint_data = blueprint_data
	var/old_obscured = obscured
	var/old_lighting_corner_NE = lighting_corner_NE
	var/old_lighting_corner_SE = lighting_corner_SE
	var/old_lighting_corner_SW = lighting_corner_SW
	var/old_lighting_corner_NW = lighting_corner_NW
	var/old_directional_opacity = directional_opacity

	BeforeChange()
	SEND_SIGNAL(src, COMSIG_TURF_CHANGE, path, defer_change, keep_icon, ignore_air, copy_existing_baseturf)

	var/old_baseturf = baseturf
	var/old_pressure_overlay
	if(pressure_overlay)
		old_pressure_overlay = pressure_overlay
		pressure_overlay = null

	changing_turf = TRUE
	qdel(src)	//Just get the side effects and call Destroy
	var/list/old_comp_lookup = comp_lookup?.Copy()
	var/list/old_signal_procs = signal_procs?.Copy()
	var/carryover_turf_flags = turf_flags & (RESERVATION_TURF|UNUSED_RESERVATION_TURF)
	var/turf/W = new path(src)
	W.turf_flags |= carryover_turf_flags
	if(old_comp_lookup)
		LAZYOR(W.comp_lookup, old_comp_lookup)
	if(old_signal_procs)
		LAZYOR(W.signal_procs, old_signal_procs)

	if(copy_existing_baseturf)
		W.baseturf = old_baseturf

	if(!defer_change)
		W.AfterChange(ignore_air)
	W.blueprint_data = old_blueprint_data
	W.pressure_overlay = old_pressure_overlay

	lighting_corner_NE = old_lighting_corner_NE
	lighting_corner_SE = old_lighting_corner_SE
	lighting_corner_SW = old_lighting_corner_SW
	lighting_corner_NW = old_lighting_corner_NW

	if(!W.dynamic_lighting)
		W.lighting_build_overlay()
	else
		W.lighting_clear_overlay()

	if(SSlighting.initialized)
		W.lighting_object = old_lighting_object
		directional_opacity = old_directional_opacity
		recalculate_directional_opacity()

		if(lighting_object && !lighting_object.needs_update)
			lighting_object.update()

		for(var/turf/space/space_tile in RANGE_TURFS(1, src))
			space_tile.update_starlight()

	obscured = old_obscured

	return W

/turf/proc/BeforeChange()
	SHOULD_CALL_PARENT(TRUE)
	if("[z]" in GLOB.space_manager.z_list)
		var/datum/space_level/S = GLOB.space_manager.get_zlev(z)
		S.remove_from_transit(src)

/turf/proc/is_safe()
	return FALSE

// I'm including `ignore_air` because BYOND lacks positional-only arguments
/turf/proc/AfterChange(ignore_air = FALSE, keep_cabling = FALSE) //called after a turf has been replaced in ChangeTurf()
	levelupdate()
	initialize_milla()
	recalculate_atmos_connectivity()

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

	if("[z]" in GLOB.space_manager.z_list)
		var/datum/space_level/S = GLOB.space_manager.get_zlev(z)
		S.add_to_transit(src)
		S.apply_transition(src)

/turf/simulated/AfterChange(ignore_air = FALSE, keep_cabling = FALSE)
	..()
	RemoveLattice()
	if(!ignore_air)
		var/datum/milla_safe/turf_assimilate_air/milla = new()
		milla.invoke_async(src)

/datum/milla_safe/turf_assimilate_air

/datum/milla_safe/turf_assimilate_air/on_run(turf/self)
	if(isnull(self))
		return

	var/datum/gas_mixture/merged = new()
	var/turf_count = 0
	for(var/turf/T in self.GetAtmosAdjacentTurfs())
		if(isspaceturf(T))
			turf_count += 1
			continue
		if(T.blocks_air)
			continue
		merged.merge(get_turf_air(T))
		turf_count += 1
	if(turf_count > 0)
		// Average the contents of the turfs.
		merged.set_oxygen(merged.oxygen() / turf_count)
		merged.set_nitrogen(merged.nitrogen() / turf_count)
		merged.set_carbon_dioxide(merged.carbon_dioxide() / turf_count)
		merged.set_toxins(merged.toxins() / turf_count)
		merged.set_sleeping_agent(merged.sleeping_agent() / turf_count)
		merged.set_agent_b(merged.agent_b() / turf_count)
	get_turf_air(self).copy_from(merged)

/turf/proc/ReplaceWithLattice()
	ChangeTurf(baseturf, keep_icon = FALSE)
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
	flags |= BLESSED_TILE

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
	var/list/L = list()
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

/turf/proc/visibility_changed()
	if(SSticker)
		GLOB.cameranet.update_visibility(src)

/turf/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(can_lay_cable())
		if(istype(used, /obj/item/stack/cable_coil))
			var/obj/item/stack/cable_coil/C = used
			for(var/obj/structure/cable/LC in src)
				if(LC.d1 == 0 || LC.d2 == 0)
					LC.item_interaction(user, C)
					return ITEM_INTERACT_COMPLETE
			C.place_turf(src, user)
			return ITEM_INTERACT_COMPLETE
		else if(istype(used, /obj/item/rcl))
			var/obj/item/rcl/R = used
			if(R.loaded)
				for(var/obj/structure/cable/LC in src)
					if(LC.d1 == 0 || LC.d2 == 0)
						LC.item_interaction(user, R)
						return ITEM_INTERACT_COMPLETE
				R.loaded.place_turf(src, user)
				R.is_empty(user)

			return ITEM_INTERACT_COMPLETE

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
				if(istype(source, /obj/structure/cable))
					var/obj/structure/cable/source_cable = source
					if(!(source_cable.connect_type & C.connect_type))
						continue
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
	if(SSticker.current_state == GAME_STATE_STARTUP || SSticker.current_state != GAME_STATE_PLAYING)
		add_blueprints(AM)

/turf/proc/empty(turf_type = /turf/space)
	// Remove all atoms except observers, landmarks, docking ports
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

/turf/AllowDrop()
	return TRUE

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


/turf/hit_by_thrown_mob(mob/living/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	if(mob_hurt || !density)
		return
	playsound(src, 'sound/weapons/punch1.ogg', 35, 1)
	C.visible_message("<span class='danger'>[C] slams into [src]!</span>", "<span class='userdanger'>You slam into [src]!</span>")
	if(issilicon(C))
		C.adjustBruteLoss(damage)
		C.Weaken(3 SECONDS)
	else
		C.take_organ_damage(damage)
		C.KnockDown(3 SECONDS)

/turf/proc/rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return

	AddElement(/datum/element/rust)

/turf/proc/magic_rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return

	AddElement(/datum/element/rust/heretic)
	new /obj/effect/glowing_rune(src)

/// Returns a list of all attached /datum/element/decal/ for this turf
/turf/proc/get_decals()
	var/list/datum/element/decals = list()
	SEND_SIGNAL(src, COMSIG_ATOM_GET_DECALS, decals)

	return decals

/turf/proc/initialize_milla()
	var/datum/milla_safe/initialize_turf/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/initialize_turf

/datum/milla_safe/initialize_turf/on_run(turf/T)
	if(!isnull(T))
		set_tile_atmos(T, atmos_mode = T.atmos_mode, environment_id = SSmapping.environments[T.atmos_environment], innate_heat_capacity = T.heat_capacity, temperature = T.temperature)

/// Do not call this directly. Use get_readonly_air or implement /datum/milla_safe.
/turf/proc/private_unsafe_get_air()
	RETURN_TYPE(/datum/gas_mixture)
	if(isnull(bound_air))
		SSair.bind_turf(src)
	return bound_air

/// Gets a read-only version of this tile's air. Do not use if you intend to modify the air later, implement /datum/milla_safe instead.
/turf/proc/get_readonly_air()
	RETURN_TYPE(/datum/gas_mixture)
	// This is one of two intended places to call this otherwise-unsafe proc.
	var/datum/gas_mixture/bound_to_turf/air = private_unsafe_get_air()
	if(air.lastread < SSair.milla_tick)
		var/list/milla_tile = new/list(MILLA_TILE_SIZE)
		get_tile_atmos(src, milla_tile)
		air.copy_from_milla(milla_tile)
		air.lastread = SSair.milla_tick
		air.readonly = null
		air.dirty = FALSE
		air.synchronized = FALSE
	return air.get_readonly()

/// Blindly releases air to this tile. Do not use if you care what the tile previously held, implement /datum/milla_safe instead.
/turf/proc/blind_release_air(datum/gas_mixture/air)
	var/datum/milla_safe/turf_blind_release/milla = new()
	milla.invoke_async(src, air)

/datum/milla_safe/turf_blind_release

/datum/milla_safe/turf_blind_release/on_run(turf/T, datum/gas_mixture/air)
	get_turf_air(T).merge(air)

// Blindly sets the air in this tile. Do not use if you care what the tile previously held, implement /datum/milla_safe instead.
/turf/proc/blind_set_air(datum/gas_mixture/air)
	var/datum/milla_safe/turf_blind_set/milla = new()
	milla.invoke_async(src, air)

/datum/milla_safe/turf_blind_set

/datum/milla_safe/turf_blind_set/on_run(turf/T, datum/gas_mixture/air)
	get_turf_air(T).copy_from(air)

/turf/simulated/proc/update_hotspot()
	// This is a horrible (but fast) way to do this. Don't copy it.
	// It's only used here because we know we're in safe code and this method is called a ton.
	var/datum/gas_mixture/air
	var/fuel_burnt = 0
	if(isnull(active_hotspot))
		active_hotspot = new(src)
		active_hotspot.update_interval = max(1, floor(length(SSair.hotspots) / 1000))
		active_hotspot.update_tick = rand(0, active_hotspot.update_interval - 1)

	if(active_hotspot.data_tick != SSair.milla_tick)
		if(isnull(bound_air) || bound_air.lastread < SSair.milla_tick)
			air = get_readonly_air()
		else
			air = bound_air
		fuel_burnt = air.fuel_burnt()
		if(air.hotspot_volume() > 0)
			active_hotspot.temperature = air.hotspot_temperature()
			active_hotspot.volume = air.hotspot_volume() * CELL_VOLUME
		else
			active_hotspot.temperature = air.temperature()
			active_hotspot.volume = CELL_VOLUME
	else
		fuel_burnt = active_hotspot.fuel_burnt

	if(fuel_burnt < 0.001)
		// If it's old, delete it.
		if(active_hotspot.death_timer < SSair.milla_tick)
			QDEL_NULL(active_hotspot)
			return FALSE
		else
			return TRUE

	active_hotspot.death_timer = SSair.milla_tick + 4

	if(active_hotspot.update_tick == 0)
		active_hotspot.update_visuals(active_hotspot.fuel_burnt)
		active_hotspot.update_interval = max(1, floor(length(SSair.hotspots) / 1000))
	active_hotspot.update_tick = (active_hotspot.update_tick + 1) % active_hotspot.update_interval
	return TRUE

/turf/simulated/proc/update_wind()
	if(wind_tick != SSair.milla_tick)
		QDEL_NULL(wind_effect)
		wind_tick = null
		return FALSE

	if(isnull(wind_effect))
		wind_effect = new(src)

	wind_effect.dir = wind_direction(wind_x, wind_y)

	// This is a horrible (but fast) way to do this. Don't copy it.
	// It's only used here because we know we're in safe code and this method is called a ton.
	var/datum/gas_mixture/air
	if(isnull(bound_air) || bound_air.lastread < SSair.milla_tick)
		air = get_readonly_air()
	else
		air = bound_air

	var/wind = sqrt(wind_x ** 2 + wind_y ** 2)
	var/wind_strength = wind * air.total_moles() / MOLES_CELLSTANDARD
	wind_effect.alpha = min(255, 5 + wind_strength * 25)
	return TRUE

/turf/return_analyzable_air()
	return get_readonly_air()

/obj/effect/abstract/pressure_overlay
	name = null
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	// I'm really not sure this is the right var for this, but it's what the suply shuttle is using to determine if anything is blocking a tile, so let's not do that.
	simulated = FALSE
	// Please do not splat the visual effect with a shuttle.
	flags_2 = IMMUNE_TO_SHUTTLECRUSH_2
	layer = OBJ_LAYER
	invisibility = 0

	var/image/overlay

/obj/effect/abstract/pressure_overlay/Initialize(mapload)
	. = ..()
	overlay = new(icon, src, "white")
	overlay.alpha = 0
	overlay.plane = ABOVE_LIGHTING_PLANE
	overlay.blend_mode = BLEND_OVERLAY
	overlay.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

/obj/effect/abstract/pressure_overlay/onShuttleMove(turf/oldT, turf/T1, rotation, mob/calling_mob)
	// No, I don't think I will.
	return FALSE

/obj/effect/abstract/pressure_overlay/singularity_pull()
	// I am not a physical object, you have no control over me!
	return FALSE

/obj/effect/abstract/pressure_overlay/singularity_act()
	// I don't taste good, either!
	return FALSE

/turf/proc/ensure_pressure_overlay()
	if(isnull(pressure_overlay))
		for(var/obj/effect/abstract/pressure_overlay/found_overlay in src)
			pressure_overlay = found_overlay
	if(isnull(pressure_overlay))
		pressure_overlay = new(src)

	if(isnull(pressure_overlay.loc))
		// Not sure how exactly this happens, but I've seen it happen, so fix it.
		pressure_overlay.forceMove(src)

	if(isnull(pressure_overlay.overlay))
		pressure_overlay.Initialize()

	return pressure_overlay

/turf/_clear_signal_refs()
	return

/turf/proc/set_transition_north(dest_z)
	destination_x = x
	destination_y = TRANSITION_BORDER_SOUTH + 1
	destination_z = dest_z

/turf/proc/set_transition_south(dest_z)
	destination_x = x
	destination_y = TRANSITION_BORDER_NORTH - 1
	destination_z = dest_z

/turf/proc/set_transition_east(dest_z)
	destination_x = TRANSITION_BORDER_WEST + 1
	destination_y = y
	destination_z = dest_z

/turf/proc/set_transition_west(dest_z)
	destination_x = TRANSITION_BORDER_EAST - 1
	destination_y = y
	destination_z = dest_z

/turf/proc/remove_transitions()
	destination_z = initial(destination_z)

/turf/attack_ghost(mob/dead/observer/user)
	if(destination_z)
		var/turf/T = locate(destination_x, destination_y, destination_z)
		user.forceMove(T)
		return TRUE
	return ..()

/// Returns whether it is safe for an atom to move across this turf
/// TODO: Things like lava will need to have more specialized code
/// but that can wait for when we port basic mobs that may actually
/// encounter lava
/turf/proc/can_cross_safely(atom/movable/crossing)
	return TRUE

/**
 * Check whether we are blocked by something dense in our contents with respect to a specific atom.
 *
 * Arguments:
 * * exclude_mobs - If TRUE, ignores dense mobs on the turf.
 * * source_atom - If this is not null, will check whether any contents on the
 *   turf can block this atom specifically. Also ignores itself on the turf.
 * * ignore_atoms - Check will ignore any atoms in this list. Useful to prevent
 *   an atom from blocking itself on the turf.
 * * type_list - are we checking for types of atoms to ignore and not physical atoms
 */
/turf/proc/is_blocked_turf(exclude_mobs = FALSE, source_atom = null, list/ignore_atoms, type_list = FALSE)
	if(density)
		return TRUE

	for(var/atom/movable/movable_content as anything in contents)
		// If a source_atom is specified, that's what we're checking
		// blockage with respect to, so we ignore it
		if(movable_content == source_atom)
			continue

		// Prevents jaunting onto the AI core cheese, AI should always block a
		// turf due to being a dense mob even when unanchored
		if(is_ai(movable_content))
			return TRUE

		// don't consider ignored atoms or their types
		if(length(ignore_atoms))
			if(!type_list && (movable_content in ignore_atoms))
				continue
			else if(type_list && is_type_in_list(movable_content, ignore_atoms))
				continue

		// If the thing is dense AND we're including mobs or the thing isn't a
		// mob AND if there's a source atom and it cannot pass through the thing
		// on the turf, we consider the turf blocked.
		if(movable_content.density && (!exclude_mobs || !ismob(movable_content)))
			if(source_atom && movable_content.CanPass(source_atom, get_dir(src, source_atom)))
				continue
			return TRUE
	return FALSE
