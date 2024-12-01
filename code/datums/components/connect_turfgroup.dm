/**
 * This component behaves similar to connect_loc_behalf but for a given set of turfs, hooking into a signal on each of them.
 * Just like connect_loc_behalf, It can react to that signal on behalf of a seperate listener.
 * Good for components, though it carries some overhead. Can't be an element as that may lead to bugs.
 */
/datum/component/connect_turfgroup
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	/// An assoc list of signal -> procpath to register to the loc this object is on.
	var/list/connections
	/// The turfs currently connected to this component
	var/list/turfs = list()
	/**
	 * The atom the component is tracking. The component will delete itself if the tracked is deleted.
	 * Signals will also be updated whenever it moves (if it's a movable).
	 */
	var/atom/tracked

	/// Whether the component works when the movable isn't directly located on a turf.
	var/works_in_containers

/datum/component/connect_turfgroup/Initialize(atom/tracked_, list/connections_, list/turfs_ = list(), works_in_containers_ = TRUE)
	if(!isatom(tracked_) || isarea(tracked_))
		return COMPONENT_INCOMPATIBLE
	connections = connections_
	set_turfs(turfs_)
	set_tracked(tracked_)
	works_in_containers = works_in_containers_

/datum/component/connect_turfgroup/Destroy()
	set_tracked(null)
	return ..()

/datum/component/connect_turfgroup/InheritComponent(datum/component/component, original, atom/tracked_, list/connections_, list/turfs_, works_in_containers_)
	// Not equivalent. Checks if they are not the same list via shallow comparison.
	if(!compare_list(connections, connections_))
		stack_trace("connect_range component attached to [parent] tried to inherit another connect_range component with different connections")
		return
	if(tracked != tracked_)
		set_tracked(tracked_)
	if(works_in_containers == works_in_containers_ && compare_list(turfs, turfs_))
		return
	//Unregister the signals with the old settings.
	unregister_signals(isturf(tracked) ? tracked : tracked.loc, turfs)
	set_turfs(turfs_)
	works_in_containers = works_in_containers_
	//Re-register the signals with the new settings.
	update_signals(tracked)

/datum/component/connect_turfgroup/proc/set_tracked(atom/new_tracked)
	if(tracked) //Unregister the signals from the old tracked and its surroundings
		unregister_signals(isturf(tracked) ? tracked : tracked.loc, turfs)
		UnregisterSignal(tracked, list(
			COMSIG_MOVABLE_MOVED,
			COMSIG_PARENT_QDELETING,
		))
	tracked = new_tracked
	if(!tracked)
		return
	//Register signals on the new tracked atom and its surroundings.
	RegisterSignal(tracked, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(tracked, COMSIG_PARENT_QDELETING, PROC_REF(handle_tracked_qdel))
	update_signals(tracked)

/datum/component/connect_turfgroup/proc/handle_tracked_qdel()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/connect_turfgroup/proc/update_signals(atom/target, atom/old_loc)
	var/turf/current_turf = get_turf(target)
	if(isnull(current_turf))
		unregister_signals(old_loc, turfs)
		turfs = list()
		return

	if(ismovable(target.loc))
		if(!works_in_containers)
			unregister_signals(old_loc, turfs)
			turfs = list()
			return
		//Keep track of possible movement of all movables the target is in.
		for(var/atom/movable/container as anything in get_nested_locs(target))
			RegisterSignal(container, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

	//Only register/unregister turf signals if it's moved to a new turf.
	if(current_turf == get_turf(old_loc))
		unregister_signals(old_loc, null)
		return
	var/list/old_turfs = turfs
	turfs = receive_new_turfs(current_turf)
	unregister_signals(old_loc, old_turfs - turfs)
	for(var/turf/target_turf as anything in turfs - old_turfs)
		for(var/signal in connections)
			parent.RegisterSignal(target_turf, signal, connections[signal])

/datum/component/connect_turfgroup/proc/unregister_signals(atom/location, list/remove_from)
	//The location is null or is a container and the component shouldn't have register signals on it
	if(isnull(location) || (!works_in_containers && !isturf(location)))
		return

	if(ismovable(location))
		for(var/atom/movable/target as anything in (get_nested_locs(location) + location))
			UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

	if(!length(remove_from))
		return
	for(var/turf/target_turf as anything in remove_from)
		parent.UnregisterSignal(target_turf, connections)

/datum/component/connect_turfgroup/proc/on_moved(atom/movable/movable, atom/old_loc)
	SIGNAL_HANDLER
	update_signals(movable, old_loc)

/datum/component/connect_turfgroup/proc/set_turfs(list/turfs_)
	turfs = turfs_

/datum/component/connect_turfgroup/proc/receive_new_turfs(turf/current_turf)
	SHOULD_CALL_PARENT(FALSE)
	return
