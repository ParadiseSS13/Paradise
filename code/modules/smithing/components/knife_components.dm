/obj/item/smithed_item/component/knife_blade
	name = "Debug knife blade"
	desc = ABSTRACT_TYPE_DESC
	icon_state = "knife_blade"
	part_type = PART_PRIMARY
	hammer_time = 6

/obj/item/smithed_item/component/knife_blade/utility
	name = "utility knife blade"
	desc = "Smithed component part of a utility knife. The blade has yet to be honed."
	materials = list(MAT_METAL = 30000)
	finished_product = /obj/item/kitchen/knife/smithed/utility

/obj/item/smithed_item/component/knife_blade/throwing
	name = "throwing knife blade"
	desc = "Lightweight smithed component part of a knife. The shape is optimally balanced."
	materials = list(MAT_METAL = 28000, MAT_TITANIUM = 28000)
	finished_product = /obj/item/kitchen/knife/smithed/thrown

/obj/item/smithed_item/component/knife_blade/combat
	name = "combat knife blade"
	desc = "Heavyweight smithed component part of a knife. A toothed edge runs across the top."
	materials = list(MAT_TITANIUM = 28000, MAT_PLASMA = 28000)
	finished_product = /obj/item/kitchen/knife/smithed/combat

/obj/item/smithed_item/component/knife_handle
	name = "Debug knife handle"
	desc = ABSTRACT_TYPE_DESC
	icon_state = "knife_handle"
	part_type = PART_SECONDARY
	hammer_time = 4

/obj/item/smithed_item/component/knife_handle/utility
	name = "utility knife handle"
	desc = "Smithed component part of a utility knife. The handle fits comfortably in your hand."
	materials = list(MAT_METAL = 18000)
	finished_product = /obj/item/kitchen/knife/smithed/utility

/obj/item/smithed_item/component/knife_handle/throwing
	name = "throwing knife handle"
	desc = "Lightweight smithed component part of a knife. There is a small ring on the end of the handle."
	materials = list(MAT_METAL = 10000, MAT_TITANIUM = 10000)
	finished_product = /obj/item/kitchen/knife/smithed/thrown

/obj/item/smithed_item/component/knife_handle/combat
	name = "combat knife handle"
	desc = "Heavyweight smithed component part of a knife. The handle is thick and rugged."
	materials = list(MAT_TITANIUM = 10000, MAT_PLASMA = 10000)
	finished_product = /obj/item/kitchen/knife/smithed/combat
