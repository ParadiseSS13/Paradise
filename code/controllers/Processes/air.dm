var/kill_air = 0

var/global/datum/controller/process/air_system/air_master
/turf/var/activeturf_airmastercycle = 0
/datum/excited_group/var/excitedturf_airmastercycle = 0
/datum/controller/process/air_system
	var/list/excited_groups = list()
	var/list/active_turfs = list()
	var/list/hotspots = list()


	//Special functions lists
	var/list/turf/simulated/active_super_conductivity = list()
	var/list/turf/simulated/high_pressure_delta = list()

	var/sub_cycle = 0
	var/current_cycle = 0
	var/failed_ticks = 0
	var/tick_progress = 0

	// Stats
	var/last_active = 0
	var/last_excited = 0
	var/last_hpd = 0
	var/last_hotspots = 0
	var/last_asc = 0

/datum/controller/process/air_system/setup()
	name = "air"
	schedule_interval = 5 // every 2 seconds
	start_delay = 4
	air_master = src

	var/watch = start_watch()
	log_startup_progress("Processing geometry...")
	setup_allturfs() // Get all currently active tiles that need processing each atmos tick.
	setup_overlays() // Assign icons and such for gas-turf-overlays
	log_startup_progress("  Geometry processed in [stop_watch(watch)]s.")

/datum/controller/process/air_system/doWork()
	if(kill_air)
		return 1
	if (sub_cycle >= 4)
		current_cycle++
		sub_cycle = 0
	sub_cycle++
	process_active_turfs()
	process_excited_groups()
	process_high_pressure_delta()
	process_hotspots()
	process_super_conductivity()
	return 1

/datum/controller/process/air_system/statProcess()
	..()
	stat(null, "[last_active] active")
	stat(null, "[last_excited] EG | [last_hpd] HPD | [last_asc] ASC | [last_hotspots] Hot")

/datum/controller/process/air_system/proc/process_hotspots()
	last_hotspots = hotspots.len
	for(var/obj/effect/hotspot/H in hotspots) //we could split it as well, but at the same time it never represented much load in any profile i saw, so maybe we could just let it be faster
		H.process()
		SCHECK

/datum/controller/process/air_system/proc/process_super_conductivity()
	last_asc = active_super_conductivity.len
	for(var/turf/simulated/T in active_super_conductivity) //we could split it as well, but at the same time it never represented much load in any profile i saw, so maybe we could just let it be faster
		T.super_conduct()
		SCHECK

/datum/controller/process/air_system/proc/process_high_pressure_delta()
	last_hpd = high_pressure_delta.len
	for(var/turf/T in high_pressure_delta)
		T.high_pressure_movements()
		T.pressure_difference = 0
		SCHECK
	high_pressure_delta.Cut()

/datum/controller/process/air_system/proc/process_active_turfs()
	last_active = active_turfs.len
	var/count = 0
	for(var/turf/simulated/T in active_turfs)
		if (T.activeturf_airmastercycle == current_cycle)
			continue
		if (count > last_active/4 && sub_cycle < 4) //do at most 1/4 every subcycle, unless its the last one, then do whatever is left (to cover those added etc)
			break
		count++
		T.activeturf_airmastercycle = current_cycle
		T.process_cell()

		SCHECK

/datum/controller/process/air_system/proc/remove_from_active(var/turf/simulated/T)
	if(istype(T))
		T.excited = 0
		active_turfs -= T
		if(T.excited_group)
			T.excited_group.garbage_collect()

/datum/controller/process/air_system/proc/add_to_active(var/turf/simulated/T, var/blockchanges = 1)
	if(istype(T) && T.air)
		T.excited = 1
		active_turfs |= T
		if(blockchanges && T.excited_group)
			T.excited_group.garbage_collect()
	else
		for(var/direction in cardinal)
			if(!(T.atmos_adjacent_turfs & direction))
				continue
			var/turf/simulated/S = get_step(T, direction)
			if(istype(S))
				add_to_active(S)

/datum/controller/process/air_system/proc/setup_allturfs(var/turfs_in = world)
	for(var/turf/simulated/T in turfs_in)
		T.CalculateAdjacentTurfs()
		if(!T.blocks_air)
			T.update_visuals()
			for(var/direction in cardinal)
				if(!(T.atmos_adjacent_turfs & direction))
					continue
				var/turf/enemy_tile = get_step(T, direction)
				if(istype(enemy_tile,/turf/simulated/))
					var/turf/simulated/enemy_simulated = enemy_tile
					if(!T.air.compare(enemy_simulated.air))
						T.excited = 1
						active_turfs |= T
						break
				else
					if(!T.air.check_turf_total(enemy_tile))
						T.excited = 1
						active_turfs |= T

/datum/controller/process/air_system/proc/process_excited_groups()
	last_excited = excited_groups.len
	var/count = 0
	for(var/datum/excited_group/EG in excited_groups)
		if (EG.excitedturf_airmastercycle == current_cycle)
			continue
		if (count > last_excited/4 && sub_cycle < 4) //do at most 1/4 every subcycle, unless its the last one, then do whatever is left (to cover those added etc)
			break
		count++
		EG.excitedturf_airmastercycle = current_cycle
		EG.breakdown_cooldown++
		if(EG.breakdown_cooldown == 10)
			EG.self_breakdown()
			SCHECK
			return
		if(EG.breakdown_cooldown > 20)
			EG.dismantle()
		SCHECK

/datum/controller/process/air_system/proc/setup_overlays()
	plmaster = new /obj/effect/overlay()
	plmaster.icon = 'icons/effects/tile_effects.dmi'
	plmaster.icon_state = "plasma"
	plmaster.layer = FLY_LAYER
	plmaster.mouse_opacity = 0

	slmaster = new /obj/effect/overlay()
	slmaster.icon = 'icons/effects/tile_effects.dmi'
	slmaster.icon_state = "sleeping_agent"
	slmaster.layer = FLY_LAYER
	slmaster.mouse_opacity = 0

	icemaster = new /obj/effect/overlay()
	icemaster.icon = 'icons/turf/overlays.dmi'
	icemaster.icon_state = "snowfloor"
	icemaster.layer = TURF_LAYER+0.1
	icemaster.mouse_opacity = 0