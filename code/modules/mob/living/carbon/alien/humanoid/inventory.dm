//unequip
/mob/living/carbon/alien/humanoid/unEquip(var/obj/item/I, var/force)
	. = ..(I, force)
	if(!. || !I)
		return

	if(I == r_store)
		r_store = null
		update_inv_pockets()

	else if(I == l_store)
		l_store = null
		update_inv_pockets()

/mob/living/carbon/alien/humanoid/attack_ui(slot_id)
	var/obj/item/W = get_active_hand()
	if(W)
		if(!istype(W))	return
		switch(slot_id)
//			if("o_clothing")
//			if("head")
			if(slot_l_store)
				if(l_store)
					return
				if(W.w_class > WEIGHT_CLASS_NORMAL)
					return
				unEquip(W)
				l_store = W
				update_inv_pockets()
			if(slot_r_store)
				if(r_store)
					return
				if(W.w_class > WEIGHT_CLASS_NORMAL)
					return
				unEquip(W)
				r_store = W
				update_inv_pockets()
	else
		switch(slot_id)
			if(slot_wear_suit)
				if(wear_suit)	wear_suit.attack_alien(src)
			if(slot_head)
				if(head)		head.attack_alien(src)
			if(slot_l_store)
				if(l_store)		l_store.attack_alien(src)
			if(slot_r_store)
				if(r_store)		r_store.attack_alien(src)
