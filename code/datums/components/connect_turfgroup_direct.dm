/// A direct turfgroup is simply a turf group whose turfs are directly specified
/// by the instantiater. When the component is re-added with new turfs, those
/// new turfs will be registered to the connection signals.
/datum/component/connect_turfgroup/direct
	/// The turfs that will be connected to this component
	var/list/pending_turfs = list()

/datum/component/connect_turfgroup/direct/receive_new_turfs(turf/current_turf)
	var/list/new_turfs = pending_turfs.Copy()
	pending_turfs.Cut()
	return new_turfs

/datum/component/connect_turfgroup/direct/set_turfs(list/turfs_)
	pending_turfs = turfs_

