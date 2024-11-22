/obj/item/card/id/syndicate
	var/static/list/restricted_appearances = list("admin", "deathsquad", "clownsquad", "data", "ERT_empty", "silver", "gold", "TDred", "TDgreen")
	var/static/list/appearances = GLOB.card_skins_ss220 + GLOB.card_skins_special_ss220 + GLOB.card_skins_donor_ss220 - restricted_appearances

/obj/item/card/id/syndicate/ui_data(mob/user)
	var/list/data = ..()
	var/default = 'icons/mob/hud/job_assets.dmi'
	var/custom = 'modular_ss220/jobs/icons/job_assets.dmi'
	data["job_assets"] = !hud_icon || icon_exists(default, hud_icon) ? default : custom
	return data

/obj/item/card/id/syndicate/ui_static_data(mob/user)
	var/list/data = ..()
	data["appearances"] = appearances
	return data
