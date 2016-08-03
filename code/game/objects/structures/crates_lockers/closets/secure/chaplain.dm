/obj/structure/closet/secure_closet/chaplain
	name = "chapel wardrobe"
	desc = "A lockable storage unit for Nanotrasen-approved religious attire."
	req_access = list(access_chapel_office)
	icon_state = "chaplainsecure1"
	icon_closed = "chaplainsecure"
	icon_locked = "chaplainsecure1"
	icon_opened = "chaplainsecureopen"
	icon_broken = "chaplainsecurebroken"
	icon_off = "chaplainsecureoff"

/obj/structure/closet/secure_closet/chaplain/New()
	..()
	new /obj/item/clothing/under/rank/chaplain(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/suit/hooded/nun(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/holidaypriest(src)
	new /obj/item/clothing/under/wedding/bride_white(src)
	new /obj/item/weapon/storage/backpack/cultpack (src)
	new /obj/item/clothing/head/helmet/riot/knight/templar(src)
	new /obj/item/clothing/suit/armor/riot/knight/templar(src)
	new /obj/item/weapon/storage/fancy/candle_box/eternal(src)
	new /obj/item/weapon/storage/fancy/candle_box/eternal(src)
	new /obj/item/weapon/storage/fancy/candle_box/eternal(src)
	new /obj/item/clothing/gloves/ring/silver(src)
	new /obj/item/clothing/gloves/ring/silver(src)
	new /obj/item/clothing/gloves/ring/gold(src)
	new /obj/item/clothing/gloves/ring/gold(src)
