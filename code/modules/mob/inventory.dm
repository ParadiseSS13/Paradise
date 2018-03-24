//These procs handle putting stuff in your hands and
//handle all relevant stuff like adding it to the player's screen and updating their overlays.

////////////////////////////////////
/////////HAND HELPERS///////////////
////////////////////////////////////

//Returns hand oppostite of currently active hand
/mob/proc/get_inactive_held_item_index()
	//selects the opposite hand, they come in pairs starting with  1,2
	var/opp_hand = active_hand_index % 2 ? active_hand_index + 1 : active_hand_index - 1

	if(opp_hand < 0 || opp_hand > held_items.len) //catches out of bounds errors
		opp_hand = 0
	return opp_hand

//Returns the side of the hand. Left is Odd
/mob/proc/held_index_to_dir(i)
	if(i % 2)
		return "l"
	return "r"

//checks if required organ exists for grasping
/mob/proc/has_hand_for_held_index(i)
	return 1

//checks if required organ exists for active hand
/mob/proc/has_active_hand()
	return has_hand_for_held_index(active_hand_index)

//Verifies item can even be held and is in fact an item
/mob/proc/put_in_hand_check(obj/item/I)
	if(lying && !(I.flags&ABSTRACT))
		return 0
	if(!istype(I))
		return 0
	return 1

////////////////////////////////////
/////////HAND GETTERS///////////////
////////////////////////////////////

//Returns item being held
/mob/proc/get_active_held_item()
	return get_item_for_held_index(active_hand_index)

//Returns item in opposite hand
/mob/proc/get_inactive_held_item()
	return get_item_for_held_index(get_inactive_held_item_index())

//returns item in specified hand or 0 if empty
/mob/proc/get_item_for_held_index(i)
	if(i > 0 && i <= held_items.len)
		return held_items[i]
	return 0

//Returns either first or all empty indices on a side
/mob/proc/get_empty_held_index_for_side(side = "left", all = 0)
	var/start = 0
	var/list/lefts = list("l" = 1,"L" = 1,"LEFT" = 1,"left" = 1)
	var/list/rights = list("r" = 1,"R" = 1,"RIGHT" = 1,"right" = 1)
	if(lefts[side])
		start = 1
	else if(rights[side])
		start = 2
	if(!start)
		return 0
	var/list/empty_hands
	for(var/i in start to held_items.len step 2)
		if(!held_items[i])
			if(!all)
				return i
			if(!empty_hands)
				empty_hands = list()
			empty_hands += i
	return empty_hands

//Returns either first or all held items on a side
/mob/proc/get_held_items_for_side(side = "left", all = 0)
	var/start = 0
	var/list/lefts = list("l" = 1,"L" = 1,"LEFT" = 1,"left" = 1)
	var/list/rights = list("r" = 1,"R" = 1,"RIGHT" = 1,"right" = 1)
	if(lefts[side])
		start = 1
	else if(rights[side])
		start = 2
	if(!start)
		return 0
	var/list/holding_items
	for(var/i in start to held_items.len step 2)
		var/obj/item/I = held_items[i]
		if(I)
			if(!all)
				return I
			if(!holding_items)
				holding_items = list()
			holding_items += I
	return holding_items

//Returns all open hand indeces
/mob/proc/get_empty_held_indices(all = 1)
	var/list/L
	for(var/i in 1 to held_items.len)
		if(!held_items[i])
			if(!all)
				return i
			if(!L)
				L = list()
			L += i
	return L

//Returns index of held item
mob/proc/get_held_index_of_item(obj/item/I)
	return held_items.Find(I)

//Returns true if item is in any hand
/mob/proc/is_holding(obj/item/I)
	return get_held_index_of_item(I)

//Returns matching item if of selected type
/mob/proc/is_holding_item_of_type(typepath)
	for(var/obj/item/I in held_items)
		if(istype(I, typepath))
			return I
	return 0

//Returns normalized name of hand
/mob/proc/get_held_index_name(i)
	var/list/hand = list()
	if(i > 2)
		hand += "upper "
	var/num = 0
	if(!(i % 2))
		num = i-2
		hand += "right hand"
	else
		num = i-1
		hand += "left hand"
	num -= (num*0.5)
	if(num > 1) //"upper left hand #1" seems weird, but "upper left hand #2" is A-ok
		hand += " #[num]"
	return hand.Join()


////////////////////////////////////
/////////HAND MANIPULATION//////////
////////////////////////////////////

//Puts an item in the specified hand or returns 0 if unable
/mob/proc/put_in_hand(obj/item/I, hand_index)
	if(!put_in_hand_check(I))
		return 0
	if(!has_hand_for_held_index(hand_index))
		return 0

	var/obj/item/curr = held_items[hand_index]
	if(!curr)
		I.loc = src
		held_items[hand_index] = I
		I.layer = ABOVE_HUD_LAYER
		I.equipped(src, slot_hands)
		if(I.pulledby)
			I.pulledby.stop_pulling()
		update_inv_hands()
		I.pixel_x = initial(I.pixel_x)
		I.pixel_y = initial(I.pixel_y)
		return 1
	return 0

//Tries to put an item in first available left hand
/mob/proc/put_in_l_hand(obj/item/I)
	return put_in_hand(I, get_empty_held_index_for_side("l"))

//Tries to put an item in first available right hand
/mob/proc/put_in_r_hand(obj/item/I)
	return put_in_hand(I, get_empty_held_index_for_side("r"))

//Tries to put an item in our active hand
/mob/proc/put_in_active_hand(obj/item/I)
	return put_in_hand(I, active_hand_index)

//Tries to put an item in the hand opposite of our active hand
/mob/proc/put_in_inactive_hand(obj/item/I
	return put_in_hand(I, get_inactive_held_item_index())

//Tries to put item in any available hand or just drops it
//Returns 1 if it makes it into a hand
/mob/proc/put_in_hands(obj/item/I, del_on_fail = 0)
	if(!I)
		return 0

	//try the active hand first
	if(put_in_active_hand(obj/item/I)
		return 1

	//any hand will suffice
	var/hand = get_empty_held_indices(0)
	if(hand)
		if(put_in_hand(I, hand))
			return 1

	//Drop or delete it then
	if(del_on_fail)
		qdel(I)
		return 0

	I.forceMove(get_turf(src))
	I.layer = initial(I.layer)
	I.dropped(src)
	return 0

//Puts it in your hands or deletes it on fail
/mob/proc/put_in_hands_or_del(obj/item/I)
	return put_in_hands(I, 1)

//Dropping items while inside of something would be problematic
/mob/proc/drop_item_v()
	if(stat == CONSCIOUS && isturf(loc))
		return drop_item()
	return 0

//Drops all the things!
/mob/proc/drop_all_held_items()
	if(!loc || !loc.allow_drop())
		return 0

	for(var/obj/item/I in held_items)
		unequip(I)
	return 1

//drops your current active item
/mob/proc/drop_item()
	if(!loc || !loc.allow_drop())
		return 0
	var/obj/item/held = get_active_held_item()
	return unEquip(held)

////////////////////////////////////
/////////OTHER INVENTORY PROCS//////
////////////////////////////////////

// Because there's several different places it's stored.
/mob/proc/get_multitool(var/if_active=0)
	return null

//Returns if a certain item can be equipped to a certain slot.
// Currently invalid for two-handed items - call obj/item/mob_can_equip() instead.
/mob/proc/can_equip(obj/item/I, slot, disable_warning = 0)
	return 0

//checks if the item exists and is droppable
/mob/proc/canUnEquip(obj/item/I, force)
	if(!I)
		return 1
	if((I.flags & NODROP) && !force)
		return 0
	return 1

//Attempts to unequip an item, returns 1 on success
/mob/proc/unEquip(obj/item/I, force) //Force overrides NODROP for things like wizarditis and admin undress.
	if(!canUnEquip(I, force))
		return 0

	var/hand_index = get_held_index_of_item(I)
	if(hand_index)
		held_items[hand_index] = null
		update_inv_hands()

	else if(I in tkgrabbed_objects)
		var/obj/item/tk_grab/tkgrab = tkgrabbed_objects[I]
		unEquip(tkgrab, force)

	if(I)
		if(client)
			client.screen -= I
		I.forceMove(loc)
		I.dropped(src)
		if(I)
			I.layer = initial(I.layer)
			I.plane = initial(I.plane)
	return 1


//Attemps to remove an object on a mob.  Will not move it to another area or such, just removes from the mob.
/mob/proc/remove_from_mob(var/obj/item/I)
	unEquip(I)
	I.screen_loc = null
	return 1


//Outdated but still in use apparently. This should at least be a human proc. Because everyone needs more colons in their life
/mob/proc/get_equipped_items()
	var/list/items = list()

	if(hasvar(src,"back")) if(src:back) items += src:back
	if(hasvar(src,"belt")) if(src:belt) items += src:belt
	if(hasvar(src,"l_ear")) if(src:l_ear) items += src:l_ear
	if(hasvar(src,"r_ear")) if(src:r_ear) items += src:r_ear
	if(hasvar(src,"glasses")) if(src:glasses) items += src:glasses
	if(hasvar(src,"gloves")) if(src:gloves) items += src:gloves
	if(hasvar(src,"head")) if(src:head) items += src:head
	if(hasvar(src,"shoes")) if(src:shoes) items += src:shoes
	if(hasvar(src,"wear_id")) if(src:wear_id) items += src:wear_id
	if(hasvar(src,"wear_mask")) if(src:wear_mask) items += src:wear_mask
	if(hasvar(src,"wear_suit")) if(src:wear_suit) items += src:wear_suit
//	if(hasvar(src,"w_radio")) if(src:w_radio) items += src:w_radio  commenting this out since headsets go on your ears now PLEASE DON'T BE MAD KEELIN
	if(hasvar(src,"w_uniform")) if(src:w_uniform) items += src:w_uniform

	//if(hasvar(src,"l_hand")) if(src:l_hand) items += src:l_hand
	//if(hasvar(src,"r_hand")) if(src:r_hand) items += src:r_hand

	return items

/obj/item/proc/equip_to_best_slot(mob/M)
	if(src != M.get_active_held_item())
		to_chat(M, "<span class='warning'>You are not holding anything to equip!</span>")
		return 0

	if(M.equip_to_appropriate_slot(src))
		M.update_inv_hands()
		return 1

	if(M.s_active && M.s_active.can_be_inserted(src, 1))	//if storage active insert there
		M.s_active.handle_item_insertion(src)
		return 1

	var/obj/item/weapon/storage/S = M.get_inactive_held_item()
	if(istype(S) && S.can_be_inserted(src, 1))	//see if we have box in other hand
		S.handle_item_insertion(src)
		return 1

	S = M.get_item_by_slot(slot_belt)
	if(istype(S) && S.can_be_inserted(src, 1))		//else we put in belt
		S.handle_item_insertion(src)
		return 1

	S = M.get_item_by_slot(slot_back)	//else we put in backpack
	if(istype(S) && S.can_be_inserted(src, 1))
		S.handle_item_insertion(src)
		playsound(loc, "rustle", 50, 1, -5)
		return 1

	to_chat(M, "<span class='warning'>You are unable to equip that!</span>")
	return 0

/mob/proc/get_all_slots()
	return list(wear_mask, back, l_hand, r_hand)

/mob/proc/get_id_card()
	for(var/obj/item/I in get_all_slots())
		. = I.GetID()
		if(.)
			break

/mob/proc/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_hands)
			return l_hand
		if(slot_r_hand)
			return r_hand
	return null


////////////////////////////////////
/////////MAKING THE HANDS CHANGE////
////////////////////////////////////

//note that this has nothing to do with dismemberment, but rather the number of slots for which a hand may exist on the mob.

/mob/proc/change_number_of_hands(amt)
	if(amt < held_items.len)
		for(var/i in held_items.len to amt step -1)
			unEquip(held_item[i])
	held_items.len = amt

	if(hud_used)
		var/style
		if(client && client.prefs)
			style = ui_style2icon(client.prefs.UI_style)
		hud_used.build_hand_slots(style)
