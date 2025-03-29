/datum/design/borg_upgrade_storageincreaser
	name = "Engineer Cyborg Upgrade (Storage Increaser)"
	id = "borg_upgrade_storageincreaser"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/storageincreaser
	req_tech = list("bluespace" = 5, "materials" = 7, "engineering" = 5)
	materials = list(MAT_METAL=15000, MAT_BLUESPACE=2000, MAT_SILVER=6000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_hypospray
	name = "Medical Cyborg Upgrade (Upgraded Hypospray)"
	id = "borg_upgrade_hypospray"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/hypospray
	req_tech = list("biotech" = 7, "materials" = 7)
	materials = list(MAT_METAL=15000, MAT_URANIUM=2000, MAT_DIAMOND=5000, MAT_SILVER=10000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")
