/datum/map_template/vr
	name = null
	var/id = null // For blacklisting purposes, all vr levels need an id
	var/description = "This is a placeholder. Please contact your virtual adminsitrator if you see this."
	var/outfit = null
	var/death_type = VR_DROP_ALL
	var/list/drop_whitelist = null
	var/list/drop_blacklist = null
	var/list/loot_common = null
	var/list/loot_rare = null
	var/prefix = null
	var/suffix = null
	var/system = 0

/datum/map_template/vr/New()
	if(!name && id)
		name = id

	mappath = prefix + suffix
	..(path = mappath)