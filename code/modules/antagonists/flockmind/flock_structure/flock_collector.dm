/obj/structure/flock/collector
	name = "weird lookin' pulsing thing"
	desc = "Seems to be pulsing."

	flock_desc = "Provides compute power and charges a nearby APC based on the number of Flock floor tiles it is connected to."
	flock_id = "Collector"

	max_integrity = 60
	resource_cost = 200

	/// The collection range.
	var/max_range = 4

	/// How much power each flocktile grants, percentage of a cell's max charge.
	var/power_per_tile = 5

	/// All flockturfs we're connected to.
	var/tmp/list/turf/simulated/floor/flock/connected_flockturfs = list()
	/// All turfs nearby we're tracking for state changes.
	var/tmp/list/turf/tracked_turfs = list()

	/// Set to TRUE when the connected_turfs list needs an update. Prevents update_connections() being called 20 times during explosions.
	var/tmp/need_turfs_update = FALSE

	var/cycle_interval = 20 SECONDS
	var/tmp/charge_per_cycle = 0
	COOLDOWN_DECLARE(charge_cd)

/obj/structure/flock/collector/Initialize(mapload, datum/flock/join_flock)
	. = ..()
	START_PROCESSING(SSobj, src)
	update_connections()
	info_tag.set_text("Bandwidth Provided: [bandwidth_provided]")

/obj/structure/flock/collector/Destroy()
	remove_flockturfs(connected_flockturfs)
	remove_tracked_turfs(tracked_turfs)
	return ..()

/obj/structure/flock/collector/update_icon_state()
	icon_state = length(connected_flockturfs) ? "collectoron" : "collector"
	return ..()

/obj/structure/flock/collector/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	update_connections()

/obj/structure/flock/collector/flock_structure_examine(mob/user)
	var/obj/machinery/power/apc/apc = get_apc()

	return list(
		SPAN_FLOCKSAY("<b>Connections:</b> Connected to [length(connected_flockturfs)] tile\s."),
		SPAN_FLOCKSAY("<b>Bandwidth Provided:</b> [bandwidth_provided]."),
		SPAN_FLOCKSAY("<b>APC Connected:</b> [(!apc?.cell || apc.cell.charge >= apc.cell.maxcharge) ? "Not charging." : "Charging local APC at [charge_per_cycle]% every [cycle_interval / 10] seconds."]")
	)

/obj/structure/flock/collector/process()
	if(need_turfs_update)
		update_connections()

	var/new_bandwidth = length(connected_flockturfs) * power_per_tile
	charge_per_cycle = length(connected_flockturfs) / 4

	if(new_bandwidth != bandwidth_provided)
		flock.remove_bandwidth_influence(bandwidth_provided)
		bandwidth_provided = new_bandwidth
		flock.add_bandwidth_influence(bandwidth_provided)
		info_tag.set_text("Bandwidth Provided: [bandwidth_provided]")

	if(!COOLDOWN_FINISHED(src, charge_cd))
		return

	COOLDOWN_START(src, charge_cd, cycle_interval)

	var/obj/machinery/power/apc/apc = get_apc()
	if(isnull(apc))
		return

	apc.cell?.give(charge_per_cycle / 100 * apc.cell.maxcharge)
	apc.AddComponent(/datum/component/flock_ping/apc_power)

/obj/structure/flock/collector/proc/get_apc() as /obj/machinery/power/apc
	var/area/A = get_area(src)
	return A?.apc

/// Recalculate the turf connections and tracking.
/obj/structure/flock/collector/proc/update_connections()
	var/list/old_tracked_turfs = tracked_turfs
	var/list/old_flockturfs = connected_flockturfs

	var/turf/our_turf = get_turf(src)

	var/list/considered_allturfs = list(our_turf)
	var/list/considered_flockturfs = list()

	if(istype(our_turf, /turf/simulated/floor/flock))
		considered_flockturfs += our_turf

	for(var/direction in GLOB.cardinal)
		var/turf/simulated/floor/flock/iter_turf = our_turf
		var/keep_flockturfs = isflockturf(our_turf)
		for(var/i in 1 to max_range)
			iter_turf = get_step(iter_turf, direction)

			if(keep_flockturfs && (!istype(iter_turf, /turf/simulated/floor/flock) || iter_turf.broken))
				keep_flockturfs = FALSE

			if(keep_flockturfs)
				considered_flockturfs += iter_turf

			considered_allturfs += iter_turf

	var/list/new_tracked_turfs = considered_allturfs - old_tracked_turfs
	var/list/removed_tracked_turfs = old_tracked_turfs - considered_allturfs
	remove_tracked_turfs(removed_tracked_turfs)
	add_tracked_turfs(new_tracked_turfs)

	var/list/new_flockturfs = considered_flockturfs - old_flockturfs
	var/list/removed_flockturfs = old_flockturfs - considered_flockturfs
	remove_flockturfs(removed_flockturfs)
	add_flockturfs(new_flockturfs)

	need_turfs_update = FALSE
	update_appearance(UPDATE_ICON_STATE)

/// Adds turfs to the flockturfs list.
/obj/structure/flock/collector/proc/add_flockturfs(list/add)
	for(var/turf/simulated/floor/flock/flockturf as anything in add)
		LAZYADD(flockturf.connected_pylons, src)
		flockturf.update_power()

	connected_flockturfs += add

/// Remove turfs from the flockturfs list.
/obj/structure/flock/collector/proc/remove_flockturfs(list/remove)
	for(var/turf/simulated/floor/flock/flockturf as anything in remove)
		LAZYREMOVE(flockturf.connected_pylons, src)
		flockturf.update_power()

	tracked_turfs -= remove

/// Add turfs to the tracked list.
/obj/structure/flock/collector/proc/add_tracked_turfs(list/add)
	for(var/turf/T as anything in add)
		RegisterSignal(T, COMSIG_TURF_CHANGE, PROC_REF(on_tracked_turf_change))

	tracked_turfs += add

/// Remove turfs from the tracked list.
/obj/structure/flock/collector/proc/remove_tracked_turfs(list/remove)
	for(var/turf/T as anything in remove)
		UnregisterSignal(T, COMSIG_TURF_CHANGE)

	tracked_turfs -= remove

/// Called when any of the connected turfs is changed.
/obj/structure/flock/collector/proc/on_tracked_turf_change(datum/source, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER

	need_turfs_update = TRUE
