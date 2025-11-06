#define SSAIR_DEFERREDPIPENETS 1
#define SSAIR_PIPENETS 2
#define SSAIR_ATMOSMACHINERY 3
#define SSAIR_INTERESTING_TILES 4
#define SSAIR_HOTSPOTS 5
#define SSAIR_WINDY_TILES 6
#define SSAIR_BOUND_MIXTURES 7
#define SSAIR_PRESSURE_OVERLAY 8
#define SSAIR_MILLA_TICK 9

SUBSYSTEM_DEF(air)
	name = "Atmospherics"
	init_order = INIT_ORDER_AIR
	priority = FIRE_PRIORITY_AIR
	// The MC really doesn't like it if we sleep (even though it's supposed to), and ends up running us continuously. Instead, we ask it to run us every tick, and "sleep" by skipping the current tick.
	wait = 1
	flags = SS_BACKGROUND | SS_TICKER
	/// How long we actually wait between ticks. Will round up to the next server tick.
	var/self_wait = 0.15 SECONDS
	/// MC seems to not be good at tracking whether SSair pauses, so track that ourselves.
	var/was_paused = FALSE
	/// And that means we also nee a replacement for times_fired.
	var/milla_tick = 0
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	offline_implications = "Turfs will no longer process atmos, and all atmospheric machines (including cryotubes) will no longer function. Shuttle call recommended."
	cpu_display = SS_CPUDISPLAY_HIGH

	/// When did we last finish running a complete tick?
	var/last_complete_tick = 0
	/// When did we last start a tick?
	var/last_tick_start = 0

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
	/// The cost of a pass through windy tiles, shown in SS Info's C block as WT.
	var/datum/resumable_cost_counter/cost_windy_tiles = new()
	/// The cost of a pass through pipenets, shown in SS Info's C block as PN.
	var/datum/resumable_cost_counter/cost_pipenets = new()
	/// The cost of a pass through building pipenets, shown in SS Info's C block as DPN.
	var/datum/resumable_cost_counter/cost_pipenets_to_build = new()
	/// The cost of a pass through atmos machinery, shown in SS Info's C block as AM.
	var/datum/resumable_cost_counter/cost_atmos_machinery = new()
	/// The cost of a pass through loading pressure tiles, shown in SS Info's C block as PT.
	var/datum/resumable_cost_counter/cost_pressure_tiles = new()

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
	/// The length of the most recent hotspot list, shown in SS Info as HS.
	var/hotspot_count = 0
	/// The length of the most recent windy tiles list, shown in SS Info as WT.
	var/windy_tile_count = 0
	/// The set of pipenets that need to be built. Length shown in SS Info as PTB.
	var/list/pipenets_to_build = list()
	/// The set of active pipenets. Length shown in SS Info as PN.
	var/list/pipenets = list()
	/// The set of active atmos machinery. Length shown in SS Info as AM.
	var/list/atmos_machinery = list()
	/// The set of tiles that are currently on fire.
	var/list/hotspots
	/// The set of tiles that are still on fire after this tick.
	var/list/new_hotspots
	/// The set of tiles that are currently experiencing wind.
	var/list/windy_tiles
	/// The set of tiles that are still experiencing wind after this tick.
	var/list/new_windy_tiles

	/// A list of atmos machinery to set up in Initialize.
	var/list/machinery_to_construct = list()

	/// An arbitrary list of stuff currently being processed.
	var/list/currentrun = list()

	/// Which step we're currently on, used to let us resume if our time budget elapses.
	var/currentpart = SSAIR_DEFERREDPIPENETS

	/// Is MILLA currently idle? TRUE if the MILLA tick has finished, meaning data is fresh and changes can be made. FALSE if MILLA is currently running a tick, meaning data is from last tick and changes cannot be made.
	var/milla_idle = TRUE

	/// Are we currently running in a MILLA-safe context, i.e. is milla_idle *guaranteed* to be TRUE. Nothing outside of this file should change this.
	VAR_PRIVATE/in_milla_safe_code = FALSE

	/// What sleeping callbacks are currently running?
	VAR_PRIVATE/list/sleepers = list()

	/// A list of callbacks waiting for MILLA to finish its tick and enter synchronous mode.
	var/list/waiting_for_sync = list()
	var/list/sleepable_waiting_for_sync = list()

	/// The coordinates of the pressure image we're currently loading.
	var/pressure_x = 0
	var/pressure_y = 0
	var/pressure_z = 0

	/// The people who were using the pressure HUD last tick.
	var/list/pressure_hud_users = list()

	/// What alpha to use for the pressure overlay. Applies to everyone using the overlay.
	var/pressure_overlay_alpha = 50

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
	msg += "WT:[cost_windy_tiles.to_string()]|"
	msg += "PN:[cost_pipenets.to_string()]|"
	msg += "PTB:[cost_pipenets_to_build.to_string()]|"
	msg += "AM:[cost_atmos_machinery.to_string()]|"
	msg += "PT:[cost_pressure_tiles.to_string()]"
	msg += "} "
	msg += "BM:[original_bound_mixtures]+[added_bound_mixtures]|"
	msg += "IT:[interesting_tile_count]|"
	msg += "HS:[hotspot_count]|"
	msg += "WT:[windy_tile_count]|"
	msg += "PN:[length(pipenets)]|"
	msg += "AM:[length(atmos_machinery)]|"
	return msg.Join("")

/datum/controller/subsystem/air/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["interesting turfs"] = interesting_tile_count
	cust["hotspots"] = hotspot_count
	cust["windy turfs"] = windy_tile_count
	.["cost"] = cost_full.last_complete_ms
	.["custom"] = cust

/datum/controller/subsystem/air/Initialize()
	in_milla_safe_code = TRUE

	setup_overlays() // Assign icons and such for gas-turf-overlays
	setup_turfs()
	setup_atmos_machinery(SSmachines.get_by_type(/obj/machinery/atmospherics))
	setup_pipenets(SSmachines.get_by_type(/obj/machinery/atmospherics))
	for(var/obj/machinery/atmospherics/A in machinery_to_construct)
		A.initialize_atmos_network()

	in_milla_safe_code = FALSE

/datum/controller/subsystem/air/Recover()
	pipenets_to_build = SSair.pipenets_to_build
	pipenets = SSair.pipenets
	atmos_machinery = SSair.atmos_machinery
	machinery_to_construct = SSair.machinery_to_construct
	currentrun = SSair.currentrun
	currentpart = SSair.currentpart
	milla_idle = SSair.milla_idle

/datum/controller/subsystem/air/pause()
	was_paused = TRUE
	return ..()

/datum/controller/subsystem/air/fire(resumed = 0)
	// All atmos stuff assumes MILLA is synchronous. Ensure it actually is.
	var/now = world.timeofday + (world.tick_lag * world.tick_usage) / 100
	var/elapsed = now - last_complete_tick
	if(!milla_idle || length(sleepers) || (elapsed >= 0 && elapsed < self_wait))
		return

	if(last_tick_start <= last_complete_tick)
		last_tick_start = now
		time_slept.record_progress(max(0, elapsed) * 100, TRUE)

		// Run the sleepless callbacks again in case more showed up since on_milla_tick_finished()
		run_sleepless_callbacks()

	fire_sleepless(resumed || was_paused)

/datum/controller/subsystem/air/proc/fire_sleepless(resumed)
	// Any proc that wants MILLA to be synchronous should not sleep.
	SHOULD_NOT_SLEEP(TRUE)
	in_milla_safe_code = TRUE
	was_paused = FALSE

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
		currentpart = SSAIR_WINDY_TILES

	if(currentpart == SSAIR_WINDY_TILES)
		timer = TICK_USAGE_REAL

		process_windy_tiles(resumed)

		cost_windy_tiles.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), state != SS_PAUSED && state != SS_PAUSING)
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
		currentpart = SSAIR_PRESSURE_OVERLAY

	if(currentpart == SSAIR_PRESSURE_OVERLAY)
		timer = TICK_USAGE_REAL

		process_pressure_overlay(resumed)

		cost_pressure_tiles.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), state != SS_PAUSED && state != SS_PAUSING)
		cost_full.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), FALSE)
		if(state == SS_PAUSED || state == SS_PAUSING)
			in_milla_safe_code = FALSE
			return
		resumed = 0
		currentpart = SSAIR_MILLA_TICK

	if(currentpart == SSAIR_MILLA_TICK)
		timer = TICK_USAGE_REAL

		spawn_milla_tick_thread()
		milla_tick++
		milla_idle = FALSE

		cost_milla_tick = MC_AVERAGE(cost_milla_tick, get_milla_tick_time())
		cost_full.record_progress(TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer), FALSE)
		if(state == SS_PAUSED || state == SS_PAUSING)
			in_milla_safe_code = FALSE
			return
		resumed = 0

	currentpart = SSAIR_DEFERREDPIPENETS
	last_complete_tick = world.timeofday + (world.tick_lag * world.tick_usage) / 100
	cost_full.record_progress(0, TRUE)
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
	var/list/supermatters = list()
	while(length(currentrun))
		var/obj/machinery/atmospherics/M = currentrun[length(currentrun)]
		currentrun.len--
		if(istype(M, /obj/machinery/atmospherics/supermatter_crystal))
			supermatters += M
		else if(isnull(M) || (M.process_atmos(seconds) == PROCESS_KILL))
			atmos_machinery -= M
		if(MC_TICK_CHECK)
			for(var/SM in supermatters)
				currentrun += SM
			return
	while(length(supermatters))
		var/obj/machinery/atmospherics/supermatter_crystal/SM = supermatters[length(supermatters)]
		supermatters.len--
		if(isnull(SM) || (SM.process_atmos(seconds) == PROCESS_KILL))
			atmos_machinery -= SM
		if(MC_TICK_CHECK)
			for(var/other_sm in supermatters)
				currentrun += other_sm
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

		// Bind the MILLA tile we got, if needed.
		if(reasons & MILLA_INTERESTING_REASON_DISPLAY)
			var/milla_tile = currentrun.Copy(offset + 1, offset + 1 + MILLA_TILE_SIZE + 1)
			if(isnull(T.bound_air))
				bind_turf(T, milla_tile)
			else if(T.bound_air.lastread < milla_tick)
				T.bound_air.copy_from_milla(milla_tile)
				T.bound_air.lastread = milla_tick
				T.bound_air.readonly = null
				T.bound_air.dirty = FALSE
				T.bound_air.synchronized = FALSE

			var/turf/simulated/S = T
			if(istype(S))
				S.update_visuals()

		if(reasons & MILLA_INTERESTING_REASON_HOT)
			var/temperature = currentrun[offset + MILLA_INDEX_TEMPERATURE]
			var/fuel_burnt = currentrun[offset + MILLA_INDEX_FUEL_BURNT]
			var/hotspot_temperature = currentrun[offset + MILLA_INDEX_HOTSPOT_TEMPERATURE]
			var/hotspot_volume = currentrun[offset + MILLA_INDEX_HOTSPOT_VOLUME]

			var/turf/simulated/S = T
			if(istype(S))
				if(isnull(S.active_hotspot))
					// Wasn't an active hotspot before, add it.
					hotspots += S
				else
					S.active_hotspot.temperature = temperature
					S.active_hotspot.fuel_burnt = fuel_burnt
					S.active_hotspot.data_tick = milla_tick
					if(hotspot_volume > 0)
						S.active_hotspot.temperature = hotspot_temperature
						S.active_hotspot.volume = hotspot_volume * CELL_VOLUME
					else
						S.active_hotspot.temperature = temperature
						S.active_hotspot.volume = CELL_VOLUME

				T.temperature_expose(temperature)
				for(var/atom/movable/item in T)
					if(item.cares_about_temperature || !isnull(item.reagents))
						item.temperature_expose(temperature, CELL_VOLUME)

		if(reasons & MILLA_INTERESTING_REASON_WIND)
			var/x_flow = currentrun[offset + MILLA_INDEX_AIRFLOW_X]
			var/y_flow = currentrun[offset + MILLA_INDEX_AIRFLOW_Y]

			var/turf/simulated/S = T
			if(istype(S))
				if(isnull(S.wind_tick))
					// Didn't have wind before, add it.
					windy_tiles += S
				S.wind_tick = milla_tick
				S.wind_x = x_flow
				S.wind_y = y_flow
			T.high_pressure_movements(x_flow, y_flow)

		currentrun.len -= MILLA_INTERESTING_TILE_SIZE
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_hotspots(resumed = 0)
	if(!resumed)
		src.currentrun = hotspots
		new_hotspots = list()
		hotspot_count = length(src.currentrun)
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/turf/simulated/S = currentrun[length(currentrun)]

		if(!istype(S))
			currentrun.len--
			continue

		if(S.update_hotspot())
			// Is still a hotspot, keep it.
			new_hotspots += S

		currentrun.len--

		if(MC_TICK_CHECK)
			return

	hotspots = new_hotspots

/datum/controller/subsystem/air/proc/process_windy_tiles(resumed = 0)
	if(!resumed)
		src.currentrun = windy_tiles
		new_windy_tiles = list()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/turf/simulated/S = currentrun[length(currentrun)]
		currentrun.len--

		if(!istype(S))
			continue

		if(S.update_wind())
			// Still has wind, keep it.
			new_windy_tiles += S

		if(MC_TICK_CHECK)
			return

	windy_tiles = new_windy_tiles

/datum/controller/subsystem/air/proc/process_pressure_overlay(resumed = 0)
	if(!resumed)
		currentrun = list(get_tracked_pressure_tiles(), pressure_hud_users)
		pressure_hud_users = list()

	//cache for sanic speed (lists are references anyways)
	var/list/tracked_tiles = currentrun[1]
	while(length(tracked_tiles))
		var/x = tracked_tiles[length(tracked_tiles) - 3]
		var/y = tracked_tiles[length(tracked_tiles) - 2]
		var/z = tracked_tiles[length(tracked_tiles) - 1]
		var/pressure = tracked_tiles[length(tracked_tiles) - 0]
		tracked_tiles.len -= 4

		var/turf/tile = locate(x, y, z)
		if(istype(tile))
			var/obj/effect/abstract/pressure_overlay/pressure_overlay = tile.ensure_pressure_overlay()
			var/ratio = pressure / ONE_ATMOSPHERE
			pressure_overlay.overlay.color = rgb((1 - ratio) * 255, 0, ratio * 255)
			pressure_overlay.overlay.alpha = pressure_overlay_alpha

		if(MC_TICK_CHECK)
			return

	var/datum/atom_hud/data/pressure/hud = GLOB.huds[DATA_HUD_PRESSURE]

	//cache for sanic speed (lists are references anyways)
	var/list/users = currentrun[2]
	while(length(users))
		var/mob/user = users[length(users)]
		var/turf/oldloc = users[user]
		users.len--

		if(!istype(user) || QDELETED(user) || isnull(user.client) || !istype(oldloc))
			continue

		if(user in hud.hudusers)
			var/turf/newloc = get_turf(user)
			if(oldloc == newloc)
				// Ya ain't moved, son. Ya get the same tiles ya already had.
				continue
			clear_pressure_hud(user, oldloc, FALSE)
			add_pressure_hud(user, oldloc, FALSE)
			pressure_hud_users[user] = newloc
		else
			clear_pressure_hud(user, oldloc, TRUE)

		if(MC_TICK_CHECK)
			return

	for(var/mob/user in hud.hudusers)
		if(isnull(user.client))
			continue
		track_pressure_tiles(user, PRESSURE_HUD_LOAD_RADIUS)
		if(!(user in pressure_hud_users))
			pressure_hud_users[user] = get_turf(user)

	// Clean up currentrun so we don't confuse the next step.
	currentrun = list()

/datum/controller/subsystem/air/proc/clear_pressure_hud(mob/user, turf/oldloc, full_clear)
	if(!istype(oldloc) || isnull(user.client))
		return
	var/turf/newloc = get_turf(user)
	if(!istype(newloc))
		full_clear = TRUE
	else if(oldloc.z != newloc.z)
		full_clear = TRUE

	for(var/x in oldloc.x - PRESSURE_HUD_RADIUS to oldloc.x + PRESSURE_HUD_RADIUS)
		if(x < 1 || x > world.maxx)
			continue

		for(var/y in oldloc.y - PRESSURE_HUD_RADIUS to oldloc.y + PRESSURE_HUD_RADIUS)
			if(y < 1 || y > world.maxy)
				continue
			if(!full_clear && abs(newloc.x - x) <= PRESSURE_HUD_RADIUS && abs(newloc.y - y) <= PRESSURE_HUD_RADIUS)
				continue

			var/turf/tile = locate(x, y, oldloc.z)
			var/obj/effect/abstract/pressure_overlay/pressure_overlay = tile.ensure_pressure_overlay()
			user.client.images -= pressure_overlay.overlay

/datum/controller/subsystem/air/proc/add_pressure_hud(mob/user, turf/oldloc, full_send)
	var/turf/newloc = get_turf(user)
	if(!istype(newloc) || isnull(user.client))
		return
	if(!istype(oldloc))
		full_send = TRUE
	else if(oldloc.z != newloc.z)
		full_send = TRUE

	for(var/x in newloc.x - PRESSURE_HUD_RADIUS to newloc.x + PRESSURE_HUD_RADIUS)
		if(x < 1 || x > world.maxx)
			continue

		for(var/y in newloc.y - PRESSURE_HUD_RADIUS to newloc.y + PRESSURE_HUD_RADIUS)
			if(y < 1 || y > world.maxy)
				continue
			if(!full_send && abs(oldloc.x - x) <= PRESSURE_HUD_RADIUS && abs(oldloc.y - y) <= PRESSURE_HUD_RADIUS)
				continue

			var/turf/tile = locate(x, y, newloc.z)
			var/obj/effect/abstract/pressure_overlay/pressure_overlay = tile.ensure_pressure_overlay()
			user.client.images += pressure_overlay.overlay

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

/datum/controller/subsystem/air/proc/setup_turfs(turf/low_corner = locate(1, 1, 1), turf/high_corner = locate(world.maxx, world.maxy, world.maxz))
	for(var/turf/T as anything in block(low_corner, high_corner))
		T.Initialize_Atmos(milla_tick)
	milla_load_turfs(low_corner, high_corner)
	for(var/turf/T as anything in block(low_corner, high_corner))
		T.milla_data.len = 0
		T.milla_data = null

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
	B.lastread = src.milla_tick
	B.readonly = null
	B.dirty = FALSE
	B.synchronized = FALSE


/// Similar to addtimer, but triggers once MILLA enters synchronous mode.
/datum/controller/subsystem/air/proc/synchronize(datum/milla_safe/CB)
	// Any proc that wants MILLA to be synchronous should not sleep.
	SHOULD_NOT_SLEEP(TRUE)

	// Just in case someone is naughty and decides to sleep, make sure that this method runs fully anyway.
	set waitfor = FALSE

	if(milla_idle)
		var/was_safe = SSair.in_milla_safe_code
		SSair.in_milla_safe_code = TRUE
		// This is one of four intended places to call this otherwise-unsafe proc.
		CB.private_unsafe_invoke()
		SSair.in_milla_safe_code = was_safe
		return

	waiting_for_sync += CB

/// Similar to addtimer, but triggers once MILLA enters synchronous mode. This version allows for sleeping if it's absolutely necessary.
/datum/controller/subsystem/air/proc/sleepable_synchronize(datum/milla_safe_must_sleep/CB)
	if(length(sleepers))
		sleepers += CB
		// This is one of four intended places to call this otherwise-unsafe proc.
		CB.private_unsafe_invoke()
		sleepers -= CB
		return

	sleepable_waiting_for_sync += CB

/datum/controller/subsystem/air/proc/is_in_milla_safe_code()
	return in_milla_safe_code || length(sleepers) > 0

/datum/controller/subsystem/air/proc/on_milla_tick_finished()
	milla_idle = TRUE
	run_sleepless_callbacks()
	run_sleeping_callbacks()

/datum/controller/subsystem/air/proc/run_sleepless_callbacks()
	// Just in case someone is naughty and decides to sleep, make sure that this method runs fully anyway.
	set waitfor = FALSE

	in_milla_safe_code = TRUE
	for(var/datum/milla_safe/CB as anything in waiting_for_sync)
		// This is one of four intended places to call this otherwise-unsafe proc.
		CB.private_unsafe_invoke()
	waiting_for_sync.Cut()
	in_milla_safe_code = FALSE

/datum/controller/subsystem/air/proc/run_sleeping_callbacks()
	in_milla_safe_code = TRUE
	for(var/datum/milla_safe_must_sleep/CB as anything in sleepable_waiting_for_sync)
		sleepers += CB
		// This is one of four intended places to call this otherwise-unsafe proc.
		CB.private_unsafe_invoke()
		sleepers -= CB
	sleepable_waiting_for_sync.Cut()
	in_milla_safe_code = FALSE

/datum/controller/subsystem/air/proc/has_sleeper(datum/milla_safe_must_sleep/sleeper)
	return sleeper in sleepers

/proc/milla_tick_finished()
	// Any proc that wants MILLA to be synchronous should not sleep.
	SHOULD_NOT_SLEEP(TRUE)

	SSair.on_milla_tick_finished()

/proc/milla_tick_error(err)
	// Any proc that wants MILLA to be synchronous should not sleep.
	SHOULD_NOT_SLEEP(TRUE)

	log_debug(err)
	var/msg = "MILLA has crashed. SSair will stop running, and all atmospherics will stop functioning. Every turf will report as full of breathable air, and all fires will be extinguished. Shuttle call highly recommended."
	to_chat(GLOB.admins, "<span class='boldannounceooc'>[msg]</span>")
	log_world(msg)

	// Disable firing.
	SSair.flags |= SS_NO_FIRE
	// Disable fire, too.
	for(var/turf/simulated/S in SSair.hotspots)
		QDEL_NULL(S.active_hotspot)

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
	if(air.lastread < SSair.milla_tick)
		var/list/milla_tile = new/list(MILLA_TILE_SIZE)
		get_tile_atmos(T, milla_tile)
		air.copy_from_milla(milla_tile)
		air.lastread = SSair.milla_tick
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

/// Create a subclass of this and implement `on_run` to manipulate tile air safely. ONLY USE THIS VERSION IF YOU CAN'T AVOID SLEEPING; it will delay atmos ticks!
/datum/milla_safe_must_sleep
	var/run_args = list()

/// All subclasses should implement this.
/datum/milla_safe_must_sleep/proc/on_run(...)
	CRASH("[src.type] does not implement on_run")

/// Call this to make the subclass run when it's safe to do so. Args will be passed to on_run.
/datum/milla_safe_must_sleep/proc/invoke_async(...)
	run_args = args.Copy()
	SSair.sleepable_synchronize(src)

/// Do not call this yourself. This is what is called to run your code from a safe context.
/datum/milla_safe_must_sleep/proc/private_unsafe_invoke()
	soft_assert_safe()
	on_run(arglist(run_args))

/// Used internally to check that we're running safely, but without breaking things worse if we aren't.
/datum/milla_safe_must_sleep/proc/soft_assert_safe()
	ASSERT(SSair.has_sleeper(src))

/// Fetch the air for a turf. Only use from `on_run`.
/datum/milla_safe_must_sleep/proc/get_turf_air(turf/T)
	RETURN_TYPE(/datum/gas_mixture)
	soft_assert_safe()
	// This is one of two intended places to call this otherwise-unsafe proc.
	var/datum/gas_mixture/bound_to_turf/air = T.private_unsafe_get_air()
	if(air.lastread < SSair.milla_tick)
		var/list/milla_tile = new/list(MILLA_TILE_SIZE)
		get_tile_atmos(T, milla_tile)
		air.copy_from_milla(milla_tile)
		air.lastread = SSair.milla_tick
		air.readonly = null
		air.dirty = FALSE
	if(!air.synchronized)
		air.synchronized = TRUE
		SSair.bound_mixtures += air
	return air

/// Add air to a turf. Only use from `on_run`.
/datum/milla_safe_must_sleep/proc/add_turf_air(turf/T, datum/gas_mixture/air)
	var/datum/gas_mixture/turf_air = get_turf_air(T)
	turf_air.merge(air)

/// Completely replace the air for a turf. Only use from `on_run`.
/datum/milla_safe_must_sleep/proc/set_turf_air(turf/T, datum/gas_mixture/air)
	var/datum/gas_mixture/turf_air = get_turf_air(T)
	turf_air.copy_from(air)

#undef SSAIR_DEFERREDPIPENETS
#undef SSAIR_PIPENETS
#undef SSAIR_ATMOSMACHINERY
#undef SSAIR_INTERESTING_TILES
#undef SSAIR_HOTSPOTS
#undef SSAIR_WINDY_TILES
#undef SSAIR_BOUND_MIXTURES
#undef SSAIR_PRESSURE_OVERLAY
#undef SSAIR_MILLA_TICK
