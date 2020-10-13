/////////////////////////////////////////
/////////////////Misc Designs////////////
/////////////////////////////////////////
/datum/design/design_disk
	name = "Design Storage Disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	build_path = /obj/item/disk/design_disk
	category = list("Miscellaneous")

/datum/design/diskplantgene
	name = "Plant data disk"
	desc = "A disk for storing plant genetic data."
	id = "diskplantgene"
	build_type = PROTOLATHE
	materials = list(MAT_METAL=200, MAT_GLASS=100)
	build_path = /obj/item/disk/plantgene
	category = list("Miscellaneous")

/datum/design/intellicard
	name = "Intellicard"
	desc = "Allows for the construction of an intellicard."
	id = "intellicard"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 200)
	build_path = /obj/item/aicard
	category = list("Miscellaneous")

/datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = "Allows for the construction of a pAI Card"
	id = "paicard"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500, MAT_METAL = 500)
	build_path = /obj/item/paicard
	category = list("Miscellaneous")

/datum/design/digital_camera
	name = "Digital Camera"
	desc = "Produce an enhanced version of the standard issue camera."
	id = "digitalcamera"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 300)
	build_path = /obj/item/camera/digital
	category = list("Miscellaneous")

/datum/design/safety_muzzle
	name = "Safety Muzzle"
	desc = "Produce a lockable muzzle keyed to security ID cards"
	id = "safetymuzzle"
	build_type = PROTOLATHE
	materials = list(MAT_METAL=500, MAT_GLASS=50)
	build_path = /obj/item/clothing/mask/muzzle/safety
	category = list("Miscellaneous")

/datum/design/shock_muzzle
	name = "Shock Muzzle"
	desc = "Produce a modified safety muzzle that includes an electric shock pack and a slot for a trigger assembly."
	id = "shockmuzzle"
	build_type = PROTOLATHE
	materials = list(MAT_METAL=500, MAT_GLASS=50)
	build_path = /obj/item/clothing/mask/muzzle/safety/shock
	category = list("Miscellaneous")

/datum/design/data_disk
	name = "Genetics Data Disk"
	desc = "Disk that allows you to store genetic data."
	id = "datadisk"
	build_type = PROTOLATHE
	materials = list(MAT_METAL=300, MAT_GLASS=100)
	build_path = /obj/item/disk/data
	category = list("Miscellaneous")

/datum/design/emergency_oxygen
	name = "Empty Emergency Oxygen Tank"
	desc = "Used for emergencies. Onl contains very little oxygen once filled up."
	id = "emergencyoxygen"
	build_type = PROTOLATHE
	materials = list(MAT_METAL=500, MAT_GLASS=100)
	build_path = /obj/item/tank/emergency_oxygen/empty
	category = list("Miscellaneous")

/datum/design/extended_oxygen
	name = "Empty Extended Emergency Oxygen Tank"
	desc = "Used for emergencies. Can contain a decent amount of oxygen once filled up."
	id = "extendedoxygen"
	build_type = PROTOLATHE
	materials = list(MAT_METAL=800, MAT_GLASS=100)
	build_path = /obj/item/tank/emergency_oxygen/engi/empty
	category = list("Miscellaneous")

/datum/design/double_oxygen
	name = "Empty Double Emergency Oxygen Tank"
	desc = "Used for emergencies. Can contain a good amount of oxygen once filled up."
	id = "doubleoxygen"
	build_type = PROTOLATHE
	materials = list(MAT_METAL=1500, MAT_GLASS=200)
	build_path = /obj/item/tank/emergency_oxygen/double/empty
	category = list("Miscellaneous")

/datum/design/oxygen_tank
	name = "Empty Oxygen Tank"
	desc = "A large, empty air tank."
	id = "oxygentank"
	build_type = PROTOLATHE
	materials = list(MAT_METAL=3000, MAT_GLASS=500)
	build_path = /obj/item/tank/oxygen/empty
	category = list("Miscellaneous")
