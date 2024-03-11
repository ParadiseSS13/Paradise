/obj/item/storage/bag/material_pouch
	name = "material pouch"
	desc = "Сумка для хранения листов материалов."
	icon = 'modular_ss220/objects/icons/material_pouch.dmi'
	icon_state = "materialpouch"
	storage_slots = 5
	max_combined_w_class = 250
	w_class = WEIGHT_CLASS_BULKY
	can_hold = list(
	/obj/item/stack/sheet,
	/obj/item/stack/rods,
	)
	cant_hold = list(
	/obj/item/stack/sheet/mineral/sandbags,
	/obj/item/stack/sheet/mineral/snow,
	/obj/item/stack/sheet/animalhide,
	/obj/item/stack/sheet/xenochitin,
	/obj/item/stack/sheet/hairlesshide,
	/obj/item/stack/sheet/wetleather,
	/obj/item/stack/sheet/leather,
	/obj/item/stack/sheet/sinew,
	/obj/item/stack/sheet/cloth,
	/obj/item/stack/sheet/durathread,
	/obj/item/stack/sheet/cotton,
	/obj/item/stack/sheet/cotton/durathread,
	/obj/item/stack/sheet/bone,
	/obj/item/stack/sheet/soil,
	/obj/item/stack/sheet/cardboard,
	/obj/item/stack/sheet/cheese,
	)
	resistance_flags = FLAMMABLE
	max_w_class = WEIGHT_CLASS_NORMAL
	slot_flags = SLOT_FLAG_BELT | SLOT_FLAG_POCKET

