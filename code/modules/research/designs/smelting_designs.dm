///////SMELTABLE ALLOYS///////

/datum/design/smelter
	build_type = SMELTER

/datum/design/smelter/plasteel_alloy
	name = "Plasteel"
	desc = "Plasma + Iron"
	id = "plasteel"
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasteel
	category = list("initial")

/datum/design/smelter/plastitanium_alloy
	name = "Plastitanium"
	desc = "Plasma + Titanium"
	id = "plastitanium"
	materials = list(MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/plastitanium
	category = list("initial")

/datum/design/smelter/plaglass_alloy
	name = "Plasma Glass"
	desc = "Plasma + Glass"
	id = "plasmaglass"
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasmaglass
	category = list("initial")

/datum/design/smelter/titaniumglass_alloy
	name = "Titanium Glass"
	desc = "Titanium + Glass"
	id = "titaniumglass"
	materials = list(MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/titaniumglass
	category = list("initial")

/datum/design/smelter/plastitaniumglass_alloy
	name = "Plastitanium Glass"
	desc = "Plasma + Titanium + Glass"
	id = "plastitaniumglass"
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT, MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plastitaniumglass
	category = list("initial")

/datum/design/smelter/alienalloy
	name = "Alien Alloy"
	desc = "A sheet of reverse-engineered alien alloy."
	id = "alienalloy"
	req_tech = list("abductor" = 1, "materials" = 7, "plasmatech" = 2)
	build_type = PROTOLATHE | SMELTER
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/abductor
	category = list("Stock Parts")
	lathe_time_factor = 5
