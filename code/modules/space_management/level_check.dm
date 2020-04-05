/proc/is_on_level_name(atom/A,name)
  var/datum/space_level/S = GLOB.space_manager.get_zlev_by_name(name)
  return A.z == S.zpos

// For expansion later
/proc/atoms_share_level(atom/A, atom/B)
  return A && B && A.z == B.z
