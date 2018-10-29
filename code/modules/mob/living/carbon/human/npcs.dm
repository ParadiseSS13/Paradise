/obj/item/clothing/under/punpun
	name = "fancy uniform"
	desc = "It looks like it was tailored for a monkey."
	icon_state = "punpun"
	item_color = "punpun"
	species_restricted = list("Monkey")

/mob/living/carbon/human/monkey/punpun/Initialize(mapload)
	..()
	name = "Pun Pun"
	real_name = name
	equip_to_slot(new /obj/item/clothing/under/punpun(src), slot_w_uniform)
