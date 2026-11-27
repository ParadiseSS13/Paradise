/obj/item/salvage/salvage_component
	name = "salvage component"
	desc = ABSTRACT_TYPE_DESC
	icon = 'icons/obj/salvage/salvage_tools.dmi'
	w_class = WEIGHT_CLASS_TINY
	new_attack_chain = TRUE

/obj/item/salvage/salvage_component/common
	name = "salvage component"
	desc = "Gears, springs, and other mechanisms commonly used in salvage decryptors."
	icon_state = "salvaged_components_common"
	materials = list(MAT_METAL = 2000, MAT_BRASS = 2000)
	origin_tech = "materials=2"

/obj/item/salvage/salvage_component/uncommon
	name = "salvage board"
	desc = "Silicon circuit boards uncommonly used in salvage decryptors."
	icon_state = "salvaged_components_uncommon"
	materials = list(MAT_GLASS = 2000, MAT_PLASTIC = 2000)
	origin_tech = "materials=2;programming=3"

/obj/item/salvage/salvage_component/rare
	name = "salvage circuit"
	desc = "Circuits and diodes rarely used in salvage decryptors."
	icon_state = "salvaged_components_rare"
	materials = list(MAT_SILVER = 2000, MAT_GOLD = 1000)
	origin_tech = "materials=3;programming=5"

