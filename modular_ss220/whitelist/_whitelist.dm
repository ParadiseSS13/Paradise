/datum/modpack/whitelist
	name = "Улучшенный вайтлист"
	desc = "Поддержка вайтлиста в бд"
	author = "furior"

/datum/modpack/whitelist/initialize()
	load_whitelist()
	GLOB.admin_verbs_server |= /client/proc/update_whitelist
