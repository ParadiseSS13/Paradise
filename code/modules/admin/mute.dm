/// Associative list of people who are muted via admin mutes
GLOBAL_LIST_EMPTY(admin_mutes_assoc)

/proc/check_mute(ckey, muteflag)
	if(isnull(GLOB.admin_mutes_assoc[ckey]))
		return FALSE

	if(GLOB.admin_mutes_assoc[ckey] & muteflag)
		return TRUE
	return FALSE

/proc/toggle_mute(ckey, muteflag)
	if(isnull(GLOB.admin_mutes_assoc[ckey]))
		GLOB.admin_mutes_assoc[ckey] = 0

	if(GLOB.admin_mutes_assoc[ckey] & muteflag)
		GLOB.admin_mutes_assoc[ckey] &= ~muteflag
	else
		GLOB.admin_mutes_assoc[ckey] |= muteflag

/proc/force_add_mute(ckey, muteflag)
	if(isnull(GLOB.admin_mutes_assoc[ckey]))
		GLOB.admin_mutes_assoc[ckey] = 0

	GLOB.admin_mutes_assoc[ckey] |= muteflag

/proc/force_remove_mute(ckey, muteflag)
	if(isnull(GLOB.admin_mutes_assoc[ckey]))
		GLOB.admin_mutes_assoc[ckey] = 0

	GLOB.admin_mutes_assoc[ckey] &= ~muteflag

