/datum/design/borg_upgrade_storageincreaser
	name = "Engineer Cyborg Upgrade (Storage Increaser)"
	id = "borg_upgrade_storageincreaser"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/storageincreaser
	req_tech = list("bluespace" = 5, "materials" = 7, "engineering" = 5)
	materials = list(MAT_METAL=15000, MAT_BLUESPACE=2000, MAT_SILVER=6000)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_hypospray
	name = "Medical Cyborg Upgrade (Upgraded Hypospray)"
	id = "borg_upgrade_hypospray"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/hypospray
	req_tech = list("biotech" = 7, "materials" = 7)
	materials = list(MAT_METAL=15000, MAT_URANIUM=2000, MAT_DIAMOND=5000, MAT_SILVER=10000)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

// Улучшения голопроектора //
/datum/design/borg_upgrade_atmos/better
	name = "Engineer Cyborg Upgrade (Upgraded ATMOS holofan projector)"
	desc = "Увеличивает количество создаваемых голопроекций до трёх."
	id = "borg_upgrade_atmos_holofan_better"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/atmos_holofan/better
	req_tech = list("materials" = 5, "engineering" = 5, "magnets" = 5)
	materials = list(MAT_METAL=5000, MAT_SILVER=2500, MAT_GOLD=2500, MAT_GLASS=2500)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_atmos/best
	name = "Engineer Cyborg Upgrade (Advanced ATMOS holofan projector)"
	desc = "Увеличивает количество создаваемых голопроекций до пяти."
	id = "borg_upgrade_atmos_holofan_best"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/atmos_holofan/best
	req_tech = list("materials" = 7, "engineering" = 7, "magnets" = 7, "programming" = 7)
	materials = list(MAT_TITANIUM=5000, MAT_SILVER=5000, MAT_GOLD = 5000, MAT_GLASS=2500, MAT_DIAMOND=1500)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")
