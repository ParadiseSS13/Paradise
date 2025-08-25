/// All job icon sprites, as visible on a security HUD. Used by orbit menu.
/datum/asset/spritesheet/job_icons
	name = "job_icons"

/datum/asset/spritesheet/job_icons/create_spritesheets()
	var/list/states = GLOB.joblist | "Prisoner" | "Centcom" | "Solgov" | "Soviet" | "Unknown"
	var/default = 'icons/mob/hud/job_assets.dmi'
	var/custom = 'modular_ss220/jobs/icons/job_assets.dmi'
	for(var/state in states)
		var/canonical_state = ckey(state)
		Insert(canonical_state, icon_exists(custom, canonical_state) ? custom : default, canonical_state)

/datum/asset/spritesheet/job_icons/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(16, 16)
	return pre_asset
