/proc/is_level_reachable(z)
	return check_level_trait(z, REACHABLE_BY_CREW)

/proc/is_station_level(z)
	return check_level_trait(z, STATION_LEVEL)

/proc/is_station_contact(z)
	return check_level_trait(z, STATION_CONTACT)

/proc/is_teleport_allowed(z)
	return !check_level_trait(z, BLOCK_TELEPORT)

/proc/is_admin_level(z)
	return check_level_trait(z, ADMIN_LEVEL)

/proc/is_away_level(z)
	return check_level_trait(z, AWAY_LEVEL)

/proc/is_mining_level(z)
	return check_level_trait(z, ORE_LEVEL)

/proc/is_ai_allowed(z)
	return check_level_trait(z, AI_OK)

/proc/level_blocks_magic(z)
	return check_level_trait(z, IMPEDES_MAGIC)

/proc/level_boosts_signal(z)
	return check_level_trait(z, BOOSTS_SIGNAL)

#define is_reserved_level(z) check_level_trait(z, ZTRAIT_RESERVED)

// Used for the nuke disk, or for checking if players survived through xenos
/proc/is_secure_level(z)
	var/secure = check_level_trait(z, STATION_LEVEL)
	if(!secure)
	// This is to allow further admin levels later, other than centcomm
		secure = (z == level_name_to_num(CENTCOMM))
	return secure

// Only CC
GLOBAL_LIST_INIT(default_map_traits, list(CC_TRANSITION_CONFIG))

/proc/check_level_trait(z, trait)
	if(!z)
		return 0 // If you're nowhere, you have no traits
	var/list/trait_list
	if(GLOB.space_manager.initialized)
		var/datum/space_level/S = GLOB.space_manager.get_zlev(z)
		trait_list = S.flags
	else
		trait_list = GLOB.default_map_traits[z]
		trait_list = trait_list["attributes"]
	return (trait in trait_list)

/proc/levels_by_trait(trait)
	var/list/result = list()
	for(var/A in GLOB.space_manager.z_list)
		var/datum/space_level/S = GLOB.space_manager.z_list[A]
		if(trait in S.flags)
			result |= S.zpos
	return result

/proc/level_name_to_num(name)
	var/datum/space_level/S = GLOB.space_manager.get_zlev_by_name(name)
	if(!S)
		CRASH("Unknown z-level name: [name]")
	return S.zpos

/**
  * Proc to get a list of all the linked-together Z-Levels
  *
  * Returns a list of zlevel numbers which can be accessed from travelling space naturally
  */
/proc/get_all_linked_levels_zpos(transit_tag = TRANSITION_TAG_SPACE)
	var/list/znums = list()
	for(var/i in GLOB.space_manager.z_list)
		var/datum/space_level/SL = GLOB.space_manager.z_list[i]
		if(SL.transition_tag == transit_tag && SL.linkage == CROSSLINKED)
			znums |= SL.zpos
	return znums
