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
	if(!W)
		switch(slot_id)
			if(ITEM_SLOT_OUTER_SUIT)
				if(wear_suit)	wear_suit.attack_alien(src)
			if(ITEM_SLOT_HEAD)
				if(head)		head.attack_alien(src)
