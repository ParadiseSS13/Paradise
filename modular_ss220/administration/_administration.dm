/datum/modpack/administration
	name = "Улучшение администрирования"
	desc = "Разные админские улучшения."
	author = "dj-34"

/datum/modpack/administration/initialize()
	GLOB.admin_verbs_admin += list(
		/client/proc/cmd_admin_offer_control,
	)
