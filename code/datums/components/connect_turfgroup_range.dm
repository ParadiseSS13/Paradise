/**
 * This component behaves similar to connect_loc_behalf but for all turfs in range, hooking into a signal on each of them.
 * Just like connect_loc_behalf, It can react to that signal on behalf of a seperate listener.
 * Good for components, though it carries some overhead. Can't be an element as that may lead to bugs.
 */
/datum/component/connect_turfgroup/ranged
	/// The component will hook into signals only on turfs not farther from tracked than this.
	var/range

/datum/component/connect_turfgroup/ranged/Initialize(atom/tracked_, list/connections_, range_, works_in_containers_ = TRUE)
	if(range_ < 0)
		return COMPONENT_INCOMPATIBLE
	return ..(tracked_, connections_, null, works_in_containers_)

/datum/component/connect_turfgroup/ranged/InheritComponent(datum/component/component, original, atom/tracked_, list/connections_, range_, works_in_containers_)
	// Not equivalent. Checks if they are not the same list via shallow comparison.
	if(!compare_list(connections, connections_))
		stack_trace("connect_range component attached to [parent] tried to inherit another connect_range component with different connections")
		return
	if(tracked != tracked_)
		set_tracked(tracked_)
	if(range == range_ && works_in_containers == works_in_containers_)
		return
	//Unregister the signals with the old settings.
	unregister_signals(isturf(tracked_) ? tracked_ : tracked_.loc, turfs)
	range = range_
	works_in_containers = works_in_containers_
	//Re-register the signals with the new settings.
	update_signals(tracked_)

/datum/component/connect_turfgroup/ranged/receive_new_turfs(turf/current_turf)
	return RANGE_TURFS(range, current_turf)
