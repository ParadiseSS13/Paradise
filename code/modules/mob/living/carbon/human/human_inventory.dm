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
		if(SLOT_HUD_BACK)
			return has_organ("chest")
		if(SLOT_HUD_WEAR_MASK)
			return has_organ("head")
		if(SLOT_HUD_HANDCUFFED)
			return has_organ("l_hand") && has_organ("r_hand")
		if(SLOT_HUD_LEGCUFFED)
			return has_organ("l_leg") && has_organ("r_leg")
		if(SLOT_HUD_LEFT_HAND)
			return has_organ("l_hand")
		if(SLOT_HUD_RIGHT_HAND)
			return has_organ("r_hand")
		if(SLOT_HUD_BELT)
			return has_organ("chest")
		if(SLOT_HUD_WEAR_ID)
			// the only relevant check for this is the uniform check
			return TRUE
		if(SLOT_HUD_WEAR_PDA)
			return TRUE
		if(SLOT_HUD_LEFT_EAR)
			return has_organ("head")
		if(SLOT_HUD_RIGHT_EAR)
			return has_organ("head")
		if(SLOT_HUD_GLASSES)
			return has_organ("head")
		if(SLOT_HUD_GLOVES)
			return has_organ("l_hand") && has_organ("r_hand")
		if(SLOT_HUD_HEAD)
			return has_organ("head")
		if(SLOT_HUD_SHOES)
			return has_organ("r_foot") && has_organ("l_foot")
		if(SLOT_HUD_OUTER_SUIT)
			return has_organ("chest")
		if(SLOT_HUD_JUMPSUIT)
			return has_organ("chest")
		if(SLOT_HUD_LEFT_STORE)
			return has_organ("chest")
		if(SLOT_HUD_RIGHT_STORE)
			return has_organ("chest")
		if(SLOT_HUD_SUIT_STORE)
			return has_organ("chest")
		if(SLOT_HUD_IN_BACKPACK)
			return TRUE
		if(SLOT_HUD_TIE)
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
		if(belt && !(belt.flags_2 & ALLOW_BELT_NO_JUMPSUIT_2))
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
		if(SLOT_HUD_BACK)
			back = I
			update_inv_back()
		if(SLOT_HUD_WEAR_MASK)
			wear_mask = I
			if((wear_mask.flags & BLOCKHAIR) || (wear_mask.flags & BLOCKHEADHAIR))
				update_hair()	//rebuild hair
				update_fhair()
				update_head_accessory()
			if(hud_list.len)
				sec_hud_set_ID()
			wear_mask_update(I, toggle_off = TRUE)
			update_inv_wear_mask()
		if(SLOT_HUD_HANDCUFFED)
			handcuffed = I
			update_inv_handcuffed()
		if(SLOT_HUD_LEGCUFFED)
			legcuffed = I
			update_inv_legcuffed()
		if(SLOT_HUD_LEFT_HAND)
			l_hand = I
			update_inv_l_hand()
		if(SLOT_HUD_RIGHT_HAND)
			r_hand = I
			update_inv_r_hand()
		if(SLOT_HUD_BELT)
			belt = I
			update_inv_belt()
		if(SLOT_HUD_WEAR_ID)
			wear_id = I
			if(hud_list.len)
				sec_hud_set_ID()
			update_inv_wear_id()
		if(SLOT_HUD_WEAR_PDA)
			wear_pda = I
			update_inv_wear_pda()
		if(SLOT_HUD_LEFT_EAR)
			l_ear = I
			if(l_ear.slot_flags & SLOT_FLAG_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(I)
				O.forceMove(src)
				r_ear = O
				O.layer = ABOVE_HUD_LAYER
				O.plane = ABOVE_HUD_PLANE
			update_inv_ears()
		if(SLOT_HUD_RIGHT_EAR)
			r_ear = I
			if(r_ear.slot_flags & SLOT_FLAG_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(I)
				O.forceMove(src)
				l_ear = O
				O.layer = ABOVE_HUD_LAYER
				O.plane = ABOVE_HUD_PLANE
			update_inv_ears()
		if(SLOT_HUD_GLASSES)
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
		if(SLOT_HUD_GLOVES)
			gloves = I
			update_inv_gloves()
		if(SLOT_HUD_HEAD)
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
		if(SLOT_HUD_SHOES)
			shoes = I
			update_inv_shoes()
		if(SLOT_HUD_OUTER_SUIT)
			wear_suit = I
			if(wear_suit.flags_inv & HIDESHOES)
				update_inv_shoes()
			update_inv_wear_suit()
		if(SLOT_HUD_JUMPSUIT)
			w_uniform = I
			update_inv_w_uniform()
		if(SLOT_HUD_LEFT_STORE)
			l_store = I
			update_inv_pockets()
		if(SLOT_HUD_RIGHT_STORE)
			r_store = I
			update_inv_pockets()
		if(SLOT_HUD_SUIT_STORE)
			s_store = I
			update_inv_s_store()
		if(SLOT_HUD_IN_BACKPACK)
			if(get_active_hand() == I)
				unEquip(I)
			if(ismodcontrol(back))
				var/obj/item/mod/control/C = back
				if(C.bag)
					I.forceMove(C.bag)
			else
				I.forceMove(back)
		if(SLOT_HUD_TIE)
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
		if(SLOT_HUD_BACK)
			return back
		if(SLOT_HUD_WEAR_MASK)
			return wear_mask
		if(SLOT_HUD_HANDCUFFED)
			return handcuffed
		if(SLOT_HUD_LEGCUFFED)
			return legcuffed
		if(SLOT_HUD_LEFT_HAND)
			return l_hand
		if(SLOT_HUD_RIGHT_HAND)
			return r_hand
		if(SLOT_HUD_BELT)
			return belt
		if(SLOT_HUD_WEAR_ID)
			return wear_id
		if(SLOT_HUD_WEAR_PDA)
			return wear_pda
		if(SLOT_HUD_LEFT_EAR)
			return l_ear
		if(SLOT_HUD_RIGHT_EAR)
			return r_ear
		if(SLOT_HUD_GLASSES)
			return glasses
		if(SLOT_HUD_GLOVES)
			return gloves
		if(SLOT_HUD_HEAD)
			return head
		if(SLOT_HUD_SHOES)
			return shoes
		if(SLOT_HUD_OUTER_SUIT)
			return wear_suit
		if(SLOT_HUD_JUMPSUIT)
			return w_uniform
		if(SLOT_HUD_LEFT_STORE)
			return l_store
		if(SLOT_HUD_RIGHT_STORE)
			return r_store
		if(SLOT_HUD_SUIT_STORE)
			return s_store
	return null

/mob/living/carbon/human/get_all_slots()
	. = get_body_slots() | get_head_slots()

/mob/living/carbon/human/proc/get_body_slots()
	return list(
		back,
		l_hand,
		r_hand,
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
