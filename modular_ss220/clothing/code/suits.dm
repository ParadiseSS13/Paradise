/obj/item/clothing/suit/v_jacket
	name = "куртка V"
	desc = "Куртка так называемого V."
	icon = 'modular_ss220/clothing/icons/object/suits.dmi'
	icon_state = "v_jacket"
	icon_override = 'modular_ss220/clothing/icons/mob/suits.dmi'
	item_state = "v_jacket"
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/takemura_jacket
	name = "куртка Такэмуры"
	desc = "Куртка так называемого Такэмуры."
	icon = 'modular_ss220/clothing/icons/object/suits.dmi'
	icon_state = "takemura_jacket"
	icon_override = 'modular_ss220/clothing/icons/mob/suits.dmi'
	item_state = "takemura_jacket"
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/katarina_jacket
	name = "куртка Катарины"
	desc = "Куртка так называемой Катарины."
	icon = 'modular_ss220/clothing/icons/object/suits.dmi'
	icon_state = "katarina_jacket"
	icon_override = 'modular_ss220/clothing/icons/mob/suits.dmi'
	item_state = "katarina_jacket"
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/katarina_cyberjacket
	name = "киберкуртка Катарины"
	desc = "Кибер-куртка так называемой Катарины."
	icon = 'modular_ss220/clothing/icons/object/suits.dmi'
	icon_state = "katarina_cyberjacket"
	icon_override = 'modular_ss220/clothing/icons/mob/suits.dmi'
	item_state = "katarina_cyberjacket"
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/hooded/shark_costume
	name = "костюм акулы"
	desc = "Костюм из 'синтетической' кожи акулы, пахнет."
	icon = 'modular_ss220/clothing/icons/object/suits.dmi'
	icon_state = "shark_casual"
	icon_override = 'modular_ss220/clothing/icons/mob/suits.dmi'
	item_state = "shark_casual"
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list(/obj/item/tank/internals/emergency_oxygen)
	hoodtype = /obj/item/clothing/head/hooded/shark_hood

/obj/item/clothing/head/hooded/shark_hood
	name = "акулий капюшон"
	desc = "Капюшон, прикрепленный к костюму акулы."
	icon = 'modular_ss220/clothing/icons/object/hats.dmi'
	icon_state = "shark_casual"
	icon_override = 'modular_ss220/clothing/icons/mob/hats.dmi'
	item_state = "shark_casual"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags = BLOCKHAIR
	flags_inv = HIDEEARS

/obj/item/clothing/suit/hooded/shark_costume/light
	name = "светло-голубой костюм акулы"
	icon_state = "shark_casual_light"
	item_state = "shark_casual_light"
	hoodtype = /obj/item/clothing/head/hooded/shark_hood/light

/obj/item/clothing/head/hooded/shark_hood/light
	name = "светло-голубой акулий капюшон"
	icon_state = "shark_casual_light"
	item_state = "shark_casual_light"

/obj/item/clothing/suit/space/deathsquad/officer/syndie
	name = "куртка офицера синдиката"
	desc = "Длинная куртка из высокопрочного волокна."
	icon = 'modular_ss220/clothing/icons/object/suits.dmi'
	icon_state = "jacket_syndie"
	icon_override = 'modular_ss220/clothing/icons/mob/suits.dmi'
	item_state = "jacket_syndie"
