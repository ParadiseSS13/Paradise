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
	/// List of light sources affecting this turf.
	var/tmp/list/datum/light_source/affecting_lights
	/// The lighting Object affecting us
	var/tmp/atom/movable/lighting_object/lighting_object
	/// A list of our lighting corners.
	var/tmp/list/datum/lighting_corner/corners
	/// Not to be confused with opacity, this will be TRUE if there's any opaque atom on the tile.
	var/tmp/has_opaque_atom = FALSE

	/// The general behavior of atmos on this tile.
	var/atmos_mode = ATMOS_MODE_SEALED
	/// The external environment that this tile is exposed to for ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	var/atmos_environment

	var/datum/gas_mixture/bound_to_turf/bound_air

	/// The effect used to render a pressure overlay from this tile.
	var/obj/effect/pressure_overlay/pressure_overlay

	var/list/milla_data = null

	new_attack_chain = TRUE

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

	if(light_power && light_range)
		update_light()

	if(opacity)
		has_opaque_atom = TRUE

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
		explosion(src, -1, 0, 2)
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
	SEND_SIGNAL(src, COMSIG_TURF_CHANGE, path, defer_change, keep_icon, ignore_air, copy_existing_baseturf)

	var/old_baseturf = baseturf
	changing_turf = TRUE
	qdel(src)	//Just get the side effects and call Destroy
	var/list/old_comp_lookup = comp_lookup?.Copy()
	var/list/old_signal_procs = signal_procs?.Copy()

	var/turf/W = new path(src)
	if(old_comp_lookup)
		LAZYOR(W.comp_lookup, old_comp_lookup)
	if(old_signal_procs)
		LAZYOR(W.signal_procs, old_signal_procs)

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
					LC.attackby__legacy__attackchain(C, user)
					return ITEM_INTERACT_COMPLETE
			C.place_turf(src, user)
			return ITEM_INTERACT_COMPLETE
		else if(istype(used, /obj/item/rcl))
			var/obj/item/rcl/R = used
			if(R.loaded)
				for(var/obj/structure/cable/LC in src)
					if(LC.d1 == 0 || LC.d2 == 0)
						LC.attackby__legacy__attackchain(R, user)
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
	var/datum/gas_mixture/air = get_readonly_air()
	if(air.fuel_burnt() < 0.001)
		if(isnull(active_hotspot))
			return FALSE

		// If it's old, delete it.
		if(active_hotspot.death_timer < SSair.milla_tick)
			QDEL_NULL(active_hotspot)
			return FALSE
		else
			return TRUE

	if(isnull(active_hotspot))
		active_hotspot = new(src)

	active_hotspot.death_timer = SSair.milla_tick + 4
	if(air.hotspot_volume() > 0)
		active_hotspot.temperature = air.hotspot_temperature()
		active_hotspot.volume = air.hotspot_volume() * CELL_VOLUME
	else
		active_hotspot.temperature = air.temperature()
		active_hotspot.volume = CELL_VOLUME

	active_hotspot.update_visuals()
	return TRUE

/turf/simulated/proc/update_wind()
	if(wind_tick != SSair.milla_tick)
		QDEL_NULL(wind_effect)
		wind_tick = null
		return FALSE

	if(isnull(wind_effect))
		wind_effect = new(src)

	wind_effect.dir = wind_direction(wind_x, wind_y)

	var/datum/gas_mixture/air = get_readonly_air()
	var/wind = sqrt(wind_x ** 2 + wind_y ** 2)
	var/wind_strength = wind * air.total_moles() / MOLES_CELLSTANDARD
	wind_effect.alpha = min(255, 5 + wind_strength * 25)
	return TRUE

/turf/return_analyzable_air()
	return get_readonly_air()

/obj/effect/pressure_overlay
	icon_state = "nothing"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	// I'm really not sure this is the right var for this, but it's what the suply shuttle is using to determine if anything is blocking a tile, so let's not do that.
	simulated = FALSE
	// Please do not splat the visual effect with a shuttle.
	flags_2 = IMMUNE_TO_SHUTTLECRUSH_2

	var/image/overlay

/obj/effect/pressure_overlay/Initialize(mapload)
	. = ..()
	overlay = new(icon, src, "white")
	overlay.alpha = 0
	overlay.plane = ABOVE_LIGHTING_PLANE
	overlay.blend_mode = BLEND_OVERLAY
	overlay.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

/obj/effect/pressure_overlay/onShuttleMove(turf/oldT, turf/T1, rotation, mob/caller)
	// No, I don't think I will.
	return FALSE

/obj/effect/pressure_overlay/singularity_pull()
	// I am not a physical object, you have no control over me!
	return FALSE

/obj/effect/pressure_overlay/singularity_act()
	// I don't taste good, either!
	return FALSE

/turf/proc/ensure_pressure_overlay()
	if(isnull(pressure_overlay))
		for(var/obj/effect/pressure_overlay/found_overlay in src)
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
