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
	var/last_attacker_name
	/// Ckey of the player who performed the last attack.
	var/last_attacker_ckey
	/// Name and type of the weapon that the last attack was performed with.
	var/last_attacker_weapon

/datum/attack_info/proc/last_attacker_html()
	var/name = "INVALID"
	var/ckey = "INVALID"
	if(last_attacker_name)
		name = last_attacker_name
	if(last_attacker_ckey)
		var/client/C = get_client_by_ckey(last_attacker_ckey)
		if(C)
			ckey = "<a href='byond://?priv_msg=[C.ckey];type=;ticket_id='>[C.ckey]</a>"
		else
			ckey = "[C.ckey] (DC)"

	return "[ckey]/([name])"

/datum/attack_info/proc/last_weapon()
	if(last_attacker_weapon)
		return " ([last_attacker_weapon])"
	return ""
