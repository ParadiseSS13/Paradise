/////////////////////////////////////////
//////////////Bluespace//////////////////
/////////////////////////////////////////
/datum/design/bluespace_crystal
	name = "Artificial Bluespace Crystal"
	desc = "A small blue crystal with mystical properties."
	id = "bluespace_crystal"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list("$diamond" = 1500, "$phoron" = 1500)
	reliability_base = 100
	build_path = /obj/item/bluespace_crystal/artificial
	category = list("Bluespace")	
	
/datum/design/bag_holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	id = "bag_holding"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list("$gold" = 3000, "$diamond" = 1500, "$uranium" = 250)
	reliability_base = 80
	build_path = /obj/item/weapon/storage/backpack/holding
	category = list("Bluespace")
	
/datum/design/bluespace_belt
	name = "Belt of Holding"
	desc = "An astonishingly complex belt popularized by a rich blue-space technology magnate."
	id = "bluespace_belt"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list("$gold" = 1500, "$diamond" = 3000, "$uranium" = 1000)
	reliability_base = 80
	build_path = /obj/item/weapon/storage/belt/bluespace
	category = list("Bluespace")
	
/datum/design/bluespacebeaker
	name = "Bluespace Beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	id = "bluespacebeaker"
	req_tech = list("bluespace" = 2, "materials" = 6)
	build_type = PROTOLATHE
	materials = list("$metal" = 3000, "$phoron" = 3000, "$diamond" = 500)
	reliability_base = 76
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/bluespace
	category = list("Medical")

/datum/design/telesci_gps
	name = "GPS Device"
	desc = "A device that can track its position at all times."
	id = "telesci_Gps"
	req_tech = list("materials" = 2, "magnets" = 3, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 500, "$glass" = 1000)
	build_path = /obj/item/device/gps
	category = list("Bluespace")
	
/datum/design/miningsatchel_holding
	name = "Mining Satchel of Holding"
	desc = "A mining satchel that can hold an infinite amount of ores."
	id = "minerbag_holding"
	req_tech = list("bluespace" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list("$gold" = 250, "$uranium" = 500) //quite cheap, for more convenience
	reliability = 100
	build_path = /obj/item/weapon/storage/bag/ore/holding
	category = list("Bluespace")

/datum/design/telepad_beacon
	name = "Telepad Beacon"
	desc = "Use to warp in a cargo telepad."
	id = "telepad_beacon"
	req_tech = list("bluespace" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list ("$metal" = 2000, "$glass" = 1750, "$silver" = 500)
	build_path = /obj/item/device/telepad_beacon
	category = list("Bluespace")

/datum/design/beacon
	name = "Tracking Beacon"
	desc = "A blue space tracking beacon."
	id = "beacon"
	req_tech = list("bluespace" = 1)
	build_type = PROTOLATHE
	materials = list ("$metal" = 20, "$glass" = 10)
	build_path = /obj/item/device/radio/beacon
	category = list("Bluespace")