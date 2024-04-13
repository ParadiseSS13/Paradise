//unequip
/mob/living/carbon/alien/humanoid/unEquip(obj/item/I, force, silent = FALSE)
	. = ..()
	if(!. || !I)
		return

	if(I == r_store)
		r_store = null
		update_inv_pockets()

	else if(I == l_store)
		l_store = null
		update_inv_pockets()

/mob/living/carbon/alien/humanoid/put_in_hands(obj/item/I)
	if(!I)
		return FALSE
	if(put_in_active_hand(I))
		return TRUE
	if(put_in_inactive_hand(I))
		return TRUE
	return FALSE

/mob/living/carbon/alien/humanoid/attack_ui(slot_id)
	var/obj/item/W = get_active_hand()
	if(W)
		if(!istype(W))	return
		switch(slot_id)
//			if("o_clothing")
//			if("head")
			if(SLOT_HUD_LEFT_STORE)
				if(l_store)
					return
				if(W.w_class > WEIGHT_CLASS_NORMAL)
					return
				unEquip(W)
				l_store = W
				update_inv_pockets()
			if(SLOT_HUD_RIGHT_STORE)
				if(r_store)
					return
				if(W.w_class > WEIGHT_CLASS_NORMAL)
					return
				unEquip(W)
				r_store = W
				update_inv_pockets()
	else
		switch(slot_id)
			if(SLOT_HUD_OUTER_SUIT)
				if(wear_suit)	wear_suit.attack_alien(src)
			if(SLOT_HUD_HEAD)
				if(head)		head.attack_alien(src)
			if(SLOT_HUD_LEFT_STORE)
				if(l_store)		l_store.attack_alien(src)
			if(SLOT_HUD_RIGHT_STORE)
				if(r_store)		r_store.attack_alien(src)
