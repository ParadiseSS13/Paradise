/**
  * # Rep Purchase - Fulton Extraction Kit
  */
/datum/rep_purchase/item/fulton
	name = "Fulton Extraction Kit"
	description = "A low accuracy pinpointer that can track anyone in the sector without the need for suit sensors. Can only be used by the first person to activate it."
	cost = 1
	stock = 1
	item_type = /obj/item/storage/box/contractor/fulton_kit

/obj/item/storage/box/contractor/fulton_kit
	name = "fulton extraction kit"
	icon_state = "box_of_doom"

/obj/item/storage/box/contractor/fulton_kit/New()
	..()
	new /obj/item/extraction_pack(src)
	new /obj/item/fulton_core(src)
