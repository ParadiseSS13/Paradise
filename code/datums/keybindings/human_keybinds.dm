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
	M.quick_equip_item(SLOT_HUD_BACK)

/datum/keybinding/human/belt_equip
	name = "Equip Held Object To Belt"
	keys = list("ShiftE")

/datum/keybinding/human/belt_equip/down(client/C)
	. = ..()
	var/mob/living/carbon/human/M = C.mob
	M.quick_equip_item(SLOT_HUD_BELT)

/datum/keybinding/human/suit_equip
	name = "Equip Held Object To Suit Storage"
	keys = list("ShiftQ")

/datum/keybinding/human/suit_equip/down(client/C)
	. = ..()
	var/mob/living/carbon/human/M = C.mob
	M.quick_equip_item(SLOT_HUD_SUIT_STORE)

/datum/keybinding/human/toggle_holster
	name = "Toggle Holster"
	keys = list("H")

/datum/keybinding/human/toggle_holster/down(client/C)
	. = ..()
	var/mob/living/carbon/human/M = C.mob
	if(!M.w_uniform)
		return
	var/obj/item/clothing/accessory/holster/H = locate() in M.w_uniform
	H?.handle_holster_usage(M)

/datum/keybinding/human/parry
	name = "Parry"
	keys = list("Space")

/datum/keybinding/human/parry/down(client/C)
	. = ..()
	SEND_SIGNAL(C.mob, COMSIG_HUMAN_PARRY)
