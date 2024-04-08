/// Sprites for Orbit Role UI
/datum/asset/spritesheet/orbit_job
	name = "orbit_job"

/datum/asset/spritesheet/orbit_job/create_spritesheets()
	var/list/states = GLOB.joblist + "prisoner" + "centcom" + "solgov" + "soviet" + "unknown"
	for(var/state in states)
		Insert(ckey(state), 'icons/mob/hud/job_assets.dmi', ckey(state))

/datum/asset/spritesheet/orbit_job/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(16, 16)
	return pre_asset
