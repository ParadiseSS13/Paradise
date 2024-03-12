/datum/modpack/antagonists
	name = "Антагонисты и режимы"
	desc = "Добавляет новые режимы и антагонистов."
	author = "Gaxeer, dj-34"

/datum/modpack/antagonists/initialize()
	GLOB.special_roles |= ROLE_BLOOD_BROTHER
	GLOB.huds += new/datum/atom_hud/antag/hidden()
