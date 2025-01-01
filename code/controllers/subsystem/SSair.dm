#define SSAIR_DEFERREDPIPENETS 1
#define SSAIR_PIPENETS 2
#define SSAIR_ATMOSMACHINERY 3
#define SSAIR_INTERESTING_TILES 4
#define SSAIR_HOTSPOTS 5
#define SSAIR_BOUND_MIXTURES 6
#define SSAIR_MILLA_TICK 7

SUBSYSTEM_DEF(air)
	name = "Atmospherics"
	init_order = INIT_ORDER_AIR
	priority = FIRE_PRIORITY_AIR
	wait = 5
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	offline_implications = "Turfs will no longer process atmos, and all atmospheric machines (including cryotubes) will no longer function. Shuttle call recommended."
	cpu_display = SS_CPUDISPLAY_HIGH

	/// How long we took for a full pass through the subsystem. Custom-tracked version of `cost`.
	var/datum/resumable_cost_counter/cost_full = new()
	/// How long we spent sleeping while waiting for MILLA to finish the last tick, shown in SS Info's C block as ZZZ.
	var/datum/resumable_cost_counter/time_slept = new()
	/// The cost of a pass through bound gas mixtures, shown in SS Info's C block as BM.
	var/datum/resumable_cost_counter/cost_bound_mixtures = new()
	/// The cost of a MILLA tick in ms, shown in SS Info's C block as MT.
	var/cost_milla_tick = 0
	/// The cost of a pass through interesting tiles, shown in SS Info's C block as IT.
	var/datum/resumable_cost_counter/cost_interesting_tiles = new()
	/// The cost of a pass through hotspots, shown in SS Info's C block as HS.
	var/datum/resumable_cost_counter/cost_hotspots = new()
	/// The cost of a pass through pipenets, shown in SS Info's C block as PN.
	var/datum/resumable_cost_counter/cost_pipenets = new()
	/// The cost of a pass through building pipenets, shown in SS Info's C block as DPN.
	var/datum/resumable_cost_counter/cost_pipenets_to_build = new()
	/// The cost of a pass through atmos machinery, shown in SS Info's C block as AM.
	var/datum/resumable_cost_counter/cost_atmos_machinery = new()

	/// The set of current bound mixtures. Shown in SS Info as BM:x+y, where x is the length at the start of the most recent processing, and y is the number of mixtures that have been added during processing.
	var/list/bound_mixtures = list()
	/// The original length of bound_mixtures.
	var/original_bound_mixtures = 0
	/// The number of bound mixtures we saw when we last stopped processing them.
	var/last_bound_mixtures = 0
	/// The number of bound mixtures that were added during this processing cycle.
	var/added_bound_mixtures = 0
	/// The length of the most recent interesting tiles list, shown in SS Info as IT.
	var/interesting_tile_count = 0
	/// The set of current active hotspots. Length shown in SS Info as HS.
	var/list/hotspots = list()
	/// The set of pipenets that need to be built. Length shown in SS Info as PTB.
	var/list/pipenets_to_build = list()
	/// The set of active pipenets. Length shown in SS Info as PN.
	var/list/pipenets = list()
	/// The set of active atmos machinery. Length shown in SS Info as AM.
	var/list/atmos_machinery = list()

	/// A list of atmos machinery to set up in Initialize.
	var/list/machinery_to_construct = list()

	/// An arbitrary list of stuff currently being processed.
	var/list/currentrun = list()

	/// Which step we're currently on, used to let us resume if our time budget elapses.
	var/currentpart = SSAIR_DEFERREDPIPENETS

	/// Is MILLA currently in synchronous mode? TRUE if data is fresh and changes can be made, FALSE if data is from last tick and changes cannot be made (because this tick is still processing).
	var/is_synchronous = TRUE

	/// Are we currently running in a MILLA-safe context, i.e. is is_synchronous *guaranteed* to be TRUE. Nothing outside of this file should change this.
	VAR_PRIVATE/in_milla_safe_code = FALSE

	/// When did we start the last MILLA tick?
	var/milla_tick_start = null

	/// Is MILLA (and hence SSair) reliably healthy?
	var/healthy = TRUE

	/// When was MILLA last seen unhealthy?
	var/last_unhealthy = 0

	/// A list of callbacks waiting for MILLA to finish its tick and enter synchronous mode.
	var/list/waiting_for_sync = list()

/// A cost counter for resumable, repeating processes.
/datum/resumable_cost_counter
	var/last_complete_ms = 0
	var/ongoing_ms = 0

/// Updates the counter based on the time spent making progress and whether we finished the task.
/datum/resumable_cost_counter/proc/record_progress(cost_ms, finished)
	if(finished)
		last_complete_ms = ongoing_ms + cost_ms
		ongoing_ms = 0
	else
		ongoing_ms += cost_ms

/// Gets a display string for this cost counter.
/datum/resumable_cost_counter/proc/to_string()
	if(ongoing_ms > last_complete_ms)
		// We're in the middle of a task that's already longer than the prior one took in total, report the in-progress time instead, but mark that it's still incomplete with a +
		return "[round(ongoing_ms, 1)]+"
	return "[round(last_complete_ms, 1)]"

/datum/controller/subsystem/air/get_cost()
	return cost_full.to_string()

/datum/controller/subsystem/air/get_stat_details()
	var/list/msg = list()
	msg += "C:{"
	msg += "ZZZ:[time_slept.to_string()]|"
	msg += "BM:[cost_bound_mixtures.to_string()]|"
	msg += "MT:[round(cost_milla_tick,1)]|"
	msg += "IT:[cost_interesting_tiles.to_string()]|"
	msg += "HS:[cost_hotspots.to_string()]|"
	msg += "PN:[cost_pipenets.to_string()]|"
	msg += "PTB:[cost_pipenets_to_build.to_string()]|"
	msg += "AM:[cost_atmos_machinery.to_string()]"
	msg += "} "
	msg += "BM:[original_bound_mixtures]+[added_bound_mixtures]|"
	msg += "IT:[interesting_tile_count]|"
	msg += "HS:[length(hotspots)]|"
	msg += "PN:[length(pipenets)]|"
	msg += "AM:[length(atmos_machinery)]|"
	return msg.Join("")

/datum/controller/subsystem/air/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["hotspots"] = length(hotspots)
	cust["interesting turfs"] = interesting_tile_count
	.["cost"] = cost_full.last_complete_ms
	.["custom"] = cust

/datum/controller/subsystem/air/Initialize()
	in_milla_safe_code = TRUE

	setup_overlays() // Assign icons and such for gas-turf-overlays
	setup_allturfs()
	setup_write_to_milla()
	setup_atmos_machinery(GLOB.machines)
	setup_pipenets(GLOB.machines)
	for(var/obj/machinery/atmospherics/A in machinery_to_construct)
		A.initialize_atmos_network()

	in_milla_safe_code = FALSE

/datum/controller/subsystem/air/Recover()
	hotspots = SSair.hotspots
	pipenets_to_build = SSair.pipenets_to_build
	pipenets = SSair.pipenets
	atmos_machinery = SSair.atmos_machinery
	machinery_to_construct = SSair.machinery_to_construct
	currentrun = SSair.currentrun
	currentpart = SSair.currentpart
	is_synchronous = SSair.is_synchronous

/datum/controller/subsystem/air/fire(resumed = 0)
	// All atmos stuff assumes MILLA is synchronous. Ensure it actually is.
	if(!is_synchronous)
		var/timer = TICK_USAGE_REAL

		while(!is_synchronous)
			// Sleep for 1ms.
			sleep(0.01)
			if(MC_TICK_CHECK)
				time_slept.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), FALSE)
				cost_full.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), FALSE)
				return

		cost_full.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), FALSE)
		time_slept.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), TRUE)

	fire_sleepless(resumed)

/datum/controller/subsystem/air/proc/fire_sleepless(resumed)
	// Any proc that wants MILLA to be synchronous should not sleep.
	SHOULD_NOT_SLEEP(TRUE)
	in_milla_safe_code = TRUE

	var/timer = TICK_USAGE_REAL

	if(currentpart == SSAIR_DEFERREDPIPENETS || !resumed)
		timer = TICK_USAGE_REAL

		build_pipenets(resumed)

		cost_pipenets_to_build.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), state != SS_PAUSED && state != SS_PAUSING)
		cost_full.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), FALSE)
		if(state == SS_PAUSED || state == SS_PAUSING)
			in_milla_safe_code = FALSE
			return
		resumed = 0
		currentpart = SSAIR_PIPENETS

	if(currentpart == SSAIR_PIPENETS || !resumed)
		timer = TICK_USAGE_REAL

		process_pipenets(resumed)

		cost_pipenets.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), state != SS_PAUSED && state != SS_PAUSING)
		cost_full.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), FALSE)
		if(state == SS_PAUSED || state == SS_PAUSING)
			in_milla_safe_code = FALSE
			return
		resumed = 0
		currentpart = SSAIR_ATMOSMACHINERY

	if(currentpart == SSAIR_ATMOSMACHINERY)
		timer = TICK_USAGE_REAL

		process_atmos_machinery(resumed)

		cost_atmos_machinery.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), state != SS_PAUSED && state != SS_PAUSING)
		cost_full.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), FALSE)
		if(state == SS_PAUSED || state == SS_PAUSING)
			in_milla_safe_code = FALSE
			return
		resumed = 0
		currentpart = SSAIR_INTERESTING_TILES

	if(currentpart == SSAIR_INTERESTING_TILES)
		timer = TICK_USAGE_REAL

		process_interesting_tiles(resumed)

		cost_interesting_tiles.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), state != SS_PAUSED && state != SS_PAUSING)
		cost_full.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), FALSE)
		if(state == SS_PAUSED || state == SS_PAUSING)
			in_milla_safe_code = FALSE
			return
		resumed = 0
		currentpart = SSAIR_HOTSPOTS

	if(currentpart == SSAIR_HOTSPOTS)
		timer = TICK_USAGE_REAL

		process_hotspots(resumed)

		cost_hotspots.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), state != SS_PAUSED && state != SS_PAUSING)
		cost_full.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), FALSE)
		if(state == SS_PAUSED || state == SS_PAUSING)
			in_milla_safe_code = FALSE
			return
		resumed = 0
		currentpart = SSAIR_BOUND_MIXTURES

	if(currentpart == SSAIR_BOUND_MIXTURES)
		timer = TICK_USAGE_REAL

		process_bound_mixtures(resumed)

		cost_bound_mixtures.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), state != SS_PAUSED && state != SS_PAUSING)
		cost_full.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), FALSE)
		if(state == SS_PAUSED || state == SS_PAUSING)
			in_milla_safe_code = FALSE
			return
		resumed = 0
		currentpart = SSAIR_MILLA_TICK

	if(currentpart == SSAIR_MILLA_TICK)
		timer = TICK_USAGE_REAL

		spawn_milla_tick_thread()
		is_synchronous = FALSE

		cost_milla_tick = MC_AVERAGE(cost_milla_tick, get_milla_tick_time())
		cost_full.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), state != SS_PAUSED && state != SS_PAUSING)
		if(state == SS_PAUSED || state == SS_PAUSING)
			in_milla_safe_code = FALSE
			return
		resumed = 0

	currentpart = SSAIR_DEFERREDPIPENETS
	in_milla_safe_code = FALSE

/datum/controller/subsystem/air/proc/build_pipenets(resumed = 0)
	if(!resumed)
		src.currentrun = pipenets_to_build.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/obj/machinery/atmospherics/A = currentrun[length(currentrun)]
		currentrun.len--
		if(A)
			A.build_network(remove_deferral = TRUE)
		else
			pipenets_to_build.Remove(A)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_pipenets(resumed = 0)
	if(!resumed)
		src.currentrun = pipenets.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/datum/pipeline/thing = currentrun[length(currentrun)]
		currentrun.len--
		if(thing)
			thing.process()
		else
			pipenets.Remove(thing)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_atmos_machinery(resumed = 0)
	var/seconds = wait * 0.1
	if(!resumed)
		src.currentrun = atmos_machinery.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/obj/machinery/atmospherics/M = currentrun[length(currentrun)]
		currentrun.len--
		if(isnull(M) || (M.process_atmos(seconds) == PROCESS_KILL))
			atmos_machinery -= M
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_hotspots(resumed = 0)
	if(!resumed)
		src.currentrun = hotspots.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/obj/effect/hotspot/H = currentrun[length(currentrun)]
		currentrun.len--
		if(H)
			H.process()
		else
			hotspots -= H
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_interesting_tiles(resumed = 0)
	if(!resumed)
		// Fetch the list of interesting tiles from MILLA.
		src.currentrun = get_interesting_atmos_tiles()
		interesting_tile_count = length(src.currentrun) / MILLA_INTERESTING_TILE_SIZE
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		// Pop a tile off the list.
		var/offset = length(currentrun) - MILLA_INTERESTING_TILE_SIZE
		var/turf/T = currentrun[offset + MILLA_INDEX_TURF]
		if(!istype(T))
			currentrun.len -= MILLA_INTERESTING_TILE_SIZE
			if(MC_TICK_CHECK)
				return
			continue

		var/reasons = currentrun[offset + MILLA_INDEX_INTERESTING_REASONS]
		var/x_flow = currentrun[offset + MILLA_INDEX_AIRFLOW_X]
		var/y_flow = currentrun[offset + MILLA_INDEX_AIRFLOW_Y]
		var/milla_tile = currentrun.Copy(offset + 1, offset + 1 + MILLA_TILE_SIZE + 1)
		currentrun.len -= MILLA_INTERESTING_TILE_SIZE

		// Bind the MILLA tile we got, if needed.
		if(isnull(T.bound_air))
			bind_turf(T, milla_tile)
		else if(T.bound_air.lastread < times_fired)
			T.bound_air.copy_from_milla(milla_tile)
			T.bound_air.lastread = times_fired
			T.bound_air.readonly = null
			T.bound_air.dirty = FALSE
			T.bound_air.synchronized = FALSE

		if(reasons & MILLA_INTERESTING_REASON_DISPLAY)
			var/turf/simulated/S = T
			if(istype(S))
				S.update_visuals()

		if(reasons & MILLA_INTERESTING_REASON_HOT)
			var/datum/gas_mixture/air = T.get_readonly_air()
			T.hotspot_expose(air.temperature(), CELL_VOLUME)
			for(var/atom/movable/item in T)
				item.temperature_expose(air, air.temperature(), CELL_VOLUME)
			T.temperature_expose(air, air.temperature(), CELL_VOLUME)

		if(reasons & MILLA_INTERESTING_REASON_WIND)
			T.high_pressure_movements(x_flow, y_flow)

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_bound_mixtures(resumed = 0)
	if(!resumed)
		original_bound_mixtures = length(bound_mixtures)
		last_bound_mixtures = length(bound_mixtures)
	// Note that we do NOT copy this list to src.currentrun. We're fine with things being added to it as we work, because it all needs to get written before the next MILLA tick.
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = bound_mixtures
	added_bound_mixtures = length(currentrun) - last_bound_mixtures
	while(length(currentrun))
		var/datum/gas_mixture/bound_to_turf/mixture = currentrun[length(currentrun)]
		currentrun.len--
		mixture.synchronized = FALSE
		if(mixture.dirty)
			// This is one of two places expected to call this otherwise-unsafe method.
			mixture.private_unsafe_write()
			mixture.dirty = FALSE
		if(MC_TICK_CHECK)
			last_bound_mixtures = length(bound_mixtures)
			return

/datum/controller/subsystem/air/proc/setup_allturfs(list/turfs_to_init = block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz)))
	for(var/turf/T as anything in turfs_to_init)
		T.Initialize_Atmos(times_fired)
		CHECK_TICK

/datum/controller/subsystem/air/proc/setup_allturfs_sleepless(list/turfs_to_init = block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz)))
	for(var/turf/T as anything in turfs_to_init)
		T.Initialize_Atmos(times_fired)

/datum/controller/subsystem/air/proc/setup_write_to_milla()
	var/watch = start_watch()
	log_startup_progress("Writing tiles to MILLA...")

	//cache for sanic speed (lists are references anyways)
	var/list/cache = bound_mixtures
	var/count = length(cache)
	while(length(cache))
		var/datum/gas_mixture/bound_to_turf/mixture = cache[length(cache)]
		cache.len--
		if(mixture.dirty)
			in_milla_safe_code = TRUE
			// This is one of two places expected to call this otherwise-unsafe method.
			mixture.private_unsafe_write()
			in_milla_safe_code = FALSE
		mixture.bound_turf.bound_air = null
		mixture.bound_turf = null
		CHECK_TICK

	log_startup_progress("Wrote [count] tiles in [stop_watch(watch)]s.")

/datum/controller/subsystem/air/proc/setup_atmos_machinery(list/machines_to_init)
	var/watch = start_watch()
	log_startup_progress("Initializing atmospherics machinery...")
	var/count = _setup_atmos_machinery(machines_to_init)
	log_startup_progress("Initialized [count] atmospherics machines in [stop_watch(watch)]s.")

// this underscored variant is so that we can have a means of late initing
// atmos machinery without a loud announcement to the world
/datum/controller/subsystem/air/proc/_setup_atmos_machinery(list/machines_to_init)
	var/count = 0
	for(var/obj/machinery/atmospherics/A in machines_to_init)
		A.atmos_init()
		count++
		CHECK_TICK
	return count

//this can't be done with setup_atmos_machinery() because
//	all atmos machinery has to initalize before the first
//	pipenet can be built.
/datum/controller/subsystem/air/proc/setup_pipenets(list/pipes)
	var/watch = start_watch()
	log_startup_progress("Initializing pipe pipenets...")
	var/count = _setup_pipenets(pipes)
	log_startup_progress("Initialized [count] pipenets in [stop_watch(watch)]s.")

// An underscored wrapper that exists for the same reason
// the machine init wrapper does
/datum/controller/subsystem/air/proc/_setup_pipenets(list/pipes)
	var/count = 0
	for(var/obj/machinery/atmospherics/machine in pipes)
		machine.build_network()
		count++
	return count

/obj/effect/overlay/turf
	icon = 'icons/effects/tile_effects.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE  // should only appear in vis_contents, but to be safe
	layer = FLY_LAYER
	appearance_flags = TILE_BOUND | RESET_TRANSFORM | RESET_COLOR

/obj/effect/overlay/turf/plasma
	icon_state = "plasma"

/obj/effect/overlay/turf/sleeping_agent
	icon_state = "sleeping_agent"

/datum/controller/subsystem/air/proc/setup_overlays()
	GLOB.plmaster = new /obj/effect/overlay/turf/plasma
	GLOB.slmaster = new /obj/effect/overlay/turf/sleeping_agent

/datum/controller/subsystem/air/proc/bind_turf(turf/T, list/milla_tile = null)
	var/datum/gas_mixture/bound_to_turf/B = new()
	T.bound_air = B
	B.bound_turf = T
	if(isnull(milla_tile))
		milla_tile = new/list(MILLA_TILE_SIZE)
		get_tile_atmos(T, milla_tile)
	B.copy_from_milla(milla_tile)
	B.lastread = src.times_fired
	B.readonly = null
	B.dirty = FALSE
	B.synchronized = FALSE


/// Similar to addtimer, but triggers once MILLA enters synchronous mode.
/datum/controller/subsystem/air/proc/synchronize(datum/milla_safe/CB)
	// Any proc that wants MILLA to be synchronous should not sleep.
	SHOULD_NOT_SLEEP(TRUE)

	if(is_synchronous)
		var/was_safe = SSair.in_milla_safe_code
		SSair.in_milla_safe_code = TRUE
		// This is one of two intended places to call this otherwise-unsafe proc.
		CB.private_unsafe_invoke()
		SSair.in_milla_safe_code = was_safe
		return

	waiting_for_sync += CB

/datum/controller/subsystem/air/proc/is_in_milla_safe_code()
	return in_milla_safe_code

/datum/controller/subsystem/air/proc/on_milla_tick_finished()
	is_synchronous = TRUE
	in_milla_safe_code = TRUE
	for(var/datum/milla_safe/CB as anything in waiting_for_sync)
		// This is one of two intended places to call this otherwise-unsafe proc.
		CB.private_unsafe_invoke()
	waiting_for_sync.Cut()
	in_milla_safe_code = FALSE

/proc/milla_tick_finished()
	// Any proc that wants MILLA to be synchronous should not sleep.
	SHOULD_NOT_SLEEP(TRUE)

	SSair.on_milla_tick_finished()

/// Create a subclass of this and implement `on_run` to manipulate tile air safely.
/datum/milla_safe
	var/run_args = list()

/// All subclasses should implement this.
/datum/milla_safe/proc/on_run(...)
	// Any proc that wants MILLA to be synchronous should not sleep.
	SHOULD_NOT_SLEEP(TRUE)

	CRASH("[src.type] does not implement on_run")

/// Call this to make the subclass run when it's safe to do so. Args will be passed to on_run.
/datum/milla_safe/proc/invoke_async(...)
	run_args = args.Copy()
	SSair.synchronize(src)

/// Do not call this yourself. This is what is called to run your code from a safe context.
/datum/milla_safe/proc/private_unsafe_invoke()
	soft_assert_safe()
	on_run(arglist(run_args))

/// Used internally to check that we're running safely, but without breaking things worse if we aren't.
/datum/milla_safe/proc/soft_assert_safe()
	ASSERT(SSair.is_in_milla_safe_code())

/// Fetch the air for a turf. Only use from `on_run`.
/datum/milla_safe/proc/get_turf_air(turf/T)
	RETURN_TYPE(/datum/gas_mixture)
	soft_assert_safe()
	// This is one of two intended places to call this otherwise-unsafe proc.
	var/datum/gas_mixture/bound_to_turf/air = T.private_unsafe_get_air()
	if(air.lastread < SSair.times_fired)
		var/list/milla_tile = new/list(MILLA_TILE_SIZE)
		get_tile_atmos(T, milla_tile)
		air.copy_from_milla(milla_tile)
		air.lastread = SSair.times_fired
		air.readonly = null
		air.dirty = FALSE
	if(!air.synchronized)
		air.synchronized = TRUE
		SSair.bound_mixtures += air
	return air

/// Add air to a turf. Only use from `on_run`.
/datum/milla_safe/proc/add_turf_air(turf/T, datum/gas_mixture/air)
	var/datum/gas_mixture/turf_air = get_turf_air(T)
	turf_air.merge(air)

/// Completely replace the air for a turf. Only use from `on_run`.
/datum/milla_safe/proc/set_turf_air(turf/T, datum/gas_mixture/air)
	var/datum/gas_mixture/turf_air = get_turf_air(T)
	turf_air.copy_from(air)

#undef SSAIR_DEFERREDPIPENETS
#undef SSAIR_PIPENETS
#undef SSAIR_ATMOSMACHINERY
#undef SSAIR_INTERESTING_TILES
#undef SSAIR_HOTSPOTS
#undef SSAIR_BOUND_MIXTURES
#undef SSAIR_MILLA_TICK
