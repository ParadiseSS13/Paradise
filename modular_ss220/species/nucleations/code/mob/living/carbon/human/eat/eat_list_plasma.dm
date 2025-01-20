//===== Plasmaman food =====
/obj/item/stack/sheet/plasmaglass/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_PLASMA
	nutritional_value = 5
	overall_heal_amount = 1
	fracture_repair_probability = 2

/obj/item/stack/ore/plasma/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_PLASMA
	nutritional_value = 5
	overall_heal_amount = 1
	fracture_repair_probability = 2

/obj/item/stack/sheet/mineral/plasma/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_PLASMA
	nutritional_value = 10
	overall_heal_amount = 2
	fracture_repair_probability = 5

/obj/item/coin/plasma/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_PLASMA
	nutritional_value = 40
	overall_heal_amount = 2
	fracture_repair_probability = 5
