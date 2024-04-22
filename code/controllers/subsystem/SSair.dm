#define SSAIR_DEFERREDPIPENETS 1
#define SSAIR_PIPENETS 2
#define SSAIR_ATMOSMACHINERY 3
#define SSAIR_ACTIVETURFS 4
#define SSAIR_EXCITEDGROUPS 5
#define SSAIR_HIGHPRESSURE 6
#define SSAIR_HOTSPOTS 7
#define SSAIR_SUPERCONDUCTIVITY 8

SUBSYSTEM_DEF(air)
	name = "Atmospherics"
	init_order = INIT_ORDER_AIR
	priority = FIRE_PRIORITY_AIR
	wait = 5
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	offline_implications = "Turfs will no longer process atmos, and all atmospheric machines (including cryotubes) will no longer function. Shuttle call recommended."
	cpu_display = SS_CPUDISPLAY_HIGH
	var/cost_turfs = 0
	var/cost_groups = 0
	var/cost_highpressure = 0
	var/cost_hotspots = 0
	var/cost_superconductivity = 0
	var/cost_pipenets = 0
	var/cost_deferred_pipenets = 0
	var/cost_atmos_machinery = 0

	var/list/excited_groups = list()
	var/list/active_turfs = list()
	var/list/hotspots = list()
	var/list/deferred_pipenet_rebuilds = list()
	var/list/networks = list()
	var/list/atmos_machinery = list()
	var/list/pipe_init_dirs_cache = list()
	var/list/machinery_to_construct = list()



	//Special functions lists
	var/list/active_super_conductivity = list()
	var/list/high_pressure_delta = list()

	/// Pipe overlay/underlay icon manager
	var/datum/pipe_icon_manager/icon_manager


	var/list/currentrun = list()
	var/currentpart = SSAIR_DEFERREDPIPENETS

/datum/controller/subsystem/air/get_stat_details()
	var/list/msg = list()
	msg += "C:{"
	msg += "AT:[round(cost_turfs,1)]|"
	msg += "EG:[round(cost_groups,1)]|"
	msg += "HP:[round(cost_highpressure,1)]|"
	msg += "HS:[round(cost_hotspots,1)]|"
	msg += "SC:[round(cost_superconductivity,1)]|"
	msg += "PN:[round(cost_pipenets,1)]|"
	msg += "DPN:[round(cost_deferred_pipenets,1)]|"
	msg += "AM:[round(cost_atmos_machinery,1)]"
	msg += "} "
	msg += "AT:[length(active_turfs)]|"
	msg += "EG:[length(excited_groups)]|"
	msg += "HS:[length(hotspots)]|"
	msg += "PN:[length(networks)]|"
	msg += "HP:[length(high_pressure_delta)]|"
	msg += "AS:[length(active_super_conductivity)]|"
	msg += "AT/MS:[round((cost ? length(active_turfs)/cost : 0),0.1)]"
	return msg.Join("")

/datum/controller/subsystem/air/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["active_turfs"] = length(active_turfs)
	cust["hotspots"] = length(hotspots)
	.["custom"] = cust

/datum/controller/subsystem/air/Initialize()
	setup_overlays() // Assign icons and such for gas-turf-overlays
	icon_manager = new() // Sets up icon manager for pipes
	setup_allturfs()
	if(length(active_turfs))
		throw_error_on_active_roundstart_turfs()
	setup_atmos_machinery(GLOB.machines)
	setup_pipenets(GLOB.machines)
	for(var/obj/machinery/atmospherics/A in machinery_to_construct)
		A.initialize_atmos_network()

/datum/controller/subsystem/air/Recover()
	excited_groups = SSair.excited_groups
	active_turfs = SSair.active_turfs
	hotspots = SSair.hotspots
	deferred_pipenet_rebuilds = SSair.deferred_pipenet_rebuilds
	networks = SSair.networks
	atmos_machinery = SSair.atmos_machinery
	pipe_init_dirs_cache = SSair.pipe_init_dirs_cache
	machinery_to_construct = SSair.machinery_to_construct
	active_super_conductivity = SSair.active_super_conductivity
	high_pressure_delta = SSair.high_pressure_delta
	icon_manager = SSair.icon_manager
	currentrun = SSair.currentrun
	currentpart = SSair.currentpart

/datum/controller/subsystem/air/fire(resumed = 0)
	var/timer = TICK_USAGE_REAL

	if(currentpart == SSAIR_DEFERREDPIPENETS || !resumed)
		process_deferred_pipenets(resumed)
		cost_deferred_pipenets = MC_AVERAGE(cost_deferred_pipenets, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_PIPENETS

	if(currentpart == SSAIR_PIPENETS || !resumed)
		process_pipenets(resumed)
		cost_pipenets = MC_AVERAGE(cost_pipenets, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_ATMOSMACHINERY

	if(currentpart == SSAIR_ATMOSMACHINERY)
		timer = TICK_USAGE_REAL
		process_atmos_machinery(resumed)
		cost_atmos_machinery = MC_AVERAGE(cost_atmos_machinery, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_ACTIVETURFS

	if(currentpart == SSAIR_ACTIVETURFS)
		timer = TICK_USAGE_REAL
		process_active_turfs(resumed)
		cost_turfs = MC_AVERAGE(cost_turfs, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_EXCITEDGROUPS

	if(currentpart == SSAIR_EXCITEDGROUPS)
		timer = TICK_USAGE_REAL
		process_excited_groups(resumed)
		cost_groups = MC_AVERAGE(cost_groups, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_HIGHPRESSURE

	if(currentpart == SSAIR_HIGHPRESSURE)
		timer = TICK_USAGE_REAL
		process_high_pressure_delta(resumed)
		cost_highpressure = MC_AVERAGE(cost_highpressure, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_HOTSPOTS

	if(currentpart == SSAIR_HOTSPOTS)
		timer = TICK_USAGE_REAL
		process_hotspots(resumed)
		cost_hotspots = MC_AVERAGE(cost_hotspots, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_SUPERCONDUCTIVITY

	if(currentpart == SSAIR_SUPERCONDUCTIVITY)
		timer = TICK_USAGE_REAL
		process_super_conductivity(resumed)
		cost_superconductivity = MC_AVERAGE(cost_superconductivity, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
	currentpart = SSAIR_DEFERREDPIPENETS

/datum/controller/subsystem/air/proc/process_deferred_pipenets(resumed = 0)
	if(!resumed)
		src.currentrun = deferred_pipenet_rebuilds.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/obj/machinery/atmospherics/A = currentrun[length(currentrun)]
		currentrun.len--
		if(A)
			A.build_network(remove_deferral = TRUE)
		else
			deferred_pipenet_rebuilds.Remove(A)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_pipenets(resumed = 0)
	if(!resumed)
		src.currentrun = networks.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/datum/pipeline/thing = currentrun[length(currentrun)]
		currentrun.len--
		if(thing)
			thing.process()
		else
			networks.Remove(thing)
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
		if(!M || (M.process_atmos(seconds) == PROCESS_KILL))
			atmos_machinery.Remove(M)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_super_conductivity(resumed = 0)
	if(!resumed)
		src.currentrun = active_super_conductivity.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/turf/simulated/T = currentrun[length(currentrun)]
		currentrun.len--
		T.super_conduct()
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

/datum/controller/subsystem/air/proc/process_high_pressure_delta(resumed = 0)
	while(length(high_pressure_delta))
		var/turf/simulated/T = high_pressure_delta[length(high_pressure_delta)]
		high_pressure_delta.len--
		T.high_pressure_movements()
		T.pressure_difference = 0
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_active_turfs(resumed = 0)
	//cache for sanic speed
	var/fire_count = times_fired
	if(!resumed)
		src.currentrun = active_turfs.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/turf/simulated/T = currentrun[length(currentrun)]
		currentrun.len--
		if(T)
			T.process_cell(fire_count)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_excited_groups(resumed = 0)
	if(!resumed)
		src.currentrun = excited_groups.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/datum/excited_group/EG = currentrun[length(currentrun)]
		currentrun.len--
		EG.breakdown_cooldown++
		if(EG.breakdown_cooldown == 10)
			EG.self_breakdown()
		else if(EG.breakdown_cooldown >= 20)
			EG.dismantle()
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/remove_from_active(turf/simulated/T)
	active_turfs -= T
	active_super_conductivity -= T // bug: if a turf is hit by ex_act 1 while processing, it can end up in super conductivity as /turf/space and cause runtimes
	if(currentpart == SSAIR_ACTIVETURFS || currentpart == SSAIR_SUPERCONDUCTIVITY)
		currentrun -= T
	if(istype(T))
		T.excited = 0
		if(T.excited_group)
			T.excited_group.garbage_collect()

/datum/controller/subsystem/air/proc/add_to_active(turf/simulated/T, blockchanges = 1)
	if(!initialized)
		/* it makes no sense to "activate" turfs before setup_allturfs is
		 * called, as setup_allturfs would simply cull the list incorrectly.
		 * only /turf/simulated/Initialize_Atmos() is blessed enough to
		 * activate turfs during this phase of initialization, as it happens
		 * post-cull and inlines the logic (perhaps incorrectly)
		 **/
		return

	if(istype(T) && T.air)
		T.excited = 1
		active_turfs |= T
		if(currentpart == SSAIR_ACTIVETURFS)
			currentrun |= T
		if(blockchanges && T.excited_group)
			T.excited_group.garbage_collect()
	else
		for(var/turf/simulated/S in T.atmos_adjacent_turfs)
			add_to_active(S)

/datum/controller/subsystem/air/proc/setup_allturfs(list/turfs_to_init = block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz)))
	for(var/thing in turfs_to_init)
		var/turf/T = thing
		if(T.blocks_air)
			continue
		T.Initialize_Atmos(times_fired)
		CHECK_TICK

/turf/simulated/proc/resolve_active_graph()
	. = list()
	var/datum/excited_group/EG = excited_group
	if(blocks_air || !air)
		return
	if(!EG)
		EG = new
		EG.add_turf(src)

	for(var/turf/simulated/ET in atmos_adjacent_turfs)
		if(ET.blocks_air || !ET.air)
			continue

		var/ET_EG = ET.excited_group
		if(ET_EG)
			if(ET_EG != EG)
				EG.merge_groups(ET_EG)
				EG = excited_group //merge_groups() may decide to replace our current EG
		else
			EG.add_turf(ET)
		if(!ET.excited)
			ET.excited = 1
			. += ET

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
	log_startup_progress("Initializing pipe networks...")
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

/datum/controller/subsystem/air/proc/throw_error_on_active_roundstart_turfs()
	// Can't properly test lavaland due to Init order issues and EVERYTHING being surrounded by rocks, as such we just ignore any turfs on that level
	var/list/active_turfs_we_care_about = list()
	var/z_level_to_exclude = level_name_to_num(MINING)
	for(var/turf/is_lavaland_turf in active_turfs)
		if(is_lavaland_turf.z != z_level_to_exclude)
			active_turfs_we_care_about += is_lavaland_turf
	if(!length(active_turfs_we_care_about))
		return
	log_debug("Turfs were active before init! Please check the runtime logger for information on the specific turfs.")
	stack_trace("Failed sanity check: active_turfs is not empty before init ([length(active_turfs)], turfs are as follows:)")
	for(var/turf/shouldnt_be_active in active_turfs_we_care_about)
		stack_trace("[shouldnt_be_active] was active before init, turf x=[shouldnt_be_active.x], turf y=[shouldnt_be_active.y], turf z=[shouldnt_be_active.z], turf area=[shouldnt_be_active.loc]")
		message_admins("[shouldnt_be_active] was active before init, [ADMIN_JMP(shouldnt_be_active)])")

#undef SSAIR_PIPENETS
#undef SSAIR_ATMOSMACHINERY
#undef SSAIR_ACTIVETURFS
#undef SSAIR_EXCITEDGROUPS
#undef SSAIR_HIGHPRESSURE
#undef SSAIR_HOTSPOTS
#undef SSAIR_SUPERCONDUCTIVITY

#undef SSAIR_DEFERREDPIPENETS
