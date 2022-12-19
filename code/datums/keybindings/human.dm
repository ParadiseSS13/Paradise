/datum/keybinding/human
	category = KB_CATEGORY_HUMAN

/datum/keybinding/human/can_use(client/C, mob/M)
	return ishuman(M) && ..()

/datum/keybinding/human/bag_equip
	name = "Equip Held Object To Bag"
	keys = list("ShiftB")

/datum/keybinding/human/bag_equip/down(client/C)
	. = ..()
	var/mob/living/carbon/human/M = C.mob
	M.quick_equip_bag()

/datum/keybinding/human/belt_equip
	name = "Equip Held Object To Belt"
	keys = list("ShiftE")

/datum/keybinding/human/belt_equip/down(client/C)
	. = ..()
	var/mob/living/carbon/human/M = C.mob
	M.quick_equip_belt()

/datum/keybinding/human/suit_equip
	name = "Equip Held Object To Suit Storage"
	keys = list("ShiftQ")

/datum/keybinding/human/suit_equip/down(client/C)
	. = ..()
	var/mob/living/carbon/human/M = C.mob
	M.quick_equip_suit()

/datum/keybinding/human/toggle_holster
	name = "Toggle Holster"
	keys = list("H")

/datum/keybinding/human/toggle_holster/down(client/C)
	. = ..()
	var/mob/living/carbon/human/M = C.mob
	if(!M.w_uniform)
		return
	var/obj/item/clothing/accessory/holster/H = locate() in M.w_uniform
	H?.holster_verb()
