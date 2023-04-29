/datum/keybinding/human
	category = KB_CATEGORY_HUMAN

/datum/keybinding/human/can_use(client/C, mob/M)
	return ishuman(M) && ..()

/datum/keybinding/human/toggle_holster
	name = "Использовать кобуру"
	keys = list("H")

/datum/keybinding/human/toggle_holster/down(client/C)
	. = ..()
	var/mob/living/carbon/human/M = C.mob
	if(!M.w_uniform)
		return
	var/obj/item/clothing/accessory/holster/H = locate() in M.w_uniform
	H?.holster_verb()

/datum/keybinding/human/quick_equip_belt
	name = "Быстрая экипировка пояса"
	keys = list("ShiftE")
	///which slot are we trying to quickdraw from/quicksheathe into?
	var/slot_type = slot_belt
	///what we should call slot_type in messages (including failure messages)
	var/slot_item_name = "belt"

/datum/keybinding/human/quick_equip_belt/down(client/C)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human = C.mob
	human.smart_equip_targeted(slot_type, slot_item_name)
	return TRUE

/datum/keybinding/human/quick_equip_belt/quick_equip_bag
	name = "Быстрая экипировка сумки"
	keys = list("ShiftV")
	slot_type = slot_back
	slot_item_name = "backpack"

/datum/keybinding/human/quick_equip_belt/quick_equip_suit_storage
	name = "Быстрая экипировка хранилища костюма"
	keys = list("ShiftQ")
	slot_type = slot_s_store
	slot_item_name = "suit storage slot item"
