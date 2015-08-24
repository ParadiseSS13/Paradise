//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting l_hand = ...etc
//as they handle all relevant stuff like adding it to the player's screen and updating their overlays.

//Returns the thing in our active hand
/mob/proc/get_active_hand()
	if(issilicon(src))
		if(isrobot(src))
			if(src:module_active)
				return src:module_active
	else
		if(hand)	return l_hand
		else		return r_hand

//Returns the thing in our inactive hand
/mob/proc/get_inactive_hand()
	if(hand)	return r_hand
	else		return l_hand

// Because there's several different places it's stored.
/mob/proc/get_multitool(var/if_active=0)
	return null

//Puts the item into your l_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_l_hand(var/obj/item/W)
	if(lying && !(W.flags & ABSTRACT))
		return 0
	if(!istype(W))
		return 0
	if(!l_hand)
		W.loc = src		//TODO: move to equipped?
		l_hand = W
		W.layer = 20	//TODO: move to equipped?
//		l_hand.screen_loc = ui_lhand
		W.equipped(src,slot_l_hand)
		if(client)	client.screen |= W
		if(pulling == W) stop_pulling()
		update_inv_l_hand()
		return 1
	return 0

//Puts the item into your r_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_r_hand(var/obj/item/W)
	if(lying && !(W.flags & ABSTRACT))
		return 0
	if(!istype(W))
		return 0
	if(!r_hand)
		W.loc = src
		r_hand = W
		W.layer = 20
//		r_hand.screen_loc = ui_rhand
		W.equipped(src,slot_r_hand)
		if(client)	client.screen |= W
		if(pulling == W) stop_pulling()
		update_inv_r_hand()
		return 1
	return 0

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
	W.loc = get_turf(src)
	W.layer = initial(W.layer)
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

/mob/proc/unEquip(obj/item/I, force) //Force overrides NODROP for things like wizarditis and admin undress.
	if(!I) //If there's nothing to drop, the drop is automatically succesfull. If(unEquip) should generally be used to check for NODROP.
		return 1

	if((I.flags & NODROP) && !force)
		return 0

	if(I == r_hand)
		r_hand = null
		update_inv_r_hand()
	else if(I == l_hand)
		l_hand = null
		update_inv_l_hand()

	if(I)
		if(client)
			client.screen -= I
		I.loc = loc
		I.dropped(src)
		if(I)
			I.layer = initial(I.layer)

	return 1


//Attemps to remove an object on a mob.  Will not move it to another area or such, just removes from the mob.
/mob/proc/remove_from_mob(var/obj/O)
	unEquip(O)
	O.screen_loc = null
	return 1


//Outdated but still in use apparently. This should at least be a human proc.
/mob/proc/get_equipped_items()
	var/list/items = new/list()

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

/** BS12's proc to get the item in the active hand. Couldn't find the /tg/ equivalent. **/
/mob/proc/equipped()
	if(issilicon(src))
		if(isrobot(src))
			if(src:module_active)
				return src:module_active
	else
		if (hand)
			return l_hand
		else
			return r_hand
		return

/mob/living/carbon/human/proc/equip_if_possible(obj/item/W, slot, del_on_fail = 1) // since byond doesn't seem to have pointers, this seems like the best way to do this :/
	//warning: icky code
	var/equipped = 0
	switch(slot)
		if(slot_back)
			if(!src.back)
				src.back = W
				equipped = 1
		if(slot_wear_mask)
			if(!src.wear_mask)
				src.wear_mask = W
				equipped = 1
		if(slot_handcuffed)
			if(!src.handcuffed)
				src.handcuffed = W
				equipped = 1
		if(slot_l_hand)
			if(!src.l_hand)
				src.l_hand = W
				equipped = 1
		if(slot_r_hand)
			if(!src.r_hand)
				src.r_hand = W
				equipped = 1
		if(slot_belt)
			if(!src.belt && src.w_uniform)
				src.belt = W
				equipped = 1
		if(slot_wear_id)
			if(!src.wear_id && src.w_uniform)
				src.wear_id = W
				equipped = 1
		if(slot_wear_pda)
			if(!src.wear_pda && src.w_uniform)
				src.wear_pda = W
				equipped = 1
		if(slot_l_ear)
			if(!src.l_ear)
				src.l_ear = W
				equipped = 1
		if(slot_r_ear)
			if(!src.r_ear)
				src.r_ear = W
				equipped = 1
		if(slot_glasses)
			if(!src.glasses)
				src.glasses = W
				equipped = 1
		if(slot_gloves)
			if(!src.gloves)
				src.gloves = W
				equipped = 1
		if(slot_head)
			if(!src.head)
				src.head = W
				equipped = 1
		if(slot_shoes)
			if(!src.shoes)
				src.shoes = W
				equipped = 1
		if(slot_wear_suit)
			if(!src.wear_suit)
				src.wear_suit = W
				equipped = 1
		if(slot_w_uniform)
			if(!src.w_uniform)
				src.w_uniform = W
				equipped = 1
		if(slot_l_store)
			if(!src.l_store && src.w_uniform)
				src.l_store = W
				equipped = 1
		if(slot_r_store)
			if(!src.r_store && src.w_uniform)
				src.r_store = W
				equipped = 1
		if(slot_s_store)
			if(!src.s_store && src.wear_suit)
				src.s_store = W
				equipped = 1
		if(slot_in_backpack)
			if (src.back && istype(src.back, /obj/item/weapon/storage/backpack))
				var/obj/item/weapon/storage/backpack/B = src.back
				if(B.contents.len < B.storage_slots && W.w_class <= B.max_w_class)
					W.loc = B
					equipped = 1

	if(equipped)
		W.layer = 20
		if(src.back && W.loc != src.back)
			W.loc = src
	else
		if (del_on_fail)
			qdel(W)
	return equipped

/mob/proc/get_all_slots()
	return list(wear_mask, back, l_hand, r_hand)	
	
/mob/proc/get_id_card()
	for(var/obj/item/I in src.get_all_slots())
		. = I.GetID()
		if(.)
			break