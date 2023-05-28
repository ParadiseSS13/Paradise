/**
  * # Rep Purchase - Fulton Extraction Kit
  */
/datum/rep_purchase/item/fulton
	name = "Fulton Extraction Kit"
	description = "For getting your target across the station to those difficult dropoffs. Place the beacon somewhere secure, and link the pack. Activating the pack on your target will send them over to the beacon - make sure they're not just going to run away though!"
	cost = 1
	stock = 2
	item_type = /obj/item/storage/box/contractor/fulton_kit

/obj/item/extraction_pack/contractor
	name = "black fulton extraction pack"
	desc = "A modified fulton pack that can be used indoors thanks to Bluespace technology. Favored by Syndicate Contractors."
	icon_state = "black"
	can_use_indoors = TRUE
/obj/item/storage/box/contractor/fulton_kit
	name = "fulton extraction kit"
	icon_state = "box_of_doom"

/obj/item/storage/box/contractor/fulton_kit/populate_contents()
	new /obj/item/extraction_pack/contractor(src)
	new /obj/item/fulton_core(src)
