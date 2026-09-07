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
	desc = "A backpack that opens into a localized pocket of Bluespace."
	id = "bag_holding"
	req_tech = list("bluespace" = 7, "materials" = 5, "engineering" = 7, "plasmatech" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 3000, MAT_DIAMOND = 1500, MAT_URANIUM = 250, MAT_BLUESPACE = 2000)
	build_path = /obj/item/storage/backpack/holding
	category = list("Bluespace")

/datum/design/bluespace_belt
	name = "Belt of Holding"
	desc = "A bleeding-edge storage medium that brings the principles first used in the Bag of Holding to belt form."
	id = "bluespace_belt"
	req_tech = list("bluespace" = 7, "materials" = 5, "engineering" = 6, "plasmatech" = 6)
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
	desc = "This device facilitates the rapid deployment of conveyor belts via the incorporation of experimental Bluespace technology."
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

/datum/design/rcs
	name = "Rapid Crate Sender"
	desc = "Used to warp crates and closets to cargo telepads."
	id = "rcs"
	req_tech = list("programming" = 5, "bluespace" = 4, "engineering" = 4, "plasmatech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 3750)
	build_path = /obj/item/rcs
	category = list("Bluespace")

/datum/design/beacon
	name = "Tracking Beacon"
	desc = "A bluespace tracking beacon."
	id = "beacon"
	req_tech = list("bluespace" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 200)
	build_path = /obj/item/beacon
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

/datum/design/bluespaceshotglass
	name = "Bluespace Shot Glass"
	desc = "For when you need to make the Bartender's life extra hell."
	req_tech = list("bluespace" = 5, "materials" = 3, "plasmatech" = 4)
	id = "bluespaceshotglass"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_BLUESPACE = 500)
	build_path = /obj/item/reagent_containers/drinks/drinkingglass/shotglass/bluespace
	category = list("Bluespace")
