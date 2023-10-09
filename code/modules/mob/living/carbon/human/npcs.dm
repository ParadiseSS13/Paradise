/obj/item/clothing/under/punpun
	name = "fancy uniform"
	desc = "It looks like it was tailored for a monkey."
	icon_state = "punpun"
	item_color = "punpun"
	species_restricted = list("Monkey")
	species_exception = list(/datum/species/monkey)

	icon = 'icons/obj/clothing/under/misc.dmi'
	sprite_sheets = list("Monkey" = 'icons/mob/clothing/under/misc.dmi')

/mob/living/carbon/human/monkey/punpun/Initialize(mapload)
	. = ..()
	name = "Pun Pun"
	real_name = name
	equip_to_slot(new /obj/item/clothing/under/punpun(src), SLOT_HUD_JUMPSUIT)

/mob/living/carbon/human/monkey/teeny/Initialize(mapload)
	. = ..()
	name = "Mr. Teeny"
	real_name = name
	resize = 0.8
	update_transform()
