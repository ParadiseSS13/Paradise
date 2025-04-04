/// Returns a list of all locations (except the area) the movable is within.
/proc/get_nested_locs(atom/movable/atom_on_location, include_turf = FALSE)
	. = list()
	var/atom/location = atom_on_location.loc
	var/turf/our_turf = get_turf(atom_on_location)
	while(location && location != our_turf)
		. += location
		location = location.loc
	if(our_turf && include_turf) // At this point, only the turf is left, provided it exists.
		. += our_turf

/// A datum storing information about attacks an atom has received.
/// Only contains attacker name/ckey right now but could be expanded.
/datum/attack_info
	/// Name of the mob who performed the last attack.
	var/last_attacker_name = null
	/// Ckey of the player who performed the last attack.
	var/last_attacker_ckey = null
