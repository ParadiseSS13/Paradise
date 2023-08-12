/mob/living/carbon/alien/humanoid/do_unEquip(obj/item/I, force = FALSE, atom/newloc, no_move = FALSE, invdrop = TRUE, silent = FALSE)
	. = ..()
	if(!. || !I)
		return

	if(I == r_store)
		r_store = null
		if(!QDELETED(src))
			update_inv_pockets()

	else if(I == l_store)
		l_store = null
		if(!QDELETED(src))
			update_inv_pockets()


/mob/living/carbon/alien/humanoid/equip_to_slot(obj/item/I, slot, initial)
	if(!slot)
		return
	if(!istype(I))
		return

	if(I == l_hand)
		l_hand = null
		update_inv_l_hand()
	else if(I == r_hand)
		r_hand = null
		update_inv_r_hand()

	if(I.pulledby)
		I.pulledby.stop_pulling()

	I.pixel_x = initial(I.pixel_x)
	I.pixel_y = initial(I.pixel_y)
	I.screen_loc = null
	I.forceMove(src)
	I.equipped(src, slot, initial)
	I.layer = ABOVE_HUD_LAYER
	I.plane = ABOVE_HUD_PLANE

	switch(slot)
		if(slot_l_hand)
			l_hand = I
			update_inv_l_hand()

		if(slot_r_hand)
			r_hand = I
			update_inv_r_hand()

		if(slot_r_store)
			r_store = I
			update_inv_pockets()

		if(slot_l_store)
			l_store = I
			update_inv_pockets()

		if(slot_handcuffed)
			handcuffed = I
			update_handcuffed_status()

		if(slot_legcuffed)
			legcuffed = I
			update_legcuffed_status()


/mob/living/carbon/alien/humanoid/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, bypass_obscured = FALSE)
	switch(slot)
		if(slot_l_hand)
			if(l_hand)
				return FALSE
			if(!I.allowed_for_alien())
				return FALSE
			if(incapacitated())
				return FALSE
			return TRUE

		if(slot_r_hand)
			if(r_hand)
				return FALSE
			if(!I.allowed_for_alien())
				return FALSE
			if(incapacitated())
				return FALSE
			return TRUE

		if(slot_l_store)
			if(l_store)
				return FALSE
			if(!I.allowed_for_alien())
				return FALSE
			if(I.flags & NODROP)
				return FALSE
			if(I.slot_flags & SLOT_DENYPOCKET)
				return FALSE

			return I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & SLOT_POCKET)

		if(slot_r_store)
			if(r_store)
				return FALSE
			if(!I.allowed_for_alien())
				return FALSE
			if(I.flags & NODROP)
				return FALSE
			if(I.slot_flags & SLOT_DENYPOCKET)
				return FALSE

			return I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & SLOT_POCKET)

		if(slot_handcuffed)
			return !handcuffed && istype(I, /obj/item/restraints/handcuffs)

		if(slot_legcuffed)
			return !legcuffed && istype(I, /obj/item/restraints/legcuffs)


/mob/living/carbon/alien/humanoid/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_back)
			return back
		if(slot_wear_mask)
			return wear_mask
		if(slot_wear_suit)
			return wear_suit
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
		if(slot_l_store)
			return l_store
		if(slot_r_store)
			return r_store
		if(slot_handcuffed)
			return handcuffed
		if(slot_legcuffed)
			return legcuffed
	return null


/mob/living/carbon/alien/humanoid/get_slot_by_item(item)
	if(item == back)
		return slot_back
	if(item == wear_mask)
		return slot_wear_mask
	if(item == wear_suit)
		return slot_wear_suit
	if(item == l_hand)
		return slot_l_hand
	if(item == r_hand)
		return slot_r_hand
	if(item == l_store)
		return slot_l_store
	if(item == r_store)
		return slot_r_store
	if(item == handcuffed)
		return slot_handcuffed
	if(item == legcuffed)
		return slot_legcuffed
	return null


/mob/living/carbon/alien/humanoid/has_organ_for_slot(slot_id)
	switch(slot_id)
		if(slot_back, slot_wear_mask, slot_wear_suit, slot_l_hand, slot_r_hand, slot_l_store, slot_r_store, slot_handcuffed, slot_legcuffed)
			return TRUE
		else
			return FALSE

