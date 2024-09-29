/// All job icon sprites, as visible on a security HUD. Used by orbit menu.
/datum/asset/spritesheet/job_icons
	name = "job_icons"

/datum/asset/spritesheet/job_icons/create_spritesheets()
	var/list/states = GLOB.joblist + "prisoner" + "centcom" + "solgov" + "soviet" + "unknown"
	for(var/state in states)
		Insert(ckey(state), 'icons/mob/hud/job_assets.dmi', ckey(state))

/datum/asset/spritesheet/job_icons/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(16, 16)
	return pre_asset
