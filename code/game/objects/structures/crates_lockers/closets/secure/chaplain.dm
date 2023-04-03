/obj/structure/closet/secure_closet/chaplain
	name = "chapel wardrobe"
	desc = "A lockable storage unit for Nanotrasen-approved religious attire."
	req_access = list(ACCESS_CHAPEL_OFFICE)
	icon_state = "chaplainsecure1"
	icon_closed = "chaplainsecure"
	icon_locked = "chaplainsecure1"
	icon_opened = "chaplainsecureopen"
	icon_broken = "chaplainsecurebroken"
	icon_off = "chaplainsecureoff"

/obj/structure/closet/secure_closet/chaplain/populate_contents()
	new /obj/item/storage/backpack/cultpack(src)
	new /obj/item/soulstone/anybody/purified/chaplain(src)
	new /obj/item/storage/fancy/candle_box/eternal(src)
	new /obj/item/storage/fancy/candle_box/eternal(src)
	new /obj/item/storage/fancy/candle_box/eternal(src)
	new /obj/item/clothing/gloves/ring/silver(src)
	new /obj/item/clothing/gloves/ring/silver(src)
	new /obj/item/clothing/gloves/ring/gold(src)
	new /obj/item/clothing/gloves/ring/gold(src)
	new /obj/item/storage/garmentbag/chaplain(src)

