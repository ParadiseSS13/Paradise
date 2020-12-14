/**
  * # Rep Purchase - Fulton Extraction Kit
  */
/datum/rep_purchase/item/fulton
	name = "Fulton Extraction Kit"
	description = "A balloon that can be used to extract equipment or personnel to a Fulton Recovery Beacon. Anything not bolted down can be moved. Link the pack to a beacon by using the pack in hand."
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
