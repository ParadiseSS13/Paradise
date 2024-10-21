/obj/structure/closet/secure_closet/chaplain
	name = "chapel wardrobe"
	desc = "A lockable storage unit for Nanotrasen-approved religious attire."
	req_access = list(ACCESS_CHAPEL_OFFICE)
	icon_state = "chaplain"
	opened_door_sprite = "chaplain"
	closed_door_sprite = "chaplain"


/obj/structure/closet/secure_closet/chaplain/populate_contents()
	new /obj/item/storage/bag/garment/chaplain(src)
	new /obj/item/storage/backpack/cultpack(src)
	new /obj/item/soulstone/anybody/purified/chaplain(src)
	new /obj/item/storage/fancy/candle_box/eternal(src)
	new /obj/item/storage/fancy/candle_box/eternal(src)
	new /obj/item/storage/fancy/candle_box/eternal(src)
	new /obj/item/thurible(src)
