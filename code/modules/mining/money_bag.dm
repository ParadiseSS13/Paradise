/obj/item/storage/bag/money
	name = "money bag"
	icon_state = "moneybag"
	force = 10
	resistance_flags = FLAMMABLE
	max_integrity = 100
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 50
	max_combined_w_class = 50
	can_hold = list(/obj/item/coin, /obj/item/stack/spacecash)

/obj/item/storage/bag/money/vault/populate_contents()
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/adamantine(src)
