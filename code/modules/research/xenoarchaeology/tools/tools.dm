
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Miscellaneous xenoarchaeology tools

/obj/item/device/measuring_tape
	name = "measuring tape"
	desc = "A coiled metallic tape used to check dimensions and lengths."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "measuring"
	w_class = WEIGHT_CLASS_SMALL

//todo: dig site tape

/obj/item/weapon/storage/bag/fossils
	name = "Fossil Satchel"
	desc = "Transports delicate fossils in suspension so they don't break during transit."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	slot_flags = SLOT_BELT | SLOT_POCKET
	w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 50
	max_combined_w_class = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * ore.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(/obj/item/weapon/fossil)
