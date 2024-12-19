//===== Nucleation food =====
/obj/item/stack/ore/uranium/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_RAD
	nutritional_value = 10
	overall_heal_amount = 2
	fracture_repair_probability = 5

/obj/item/stack/sheet/mineral/uranium/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_RAD
	nutritional_value = 20
	overall_heal_amount = 5
	fracture_repair_probability = 5

/obj/item/coin/uranium/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_RAD
	nutritional_value = 20
	overall_heal_amount = 5
	fracture_repair_probability = 5
