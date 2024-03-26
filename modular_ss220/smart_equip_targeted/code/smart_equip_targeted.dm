/// take the most recent item out of a slot or place held item in a slot
/mob/living/carbon/human/proc/smart_equip_targeted(slot_item = SLOT_HUD_BELT)
	var/obj/item/thing = get_active_hand()
	var/obj/item/item_in_slot = get_item_by_slot(slot_item)
	var/obj/item/storage/equipped_item
	if(isstorage(item_in_slot))
		equipped_item = item_in_slot
	if(!istype(equipped_item) && ismodcontrol(item_in_slot))
		var/obj/item/mod/control/mod = item_in_slot
		if(mod.bag)
			equipped_item = mod.bag
	if(ismecha(loc) || HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(!istype(equipped_item))
		if(thing)
			equip_to_slot_if_possible(thing, slot_item)
		else
			if(istype(item_in_slot))
				item_in_slot.attack_hand(src)
		return
	if(thing && equipped_item.can_be_inserted(thing))
		equipped_item.handle_item_insertion(thing, src)
		playsound(loc, "rustle", 50, 1, -5)
		return
	if(thing)
		return
	if(!length(equipped_item.contents))
		return
	var/obj/item/stored = equipped_item.contents[length(equipped_item.contents)]
	if(!stored || stored.on_found(src))
		return
	stored.attack_hand(src) // take out thing from item in storage slot

/mob/living/carbon/human/quick_equip_item(slot_item)
	smart_equip_targeted(slot_item)
