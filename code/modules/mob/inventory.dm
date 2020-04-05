//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting l_hand = ...etc
//as they handle all relevant stuff like adding it to the player's screen and updating their overlays.

//Returns the thing in our active hand
/mob/proc/get_active_hand()
	if(hand)	return l_hand
	else		return r_hand

/mob/verb/quick_equip()
	set name = "quick-equip"
	set hidden = 1

	var/obj/item/I = get_active_hand()
	if(I)
		I.equip_to_best_slot(src)

/mob/proc/is_in_active_hand(obj/item/I)
	var/obj/item/item_to_test = get_active_hand()

	return item_to_test && item_to_test.is_equivalent(I)


//Returns the thing in our inactive hand
/mob/proc/get_inactive_hand()
	if(hand)	return r_hand
	else		return l_hand

/mob/proc/is_in_inactive_hand(obj/item/I)
	var/obj/item/item_to_test = get_inactive_hand()

	return item_to_test && item_to_test.is_equivalent(I)

//Returns if a certain item can be equipped to a certain slot.
// Currently invalid for two-handed items - call obj/item/mob_can_equip() instead.
/mob/proc/can_equip(obj/item/I, slot, disable_warning = 0)
	return 0

// Because there's several different places it's stored.
/mob/proc/get_multitool(var/if_active=0)
	return null

//Puts the item into your l_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_l_hand(var/obj/item/W)
	if(!put_in_hand_check(W))
		return 0
	if(!l_hand && has_left_hand())
		W.forceMove(src)		//TODO: move to equipped?
		l_hand = W
		W.layer = ABOVE_HUD_LAYER	//TODO: move to equipped?
		W.plane = ABOVE_HUD_PLANE	//TODO: move to equipped?
		W.equipped(src,slot_l_hand)
		if(pulling == W)
			stop_pulling()
		update_inv_l_hand()
		return 1
	return 0

//Puts the item into your r_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_r_hand(var/obj/item/W)
	if(!put_in_hand_check(W))
		return 0
	if(!r_hand && has_right_hand())
		W.forceMove(src)
		r_hand = W
		W.layer = ABOVE_HUD_LAYER
		W.plane = ABOVE_HUD_PLANE
		W.equipped(src,slot_r_hand)
		if(pulling == W)
			stop_pulling()
		update_inv_r_hand()
		return 1
	return 0

/mob/proc/put_in_hand_check(var/obj/item/W)
	if(lying && !(W.flags & ABSTRACT))	return 0
	if(!istype(W))	return 0
	return 1

//Puts the item into our active hand if possible. returns 1 on success.
/mob/proc/put_in_active_hand(var/obj/item/W)
	if(hand)	return put_in_l_hand(W)
	else		return put_in_r_hand(W)

//Puts the item into our inactive hand if possible. returns 1 on success.
/mob/proc/put_in_inactive_hand(var/obj/item/W)
	if(hand)	return put_in_r_hand(W)
	else		return put_in_l_hand(W)

//Puts the item our active hand if possible. Failing that it tries our inactive hand. Returns 1 on success.
//If both fail it drops it on the floor and returns 0.
//This is probably the main one you need to know :)
//Just puts stuff on the floor for most mobs, since all mobs have hands but putting stuff in the AI/corgi/ghost hand is VERY BAD.
/mob/proc/put_in_hands(obj/item/W)
	W.forceMove(drop_location())
	W.layer = initial(W.layer)
	W.plane = initial(W.plane)
	W.dropped()

/mob/proc/drop_item_v()		//this is dumb.
	if(stat == CONSCIOUS && isturf(loc))
		return drop_item()
	return 0

//Drops the item in our left hand
/mob/proc/drop_l_hand()
	return unEquip(l_hand) //All needed checks are in unEquip

//Drops the item in our right hand
/mob/proc/drop_r_hand()
	return unEquip(r_hand) //Why was this not calling unEquip in the first place jesus fuck.

//Drops the item in our active hand.
/mob/proc/drop_item() //THIS. DOES. NOT. NEED. AN. ARGUMENT.
	if(hand)
		return drop_l_hand()
	else
		return drop_r_hand()

//Here lie unEquip and before_item_take, already forgotten and not missed.

/mob/proc/canUnEquip(obj/item/I, force)
	if(!I)
		return 1
	if((I.flags & NODROP) && !force)
		return 0
	return 1

/mob/proc/unEquip(obj/item/I, force) //Force overrides NODROP for things like wizarditis and admin undress.
	if(!I) //If there's nothing to drop, the drop is automatically succesfull. If(unEquip) should generally be used to check for NODROP.
		return 1

	if(!canUnEquip(I, force))
		return 0

	if(I == r_hand)
		r_hand = null
		update_inv_r_hand()
	else if(I == l_hand)
		l_hand = null
		update_inv_l_hand()
	else if(I in tkgrabbed_objects)
		var/obj/item/tk_grab/tkgrab = tkgrabbed_objects[I]
		unEquip(tkgrab, force)

	if(I)
		if(client)
			client.screen -= I
		I.forceMove(drop_location())
		I.dropped(src)
		if(I)
			I.layer = initial(I.layer)
			I.plane = initial(I.plane)
	return 1


//Attemps to remove an object on a mob.  Will not move it to another area or such, just removes from the mob.
/mob/proc/remove_from_mob(var/obj/O)
	unEquip(O)
	O.screen_loc = null
	return 1


//Outdated but still in use apparently. This should at least be a human proc.
//Daily reminder to murder this - Remie.
/mob/proc/get_equipped_items(include_pockets = FALSE)
	var/list/items = list()
	if(back)
		items += back
	if(wear_mask)
		items += wear_mask
	return items

/mob/living/carbon/get_equipped_items(include_pockets = FALSE)
	var/list/items = ..()
	if(wear_suit)
		items += wear_suit
	if(head)
		items += head
	return items

/mob/living/carbon/human/get_equipped_items(include_pockets = FALSE)
	var/list/items = ..()
	if(belt)
		items += belt
	if(l_ear)
		items += l_ear
	if(r_ear)
		items += r_ear
	if(glasses)
		items += glasses
	if(gloves)
		items += gloves
	if(shoes)
		items += shoes
	if(wear_id)
		items += wear_id
	if(wear_pda)
		items += wear_pda
	if(w_uniform)
		items += w_uniform
	if(include_pockets)
		if(l_store)
			items += l_store
		if(r_store)
			items += r_store
		if(s_store)
			items += s_store
	return items

/obj/item/proc/equip_to_best_slot(mob/M)
	if(src != M.get_active_hand())
		to_chat(M, "<span class='warning'>You are not holding anything to equip!</span>")
		return 0

	if(M.equip_to_appropriate_slot(src))
		if(M.hand)
			M.update_inv_l_hand(0)
		else
			M.update_inv_r_hand(0)
		return 1

	if(M.s_active && M.s_active.can_be_inserted(src, 1))	//if storage active insert there
		M.s_active.handle_item_insertion(src)
		return 1

	var/obj/item/storage/S = M.get_inactive_hand()
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
		if(slot_wear_mask)
			return wear_mask
		if(slot_back)
			return back
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
	return null

