/////////////////////////////////////////
//////////////Bluespace//////////////////
/////////////////////////////////////////
/datum/design/bluespace_crystal
	name = "Artificial Bluespace Crystal"
	desc = "A small blue crystal with mystical properties."
	id = "bluespace_crystal"
	req_tech = list("bluespace" = 3, "materials" = 6, "plasmatech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_DIAMOND = 1500, MAT_PLASMA = 1500)
	build_path = /obj/item/stack/ore/bluespace_crystal/artificial
	category = list("Bluespace")

/datum/design/bag_holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	id = "bag_holding"
	req_tech = list("bluespace" = 7, "materials" = 5, "engineering" = 5, "plasmatech" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 3000, MAT_DIAMOND = 1500, MAT_URANIUM = 250, MAT_BLUESPACE = 2000)
	build_path = /obj/item/storage/backpack/holding
	category = list("Bluespace")

/datum/design/bluespace_belt
	name = "Belt of Holding"
	desc = "An astonishingly complex belt popularized by a rich blue-space technology magnate."
	id = "bluespace_belt"
	req_tech = list("bluespace" = 7, "materials" = 5, "engineering" = 5, "plasmatech" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1500, MAT_DIAMOND = 3000, MAT_URANIUM = 1000)
	build_path = /obj/item/storage/belt/bluespace
	category = list("Bluespace")

/datum/design/telesci_gps
	name = "GPS Device"
	desc = "A device that can track its position at all times."
	id = "telesci_Gps"
	req_tech = list("materials" = 2, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 1000)
	build_path = /obj/item/gps
	category = list("Bluespace")

/datum/design/miningsatchel_holding
	name = "Mining Satchel of Holding"
	desc = "A mining satchel that can hold an infinite amount of ores."
	id = "minerbag_holding"
	req_tech = list("bluespace" = 4, "materials" = 3, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 250, MAT_URANIUM = 500) //quite cheap, for more convenience
	build_path = /obj/item/storage/bag/ore/holding
	category = list("Bluespace")

/datum/design/bluespace_belt_holder
	name = "Bluespace Conveyor Belt Placer"
	desc = "This device facilitates the rapid deployment of conveyor belts. This one is powered by bluespace."
	id = "bluespace_belt_holder"
	req_tech = list("materials" = 1, "engineering" = 3, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_SILVER = 500) //Costs similar materials to the basic one, but this one needs silver
	build_path = /obj/item/storage/conveyor/bluespace
	category = list("Bluespace")

/datum/design/telepad_beacon
	name = "Telepad Beacon"
	desc = "Use to warp in a cargo telepad."
	id = "telepad_beacon"
	req_tech = list("programming" = 5, "bluespace" = 4, "engineering" = 4, "plasmatech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1750, MAT_SILVER = 500)
	build_path = /obj/item/telepad_beacon
	category = list("Bluespace")

/datum/design/beacon
	name = "Tracking Beacon"
	desc = "A blue space tracking beacon."
	id = "beacon"
	req_tech = list("bluespace" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 100)
	build_path = /obj/item/radio/beacon
	category = list("Bluespace")

/datum/design/brpd
	name = "Bluespace Rapid Pipe Dispenser (BRPD)"
	desc = "Similar to the Rapid Pipe Dispenser, lets you rapidly dispense pipes. Now at long range!"
	req_tech = list("bluespace" = 3, "toxins" = 6)
	id = "brpd"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 75000, MAT_GLASS = 37500, MAT_SILVER = 3000)
	build_path = /obj/item/rpd/bluespace
	category = list("Bluespace")
