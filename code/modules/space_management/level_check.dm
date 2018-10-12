/proc/is_on_level_name(atom/A,name)
  var/datum/space_level/S = space_manager.get_zlev_by_name(name)
  return A.z == S.zpos

/proc/get_radio_id(z)
	if(space_manager.initialized)
		var/datum/space_level/S = space_manager.get_zlev(z)
		return S.level_get_radio_id()
	else
		return z

/datum/space_level/proc/level_get_radio_id()
	return zpos

// For expansion later
/proc/atoms_share_level(atom/A, atom/B)
  return A && B && A.z == B.z
