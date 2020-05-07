// -----------------------------
//          Gadget Bag
// -----------------------------
/obj/item/storage/bag/component
	icon = 'icons/hispania/obj/storage/storage.dmi'
	icon_state = "component_bag"
	slot_flags = SLOT_BELT | SLOT_POCKET
	name = "component bag"
	desc = "This bag with sciences colors can be used to store many machine components."
	storage_slots = 50
	max_combined_w_class = 100
	w_class = WEIGHT_CLASS_TINY
	can_hold = list("/obj/item/stock_parts", "/obj/item/circuitboard", "/obj/item/apc_electronics", "/obj/item/airlock_electronics",
					"/obj/item/firelock_electronics", "/obj/item/firealarm_electronics", "/obj/item/airalarm_electronics",
					"/obj/item/assembly/igniter", "/obj/item/stack/ore/bluespace_crystal", "/obj/item/reagent_containers/glass/beaker")
	display_contents_with_number = TRUE

/obj/item/storage/bag/component/inge
	icon_state = "component_bag_inge"
	desc = "This bag with engineers colors can be used to store many machine components."

// -----------------------------
//          Kitchen Bag
// -----------------------------
/obj/item/storage/bag/kitchenbag
	name = "kitchen bag"
	icon = 'icons/hispania/obj/storage/storage.dmi'
	icon_state = "kitchenbag"
	desc = "A simple bag with a cute logo to transport your food."
	storage_slots = 50
	max_combined_w_class = 100
	w_class = WEIGHT_CLASS_TINY
	can_hold = list("/obj/item/reagent_containers/food/snacks")
