/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for(var/slot in slots)
		if(equip_to_slot_if_possible(W, slots[slot], del_on_fail = 0))
			return slot
	if(del_on_fail)
		qdel(W)
	return null

/mob/living/carbon/human/proc/is_in_hands(typepath)
	if(istype(l_hand,typepath))
		return l_hand
	if(istype(r_hand,typepath))
		return r_hand
	return 0


/mob/living/carbon/human/proc/has_organ(name)
	var/obj/item/organ/external/O = bodyparts_by_name[name]
	return O

/mob/living/carbon/human/proc/has_organ_for_slot(slot)
	switch(slot)
		if(slot_back)
			return has_organ("chest")
		if(slot_wear_mask)
			return has_organ("head")
		if(slot_handcuffed)
			return has_organ("l_hand") && has_organ("r_hand")
		if(slot_legcuffed)
			return has_organ("l_leg") && has_organ("r_leg")
		if(slot_l_hand)
			return has_organ("l_hand")
		if(slot_r_hand)
			return has_organ("r_hand")
		if(slot_belt)
			return has_organ("chest")
		if(slot_wear_id)
			// the only relevant check for this is the uniform check
			return TRUE
		if(slot_wear_pda)
			return TRUE
		if(slot_l_ear)
			return has_organ("head")
		if(slot_r_ear)
			return has_organ("head")
		if(slot_glasses)
			return has_organ("head")
		if(slot_gloves)
			return has_organ("l_hand") && has_organ("r_hand")
		if(slot_head)
			return has_organ("head")
		if(slot_shoes)
			return has_organ("r_foot") && has_organ("l_foot")
		if(slot_wear_suit)
			return has_organ("chest")
		if(slot_w_uniform)
			return has_organ("chest")
		if(slot_l_store)
			return has_organ("chest")
		if(slot_r_store)
			return has_organ("chest")
		if(slot_s_store)
			return has_organ("chest")
		if(slot_in_backpack)
			return TRUE
		if(slot_tie)
			return TRUE

/mob/living/carbon/human/unEquip(obj/item/I, force, silent = FALSE)
	. = ..() //See mob.dm for an explanation on this and some rage about people copypasting instead of calling ..() like they should.
	if(!. || !I)
		return

	if(I == wear_suit)
		if(s_store)
			unEquip(s_store, 1) //It makes no sense for your suit storage to stay on you if you drop your suit.
		wear_suit = null
		if(I.flags_inv & HIDEJUMPSUIT)
			update_inv_w_uniform()
		if(I.flags_inv & HIDESHOES)
			update_inv_shoes()
		update_inv_wear_suit()
	else if(I == w_uniform)
		if(r_store)
			unEquip(r_store, 1) //Again, makes sense for pockets to drop.
		if(l_store)
			unEquip(l_store, 1)
		if(wear_id)
			unEquip(wear_id)
		if(belt)
			unEquip(belt)
		w_uniform = null
		update_inv_w_uniform()
	else if(I == gloves)
		gloves = null
		update_inv_gloves()
	else if(I == glasses)
		glasses = null
		var/obj/item/clothing/glasses/G = I
		if(G.tint)
			update_tint()
		if(G.prescription)
			update_nearsighted_effects()
		if(G.vision_flags || G.see_in_dark || G.invis_override || G.invis_view || !isnull(G.lighting_alpha))
			update_sight()
		update_inv_glasses()
		update_client_colour()
	else if(I == head)
		head = null
		if(I.flags & BLOCKHAIR || I.flags & BLOCKHEADHAIR)
			update_hair()	//rebuild hair
			update_fhair()
			update_head_accessory()
		// Bandanas and paper hats go on the head but are not head clothing
		if(istype(I,/obj/item/clothing/head))
			var/obj/item/clothing/head/hat = I
			if(hat.vision_flags || hat.see_in_dark || !isnull(hat.lighting_alpha))
				update_sight()
		head_update(I)
		update_inv_head()
	else if(I == r_ear)
		r_ear = null
		update_inv_ears()
	else if(I == l_ear)
		l_ear = null
		update_inv_ears()
	else if(I == shoes)
		shoes = null
		update_inv_shoes()
	else if(I == belt)
		belt = null
		update_inv_belt()
	else if(I == wear_mask)
		wear_mask = null
		if(I.flags & BLOCKHAIR || I.flags & BLOCKHEADHAIR)
			update_hair()	//rebuild hair
			update_fhair()
			update_head_accessory()
		if(internal && !get_organ_slot("breathing_tube"))
			internal = null
		wear_mask_update(I, toggle_off = FALSE)
		sec_hud_set_ID()
		update_inv_wear_mask()
	else if(I == wear_id)
		wear_id = null
		sec_hud_set_ID()
		update_inv_wear_id()
	else if(I == wear_pda)
		wear_pda = null
		update_inv_wear_pda()
	else if(I == r_store)
		r_store = null
		update_inv_pockets()
	else if(I == l_store)
		l_store = null
		update_inv_pockets()
	else if(I == s_store)
		s_store = null
		update_inv_s_store()
	else if(I == back)
		back = null
		update_inv_back()
	else if(I == r_hand)
		r_hand = null
		update_inv_r_hand()
	else if(I == l_hand)
		l_hand = null
		update_inv_l_hand()
	update_action_buttons_icon()




//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
// Initial is used to indicate whether or not this is the initial equipment (job datums etc) or just a player doing it
/mob/living/carbon/human/equip_to_slot(obj/item/I, slot, initial = FALSE)
	if(!slot)
		return
	if(!istype(I))
		return
	if(!has_organ_for_slot(slot))
		return

	if(I == src.l_hand)
		src.l_hand = null
		update_inv_l_hand() //So items actually disappear from hands.
	else if(I == src.r_hand)
		src.r_hand = null
		update_inv_r_hand()

	I.screen_loc = null
	I.forceMove(src)
	I.equipped(src, slot, initial)
	I.layer = ABOVE_HUD_LAYER
	I.plane = ABOVE_HUD_PLANE

	switch(slot)
		if(slot_back)
			back = I
			update_inv_back()
		if(slot_wear_mask)
			wear_mask = I
			if((wear_mask.flags & BLOCKHAIR) || (wear_mask.flags & BLOCKHEADHAIR))
				update_hair()	//rebuild hair
				update_fhair()
				update_head_accessory()
			if(hud_list.len)
				sec_hud_set_ID()
			wear_mask_update(I, toggle_off = TRUE)
			update_inv_wear_mask()
		if(slot_handcuffed)
			handcuffed = I
			update_inv_handcuffed()
		if(slot_legcuffed)
			legcuffed = I
			update_inv_legcuffed()
		if(slot_l_hand)
			l_hand = I
			update_inv_l_hand()
		if(slot_r_hand)
			r_hand = I
			update_inv_r_hand()
		if(slot_belt)
			belt = I
			update_inv_belt()
		if(slot_wear_id)
			wear_id = I
			if(hud_list.len)
				sec_hud_set_ID()
			update_inv_wear_id()
		if(slot_wear_pda)
			wear_pda = I
			update_inv_wear_pda()
		if(slot_l_ear)
			l_ear = I
			if(l_ear.slot_flags & SLOT_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(I)
				O.forceMove(src)
				r_ear = O
				O.layer = ABOVE_HUD_LAYER
				O.plane = ABOVE_HUD_PLANE
			update_inv_ears()
		if(slot_r_ear)
			r_ear = I
			if(r_ear.slot_flags & SLOT_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(I)
				O.forceMove(src)
				l_ear = O
				O.layer = ABOVE_HUD_LAYER
				O.plane = ABOVE_HUD_PLANE
			update_inv_ears()
		if(slot_glasses)
			glasses = I
			var/obj/item/clothing/glasses/G = I
			if(G.tint)
				update_tint()
			if(G.prescription)
				update_nearsighted_effects()
			if(G.vision_flags || G.see_in_dark || G.invis_override || G.invis_view || !isnull(G.lighting_alpha))
				update_sight()
			update_inv_glasses()
			update_client_colour()
		if(slot_gloves)
			gloves = I
			update_inv_gloves()
		if(slot_head)
			head = I
			if((head.flags & BLOCKHAIR) || (head.flags & BLOCKHEADHAIR))
				update_hair()	//rebuild hair
				update_fhair()
				update_head_accessory()
			// paper + bandanas
			if(istype(I, /obj/item/clothing/head))
				var/obj/item/clothing/head/hat = I
				if(hat.vision_flags || hat.see_in_dark || !isnull(hat.lighting_alpha))
					update_sight()
			head_update(I)
			update_inv_head()
		if(slot_shoes)
			shoes = I
			update_inv_shoes()
		if(slot_wear_suit)
			wear_suit = I
			if(wear_suit.flags_inv & HIDESHOES)
				update_inv_shoes()
			update_inv_wear_suit()
		if(slot_w_uniform)
			w_uniform = I
			update_inv_w_uniform()
		if(slot_l_store)
			l_store = I
			update_inv_pockets()
		if(slot_r_store)
			r_store = I
			update_inv_pockets()
		if(slot_s_store)
			s_store = I
			update_inv_s_store()
		if(slot_in_backpack)
			if(get_active_hand() == I)
				unEquip(I)
			I.forceMove(back)
		if(slot_tie)
			var/obj/item/clothing/under/uniform = src.w_uniform
			uniform.attackby(I, src)
		else
			to_chat(src, "<span class='warning'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>")

/mob/living/carbon/human/put_in_hands(obj/item/I)
	if(!I)
		return FALSE
	if(istype(I, /obj/item/stack))
		var/obj/item/stack/S = I
		if(!S.get_amount())
			qdel(I)
			return FALSE
	if(put_in_active_hand(I))
		return TRUE
	else if(put_in_inactive_hand(I))
		return TRUE
	else
		. = ..()

// Return the item currently in the slot ID
/mob/living/carbon/human/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_back)
			return back
		if(slot_wear_mask)
			return wear_mask
		if(slot_handcuffed)
			return handcuffed
		if(slot_legcuffed)
			return legcuffed
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
		if(slot_belt)
			return belt
		if(slot_wear_id)
			return wear_id
		if(slot_wear_pda)
			return wear_pda
		if(slot_l_ear)
			return l_ear
		if(slot_r_ear)
			return r_ear
		if(slot_glasses)
			return glasses
		if(slot_gloves)
			return gloves
		if(slot_head)
			return head
		if(slot_shoes)
			return shoes
		if(slot_wear_suit)
			return wear_suit
		if(slot_w_uniform)
			return w_uniform
		if(slot_l_store)
			return l_store
		if(slot_r_store)
			return r_store
		if(slot_s_store)
			return s_store
	return null

/mob/living/carbon/human/get_all_slots()
	. = get_head_slots() | get_body_slots()

/mob/living/carbon/human/proc/get_body_slots()
	return list(
		l_hand,
		r_hand,
		back,
		s_store,
		handcuffed,
		legcuffed,
		wear_suit,
		gloves,
		shoes,
		belt,
		wear_id,
		wear_pda,
		l_store,
		r_store,
		w_uniform
		)

/mob/living/carbon/human/proc/get_head_slots()
	return list(
		head,
		wear_mask,
		glasses,
		r_ear,
		l_ear,
		)

// humans have their pickpocket gloves, so they get no message when stealing things
/mob/living/carbon/human/stripPanelUnequip(obj/item/what, mob/who, where)
	var/is_silent = 0
	var/obj/item/clothing/gloves/G = gloves
	if(istype(G))
		is_silent = G.pickpocket

	..(what, who, where, silent = is_silent)

// humans have their pickpocket gloves, so they get no message when stealing things
/mob/living/carbon/human/stripPanelEquip(obj/item/what, mob/who, where)
	var/is_silent = 0
	var/obj/item/clothing/gloves/G = gloves
	if(istype(G))
		is_silent = G.pickpocket

	..(what, who, where, silent = is_silent)

/mob/living/carbon/human/can_equip(obj/item/I, slot, disable_warning = FALSE)
	return dna.species.can_equip(I, slot, disable_warning, src)

/mob/living/carbon/human/proc/equipOutfit(outfit, visualsOnly = FALSE)
	var/datum/outfit/O = null

	if(ispath(outfit))
		O = new outfit
	else
		O = outfit
		if(!istype(O))
			return 0
	if(!O)
		return 0

	return O.equip(src, visualsOnly)

//delete all equipment without dropping anything
/mob/living/carbon/human/proc/delete_equipment()
	for(var/slot in get_all_slots())//order matters, dependant slots go first
		qdel(slot)

/mob/living/carbon/human/proc/quick_equip_item(slot_item) // puts things in belt or bag
	var/obj/item/thing = get_active_hand()
	var/obj/item/storage/equipped_item = get_item_by_slot(slot_item)
	if(ismecha(loc) || HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(!istype(equipped_item)) // We also let you equip things like this
		equip_to_slot_if_possible(thing, slot_item)
		return
	if(thing && equipped_item.can_be_inserted(thing)) // put thing in belt or bag
		equipped_item.handle_item_insertion(thing)
		playsound(loc, "rustle", 50, 1, -5)
