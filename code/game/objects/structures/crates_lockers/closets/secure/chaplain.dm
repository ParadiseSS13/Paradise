/obj/structure/closet/secure_closet/chaplain
	name = "chapel wardrobe"
	desc = "A lockable storage unit for Nanotrasen-approved religious attire."
	req_access = list(ACCESS_CHAPEL_OFFICE)
	icon_state = "chaplain"

/obj/structure/closet/secure_closet/chaplain/populate_contents()
	new /obj/item/storage/backpack/cultpack(src)
	new /obj/item/soulstone/anybody/purified/chaplain(src)
	new /obj/structure/constructshell/holy(src)
	new /obj/item/storage/fancy/candle_box/eternal(src)
	new /obj/item/storage/fancy/candle_box/eternal(src)
	new /obj/item/storage/fancy/candle_box/eternal(src)
	new /obj/item/clothing/gloves/ring/silver(src)
	new /obj/item/clothing/gloves/ring/silver(src)
	new /obj/item/clothing/gloves/ring/gold(src)
	new /obj/item/clothing/gloves/ring/gold(src)
	new /obj/item/storage/garmentbag/chaplain(src)

