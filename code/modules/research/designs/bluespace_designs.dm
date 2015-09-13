/////////////////////////////////////////
//////////////Bluespace//////////////////
/////////////////////////////////////////
/datum/design/bluespace_crystal
	name = "Artificial Bluespace Crystal"
	desc = "A small blue crystal with mystical properties."
	id = "bluespace_crystal"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_DIAMOND = 1500, MAT_PLASMA = 1500)
	reliability = 100
	build_path = /obj/item/bluespace_crystal/artificial
	category = list("Bluespace")

/datum/design/bag_holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	id = "bag_holding"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 3000, MAT_DIAMOND = 1500, MAT_URANIUM = 250)
	reliability = 80
	build_path = /obj/item/weapon/storage/backpack/holding
	category = list("Bluespace")

/datum/design/bluespace_belt
	name = "Belt of Holding"
	desc = "An astonishingly complex belt popularized by a rich blue-space technology magnate."
	id = "bluespace_belt"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1500, MAT_DIAMOND = 3000, MAT_URANIUM = 1000)
	reliability = 80
	build_path = /obj/item/weapon/storage/belt/bluespace
	category = list("Bluespace")

/datum/design/bluespacebeaker
	name = "Bluespace Beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	id = "bluespacebeaker"
	req_tech = list("bluespace" = 2, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_PLASMA = 3000, MAT_DIAMOND = 500)
	reliability = 76
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/bluespace
	category = list("Medical")

/datum/design/telesci_gps
	name = "GPS Device"
	desc = "A device that can track its position at all times."
	id = "telesci_Gps"
	req_tech = list("materials" = 2, "magnets" = 3, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 1000)
	build_path = /obj/item/device/gps
	category = list("Bluespace")

/datum/design/miningsatchel_holding
	name = "Mining Satchel of Holding"
	desc = "A mining satchel that can hold an infinite amount of ores."
	id = "minerbag_holding"
	req_tech = list("bluespace" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 250, MAT_URANIUM = 500) //quite cheap, for more convenience
	reliability = 100
	build_path = /obj/item/weapon/storage/bag/ore/holding
	category = list("Bluespace")

/datum/design/telepad_beacon
	name = "Telepad Beacon"
	desc = "Use to warp in a cargo telepad."
	id = "telepad_beacon"
	req_tech = list("bluespace" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list (MAT_METAL = 2000, MAT_GLASS = 1750, MAT_SILVER = 500)
	build_path = /obj/item/device/telepad_beacon
	category = list("Bluespace")

/datum/design/beacon
	name = "Tracking Beacon"
	desc = "A blue space tracking beacon."
	id = "beacon"
	req_tech = list("bluespace" = 1)
	build_type = PROTOLATHE
	materials = list (MAT_METAL = 20, MAT_GLASS = 10)
	build_path = /obj/item/device/radio/beacon
	category = list("Bluespace")